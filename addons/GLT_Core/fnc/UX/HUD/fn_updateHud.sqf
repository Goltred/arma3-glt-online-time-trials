/*
    GLT_Trials_fnc_updateHud
    Enables client-side HUD drawing for the given runId.
    Params: [_runId]
*/

params ["_runId"];
if (!hasInterface) exitWith {};
if (isNil "_runId") exitWith {};

private _rid = if (_runId isEqualType 0) then { _runId } else { parseNumber (str _runId) };
if (_rid < 0) exitWith {};

GLT_Trials_clientRunId = _rid;
GLT_Trials_clientHudShown = true;
// Fresh grace window for Draw3D until activeRunsPublic catches up (server tick is ~0.1s).
GLT_Trials_clientRunSyncStarted = -1;
// Until true, empty active list means "still syncing"; after true, empty means "run ended" (no false syncing).
GLT_Trials_clientRunSyncedOnce = false;
GLT_Trials_clientHudSpectator = false;

true

