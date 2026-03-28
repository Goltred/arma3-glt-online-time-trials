/*
    GLT_Trials_fnc_onKeySelectTrial
    Invoked from a keybind to open the trial selection dialog for the current helicopter.
*/

if (!hasInterface) exitWith {};

private _veh = vehicle player;
if (_veh isEqualTo player) exitWith {
    hintSilent "Time Trials: you must be in a helicopter as pilot.";
};

if (!(_veh isKindOf "Helicopter")) exitWith {
    hintSilent "Time Trials: only helicopters are supported.";
};

if (driver _veh isNotEqualTo player) exitWith {
    hintSilent "Time Trials: you must be the pilot.";
};

if (isNil "GLT_Trials_trials") exitWith {
    hintSilent "Time Trials: trials not synchronised yet.";
};

private _heliType = typeOf _veh;
private _eligible = [];
{
    private _trialId = _x select 0;
    private _trialName = _x select 1;
    private _allowedHelis = _x select 2;
    // Empty list = no restriction (Eden default was often "[]" / unset).
    if ((count _allowedHelis isEqualTo 0) || (_allowedHelis find _heliType >= 0)) then {
        _eligible pushBack [_trialId, _trialName];
    };
} forEach GLT_Trials_trials;

if (count _eligible isEqualTo 0) exitWith {
    hintSilent "Time Trials: no trials available for this helicopter.";
};

[_veh, _eligible] call GLT_Trials_fnc_openTrialMenu;

