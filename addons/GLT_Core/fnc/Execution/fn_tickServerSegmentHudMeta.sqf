/*
    GLT_Trials_fnc_tickServerSegmentHudMeta
    Server: HUD description, world position hint, and segment type for the current segment index.
    Params: [_run, _segments, _segIdx]
    Returns: [_segmentDesc, _segmentPos, _segmentType]
*/

params ["_run", "_segments", "_segIdx"];

private _segmentDesc = "";
private _segmentPos = [0, 0, 0];
private _segmentType = "";

if (_segIdx < count _segments) then {
    private _seg = _segments select _segIdx;
    _segmentType = _seg select 0;
    _segmentPos = _seg select 2;

    switch (_segmentType) do {
        case "CROSS_GATE": {
            _segmentDesc = format ["Fly through gate %1", _segIdx + 1];
        };
        case "HOVER_POINT": {
            _segmentDesc = format ["Hover above %1", _segIdx + 1];
        };
        case "LAND_POINT": {
            _segmentDesc = format ["Land at %1", _segIdx + 1];
        };
        case "SLING_PICKUP": {
            _segmentDesc = format ["Sling pickup %1", _segIdx + 1];
        };
        case "SLING_DELIVER_CIRCLE";
        case "SLING_DELIVER_RECT": {
            _segmentDesc = format ["Sling deliver %1", _segIdx + 1];
        };
        case "DESTROY_TARGET": {
            private _disp = _seg select 7;
            private _targetObj = _run getOrDefault ["destroyCurrentObj", objNull];
            private _targetPos = _seg select 2;
            if (!isNull _targetObj) then {
                _targetPos = getPosWorld _targetObj;
            };
            private _gridT = mapGridPosition _targetPos;
            _segmentPos = _targetPos;
            _segmentDesc = format ["Destroy %1 at %2", _disp, _gridT];
        };
        case "DESTROY_INFANTRY": {
            private _disp = _seg select 6;
            private _targetObj = _run getOrDefault ["destroyCurrentObj", objNull];
            private _targetPos = _seg select 2;
            if (!isNull _targetObj) then {
                _targetPos = getPosWorld _targetObj;
            };
            private _gridT = mapGridPosition _targetPos;
            _segmentPos = _targetPos;
            _segmentDesc = format ["Eliminate %1 at %2", _disp, _gridT];
        };
        default { _segmentDesc = "Segment"; };
    };
} else {
    if ((count _segments) > 0) then {
        private _segF = _segments select ((count _segments) - 1);
        _segmentType = _segF select 0;
        _segmentPos = _segF select 2;
        _segmentDesc = "Finalizing…";
    };
};

[_segmentDesc, _segmentPos, _segmentType]
