/*
    GLT_Trials_fnc_registerSegments_DestroyTarget
    Returns: [segments, courseObjs, optionalRows]
*/

params [["_trialId", "", [""]]];

private _segments = [];
private _objs = [];
private _optionalRows = [];

private _destroyTargets = allMissionObjects "GLT_Trials_DestroyTarget";
{
    private _sid = _x getVariable ["GLT_Trials_trialId", ""];
    if !(_sid isEqualTo _trialId) then { continue };
    // Arrow helper is an editor gizmo only; keep it hidden at runtime (syncCourseObjectVisibility).
    _x setVariable ["GLT_Trials_runtimeAlwaysHidden", true, true];

    private _segIdx = _x getVariable ["GLT_Trials_segmentIndex", 0];
    private _posWorld = getPosASL _x;
    private _vehClass = _x getVariable ["GLT_Trials_destroyVehicleClass", "O_G_Offroad_01_armed_F"];
    if (_vehClass isEqualType "") then {
        if (_vehClass isEqualTo "") then { _vehClass = "O_G_Offroad_01_armed_F" };
    } else {
        _vehClass = str _vehClass;
    };
    private _spawnDriver = [_x getVariable ["GLT_Trials_destroySpawnDriver", 0], 0] call GLT_Trials_fnc_numberFromEden;
    private _spawnGunners = [_x getVariable ["GLT_Trials_destroySpawnGunners", 0], 0] call GLT_Trials_fnc_numberFromEden;
    _spawnDriver = if (_spawnDriver > 0) then { 1 } else { 0 };
    _spawnGunners = if (_spawnGunners > 0) then { 1 } else { 0 };
    private _sideN = [_x getVariable ["GLT_Trials_destroySide", 0], 0] call GLT_Trials_fnc_numberFromEden;
    if (_sideN < 0 || {_sideN > 3}) then { _sideN = 0 };
    private _skill = [_x getVariable ["GLT_Trials_destroySkill", 1], 1] call GLT_Trials_fnc_numberFromEden;
    if (_skill < 0) then { _skill = 0 };
    if (_skill > 1) then { _skill = 1 };
    private _optional = [_x getVariable ["GLT_Trials_Optional", 0], 0] call GLT_Trials_fnc_numberFromEden;
    _optional = if (_optional > 0) then { 1 } else { 0 };

    private _disp = getText (configFile >> "CfgVehicles" >> _vehClass >> "displayName");
    if (_disp isEqualTo "") then { _disp = _vehClass };

    _objs pushBack _x;
    if (_optional > 0) then {
        _optionalRows pushBack [
            _segIdx,
            _posWorld,
            _vehClass,
            _spawnDriver,
            _spawnGunners,
            _sideN,
            _disp,
            _x,
            _skill
        ];
    } else {
        // ["DESTROY_TARGET", segIdx, posASL, vehClass, spawnDriver, spawnGunners, side(0..3), displayName, markerObj, skill(0..1)]
        _segments pushBack ["DESTROY_TARGET", _segIdx, _posWorld, _vehClass, _spawnDriver, _spawnGunners, _sideN, _disp, _x, _skill];
    };
} forEach _destroyTargets;

[_segments, _objs, _optionalRows]

