/*
    GLT_Trials_fnc_parseAllowedHelis
    Parse Eden GLT_Trials_allowedHelis (vehicle class whitelist) into an array of classnames.

    Accepts:
      - "" or "[]" -> []
      - "A,B,C" -> ["A","B","C"] (whitespace trimmed)
      - ["A","B"] -> ["A","B"] (non-strings ignored)
      - any other type -> [] (stringified then parsed as CSV)
*/

params [["_raw", nil]];

if (isNil "_raw") exitWith { [] };

// Some Eden setups store a real array; keep only string entries.
if (_raw isEqualType []) exitWith {
    private _out = [];
    { if (_x isEqualType "") then { _out pushBack _x }; } forEach _raw;
    _out
};

private _s = if (_raw isEqualType "") then { _raw } else { str _raw };
_s = trim _s;

if ((_s isEqualTo "") || { _s isEqualTo "[]" }) exitWith { [] };

private _out = [];
{
    private _t = trim _x;
    if !(_t isEqualTo "") then {
        if !(_t isEqualTo "[]") then { _out pushBack _t };
    };
} forEach (_s splitString ",");

_out

