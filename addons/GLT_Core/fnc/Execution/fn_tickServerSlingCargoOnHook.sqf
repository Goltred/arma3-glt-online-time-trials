/*
    GLT_Trials_fnc_tickServerSlingCargoOnHook
    Server: whether trial cargo is attached to the helicopter (sling load or rope variable).
    Params: [_run, _cargo]
    Returns: boolean
*/

params ["_run", "_cargo"];
if (isNull _cargo) exitWith { false };

private _heli = _run get "heli";
if (isNull _heli) exitWith { false };

private _sl = getSlingLoad _heli;
if (!isNull _sl) exitWith { _sl == _cargo };

(_cargo getVariable ["GLT_Trials_cargoRopesAttached", 0] > 0)
