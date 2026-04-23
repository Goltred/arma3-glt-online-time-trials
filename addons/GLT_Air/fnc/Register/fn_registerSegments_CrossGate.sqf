/*
    GLT_Trials_fnc_registerSegments_CrossGate
    Params: [_candidates] — objects synchronized to the Trial Definition (filtered here by type).
    Returns: [segments, courseObjs]
*/

params [["_candidates", [], [[]]]];

private _segments = [];
private _objs = [];

{
    if (isNull _x) then { continue };
    if !(_x isKindOf "GLT_Trials_CrossGate") then { continue };
    _objs pushBack _x;

    private _segIdx = _x getVariable ["GLT_Trials_segmentIndex", 0];
    private _gateRadius = _x getVariable ["GLT_Trials_gateRadius", 20];
    private _gateCrossTolerance = _x getVariable ["GLT_Trials_gateCrossTolerance", 3];

    private _gatePosWorld = getPosWorld _x;
    private _gateNormal = vectorDir _x; // forward direction
    private _gateUp = vectorUp _x;
    private _gateRight = _gateNormal vectorCrossProduct _gateUp;

    _segments pushBack [
        "CROSS_GATE",
        _segIdx,
        _gatePosWorld,
        _gateNormal,
        _gateUp,
        _gateRight,
        _gateRadius,
        _gateCrossTolerance
    ];
} forEach _candidates;

[_segments, _objs]
