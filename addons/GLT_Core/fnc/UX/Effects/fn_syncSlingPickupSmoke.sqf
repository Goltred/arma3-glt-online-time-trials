/*
    GLT_Trials_fnc_syncSlingPickupSmoke
    Client: green smoke at SLING_PICKUP segment center (same pattern as land smoke shells).
*/

if (!hasInterface) exitWith {};

if (!GLT_Trials_clientHudShown) exitWith { [] call GLT_Trials_fnc_clearSlingPickupSmoke };
if (!isNull findDisplay 88100) exitWith { [] call GLT_Trials_fnc_clearSlingPickupSmoke };
if (isNil "GLT_Trials_activeRunsPublic") exitWith { [] call GLT_Trials_fnc_clearSlingPickupSmoke };

private _myRun = [] call GLT_Trials_fnc_resolveClientHudRun;

if ((count _myRun) isEqualTo 0) exitWith { [] call GLT_Trials_fnc_clearSlingPickupSmoke };

private _segType = _myRun param [9, ""];
private _segPos = _myRun param [8, [0, 0, 0]];

if ((count _segPos) < 3 || {!(_segType isEqualTo "SLING_PICKUP")}) exitWith {
    [] call GLT_Trials_fnc_clearSlingPickupSmoke
};

private _posASL = (+_segPos) vectorAdd [0, 0, 0.35];
private _sig = format ["%1_%2_%3", _posASL select 0, _posASL select 1, _posASL select 2];

private _oldSig = uiNamespace getVariable ["GLT_Trials_slingPickupSmokeSig", ""];
private _cur = uiNamespace getVariable ["GLT_Trials_slingPickupSmokeObj", objNull];
private _refreshAt = uiNamespace getVariable ["GLT_Trials_slingPickupSmokeRefreshAt", 0];

private _needRefresh = (_sig isNotEqualTo _oldSig) || { isNull _cur } || { diag_tickTime >= _refreshAt };

if (!_needRefresh) exitWith {};

if (!isNull _cur) then {
    deleteVehicle _cur;
};
uiNamespace setVariable ["GLT_Trials_slingPickupSmokeObj", nil];

private _refreshInterval = 35;

private _spawnShell = {
    params ["_className", "_asl"];
    private _try = createVehicleLocal [_className, [0, 0, 0], [], 0, "CAN_COLLIDE"];
    if (isNull _try) exitWith { objNull };
    _try setPosASL _asl;
    _try enableSimulation true;
    _try
};

private _smoke = objNull;
private _greens = [
    "SmokeShellGreen",
    "G_40mm_Smoke_Green"
];

private _gi = 0;
while { isNull _smoke && {_gi < (count _greens)} } do {
    private _cls = _greens select _gi;
    _gi = _gi + 1;
    if (isClass (configFile >> "CfgVehicles" >> _cls)) then {
        _smoke = [_cls, _posASL] call _spawnShell;
    };
};

if (isNull _smoke) then {
    private _force = ["SmokeShellGreen", "G_40mm_Smoke_Green"];
    private _fi = 0;
    while { isNull _smoke && {_fi < (count _force)} } do {
        private _fn = _force select _fi;
        _fi = _fi + 1;
        _smoke = [_fn, _posASL] call _spawnShell;
    };
};

uiNamespace setVariable ["GLT_Trials_slingPickupSmokeObj", _smoke];
uiNamespace setVariable ["GLT_Trials_slingPickupSmokeSig", _sig];
uiNamespace setVariable ["GLT_Trials_slingPickupSmokeRefreshAt", diag_tickTime + _refreshInterval];

true
