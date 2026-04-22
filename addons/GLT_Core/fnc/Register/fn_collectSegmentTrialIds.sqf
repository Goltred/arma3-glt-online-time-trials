/*
    GLT_Trials_fnc_collectSegmentTrialIds
    Server: unique non-empty GLT_Trials_trialId values from segment waypoints and Trial Definition helpers
    (registerTrial requires a matching GLT_Trials_TrialMeta per id for the trial to be active).
    Returns: array of strings
*/

if (!isServer) exitWith { [] };

private _ids = [];

private _addFromType = {
    params ["_typeName"];
    private _objs = allMissionObjects _typeName;
    if ((count _objs) isEqualTo 0) then {
        _objs = (allMissionObjects "") select { typeOf _x == _typeName };
    };
    {
        private _tid = _x getVariable ["GLT_Trials_trialId", ""];
        if (_tid isEqualTo "") then { continue };
        _ids pushBackUnique _tid;
    } forEach _objs;
};

"GLT_Trials_CrossGate" call _addFromType;
"GLT_Trials_HoverPoint" call _addFromType;
"GLT_Trials_LandPoint" call _addFromType;
"GLT_Trials_SlingPickup" call _addFromType;
"GLT_Trials_SlingDeliver" call _addFromType;
"GLT_Trials_SlingDeliverRect" call _addFromType;
"GLT_Trials_DestroyTarget" call _addFromType;
"GLT_Trials_DestroyInfantry" call _addFromType;
"GLT_Trials_TrialMeta" call _addFromType;

_ids
