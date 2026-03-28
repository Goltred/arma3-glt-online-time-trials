/*
    GLT_Trials_fnc_openTerminalView
    Opens the terminal Rsc window with switchable LIVE/LEADERBOARD tabs.

    Params: ["_mode", "_terminal", "_caller"]
*/

params ["_mode", "_terminal", "_caller"];
if (!hasInterface) exitWith {};
if (isNull _terminal) exitWith {};
if (isNil "_caller") exitWith {};
if (_caller isNotEqualTo player) exitWith {};

private _modeUpper = toUpper _mode;
if !(_modeUpper in ["LIVE", "LEADERBOARD"]) then { _modeUpper = "LIVE" };

if (isNil "GLT_Trials_terminalViewToken") then { GLT_Trials_terminalViewToken = 0 };
GLT_Trials_terminalViewToken = GLT_Trials_terminalViewToken + 1;
private _token = GLT_Trials_terminalViewToken;

missionNamespace setVariable ["GLT_Trials_terminalMode", _modeUpper];
missionNamespace setVariable ["GLT_Trials_terminalObject", _terminal];
GLT_Trials_terminalViewActive = true;
hintSilent "";

if (!isNull findDisplay 88100) then { closeDialog 0 };
createDialog "RscDisplayGLT_Trials_Terminal";
private _disp = findDisplay 88100;
if (isNull _disp) exitWith { GLT_Trials_terminalViewActive = false; false };

[_modeUpper] call GLT_Trials_fnc_terminalDialogButton;

[_terminal, _token] spawn {
    params ["_termLocal", "_tokenLocal"];

    while {
        alive player
        && { !isNull _termLocal }
        && { (player distance _termLocal) <= 4 }
        && { GLT_Trials_terminalViewToken isEqualTo _tokenLocal }
        && { !isNull findDisplay 88100 }
    } do {
        private _dispLocal = findDisplay 88100;
        private _modeLocal = missionNamespace getVariable ["GLT_Trials_terminalMode", "LIVE"];
        private _content = [_modeLocal] call GLT_Trials_fnc_updateTerminalScreens;
        private _title = _content select 0;
        private _body = _content select 1;

        (_dispLocal displayCtrl 1100) ctrlSetText _title;
        (_dispLocal displayCtrl 1101) ctrlSetStructuredText parseText _body;
        uiSleep 0.2;
    };

    if (GLT_Trials_terminalViewToken isEqualTo _tokenLocal) then {
        GLT_Trials_terminalViewActive = false;
        if (!isNull findDisplay 88100) then { closeDialog 0 };
    };
};

true

