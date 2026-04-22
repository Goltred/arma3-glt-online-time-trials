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

private _activeTids = [];
{
    _activeTids pushBackUnique (_x get "trialId");
} forEach GLT_Trials_activeRunsPrivate;

{
    private _tid = _x;
    private _objs = GLT_Trials_courseObjectsByTrial getOrDefault [_tid, []];
    private _show = (_activeTids find _tid) >= 0;
    {
        if (isNull _x) then { continue };
        private _wantHiddenGlobal = !_show;
        if (_x getVariable ["GLT_Trials_runtimeAlwaysHidden", false]) then {
            _wantHiddenGlobal = true;
        };
        private _prev = _x getVariable ["GLT_Trials_ttSrvCourseHidden", nil];
        if (!isNil "_prev" && {_prev isEqualTo _wantHiddenGlobal}) then { continue };
        _x hideObjectGlobal _wantHiddenGlobal;
        _x setVariable ["GLT_Trials_ttSrvCourseHidden", _wantHiddenGlobal];
    } forEach _objs;
} forEach _trialIds;

true
