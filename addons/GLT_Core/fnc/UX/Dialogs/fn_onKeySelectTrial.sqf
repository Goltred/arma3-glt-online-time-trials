/*
    GLT_Trials_fnc_onKeySelectTrial
    Invoked from a keybind to open the trial selection dialog for the vehicle you are driving.
*/

if (!hasInterface) exitWith {};
if (!(missionNamespace getVariable ["GLT_Trials_trialsAvailable", false])) exitWith {
    hintSilent "Time Trials: no trials are configured on this mission.";
};

private _veh = vehicle player;
if (_veh isEqualTo player) exitWith {
    hintSilent "Time Trials: you must be in a vehicle as driver.";
};

if (driver _veh isNotEqualTo player) exitWith {
    hintSilent "Time Trials: you must be the driver.";
};

if (isNil "GLT_Trials_trials") exitWith {
    hintSilent "Time Trials: trials not synchronised yet.";
};

private _heliType = typeOf _veh;

private _eligible = [];
{
    private _trialId = _x select 0;
    private _trialName = _x select 1;
    private _allowedHelis = _x select 2;
    private _catMask = [_trialId, _x] call GLT_Trials_fnc_resolveTrialCategoryMask;
    private _classOk = (count _allowedHelis isEqualTo 0) || (_allowedHelis find _heliType >= 0);
    private _catOk = [_veh, _catMask] call GLT_Trials_fnc_vehicleMatchesTrialCategoryMask;
    if (_classOk && {_catOk}) then {
        _eligible pushBack [_trialId, _trialName];
    };
} forEach GLT_Trials_trials;

private _row = [] call GLT_Trials_fnc_resolveClientHudRun;
private _myUid = getPlayerUID player;
private _activeHere = false;
if ((count _row) > 0 && { (_row select 1) isEqualTo _myUid }) then {
    private _rn = _row param [22, ""];
    if (_rn isNotEqualTo "") then {
        _activeHere = _rn isEqualTo (netId _veh);
    } else {
        private _ridRow = parseNumber (str (_row select 0));
        private _ridClient = if (isNil "GLT_Trials_clientRunId") then { -1 } else { parseNumber (str GLT_Trials_clientRunId) };
        _activeHere = (_ridRow >= 0) && { _ridRow isEqualTo _ridClient };
    };
};

if (_activeHere) exitWith {
    [_veh, _eligible, _row] call GLT_Trials_fnc_openTrialMenu;
};

if (count _eligible isEqualTo 0) exitWith {
    hintSilent "Time Trials: no trials available for this vehicle.";
};

[_veh, _eligible] call GLT_Trials_fnc_openTrialMenu;
