/*
    GLT_Trials_fnc_registerSegments_LandPoint
    Returns: [segments, courseObjs]
*/

params [["_trialId", "", [""]]];

private _segments = [];
private _objs = [];

private _landPoints = allMissionObjects "GLT_Trials_LandPoint";
{
    private _sid = _x getVariable ["GLT_Trials_trialId", ""];
    if !(_sid isEqualTo _trialId) then { continue };
    _objs pushBack _x;

    private _segIdx = _x getVariable ["GLT_Trials_segmentIndex", 0];
    private _radius = _x getVariable ["GLT_Trials_landRadius", 8];
    private _staySeconds = _x getVariable ["GLT_Trials_landStaySeconds", 3];
    private _posWorld = getPosWorld _x;

    // ["LAND_POINT", segIdx, posWorld, radius, staySeconds] — landed = touching ground in zone.
    _segments pushBack ["LAND_POINT", _segIdx, _posWorld, _radius, _staySeconds];
} forEach _landPoints;

[_segments, _objs]

