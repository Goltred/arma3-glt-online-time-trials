/*
    GLT_Trials_fnc_cleanupSlingCargo
    Server: delete trial-spawned sling cargo if still present.
    Params: [_run]
*/

params ["_run"];
if (!isServer) exitWith {};
if (isNil "_run") exitWith {};

if (!isNull (_run getOrDefault ["slingCargoObj", objNull])) then {
    deleteVehicle (_run getOrDefault ["slingCargoObj", objNull]);
};
_run set ["slingCargoObj", nil];

true
