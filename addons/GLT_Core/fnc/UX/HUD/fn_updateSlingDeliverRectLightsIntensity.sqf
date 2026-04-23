/*
    GLT_Trials_fnc_updateSlingDeliverRectLightsIntensity
    Client: distance fade + red / yellow / green from server row index 18.
*/

if (!hasInterface) exitWith {};

private _objs = uiNamespace getVariable ["GLT_Trials_slingDeliverLightObjs", []];
private _ctr = uiNamespace getVariable ["GLT_Trials_slingDeliverLightCenter", []];

if ((count _ctr) < 3) exitWith {};
private _alive = false;
{ if (!isNull _x) exitWith { _alive = true }; } forEach _objs;
if (!_alive) exitWith {};

private _hz = 15;
private _lastT = uiNamespace getVariable ["GLT_Trials_slingDeliverLightIntLastT", -1e9];
if ((time - _lastT) < (1 / _hz)) exitWith {};
uiNamespace setVariable ["GLT_Trials_slingDeliverLightIntLastT", time];

private _state = -1;
if !(isNil "GLT_Trials_activeRunsPublic") then {
    private _myRun = [] call GLT_Trials_fnc_resolveClientHudRun;
    private _segT = _myRun param [9, ""];
    if ((count _myRun) > 0 && { _segT isEqualTo "SLING_DELIVER_RECT" || { _segT isEqualTo "SLING_DELIVER_CIRCLE" } }) then {
        _state = _myRun param [18, -1];
    };
};

private _rgb = switch (_state) do {
    case 1: { [0.95, 0.85, 0.12] };
    case 2: { [0.2, 0.92, 0.32] };
    default { [0.95, 0.14, 0.12] };
};
private _dFar = uiNamespace getVariable ["GLT_Trials_slingDeliverLightDimFar", 95];
private _dClose = uiNamespace getVariable ["GLT_Trials_slingDeliverLightDimClose", 32];
[_objs, _ctr, _rgb, _dFar, _dClose] call GLT_Trials_fnc_applyDistanceLightIntensity;

true
