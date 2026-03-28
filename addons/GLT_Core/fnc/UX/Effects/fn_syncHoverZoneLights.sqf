/*
    GLT_Trials_fnc_syncHoverZoneLights
    Client: while trial HUD is active and current segment is HOVER_POINT, show corner/cross
    lamps around the segment center (server row index 8). Cleared otherwise.
*/

if (!hasInterface) exitWith {};

if (!GLT_Trials_clientHudShown) exitWith { [] call GLT_Trials_fnc_clearHoverZoneLights };
if (!isNull findDisplay 88100) exitWith { [] call GLT_Trials_fnc_clearHoverZoneLights };
if (isNil "GLT_Trials_activeRunsPublic") exitWith { [] call GLT_Trials_fnc_clearHoverZoneLights };

private _myUID = getPlayerUID player;
private _myRunId = parseNumber (str GLT_Trials_clientRunId);

private _myRunCandidates = GLT_Trials_activeRunsPublic select {
    parseNumber (str (_x select 0)) isEqualTo _myRunId
};
private _myRun = if (count _myRunCandidates > 0) then { _myRunCandidates select 0 } else { [] };
if ((count _myRun) isEqualTo 0) then {
    private _uidCandidates = GLT_Trials_activeRunsPublic select { (_x select 1) isEqualTo _myUID };
    _myRun = if (count _uidCandidates > 0) then { _uidCandidates select 0 } else { [] };
};

if ((count _myRun) isEqualTo 0) exitWith { [] call GLT_Trials_fnc_clearHoverZoneLights };

private _segType = _myRun param [9, ""];
private _segPos = _myRun param [8, [0, 0, 0]];

if ((_segType isEqualTo "HOVER_POINT") && {(count _segPos) >= 3}) then {
    private _dimFar = _myRun param [16, 95];
    private _dimClose = _myRun param [17, 32];
    if (_dimFar < 0) then { _dimFar = 95 };
    if (_dimClose < 0) then { _dimClose = 32 };
    private _inHover = (_myRun param [14, -1]) >= 0;
    private _rgb = if (_inHover) then { [0.2, 0.92, 0.32] } else { [0.95, 0.14, 0.12] };
    // Arm length: slightly inside typical VR disc.
    [_segPos, 8, "CROSS", _rgb, _dimFar, _dimClose] call GLT_Trials_fnc_hoverZoneLights;
} else {
    [] call GLT_Trials_fnc_clearHoverZoneLights;
};

true
