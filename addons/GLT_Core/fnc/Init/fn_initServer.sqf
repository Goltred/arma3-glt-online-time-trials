/*
    GLT_Trials_fnc_initServer
    Server-side bootstrap for the helicopter time trial framework.
*/

if (!isServer) exitWith {};

// Server authoritative containers
GLT_Trials_trials = [];                   // public trial list: [trialId, trialName, allowedHelis]
GLT_Trials_trialsById = createHashMap;   // internal trial configs by id
GLT_Trials_activeRunsPrivate = [];       // internal run hashmaps
GLT_Trials_activeRunsPublic = [];        // for clients (HUD)
// Client HUD: [[runId, pilotUID, completedBool, elapsedSec], ...] for runs that ended this tick (success or discard)
GLT_Trials_runEndBroadcast = [];
GLT_Trials_recentRuns = [];              // completed runs (server internal)
GLT_Trials_recentRunsPublic = [];       // completed runs (client leaderboard)

// Persistence config
GLT_Trials_persistenceMode = 0;         // 0 = no persistence, 1 = profileNamespace
GLT_Trials_leaderboardSize = 15;        // max entries to keep
GLT_Trials_persistenceBackend = "profileNamespace"; // pluggable backend name

// Allow mission designer to override persistence mode via missionNamespace var
if (!isNil { missionNamespace getVariable "GLT_Trials_persistenceMode" }) then {
    GLT_Trials_persistenceMode = missionNamespace getVariable ["GLT_Trials_persistenceMode", 0];
};

// Eden master object can override persistence config
private _masters = allMissionObjects "GLT_Trials_Master";
if (count _masters > 0) then {
    // If multiple exist, last one wins.
    private _m = _masters select (count _masters - 1);
    GLT_Trials_persistenceMode = _m getVariable ["GLT_Trials_persistenceMode", GLT_Trials_persistenceMode];
    GLT_Trials_leaderboardSize = _m getVariable ["GLT_Trials_leaderboardSize", GLT_Trials_leaderboardSize];
    GLT_Trials_persistenceBackend = _m getVariable ["GLT_Trials_persistenceBackend", GLT_Trials_persistenceBackend];
};

// Register trials after a short delay so mission objects (and Eden attribute variables) exist on dedicated server.
[] spawn {
    uiSleep 0.1;
    [] call GLT_Trials_fnc_registerTrial;
};

// Load leaderboard if persistence enabled
if (GLT_Trials_persistenceMode > 0) then {
    GLT_Trials_recentRuns = ["default", GLT_Trials_persistenceMode] call GLT_Trials_fnc_loadLeaderboard;
};

// Clamp loaded data to current leaderboard size (keeps chronological tail).
if (count GLT_Trials_recentRuns > GLT_Trials_leaderboardSize) then {
    private _start = (count GLT_Trials_recentRuns) - GLT_Trials_leaderboardSize;
    GLT_Trials_recentRuns = GLT_Trials_recentRuns select [_start, GLT_Trials_leaderboardSize];
};

GLT_Trials_recentRunsPublic = +GLT_Trials_recentRuns;
// Sort client-facing leaderboard by total runtime (index 2 of entry)
GLT_Trials_recentRunsPublic = [GLT_Trials_recentRunsPublic, [], { _x select 2 }, "ASCEND"] call BIS_fnc_sortBy;

// Start server tick loop for active runs
[] spawn {
    while {true} do {
        // Tick every 0.1s for reasonably smooth timing
        [time] call GLT_Trials_fnc_tickServer;
        uiSleep 0.1;
    };
};

publicVariable "GLT_Trials_persistenceMode";
publicVariable "GLT_Trials_leaderboardSize";
publicVariable "GLT_Trials_persistenceBackend";

// GLT_Trials_trials is broadcast from GLT_Trials_fnc_registerTrial once the scan completes.
publicVariable "GLT_Trials_activeRunsPublic";
publicVariable "GLT_Trials_runEndBroadcast";
publicVariable "GLT_Trials_recentRunsPublic";

