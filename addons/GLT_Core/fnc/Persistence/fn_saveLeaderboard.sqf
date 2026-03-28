/*
    GLT_Trials_fnc_saveLeaderboard
    Params: [_key, _mode]
    Saves current GLT_Trials_recentRuns to configured backend.
*/

params ["_key", "_mode"];

if (!isServer) exitWith {};
if (isNil "_mode") then { _mode = 0 };
if (_mode <= 0) exitWith {};

private _backend = GLT_Trials_persistenceBackend;
if (isNil "_backend") then { _backend = "profileNamespace" };

private _data = +GLT_Trials_recentRuns;

switch (_backend) do {
    case "profileNamespace": {
        private _varName = format ["GLT_Trials_leaderboard_%1", _key];
        profileNamespace setVariable [_varName, _data];
        saveProfileNamespace;
    };
    default {
        // No-op for unsupported backends.
    };
};

true

