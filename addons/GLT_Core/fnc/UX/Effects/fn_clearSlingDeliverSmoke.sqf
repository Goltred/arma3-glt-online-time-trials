/*
    GLT_Trials_fnc_clearSlingDeliverSmoke
*/

if (!hasInterface) exitWith {};

private _o = uiNamespace getVariable ["GLT_Trials_slingDeliverSmokeObj", objNull];
if (!isNull _o) then {
    deleteVehicle _o;
};
uiNamespace setVariable ["GLT_Trials_slingDeliverSmokeObj", nil];
uiNamespace setVariable ["GLT_Trials_slingDeliverSmokeSig", ""];
uiNamespace setVariable ["GLT_Trials_slingDeliverSmokeRefreshAt", 0];

true
