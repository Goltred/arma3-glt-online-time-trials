/*
    GLT_Trials_fnc_spawnDestroyTarget
    Server: spawn a destroy target vehicle and optional crew.
    Params: [_cfgRow, _pilotObj]
      _cfgRow: [segIdx, posASL, vehClass, spawnDriver(0/1), spawnGunners(0/1), side(0..3), displayName, markerObj, skill(0..1)]
    _pilotObj: pilot unit (optional); crew is revealed / targets pilot vehicle when present.
    Returns: spawned vehicle or objNull on failure.
*/

params ["_cfgRow", "_pilotObj"];
if (!isServer) exitWith { objNull };
if (isNil "_cfgRow") exitWith { objNull };
if (isNil "_pilotObj") then { _pilotObj = objNull };
if ((count _cfgRow) < 9) exitWith { objNull };

private _segIdx = _cfgRow select 0;
private _pos = +(_cfgRow select 1);
private _vehClass = _cfgRow select 2;
private _spawnDriver = 0;
private _spawnGunners = 0;
private _sideN = 0;
private _markerObj = objNull;
private _skill = 1;

_spawnDriver = _cfgRow select 3;
_spawnGunners = _cfgRow select 4;
_sideN = _cfgRow select 5;
_markerObj = _cfgRow select 7;
_skill = _cfgRow select 8;

if (_spawnDriver isEqualType "") then { _spawnDriver = parseNumber _spawnDriver };
if (_spawnGunners isEqualType "") then { _spawnGunners = parseNumber _spawnGunners };
if (_sideN isEqualType "") then { _sideN = parseNumber _sideN };
if (_skill isEqualType "") then { _skill = parseNumber _skill };
_spawnDriver = if (_spawnDriver > 0) then { 1 } else { 0 };
_spawnGunners = if (_spawnGunners > 0) then { 1 } else { 0 };
if (_sideN < 0 || {_sideN > 3}) then { _sideN = 0 };
if (_skill < 0) then { _skill = 0 };
if (_skill > 1) then { _skill = 1 };

if ((count _pos) < 3) exitWith { objNull };
if !(_vehClass isEqualType "") then { _vehClass = str _vehClass };
if (_vehClass isEqualTo "") then { _vehClass = "O_G_Offroad_01_armed_F" };

private _veh = createVehicle [_vehClass, [0, 0, 0], [], 0, "NONE"];
if (isNull _veh) exitWith { objNull };

_veh setPosASL _pos;
if (!isNull _markerObj) then {
    _veh setDir (getDir _markerObj);
    _veh setVectorUp (vectorUp _markerObj);
};
_veh lock 2;
_veh allowCrewInImmobile true;
_veh setVariable ["GLT_Trials_destroyTarget", true, true];
_veh setVariable ["GLT_Trials_destroySegIdx", _segIdx, true];

private _grp = grpNull;
if ((_spawnDriver > 0) || {_spawnGunners > 0}) then {
    private _side = switch (_sideN) do {
        case 1: { west };
        case 2: { independent };
        case 3: { civilian };
        default { east };
    };
    private _unitClass = switch (_sideN) do {
        case 1: { "B_crew_F" };
        case 2: { "I_crew_F" };
        case 3: { "C_man_w_worker_F" };
        default { "O_crew_F" };
    };
    _grp = createGroup [_side, true];
    private _crewSeats = fullCrew [_veh, "", true];
    {
        _x params ["_seatUnit", "_role", "_cargoIdx", "_turretPath"];
        private _want = false;
        if (_role isEqualTo "driver") then {
            _want = (_spawnDriver > 0);
        } else {
            if (
                (_role isEqualTo "gunner")
                || { _role isEqualTo "commander" }
                || { _role isEqualTo "turret" }
            ) then {
                _want = (_spawnGunners > 0);
            };
        };
        if (_want) then {
            private _unit = _grp createUnit [_unitClass, _pos, [], 0, "NONE"];
            if (!isNull _unit) then {
                switch (_role) do {
                    case "driver": { _unit moveInDriver _veh; };
                    case "commander": { _unit moveInCommander _veh; };
                    case "gunner": { _unit moveInGunner _veh; };
                    case "turret": { _unit moveInTurret [_veh, _turretPath]; };
                };
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
            };
        };
    } forEach _crewSeats;
    if ((count units _grp) < 1) then {
        deleteGroup _grp;
        _grp = grpNull;
    };
};

if (!isNull _grp && {(count units _grp) > 0}) then {
    _grp setBehaviour "COMBAT";
    _grp setCombatMode "RED";
    private _threat = objNull;
    if (!isNull _pilotObj && {alive _pilotObj}) then {
        _threat = vehicle _pilotObj;
        if (isNull _threat) then { _threat = _pilotObj };
    };
    if (!isNull _threat && {alive _threat}) then {
        _grp reveal [_threat, 4];
        {
            if (alive _x) then {
                _x doTarget _threat;
                _x doWatch _threat;
            };
        } forEach units _grp;
    };
};

_veh
