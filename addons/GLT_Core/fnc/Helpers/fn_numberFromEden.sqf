/*
    GLT_Trials_fnc_numberFromEden
    Convert Eden attribute value to a NUMBER safely.

    - If value is a string: parseNumber
    - If value is already a number: return it
    - If value is nil / other type: return default
*/

params [
    ["_raw", nil],
    ["_default", 0, [0]]
];

if (isNil "_raw") exitWith { _default };

if (_raw isEqualType 0) exitWith { _raw };
if (_raw isEqualType "") exitWith { parseNumber _raw };

_default

