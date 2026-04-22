/*
    GLT_Trials_fnc_updateBaseScreens
    Draw3D-time HUD for in-vehicle trial overlay (not the placed terminal Rsc).
*/

if (!hasInterface) exitWith {};
if (!GLT_Trials_clientHudShown) exitWith {};
// While the terminal Rsc (88100) is open, don't draw the in-vehicle hint HUD on top of it.
if (!isNull findDisplay 88100) exitWith {};

// Throttle hint updates (Draw3D can be very frequent)
if (isNil "GLT_Trials_lastHintUpdate") then { GLT_Trials_lastHintUpdate = 0 };
if ((time - GLT_Trials_lastHintUpdate) < 0.2) exitWith {};
GLT_Trials_lastHintUpdate = time;

if (isNil "GLT_Trials_activeRunsPublic") exitWith {};
if (isNil "GLT_Trials_recentRunsPublic") exitWith {};

private _myUID = getPlayerUID player;
private _myRunId = parseNumber (str GLT_Trials_clientRunId);
private _myRun = [] call GLT_Trials_fnc_resolveClientHudRun;

private _screenATop = "<t size='1.1' color='#00e5ff'>Trials</t><br/>";

private _myLine = "";
private _now = time;
private _skipFinalHint = false;

// Track last seen run row so we can show a short finish/ended message when the row disappears.
if (isNil "GLT_Trials_lastSeenRunRow") then { GLT_Trials_lastSeenRunRow = [] };
if (isNil "GLT_Trials_lastSeenRunAt") then { GLT_Trials_lastSeenRunAt = -1 };
if (isNil "GLT_Trials_finishHudUntil") then { GLT_Trials_finishHudUntil = -1 };

