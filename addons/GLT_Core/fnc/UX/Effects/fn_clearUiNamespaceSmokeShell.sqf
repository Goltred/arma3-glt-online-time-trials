/*
    GLT_Trials_fnc_clearUiNamespaceSmokeShell
    Client: delete local smoke shell tracked under uiNamespace (obj + sig + refresh keys).
    Params: [_keyObj, _keySig, _keyRefresh] — string names for uiNamespace variables
*/

params ["_keyObj", "_keySig", "_keyRefresh"];

if (!hasInterface) exitWith {};

private _o = uiNamespace getVariable [_keyObj, objNull];
if (!isNull _o) then {
    deleteVehicle _o;
};
uiNamespace setVariable [_keyObj, nil];
uiNamespace setVariable [_keySig, ""];
uiNamespace setVariable [_keyRefresh, 0];

true
