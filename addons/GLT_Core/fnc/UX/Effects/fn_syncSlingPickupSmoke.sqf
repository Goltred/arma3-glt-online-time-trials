/*
    GLT_Trials_fnc_syncSlingPickupSmoke
    Client: green smoke at SLING_PICKUP segment center (same pattern as land smoke shells).
*/

[
    {
        private _segType = _this param [9, ""];
        private _segPos = _this param [8, [0, 0, 0]];
        if ((count _segPos) < 3 || {!(_segType isEqualTo "SLING_PICKUP")}) exitWith { [] };
        _segPos
    },
    "GLT_Trials_slingPickupSmokeObj",
    "GLT_Trials_slingPickupSmokeSig",
    "GLT_Trials_slingPickupSmokeRefreshAt",
    ["SmokeShellGreen", "G_40mm_Smoke_Green"],
    ["SmokeShellGreen", "G_40mm_Smoke_Green"]
] call GLT_Trials_fnc_syncHudSmokeShell
