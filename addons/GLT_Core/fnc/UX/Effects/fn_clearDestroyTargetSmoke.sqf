/*
    GLT_Trials_fnc_clearDestroyTargetSmoke
*/

if (!hasInterface) exitWith {};

private _o = uiNamespace getVariable ["GLT_Trials_destroySmokeObj", objNull];
if (!isNull _o) then {
    deleteVehicle _o;
};
uiNamespace setVariable ["GLT_Trials_destroySmokeObj", nil];
uiNamespace setVariable ["GLT_Trials_destroySmokeSig", ""];
uiNamespace setVariable ["GLT_Trials_destroySmokeRefreshAt", 0];

true
