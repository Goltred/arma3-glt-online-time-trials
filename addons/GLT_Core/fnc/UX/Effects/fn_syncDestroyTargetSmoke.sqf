/*
    GLT_Trials_fnc_syncDestroyTargetSmoke
    Client: red smoke on active DESTROY_TARGET / DESTROY_INFANTRY objective.
*/

if (!hasInterface) exitWith {};

if (!GLT_Trials_clientHudShown) exitWith { [] call GLT_Trials_fnc_clearDestroyTargetSmoke };
if (!isNull findDisplay 88100) exitWith { [] call GLT_Trials_fnc_clearDestroyTargetSmoke };
if (isNil "GLT_Trials_activeRunsPublic") exitWith { [] call GLT_Trials_fnc_clearDestroyTargetSmoke };

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

if ((count _myRun) isEqualTo 0) exitWith { [] call GLT_Trials_fnc_clearDestroyTargetSmoke };

private _segType = _myRun param [9, ""];
private _posASL = _myRun param [21, []];
if (
    (_segType isNotEqualTo "DESTROY_TARGET")
    && { _segType isNotEqualTo "DESTROY_INFANTRY" }
) exitWith { [] call GLT_Trials_fnc_clearDestroyTargetSmoke };
if ((count _posASL) < 3) exitWith { [] call GLT_Trials_fnc_clearDestroyTargetSmoke };

private _spawnPos = (+_posASL) vectorAdd [0, 0, 0.35];
private _sig = format ["%1_%2_%3", _spawnPos select 0, _spawnPos select 1, _spawnPos select 2];
private _oldSig = uiNamespace getVariable ["GLT_Trials_destroySmokeSig", ""];
private _cur = uiNamespace getVariable ["GLT_Trials_destroySmokeObj", objNull];
private _refreshAt = uiNamespace getVariable ["GLT_Trials_destroySmokeRefreshAt", 0];

private _needRefresh = (_sig isNotEqualTo _oldSig) || { isNull _cur } || { diag_tickTime >= _refreshAt };
if (!_needRefresh) exitWith {};

if (!isNull _cur) then { deleteVehicle _cur; };
uiNamespace setVariable ["GLT_Trials_destroySmokeObj", nil];

private _spawnShell = {
    params ["_className", "_asl"];
    private _try = createVehicleLocal [_className, [0, 0, 0], [], 0, "CAN_COLLIDE"];
    if (isNull _try) exitWith { objNull };
    _try setPosASL _asl;
    _try enableSimulation true;
    _try
};

private _smoke = objNull;
private _classes = ["SmokeShellRed", "G_40mm_Smoke_Red"];
private _i = 0;
while { isNull _smoke && {_i < (count _classes)} } do {
    private _cls = _classes select _i;
    _i = _i + 1;
    if (isClass (configFile >> "CfgVehicles" >> _cls)) then {
        _smoke = [_cls, _spawnPos] call _spawnShell;
    };
};
if (isNull _smoke) then {
    private _j = 0;
    while { isNull _smoke && {_j < (count _classes)} } do {
        private _cls2 = _classes select _j;
        _j = _j + 1;
        _smoke = [_cls2, _spawnPos] call _spawnShell;
    };
};

uiNamespace setVariable ["GLT_Trials_destroySmokeObj", _smoke];
uiNamespace setVariable ["GLT_Trials_destroySmokeSig", _sig];
uiNamespace setVariable ["GLT_Trials_destroySmokeRefreshAt", diag_tickTime + 35];

true
