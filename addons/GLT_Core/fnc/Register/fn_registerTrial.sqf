/*
    GLT_Trials_fnc_registerTrial
    Scans Eden-placed logic objects and builds:
      - GLT_Trials_trials (public array for clients): [trialId, trialName, allowedHelis]
      - GLT_Trials_trialsById (internal map): trialId -> trialConfig
*/

if (!isServer) exitWith {};

GLT_Trials_courseObjectsByTrial = createHashMap;

// Prefer typed lookup; fall back to full scan (some setups resolve subclasses oddly).
private _starts = allMissionObjects "GLT_Trials_TrialStart";
if (count _starts isEqualTo 0) then {
    _starts = (allMissionObjects "") select { typeOf _x == "GLT_Trials_TrialStart" };
};

private _ends = allMissionObjects "GLT_Trials_TrialEnd";
if (count _ends isEqualTo 0) then {
    _ends = (allMissionObjects "") select { typeOf _x == "GLT_Trials_TrialEnd" };
};

diag_log text format [
    "[PTF_TT][REGISTER] scan: TrialStart=%1 TrialEnd=%2",
    count _starts,
    count _ends
];

// Eden attribute expressions set object variables via setVariable.
// On dedicated servers this can happen a tick or two after postInit; wait briefly
// and then print what we actually see on the server.
private _deadline = time + 5;
diag_log text format ["[PTF_TT][REGISTER] waiting for Eden vars until t=%1", _deadline];

while { time <= _deadline } do {
    private _hasStartId = ({ (_x getVariable ["GLT_Trials_trialId", "__NO_VAR__"]) != "" } count _starts) > 0;
    private _hasEndId = ({ (_x getVariable ["GLT_Trials_trialId", "__NO_VAR__"]) != "" } count _ends) > 0;
    if (_hasStartId || _hasEndId) exitWith {};
    sleep 0.1;
};

private _startIdsCount = ({ (_x getVariable ["GLT_Trials_trialId", ""]) != "" } count _starts);
private _endIdsCount = ({ (_x getVariable ["GLT_Trials_trialId", ""]) != "" } count _ends);
diag_log text format [
    "[PTF_TT][REGISTER] after wait: StartWithId=%1 EndWithId=%2",
    _startIdsCount,
    _endIdsCount
];

// Trial start -> internal trial config, trialId -> trial config.
GLT_Trials_trialsById = createHashMap;
GLT_Trials_trials = [];

// Index end objects by trialId for quick lookup.
private _endById = createHashMap;
{
    private _tid = _x getVariable ["GLT_Trials_trialId", ""];
    if (_tid isEqualTo "") then { continue };
    _endById set [_tid, _x];
} forEach _ends;

