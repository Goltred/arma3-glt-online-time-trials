/*
    GLT_Trials_fnc_registerTrial
    Scans Eden-placed Trial Definition objects (GLT_Trials_TrialMeta) and objects synchronized to each one, then builds:
      - GLT_Trials_trials (public array for clients)
      - GLT_Trials_trialsById (internal map): trialId -> trialConfig

    Workflow: set Trial Id on the Trial Definition, sync all segment waypoints to that object (Eden connector), set
    Segment Index on each segment for order. After sorting by segmentIndex, the first segment is run entry (timer arms
    when segment 0 completes). Trial Definition props are deleted after scan.
*/

if (!isServer) exitWith {};

GLT_Trials_courseObjectsByTrial = createHashMap;
GLT_Trials_categoryMaskByTrialId = createHashMap;

// Eden attribute expressions set object variables via setVariable.
// On dedicated servers this can happen a tick or two after postInit; wait briefly.
private _deadline = time + 5;

while { time <= _deadline } do {
    if ((count ([] call GLT_Trials_fnc_collectSegmentTrialIds)) > 0) exitWith {};
    sleep 0.1;
};

private _metaByTid = createHashMap;
private _seenTrialIds = [];
{
    private _metaObj = _x;
    private _tid = _metaObj getVariable ["GLT_Trials_trialId", ""];
    if (_tid isEqualTo "") then { continue };
    if (_tid in _seenTrialIds) then {
        diag_log text format [
            "[GLT_Trials][REGISTER] Duplicate Trial Definition for trial id '%1'; keeping first object, ignoring %2.",
            _tid,
            typeOf _metaObj
        ];
    } else {
        _seenTrialIds pushBack _tid;
        _metaByTid set [_tid, _metaObj];
    };
} forEach ((allMissionObjects "") select { typeOf _x == "GLT_Trials_TrialMeta" });

private _trialIds = keys _metaByTid;
_trialIds sort true;

GLT_Trials_trialsById = createHashMap;
GLT_Trials_trials = [];

