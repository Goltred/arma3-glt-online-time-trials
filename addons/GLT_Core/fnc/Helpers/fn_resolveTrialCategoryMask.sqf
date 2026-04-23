/*
    GLT_Trials_fnc_resolveTrialCategoryMask
    Client/server: category mask for a trial. Prefer GLT_Trials_categoryMaskByTrialId (small hashMap, reliable over MP)
    because GLT_Trials_trials rows contain large object arrays and index 9 may not sync on all clients.

    Params: [_trialId, _trialRow] — _trialRow is the GLT_Trials_trials entry (may be incomplete on clients).
    Returns: [] or [h,p,g,s] (numbers 0/1)
*/

params [["_trialId", "", [""]], ["_trialRow", [], [[]]]];
private _m = missionNamespace getVariable ["GLT_Trials_categoryMaskByTrialId", nil];
if (isNil "_m") exitWith { +(_trialRow param [9, []]) };
+(_m getOrDefault [_trialId, _trialRow param [9, []]])
