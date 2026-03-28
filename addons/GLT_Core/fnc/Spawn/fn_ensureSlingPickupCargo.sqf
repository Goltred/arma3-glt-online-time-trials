/*
    GLT_Trials_fnc_ensureSlingPickupCargo
    Server: ensure a sling pickup cargo object exists for this run.
    Params: [_run, _seg] — _seg = ["SLING_PICKUP", idx, posASL, cargoClass]

    Cargo is always a spawned vehicle of the configured class at the helper position.
    The helper object itself is an editor gizmo only (hidden at runtime).
*/

params ["_run", "_seg"];

if (!isServer) exitWith {};

if (!isNull (_run getOrDefault ["slingCargoObj", objNull])) exitWith { true };

private _pos = +(_seg select 2);
private _cargoClass = _seg select 3;
if ((count _pos) < 3) exitWith { false };
if !(_cargoClass isEqualType "") then { _cargoClass = str _cargoClass };
if (_cargoClass isEqualTo "") then { _cargoClass = "Land_FoodSacks_01_cargo_white_idap_F" };

private _cargo = createVehicle [_cargoClass, [0, 0, 0], [], 0, "CAN_COLLIDE"];
if (isNull _cargo) exitWith { false };

_cargo setPosASL _pos;
_cargo setVectorUp (surfaceNormal getPosASL _cargo);
_cargo enableSimulationGlobal true;

_run set ["slingCargoObj", _cargo];

true
