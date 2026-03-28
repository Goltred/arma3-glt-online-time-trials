/*
    GLT_Trials_fnc_registerSegments_SlingDeliverCircle
    Returns: [segments, courseObjs]
*/

params [["_trialId", "", [""]]];

private _segments = [];
private _objs = [];

private _slingCircle = allMissionObjects "GLT_Trials_SlingDeliver";
{
    private _sid = _x getVariable ["GLT_Trials_trialId", ""];
    if !(_sid isEqualTo _trialId) then { continue };
    _objs pushBack _x;

    private _segIdx = _x getVariable ["GLT_Trials_segmentIndex", 0];
    private _radius = [_x getVariable ["GLT_Trials_slingRadius", 8], 8] call GLT_Trials_fnc_numberFromEden;
    private _posWorld = getPosASL _x;

    // ["SLING_DELIVER_CIRCLE", segIdx, posASL, radius]
    _segments pushBack ["SLING_DELIVER_CIRCLE", _segIdx, _posWorld, _radius];
} forEach _slingCircle;

[_segments, _objs]

