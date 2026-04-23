/*
    GLT_Trials_fnc_tickServerUpdateCourseVisDiff
    Server: sync course object visibility when active-trial membership changes.
    Params: none (reads missionNamespace trial globals)
*/

if (!isNil "GLT_Trials_trials" && { (count GLT_Trials_trials) > 0 }) then {
    private _nowTids = [] call GLT_Trials_fnc_collectActiveTrialIds;

    private _prev = GLT_Trials_courseVisLastActiveTids;
    private _dirtyTids = [];
    {
        if (!(_x in _prev)) then { _dirtyTids pushBackUnique _x };
    } forEach _nowTids;
    {
        if (!(_x in _nowTids)) then { _dirtyTids pushBackUnique _x };
    } forEach _prev;

    if ((count _dirtyTids) > 0) then {
        _dirtyTids call GLT_Trials_fnc_syncCourseObjectVisibilityForTrialIds;
    };
    GLT_Trials_courseVisLastActiveTids = +_nowTids;
};
