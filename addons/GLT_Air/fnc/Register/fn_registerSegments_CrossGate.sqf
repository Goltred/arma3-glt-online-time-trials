/*
    GLT_Trials_fnc_registerSegments_CrossGate
    Returns: [segments, courseObjs]
*/

params [["_trialId", "", [""]]];

private _segments = [];
private _objs = [];

private _crossGates = allMissionObjects "GLT_Trials_CrossGate";
{
    private _sid = _x getVariable ["GLT_Trials_trialId", ""];
    if !(_sid isEqualTo _trialId) then { continue };
    _objs pushBack _x;

    private _segIdx = _x getVariable ["GLT_Trials_segmentIndex", 0];
    private _gateRadius = _x getVariable ["GLT_Trials_gateRadius", 8];
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
} forEach _crossGates;

[_segments, _objs]