{
    private _trialId = _x;
    if (_trialId isEqualTo "") then { continue };

    private _meta = _metaByTid get _trialId;
    private _candidates = [_meta, _trialId] call GLT_Trials_fnc_collectSegmentObjectsForTrialMeta;
    if (isNil "_candidates") then { _candidates = []; };

    private _segments = [];
    private _courseObjs = [];

    private _callRegisterPair = {
        params ["_fnName", "_cand", "_segs", "_objs"];
        if (isNil _fnName) exitWith {};
        private _resLocal = [_cand] call (missionNamespace getVariable _fnName);
        _segs append (_resLocal select 0);
        { _objs pushBackUnique _x } forEach (_resLocal select 1);
    };
    ["GLT_Trials_fnc_registerSegments_CrossGate", _candidates, _segments, _courseObjs] call _callRegisterPair;
    ["GLT_Trials_fnc_registerSegments_HoverPoint", _candidates, _segments, _courseObjs] call _callRegisterPair;
    ["GLT_Trials_fnc_registerSegments_LandPoint", _candidates, _segments, _courseObjs] call _callRegisterPair;
    ["GLT_Trials_fnc_registerSegments_SlingPickup", _candidates, _segments, _courseObjs] call _callRegisterPair;
    ["GLT_Trials_fnc_registerSegments_SlingDeliverCircle", _candidates, _segments, _courseObjs] call _callRegisterPair;
    ["GLT_Trials_fnc_registerSegments_SlingDeliverRect", _candidates, _segments, _courseObjs] call _callRegisterPair;

    private _res = [_candidates] call GLT_Trials_fnc_registerSegments_DestroyTarget;
    _segments append (_res select 0);
    { _courseObjs pushBackUnique _x } forEach (_res select 1);
    private _optionalDestroyRows = _res select 2;

    _res = [_candidates] call GLT_Trials_fnc_registerSegments_DestroyInfantry;
    _segments append (_res select 0);
    { _courseObjs pushBackUnique _x } forEach (_res select 1);
    private _optionalDestroyInfRows = _res select 2;

    _segments = [_segments, [], { _x#1 }, "ASCEND"] call BIS_fnc_sortBy;

    if ((count _segments) isEqualTo 0) then {
        diag_log text format [
            "[GLT_Trials][REGISTER] Trial '%1' skipped: no segment objects in synchronizedObjects(Trial Definition). Sync segments to the Trial Definition Logic in Eden.",
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
    private _anchorObj = [_firstSeg, _courseObjs] call GLT_Trials_fnc_resolveSegmentCourseObject;

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

    // Vehicle-type checkboxes on Trial Definition: [heli, plane, ground, ship] each 0/1; [] = no filter (allow all).
    // CheckboxNumber may omit keys until first edit in Eden. If no category key exists, default heli=1 (Eden default).
    // Any key present => missing keys count as 0 (unticked). Do NOT use _v isEqualType 0/1 for scalars — in SQF every
    // scalar has the same type, so 1 isEqualType 0 is true and would coerce ticked checkboxes to 0.
    private _vehicleCategoryMask = [];
    private _hasAnyCatVar =
        !isNil { _meta getVariable "GLT_Trials_catHelicopter" }
        || { !isNil { _meta getVariable "GLT_Trials_catPlane" } }
        || { !isNil { _meta getVariable "GLT_Trials_catGround" } }
        || { !isNil { _meta getVariable "GLT_Trials_catShip" } };
    private _to01 = {
        params ["_v"];
        if (isNil "_v") exitWith { 0 };
        if (_v isEqualTo true) exitWith { 1 };
        if (_v isEqualTo false) exitWith { 0 };
        if (_v isEqualTo 0) exitWith { 0 };
        if (_v isEqualTo 1) exitWith { 1 };
        if (_v isEqualType 0) exitWith { (_v max 0) min 1 };
        0
    };
    private _defH = if (_hasAnyCatVar) then { 0 } else { 1 };
    private _h = [_meta getVariable ["GLT_Trials_catHelicopter", _defH]] call _to01;
    private _p = [_meta getVariable ["GLT_Trials_catPlane", 0]] call _to01;
    private _g = [_meta getVariable ["GLT_Trials_catGround", 0]] call _to01;
    private _s = [_meta getVariable ["GLT_Trials_catShip", 0]] call _to01;
    _vehicleCategoryMask = [_h, _p, _g, _s];
    if (
        ((_vehicleCategoryMask select 0) + (_vehicleCategoryMask select 1)
        + (_vehicleCategoryMask select 2) + (_vehicleCategoryMask select 3)) < 1
    ) then {
        _vehicleCategoryMask = [];
    };

    GLT_Trials_categoryMaskByTrialId set [_trialId, +_vehicleCategoryMask];

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

    // Internal server-only row: indices referenced by name in fn_startRun.sqf / fn_tickServer.sqf / fn_updateRunState.sqf (see AGENTS.md).
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

    GLT_Trials_trialsById set [_trialId, _trialConfig];

    private _firstWaypointPosWorld = (_segments select 0) select 2;

    private _mapRoute = [];
    {
        _mapRoute pushBack [_x select 0, +(_x select 2)];
    } forEach _segments;

    private _routeIdxSeg = 0;
    {
        private _segRow = _x;
        private _hit = [_segRow, _courseObjs] call GLT_Trials_fnc_resolveSegmentCourseObject;
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
publicVariable "GLT_Trials_categoryMaskByTrialId";
GLT_Trials_trialsAvailable = (count GLT_Trials_trials) > 0;
publicVariable "GLT_Trials_trialsAvailable";

[] call GLT_Trials_fnc_syncCourseObjectVisibilityFull;

private _metaHelpers = (allMissionObjects "") select { typeOf _x == "GLT_Trials_TrialMeta" };
{ deleteVehicle _x } forEach _metaHelpers;

if (count GLT_Trials_trials isEqualTo 0) then {
    diag_log "[GLT_Trials][REGISTER] WARNING: zero trials registered. Place GLT_Trials_TrialMeta with Trial Id, sync segment objects to it, set Segment Index on each segment, and configure name / allowed classes / categories on the Trial Definition.";
};

true
