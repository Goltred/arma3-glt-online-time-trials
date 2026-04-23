/*
    GLT_Trials_fnc_tickServerProcessFinishedRun
    Server: finalize or cleanup a finished run and produce the run-end broadcast row.
    Params: [_run, _now]
    Returns: [_runId, _pilotUID, _completed, _elapsedShow] for GLT_Trials_runEndBroadcast
*/

params ["_run", "_now"];

private _completed = (_run get "didFinish") isEqualTo true;
private _startTime = _run get "startTime";
private _elapsedShow = 0;
if (_startTime >= 0) then {
    _elapsedShow = _now - _startTime;
    if (_elapsedShow < 0) then { _elapsedShow = 0 };
};

if (_completed) then {
    [_run, _now] call GLT_Trials_fnc_finishRun;
} else {
    [_run] call GLT_Trials_fnc_cleanupSlingCargo;
    [_run] call GLT_Trials_fnc_cleanupDestroyTargets;
};

[
    _run get "runId",
    _run get "pilotUID",
    _completed,
    _elapsedShow
]
