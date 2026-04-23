/*
    GLT_Trials_fnc_syncLandPointSmoke
    Client: smoke at the active LAND_POINT segment center (server row index 8).

    Only CfgVehicles smoke *shells* (same sim as hand/40mm smoke grenades) so the plume reacts
    to wind and rotor wash. No #particlesource / CfgCloudlets fallback — those are static-looking
    and often read as a dark column with no wash interaction.

    createVehicleLocal position is unreliable with raw ASL; spawn at origin then setPosASL.
    Do not use !alive on smoke shells — many builds report !alive while smoke is visible or
    immediately, which would delete/recreate every Draw3D and look like "no smoke".

    CAN_COLLIDE so the entity participates in collision/physics like a dropped grenade.
*/

private _shellClassesPreferred = [
    "SmokeShellBlue",
    "G_40mm_Smoke_Blue",
    "SmokeShell"
];
private _classesToTry = _shellClassesPreferred + [
    "SmokeShellGreen",
    "SmokeShellYellow",
    "SmokeShellRed",
    "SmokeShellOrange",
    "SmokeShellPurple"
];

[
    {
        private _segType = _this param [9, ""];
        private _segPos = _this param [8, [0, 0, 0]];
        if ((count _segPos) < 3 || {!(_segType isEqualTo "LAND_POINT")}) exitWith { [] };
        _segPos
    },
    "GLT_Trials_landSmokeObj",
    "GLT_Trials_landSmokeSig",
    "GLT_Trials_landSmokeRefreshAt",
    _classesToTry,
    _shellClassesPreferred
] call GLT_Trials_fnc_syncHudSmokeShell
