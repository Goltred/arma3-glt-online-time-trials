/*
    GLT_Trials_fnc_applyDistanceLightIntensity
    Client: shared distance-based light fade and attenuation profile.
    Params: [_objs, _center, _rgb, _dFar, _dClose]
*/

params ["_objs", "_center", "_rgb", "_dFar", "_dClose"];

if ((count _center) < 3) exitWith {};

private _r = _rgb select 0;
private _g = _rgb select 1;
private _b = _rgb select 2;

private _dist = (eyePos player) distance _center;

if (_dFar < 25) then { _dFar = 25 };
if (_dClose < 5) then { _dClose = 5 };
if (_dClose >= _dFar) then { _dClose = (_dFar * 0.34) max 8 min (_dFar - 5) };

private _t = ((_dist - _dClose) / (_dFar - _dClose)) max 0 min 1;
private _u = _t * _t * (3 - 2 * _t);
private _mul = 0.14 + 0.86 * _u;

private _bright = (25 * _mul) max 3 min 25;
private _amb = 0.12 * _mul;
private _flare = (0.42 + 1.38 * _u) max 0.35 min 1.85;
private _flareDist = (45 + 135 * _u) max 40 min 180;
private _quad = 2.2 + 5.5 * (1 - _u);
private _lin = 55 + 25 * _u;

{
    if (!isNull _x) then {
        _x setLightColor [_r, _g, _b];
        _x setLightUseFlare true;
        _x setLightBrightness _bright;
        _x setLightAmbient [_r * _amb, _g * _amb, _b * _amb];
        _x setLightFlareSize _flare;
        _x setLightFlareMaxDistance _flareDist;
        _x setLightAttenuation [0.12, _lin, 0, _quad];
    };
} forEach _objs;

true
