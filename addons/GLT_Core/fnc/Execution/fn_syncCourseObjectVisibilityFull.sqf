/*
    GLT_Trials_fnc_syncCourseObjectVisibilityFull
    Server: apply course hide/show for every trial (mission register / reconcile).
    Updates GLT_Trials_courseVisLastActiveTids to match current active runs.
*/

if (!isServer) exitWith {};

if (isNil "GLT_Trials_courseObjectsByTrial") exitWith {};
if (isNil "GLT_Trials_trials") exitWith {};

private _activeTids = [] call GLT_Trials_fnc_collectActiveTrialIds;

{
    [_x select 0, _activeTids] call GLT_Trials_fnc_applyCourseVisibilityForTrial;
} forEach GLT_Trials_trials;

GLT_Trials_courseVisLastActiveTids = +_activeTids;

true
