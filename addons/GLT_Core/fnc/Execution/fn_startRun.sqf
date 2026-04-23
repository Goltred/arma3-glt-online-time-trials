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

private _pilotUID = getPlayerUID _player;
if (_pilotUID isEqualTo "") exitWith {-1};

private _trial = GLT_Trials_trialsById getOrDefault [_trialId, nil];
if (isNil "_trial") exitWith {-1};

// Internal trial row = `_trialConfig` in fn_registerTrial.sqf (order must stay identical).
private _tcTrialName = 1;
private _tcAllowedHelis = 2;
private _tcSegments = 9;
private _tcOptionalDestroyRows = 15;
private _tcOptionalDestroyInfRows = 16;
private _tcVehicleCategoryMask = 17;

private _trialName = _trial select _tcTrialName;
private _allowedHelis = _trial select _tcAllowedHelis;

private _heliType = typeOf _heli;
// Empty allowedHelis = any vehicle classname (see registerTrial / Eden defaults).
if !((count _allowedHelis isEqualTo 0) || (_allowedHelis find _heliType >= 0)) exitWith {-1};

private _catMask = _trial param [_tcVehicleCategoryMask, []];
if ((count _catMask) isEqualTo 4) then {
    if (!([_heli, _catMask] call GLT_Trials_fnc_vehicleMatchesTrialCategoryMask)) exitWith {-1};
};

// Only allow one active run per pilot.
if ({ (_x get "pilotUID") isEqualTo _pilotUID } count GLT_Trials_activeRunsPrivate > 0) exitWith {-1};

// Ensure player is driving the trial vehicle.
if (driver _heli isNotEqualTo _player) exitWith {-1};

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
_run set ["startTime", -1];

private _segments = _trial select _tcSegments;
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

private _optionalDestroyRows = _trial param [_tcOptionalDestroyRows, []];
private _optionalSpawned = [];
{
    private _spawned = [_x, _player] call GLT_Trials_fnc_spawnDestroyTarget;
    if (!isNull _spawned) then {
        _optionalSpawned pushBack _spawned;
    };
} forEach _optionalDestroyRows;
_run set ["destroyOptionalObjs", _optionalSpawned];

private _optionalDestroyInfRows = _trial param [_tcOptionalDestroyInfRows, []];
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

// Publish active run row immediately; tick loop can be up to ~0.1s behind Draw3D on clients.
[time] call GLT_Trials_fnc_tickServer;
publicVariable "GLT_Trials_activeRunsPublic";

_runId

