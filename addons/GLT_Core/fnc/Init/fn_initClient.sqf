/*
    GLT_Trials_fnc_initClient
    Client-side bootstrap for the helicopter time trial framework.
*/

if (!hasInterface) exitWith {};

// Clear any stray local hover lamps from a previous session (e.g. editor restart).
[] call GLT_Trials_fnc_clearHoverZoneLights;
[] call GLT_Trials_fnc_clearLandPointSmoke;
[] call GLT_Trials_fnc_clearSlingPickupSmoke;
[] call GLT_Trials_fnc_clearSlingDeliverSmoke;
[] call GLT_Trials_fnc_clearDestroyTargetSmoke;
[] call GLT_Trials_fnc_clearSlingDeliverVisuals;
// Progress bar controls live in uiNamespace only (not missionNamespace — controls are not serializable).
uiNamespace setVariable ["GLT_Trials_hoverBarBg", nil];
uiNamespace setVariable ["GLT_Trials_hoverBarProg", nil];
uiNamespace setVariable ["GLT_Trials_hoverBarTxt", nil];
uiNamespace setVariable ["GLT_Trials_deliverHudBg", nil];
uiNamespace setVariable ["GLT_Trials_deliverHudTxt", nil];

// Terminal Rsc uses this flag for cleanup; keep false so trial HUD is never blocked at mission start.
GLT_Trials_terminalViewActive = false;

// Local client state containers
GLT_Trials_clientActiveRun = objNull;   // info about the run this client is viewing/participating in
GLT_Trials_clientHudShown = false;

GLT_Trials_clientRunId = -1;
GLT_Trials_clientRunSyncedOnce = false;
GLT_Trials_draw3D_eh = -1;

// Ensure Draw3D handler is installed; it drives HUD + guidance markers.
if (isNil "GLT_Trials_draw3D_eh" || { GLT_Trials_draw3D_eh < 0 }) then {
    GLT_Trials_draw3D_eh = addMissionEventHandler ["Draw3D", {
        call GLT_Trials_fnc_drawFrame;
    }];
};

// Attach/cleanup the "Time Trials" action when the player enters/exits a valid helicopter.
player addEventHandler ["GetInMan", {
    params ["_unit", "_role", "_vehicle"];
    diag_log text format ["[PTF_TT][GETIN] unit=%1 role=%2 vehicle=%3 type=%4", _unit, _role, _vehicle, typeOf _vehicle];
    if (_unit isNotEqualTo player) exitWith {};
    if (isNull _vehicle) exitWith {};
    [_unit, _vehicle] call GLT_Trials_fnc_onVehicleEntered;
}];

player addEventHandler ["GetOutMan", {
    params ["_unit", "_role", "_vehicle"];
    if (_unit isNotEqualTo player) exitWith {};
    if (isNull _vehicle) exitWith {};
    [_unit, _vehicle] call GLT_Trials_fnc_onVehicleExited;
}];

// Setup interactive terminals (single class: GLT_Trials_Terminal; Rsc UI with Live / Leaderboard tabs).
{
    private _obj = _x;
    if (isNull _obj) exitWith {};
    private _existing = _obj getVariable ["GLT_Trials_terminalActionId", -1];
    if (_existing >= 0) exitWith {};

    private _id = _obj addAction [
        "Time Trials Terminal",
        {
            params ["_target", "_caller"];
            ["LIVE", _target, _caller] call GLT_Trials_fnc_openTerminalView;
        },
        [],
        1.5,
        false,
        true,
        "",
        "player distance _target <= 4"
    ];
    _obj setVariable ["GLT_Trials_terminalActionId", _id];
} forEach (allMissionObjects "GLT_Trials_Terminal");

// Clients rely on server broadcasts (GLT_Trials_activeRunsPublic / GLT_Trials_recentRunsPublic) for timing + state.

// Register keybind (CBA) for opening the Time Trials selector, if CBA is present.
if (isClass (configFile >> "CfgPatches" >> "cba_main")) then {
    // DIK_T = 0x14; Shift + T
    ["PTF_TT",
     "TimeTrialsSelect",
     ["Time Trials - Select Trial", "Time Trials"],
     { [] call GLT_Trials_fnc_onKeySelectTrial },
     {},
     [0x14, [true, false, false]]
    ] call CBA_fnc_addKeybind;
};
