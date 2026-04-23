/*
    GLT_Trials_fnc_tickServerBuildActiveRunPublicRow
    Server: assemble one GLT_Trials_activeRunsPublic row (field order is a client contract).
    Params: [_run, _now, _trial]
    Returns: array (same length/order as fn_tickServer pushBack before modularization)
*/

params ["_run", "_now", "_trial"];

private _tcSegments = 9; // same as _trialConfig in fn_registerTrial.sqf
private _segments = _trial select _tcSegments;
private _segIdx = _run get "segmentIndex";
private _segCount = _run get "segmentsCount";

([_run, _segments, _segIdx] call GLT_Trials_fnc_tickServerSegmentHudMeta) params ["_segmentDesc", "_segmentPos", "_segmentType"];

private _startTime = _run get "startTime";
private _nowElapsed = if (_startTime < 0) then { 0 } else { _now - _startTime };

([_run, _segments, _segmentType, _segIdx] call GLT_Trials_fnc_tickServerHoverLandHudExtras) params [
    "_hoverBarStart",
    "_hoverBarDur",
    "_hLightDimFar",
    "_hLightDimClose",
    "_segmentHorizRadius"
];

private _grid = mapGridPosition (_run get "lastPosWorld");

private _totalWaypoints = _segCount max 1;
private _wpIndex = 0;
if (_segIdx >= 0) then { _wpIndex = _segIdx };

private _nextPos = _segmentPos;
if ((_segIdx + 1) < count _segments) then {
    _nextPos = (_segments select (_segIdx + 1)) select 2;
} else {
    _nextPos = (_segments select _segIdx) select 2;
};

private _heliPosWorld = _run get "lastPosWorld";
([_run, _segments, _segIdx, _heliPosWorld] call GLT_Trials_fnc_tickServerSlingDeliverHud) params [
    "_slingLightState",
    "_slingViz",
    "_destroySmokePos"
];

private _slingCargoNetId = "";
if (!isNull (_run getOrDefault ["slingCargoObj", objNull])) then {
    _slingCargoNetId = netId (_run getOrDefault ["slingCargoObj", objNull]);
};

private _trialHeliNetId = "";
private _trialHeli = _run get "heli";
if (!isNull _trialHeli) then {
    _trialHeliNetId = netId _trialHeli;
};

[
    _run get "runId",
    _run get "pilotUID",
    _run get "heliCallsign",
    _run get "pilotName",
    _grid,
    _run get "trialName",
    _segmentDesc,
    _nowElapsed,
    _segmentPos,
    _segmentType,
    _wpIndex,
    _totalWaypoints,
    _nextPos,
    _run get "trialId",
    _hoverBarStart,
    _hoverBarDur,
    _hLightDimFar,
    _hLightDimClose,
    _slingLightState,
    _slingViz,
    _slingCargoNetId,
    _destroySmokePos,
    _trialHeliNetId,
    _segmentHorizRadius
]
