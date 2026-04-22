/*
    GLT_Trials_fnc_onVehicleEntered
    Client-side: attach ACE "Time Trials" interaction to vehicles eligible for a trial (when ACE is present).
    Params: [_unit, _vehicle]
*/

params ["_unit", "_vehicle"];
if (!hasInterface) exitWith {};
if (isNull _vehicle) exitWith {};
if (_unit isNotEqualTo player) exitWith {};
if (!(missionNamespace getVariable ["GLT_Trials_trialsAvailable", false])) exitWith {};

if (isNil "GLT_Trials_trials") exitWith {};
private _heliType = typeOf _vehicle;
if (_heliType isEqualTo "") exitWith {};

private _isAllowed = false;
{
    private _allowedHelis = _x select 2;
    private _catMask = _x param [9, []];
    private _classOk = (count _allowedHelis isEqualTo 0) || (_allowedHelis find _heliType >= 0);
    if (_classOk && {[_vehicle, _catMask] call GLT_Trials_fnc_vehicleMatchesTrialCategoryMask}) exitWith { _isAllowed = true; };
} forEach GLT_Trials_trials;

if (!(_isAllowed)) exitWith {};

// Only add interaction when player is driver.
if (driver _vehicle isNotEqualTo player) exitWith {};

// Remove any previously added ACE action (re-enter / seat switch).
private _existingPath = _vehicle getVariable ["GLT_Trials_aceActionPath", []];
if (count _existingPath > 0) then {
    [_vehicle, 0, _existingPath] call ace_interact_menu_fnc_removeActionFromObject;
    _vehicle setVariable ["GLT_Trials_aceActionPath", nil];
};

// Add ACE action as secondary entry point (same flow as Shift+T).
if (!(isClass (configFile >> "CfgPatches" >> "ace_interact_menu"))) exitWith {};

private _action = [
    "GLT_Trials_OpenTrials",
    "Time Trials",
    "",
    { [] call GLT_Trials_fnc_onKeySelectTrial; },
    { true },
    {},
    [],
    [0, 0, 0],
    4
] call ace_interact_menu_fnc_createAction;

private _path = [_vehicle, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
_vehicle setVariable ["GLT_Trials_aceActionPath", _path];

true
