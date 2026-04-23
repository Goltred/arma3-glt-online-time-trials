/*
    GLT_Trials_fnc_registerSegments_HoverPoint
    Params: [_candidates] — objects synchronized to the Trial Definition (filtered here by type).
    Returns: [segments, courseObjs]
*/

params [["_candidates", [], [[]]]];

private _segments = [];
private _objs = [];

{
    if (isNull _x) then { continue };
    if !(_x isKindOf "GLT_Trials_HoverPoint") then { continue };
    _objs pushBack _x;

    private _segIdx = _x getVariable ["GLT_Trials_segmentIndex", 0];
    // Horizontal size from placed VR circle (editor scale applies). World AABB half-extent on X/Y.
    private _bb = boundingBox _x;
    private _bbMin = _bb select 0;
    private _bbMax = _bb select 1;
    private _dx = abs ((_bbMax select 0) - (_bbMin select 0));
    private _dy = abs ((_bbMax select 1) - (_bbMin select 1));
    private _radius = (_dx max _dy) / 2;
    if (_radius < 0.25) then { _radius = 2 };

    private _rExtra = [_x getVariable ["GLT_Trials_hoverRadiusExtra", 2], 2] call GLT_Trials_fnc_numberFromEden;
    _radius = _radius + _rExtra;
    if (_radius < 0.5) then { _radius = 0.5 };

    private _altMin = _x getVariable ["GLT_Trials_hoverAltitudeMin", 0];
    private _altMax = _x getVariable ["GLT_Trials_hoverAltitudeMax", 5];

    private _hoverSeconds = [_x getVariable ["GLT_Trials_hoverSeconds", 4], 4] call GLT_Trials_fnc_numberFromEden;
    private _posWorld = getPosWorld _x;

    // Helper light fade: full strength beyond _dimFar (m), minimum within _dimClose (m).
    private _dims = [_x, "GLT_Trials_hoverLightDimFar", "GLT_Trials_hoverLightDimClose", 95, 32] call GLT_Trials_fnc_getHelperLightDimsFromObj;
    private _dimFar = _dims select 0;
    private _dimClose = _dims select 1;

    _segments pushBack ["HOVER_POINT", _segIdx, _posWorld, _radius, _altMin, _altMax, _hoverSeconds, _dimFar, _dimClose];
} forEach _candidates;

[_segments, _objs]
