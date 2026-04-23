/*
    GLT_Trials_fnc_registerSegments_SlingDeliverRect
    Params: [_candidates] — objects synchronized to the Trial Definition (filtered here by type).
    Returns: [segments, courseObjs]
*/

params [["_candidates", [], [[]]]];

private _segments = [];
private _objs = [];

{
    if (isNull _x) then { continue };
    if !(_x isKindOf "GLT_Trials_SlingDeliverRect") then { continue };

    // Rectangle helper arrow is an editor gizmo only; keep it hidden at runtime.
    _x setVariable ["GLT_Trials_runtimeAlwaysHidden", true, true];

    _objs pushBack _x;

    private _segIdx = _x getVariable ["GLT_Trials_segmentIndex", 0];
    private _halfW = [_x getVariable ["GLT_Trials_slingRectHalfWidth", 10], 10] call GLT_Trials_fnc_numberFromEden;
    private _halfL = [_x getVariable ["GLT_Trials_slingRectHalfLength", 15], 15] call GLT_Trials_fnc_numberFromEden;
    if (_halfW < 1) then { _halfW = 1 };
    if (_halfL < 1) then { _halfL = 1 };

    private _dims = [_x, "GLT_Trials_slingRectLightDimFar", "GLT_Trials_slingRectLightDimClose", 95, 32] call GLT_Trials_fnc_getHelperLightDimsFromObj;
    private _dimFar = _dims select 0;
    private _dimClose = _dims select 1;

    private _posWorld = getPosASL _x;
    private _up = vectorNormalized (vectorUp _x);
    private _f = vectorNormalized (vectorDir _x);
    private _r = vectorNormalized (_f vectorCrossProduct _up);

    // ["SLING_DELIVER_RECT", segIdx, posASL, axisR, axisF, halfW, halfL, dimFar, dimClose]
    _segments pushBack ["SLING_DELIVER_RECT", _segIdx, _posWorld, _r, _f, _halfW, _halfL, _dimFar, _dimClose];
} forEach _candidates;

[_segments, _objs]
