/*
    GLT_Trials_fnc_registerSegments_SlingPickup
    Params: [_candidates] — objects synchronized to the Trial Definition (filtered here by type).
    Returns: [segments, courseObjs]
*/

params [["_candidates", [], [[]]]];

private _segments = [];
private _objs = [];

{
    if (isNull _x) then { continue };
    if !(_x isKindOf "GLT_Trials_SlingPickup") then { continue };

    // Green arrow helper only (like sling deliver rect / destroy spawns); hidden in mission via syncCourseObjectVisibility.
    _x setVariable ["GLT_Trials_runtimeAlwaysHidden", true, true];
    _objs pushBack _x;

    private _segIdx = _x getVariable ["GLT_Trials_segmentIndex", 0];
    private _posWorld = getPosASL _x;

    private _cargoClass = _x getVariable ["GLT_Trials_slingPickupCargoClass", "Land_FoodSacks_01_cargo_white_idap_F"];
    if !(_cargoClass isEqualType "") then { _cargoClass = str _cargoClass };
    if (_cargoClass isEqualTo "") then { _cargoClass = "Land_FoodSacks_01_cargo_white_idap_F" };

    // ["SLING_PICKUP", segIdx, posASL, cargoClass]
    _segments pushBack ["SLING_PICKUP", _segIdx, _posWorld, _cargoClass];
} forEach _candidates;

[_segments, _objs]
