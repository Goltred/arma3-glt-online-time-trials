/*
    GLT_Trials_fnc_startRun
    Server-side start handler for a driver selecting a trial.
    Params: [_heli, _trialId, _player]
    Returns: runId (number) or -1 if rejected.
*/

params ["_heli", "_trialId", "_player"];

if (!isServer) exitWith {-1};
if (isNull _heli) exitWith {-1};
if (isNull _player) exitWith {-1};
if (!isPlayer _player) exitWith {-1};

diag_log text format [
    "[PTF_TT][START_RUN] request vehType=%1 trialId=%2 pilot=%3",
    typeOf _heli,
    _trialId,
    name _player
];
private _pilotUID = getPlayerUID _player;
if (_pilotUID isEqualTo "") exitWith {-1};

private _trial = GLT_Trials_trialsById getOrDefault [_trialId, nil];
if (isNil "_trial") exitWith {
    diag_log text format ["[PTF_TT][START_RUN] REJECT trialId=%1 not found", _trialId];
    -1
};

private _trialName = _trial select 1;
private _allowedHelis = _trial select 2;

private _heliType = typeOf _heli;
// Empty allowedHelis = any vehicle classname (see registerTrial / Eden defaults).
if !((count _allowedHelis isEqualTo 0) || (_allowedHelis find _heliType >= 0)) exitWith {
    diag_log text format [
        "[PTF_TT][START_RUN] REJECT vehType=%1 not in allowedHelis=%2",
        _heliType,
        _allowedHelis
    ];
    -1
};

private _catMask = _trial param [17, []];
if ((count _catMask) isEqualTo 4) then {
    if (!([_heli, _catMask] call GLT_Trials_fnc_vehicleMatchesTrialCategoryMask)) exitWith {
        diag_log text format [
            "[PTF_TT][START_RUN] REJECT vehType=%1 fails vehicle category mask=%2",
            _heliType,
            _catMask
        ];
        -1
    };
};

// Only allow one active run per pilot.
if ({ (_x get "pilotUID") isEqualTo _pilotUID } count GLT_Trials_activeRunsPrivate > 0) exitWith {-1};

// Start zone validation removed:
// the timer begins when the pilot flies through the start object plane.

// Ensure player is driving the trial vehicle.
if (driver _heli isNotEqualTo _player) exitWith {
    diag_log "[PTF_TT][START_RUN] REJECT driver is not requesting player";
    -1
};

private _runId = floor (diag_tickTime * 1000);

private _groupId = groupId group _player;
private _heliCallsign = if (_groupId isEqualTo "") then { "UNKNOWN" } else { _groupId };
private _pilotName = name _player;

private _run = createHashMap;
_run set ["runId", _runId];
_run set ["trialId", _trialId];
_run set ["trialName", _trialName];
_run set ["pilotUID", _pilotUID];
_run set ["pilotName", _pilotName];
_run set ["heliCallsign", _heliCallsign];
_run set ["heliType", _heliType];
_run set ["heli", _heli];
_run set ["pilotObj", _player];
// Waiting for fly-through start.
_run set ["startTime", -1];

private _segments = _trial select 9;
// segmentIndex 0 = first waypoint; startTime stays -1 until segment 0 completes (timer arms then).
_run set ["segmentIndex", 0];
_run set ["segmentsCount", count _segments];

_run set ["hoverStartTime", -1];
_run set ["landStayStartTime", -1];
_run set ["slingStayStartTime", -1];
_run set ["endStayStartTime", -1];
_run set ["slingPickupSpawned", false];
_run set ["slingCargoObj", nil];
_run set ["destroyMandatoryObjs", []];
_run set ["destroyOptionalObjs", []];
_run set ["destroyInfMandatoryGrps", []];
_run set ["destroyInfOptionalGrps", []];
_run set ["destroyCurrentObj", objNull];
_run set ["destroyCurrentGroup", grpNull];

_run set ["lastPosWorld", getPosWorld _heli];

// tickServer uses this to decide whether to record leaderboard.
_run set ["didFinish", false];

private _optionalDestroyRows = _trial param [15, []];
private _optionalSpawned = [];
{
    private _spawned = [_x, _player] call GLT_Trials_fnc_spawnDestroyTarget;
    if (!isNull _spawned) then {
        _optionalSpawned pushBack _spawned;
    };
} forEach _optionalDestroyRows;
_run set ["destroyOptionalObjs", _optionalSpawned];

private _optionalDestroyInfRows = _trial param [16, []];
private _optionalSpawnedInf = [];
{
    private _spawnedInf = [_x, _player] call GLT_Trials_fnc_spawnDestroyInfantry;
    private _grpInf = _spawnedInf param [1, grpNull];
    if (!isNull _grpInf) then {
        _optionalSpawnedInf pushBack _grpInf;
    };
} forEach _optionalDestroyInfRows;
_run set ["destroyInfOptionalGrps", _optionalSpawnedInf];

GLT_Trials_activeRunsPrivate pushBack _run;

diag_log text format [
    "[PTF_TT][START_RUN] ACCEPT runId=%1 trialId=%2 vehType=%3 allowedHelis=%4 pilotUID=%5",
    _runId,
    _trialId,
    _heliType,
    _allowedHelis,
    _pilotUID
];

// Publish active run row immediately; tick loop can be up to ~0.1s behind Draw3D on clients.
[time] call GLT_Trials_fnc_tickServer;
publicVariable "GLT_Trials_activeRunsPublic";

_runId

