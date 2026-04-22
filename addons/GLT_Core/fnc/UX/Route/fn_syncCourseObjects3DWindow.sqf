/*
    GLT_Trials_fnc_syncCourseObjects3DWindow
    Client: locally hide course objects (start / gates / hover VR disc / land / sling helpers) so only
    the current route step and the next two remain visible in 3D. Does not touch map markers.

    Server still toggles hideObjectGlobal via syncCourseObjectVisibilityFull / ForTrialIds when a trial has any active run;
    this layer applies hideObject (local only) for the driver and vehicle crew based on HUD run state.

    Important: local hideObject false overrides hideObjectGlobal true (BIKI). After a run finishes, the
    server hides the course globally; do not keep re-applying the last window (END leaves the end ring
    with hideObject false) or that ring stays visible until local overrides are cleared.

    Trial row GLT_Trials_trials index 8 = course object list; index 9 = vehicle category mask (see registerTrial).
    Each course object should have GLT_Trials_routeIndex (set
    at register time). Missing routeIndex => left visible (compat with older missions).

    Optional: missionNamespace GLT_Trials_timeTrialsShowFullCourse3D = true — disable windowing.
*/

if (!hasInterface) exitWith {};

private _applyWindow = {
    params ["_activeR", "_iMax", "_courseObjs"];
    {
        if (isNull _x) then { continue };
        if (_x getVariable ["GLT_Trials_runtimeAlwaysHidden", false]) then {
            _x hideObject true;
            continue;
        };
        private _ri = _x getVariable ["GLT_Trials_routeIndex", -1];
        private _show = true;
        if (_ri >= 0) then {
            _show = _ri >= _activeR && { _ri <= _iMax };
        };
        _x hideObject (!_show);
    } forEach _courseObjs;
};

// Clear local hideObject overrides so server hideObjectGlobal is not defeated (see header).
private _resetLocal = {
    private _objs = missionNamespace getVariable ["GLT_Trials_course3dWindowObjs", []];
    if ((count _objs) isEqualTo 0) then {
        private _c = missionNamespace getVariable ["GLT_Trials_course3dCache", []];
        if ((count _c) >= 3) then { _objs = _c select 2 };
    };
    if ((count _objs) isEqualTo 0) then {
        if (!isNil "GLT_Trials_lastSeenRunRow") then {
            private _tid = GLT_Trials_lastSeenRunRow param [13, ""];
            if (!isNil "GLT_Trials_trials" && { _tid isNotEqualTo "" }) then {
                private _trialRow = [];
                {
                    if ((_x select 0) isEqualTo _tid) exitWith { _trialRow = _x };
                } forEach GLT_Trials_trials;
                _objs = _trialRow param [8, []];
            };
        };
    };
    {
        if (!isNull _x) then {
            _x hideObject true;
        };
    } forEach _objs;
    missionNamespace setVariable ["GLT_Trials_course3dWindowObjs", []];
    missionNamespace setVariable ["GLT_Trials_course3dCache", []];
};

if (!GLT_Trials_clientHudShown) exitWith { call _resetLocal };

// While HUD thinks we have a run, missing/empty public row is usually a short MP sync gap
// (broadcast ~0.25s). Resetting here would hideObject false on everything for one frame — END
// During brief empty activeRunsPublic, keep last frame's local visibility instead of flashing.
private _runIdN = if (isNil "GLT_Trials_clientRunId") then { -1 } else { parseNumber (str GLT_Trials_clientRunId) };
private _expectingRunRow = _runIdN >= 0;

if (isNil "GLT_Trials_activeRunsPublic") exitWith {
    if (!_expectingRunRow) then { call _resetLocal } else {
        private _gapCache = missionNamespace getVariable ["GLT_Trials_course3dCache", []];
        if ((count _gapCache) >= 3) then { _gapCache call _applyWindow };
    };
};

private _myRun = [] call GLT_Trials_fnc_resolveClientHudRun;

if ((count _myRun) isEqualTo 0) exitWith {
    if (!_expectingRunRow) then {
        call _resetLocal;
    } else {
        private _syncedOnce = missionNamespace getVariable ["GLT_Trials_clientRunSyncedOnce", false];
        if (!_syncedOnce) then {
            // First server row not yet seen: empty public list is usually a short MP sync gap.
            private _gapCache = missionNamespace getVariable ["GLT_Trials_course3dCache", []];
            if ((count _gapCache) >= 3) then { _gapCache call _applyWindow };
        } else {
            // Row gone after we had a row: run finished/aborted — do not re-apply END window (local hideObject false).
            call _resetLocal;
        };
    };
};

if (missionNamespace getVariable ["GLT_Trials_timeTrialsShowFullCourse3D", false]) exitWith {
    private _trialRowFull = [];
    private _tidF = _myRun param [13, ""];
    if (!isNil "GLT_Trials_trials" && { _tidF isNotEqualTo "" }) then {
        {
            if ((_x select 0) isEqualTo _tidF) exitWith { _trialRowFull = _x };
        } forEach GLT_Trials_trials;
    };
    private _objsF = _trialRowFull param [8, []];
    {
        if (!isNull _x) then {
            _x hideObject (_x getVariable ["GLT_Trials_runtimeAlwaysHidden", false]);
        };
    } forEach _objsF;
    missionNamespace setVariable ["GLT_Trials_course3dWindowObjs", _objsF];
    missionNamespace setVariable ["GLT_Trials_course3dCache", []];
};

private _tid = _myRun param [13, ""];
private _trialRow = [];
if (!isNil "GLT_Trials_trials" && { _tid isNotEqualTo "" }) then {
    {
        if ((_x select 0) isEqualTo _tid) exitWith { _trialRow = _x };
    } forEach GLT_Trials_trials;
};

private _courseObjs = _trialRow param [8, []];
if ((count _courseObjs) isEqualTo 0) exitWith {};

private _route = _trialRow param [7, []];
if ((count _route) isEqualTo 0) exitWith {};

private _segType = _myRun param [9, ""];
private _wpIndex = _myRun param [10, 0];
if !(_wpIndex isEqualType 0) then { _wpIndex = parseNumber (str _wpIndex) };

// mapRoute is segment-only; route index matches HUD waypoint index.
private _activeR = _wpIndex;

if (_activeR < 0) then { _activeR = 0 };
private _nR = count _route;
if (_activeR >= _nR) then { _activeR = _nR - 1 };

private _iMax = (_activeR + 2) min (_nR - 1);

[_activeR, _iMax, _courseObjs] call _applyWindow;

missionNamespace setVariable ["GLT_Trials_course3dWindowObjs", _courseObjs];
missionNamespace setVariable ["GLT_Trials_course3dCache", [_activeR, _iMax, _courseObjs]];

true
