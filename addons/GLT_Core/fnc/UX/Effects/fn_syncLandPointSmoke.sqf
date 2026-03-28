/*
    GLT_Trials_fnc_syncLandPointSmoke
    Client: smoke at the active LAND_POINT segment center (server row index 8).

    Only CfgVehicles smoke *shells* (same sim as hand/40mm smoke grenades) so the plume reacts
    to wind and rotor wash. No #particlesource / CfgCloudlets fallback — those are static-looking
    and often read as a dark column with no wash interaction.

    createVehicleLocal position is unreliable with raw ASL; spawn at origin then setPosASL.
    Do not use !alive on smoke shells — many builds report !alive while smoke is visible or
    immediately, which would delete/recreate every Draw3D and look like "no smoke".

    CAN_COLLIDE so the entity participates in collision/physics like a dropped grenade.
*/

if (!hasInterface) exitWith {};

if (!GLT_Trials_clientHudShown) exitWith { [] call GLT_Trials_fnc_clearLandPointSmoke };
if (!isNull findDisplay 88100) exitWith { [] call GLT_Trials_fnc_clearLandPointSmoke };
if (isNil "GLT_Trials_activeRunsPublic") exitWith { [] call GLT_Trials_fnc_clearLandPointSmoke };

private _myUID = getPlayerUID player;
private _myRunId = parseNumber (str GLT_Trials_clientRunId);

private _myRunCandidates = GLT_Trials_activeRunsPublic select {
    parseNumber (str (_x select 0)) isEqualTo _myRunId
};
private _myRun = if ((count _myRunCandidates) > 0) then { _myRunCandidates select 0 } else { [] };
if ((count _myRun) isEqualTo 0) then {
    private _uidCandidates = GLT_Trials_activeRunsPublic select { (_x select 1) isEqualTo _myUID };
    _myRun = if ((count _uidCandidates) > 0) then { _uidCandidates select 0 } else { [] };
};

if ((count _myRun) isEqualTo 0) exitWith { [] call GLT_Trials_fnc_clearLandPointSmoke };

private _segType = _myRun param [9, ""];
private _segPos = _myRun param [8, [0, 0, 0]];

if ((count _segPos) < 3 || {!(_segType isEqualTo "LAND_POINT")}) exitWith {
    [] call GLT_Trials_fnc_clearLandPointSmoke
};

// Slightly above helipad center so the shell isn't clipped into the pad / terrain.
private _posASL = (+_segPos) vectorAdd [0, 0, 0.35];
private _sig = format ["%1_%2_%3", _posASL select 0, _posASL select 1, _posASL select 2];

private _oldSig = uiNamespace getVariable ["GLT_Trials_landSmokeSig", ""];
private _cur = uiNamespace getVariable ["GLT_Trials_landSmokeObj", objNull];
private _refreshAt = uiNamespace getVariable ["GLT_Trials_landSmokeRefreshAt", 0];

private _needRefresh = (_sig isNotEqualTo _oldSig) || { isNull _cur } || { diag_tickTime >= _refreshAt };

if (!_needRefresh) exitWith {};

if (!isNull _cur) then {
    deleteVehicle _cur;
};
uiNamespace setVariable ["GLT_Trials_landSmokeObj", nil];

// ~35s matches typical smoke grenade duration so we refresh before it fully fades.
private _refreshInterval = 35;

private _spawnLandSmokeShell = {
    params ["_className", "_asl"];
    private _try = createVehicleLocal [_className, [0, 0, 0], [], 0, "CAN_COLLIDE"];
    if (isNull _try) exitWith { objNull };
    _try setPosASL _asl;
    _try enableSimulation true;
    _try
};

private _smoke = objNull;
// Prefer blue/white; extra colours if those classes are missing (modded games).
private _shellClassesPreferred = [
    "SmokeShellBlue",
    "G_40mm_Smoke_Blue",
    "SmokeShell"
];
private _classesToTry = _shellClassesPreferred + [
    "SmokeShellGreen",
    "SmokeShellYellow",
    "SmokeShellRed",
    "SmokeShellOrange",
    "SmokeShellPurple"
];

private _ci = 0;
while { isNull _smoke && {_ci < (count _classesToTry)} } do {
    private _cls = _classesToTry select _ci;
    _ci = _ci + 1;
    if (isClass (configFile >> "CfgVehicles" >> _cls)) then {
        _smoke = [_cls, _posASL] call _spawnLandSmokeShell;
    };
};

// Some mod/load orders break isClass for vanilla shells; try create anyway (objNull if missing).
if (isNull _smoke) then {
    private _fi = 0;
    while { isNull _smoke && {_fi < (count _shellClassesPreferred)} } do {
        private _fn = _shellClassesPreferred select _fi;
        _fi = _fi + 1;
        _smoke = [_fn, _posASL] call _spawnLandSmokeShell;
    };
};

uiNamespace setVariable ["GLT_Trials_landSmokeObj", _smoke];
uiNamespace setVariable ["GLT_Trials_landSmokeSig", _sig];
uiNamespace setVariable ["GLT_Trials_landSmokeRefreshAt", diag_tickTime + _refreshInterval];

true
