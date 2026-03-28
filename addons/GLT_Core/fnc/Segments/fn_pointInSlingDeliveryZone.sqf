/*
    GLT_Trials_fnc_pointInSlingDeliveryZone
    Params: [_posWorld, _seg] — _seg is full segment row from trial config.
*/

params ["_posWorld", "_seg"];

private _t = _seg select 0;
if (_t isEqualTo "SLING_DELIVER_CIRCLE") exitWith {
    private _c = _seg select 2;
    private _rad = _seg select 3;
    (_posWorld distance2D _c) <= _rad
};
if (_t isEqualTo "SLING_DELIVER_RECT") exitWith {
    [
        _posWorld,
        _seg select 2,
        _seg select 3,
        _seg select 4,
        _seg select 5,
        _seg select 6
    ] call GLT_Trials_fnc_pointInSlingRect
};

false
