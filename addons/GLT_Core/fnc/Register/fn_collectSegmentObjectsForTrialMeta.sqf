/*
    GLT_Trials_fnc_collectSegmentObjectsForTrialMeta
    Server: objects synchronized to one Trial Definition (Eden links to the Logic only).

    Uses synchronizedObjects(_meta) only. Reverse scans that call synchronizedObjects on every segment can hang or
    crash when Eden sync graphs are circular or deep.

    Params: [_meta, _trialId] — _trialId reserved for callers; unused here.
    Returns: array of objects (may include non-segments; callers filter)
*/

params [["_meta", objNull], ["_trialId", "", [""]]];
if (isNull _meta) exitWith { [] };

+ (synchronizedObjects _meta)
