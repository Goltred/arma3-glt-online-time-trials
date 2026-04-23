/*
    GLT_Trials_fnc_tickServerHoverLandHudExtras
    Server: hover/land progress bar, hover helper light dims, and horizontal radius for HUD ring.
    Params: [_run, _segments, _segmentType, _segIdx]
    Returns: [_hoverBarStart, _hoverBarDur, _hLightDimFar, _hLightDimClose, _segmentHorizRadius]
*/

params ["_run", "_segments", "_segmentType", "_segIdx"];

private _hoverBarStart = -1;
private _hoverBarDur = 0;
private _hLightDimFar = -1;
private _hLightDimClose = -1;
private _segmentHorizRadius = -1;

if (
    _segmentType isEqualTo "HOVER_POINT"
    && {_segIdx >= 0}
    && {_segIdx < count _segments}
) then {
    private _segH = _segments select _segIdx;
    if ((_segH select 0) isEqualTo "HOVER_POINT") then {
        _hoverBarDur = _segH select 6;
        private _hst = _run get "hoverStartTime";
        if (_hst >= 0) then { _hoverBarStart = _hst };
    };
} else {
    if (
        _segmentType isEqualTo "LAND_POINT"
        && {_segIdx >= 0}
        && {_segIdx < count _segments}
    ) then {
        private _segL = _segments select _segIdx;
        if ((_segL select 0) isEqualTo "LAND_POINT") then {
            _hoverBarDur = _segL select 4;
            private _lst = _run get "landStayStartTime";
            if (_lst >= 0) then { _hoverBarStart = _lst };
        };
    };
};

if (
    _segmentType isEqualTo "HOVER_POINT"
    && {_segIdx >= 0}
    && {_segIdx < count _segments}
) then {
    private _segL2 = _segments select _segIdx;
    if ((_segL2 select 0) isEqualTo "HOVER_POINT") then {
        _hLightDimFar = _segL2 select 7;
        _hLightDimClose = _segL2 select 8;
    };
};

if (
    (_segmentType isEqualTo "HOVER_POINT" || {_segmentType isEqualTo "LAND_POINT"})
    && {_segIdx >= 0}
    && {_segIdx < count _segments}
) then {
    private _segZ = _segments select _segIdx;
    if ((_segZ select 0) isEqualTo _segmentType) then {
        _segmentHorizRadius = _segZ select 3;
    };
};

[_hoverBarStart, _hoverBarDur, _hLightDimFar, _hLightDimClose, _segmentHorizRadius]
