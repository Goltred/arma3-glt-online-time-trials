/*
    GLT_Trials_fnc_syncHudSmokeShell
    Client: shared HUD smoke shell sync (createVehicleLocal + uiNamespace cache).
    Params: [_posCode, _keyObj, _keySig, _keyRefresh, _preferredClasses, _forceClasses, _refreshInterval]
      _posCode — CODE; _this = active public row; return [] to clear, else raw position (3-vector, ASL-compatible).
      _preferredClasses — try create only when isClass succeeds (in order).
      _forceClasses — if still null, try create without isClass guard (land smoke pattern).
    Optional 7th: refresh interval seconds (default 35).
*/

params [
    "_posCode",
    "_keyObj",
    "_keySig",
    "_keyRefresh",
    "_preferredClasses",
    "_forceClasses",
    ["_refreshInterval", 35]
];

if (!hasInterface) exitWith {};

if (!GLT_Trials_clientHudShown) exitWith {
    [_keyObj, _keySig, _keyRefresh] call GLT_Trials_fnc_clearUiNamespaceSmokeShell
};
if (!isNull findDisplay 88100) exitWith {
    [_keyObj, _keySig, _keyRefresh] call GLT_Trials_fnc_clearUiNamespaceSmokeShell
};
if (isNil "GLT_Trials_activeRunsPublic") exitWith {
    [_keyObj, _keySig, _keyRefresh] call GLT_Trials_fnc_clearUiNamespaceSmokeShell
};

private _myRun = [] call GLT_Trials_fnc_resolveClientHudRun;

if ((count _myRun) isEqualTo 0) exitWith {
    [_keyObj, _keySig, _keyRefresh] call GLT_Trials_fnc_clearUiNamespaceSmokeShell
};

private _raw = _myRun call _posCode;
if ((count _raw) < 3) exitWith {
    [_keyObj, _keySig, _keyRefresh] call GLT_Trials_fnc_clearUiNamespaceSmokeShell
};

private _posASL = (+_raw) vectorAdd [0, 0, 0.35];
private _sig = format ["%1_%2_%3", _posASL select 0, _posASL select 1, _posASL select 2];

private _oldSig = uiNamespace getVariable [_keySig, ""];
private _cur = uiNamespace getVariable [_keyObj, objNull];
private _refreshAt = uiNamespace getVariable [_keyRefresh, 0];

private _needRefresh = (_sig isNotEqualTo _oldSig) || { isNull _cur } || { diag_tickTime >= _refreshAt };

if (!_needRefresh) exitWith {};

if (!isNull _cur) then {
    deleteVehicle _cur;
};
uiNamespace setVariable [_keyObj, nil];

private _spawnShell = {
    params ["_className", "_asl"];
    private _try = createVehicleLocal [_className, [0, 0, 0], [], 0, "CAN_COLLIDE"];
    if (isNull _try) exitWith { objNull };
    _try setPosASL _asl;
    _try enableSimulation true;
    _try
};

private _smoke = objNull;
private _ci = 0;
while { isNull _smoke && {_ci < (count _preferredClasses)} } do {
    private _cls = _preferredClasses select _ci;
    _ci = _ci + 1;
    if (isClass (configFile >> "CfgVehicles" >> _cls)) then {
        _smoke = [_cls, _posASL] call _spawnShell;
    };
};

if (isNull _smoke) then {
    private _fi = 0;
    while { isNull _smoke && {_fi < (count _forceClasses)} } do {
        private _fn = _forceClasses select _fi;
        _fi = _fi + 1;
        _smoke = [_fn, _posASL] call _spawnShell;
    };
};

uiNamespace setVariable [_keyObj, _smoke];
uiNamespace setVariable [_keySig, _sig];
uiNamespace setVariable [_keyRefresh, diag_tickTime + _refreshInterval];

true
