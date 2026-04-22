/*
    GLT_Trials_fnc_registerTrial
    Scans Eden-placed segment objects and builds:
      - GLT_Trials_trials (public array for clients)
      - GLT_Trials_trialsById (internal map): trialId -> trialConfig

    Trial ids are collected from segment waypoints and GLT_Trials_TrialMeta helpers. After sorting by segmentIndex,
    the first waypoint is the run entry (timer arms when segment 0 completes). A matching Trial Definition
    (GLT_Trials_TrialMeta, same trial id) is required: display name, allowed class list, and vehicle-type category
    toggles are read from it. Trials with segments but no Trial Definition are skipped (not registered / not active).
    Trial Definition props are deleted after scan.
*/

if (!isServer) exitWith {};

GLT_Trials_courseObjectsByTrial = createHashMap;

diag_log text format [
    "[PTF_TT][REGISTER] trial id scan (segments + definitions)=%1",
    count ([] call GLT_Trials_fnc_collectSegmentTrialIds)
];

// Eden attribute expressions set object variables via setVariable.
// On dedicated servers this can happen a tick or two after postInit; wait briefly.
private _deadline = time + 5;
diag_log text format ["[PTF_TT][REGISTER] waiting for segment trial ids until t=%1", _deadline];

while { time <= _deadline } do {
    if ((count ([] call GLT_Trials_fnc_collectSegmentTrialIds)) > 0) exitWith {};
    sleep 0.1;
};

private _trialIds = [] call GLT_Trials_fnc_collectSegmentTrialIds;
_trialIds sort true;

diag_log text format [
    "[PTF_TT][REGISTER] after wait: trialIdCount=%1",
    count _trialIds
];

GLT_Trials_trialsById = createHashMap;
GLT_Trials_trials = [];

