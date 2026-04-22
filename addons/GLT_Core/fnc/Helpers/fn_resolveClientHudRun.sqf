/*
    GLT_Trials_fnc_resolveClientHudRun
    Client: pick the GLT_Trials_activeRunsPublic row this machine should use for trial HUD / effects.

    Row index 22 = trial vehicle netId (see fn_tickServer), when present and matching.
    Also treats crew as "in run" when the trial pilot is the driver of vehicle player (covers
    netId mismatches / empty row[22]).
*/

if (!hasInterface) exitWith {[]};
if (isNil "GLT_Trials_activeRunsPublic") exitWith {[]};

private _list = GLT_Trials_activeRunsPublic;
if ((count _list) isEqualTo 0) exitWith {[]};

private _myUID = getPlayerUID player;
private _veh = vehicle player;

// netId for MP matching on any crewed vehicle (cars, boats, aircraft, etc.).
private _vn = "";
if (_veh isNotEqualTo player) then {
    _vn = netId _veh;
};

private _rowViewable = {
    params ["_row", "_uid", "_heliNetLocal"];
    private _pilotUid = _row param [1, ""];
    if (_uid isEqualTo _pilotUid) exitWith { true };
    private _h = _row param [22, ""];
    if (
        _heliNetLocal isNotEqualTo ""
        && {_h isNotEqualTo ""}
        && {_h isEqualTo _heliNetLocal}
    ) exitWith { true };
    private _vp = vehicle player;
    if (_vp isEqualTo player) exitWith { false };
    private _drv = driver _vp;
    if (isNull _drv || {!isPlayer _drv}) exitWith { false };
    (getPlayerUID _drv) isEqualTo _pilotUid
};

private _rid = if (isNil "GLT_Trials_clientRunId") then { -1 } else { parseNumber (str GLT_Trials_clientRunId) };

if (_rid >= 0) then {
    private _byRun = _list select {
        parseNumber (str (_x select 0)) isEqualTo _rid
        && { [_x, _myUID, _vn] call _rowViewable }
    };
    if ((count _byRun) > 0) exitWith { _byRun select 0 };
};

private _byPilot = _list select { (_x select 1) isEqualTo _myUID };
if ((count _byPilot) > 0) exitWith { _byPilot select 0 };

if (_vn isNotEqualTo "") then {
    private _byHeli = _list select {
        private _h = _x param [22, ""];
        _h isNotEqualTo "" && { _h isEqualTo _vn }
    };
    if ((count _byHeli) > 0) exitWith { _byHeli select 0 };
};

// Crew fallback: active run whose pilot UID is our vehicle's driver (no netId on row required).
private _crewRow = [];
if (_veh isNotEqualTo player) then {
    private _drv = driver _veh;
    if (!isNull _drv && { isPlayer _drv }) then {
        private _driverUid = getPlayerUID _drv;
        if (_driverUid isNotEqualTo "" && {_driverUid isNotEqualTo _myUID}) then {
            private _asCrew = _list select { (_x select 1) isEqualTo _driverUid };
            if ((count _asCrew) > 0) then {
                _crewRow = _asCrew select 0;
            };
        };
    };
};
if ((count _crewRow) > 0) exitWith { _crewRow };

[]
