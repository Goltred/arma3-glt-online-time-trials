/*
    GLT_Trials_fnc_clearSlingDeliverVisuals
    Client: remove local cones / rect lights for sling delivery zones.
*/

if (!hasInterface) exitWith {};

{
    if (!isNull _x) then {
        deleteVehicle _x;
    };
} forEach (uiNamespace getVariable ["GLT_Trials_slingDeliverConeObjs", []]);
uiNamespace setVariable ["GLT_Trials_slingDeliverConeObjs", []];

{
    if (!isNull _x) then {
        deleteVehicle _x;
    };
} forEach (uiNamespace getVariable ["GLT_Trials_slingDeliverLightObjs", []]);
uiNamespace setVariable ["GLT_Trials_slingDeliverLightObjs", []];
uiNamespace setVariable ["GLT_Trials_slingDeliverLightCenter", []];
uiNamespace setVariable ["GLT_Trials_slingDeliverLightDimFar", 95];
uiNamespace setVariable ["GLT_Trials_slingDeliverLightDimClose", 32];
uiNamespace setVariable ["GLT_Trials_slingDeliverSig", ""];

true