{
    private _trialId = _x;
    if (_trialId isEqualTo "") then { continue };

    private _segments = [];
    private _courseObjs = [];

    private _callRegisterPair = {
        params ["_fnName"];
        if (isNil _fnName) exitWith {};
        private _resLocal = [_trialId] call (missionNamespace getVariable _fnName);
        _segments append (_resLocal select 0);
        { _courseObjs pushBackUnique _x } forEach (_resLocal select 1);
    };
    ["GLT_Trials_fnc_registerSegments_CrossGate"] call _callRegisterPair;
    ["GLT_Trials_fnc_registerSegments_HoverPoint"] call _callRegisterPair;
    ["GLT_Trials_fnc_registerSegments_LandPoint"] call _callRegisterPair;
    ["GLT_Trials_fnc_registerSegments_SlingPickup"] call _callRegisterPair;
    ["GLT_Trials_fnc_registerSegments_SlingDeliverCircle"] call _callRegisterPair;
    ["GLT_Trials_fnc_registerSegments_SlingDeliverRect"] call _callRegisterPair;

    private _res = [_trialId] call GLT_Trials_fnc_registerSegments_DestroyTarget;
    _segments append (_res select 0);
    { _courseObjs pushBackUnique _x } forEach (_res select 1);
    private _optionalDestroyRows = _res select 2;

    _res = [_trialId] call GLT_Trials_fnc_registerSegments_DestroyInfantry;
    _segments append (_res select 0);
    { _courseObjs pushBackUnique _x } forEach (_res select 1);
    private _optionalDestroyInfRows = _res select 2;

    _segments = [_segments, [], { _x#1 }, "ASCEND"] call BIS_fnc_sortBy;

    if ((count _segments) isEqualTo 0) then {
        diag_log format ["[PTF_TT] Trial '%1' has no waypoint segments for this trialId. Skipping.", _trialId];
        continue;
    };

    private _meta = [_trialId] call GLT_Trials_fnc_resolveTrialMetaObject;
    if (isNull _meta) then {
        diag_log text format [
            "[PTF_TT][REGISTER] Trial '%1' has no Trial Definition (GLT_Trials_TrialMeta). Skipping — not active.",
            _trialId
        ];
        continue;
    };

    private _trialName = _trialId;
    private _allowedHelisRaw = "";
    private _tn = _meta getVariable ["GLT_Trials_trialName", ""];
    if ((_tn isEqualType "") && {!(_tn isEqualTo "")}) then {
        _trialName = _tn;
    };
    _allowedHelisRaw = _meta getVariable ["GLT_Trials_allowedHelis", ""];
    if (!(_allowedHelisRaw isEqualType "")) then { _allowedHelisRaw = ""; };

    private _firstSeg = _segments select 0;
    private _anchorObj = [_trialId, _firstSeg, _courseObjs] call GLT_Trials_fnc_resolveSegmentCourseObject;

    private _allowedHelis = [_allowedHelisRaw] call GLT_Trials_fnc_parseAllowedHelis;

    private _fst = _firstSeg select 0;
    private _startPosWorld = +(_firstSeg select 2);
    private _startNormal = [0, 1, 0];
    private _startUp = [0, 0, 1];
    private _startRight = [1, 0, 0];
    private _startRadius = 30;
    private _startTouchMethod = 2;
    private _startTouchPadding = 0;
    private _startOBBHalfExtents = [1, 1, 1];

    switch (_fst) do {
        case "CROSS_GATE": { _startRadius = _firstSeg select 6; };
        case "HOVER_POINT": { _startRadius = _firstSeg select 3; };
        case "LAND_POINT": { _startRadius = _firstSeg select 3; };
        case "SLING_PICKUP": { _startRadius = 25; };
        case "SLING_DELIVER_CIRCLE": { _startRadius = _firstSeg select 3; };
        case "SLING_DELIVER_RECT": {
            private _hw = _firstSeg select 5;
            private _hl = _firstSeg select 6;
            _startRadius = (_hw max _hl) max 15;
        };
        case "DESTROY_TARGET";
        case "DESTROY_INFANTRY": { _startRadius = 80; };
    };

    if (!isNull _anchorObj) then {
        _startNormal = vectorDir _anchorObj;
        _startUp = vectorUp _anchorObj;
        _startRight = _startNormal vectorCrossProduct _startUp;
        private _startOBBData = [_anchorObj, _startRight, _startUp, _startNormal] call GLT_Trials_fnc_calcOBBData;
        _startPosWorld = _startOBBData select 0;
        _startOBBHalfExtents = _startOBBData select 1;
        _startTouchMethod = _anchorObj getVariable ["GLT_Trials_touchMethod", 0];
        _startTouchPadding = _anchorObj getVariable ["GLT_Trials_touchPadding", 0];
    };

    // Vehicle-type checkboxes on Trial Definition object: [heli, plane, ground, ship] 0/1; [] = no filter.
    private _vehicleCategoryMask = [];
    private _rh = _meta getVariable "GLT_Trials_catHelicopter";
    private _rp = _meta getVariable "GLT_Trials_catPlane";
    private _rg = _meta getVariable "GLT_Trials_catGround";
    private _rs = _meta getVariable "GLT_Trials_catShip";
    if (!(isNil "_rh") && {!(isNil "_rp")} && {!(isNil "_rg")} && {!(isNil "_rs")}) then {
        private _to01 = {
            params ["_v"];
            if (_v isEqualType true) exitWith { 1 };
            if (_v isEqualType false) exitWith { 0 };
            if (_v isEqualType 0) exitWith { 0 };
            if (_v isEqualType 1) exitWith { 1 };
            (_v max 0) min 1
        };
        _vehicleCategoryMask = [[_rh] call _to01, [_rp] call _to01, [_rg] call _to01, [_rs] call _to01];
        if (
            ((_vehicleCategoryMask select 0) + (_vehicleCategoryMask select 1)
            + (_vehicleCategoryMask select 2) + (_vehicleCategoryMask select 3)) < 1
        ) then {
            _vehicleCategoryMask = [];
        };
    };

    private _startSphereCenterWorld = _startPosWorld;
    private _srX = _startOBBHalfExtents select 0;
    private _srY = _startOBBHalfExtents select 1;
    private _srZ = _startOBBHalfExtents select 2;
    private _startSphereRadius = sqrt ((_srX * _srX) + (_srY * _srY) + (_srZ * _srZ));

    private _lastSeg = _segments select ((count _segments) - 1);
    private _endPosWorld = +(_lastSeg select 2);
    private _endRadius = 30;
    private _endNormal = [0, 1, 0];
    private _endUp = [0, 0, 1];
    private _endRight = [1, 0, 0];
    private _endTouchMethod = 2;
    private _endTouchPadding = 0;
    private _endOBBHalfExtents = [1, 1, 1];
    private _endSphereCenterWorld = _endPosWorld;
    private _endSphereRadius = sqrt (3);
    private _endConfig = [
        _endPosWorld,
        _endRadius,
        _endNormal,
        _endUp,
        _endRight,
        _endTouchMethod,
        _endTouchPadding,
        _endOBBHalfExtents,
        _endSphereCenterWorld,
        _endSphereRadius
    ];

    GLT_Trials_courseObjectsByTrial set [_trialId, _courseObjs];

    private _trialConfig = [
        _trialId,
        _trialName,
        _allowedHelis,
        _startPosWorld,
        _startRadius,
        _startNormal,
        _startUp,
        _startRight,
        _endConfig,
        _segments,
        _startTouchMethod,
        _startTouchPadding,
        _startOBBHalfExtents,
        _startSphereCenterWorld,
        _startSphereRadius,
        _optionalDestroyRows,
        _optionalDestroyInfRows,
        _vehicleCategoryMask
    ];

    diag_log text format [
        "[PTF_TT][REGISTER] trialId=%1 name=%2 allowedRaw='%3' allowedParsed=%4 segCount=%5",
        _trialId,
        _trialName,
        _allowedHelisRaw,
        _allowedHelis,
        count _segments
    ];

    GLT_Trials_trialsById set [_trialId, _trialConfig];

    private _firstWaypointPosWorld = (_segments select 0) select 2;

    private _mapRoute = [];
    {
        _mapRoute pushBack [_x select 0, +(_x select 2)];
    } forEach _segments;

    private _routeIdxSeg = 0;
    {
        private _segRow = _x;
        private _hit = [_trialId, _segRow, _courseObjs] call GLT_Trials_fnc_resolveSegmentCourseObject;
        if (!isNull _hit) then {
            _hit setVariable ["GLT_Trials_routeIndex", _routeIdxSeg, true];
        };
        _routeIdxSeg = _routeIdxSeg + 1;
    } forEach _segments;

    GLT_Trials_trials pushBack [
        _trialId,
        _trialName,
        _allowedHelis,
        _startPosWorld,
        _startRadius,
        _endPosWorld,
        _firstWaypointPosWorld,
        _mapRoute,
        _courseObjs,
        _vehicleCategoryMask
    ];
} forEach _trialIds;

publicVariable "GLT_Trials_trials";
GLT_Trials_trialsAvailable = (count GLT_Trials_trials) > 0;
publicVariable "GLT_Trials_trialsAvailable";

[] call GLT_Trials_fnc_syncCourseObjectVisibilityFull;

private _metaHelpers = (allMissionObjects "") select { typeOf _x == "GLT_Trials_TrialMeta" };
{ deleteVehicle _x } forEach _metaHelpers;
if ((count _metaHelpers) > 0) then {
    diag_log text format ["[PTF_TT][REGISTER] removed %1 Trial Definition helper(s) from mission world.", count _metaHelpers];
};

if (count GLT_Trials_trials isEqualTo 0) then {
    diag_log "[PTF_TT][REGISTER] WARNING: zero trials registered. Each trial id needs segment waypoints plus a Trial Definition (GLT_Trials_TrialMeta) with the same id (name, allowed classes, vehicle-type filters).";
};

true
