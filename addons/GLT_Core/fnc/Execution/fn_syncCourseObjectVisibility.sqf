/*
    GLT_Trials_fnc_syncCourseObjectVisibility
    Server: hide course objects (start/end/segments) unless their trial has an active run.
    Uses GLT_Trials_courseObjectsByTrial (trialId -> [objects]) filled in registerTrial.

    Important: only call hideObjectGlobal when the desired state *changes*. Re-sending
    hideObjectGlobal false every tick resets client-side hideObject() and makes the
    3D visibility window (syncCourseObjects3DWindow) blink for all hidden waypoints.
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

true
