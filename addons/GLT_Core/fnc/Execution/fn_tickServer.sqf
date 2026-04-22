/*
    GLT_Trials_fnc_tickServer
    Server tick for active runs.
    Params: [_now]
*/

params ["_now"];
if (!isServer) exitWith {};
if (!(missionNamespace getVariable ["GLT_Trials_trialsAvailable", false]) && { (count GLT_Trials_activeRunsPrivate) isEqualTo 0 }) exitWith { true };

if (isNil "GLT_Trials_lastBroadcastTime") then {
    GLT_Trials_lastBroadcastTime = 0;
};

private _broadcastInterval = 0.25;
private _activePublic = [];
private _runEndSignals = [];

// Iterate and keep only non-finished runs.
private _remaining = [];
{
    private _run = _x;
    private _finished = false;
    if (_run getOrDefault ["pilotCancelRequested", false]) then {
        _run set ["didFinish", false];
        _finished = true;
    } else {
        _finished = [_run, _now] call GLT_Trials_fnc_updateRunState;
    };

    if (_finished) then {
        // Finished run: finalize leaderboard and skip from active list.
        // updateRunState returns true also for abort cases (e.g., destroyed trial vehicle).
        // We only record leaderboard if this was a real finish (not an abort).
        private _completed = (_run get "didFinish") isEqualTo true;
        private _startTime = _run get "startTime";
        private _elapsedShow = 0;
        if (_startTime >= 0) then {
            _elapsedShow = _now - _startTime;
            if (_elapsedShow < 0) then { _elapsedShow = 0 };
        };
        if (_completed) then {
            [_run, _now] call GLT_Trials_fnc_finishRun;
        } else {
            [_run] call GLT_Trials_fnc_cleanupSlingCargo;
            [_run] call GLT_Trials_fnc_cleanupDestroyTargets;
        };
        _runEndSignals pushBack [
            _run get "runId",
            _run get "pilotUID",
            _completed,
            _elapsedShow
        ];
    } else {
        _remaining pushBack _run;

        // Build public run state for HUD.
        private _trial = GLT_Trials_trialsById getOrDefault [_run get "trialId", nil];
        if (!isNil "_trial") then {
            private _segments = _trial select 9;
            private _segIdx = _run get "segmentIndex";
            private _segCount = _run get "segmentsCount";
            private _segmentDesc = "";
            private _segmentPos = [0,0,0];
            private _segmentType = "";

            // MapGrid uses lastPosWorld; that's always updated by updateRunState.
            private _startTime = _run get "startTime";
            private _nowElapsed = if (_startTime < 0) then {0} else { _now - _startTime };

            if (_segIdx < count _segments) then {
                private _seg = _segments select _segIdx;
                _segmentType = _seg select 0;
                _segmentPos = _seg select 2;

                switch (_segmentType) do {
                    case "CROSS_GATE": {
                        _segmentDesc = format ["Fly through gate %1", _segIdx + 1];
                    };
                    case "HOVER_POINT": {
                        _segmentDesc = format ["Hover above %1", _segIdx + 1];
                    };
                    case "LAND_POINT": {
                        _segmentDesc = format ["Land at %1", _segIdx + 1];
                    };
                    case "SLING_PICKUP": {
                        _segmentDesc = format ["Sling pickup %1", _segIdx + 1];
                    };
                    case "SLING_DELIVER_CIRCLE";
                    case "SLING_DELIVER_RECT": {
                        _segmentDesc = format ["Sling deliver %1", _segIdx + 1];
                    };
                    case "DESTROY_TARGET": {
                        private _disp = _seg select 7;
                        private _targetObj = _run getOrDefault ["destroyCurrentObj", objNull];
                        private _targetPos = _seg select 2;
                        if (!isNull _targetObj) then {
                            _targetPos = getPosWorld _targetObj;
                        };
                        private _gridT = mapGridPosition _targetPos;
                        _segmentPos = _targetPos;
                        _segmentDesc = format ["Destroy %1 at %2", _disp, _gridT];
                    };
                    case "DESTROY_INFANTRY": {
                        private _disp = _seg select 6;
                        private _targetObj = _run getOrDefault ["destroyCurrentObj", objNull];
                        private _targetPos = _seg select 2;
                        if (!isNull _targetObj) then {
                            _targetPos = getPosWorld _targetObj;
                        };
                        private _gridT = mapGridPosition _targetPos;
                        _segmentPos = _targetPos;
                        _segmentDesc = format ["Eliminate %1 at %2", _disp, _gridT];
                    };
                    default { _segmentDesc = "Segment"; };
                };
            } else {
                // segmentIndex out of range while run still listed — should not happen; show last segment.
                if ((count _segments) > 0) then {
                    private _segF = _segments select ((count _segments) - 1);
                    _segmentType = _segF select 0;
                    _segmentPos = _segF select 2;
                    _segmentDesc = "Finalizing…";
                };
            };

            // Hover / land progress bar (client): mission-time stamp when accumulating; -1 = not in zone.
            // Indices 14–15 reused for HOVER_POINT and LAND_POINT (same HUD bar).
            private _hoverBarStart = -1;
            private _hoverBarDur = 0;
            if (
                _segmentType isEqualTo "HOVER_POINT"
                && {_segIdx >= 0}
                && {_segIdx < count _segments}
            ) then {
                private _segH = _segments select _segIdx;
                if ((_segH select 0) isEqualTo "HOVER_POINT") then {
                    _hoverBarDur = _segH select 6;
                    private _hst = _run get "hoverStartTime";
                    if (_hst >= 0) then { _hoverBarStart = _hst };
                };
            } else {
                if (
                    _segmentType isEqualTo "LAND_POINT"
                    && {_segIdx >= 0}
                    && {_segIdx < count _segments}
                ) then {
                    private _segL = _segments select _segIdx;
                    if ((_segL select 0) isEqualTo "LAND_POINT") then {
                        _hoverBarDur = _segL select 4;
                        private _lst = _run get "landStayStartTime";
                        if (_lst >= 0) then { _hoverBarStart = _lst };
                    };
                };
            };

            private _grid = mapGridPosition (_run get "lastPosWorld");

            // Waypoint info for HUD: one waypoint per segment (trial completes at the last).
            private _totalWaypoints = _segCount max 1;
            private _wpIndex = 0;
            if (_segIdx >= 0) then { _wpIndex = _segIdx };

            // Next waypoint position (for circle orientation on the client).
            private _nextPos = _segmentPos;
            if ((_segIdx + 1) < count _segments) then {
                _nextPos = (_segments select (_segIdx + 1)) select 2;
            } else {
                _nextPos = (_segments select _segIdx) select 2;
            };

            // Client hover helper lights (indices 16–17); -1 when not on HOVER_POINT.
            private _hLightDimFar = -1;
            private _hLightDimClose = -1;
            if (
                _segmentType isEqualTo "HOVER_POINT"
                && {_segIdx >= 0}
                && {_segIdx < count _segments}
            ) then {
                private _segL = _segments select _segIdx;
                if ((_segL select 0) isEqualTo "HOVER_POINT") then {
                    _hLightDimFar = _segL select 7;
                    _hLightDimClose = _segL select 8;
                };
            };

            // Sling deliver: index 18 = rect light state (0 red, 1 yellow, 2 green), -1 if N/A.
            // Index 19 = viz bundle for client cones/lights (see fn_syncSlingDeliverVisuals).
            // Index 20 = netId of trial sling cargo (for client HUD), or "".
            // Index 21 = active destroy target position ASL for red smoke ([] when N/A).
            // Index 22 = netId of trial vehicle (for MP crew/passenger HUD sync), or "".
            // Index 23 = horizontal radius (m) of current waypoint for HOVER_POINT / LAND_POINT (HUD distance ring); -1 if N/A.
            private _segmentHorizRadius = -1;
            if (
                (_segmentType isEqualTo "HOVER_POINT" || {_segmentType isEqualTo "LAND_POINT"})
                && {_segIdx >= 0}
                && {_segIdx < count _segments}
            ) then {
                private _segZ = _segments select _segIdx;
                if ((_segZ select 0) isEqualTo _segmentType) then {
                    _segmentHorizRadius = _segZ select 3;
                };
            };

            private _slingLightState = -1;
            private _slingViz = -1;
            private _destroySmokePos = [];
            private _heliPosWorld = _run get "lastPosWorld";
            if (
                _segIdx >= 0
                && {_segIdx < count _segments}
            ) then {
                private _segS = _segments select _segIdx;
                private _st = _segS select 0;
                private _cargo = _run get "slingCargoObj";
                if (isNil "_cargo") then { _cargo = objNull };

                if (_st isEqualTo "SLING_DELIVER_CIRCLE") then {
                    private _rad = _segS select 3;
                    private _center = _segS select 2;
                    _slingViz = [0, _rad];

                    private _heliInZone = (_heliPosWorld distance2D _center) <= _rad;
                    if (isNull _cargo) then {
                        _slingLightState = 0;
                    } else {
                        private _onHook = false;
                        private _sl = getSlingLoad (_run get "heli");
                        if (!isNull _sl) then {
                            _onHook = (_sl == _cargo);
                        } else {
                            _onHook = (_cargo getVariable ["PTF_RopesAttached", 0] > 0);
                        };

                        if (_heliInZone) then {
                            if (_onHook) then { _slingLightState = 1 } else { _slingLightState = 2 };
                        } else {
                            _slingLightState = 0;
                        };
                    };
                };

                if (_st isEqualTo "SLING_DELIVER_RECT") then {
                    _slingViz = [
                        1,
                        _segS select 3,
                        _segS select 4,
                        _segS select 5,
                        _segS select 6,
                        _segS select 7,
                        _segS select 8
                    ];
                    private _center = _segS select 2;
                    private _axisR = _segS select 3;
                    private _axisF = _segS select 4;
                    private _halfW = _segS select 5;
                    private _halfL = _segS select 6;
                    private _heliInZone = [_heliPosWorld, _center, _axisR, _axisF, _halfW, _halfL] call GLT_Trials_fnc_pointInSlingRect;
                    if (isNull _cargo) then {
                        _slingLightState = 0;
                    } else {
                        private _onHook = false;
                        private _sl = getSlingLoad (_run get "heli");
                        if (!isNull _sl) then {
                            _onHook = (_sl == _cargo);
                        } else {
                            _onHook = (_cargo getVariable ["PTF_RopesAttached", 0] > 0);
                        };
                        if (_heliInZone) then {
                            if (_onHook) then {
                                _slingLightState = 1;
                            } else {
                                _slingLightState = 2;
                            };
                        } else {
                            _slingLightState = 0;
                        };
                    };
                };

                if ((_st isEqualTo "DESTROY_TARGET") || { _st isEqualTo "DESTROY_INFANTRY" }) then {
                    private _tgt = _run getOrDefault ["destroyCurrentObj", objNull];
                    if (!isNull _tgt) then {
                        _destroySmokePos = getPosASL _tgt;
                    } else {
                        _destroySmokePos = _segS select 2;
                    };
                };
            };

            private _slingCargoNetId = "";
            if (!isNull (_run getOrDefault ["slingCargoObj", objNull])) then {
                _slingCargoNetId = netId (_run getOrDefault ["slingCargoObj", objNull]);
            };

            private _trialHeliNetId = "";
            private _trialHeli = _run get "heli";
            if (!isNull _trialHeli) then {
                _trialHeliNetId = netId _trialHeli;
            };

            _activePublic pushBack [
                _run get "runId",
                _run get "pilotUID",
                _run get "heliCallsign",
                _run get "pilotName",
                _grid,
                _run get "trialName",
                _segmentDesc,
                _nowElapsed,
                _segmentPos,
                _segmentType,
                _wpIndex,
                _totalWaypoints,
                _nextPos,
                _run get "trialId",
                _hoverBarStart,
                _hoverBarDur,
                _hLightDimFar,
                _hLightDimClose,
                _slingLightState,
                _slingViz,
                _slingCargoNetId,
                _destroySmokePos,
                _trialHeliNetId,
                _segmentHorizRadius
            ];
        };
    };
} forEach GLT_Trials_activeRunsPrivate;

