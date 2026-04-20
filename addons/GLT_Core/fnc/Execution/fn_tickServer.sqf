/*
    GLT_Trials_fnc_tickServer
    Server tick for active runs.
    Params: [_now]
*/

params ["_now"];
if (!isServer) exitWith {};

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
        // updateRunState returns true also for abort cases (e.g., destroyed heli).
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

            // WAIT_START phase: segmentIndex < 0.
            if (_segIdx < 0) then {
                _segmentType = "WAIT_START";
                _segmentPos = _trial select 3; // startPosWorld
                _segmentDesc = "Fly through start";
            } else { if (_segIdx < count _segments) then {
                private _seg = _segments select _segIdx;
                _segmentType = _seg select 0;
                _segmentPos = _seg select 2;

                switch (_segmentType) do {
                    case "CROSS_GATE": {
                        private _r = _seg select 6;
                        _segmentDesc = format ["Cross gate %1 (r=%2m)", _segIdx + 1, _r];
                    };
                    case "HOVER_POINT": {
                        private _r = _seg select 3;
                        private _altMin = _seg select 4;
                        private _altMax = _seg select 5;
                        private _hoverSeconds = _seg select 6;
                        _segmentDesc = format [
                            "Hover at %1 — within %2m, %3–%4m above marker, %5s",
                            _segIdx + 1,
                            _r,
                            _altMin,
                            _altMax,
                            _hoverSeconds
                        ];
                    };
                    case "LAND_POINT": {
                        private _r = _seg select 3;
                        private _staySeconds = _seg select 4;
                        _segmentDesc = format [
                            "Land %1 — on ground (touching), %2s within %3m",
                            _segIdx + 1,
                            _staySeconds,
                            _r
                        ];
                    };
                    case "SLING_PICKUP": {
                        _segmentDesc = format ["Sling pickup %1 — hook cargo", _segIdx + 1];
                    };
                    case "SLING_DELIVER_CIRCLE": {
                        private _r = _seg select 3;
                        _segmentDesc = format ["Sling deliver %1 — circle r=%2m (drop in zone)", _segIdx + 1, _r];
                    };
                    case "SLING_DELIVER_RECT": {
                        private _hw = _seg select 5;
                        private _hl = _seg select 6;
                        _segmentDesc = format ["Sling deliver %1 — rectangle %2×%3m (drop in zone)", _segIdx + 1, _hw * 2, _hl * 2];
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
                private _endCfg = _trial select 8; // [endPosWorld, endRadius, endNormal, endUp, endRight, ...]
                _segmentType = "END";
                _segmentPos = _endCfg select 0;
                _segmentDesc = "Fly through end";
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

            // Waypoint info for HUD:
            // - Waypoints are: each segment + final end zone => total = segmentsCount + 1
            // - Current index starts at 0 for first segment, and equals segmentsCount when at END.
            private _totalWaypoints = _segCount + 1;
            private _wpIndex = 0;
            if (_segmentType isEqualTo "END") then {
                _wpIndex = _segCount;
            } else {
                if (_segIdx >= 0) then { _wpIndex = _segIdx };
            };

            // Next waypoint position (for circle orientation on the client).
            private _nextPos = _segmentPos;
            if (_segmentType isEqualTo "WAIT_START") then {
                // Next objective: first segment if present, otherwise END.
                if (_segCount > 0) then {
                    _nextPos = (_segments select 0) select 2;
                } else {
                    _nextPos = (_trial select 8) select 0;
                };
            } else {
                if (_segmentType isEqualTo "END") then {
                    // _nextPos already matches end (same as _segmentPos).
                } else {
                    // On a segment: next is following segment, or END if this is the last segment.
                    if ((_segIdx + 1) < count _segments) then {
                        _nextPos = (_segments select (_segIdx + 1)) select 2;
                    } else {
                        _nextPos = (_trial select 8) select 0;
                    };
                };
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
            // Index 22 = netId of trial helicopter (for MP crew/passenger HUD sync), or "".
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
                _trialHeliNetId
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
    publicVariable "GLT_Trials_recentRunsPublic";
    GLT_Trials_lastBroadcastTime = _now;
};

[] call GLT_Trials_fnc_syncCourseObjectVisibility;

true

