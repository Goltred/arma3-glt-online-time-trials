/*
    GLT_Trials_fnc_updateTerminalScreens
    Builds terminal Rsc content for a single player.

    Params: ["_mode"]
    Returns: [titleText, bodyStructuredText]
*/

params ["_mode"];
if (!hasInterface) exitWith { ["Time Trials Terminal", "<t size='0.9'>Client unavailable.</t>"] };

if (isNil "GLT_Trials_activeRunsPublic") exitWith { ["Time Trials Terminal", "<t size='0.9'>Waiting for server data...</t>"] };
if (isNil "GLT_Trials_recentRunsPublic") exitWith { ["Time Trials Terminal", "<t size='0.9'>Waiting for server data...</t>"] };

private _modeUpper = toUpper _mode;
private _title = "Time Trials Terminal";
private _body = "";

switch (_modeUpper) do {
    case "LIVE": {
        _title = "Time Trials - Live Trials";
        private _runs = GLT_Trials_activeRunsPublic;
        if ((count _runs) isEqualTo 0) then {
            _body = "<t size='0.9' color='#cccccc'>No active trials.</t>";
        } else {
            private _maxRows = 24;
            private _end = ((count _runs) min _maxRows);
            for "_i" from 0 to (_end - 1) do {
                private _run = _runs select _i;
                private _heliCallsign = _run select 2;
                private _pilotName = _run select 3;
                private _grid = _run select 4;
                private _trialName = _run select 5;
                private _segmentDesc = _run select 6;
                private _elapsed = _run select 7;

                _body = _body + format [
                    "<t size='0.88' color='#ffffff'>%1 - %2</t><br/><t size='0.8' color='#9ad9ff'>%3 - %4</t><br/><t size='0.8' color='#cfcfcf'>%5 (%6)</t><br/><br/>",
                    _heliCallsign,
                    _pilotName,
                    _grid,
                    _trialName,
                    _segmentDesc,
                    [_elapsed] call BIS_fnc_secondsToString
                ];
            };
        };
    };

    case "LEADERBOARD": {
        _title = "Time Trials - Leaderboard";
        private _rows = GLT_Trials_recentRunsPublic;
        if ((count _rows) isEqualTo 0) then {
            _body = "<t size='0.9' color='#cccccc'>No completed runs yet.</t>";
        } else {
            private _maxRows = 20;
            private _end = ((count _rows) min _maxRows);
            for "_i" from 0 to (_end - 1) do {
                private _entry = _rows select _i;
                private _trialName = _entry select 0;
                private _pilotName = _entry select 1;
                private _totalTime = _entry select 2;
                private _dateStamp = _entry select 3;
                private _rank = _i + 1;

                // One line: Rank - Trial - Pilot - Date - Run time
                _body = _body + format [
                    "<t size='0.85' color='#ffffff'><t color='#ffd36e'>#%1</t> - %2 - %3 - %4 - %5</t><br/>",
                    _rank,
                    _trialName,
                    _pilotName,
                    _dateStamp,
                    ([_totalTime] call BIS_fnc_secondsToString)
                ];
            };
        };
    };

    default {
        _body = "<t size='0.9' color='#ff8888'>Unknown terminal mode.</t>";
    };
};

[_title, _body]

