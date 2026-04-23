/*
    GLT_Trials_fnc_collectActiveTrialIds
    Server: unique trialId strings from GLT_Trials_activeRunsPrivate.
    Returns: array of strings
*/

if (!isServer) exitWith { [] };

private _out = [];
{
    _out pushBackUnique (_x get "trialId");
} forEach GLT_Trials_activeRunsPrivate;

_out
