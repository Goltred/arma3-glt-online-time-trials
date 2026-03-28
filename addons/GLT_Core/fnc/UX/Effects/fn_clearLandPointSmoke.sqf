/*
    GLT_Trials_fnc_clearLandPointSmoke
    Client: remove the local LAND_POINT smoke shell / object (see syncLandPointSmoke).
*/

if (!hasInterface) exitWith {};

private _o = uiNamespace getVariable ["GLT_Trials_landSmokeObj", objNull];
if (!isNull _o) then {
    deleteVehicle _o;
};
uiNamespace setVariable ["GLT_Trials_landSmokeObj", nil];
uiNamespace setVariable ["GLT_Trials_landSmokeSig", ""];
uiNamespace setVariable ["GLT_Trials_landSmokeRefreshAt", 0];

true
