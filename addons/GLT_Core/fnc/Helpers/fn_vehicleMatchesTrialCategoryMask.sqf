/*
    GLT_Trials_fnc_vehicleMatchesTrialCategoryMask
    Params: [_vehicle, _mask]
      _mask: [] = no filter (allow); else [heli, plane, ground, ship] each 0 or 1 — allow if vehicle matches any ticked category.
    Returns: boolean
*/

params [["_vehicle", objNull, [objNull]], ["_mask", [], [[]]]];

if (isNull _vehicle) exitWith { false };
if (!(_mask isEqualType []) || {(count _mask) != 4}) exitWith { true };

private _sum = (_mask select 0) + (_mask select 1) + (_mask select 2) + (_mask select 3);
if (_sum < 1) exitWith { true };

private _isHeli = _vehicle isKindOf "Helicopter";
if (!_isHeli && {_vehicle isKindOf "Air"}) then {
    private _sim = toLower getText (configFile >> "CfgVehicles" >> typeOf _vehicle >> "simulation");
    _isHeli = ((_sim find "helicopter") >= 0) || {_sim isEqualTo "helicopterrtd"};
};

private _isPlane = (_vehicle isKindOf "Plane") || {_vehicle isKindOf "Air" && {!_isHeli}};
private _isShip = _vehicle isKindOf "Ship";
private _isGround = _vehicle isKindOf "LandVehicle";

(
    (((_mask select 0) > 0) && {_isHeli})
    || {((_mask select 1) > 0) && {_isPlane}}
    || {((_mask select 2) > 0) && {_isGround}}
    || {((_mask select 3) > 0) && {_isShip}}
)
