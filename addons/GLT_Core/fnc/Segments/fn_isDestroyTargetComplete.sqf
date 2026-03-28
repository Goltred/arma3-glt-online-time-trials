/*
    GLT_Trials_fnc_isDestroyTargetComplete
    Params: [_veh]
    Returns: true when vehicle is considered destroyed.
*/

params ["_veh"];

if (isNull _veh) exitWith { true };
if (!(alive _veh)) exitWith { true };
if (!(canMove _veh)) exitWith { true };

false
