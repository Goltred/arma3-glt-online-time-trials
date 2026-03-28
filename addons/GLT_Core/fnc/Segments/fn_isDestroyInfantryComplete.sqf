/*
    GLT_Trials_fnc_isDestroyInfantryComplete
    Params: [_grp]
    Returns: true when all units in the infantry objective are dead.
*/

params ["_grp"];

if (isNull _grp) exitWith { true };

private _aliveCount = { alive _x } count units _grp;
(_aliveCount <= 0)
