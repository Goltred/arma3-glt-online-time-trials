/*
    GLT_Trials_fnc_finishRun
    Server-side finalize logic for a finished run.
    Params: [_run, _now]
*/

params ["_run", "_now"];
if (!isServer) exitWith {};

[_run] call GLT_Trials_fnc_cleanupSlingCargo;
[_run] call GLT_Trials_fnc_cleanupDestroyTargets;

private _runId = _run get "runId";
private _trialName = _run get "trialName";
private _pilotName = _run get "pilotName";

private _startTime = _run get "startTime";
private _totalTime = _now - _startTime;
if (_totalTime < 0) then { _totalTime = 0 };

// Real-world date on the server host (mission `date` is scenario fiction, e.g. 1994 on Everon).
private _d = systemTime;
private _year = _d select 0;
private _month = _d select 1;
private _day = _d select 2;
private _dateStamp = format ["%1/%2/%3", _day, _month, _year];

private _entry = [_trialName, _pilotName, _totalTime, _dateStamp];

GLT_Trials_recentRuns pushBack _entry;

// Keep only last N completed runs (chronological completion order)
private _keep = GLT_Trials_leaderboardSize;
if (count GLT_Trials_recentRuns > _keep) then {
    private _toRemove = (count GLT_Trials_recentRuns) - _keep;
    for "_i" from 1 to _toRemove do {
        GLT_Trials_recentRuns deleteAt 0;
    };
};

// Build client leaderboard view ordered by totalTime (runtime)
// recentRunsPublic expects the same entry shape; we sort a copy.
GLT_Trials_recentRunsPublic = +GLT_Trials_recentRuns;
GLT_Trials_recentRunsPublic = [GLT_Trials_recentRunsPublic, [], { _x select 2 }, "ASCEND"] call BIS_fnc_sortBy;

// Optional persistence save
if (GLT_Trials_persistenceMode > 0) then {
    ["default", GLT_Trials_persistenceMode] call GLT_Trials_fnc_saveLeaderboard;
};

// No return value.

