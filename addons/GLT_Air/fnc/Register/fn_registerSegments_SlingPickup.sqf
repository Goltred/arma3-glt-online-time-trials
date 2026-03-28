/*
    GLT_Trials_fnc_registerSegments_SlingPickup
    Returns: [segments, courseObjs]
*/

params [["_trialId", "", [""]]];

private _segments = [];
private _objs = [];

private _slingPickups = allMissionObjects "GLT_Trials_SlingPickup";
{
    private _sid = _x getVariable ["GLT_Trials_trialId", ""];
    if !(_sid isEqualTo _trialId) then { continue };

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
} forEach _slingPickups;

[_segments, _objs]

