/*
    GLT_Trials_fnc_updateHoverZoneLightsIntensity
    Client: fade hover helper lights by distance from the pilot's eyes — brighter when
    approaching, dimmer up close (flares stay on; strength ramps to a low floor near the zone).
    Expects uiNamespace: GLT_Trials_hoverZoneLightObjs, center, dim distances. Colour: red until the
    server reports hover accumulation (row index 14 >= 0), then green.

    Throttled (~15 Hz): four #lightpoints × a few setLight* calls per update is already light;
    full Draw3D rate is fine too, but this avoids pointless work. Do NOT tie to server tick —
    dimming uses local eyePos; server intervals would add visible stepping when flying.
*/

if (!hasInterface) exitWith {};

private _objs = uiNamespace getVariable ["GLT_Trials_hoverZoneLightObjs", []];
private _ctr = uiNamespace getVariable ["GLT_Trials_hoverZoneLightCenter", []];

if ((count _ctr) < 3) exitWith {};
private _alive = false;
{ if (!isNull _x) exitWith { _alive = true }; } forEach _objs;
if (!_alive) exitWith {};

// ~15 updates/sec — smooth enough for distance fade, fewer calls than every Draw3D.
private _hz = 15;
private _lastT = uiNamespace getVariable ["GLT_Trials_hoverLightIntLastT", -1e9];
if ((time - _lastT) < (1 / _hz)) exitWith {};
uiNamespace setVariable ["GLT_Trials_hoverLightIntLastT", time];

// Red = in segment but not yet meeting hover cylinder / timer; green = server is accumulating hover (index 14).
private _inHover = false;
if !(isNil "GLT_Trials_activeRunsPublic") then {
    private _myUID = getPlayerUID player;
    private _myRunId = parseNumber (str GLT_Trials_clientRunId);
    private _cand = GLT_Trials_activeRunsPublic select { parseNumber (str (_x select 0)) isEqualTo _myRunId };
    private _myRun = if (count _cand > 0) then { _cand select 0 } else { [] };
    if ((count _myRun) isEqualTo 0) then {
        _cand = GLT_Trials_activeRunsPublic select { (_x select 1) isEqualTo _myUID };
        _myRun = if (count _cand > 0) then { _cand select 0 } else { [] };
    };
    if (
        (count _myRun) > 0
        && { (_myRun param [9, ""]) isEqualTo "HOVER_POINT" }
    ) then {
        _inHover = (_myRun param [14, -1]) >= 0;
    };
};

private _rgb = if (_inHover) then {
    [0.2, 0.92, 0.32]
} else {
    [0.95, 0.14, 0.12]
};
private _r = _rgb select 0;
private _g = _rgb select 1;
private _b = _rgb select 2;

// 3D distance from eyes to waypoint center (works in cockpit / helicopter).
private _d = (eyePos player) distance _ctr;

// From Eden (per hover waypoint), with script fallbacks.
private _dFar = uiNamespace getVariable ["GLT_Trials_hoverZoneLightDimFar", 95];
private _dClose = uiNamespace getVariable ["GLT_Trials_hoverZoneLightDimClose", 32];
if (_dFar < 25) then { _dFar = 25 };
if (_dClose < 5) then { _dClose = 5 };
if (_dClose >= _dFar) then { _dClose = (_dFar * 0.34) max 8 min (_dFar - 5) };

// Inside _dClose: strongest dim (still visible). Beyond _dFar: full strength.
private _t = ((_d - _dClose) / (_dFar - _dClose)) max 0 min 1;
// Smoothstep
private _u = _t * _t * (3 - 2 * _t);

// Intensity multiplier: ~0.14 when very close, 1.0 when far.
private _mul = 0.14 + 0.86 * _u;

private _bright = (25 * _mul) max 3 min 25;
private _amb = 0.12 * _mul;

private _flare = (0.42 + 1.38 * _u) max 0.35 min 1.85;
private _flareDist = (45 + 135 * _u) max 40 min 180;

{
    if (!isNull _x) then {
        _x setLightColor [_r, _g, _b];
        _x setLightUseFlare true;
        _x setLightBrightness _bright;
        _x setLightAmbient [_r * _amb, _g * _amb, _b * _amb];
        _x setLightFlareSize _flare;
        _x setLightFlareMaxDistance _flareDist;
        // Tighter falloff when close = less terrain flood; softer when far = visible approach.
        private _quad = 2.2 + 5.5 * (1 - _u);
        _x setLightAttenuation [0.12, 55 + 25 * _u, 0, _quad];
    };
} forEach _objs;

true
