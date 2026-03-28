/*
    GLT_Trials_fnc_pointInSlingRect
    Params: [_posWorld, _center, _axisR, _axisF, _halfW, _halfL]
*/

params ["_posWorld", "_center", "_axisR", "_axisF", "_halfW", "_halfL"];

private _rel = _posWorld vectorDiff _center;
private _r = _rel vectorDotProduct _axisR;
private _f = _rel vectorDotProduct _axisF;

(abs _r <= _halfW) && (abs _f <= _halfL)
