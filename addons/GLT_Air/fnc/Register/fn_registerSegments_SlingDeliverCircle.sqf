/*
    GLT_Trials_fnc_registerSegments_SlingDeliverCircle
    Params: [_candidates] — objects synchronized to the Trial Definition (filtered here by type).
    Returns: [segments, courseObjs]
*/

params [["_candidates", [], [[]]]];

private _segments = [];
private _objs = [];

{
    if (isNull _x) then { continue };
    if !(_x isKindOf "GLT_Trials_SlingDeliver") then { continue };
    _objs pushBack _x;

    private _segIdx = _x getVariable ["GLT_Trials_segmentIndex", 0];
    private _radius = [_x getVariable ["GLT_Trials_slingRadius", 8], 8] call GLT_Trials_fnc_numberFromEden;
    private _posWorld = getPosASL _x;

    // ["SLING_DELIVER_CIRCLE", segIdx, posASL, radius]
    _segments pushBack ["SLING_DELIVER_CIRCLE", _segIdx, _posWorld, _radius];
} forEach _candidates;

[_segments, _objs]
