/*
    GLT_Trials_fnc_updateRunState
    Evaluates current segment completion for one active run.
    Params: [_run, _now]
    Returns: true if the run is finished, false otherwise.
*/

params ["_run", "_now"];

if (isNil "_run") exitWith {false};

private _heli = _run get "heli";
if (isNull _heli) exitWith { _run set ["didFinish", false]; true };
if !(alive _heli) exitWith { _run set ["didFinish", false]; true };
if (isNull (driver _heli)) exitWith { _run set ["didFinish", false]; true };

// Abort if the original pilot is no longer driving.
private _pilotObj = _run get "pilotObj";
if (isNull _pilotObj) exitWith { _run set ["didFinish", false]; true };
if (driver _heli isNotEqualTo _pilotObj) exitWith { _run set ["didFinish", false]; true };

private _trialId = _run get "trialId";
private _trial = GLT_Trials_trialsById getOrDefault [_trialId, nil];
if (isNil "_trial") exitWith { _run set ["didFinish", false]; true };

private _segments = _trial select 9;
private _segmentIndex = _run get "segmentIndex";

private _posWorld = getPosWorld _heli;
private _lastPosWorld = _run get "lastPosWorld";

private _finish = false;

// WAIT_START phase: touch the start object.
// Simplified rule: when the heli is within startRadius (2D), consider it crossed.
if (_segmentIndex < 0) then {
    private _startPosWorld = _trial select 3; // OBB center
    private _startRadius = _trial select 4; // legacy / CENTER_2D
    private _startNormal = _trial select 5;
    private _startUp = _trial select 6;
    private _startRight = _trial select 7;

    private _startTouchMethod = _trial select 10;
    private _startTouchPadding = _trial select 11;
    private _startOBBHalfExtents = _trial select 12;
    private _startSphereCenterWorld = _trial select 13;
    private _startSphereRadius = _trial select 14;

    // Approximate heli hull using boundingBoxReal (works for MP and doesn't rely on boundingSphere*).
    private _axisRightN = vectorNormalized _startRight;
    private _axisUpN = vectorNormalized _startUp;
    private _axisNormalN = vectorNormalized _startNormal;

    private _bb = boundingBoxReal _heli;
    private _bbMin = _bb select 0;
    private _bbMax = _bb select 1;

    private _cx = ((_bbMin select 0) + (_bbMax select 0)) / 2;
    private _cy = ((_bbMin select 1) + (_bbMax select 1)) / 2;
    private _cz = ((_bbMin select 2) + (_bbMax select 2)) / 2;
    private _heliCenterWorld = _heli modelToWorld [_cx, _cy, _cz];

    private _xMin = _bbMin select 0; private _xMax = _bbMax select 0;
    private _yMin = _bbMin select 1; private _yMax = _bbMax select 1;
    private _zMin = _bbMin select 2; private _zMax = _bbMax select 2;

    private _cornersLocal = [
        [_xMin,_yMin,_zMin],
        [_xMin,_yMin,_zMax],
        [_xMin,_yMax,_zMin],
        [_xMin,_yMax,_zMax],
        [_xMax,_yMin,_zMin],
        [_xMax,_yMin,_zMax],
        [_xMax,_yMax,_zMin],
        [_xMax,_yMax,_zMax]
    ];

    private _heliHalfRight = 0;
    private _heliHalfUp = 0;
    private _heliHalfNormal = 0;
    private _heliSphereRadius = 0;

    {
        private _cw = _heli modelToWorld _x;
        private _delta = _cw vectorDiff _heliCenterWorld;

        private _pR = abs (_delta vectorDotProduct _axisRightN);
        private _pU = abs (_delta vectorDotProduct _axisUpN);
        private _pN = abs (_delta vectorDotProduct _axisNormalN);
        if (_pR > _heliHalfRight) then { _heliHalfRight = _pR };
        if (_pU > _heliHalfUp) then { _heliHalfUp = _pU };
        if (_pN > _heliHalfNormal) then { _heliHalfNormal = _pN };

        private _d = sqrt (
            (_delta select 0) * (_delta select 0) +
            (_delta select 1) * (_delta select 1) +
            (_delta select 2) * (_delta select 2)
        );
        if (_d > _heliSphereRadius) then { _heliSphereRadius = _d };
    } forEach _cornersLocal;

    private _crossed = false;
    if (_startTouchMethod isEqualTo 0) then {
        // OBB_HULL: center-in-inflated-OBB using heli half extents projected onto the target axes.
        private _rel = _heliCenterWorld vectorDiff _startPosWorld;

        private _x = abs (_rel vectorDotProduct _axisRightN);
        private _y = abs (_rel vectorDotProduct _axisUpN);
        private _z = abs (_rel vectorDotProduct _axisNormalN);

        private _hx = (_startOBBHalfExtents select 0) + _heliHalfRight + _startTouchPadding;
        private _hy = (_startOBBHalfExtents select 1) + _heliHalfUp + _startTouchPadding;
        private _hz = (_startOBBHalfExtents select 2) + _heliHalfNormal + _startTouchPadding;

        if ((_x <= _hx) && { (_y <= _hy) } && { (_z <= _hz) }) then { _crossed = true };
    } else {
    if (_startTouchMethod isEqualTo 1) then {
        // SPHERE_HULL: sphere-sphere (sphere center uses the OBB center for robustness).
        private _d = _heliCenterWorld distance _startPosWorld;
        if (_d <= (_startSphereRadius + _heliSphereRadius + _startTouchPadding)) then { _crossed = true };
    } else {
    if (_startTouchMethod isEqualTo 2) then {
        // CENTER_2D (legacy).
        private _d2 = _heliCenterWorld distance2D _startPosWorld;
        if (_d2 <= (_startRadius + _startTouchPadding)) then { _crossed = true };
    };
    };
    };

    if (_crossed) then {
        _run set ["startTime", _now];
        _run set ["segmentIndex", 0];
        _run set ["hoverStartTime", -1];
        _run set ["landStayStartTime", -1];
        _run set ["slingStayStartTime", -1];
    };
} else { if (_segmentIndex < count _segments) then {
    private _seg = _segments select _segmentIndex;
    private _segType = _seg select 0;

    private _segmentCompleted = false;

    switch (_segType) do {
        case "CROSS_GATE": {
            // ["CROSS_GATE", idx, gatePosWorld, gateNormal, gateUp, gateRight, gateRadius, gateCrossTolerance]
            private _gatePosWorld = _seg select 2;
            private _gateRadius = _seg select 6;
            // Simplified rule: if the heli touches the gate area, count it as crossed.
            private _dist2D = (_posWorld distance2D _gatePosWorld);
            if (_dist2D <= _gateRadius) then {
                _segmentCompleted = true;
            };
        };

        case "HOVER_POINT": {
            // ["HOVER_POINT", idx, posWorld, radius, altMin, altMax, hoverSeconds, lightDimFar_m, lightDimClose_m]
            private _p = _seg select 2;
            private _radius = _seg select 3;
            private _altMin = _seg select 4;
            private _altMax = _seg select 5;
            private _hoverSeconds = _seg select 6;

            private _dist2D = (_posWorld distance2D _p);
            // Height above marker center (world Z), not terrain AGL — matches "m above asset".
            private _altAbove = (getPosASL _heli select 2) - (_p select 2);

            private _cond = (_dist2D <= _radius) && (_altAbove >= _altMin) && (_altAbove <= _altMax);

            private _hoverStartTime = _run get "hoverStartTime";
            if (_cond) then {
                if (_hoverStartTime < 0) then { _run set ["hoverStartTime", _now] };
                if ((_now - (_run get "hoverStartTime")) >= _hoverSeconds) then {
                    _segmentCompleted = true;
                };
            } else {
                _run set ["hoverStartTime", -1];
            };
        };

        case "LAND_POINT": {
            // ["LAND_POINT", idx, posWorld, radius, staySeconds]
            // Landed = in radius, on ground (engine may stay on), not creeping — no separate max AGL; touching ground is the height check.
            private _p = _seg select 2;
            private _radius = _seg select 3;
            private _staySeconds = _seg select 4;

            private _dist2D = (_posWorld distance2D _p);
            private _spd = speed _heli;

            private _onGround = isTouchingGround _heli;
            private _cond = (_dist2D <= _radius) && (_spd <= 2) && _onGround;

            private _stayStart = _run get "landStayStartTime";
            if (_cond) then {
                if (_stayStart < 0) then { _run set ["landStayStartTime", _now] };
                if ((_now - (_run get "landStayStartTime")) >= _staySeconds) then {
                    _segmentCompleted = true;
                };
            } else {
                _run set ["landStayStartTime", -1];
            };
        };

        case "SLING_PICKUP": {
            // ["SLING_PICKUP", idx, posASL, cargoClass]
            [_run, _seg] call GLT_Trials_fnc_ensureSlingPickupCargo;
            private _cargo = _run get "slingCargoObj";
            if (isNil "_cargo") then { _cargo = objNull };
            if (!isNull _cargo) then {
                private _sl = getSlingLoad _heli;
                if (!isNull _sl && {_sl == _cargo}) then {
                    _segmentCompleted = true;
                };
            };
        };

        case "DESTROY_TARGET": {
            // ["DESTROY_TARGET", segIdx, posASL, vehClass, spawnDriver, spawnGunners, side, displayName, markerObj, skill]
            private _segIdxCfg = _seg select 1;
            private _curObj = _run getOrDefault ["destroyCurrentObj", objNull];
            private _curSeg = _run getOrDefault ["destroyCurrentSegIdx", -999];
            private _needsSpawn = false;

            if (isNull _curObj) then { _needsSpawn = true };
            if (_curSeg isNotEqualTo _segIdxCfg) then { _needsSpawn = true };

            if (_needsSpawn) then {
                private _cfgRow = [
                    _seg select 1,
                    _seg select 2,
                    _seg select 3,
                    _seg select 4,
                    _seg select 5,
                    _seg select 6,
                    _seg select 7,
                    _seg select 8,
                    _seg select 9
                ];
                private _pilot = _run getOrDefault ["pilotObj", objNull];
                private _spawned = [_cfgRow, _pilot] call GLT_Trials_fnc_spawnDestroyTarget;
                _run set ["destroyCurrentObj", _spawned];
                _run set ["destroyCurrentSegIdx", _segIdxCfg];
                if (!isNull _spawned) then {
                    private _mandatory = _run getOrDefault ["destroyMandatoryObjs", []];
                    _mandatory pushBackUnique _spawned;
                    _run set ["destroyMandatoryObjs", _mandatory];
                };
            };

            private _targetObj = _run getOrDefault ["destroyCurrentObj", objNull];
            if ([_targetObj] call GLT_Trials_fnc_isDestroyTargetComplete) then {
                _segmentCompleted = true;
            };
        };

        case "DESTROY_INFANTRY": {
            // ["DESTROY_INFANTRY", segIdx, posASL, infClass, count, skill, displayName, markerObj]
            private _segIdxCfg = _seg select 1;
            private _curGrp = _run getOrDefault ["destroyCurrentGroup", grpNull];
            private _curSeg = _run getOrDefault ["destroyCurrentSegIdx", -999];
            private _needsSpawn = false;

            if (isNull _curGrp) then { _needsSpawn = true };
            if (_curSeg isNotEqualTo _segIdxCfg) then { _needsSpawn = true };

            if (_needsSpawn) then {
                private _cfgRow = [
                    _seg select 1,
                    _seg select 2,
                    _seg select 3,
                    _seg select 4,
                    _seg select 5,
                    _seg select 6,
                    _seg select 7
                ];
                private _pilot = _run getOrDefault ["pilotObj", objNull];
                private _spawned = [_cfgRow, _pilot] call GLT_Trials_fnc_spawnDestroyInfantry;
                private _leader = _spawned param [0, objNull];
                private _grp = _spawned param [1, grpNull];
                _run set ["destroyCurrentObj", _leader];
                _run set ["destroyCurrentGroup", _grp];
                _run set ["destroyCurrentSegIdx", _segIdxCfg];
                if (!isNull _grp) then {
                    private _mandatoryInf = _run getOrDefault ["destroyInfMandatoryGrps", []];
                    _mandatoryInf pushBackUnique _grp;
                    _run set ["destroyInfMandatoryGrps", _mandatoryInf];
                };
            };

            private _targetGrp = _run getOrDefault ["destroyCurrentGroup", grpNull];
            if ([_targetGrp] call GLT_Trials_fnc_isDestroyInfantryComplete) then {
                _segmentCompleted = true;
            } else {
                // Keep smoke roughly on active squad leader while the group is alive.
                private _leaderAlive = objNull;
                {
                    if (alive _x) exitWith { _leaderAlive = _x };
                } forEach units _targetGrp;
                if (!isNull _leaderAlive) then {
                    _run set ["destroyCurrentObj", _leaderAlive];
                };
            };
        };

        case "SLING_DELIVER_CIRCLE";
        case "SLING_DELIVER_RECT": {
            // Circle: ["SLING_DELIVER_CIRCLE", idx, posASL, radius]
            // Rect:   ["SLING_DELIVER_RECT", idx, posASL, axisR, axisF, halfW, halfL, dimFar, dimClose]
            // Complete when trial cargo is in zone on the ground (not on this heli's sling).
            private _cargo = _run get "slingCargoObj";
            if (isNil "_cargo") then { _cargo = objNull };
            if (!isNull _cargo) then {
                private _posC = getPosWorld _cargo;
                private _inZone = [_posC, _seg] call GLT_Trials_fnc_pointInSlingDeliveryZone;
                private _sl = getSlingLoad _heli;
                private _onHook = (!isNull _sl && {_sl == _cargo}) || {
                    (_cargo getVariable ["PTF_RopesAttached", 0] > 0)
                };
                if (_inZone && {!_onHook}) then {
                    _segmentCompleted = true;
                };
            };
        };
    };

    // Move to next segment on completion
    if (_segmentCompleted) then {
        _run set ["segmentIndex", _segmentIndex + 1];
        _run set ["hoverStartTime", -1];
        _run set ["landStayStartTime", -1];
        _run set ["slingStayStartTime", -1];
    };
} else {
    // End stage: finish when touching the end object.
    private _endConfig = _trial select 8; // [endPosWorld, endRadius, endNormal, endUp, endRight, ...]
    private _endPos = _endConfig select 0;
    private _endRadius = _endConfig select 1;

    private _endTouchMethod = _endConfig select 5;
    private _endTouchPadding = _endConfig select 6;
    private _endOBBHalfExtents = _endConfig select 7;
    private _endSphereCenterWorld = _endConfig select 8;
    private _endSphereRadius = _endConfig select 9;

    // Approximate heli hull using boundingBoxReal (works without boundingSphere*).
    private _axisRightN = vectorNormalized (_endConfig select 4);
    private _axisUpN = vectorNormalized (_endConfig select 3);
    private _axisNormalN = vectorNormalized (_endConfig select 2);

    private _bb = boundingBoxReal _heli;
    private _bbMin = _bb select 0;
    private _bbMax = _bb select 1;

    private _cx = ((_bbMin select 0) + (_bbMax select 0)) / 2;
    private _cy = ((_bbMin select 1) + (_bbMax select 1)) / 2;
    private _cz = ((_bbMin select 2) + (_bbMax select 2)) / 2;
    private _heliCenterWorld = _heli modelToWorld [_cx, _cy, _cz];

    private _xMin = _bbMin select 0; private _xMax = _bbMax select 0;
    private _yMin = _bbMin select 1; private _yMax = _bbMax select 1;
    private _zMin = _bbMin select 2; private _zMax = _bbMax select 2;

    private _cornersLocal = [
        [_xMin,_yMin,_zMin],
        [_xMin,_yMin,_zMax],
        [_xMin,_yMax,_zMin],
        [_xMin,_yMax,_zMax],
        [_xMax,_yMin,_zMin],
        [_xMax,_yMin,_zMax],
        [_xMax,_yMax,_zMin],
        [_xMax,_yMax,_zMax]
    ];

    private _heliHalfRight = 0;
    private _heliHalfUp = 0;
    private _heliHalfNormal = 0;
    private _heliSphereRadius = 0;

    {
        private _cw = _heli modelToWorld _x;
        private _delta = _cw vectorDiff _heliCenterWorld;

        private _pR = abs (_delta vectorDotProduct _axisRightN);
        private _pU = abs (_delta vectorDotProduct _axisUpN);
        private _pN = abs (_delta vectorDotProduct _axisNormalN);
        if (_pR > _heliHalfRight) then { _heliHalfRight = _pR };
        if (_pU > _heliHalfUp) then { _heliHalfUp = _pU };
        if (_pN > _heliHalfNormal) then { _heliHalfNormal = _pN };

        private _d = sqrt (
            (_delta select 0) * (_delta select 0) +
            (_delta select 1) * (_delta select 1) +
            (_delta select 2) * (_delta select 2)
        );
        if (_d > _heliSphereRadius) then { _heliSphereRadius = _d };
    } forEach _cornersLocal;

    private _crossed = false;
    if (_endTouchMethod isEqualTo 0) then {
        // OBB_HULL
        private _rel = _heliCenterWorld vectorDiff _endPos;

        private _x = abs (_rel vectorDotProduct _axisRightN);
        private _y = abs (_rel vectorDotProduct _axisUpN);
        private _z = abs (_rel vectorDotProduct _axisNormalN);

        private _hx = (_endOBBHalfExtents select 0) + _heliHalfRight + _endTouchPadding;
        private _hy = (_endOBBHalfExtents select 1) + _heliHalfUp + _endTouchPadding;
        private _hz = (_endOBBHalfExtents select 2) + _heliHalfNormal + _endTouchPadding;

        if ((_x <= _hx) && { (_y <= _hy) } && { (_z <= _hz) }) then { _crossed = true };
    } else {
    if (_endTouchMethod isEqualTo 1) then {
        // SPHERE_HULL (sphere center uses the OBB center).
        private _d = _heliCenterWorld distance _endPos;
        if (_d <= (_endSphereRadius + _heliSphereRadius + _endTouchPadding)) then { _crossed = true };
    } else {
    if (_endTouchMethod isEqualTo 2) then {
        // CENTER_2D (legacy)
        private _d2 = _heliCenterWorld distance2D _endPos;
        if (_d2 <= (_endRadius + _endTouchPadding)) then { _crossed = true };
    };
    };
    };

    // Pure fly-through end gate: crossing the end volume is enough (heli must still be alive).
    if (_crossed && {alive _heli}) then { _finish = true };
};
};

// Update last position for gate crossing.
_run set ["lastPosWorld", _posWorld];

_run set ["didFinish", _finish];
_finish

