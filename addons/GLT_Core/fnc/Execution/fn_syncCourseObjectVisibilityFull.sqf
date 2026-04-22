/*
    GLT_Trials_fnc_syncCourseObjectVisibilityFull
    Server: apply course hide/show for every trial (mission register / reconcile).
    Updates GLT_Trials_courseVisLastActiveTids to match current active runs.
*/

if (!isServer) exitWith {};

if (isNil "GLT_Trials_courseObjectsByTrial") exitWith {};
if (isNil "GLT_Trials_trials") exitWith {};

private _activeTids = [];
{
    _activeTids pushBackUnique (_x get "trialId");
} forEach GLT_Trials_activeRunsPrivate;

{
    private _tid = _x select 0;
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
} forEach GLT_Trials_trials;

GLT_Trials_courseVisLastActiveTids = +_activeTids;

true
