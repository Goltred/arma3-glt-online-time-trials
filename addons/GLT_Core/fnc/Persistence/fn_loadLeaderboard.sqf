/*
    GLT_Trials_fnc_loadLeaderboard
    Params: [_key, _mode]
    Returns: array of leaderboard entries: [trialName, pilotName, totalTime, dateStamp]
*/

params ["_key", "_mode"];

if (!isServer) exitWith {[]};
if (isNil "_mode") then { _mode = 0 };
if (_mode <= 0) exitWith {[]};

private _backend = GLT_Trials_persistenceBackend;
if (isNil "_backend") then { _backend = "profileNamespace" };

switch (_backend) do {
    case "profileNamespace": {
        private _varName = format ["GLT_Trials_leaderboard_%1", _key];
        private _data = profileNamespace getVariable [_varName, []];
        if (typeName _data isNotEqualTo "ARRAY") then { _data = [] };
        _data
    };
    default {
        []
    };
};

