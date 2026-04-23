/*
    GLT_Trials_fnc_syncDestroyTargetSmoke
    Client: red smoke on active DESTROY_TARGET / DESTROY_INFANTRY objective.
*/

[
    {
        private _segType = _this param [9, ""];
        private _posASL = _this param [21, []];
        if (
            (_segType isNotEqualTo "DESTROY_TARGET")
            && { _segType isNotEqualTo "DESTROY_INFANTRY" }
        ) exitWith { [] };
        if ((count _posASL) < 3) exitWith { [] };
        _posASL
    },
    "GLT_Trials_destroySmokeObj",
    "GLT_Trials_destroySmokeSig",
    "GLT_Trials_destroySmokeRefreshAt",
    ["SmokeShellRed", "G_40mm_Smoke_Red"],
    ["SmokeShellRed", "G_40mm_Smoke_Red"]
] call GLT_Trials_fnc_syncHudSmokeShell
