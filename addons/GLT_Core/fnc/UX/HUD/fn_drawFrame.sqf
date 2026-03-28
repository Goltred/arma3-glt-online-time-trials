/*
    GLT_Trials_fnc_drawFrame
    Draw3D handler used to render the Time Trials HUD (and nothing else).
*/

if (!hasInterface) exitWith {};

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

