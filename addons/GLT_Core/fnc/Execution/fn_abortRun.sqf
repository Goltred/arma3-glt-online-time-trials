/*
    GLT_Trials_fnc_abortRun
    Server-side cleanup for an aborted run.
    Params: [_run]
*/

params ["_run"];
if (!isServer) exitWith {};
if (isNil "_run") exitWith {};

[_run] call GLT_Trials_fnc_cleanupSlingCargo;
[_run] call GLT_Trials_fnc_cleanupDestroyTargets;

private _runId = _run get "runId";
private _trialId = _run get "trialId";
GLT_Trials_activeRunsPrivate = GLT_Trials_activeRunsPrivate select { (_x get "runId") isNotEqualTo _runId };

[_trialId] call GLT_Trials_fnc_syncCourseObjectVisibilityForTrialIds;
private _c = [];
{
    _c pushBackUnique (_x get "trialId");
} forEach GLT_Trials_activeRunsPrivate;
GLT_Trials_courseVisLastActiveTids = +_c;