GLT_Trials_activeRunsPrivate = _remaining;
GLT_Trials_activeRunsPublic = _activePublic;

if ((count _runEndSignals) > 0) then {
    GLT_Trials_runEndBroadcast = _runEndSignals;
    publicVariable "GLT_Trials_runEndBroadcast";
};

if ((_now - GLT_Trials_lastBroadcastTime) >= _broadcastInterval) then {
    publicVariable "GLT_Trials_activeRunsPublic";
    if (GLT_Trials_recentRunsDirty) then {
        publicVariable "GLT_Trials_recentRunsPublic";
        GLT_Trials_recentRunsDirty = false;
    };
    GLT_Trials_lastBroadcastTime = _now;
};

// Course visibility: only touch trials whose active-run membership changed (see syncCourseObjectVisibilityFull on register).
if (!isNil "GLT_Trials_trials" && { (count GLT_Trials_trials) > 0 }) then {
    private _nowTids = [];
    {
        _nowTids pushBackUnique (_x get "trialId");
    } forEach GLT_Trials_activeRunsPrivate;

    private _prev = GLT_Trials_courseVisLastActiveTids;
    private _dirtyTids = [];
    {
        if (!(_x in _prev)) then { _dirtyTids pushBackUnique _x };
    } forEach _nowTids;
    {
        if (!(_x in _nowTids)) then { _dirtyTids pushBackUnique _x };
    } forEach _prev;

    if ((count _dirtyTids) > 0) then {
        _dirtyTids call GLT_Trials_fnc_syncCourseObjectVisibilityForTrialIds;
    };
    GLT_Trials_courseVisLastActiveTids = +_nowTids;
};

true

