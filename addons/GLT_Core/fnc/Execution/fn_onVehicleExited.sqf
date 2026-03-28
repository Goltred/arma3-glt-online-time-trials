/*
    GLT_Trials_fnc_onVehicleExited
    Client-side: remove ACE "Time Trials" interaction from heli when pilot exits.
    Params: [_unit, _vehicle]
*/

params ["_unit", "_vehicle"];
if (!hasInterface) exitWith {};
if (isNull _vehicle) exitWith {};
if (_unit isNotEqualTo player) exitWith {};

private _path = _vehicle getVariable ["GLT_Trials_aceActionPath", []];
if (count _path > 0) then {
    if (isClass (configFile >> "CfgPatches" >> "ace_interact_menu")) then {
        [_vehicle, 0, _path] call ace_interact_menu_fnc_removeActionFromObject;
    };
    _vehicle setVariable ["GLT_Trials_aceActionPath", nil];
};

true
