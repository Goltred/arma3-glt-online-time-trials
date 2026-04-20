/*
    GLT_Trials_fnc_updateSlingDeliverRectLightsIntensity
    Client: distance fade + red / yellow / green from server row index 18.
*/

if (!hasInterface) exitWith {};

private _objs = uiNamespace getVariable ["GLT_Trials_slingDeliverLightObjs", []];
private _ctr = uiNamespace getVariable ["GLT_Trials_slingDeliverLightCenter", []];

if ((count _ctr) < 3) exitWith {};
private _alive = false;
{ if (!isNull _x) exitWith { _alive = true }; } forEach _objs;
if (!_alive) exitWith {};

private _hz = 15;
private _lastT = uiNamespace getVariable ["GLT_Trials_slingDeliverLightIntLastT", -1e9];
if ((time - _lastT) < (1 / _hz)) exitWith {};
uiNamespace setVariable ["GLT_Trials_slingDeliverLightIntLastT", time];

private _state = -1;
if !(isNil "GLT_Trials_activeRunsPublic") then {
    private _myRun = [] call GLT_Trials_fnc_resolveClientHudRun;
    private _segT = _myRun param [9, ""];
    if ((count _myRun) > 0 && { _segT isEqualTo "SLING_DELIVER_RECT" || { _segT isEqualTo "SLING_DELIVER_CIRCLE" } }) then {
        _state = _myRun param [18, -1];
    };
};

private _rgb = switch (_state) do {
    case 1: { [0.95, 0.85, 0.12] };
    case 2: { [0.2, 0.92, 0.32] };
    default { [0.95, 0.14, 0.12] };
};
private _r = _rgb select 0;
private _g = _rgb select 1;
private _b = _rgb select 2;

private _d = (eyePos player) distance _ctr;

private _dFar = uiNamespace getVariable ["GLT_Trials_slingDeliverLightDimFar", 95];
private _dClose = uiNamespace getVariable ["GLT_Trials_slingDeliverLightDimClose", 32];
if (_dFar < 25) then { _dFar = 25 };
if (_dClose < 5) then { _dClose = 5 };
if (_dClose >= _dFar) then { _dClose = (_dFar * 0.34) max 8 min (_dFar - 5) };

private _t = ((_d - _dClose) / (_dFar - _dClose)) max 0 min 1;
private _u = _t * _t * (3 - 2 * _t);
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
        private _quad = 2.2 + 5.5 * (1 - _u);
        _x setLightAttenuation [0.12, 55 + 25 * _u, 0, _quad];
    };
} forEach _objs;

true
