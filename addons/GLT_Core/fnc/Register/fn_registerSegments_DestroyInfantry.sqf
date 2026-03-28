/*
    GLT_Trials_fnc_registerSegments_DestroyInfantry
    Returns: [segments, courseObjs, optionalRows]
*/

params [["_trialId", "", [""]]];

private _segments = [];
private _objs = [];
private _optionalRows = [];

private _destroyInfantry = allMissionObjects "GLT_Trials_DestroyInfantry";
{
    private _sid = _x getVariable ["GLT_Trials_trialId", ""];
    if !(_sid isEqualTo _trialId) then { continue };
    // Arrow helper is an editor gizmo only; keep it hidden at runtime (syncCourseObjectVisibility).
    _x setVariable ["GLT_Trials_runtimeAlwaysHidden", true, true];

    private _segIdx = _x getVariable ["GLT_Trials_segmentIndex", 0];
    private _posWorld = getPosASL _x;
    private _infClass = _x getVariable ["GLT_Trials_destroyInfClass", "O_Soldier_F"];
    if !(_infClass isEqualType "") then { _infClass = str _infClass };
    if (_infClass isEqualTo "") then { _infClass = "O_Soldier_F" };
    private _countN = [_x getVariable ["GLT_Trials_destroyInfCount", 6], 6] call GLT_Trials_fnc_numberFromEden;
    private _skillN = [_x getVariable ["GLT_Trials_destroyInfSkill", 0.8], 0.8] call GLT_Trials_fnc_numberFromEden;
    if (_countN < 1) then { _countN = 1 };
    if (_countN > 24) then { _countN = 24 };
    if (_skillN < 0) then { _skillN = 0 };
    if (_skillN > 1) then { _skillN = 1 };
    private _optionalN = [_x getVariable ["GLT_Trials_optional", 0], 0] call GLT_Trials_fnc_numberFromEden;
    _optionalN = if (_optionalN > 0) then { 1 } else { 0 };

    private _disp = getText (configFile >> "CfgVehicles" >> _infClass >> "displayName");
    if (_disp isEqualTo "") then { _disp = _infClass };

    _objs pushBack _x;
    if (_optionalN > 0) then {
        _optionalRows pushBack [
            _segIdx,
            _posWorld,
            _infClass,
            _countN,
            _skillN,
            _disp,
            _x
        ];
    } else {
        // ["DESTROY_INFANTRY", segIdx, posASL, infClass, count, skill, displayName, markerObj]
        _segments pushBack ["DESTROY_INFANTRY", _segIdx, _posWorld, _infClass, _countN, _skillN, _disp, _x];
    };
} forEach _destroyInfantry;

[_segments, _objs, _optionalRows]

