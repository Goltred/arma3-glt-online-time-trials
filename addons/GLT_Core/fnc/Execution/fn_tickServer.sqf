/*
    GLT_Trials_fnc_tickServer
    Server tick for active runs.
    Params: [_now]
*/

params ["_now"];
if (!isServer) exitWith {};
if (!(missionNamespace getVariable ["GLT_Trials_trialsAvailable", false]) && { (count GLT_Trials_activeRunsPrivate) isEqualTo 0 }) exitWith { true };

if (isNil "GLT_Trials_lastBroadcastTime") then {
    GLT_Trials_lastBroadcastTime = 0;
};

private _broadcastInterval = 0.25;
private _activePublic = [];
private _runEndSignals = [];

// Iterate and keep only non-finished runs.
private _remaining = [];
{
    private _run = _x;
    private _finished = false;
    if (_run getOrDefault ["pilotCancelRequested", false]) then {
        _run set ["didFinish", false];
        _finished = true;
    } else {
        _finished = [_run, _now] call GLT_Trials_fnc_updateRunState;
    };

    if (_finished) then {
        // Finished run: finalize leaderboard and skip from active list.
        // updateRunState returns true also for abort cases (e.g., destroyed trial vehicle).
        // We only record leaderboard if this was a real finish (not an abort).
        _runEndSignals pushBack ([_run, _now] call GLT_Trials_fnc_tickServerProcessFinishedRun);
    } else {
        _remaining pushBack _run;

        // Build public run state for HUD.
        private _trial = GLT_Trials_trialsById getOrDefault [_run get "trialId", nil];
        if (!isNil "_trial") then {
            private _row = [_run, _now, _trial] call GLT_Trials_fnc_tickServerBuildActiveRunPublicRow;
            _activePublic pushBack _row;
        };
    };
} forEach GLT_Trials_activeRunsPrivate;

GLT_Trials_activeRunsPrivate = _remaining;
GLT_Trials_activeRunsPublic = _activePublic;

if ((count _runEndSignals) > 0) then {
    GLT_Trials_runEndBroadcast = _runEndSignals;
    publicVariable "GLT_Trials_runEndBroadcast";
};

[_now, _broadcastInterval] call GLT_Trials_fnc_tickServerMaybeBroadcast;

[] call GLT_Trials_fnc_tickServerUpdateCourseVisDiff;

true
