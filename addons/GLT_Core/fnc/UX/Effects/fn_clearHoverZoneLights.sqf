/*
    GLT_Trials_fnc_clearHoverZoneLights
    Client-only: delete local hover helper lights from GLT_Trials_fnc_hoverZoneLights.
*/

if (!hasInterface) exitWith {};

uiNamespace setVariable ["GLT_Trials_hoverLightSig", ""];

{
    if (!isNull _x) then {
        deleteVehicle _x;
    };
} forEach (uiNamespace getVariable ["GLT_Trials_hoverZoneLightObjs", []]);

uiNamespace setVariable ["GLT_Trials_hoverZoneLightObjs", []];
uiNamespace setVariable ["GLT_Trials_hoverZoneLightCenter", nil];
uiNamespace setVariable ["GLT_Trials_hoverZoneLightRGB", nil];
uiNamespace setVariable ["GLT_Trials_hoverZoneLightDimFar", nil];
uiNamespace setVariable ["GLT_Trials_hoverZoneLightDimClose", nil];

true
