/*
    GLT_Trials_fnc_registerSegments_LandPoint
    Params: [_candidates] — objects synchronized to the Trial Definition (filtered here by type).
    Returns: [segments, courseObjs]
*/

params [["_candidates", [], [[]]]];

private _segments = [];
private _objs = [];

{
    if (isNull _x) then { continue };
    if !(_x isKindOf "GLT_Trials_LandPoint") then { continue };
    _objs pushBack _x;

    private _segIdx = _x getVariable ["GLT_Trials_segmentIndex", 0];
    private _radius = _x getVariable ["GLT_Trials_landRadius", 8];
    private _staySeconds = _x getVariable ["GLT_Trials_landStaySeconds", 3];
    private _posWorld = getPosWorld _x;

    // ["LAND_POINT", segIdx, posWorld, radius, staySeconds] — landed = touching ground in zone.
    _segments pushBack ["LAND_POINT", _segIdx, _posWorld, _radius, _staySeconds];
} forEach _candidates;

[_segments, _objs]
