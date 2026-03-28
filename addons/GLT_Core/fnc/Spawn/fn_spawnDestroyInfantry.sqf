/*
    GLT_Trials_fnc_spawnDestroyInfantry
    Server: spawn an infantry destroy objective squad.
    Params: [_cfgRow, _pilotObj]
      _cfgRow: [segIdx, posASL, infClass, count, skill(0..1), displayName, markerObj]
    Returns: [leaderObj, groupObj]
*/

params ["_cfgRow", "_pilotObj"];
if (!isServer) exitWith { [objNull, grpNull] };
if (isNil "_cfgRow") exitWith { [objNull, grpNull] };
if (isNil "_pilotObj") then { _pilotObj = objNull };
if ((count _cfgRow) < 7) exitWith { [objNull, grpNull] };

private _segIdx = _cfgRow select 0;
private _pos = +(_cfgRow select 1);
private _infClass = _cfgRow select 2;
private _count = _cfgRow select 3;
private _skill = _cfgRow select 4;
private _markerObj = _cfgRow select 6;

if !(_infClass isEqualType "") then { _infClass = str _infClass };
if (_infClass isEqualTo "") then { _infClass = "O_Soldier_F" };
if (_count isEqualType "") then { _count = parseNumber _count };
if (_skill isEqualType "") then { _skill = parseNumber _skill };
if (_count < 1) then { _count = 1 };
if (_count > 24) then { _count = 24 };
if (_skill < 0) then { _skill = 0 };
if (_skill > 1) then { _skill = 1 };
if ((count _pos) < 3) exitWith { [objNull, grpNull] };

private _sideN = getNumber (configFile >> "CfgVehicles" >> _infClass >> "side");
private _side = switch (_sideN) do {
    case 1: { west };
    case 2: { independent };
    case 3: { civilian };
    default { east };
};

private _grp = createGroup [_side, true];
private _spawnPos = ASLToATL _pos;
private _spawnDir = if (!isNull _markerObj) then { getDir _markerObj } else { random 360 };
private _leader = objNull;

for "_i" from 1 to _count do {
    private _unit = _grp createUnit [_infClass, _spawnPos, [], 2, "FORM"];
    if (!isNull _unit) then {
        _unit setDir _spawnDir;
        _unit setSkill _skill;
        {
            _unit setSkill [_x, _skill];
        } forEach [
            "aimingAccuracy",
            "aimingShake",
            "aimingSpeed",
            "endurance",
            "spotDistance",
            "spotTime",
            "courage",
            "reloadSpeed",
            "commanding",
            "general"
        ];
        _unit setVariable ["GLT_Trials_destroyInfantry", true, true];
        _unit setVariable ["GLT_Trials_destroySegIdx", _segIdx, true];
        if (isNull _leader) then { _leader = _unit };
    };
};

if ((count units _grp) < 1) exitWith {
    deleteGroup _grp;
    [objNull, grpNull]
};

_grp setFormation "WEDGE";
_grp setBehaviour "COMBAT";
_grp setCombatMode "RED";
_grp setSpeedMode "NORMAL";

private _threat = objNull;
if (!isNull _pilotObj && {alive _pilotObj}) then {
    _threat = vehicle _pilotObj;
    if (isNull _threat) then { _threat = _pilotObj };
};
if (!isNull _threat && {alive _threat}) then {
    _grp reveal [_threat, 4];
    private _wp = _grp addWaypoint [getPosWorld _threat, 0];
    _wp setWaypointType "SAD";
    _wp setWaypointBehaviour "COMBAT";
    _wp setWaypointCombatMode "RED";
    {
        if (alive _x) then {
            _x doTarget _threat;
            _x doWatch _threat;
        };
    } forEach units _grp;
};

[_leader, _grp]