// Build trials
{
    private _startObj = _x;
    private _trialId = _startObj getVariable ["GLT_Trials_trialId", ""];
    if (_trialId isEqualTo "") then { continue };

    private _trialName = _startObj getVariable ["GLT_Trials_trialName", _trialId];
    private _allowedHelisRaw = _startObj getVariable ["GLT_Trials_allowedHelis", ""];
    private _allowedHelis = [_allowedHelisRaw] call GLT_Trials_fnc_parseAllowedHelis;
    private _startRadius = _startObj getVariable ["GLT_Trials_startRadius", 30];
    private _startTouchMethod = _startObj getVariable ["GLT_Trials_touchMethod", 0]; // 0=OBB_HULL, 1=SPHERE_HULL, 2=CENTER_2D
    private _startTouchPadding = _startObj getVariable ["GLT_Trials_touchPadding", 0];

    // Axes from Eden orientation.
    private _startNormal = vectorDir _startObj;
    private _startUp = vectorUp _startObj;
    private _startRight = _startNormal vectorCrossProduct _startUp;

    // OBB center + half extents (collision center is the OBB center).
    private _startOBBData = [_startObj, _startRight, _startUp, _startNormal] call GLT_Trials_fnc_calcOBBData;
    private _startPosWorld = _startOBBData select 0;
    private _startOBBHalfExtents = _startOBBData select 1;

    // Sphere approximation (derived from OBB half extents to avoid boundingSphere* calls).
    private _startSphereCenterWorld = _startPosWorld;
    private _srX = _startOBBHalfExtents select 0;
    private _srY = _startOBBHalfExtents select 1;
    private _srZ = _startOBBHalfExtents select 2;
    private _startSphereRadius = sqrt ((_srX * _srX) + (_srY * _srY) + (_srZ * _srZ));

    private _endObj = _endById getOrDefault [_trialId, objNull];
    if (isNull _endObj) then {
        diag_log format ["[PTF_TT] Trial '%1' missing TrialEnd object. Skipping.", _trialId];
        continue;
    };

    private _endRadius = _endObj getVariable ["GLT_Trials_endRadius", 30];
    private _endTouchMethod = _endObj getVariable ["GLT_Trials_touchMethod", 0]; // 0=OBB_HULL, 1=SPHERE_HULL, 2=CENTER_2D
    private _endTouchPadding = _endObj getVariable ["GLT_Trials_touchPadding", 0];

    // Axes from Eden orientation.
    private _endNormal = vectorDir _endObj;
    private _endUp = vectorUp _endObj;
    private _endRight = _endNormal vectorCrossProduct _endUp;

    // OBB center + half extents.
    private _endOBBData = [_endObj, _endRight, _endUp, _endNormal] call GLT_Trials_fnc_calcOBBData;
    private _endPosWorld = _endOBBData select 0;
    private _endOBBHalfExtents = _endOBBData select 1;

    // Sphere approximation (derived from OBB half extents to avoid boundingSphere* calls).
    private _endSphereCenterWorld = _endPosWorld;
    private _erX = _endOBBHalfExtents select 0;
    private _erY = _endOBBHalfExtents select 1;
    private _erZ = _endOBBHalfExtents select 2;
    private _endSphereRadius = sqrt ((_erX * _erX) + (_erY * _erY) + (_erZ * _erZ));

    // endConfig:
    //   0: endPosWorld (OBB center)
    //   1: endRadius (legacy / CENTER_2D)
    //   2: endNormal
    //   3: endUp
    //   4: endRight
    //   5: endTouchMethod
    //   6: endTouchPadding
    //   7: endOBBHalfExtents
    //   8: endSphereCenterWorld
    //   9: endSphereRadius
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

    // Segments per trial: we scan all known segment types and filter by trialId.
    private _segments = [];
    private _courseObjs = [_startObj, _endObj];

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

    // Sort by segment index (ascending)
    _segments = [_segments, [], { _x#1 }, "ASCEND"] call BIS_fnc_sortBy;

    GLT_Trials_courseObjectsByTrial set [_trialId, _courseObjs];

    // Trial config structure:
    //   0: trialId
    //   1: trialName
    //   2: allowedHelis
    //   3: startPosWorld (OBB center)
    //   4: startRadius (legacy / CENTER_2D)
    //   5: startNormal
    //   6: startUp
    //   7: startRight
    //   8: endConfig (see above)
    //   9: segments
    //  10: startTouchMethod
    //  11: startTouchPadding
    //  12: startOBBHalfExtents
    //  13: startSphereCenterWorld
    //  14: startSphereRadius
    //  15: optionalDestroyRows [[segIdx,posASL,vehClass,spawnDriver,spawnGunners,side,displayName,markerObj,skill], ...]
    //  16: optionalDestroyInfRows [[segIdx,posASL,infClass,count,skill,displayName,markerObj], ...]
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
        _optionalDestroyInfRows
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

    // Public summary for clients.
    // Indices are relied upon by client code:
    //   0: trialId
    //   1: trialName
    //   2: allowedHelis
    //   3: startPosWorld
    //   4: startRadius
    //   5: endPosWorld (used for pre-start orientation in start/end-only trials)
    //   6: nextWaypointPosWorld (first segment position if any, otherwise endPosWorld)
    //   7: mapRoute — [[kind, posASL], ...] kind = "START" | segment type | "END"
    //   8: courseObjs — [start, end, ...segment objects] for client 3D visibility (hideObject local)
    private _firstWaypointPosWorld = if (count _segments > 0) then { (_segments select 0) select 2 } else { _endPosWorld };
    private _mapRoute = [];
    _mapRoute pushBack ["START", +_startPosWorld];
    {
        _mapRoute pushBack [_x select 0, +(_x select 2)];
    } forEach _segments;
    _mapRoute pushBack ["END", +_endPosWorld];

    // Client GLT_Trials_fnc_syncCourseObjects3DWindow: route index aligns with mapRoute (0 = start, last = end).
    _startObj setVariable ["GLT_Trials_routeIndex", 0, true];
    _endObj setVariable ["GLT_Trials_routeIndex", (count _mapRoute) - 1, true];
    private _routeIdxSeg = 1;
    {
        private _segRow = _x;
        private _stype = _segRow select 0;
        private _sidx = _segRow select 1;
        private _hit = objNull;
        {
            if (isNull _x) then { continue };
            if ((_x getVariable ["GLT_Trials_trialId", ""]) isNotEqualTo _trialId) then { continue };
            if ((_x getVariable ["GLT_Trials_segmentIndex", -999]) isNotEqualTo _sidx) then { continue };
            private _oType = switch (true) do {
                case (_x isKindOf "GLT_Trials_CrossGate"): { "CROSS_GATE" };
                case (_x isKindOf "GLT_Trials_HoverPoint"): { "HOVER_POINT" };
                case (_x isKindOf "GLT_Trials_LandPoint"): { "LAND_POINT" };
                case (_x isKindOf "GLT_Trials_SlingPickup"): { "SLING_PICKUP" };
                case (_x isKindOf "GLT_Trials_SlingDeliver"): { "SLING_DELIVER_CIRCLE" };
                case (_x isKindOf "GLT_Trials_SlingDeliverRect"): { "SLING_DELIVER_RECT" };
                case (_x isKindOf "GLT_Trials_DestroyTarget"): { "DESTROY_TARGET" };
                case (_x isKindOf "GLT_Trials_DestroyInfantry"): { "DESTROY_INFANTRY" };
                default { "" };
            };
            if (_oType isEqualTo _stype) then {
                _hit = _x;
            };
        } forEach _courseObjs;
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
        _courseObjs
    ];
} forEach _starts;

publicVariable "GLT_Trials_trials";

// All course markers hidden until a run is accepted for that trial.
[] call GLT_Trials_fnc_syncCourseObjectVisibility;

if (count GLT_Trials_trials isEqualTo 0) then {
    diag_log "[PTF_TT][REGISTER] WARNING: zero trials registered. Check Trial Start/End objects, matching GLT_Trials_trialId, and that classes are GLT_Trials_TrialStart / GLT_Trials_TrialEnd.";
};

true