if ((count _myRun) isEqualTo 0) then {
    private _showRecent = false;
    if ((count GLT_Trials_lastSeenRunRow) > 0 && { GLT_Trials_finishHudUntil > _now }) then {
        _showRecent = true;
    };

    // Only while waiting for the *first* server row for this run (after OK). After we've seen a row once,
    // an empty list means the run finished — do not show "syncing" or hit timeout after the finish banner.
    private _syncedOnce = missionNamespace getVariable ["GLT_Trials_clientRunSyncedOnce", false];
    private _pendingLocalRun = GLT_Trials_clientHudShown && { _myRunId >= 0 } && {!_syncedOnce};
    if (_pendingLocalRun && {!_showRecent}) then {
        if (isNil "GLT_Trials_clientRunSyncStarted") then { GLT_Trials_clientRunSyncStarted = -1 };
        if (GLT_Trials_clientRunSyncStarted < 0) then { GLT_Trials_clientRunSyncStarted = _now };
        private _grace = 5;
        if ((_now - GLT_Trials_clientRunSyncStarted) < _grace) then {
            _myLine = "<t size='0.9' color='#ffcc00'>Starting trial… (syncing with server)</t><br/>";
            _skipFinalHint = false;
        } else {
            GLT_Trials_clientRunSyncStarted = -1;
            GLT_Trials_clientHudShown = false;
            GLT_Trials_clientRunId = -1;
            GLT_Trials_clientRunSyncedOnce = false;
            GLT_Trials_lastSeenRunRow = [];
            GLT_Trials_lastSeenRunAt = -1;
            GLT_Trials_finishHudUntil = -1;
            [] call GLT_Trials_fnc_deleteTrialRouteMarkers;
            hintSilent "Time Trials: run did not appear from server (timeout).";
            _skipFinalHint = true;
        };
    };

    if (_showRecent) then {
        private _trialName = GLT_Trials_lastSeenRunRow param [5, ""];
        private _elapsed = GLT_Trials_lastSeenRunRow param [7, 0];
        private _segmentType = GLT_Trials_lastSeenRunRow param [9, ""];
        private _lastRunId = parseNumber (str (GLT_Trials_lastSeenRunRow param [0, -1]));

        private _completed = false;
        private _fromServer = false;
        private _runPilotUid = GLT_Trials_lastSeenRunRow param [1, _myUID];
        if (!isNil "GLT_Trials_runEndBroadcast" && {(count GLT_Trials_runEndBroadcast) > 0}) then {
            private _sigIdx = GLT_Trials_runEndBroadcast findIf {
                (count _x) >= 4
                && {(parseNumber (str (_x select 0))) isEqualTo _lastRunId}
                && {(_x select 1) isEqualTo _runPilotUid}
            };
            if (_sigIdx >= 0) then {
                (GLT_Trials_runEndBroadcast select _sigIdx) params ["_sigRunId", "_sigUid", "_sigDone", "_sigElapsed"];
                _fromServer = true;
                _completed = _sigDone isEqualTo true;
                _elapsed = _sigElapsed;
            };
        };

        if (_fromServer) then {
            if (_completed) then {
                _myLine = format [
                    "<t size='0.9' color='#7CFC00'>Finished: %1<br/>Final Time: %2</t><br/>",
                    _trialName,
                    [_elapsed] call BIS_fnc_secondsToString
                ];
            } else {
                _myLine = "<t size='0.9' color='#ff8866'>Run discarded (not completed).</t><br/>";
            };
            if (GLT_Trials_nextMarkerName in allMapMarkers) then { deleteMarkerLocal GLT_Trials_nextMarkerName; };
        } else {
            private _wpIdx = parseNumber (str (GLT_Trials_lastSeenRunRow param [10, 0]));
            private _wpTot = parseNumber (str (GLT_Trials_lastSeenRunRow param [11, 1]));
            private _onLastWaypoint = (_wpTot > 0) && { (_wpIdx + 1) >= _wpTot };
            if (_onLastWaypoint || {_segmentType isEqualTo "END"}) then {
                _myLine = format [
                    "<t size='0.9' color='#7CFC00'>Finished: %1<br/>Final Time: %2</t><br/>",
                    _trialName,
                    [_elapsed] call BIS_fnc_secondsToString
                ];
                if (GLT_Trials_nextMarkerName in allMapMarkers) then { deleteMarkerLocal GLT_Trials_nextMarkerName; };
            } else {
                _myLine = "<t size='0.9' color='#ffcc00'>Run ended.</t><br/>";
            };
        };
    } else {
        // No active run and finish message timeout expired: hide HUD unless waiting for public row (above).
        if (!_pendingLocalRun || {_showRecent}) then {
            GLT_Trials_clientRunSyncStarted = -1;
            GLT_Trials_clientHudShown = false;
            GLT_Trials_clientRunId = -1;
            GLT_Trials_clientRunSyncedOnce = false;
            GLT_Trials_lastSeenRunRow = [];
            GLT_Trials_lastSeenRunAt = -1;
            GLT_Trials_finishHudUntil = -1;
            [] call GLT_Trials_fnc_deleteTrialRouteMarkers;
            hintSilent "";
            _skipFinalHint = true;
        };
    };
} else {
    GLT_Trials_clientRunSyncedOnce = true;
    GLT_Trials_clientRunSyncStarted = -1;
    GLT_Trials_lastSeenRunRow = +_myRun;
    GLT_Trials_lastSeenRunAt = _now;
    GLT_Trials_finishHudUntil = _now + 15;

    private _trialName = _myRun param [5, ""];
    private _segmentDesc = _myRun param [6, ""];
    private _elapsed = _myRun param [7, 0];
    private _wpIndex = _myRun param [10, 0];
    private _wpTotal = _myRun param [11, 0];
    private _segType = _myRun param [9, ""];
    private _wpIdxN = parseNumber (str _wpIndex);
    private _wpTotN = parseNumber (str _wpTotal);

    _myLine = format [
        "<t size='0.9' color='#ffffff'>%1<br/>Waypoint: %2 / %3<br/>%4<br/>Elapsed: %5</t><br/>",
        _trialName,
        (_wpIdxN + 1) max 1,
        (_wpTotN max 1),
        _segmentDesc,
        [_elapsed] call BIS_fnc_secondsToString
    ];

    if ((_segType isEqualTo "SLING_DELIVER_CIRCLE") || { _segType isEqualTo "SLING_DELIVER_RECT" }) then {
        private _center = _myRun param [8, [0, 0, 0]];
        private _viz = _myRun param [19, -1];
        private _netId = _myRun param [20, ""];
        private _cargo = objNull;

        if (_netId != "") then {
            _cargo = objectFromNetId _netId;
        };
        if (isNull _cargo) then {
            private _vehA = vehicle player;
            if (_vehA != player) then {
                private _slA = getSlingLoad _vehA;
                if (!isNull _slA) then {
                    _cargo = _slA;
                };
            };
        };

        private _zoneStr = "Cargo: not found (pick up first)";
        private _hookStr = "";
        private _distStr = "To Center: -";
        private _clockStr = "";

        if (!isNull _cargo) then {
            private _cargoPos = getPosWorld _cargo;
            private _dist2D = _cargoPos distance2D _center;
            private _d10 = round (_dist2D * 10);
            private _whole = floor (_d10 / 10);
            private _frac = _d10 mod 10;
            private _dFmt = "";
            if (_frac isEqualTo 0) then { _dFmt = str _whole } else { _dFmt = (str _whole) + "." + (str _frac) };
            _distStr = "" + _dFmt + " m";

            private _inZone = false;
            if (_segType isEqualTo "SLING_DELIVER_CIRCLE") then {
                private _rad = _viz select 1;
                _inZone = (_dist2D <= _rad);
            } else {
                private _axisR = _viz select 1;
                private _axisF = _viz select 2;
                private _hw = _viz select 3;
                private _hl = _viz select 4;
                _inZone = [_cargoPos, _center, _axisR, _axisF, _hw, _hl] call GLT_Trials_fnc_pointInSlingRect;
            };
            if (_inZone) then { _zoneStr = "Cargo: in zone" } else { _zoneStr = "Cargo: outside zone" };

            private _vehB = vehicle player;
            private _onHook = false;
            if (_vehB != player) then {
                private _slB = getSlingLoad _vehB;
                if (!isNull _slB) then {
                    if (_slB == _cargo) then { _onHook = true };
                };
                if (!_onHook) then {
                    _onHook = (_cargo getVariable ["PTF_RopesAttached", 0] > 0);
                };
            } else {
                _onHook = (_cargo getVariable ["PTF_RopesAttached", 0] > 0);
            };
            if (_onHook) then { _hookStr = "Hook: attached" } else { _hookStr = "Hook: released" };

            private _fromPos = _cargoPos;
            if (_vehB != player) then {
                _fromPos = getPosWorld _vehB;
            };
            private _dirToCenter = [_fromPos, _center] call BIS_fnc_dirTo;
            private _refDir = if (_vehB != player) then { getDir _vehB } else { getDir player };
            private _rel = _dirToCenter - _refDir;
            if (_rel < 0) then { _rel = _rel + 360 };
            if (_rel >= 360) then { _rel = _rel - 360 };
            private _sector = floor ((_rel + 15) / 30);
            if (_sector >= 12) then { _sector = 0 };
            private _clock = if (_sector isEqualTo 0) then { 12 } else { _sector };
            _clockStr = "Center: " + (str _clock) + " o'clock";
        };

        _myLine = _myLine + "<t size='0.8' color='#6f6f6f'>--------------------</t><br/>";
        _myLine = _myLine + "<t size='0.85' color='#bdefff'>Sling delivery</t><br/>";
        _myLine = _myLine + "<t size='0.82' color='#ffffff'>" + _zoneStr + "<br/>" + _hookStr + "<br/>" + _distStr + " - " + _clockStr + "</t>";
    };

    // Same distance + clock reference as sling delivery, using trial vehicle position vs waypoint center.
    if ((_segType isEqualTo "HOVER_POINT") || { _segType isEqualTo "LAND_POINT" }) then {
        private _centerHL = _myRun param [8, [0, 0, 0]];
        private _radHL = _myRun param [23, -1];
        if ((count _centerHL) >= 3) then {
            private _vehHL = vehicle player;
            private _fromPosHL = if (_vehHL != player) then { getPosWorld _vehHL } else { getPosWorld player };
            private _dist2DHL = _fromPosHL distance2D _centerHL;
            private _d10hl = round (_dist2DHL * 10);
            private _wholehl = floor (_d10hl / 10);
            private _frachl = _d10hl mod 10;
            private _dFmtHL = "";
            if (_frachl isEqualTo 0) then { _dFmtHL = str _wholehl } else { _dFmtHL = (str _wholehl) + "." + (str _frachl) };
            private _distLineHL = _dFmtHL + " m";

            private _zoneStrHL = "";
            if (_radHL > 0) then {
                if (_dist2DHL <= _radHL) then {
                    _zoneStrHL = "Vehicle: within radius";
                } else {
                    _zoneStrHL = "Vehicle: outside radius";
                };
            } else {
                _zoneStrHL = "Vehicle: distance to center";
            };

            private _dirToC = [_fromPosHL, _centerHL] call BIS_fnc_dirTo;
            private _refDirHL = if (_vehHL != player) then { getDir _vehHL } else { getDir player };
            private _relHL = _dirToC - _refDirHL;
            if (_relHL < 0) then { _relHL = _relHL + 360 };
            if (_relHL >= 360) then { _relHL = _relHL - 360 };
            private _sectorHL = floor ((_relHL + 15) / 30);
            if (_sectorHL >= 12) then { _sectorHL = 0 };
            private _clockHL = if (_sectorHL isEqualTo 0) then { 12 } else { _sectorHL };
            private _clockStrHL = "Center: " + (str _clockHL) + " o'clock";

            private _titleHL = if (_segType isEqualTo "HOVER_POINT") then { "Hover zone" } else { "Landing zone" };

            _myLine = _myLine + "<t size='0.8' color='#6f6f6f'>--------------------</t><br/>";
            _myLine = _myLine + "<t size='0.85' color='#bdefff'>" + _titleHL + "</t><br/>";
            _myLine = _myLine + "<t size='0.82' color='#ffffff'>" + _zoneStrHL + "<br/>" + _distLineHL + " - " + _clockStrHL + "</t>";
        };
    };

    // Map route: all waypoints; current objective green (1), others black (0.5).
    private _tid = _myRun param [13, ""];
    private _route = [];
    if (!isNil "GLT_Trials_trials" && { _tid isNotEqualTo "" }) then {
        {
            if ((_x select 0) isEqualTo _tid) exitWith {
                _route = _x param [7, []];
            };
        } forEach GLT_Trials_trials;
    };
    if ((count _route) > 0) then {
        private _segType = _myRun param [9, ""];
        private _wpIndex = _myRun param [10, 0];
        private _activeR = _wpIndex;
        [_route, _activeR] call GLT_Trials_fnc_updateTrialRouteMarkers;
    } else {
        private _segPos = _myRun param [8, []];
        private _st = _myRun param [9, ""];
        if ((count _segPos) >= 3) then {
            private _kind = if (_st isEqualTo "END") then { "END" } else { _st };
            [[[_kind, _segPos]], 0] call GLT_Trials_fnc_updateTrialRouteMarkers;
        };
    };
};

if (!_skipFinalHint) then {
    hintSilent parseText (_screenATop + _myLine);
};

true

