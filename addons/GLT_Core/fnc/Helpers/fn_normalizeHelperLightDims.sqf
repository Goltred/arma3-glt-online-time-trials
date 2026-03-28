/*
    GLT_Trials_fnc_normalizeHelperLightDims
    Normalize helper-light dim distances and return [dimFar, dimClose].
*/

params [
    ["_dimFar", 95],
    ["_dimClose", 32]
];

if (_dimFar isEqualType "") then { _dimFar = parseNumber _dimFar };
if (_dimClose isEqualType "") then { _dimClose = parseNumber _dimClose };

if (_dimFar < 25) then { _dimFar = 25 };
if (_dimClose < 5) then { _dimClose = 5 };
if (_dimClose >= _dimFar) then { _dimClose = (_dimFar * 0.34) max 8 min (_dimFar - 5) };

[_dimFar, _dimClose]

