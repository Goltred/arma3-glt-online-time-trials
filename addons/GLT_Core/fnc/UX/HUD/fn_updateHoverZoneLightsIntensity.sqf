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
    private _myRun = [] call GLT_Trials_fnc_resolveClientHudRun;
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
private _dFar = uiNamespace getVariable ["GLT_Trials_hoverZoneLightDimFar", 95];
private _dClose = uiNamespace getVariable ["GLT_Trials_hoverZoneLightDimClose", 32];
[_objs, _ctr, _rgb, _dFar, _dClose] call GLT_Trials_fnc_applyDistanceLightIntensity;

true
