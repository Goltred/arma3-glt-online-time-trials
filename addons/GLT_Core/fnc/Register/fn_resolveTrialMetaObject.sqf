/*
    GLT_Trials_fnc_resolveTrialMetaObject
    Server: first GLT_Trials_TrialMeta object with matching GLT_Trials_trialId.
    Params: [_trialId]
    Returns: object or objNull
*/

params [["_trialId", "", [""]]];
if (_trialId isEqualTo "") exitWith { objNull };

private _candidates = (allMissionObjects "") select {
    (typeOf _x == "GLT_Trials_TrialMeta") && { (_x getVariable ["GLT_Trials_trialId", ""]) isEqualTo _trialId }
};

if ((count _candidates) > 0) exitWith { _candidates select 0 };

objNull
