/*
    GLT_Trials_fnc_openTrialMenu
    Client-side trial selection UI using a simple dialog.
    Params: [_vehicle, _eligibleTrials]
        _vehicle: helicopter object
        _eligibleTrials: array of [trialId, trialName]
*/

params ["_vehicle", "_eligible"];
if (!hasInterface) exitWith {};
if (isNull _vehicle) exitWith {};
if (isNil "_eligible") exitWith {};
if (count _eligible isEqualTo 0) exitWith {};

// Store context for dialog callbacks
missionNamespace setVariable ["GLT_Trials_trialVehicle", _vehicle];
missionNamespace setVariable ["GLT_Trials_trialEligible", _eligible];

createDialog "RscDisplayGLT_Trials_Selector";

private _disp = findDisplay 88000;
if (isNull _disp) exitWith {};

private _ctrlList = _disp displayCtrl 1500;
lbClear _ctrlList;

{
    private _trialId = _x select 0;
    private _trialName = _x select 1;
    private _idx = _ctrlList lbAdd _trialName;
    _ctrlList lbSetData [_idx, _trialId];
} forEach _eligible;

