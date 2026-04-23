/*
    GLT_Trials_fnc_tickServerSlingDeliverHud
    Server: sling deliver light state, client viz bundle, and destroy smoke ASL for HUD row.
    Params: [_run, _segments, _segIdx, _heliPosWorld]
    Returns: [_slingLightState, _slingViz, _destroySmokePos]
*/

params ["_run", "_segments", "_segIdx", "_heliPosWorld"];

private _slingLightState = -1;
private _slingViz = -1;
private _destroySmokePos = [];

if (_segIdx < 0 || {_segIdx >= count _segments}) exitWith { [_slingLightState, _slingViz, _destroySmokePos] };

private _segS = _segments select _segIdx;
private _st = _segS select 0;
private _cargo = _run get "slingCargoObj";
if (isNil "_cargo") then { _cargo = objNull };

if (_st isEqualTo "SLING_DELIVER_CIRCLE") then {
    private _rad = _segS select 3;
    private _center = _segS select 2;
    _slingViz = [0, _rad];

    private _heliInZone = (_heliPosWorld distance2D _center) <= _rad;
    if (isNull _cargo) then {
        _slingLightState = 0;
    } else {
        private _onHook = [_run, _cargo] call GLT_Trials_fnc_tickServerSlingCargoOnHook;
        if (_heliInZone) then {
            if (_onHook) then { _slingLightState = 1 } else { _slingLightState = 2 };
        } else {
            _slingLightState = 0;
        };
    };
};

if (_st isEqualTo "SLING_DELIVER_RECT") then {
    _slingViz = [
        1,
        _segS select 3,
        _segS select 4,
        _segS select 5,
        _segS select 6,
        _segS select 7,
        _segS select 8
    ];
    private _center = _segS select 2;
    private _axisR = _segS select 3;
    private _axisF = _segS select 4;
    private _halfW = _segS select 5;
    private _halfL = _segS select 6;
    private _heliInZone = [_heliPosWorld, _center, _axisR, _axisF, _halfW, _halfL] call GLT_Trials_fnc_pointInSlingRect;
    if (isNull _cargo) then {
        _slingLightState = 0;
    } else {
        private _onHook = [_run, _cargo] call GLT_Trials_fnc_tickServerSlingCargoOnHook;
        if (_heliInZone) then {
            if (_onHook) then {
                _slingLightState = 1;
            } else {
                _slingLightState = 2;
            };
        } else {
            _slingLightState = 0;
        };
    };
};

if ((_st isEqualTo "DESTROY_TARGET") || { _st isEqualTo "DESTROY_INFANTRY" }) then {
    private _tgt = _run getOrDefault ["destroyCurrentObj", objNull];
    if (!isNull _tgt) then {
        _destroySmokePos = getPosASL _tgt;
    } else {
        _destroySmokePos = _segS select 2;
    };
};

[_slingLightState, _slingViz, _destroySmokePos]
