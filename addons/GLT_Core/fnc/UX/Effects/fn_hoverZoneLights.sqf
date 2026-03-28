/*
    GLT_Trials_fnc_hoverZoneLights
    Client-only: place 4 local #lightpoint sources in a cross or square around a center (ASL).
    Helps pilots see hover waypoints when the VR disc is hard to see from below.

    Params: [_centerASL, _armMeters, _pattern, _rgbColor, _dimFar_m, _dimClose_m]
      _centerASL: world position (getPosASL / getPosWorld style [x,y,z])
      _armMeters: horizontal offset from center for each lamp (default 8)
      _pattern: "CROSS" (cardinal N/E/S/W) or "BOX" (square corners) — default "CROSS"
      _rgbColor: initial [R,G,B] 0..1 — updated live by fn_updateHoverZoneLightsIntensity (red / green)
      _dimFar_m: eye distance (m) beyond which lights are full strength (Eden default 95)
      _dimClose_m: eye distance (m) inside which lights are dimmest (Eden default 32)

    Replaces any previous cluster created by this function (same client).
*/

if (!hasInterface) exitWith {};

params [
    ["_center", [0, 0, 0], [[]]],
    ["_arm", 8, [0]],
    ["_pattern", "CROSS", [""]],
    ["_rgb", [0.85, 1, 0.15], [[]]],
    ["_dimFar", 95, [0]],
    ["_dimClose", 32, [0]]
];

if ((count _center) < 3) exitWith {};

if (_dimFar < 25) then { _dimFar = 25 };
if (_dimClose < 5) then { _dimClose = 5 };
if (_dimClose >= _dimFar) then { _dimClose = (_dimFar * 0.34) max 8 min (_dimFar - 5) };

private _pat = toUpper _pattern;
private _offs = if (_pat isEqualTo "BOX") then {
    [
        [_arm, _arm, 0],
        [-_arm, _arm, 0],
        [-_arm, -_arm, 0],
        [_arm, -_arm, 0]
    ]
} else {
    // CROSS: +X, -X, +Y, -Y in world space (horizontal plane)
    [
        [_arm, 0, 0],
        [-_arm, 0, 0],
        [0, _arm, 0],
        [0, -_arm, 0]
    ]
};

private _sig = format ["%1_%2_%3_%4_%5", _center, _arm, _pat, _dimFar, _dimClose];
private _oldSig = uiNamespace getVariable ["GLT_Trials_hoverLightSig", ""];
private _oldObjs = uiNamespace getVariable ["GLT_Trials_hoverZoneLightObjs", []];
private _anyLight = false;
{ if (!isNull _x) exitWith { _anyLight = true }; } forEach _oldObjs;

if ((_sig isEqualTo _oldSig) && _anyLight) exitWith {};

// Recycle: drop old points
[] call GLT_Trials_fnc_clearHoverZoneLights;
uiNamespace setVariable ["GLT_Trials_hoverLightSig", _sig];

private _lift = 0.4;
private _lights = [];
private _r = _rgb param [0, 0.85, [0]];
private _g = _rgb param [1, 1, [0]];
private _b = _rgb param [2, 0.15, [0]];

{
    private _pos = [
        (_center select 0) + (_x select 0),
        (_center select 1) + (_x select 1),
        (_center select 2) + (_x select 2) + _lift
    ];
    private _li = "#lightpoint" createVehicleLocal [0, 0, 0];
    _li setPosASL _pos;
    _li setLightColor [_r, _g, _b];
    _li setLightDayLight true;
    _li setLightUseFlare true;
    // Initial values; fn_updateHoverZoneLightsIntensity sets brightness/ambient/flare each frame.
    _li setLightBrightness 25;
    _li setLightAmbient [_r * 0.12, _g * 0.12, _b * 0.12];
    _li setLightFlareSize 1.8;
    _li setLightFlareMaxDistance 180;
    _li setLightAttenuation [0.12, 60, 0, 4.5];
    _lights pushBack _li;
} forEach _offs;

uiNamespace setVariable ["GLT_Trials_hoverZoneLightObjs", _lights];
uiNamespace setVariable ["GLT_Trials_hoverZoneLightCenter", +_center];
uiNamespace setVariable ["GLT_Trials_hoverZoneLightRGB", [_r, _g, _b]];
uiNamespace setVariable ["GLT_Trials_hoverZoneLightDimFar", _dimFar];
uiNamespace setVariable ["GLT_Trials_hoverZoneLightDimClose", _dimClose];

true
