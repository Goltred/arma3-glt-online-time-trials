/*
    GLT_Trials_fnc_requestCancelRun
    Server: driver requests to cancel their active trial run.
    Params: [_player]
*/

params ["_player"];
if (!isServer) exitWith {};
if (isNull _player) exitWith {};
if (!isPlayer _player) exitWith {};

private _uid = getPlayerUID _player;
if (_uid isEqualTo "") exitWith {};

private _idx = GLT_Trials_activeRunsPrivate findIf { (_x get "pilotUID") isEqualTo _uid };
if (_idx < 0) exitWith {};

private _run = GLT_Trials_activeRunsPrivate select _idx;
private _heli = _run get "heli";
if (isNull _heli) exitWith {};
if (vehicle _player isNotEqualTo _heli) exitWith {};
if (driver _heli isNotEqualTo _player) exitWith {};

_run set ["pilotCancelRequested", true];
[time] call GLT_Trials_fnc_tickServer;

true
