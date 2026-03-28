/*
    GLT_Trials_fnc_cleanupDestroyTargets
    Server: remove spawned destroy targets for a run.
    Params: [_run]
*/

params ["_run"];
if (!isServer) exitWith {};
if (isNil "_run") exitWith {};

private _mandatory = _run getOrDefault ["destroyMandatoryObjs", []];
{
    if (!isNull _x) then {
        deleteVehicleCrew _x;
        deleteVehicle _x;
    };
} forEach _mandatory;
_run set ["destroyMandatoryObjs", []];

private _optional = _run getOrDefault ["destroyOptionalObjs", []];
{
    if (!isNull _x) then {
        deleteVehicleCrew _x;
        deleteVehicle _x;
    };
} forEach _optional;
_run set ["destroyOptionalObjs", []];

_run set ["destroyCurrentObj", objNull];

private _mandatoryInf = _run getOrDefault ["destroyInfMandatoryGrps", []];
{
    if (!isNull _x) then {
        {
            if (!isNull _x) then { deleteVehicle _x };
        } forEach units _x;
        deleteGroup _x;
    };
} forEach _mandatoryInf;
_run set ["destroyInfMandatoryGrps", []];

private _optionalInf = _run getOrDefault ["destroyInfOptionalGrps", []];
{
    if (!isNull _x) then {
        {
            if (!isNull _x) then { deleteVehicle _x };
        } forEach units _x;
        deleteGroup _x;
    };
} forEach _optionalInf;
_run set ["destroyInfOptionalGrps", []];

_run set ["destroyCurrentGroup", grpNull];

true
