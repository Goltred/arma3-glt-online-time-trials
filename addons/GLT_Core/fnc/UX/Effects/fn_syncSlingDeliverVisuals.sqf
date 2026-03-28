/*
    GLT_Trials_fnc_syncSlingDeliverVisuals
    Client: cones for circle delivery; cones + lights for rectangle (see row indices 18–19).
*/

if (!hasInterface) exitWith {};

if (!GLT_Trials_clientHudShown) exitWith { [] call GLT_Trials_fnc_clearSlingDeliverVisuals };
if (!isNull findDisplay 88100) exitWith { [] call GLT_Trials_fnc_clearSlingDeliverVisuals };
if (isNil "GLT_Trials_activeRunsPublic") exitWith { [] call GLT_Trials_fnc_clearSlingDeliverVisuals };

private _myUID = getPlayerUID player;
private _myRunId = parseNumber (str GLT_Trials_clientRunId);

private _myRunCandidates = GLT_Trials_activeRunsPublic select {
    parseNumber (str (_x select 0)) isEqualTo _myRunId
};
private _myRun = if ((count _myRunCandidates) > 0) then { _myRunCandidates select 0 } else { [] };
if ((count _myRun) isEqualTo 0) then {
    private _uidCandidates = GLT_Trials_activeRunsPublic select { (_x select 1) isEqualTo _myUID };
    _myRun = if ((count _uidCandidates) > 0) then { _uidCandidates select 0 } else { [] };
};

if ((count _myRun) isEqualTo 0) exitWith { [] call GLT_Trials_fnc_clearSlingDeliverVisuals };

private _segType = _myRun param [9, ""];
private _center = _myRun param [8, [0, 0, 0]];
private _viz = _myRun param [19, -1];

if (
    (_segType isNotEqualTo "SLING_DELIVER_CIRCLE")
    && {_segType isNotEqualTo "SLING_DELIVER_RECT"}
) exitWith {
    [] call GLT_Trials_fnc_clearSlingDeliverVisuals
};

if (_viz isEqualTo -1) exitWith { [] call GLT_Trials_fnc_clearSlingDeliverVisuals };
if ((count _center) < 3) exitWith { [] call GLT_Trials_fnc_clearSlingDeliverVisuals };

private _sig = format ["%1_%2_%3", _segType, _center, _viz];
if ((_sig isEqualTo (uiNamespace getVariable ["GLT_Trials_slingDeliverSig", ""])) && {
    count (uiNamespace getVariable ["GLT_Trials_slingDeliverConeObjs", []]) > 0
    && { count (uiNamespace getVariable ["GLT_Trials_slingDeliverLightObjs", []]) > 0 }
}) exitWith {};

[] call GLT_Trials_fnc_clearSlingDeliverVisuals;
uiNamespace setVariable ["GLT_Trials_slingDeliverSig", _sig];

private _coneAt = {
    private _asl = _this;
    private _c = "RoadCone_L_F" createVehicleLocal [0, 0, 0];
    _c setPosASL _asl;
    _c enableSimulation false;
    _c
};

private _kind = _viz select 0;

if (_kind isEqualTo 0) then {
    private _rad = _viz select 1;
    private _cx = _center select 0;
    private _cy = _center select 1;
    private _cz = _center select 2;
    uiNamespace setVariable ["GLT_Trials_slingDeliverLightDimFar", 95];
    uiNamespace setVariable ["GLT_Trials_slingDeliverLightDimClose", 32];
    uiNamespace setVariable ["GLT_Trials_slingDeliverLightCenter", +_center];
    private _offs = [
        [_rad, 0, 0],
        [-_rad, 0, 0],
        [0, _rad, 0],
        [0, -_rad, 0]
    ];
    private _cones = [];
    private _lights = [];
    private _lift = 0.45;
    {
        private _wx = _cx + (_x select 0);
        private _wy = _cy + (_x select 1);
        private _wz = getTerrainHeightASL [_wx, _wy];
        private _p = [_wx, _wy, _wz + 0.02];
        _cones pushBack (_p call _coneAt);

        private _lp = [_wx, _wy, _wz + _lift];
        private _li = "#lightpoint" createVehicleLocal [0, 0, 0];
        _li setPosASL _lp;
        _li setLightColor [0.95, 0.14, 0.12];
        _li setLightDayLight true;
        _li setLightUseFlare true;
        _li setLightBrightness 25;
        _li setLightAmbient [0.12, 0.02, 0.02];
        _li setLightFlareSize 1.8;
        _li setLightFlareMaxDistance 180;
        _li setLightAttenuation [0.12, 60, 0, 4.5];
        _lights pushBack _li;
    } forEach _offs;
    uiNamespace setVariable ["GLT_Trials_slingDeliverConeObjs", _cones];
    uiNamespace setVariable ["GLT_Trials_slingDeliverLightObjs", _lights];
};

if (_kind isEqualTo 1) then {
    private _axisR = _viz select 1;
    private _axisF = _viz select 2;
    private _halfW = _viz select 3;
    private _halfL = _viz select 4;
    private _dimFar = _viz select 5;
    private _dimClose = _viz select 6;

    uiNamespace setVariable ["GLT_Trials_slingDeliverLightDimFar", _dimFar];
    uiNamespace setVariable ["GLT_Trials_slingDeliverLightDimClose", _dimClose];
    uiNamespace setVariable ["GLT_Trials_slingDeliverLightCenter", +_center];

    private _corners = [[1, 1], [-1, 1], [-1, -1], [1, -1]];
    private _cones = [];
    private _lights = [];
    private _lift = 0.45;

    {
        private _sr = _x select 0;
        private _sf = _x select 1;
        // SQF does not reliably treat vectorMultiply(number) as scalar scaling; scale vectors explicitly.
        private _rScale = _sr * _halfW;
        private _fScale = _sf * _halfL;
        private _axisRScaled = _axisR vectorMultiply [_rScale, _rScale, _rScale];
        private _axisFScaled = _axisF vectorMultiply [_fScale, _fScale, _fScale];
        private _off = _axisRScaled vectorAdd _axisFScaled;
        private _p = _center vectorAdd _off;
        private _wx = _p select 0;
        private _wy = _p select 1;
        private _wz = getTerrainHeightASL [_wx, _wy];
        private _asl = [_wx, _wy, _wz + 0.02];
        _cones pushBack (_asl call _coneAt);

        private _lp = [_wx, _wy, _wz + _lift];
        private _li = "#lightpoint" createVehicleLocal [0, 0, 0];
        _li setPosASL _lp;
        _li setLightColor [0.95, 0.14, 0.12];
        _li setLightDayLight true;
        _li setLightUseFlare true;
        _li setLightBrightness 25;
        _li setLightAmbient [0.12, 0.02, 0.02];
        _li setLightFlareSize 1.8;
        _li setLightFlareMaxDistance 180;
        _li setLightAttenuation [0.12, 60, 0, 4.5];
        _lights pushBack _li;
    } forEach _corners;

    uiNamespace setVariable ["GLT_Trials_slingDeliverConeObjs", _cones];
    uiNamespace setVariable ["GLT_Trials_slingDeliverLightObjs", _lights];
};

true
