/*
    GLT_Trials_fnc_trialDialogButton
    Handles OK / CANCEL / STOP actions from the trial selection display (88000).
    Params: [_mode] where _mode is "OK", "CANCEL", or "STOP".
*/

params ["_mode"];
if (!hasInterface) exitWith {};

// SP / non-networked: always call (reliable return). MP dedicated client: remoteExecCall.
// Note: UI button context can misreport isServer; isMultiplayer && {!isServer} is the reliable client check.
private _startRunLocal = {
    params ["_v", "_tid", "_pl"];
    private _r = -1;
    if (isMultiplayer && {!isServer}) then {
        _r = [_v, _tid, _pl] remoteExecCall ["GLT_Trials_fnc_startRun", 2];
    } else {
        _r = [_v, _tid, _pl] call GLT_Trials_fnc_startRun;
    };
    _r
};

private _requestCancelLocal = {
    params ["_pl"];
    if (isMultiplayer && {!isServer}) then {
        [_pl] remoteExecCall ["GLT_Trials_fnc_requestCancelRun", 2];
    } else {
        [_pl] call GLT_Trials_fnc_requestCancelRun;
    };
};

private _coerceRunId = {
    params ["_raw"];
    if (isNil "_raw") exitWith { -1 };
    if (_raw isEqualType 0) exitWith { _raw };
    parseNumber (str _raw)
};

private _disp = findDisplay 88000;
if (isNull _disp) exitWith {};

if (_mode isEqualTo "CANCEL") exitWith {
    private _active = missionNamespace getVariable ["GLT_Trials_trialMenuActiveRow", []];
    if (count _active isEqualTo 0) then {
        [] call GLT_Trials_fnc_deleteTrialRouteMarkers;
    };
    _disp closeDisplay 0;
};

if (_mode isEqualTo "STOP") exitWith {
    private _veh = missionNamespace getVariable ["GLT_Trials_trialVehicle", objNull];
    if (isNull _veh) exitWith {
        hintSilent "Time Trials: vehicle no longer available.";
    };
    if (driver _veh isNotEqualTo player) exitWith {
        hintSilent "Time Trials: you must be the pilot.";
    };
    [player] call _requestCancelLocal;
    _disp closeDisplay 0;
};

// OK button
private _ctrlList = _disp displayCtrl 1500;
private _sel = lbCurSel _ctrlList;
if (_sel < 0) exitWith {
    hintSilent "Time Trials: no trial selected.";
};

private _trialId = _ctrlList lbData _sel;
if (_trialId isEqualTo "") exitWith {
    hintSilent "Time Trials: invalid selection.";
};

private _veh = missionNamespace getVariable ["GLT_Trials_trialVehicle", objNull];
if (isNull _veh) exitWith {
    hintSilent "Time Trials: vehicle no longer available.";
};

// If we don't have the public trial summary yet, fall back to old behavior.
if (isNil "GLT_Trials_trials") exitWith {
    _disp closeDisplay 0;
    private _runId = [_veh, _trialId, player] call _startRunLocal;
    private _runIdN = [_runId] call _coerceRunId;
    if (_runIdN >= 0) then { [_runIdN] call GLT_Trials_fnc_updateHud } else { hintSilent "Time Trials: could not start run."; };
};

// Look up start position + radius for this trial (from public summary array).
private _startPos = [];
private _startRadius = 0;
{
    private _tid = _x select 0;
    if (_tid isEqualTo _trialId) exitWith {
        _startPos = _x select 3;
        _startRadius = _x select 4;
    };
} forEach GLT_Trials_trials;

// If we don't know start position/radius, fall back to old behavior.
if (!(_startPos isEqualType []) || { count _startPos < 3 }) exitWith {
    _disp closeDisplay 0;
    private _runId = [_veh, _trialId, player] call _startRunLocal;
    private _runIdN = [_runId] call _coerceRunId;
    if (_runIdN >= 0) then { [_runIdN] call GLT_Trials_fnc_updateHud } else { hintSilent "Time Trials: could not start run."; };
};

// Close the overlay display.
_disp closeDisplay 0;

// Full route on map; start is active until server state arrives.
private _mapRoute = [];
{
    if ((_x select 0) isEqualTo _trialId) exitWith {
        _mapRoute = _x param [7, []];
    };
} forEach GLT_Trials_trials;
if ((count _mapRoute) isEqualTo 0) then {
    _mapRoute = [["START", _startPos]];
};
[_mapRoute, 0] call GLT_Trials_fnc_updateTrialRouteMarkers;

// Start the run immediately; the server will begin the timer on fly-through of the start object plane.
private _runId = [_veh, _trialId, player] call _startRunLocal;
private _runIdN = [_runId] call _coerceRunId;
if (_runIdN >= 0) then {
    [_runIdN] call GLT_Trials_fnc_updateHud;
} else {
    hintSilent "Time Trials: run rejected.";
};
