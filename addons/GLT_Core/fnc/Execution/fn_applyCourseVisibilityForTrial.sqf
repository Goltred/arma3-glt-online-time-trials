/*
    GLT_Trials_fnc_applyCourseVisibilityForTrial
    Server: set hideObjectGlobal on all course objects for one trial from GLT_Trials_courseObjectsByTrial.
    Params: [_trialId, _activeTids] — _activeTids = list of trial ids that currently have an active run.
*/

params [["_trialId", "", [""]], ["_activeTids", [], [[]]]];
if (!isServer) exitWith {};
if (isNil "GLT_Trials_courseObjectsByTrial") exitWith {};

private _objs = GLT_Trials_courseObjectsByTrial getOrDefault [_trialId, []];
private _show = (_activeTids find _trialId) >= 0;
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

true
