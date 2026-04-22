/*
    GLT_Trials_fnc_drawFrame
    Draw3D handler used to render the Time Trials HUD (and nothing else).
*/

if (!hasInterface) exitWith {};
if (!(missionNamespace getVariable ["GLT_Trials_trialsAvailable", false])) exitWith { true };

// MP: crew in the trial vehicle adopt the driver's public run row (HUD, markers, smoke, 3D window).
private _resolvedRow = [] call GLT_Trials_fnc_resolveClientHudRun;
private _onFoot = (vehicle player isEqualTo player);
if ((count _resolvedRow) > 0) then {
    GLT_Trials_spectatorResolveMissFrames = 0;
    private _rid = parseNumber (str (_resolvedRow select 0));
    private _prevRid = if (isNil "GLT_Trials_clientRunId") then { -1 } else { parseNumber (str GLT_Trials_clientRunId) };
    if (_rid isNotEqualTo _prevRid) then {
        GLT_Trials_clientRunSyncStarted = -1;
        GLT_Trials_clientRunSyncedOnce = false;
    };
    GLT_Trials_clientRunId = _rid;
    GLT_Trials_clientHudShown = true;
    GLT_Trials_clientHudSpectator = ((getPlayerUID player) isNotEqualTo (_resolvedRow select 1));
} else {
    private _pendingFirstSync = GLT_Trials_clientHudShown
        && { (parseNumber (str GLT_Trials_clientRunId)) >= 0 }
        && { !(missionNamespace getVariable ["GLT_Trials_clientRunSyncedOnce", false]) };
    if (!_pendingFirstSync) then {
        if (GLT_Trials_clientHudShown && { GLT_Trials_clientHudSpectator }) then {
            private _dropSpectator = false;
            if (_onFoot) then {
                _dropSpectator = true;
            } else {
                // In a vehicle: tolerate brief empty activeRunsPublic between server broadcasts (~0.25s).
                GLT_Trials_spectatorResolveMissFrames = GLT_Trials_spectatorResolveMissFrames + 1;
                if (GLT_Trials_spectatorResolveMissFrames > 45) then {
                    _dropSpectator = true;
                };
            };
            if (_dropSpectator) then {
                GLT_Trials_spectatorResolveMissFrames = 0;
                GLT_Trials_clientRunSyncStarted = -1;
                GLT_Trials_clientHudShown = false;
                GLT_Trials_clientRunId = -1;
                GLT_Trials_clientRunSyncedOnce = false;
                GLT_Trials_lastSeenRunRow = [];
                GLT_Trials_lastSeenRunAt = -1;
                GLT_Trials_finishHudUntil = -1;
                GLT_Trials_clientHudSpectator = false;
                [] call GLT_Trials_fnc_deleteTrialRouteMarkers;
                hintSilent "";
            };
        };
    };
};

call GLT_Trials_fnc_syncCourseObjects3DWindow;
call GLT_Trials_fnc_updateHoverProgressBar;
call GLT_Trials_fnc_syncHoverZoneLights;
call GLT_Trials_fnc_syncLandPointSmoke;
call GLT_Trials_fnc_syncSlingPickupSmoke;
call GLT_Trials_fnc_syncSlingDeliverVisuals;
call GLT_Trials_fnc_syncSlingDeliverSmoke;
call GLT_Trials_fnc_syncDestroyTargetSmoke;
call GLT_Trials_fnc_updateHoverZoneLightsIntensity;
call GLT_Trials_fnc_updateSlingDeliverRectLightsIntensity;
call GLT_Trials_fnc_updateBaseScreens;

true

