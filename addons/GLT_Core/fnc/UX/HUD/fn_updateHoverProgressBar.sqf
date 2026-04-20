/*
    GLT_Trials_fnc_updateHoverProgressBar
    Client: IGUI progress bar (right side, below sensor stack) while the pilot is in the
    active HOVER_POINT cylinder or LAND_POINT zone with timer running.
    Uses server row indices 14–15 (mission time start, required seconds).
*/

if (!hasInterface) exitWith {};

private _fncHide = {
    {
        private _c = uiNamespace getVariable [_x, controlNull];
        if (!isNull _c) then {
            _c ctrlShow false;
        };
    } forEach [
        "GLT_Trials_hoverBarBg",
        "GLT_Trials_hoverBarProg",
        "GLT_Trials_hoverBarTxt"
    ];
};

if (!GLT_Trials_clientHudShown) exitWith { call _fncHide };
if (!isNull findDisplay 88100) exitWith { call _fncHide };
if (isNil "GLT_Trials_activeRunsPublic") exitWith { call _fncHide };

private _myRun = [] call GLT_Trials_fnc_resolveClientHudRun;

private _show = false;
private _progress = 0;
private _remain = 0;

if ((count _myRun) > 0) then {
    private _segType = _myRun param [9, ""];
    if (
        (_segType isEqualTo "HOVER_POINT")
        || { _segType isEqualTo "LAND_POINT" }
    ) then {
        private _hStart = _myRun param [14, -1];
        private _hDur = _myRun param [15, 0];
        if ((_hStart >= 0) && {_hDur > 0}) then {
            _show = true;
            private _elapsed = time - _hStart;
            _progress = (_elapsed / _hDur) min 1;
            _remain = (_hDur - _elapsed) max 0;
        };
    };
};

if (!_show) exitWith { call _fncHide };

disableSerialization;

private _disp = [] call BIS_fnc_displayMission;
if (isNull _disp) then { _disp = findDisplay 46 };
if (isNull _disp) exitWith {};

private _prog = uiNamespace getVariable ["GLT_Trials_hoverBarProg", controlNull];
if (!isNull _prog) then {
    if (isNull ctrlParent _prog) then {
        uiNamespace setVariable ["GLT_Trials_hoverBarProg", nil];
        uiNamespace setVariable ["GLT_Trials_hoverBarBg", nil];
        uiNamespace setVariable ["GLT_Trials_hoverBarTxt", nil];
        _prog = controlNull;
    };
};

if (isNull _prog) then {
    private _px = safeZoneX + safeZoneW * 0.74;
    private _pw = safeZoneW * 0.24;
    private _py = safeZoneY + safeZoneH * 0.52;
    private _ph = safeZoneH * 0.018;

    private _bg = _disp ctrlCreate ["RscText", 88411];
    _bg ctrlSetPosition [_px, _py, _pw, _ph];
    _bg ctrlSetBackgroundColor [0, 0, 0, 0.55];
    _bg ctrlCommit 0;

    _prog = _disp ctrlCreate ["RscProgress", 88410];
    _prog ctrlSetPosition [_px + safeZoneW * 0.004, _py + safeZoneH * 0.003, _pw - safeZoneW * 0.008, _ph - safeZoneH * 0.006];
    _prog ctrlSetTextColor [0.25, 0.85, 0.35, 0.95];
    _prog ctrlCommit 0;

    private _txt = _disp ctrlCreate ["RscStructuredText", 88412];
    _txt ctrlSetPosition [_px, _py, _pw, _ph];
    _txt ctrlSetBackgroundColor [0, 0, 0, 0];
    _txt ctrlCommit 0;

    if (isNull _prog || { isNull _txt }) exitWith {};

    uiNamespace setVariable ["GLT_Trials_hoverBarBg", _bg];
    uiNamespace setVariable ["GLT_Trials_hoverBarProg", _prog];
    uiNamespace setVariable ["GLT_Trials_hoverBarTxt", _txt];
};

_prog = uiNamespace getVariable ["GLT_Trials_hoverBarProg", controlNull];
private _bg = uiNamespace getVariable ["GLT_Trials_hoverBarBg", controlNull];
private _txt = uiNamespace getVariable ["GLT_Trials_hoverBarTxt", controlNull];

if (isNull _prog || { isNull _bg } || { isNull _txt }) exitWith {};

_prog progressSetPosition _progress;

// Do not use "%.1f" inside parseText — Structured Text treats % specially and can show ".1f".
private _remStr = if (_remain >= 9.995) then {
    str (floor (_remain + 0.5))
} else {
    private _d10 = round (_remain * 10);
    private _whole = floor (_d10 / 10);
    private _frac = _d10 mod 10;
    if (_frac isEqualTo 0) then {
        str _whole
    } else {
        (str _whole) + "." + (str _frac)
    }
};

private _segTypeBar = _myRun param [9, ""];
private _line = if (_segTypeBar isEqualTo "LAND_POINT") then {
    "Land hold for " + _remStr + "s"
} else {
    "Hold for " + _remStr + "s"
};
_txt ctrlSetStructuredText parseText (
    "<t align='center' valign='middle' size='0.78' color='#ffffff' shadow='2'>" + _line + "</t>"
);

{
    _x ctrlShow true;
} forEach [_bg, _prog, _txt];

true
