/*
    GLT_Trials_fnc_syncSlingDeliverSmoke
    Client: blue smoke at sling delivery zone center (same pattern as pickup / land smoke).
*/

[
    {
        private _segType = _this param [9, ""];
        private _segPos = _this param [8, [0, 0, 0]];
        if (
            (count _segPos) < 3
            || { (_segType isNotEqualTo "SLING_DELIVER_CIRCLE") && {_segType isNotEqualTo "SLING_DELIVER_RECT"} }
        ) exitWith { [] };
        _segPos
    },
    "GLT_Trials_slingDeliverSmokeObj",
    "GLT_Trials_slingDeliverSmokeSig",
    "GLT_Trials_slingDeliverSmokeRefreshAt",
    ["SmokeShellBlue", "G_40mm_Smoke_Blue"],
    ["SmokeShellBlue", "G_40mm_Smoke_Blue"]
] call GLT_Trials_fnc_syncHudSmokeShell
