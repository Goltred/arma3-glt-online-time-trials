/*
    GLT_Trials_fnc_calcOBBData
    Compute [centerWorld, [halfR, halfU, halfN]] for an oriented bounding box (OBB),
    using boundingBoxReal corners projected onto provided axes.
*/

params ["_obj", "_axisRight", "_axisUp", "_axisNormal"];

private _bb = boundingBoxReal _obj;
private _bbMin = _bb select 0;
private _bbMax = _bb select 1;

private _centerLocal = [
    ((_bbMin select 0) + (_bbMax select 0)) / 2,
    ((_bbMin select 1) + (_bbMax select 1)) / 2,
    ((_bbMin select 2) + (_bbMax select 2)) / 2
];
private _centerWorld = _obj modelToWorld _centerLocal;

private _axisRightN = vectorNormalized _axisRight;
private _axisUpN = vectorNormalized _axisUp;
private _axisNormalN = vectorNormalized _axisNormal;

private _minR = 1e9;
private _maxR = -1e9;
private _minU = 1e9;
private _maxU = -1e9;
private _minN = 1e9;
private _maxN = -1e9;

private _xMin = _bbMin select 0; private _xMax = _bbMax select 0;
private _yMin = _bbMin select 1; private _yMax = _bbMax select 1;
private _zMin = _bbMin select 2; private _zMax = _bbMax select 2;

private _cornersLocal = [
    [_xMin,_yMin,_zMin],
    [_xMin,_yMin,_zMax],
    [_xMin,_yMax,_zMin],
    [_xMin,_yMax,_zMax],
    [_xMax,_yMin,_zMin],
    [_xMax,_yMin,_zMax],
    [_xMax,_yMax,_zMin],
    [_xMax,_yMax,_zMax]
];

{
    private _cornerWorld = _obj modelToWorld _x;
    private _rel = _cornerWorld vectorDiff _centerWorld;
    private _r = _rel vectorDotProduct _axisRightN;
    private _u = _rel vectorDotProduct _axisUpN;
    private _n = _rel vectorDotProduct _axisNormalN;

    if (_r < _minR) then { _minR = _r };
    if (_r > _maxR) then { _maxR = _r };
    if (_u < _minU) then { _minU = _u };
    if (_u > _maxU) then { _maxU = _u };
    if (_n < _minN) then { _minN = _n };
    if (_n > _maxN) then { _maxN = _n };
} forEach _cornersLocal;

private _halfR = (_maxR - _minR) / 2;
private _halfU = (_maxU - _minU) / 2;
private _halfN = (_maxN - _minN) / 2;

[_centerWorld, [_halfR, _halfU, _halfN]]

