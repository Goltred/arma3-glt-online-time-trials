/*
    GLT_Trials_fnc_clearSlingPickupSmoke
*/

if (!hasInterface) exitWith {};

private _o = uiNamespace getVariable ["GLT_Trials_slingPickupSmokeObj", objNull];
if (!isNull _o) then {
    deleteVehicle _o;
};
uiNamespace setVariable ["GLT_Trials_slingPickupSmokeObj", nil];
uiNamespace setVariable ["GLT_Trials_slingPickupSmokeSig", ""];
uiNamespace setVariable ["GLT_Trials_slingPickupSmokeRefreshAt", 0];

true
