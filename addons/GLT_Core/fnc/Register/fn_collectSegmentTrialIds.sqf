/*
    GLT_Trials_fnc_collectSegmentTrialIds
    Server: unique non-empty GLT_Trials_trialId values from Trial Definition objects only.
    Segments are discovered via Eden sync to each GLT_Trials_TrialMeta (see registerTrial).
    Returns: array of strings
*/

if (!isServer) exitWith { [] };

private _ids = [];

{
    private _tid = _x getVariable ["GLT_Trials_trialId", ""];
    if (_tid isEqualTo "") then { continue };
    _ids pushBackUnique _tid;
} forEach ((allMissionObjects "") select { typeOf _x == "GLT_Trials_TrialMeta" });

_ids
