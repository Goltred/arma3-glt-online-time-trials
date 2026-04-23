/*
    GLT_Trials_fnc_findPublicTrialRowById
    Look up one entry in GLT_Trials_trials by trial id (public summary row from registration).
    Params: [_trialId]
    Returns: the trial row array, or [] if not found / missing data.
*/

params [["_trialId", "", [""]]];
if (_trialId isEqualTo "") exitWith { [] };
if (isNil "GLT_Trials_trials") exitWith { [] };

private _row = [];
{
    if ((_x select 0) isEqualTo _trialId) exitWith { _row = _x };
} forEach GLT_Trials_trials;

_row
