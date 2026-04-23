/*
    GLT_Trials_fnc_syncCourseObjectVisibilityForTrialIds
    Server: update hideObjectGlobal only for the given trial ids (symmetric-diff / abort paths).
    Call: _trialIds call GLT_Trials_fnc_syncCourseObjectVisibilityForTrialIds
      where _trialIds is an array of trialId strings (may be empty; no-op).
*/

if (!isServer) exitWith {};

private _trialIds = _this;
if (!(_trialIds isEqualType [])) then { _trialIds = [_trialIds]; };

if (isNil "GLT_Trials_courseObjectsByTrial") exitWith {};
if (isNil "GLT_Trials_trials") exitWith {};

if ((count _trialIds) isEqualTo 0) exitWith {};

private _activeTids = [] call GLT_Trials_fnc_collectActiveTrialIds;

{
    [_x, _activeTids] call GLT_Trials_fnc_applyCourseVisibilityForTrial;
} forEach _trialIds;

true
