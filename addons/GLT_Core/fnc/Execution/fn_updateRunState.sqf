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

private _tcSegments = 9; // same as _trialConfig in fn_registerTrial.sqf
private _segments = _trial select _tcSegments;
private _segmentIndex = _run get "segmentIndex";

private _posWorld = getPosWorld _heli;
private _lastPosWorld = _run get "lastPosWorld";

private _finish = false;

// segmentIndex is always in range during a normal run (starts at 0; no separate WAIT_START phase).
if (_segmentIndex < 0 || { _segmentIndex >= count _segments }) then {
    _run set ["didFinish", false];
    _finish = true;
} else {
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
                    (_cargo getVariable ["GLT_Trials_cargoRopesAttached", 0] > 0)
                };
                if (_inZone && {!_onHook}) then {
                    _segmentCompleted = true;
                };
            };
        };
    };

    // Move to next segment on completion, or finish when the last waypoint (last segment) is complete.
    // Timer arms when segment 0 completes (startTime was -1 at run accept).
    if (_segmentCompleted) then {
        if ((_run get "startTime") < 0 && { _segmentIndex isEqualTo 0 }) then {
            _run set ["startTime", _now];
        };
        if (_segmentIndex >= ((count _segments) - 1)) then {
            _run set ["didFinish", true];
            _finish = true;
        } else {
            _run set ["segmentIndex", _segmentIndex + 1];
            _run set ["hoverStartTime", -1];
            _run set ["landStayStartTime", -1];
            _run set ["slingStayStartTime", -1];
        };
    };
};

// Update last position for gate crossing.
_run set ["lastPosWorld", _posWorld];

_finish

