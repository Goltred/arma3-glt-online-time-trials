/*
    GLT_Trials_fnc_getHelperLightDimsFromObj
    Read helper-light dim distances from an object and return normalized [dimFar, dimClose].

    Params:
      0: obj
      1: primaryFarVar (STRING)
      2: primaryCloseVar (STRING)
      3: defaultFar (NUMBER, default 95)
      4: defaultClose (NUMBER, default 32)
      5: fallbackFarVar (STRING, optional, default "")
      6: fallbackCloseVar (STRING, optional, default "")
*/

params [
    ["_obj", objNull, [objNull]],
    ["_primaryFarVar", "", [""]],
    ["_primaryCloseVar", "", [""]],
    ["_defaultFar", 95, [0]],
    ["_defaultClose", 32, [0]],
    ["_fallbackFarVar", "", [""]],
    ["_fallbackCloseVar", "", [""]]
];

private _rawFar = _obj getVariable [_primaryFarVar, _defaultFar];
private _rawClose = _obj getVariable [_primaryCloseVar, _defaultClose];

if !(_fallbackFarVar isEqualTo "") then {
    _rawFar = _obj getVariable [_primaryFarVar, _obj getVariable [_fallbackFarVar, _defaultFar]];
};
if !(_fallbackCloseVar isEqualTo "") then {
    _rawClose = _obj getVariable [_primaryCloseVar, _obj getVariable [_fallbackCloseVar, _defaultClose]];
};

[_rawFar, _rawClose] call GLT_Trials_fnc_normalizeHelperLightDims

