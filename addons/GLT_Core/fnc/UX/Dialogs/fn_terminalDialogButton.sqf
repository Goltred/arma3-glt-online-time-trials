/*
    GLT_Trials_fnc_terminalDialogButton
    Handles tab/close buttons for the terminal Rsc window.
    Params: [_action] where action is "LIVE", "LEADERBOARD", or "CLOSE".
*/

params ["_action"];
if (!hasInterface) exitWith {};

private _act = toUpper _action;
if (_act isEqualTo "CLOSE") exitWith {
    GLT_Trials_terminalViewActive = false;
    closeDialog 0;
};

if !(_act in ["LIVE", "LEADERBOARD"]) exitWith {};
missionNamespace setVariable ["GLT_Trials_terminalMode", _act];

private _disp = findDisplay 88100;
if (isNull _disp) exitWith {};

private _btnLive = _disp displayCtrl 1602;
private _btnLb = _disp displayCtrl 1603;

if (_act isEqualTo "LIVE") then {
    _btnLive ctrlSetTextColor [0.2, 0.9, 1, 1];
    _btnLb ctrlSetTextColor [1, 1, 1, 1];
} else {
    _btnLive ctrlSetTextColor [1, 1, 1, 1];
    _btnLb ctrlSetTextColor [0.2, 0.9, 1, 1];
};

true
