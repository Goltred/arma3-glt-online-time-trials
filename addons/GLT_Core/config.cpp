class CfgPatches
{
    class GLT_Core
    {
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.0;
        requiredAddons[] = {
            "cba_main",
            "A3_Structures_F_Training",
            "A3_Structures_F_Mil_Helipads",
            "A3_Signs_F"
        };
        author = "Goltred";
    };
};

class CfgEditorCategories
{
    class GLT_Trials
    {
        displayName = "Online Time Trials";
        Priority = 0;
        side = 8;
    };
};

class CfgEditorSubcategories
{
    class GLT_Trials_Config
    {
        displayName = "Online Time Trials - Config";
    };
    class GLT_Trials_Trials
    {
        displayName = "Online Time Trials - Trials";
    };
    class GLT_Trials_Segments
    {
        displayName = "Online Time Trials - Segments";
    };
    class GLT_Trials_Terminals
    {
        displayName = "Online Time Trials - Terminals";
    };
};

class CfgFunctions
{
    class GLT_Trials_Core
    {
        tag = "GLT_Trials";

        class Init
        {
            file = "\z\GLT\addons\GLT_Core\fnc\Init";
            class initServer
            {
                postInit = 1;
                serverOnly = 1;
            };
            class initClient
            {
                postInit = 1;
                serverOnly = 0;
            };
        };

        class Register
        {
            file = "\z\GLT\addons\GLT_Core\fnc\Register";
            class registerTrial {};
            class registerSegments_DestroyTarget {};
            class registerSegments_DestroyInfantry {};
        };

        class Execution
        {
            file = "\z\GLT\addons\GLT_Core\fnc\Execution";
            class startRun {};
            class requestCancelRun {};
            class updateRunState {};
            class tickServer {};
            class finishRun {};
            class abortRun {};
            class onVehicleEntered {};
            class onVehicleExited {};
            class syncCourseObjectVisibility {};
        };

        class Segments
        {
            file = "\z\GLT\addons\GLT_Core\fnc\Segments";
            class pointInSlingRect {};
            class pointInSlingDeliveryZone {};
            class isDestroyTargetComplete {};
            class isDestroyInfantryComplete {};
            class segmentWaypointLabel {};
        };

        class Spawn
        {
            file = "\z\GLT\addons\GLT_Core\fnc\Spawn";
            class ensureSlingPickupCargo {};
            class spawnDestroyTarget {};
            class spawnDestroyInfantry {};
        };

        class Cleanup
        {
            file = "\z\GLT\addons\GLT_Core\fnc\Cleanup";
            class cleanupSlingCargo {};
            class cleanupDestroyTargets {};
        };

        class Helpers
        {
            file = "\z\GLT\addons\GLT_Core\fnc\Helpers";
            class parseAllowedHelis {};
            class calcOBBData {};
            class getHelperLightDimsFromObj {};
            class normalizeHelperLightDims {};
            class numberFromEden {};
            class resolveClientHudRun {};
        };

        class UXDialogs
        {
            file = "\z\GLT\addons\GLT_Core\fnc\UX\Dialogs";
            class openTrialMenu {};
            class onKeySelectTrial {};
            class trialDialogButton {};
            class terminalDialogButton {};
            class openTerminalView {};
        };

        class UXHUD
        {
            file = "\z\GLT\addons\GLT_Core\fnc\UX\HUD";
            class updateHud {};
            class drawFrame {};
            class updateHoverProgressBar {};
            class updateHoverZoneLightsIntensity {};
            class updateSlingDeliverRectLightsIntensity {};
        };

        class UXRoute
        {
            file = "\z\GLT\addons\GLT_Core\fnc\UX\Route";
            class updateTrialRouteMarkers {};
            class syncCourseObjects3DWindow {};
            class deleteTrialRouteMarkers {};
        };

        class UXTerminal
        {
            file = "\z\GLT\addons\GLT_Core\fnc\UX\Terminal";
            class updateBaseScreens {};
            class updateTerminalScreens {};
        };

        class UXEffects
        {
            file = "\z\GLT\addons\GLT_Core\fnc\UX\Effects";
            class hoverZoneLights {};
            class clearHoverZoneLights {};
            class syncHoverZoneLights {};
            class syncLandPointSmoke {};
            class clearLandPointSmoke {};
            class syncSlingPickupSmoke {};
            class clearSlingPickupSmoke {};
            class syncSlingDeliverVisuals {};
            class clearSlingDeliverVisuals {};
            class syncSlingDeliverSmoke {};
            class clearSlingDeliverSmoke {};
            class syncDestroyTargetSmoke {};
            class clearDestroyTargetSmoke {};
        };

        class Persistence
        {
            file = "\z\GLT\addons\GLT_Core\fnc\Persistence";
            class loadLeaderboard {};
            class saveLeaderboard {};
        };
    };
};

// Simple trial selection dialog
class RscText;
class RscButton;
class RscListbox;
class RscStructuredText;

class RscDisplayGLT_Trials_Selector
{
    idd = 88000;
    movingEnable = 0;
    enableSimulation = 1;
    onUnload = "missionNamespace setVariable ['GLT_Trials_trialVehicle', objNull]; missionNamespace setVariable ['GLT_Trials_trialEligible', []]; missionNamespace setVariable ['GLT_Trials_trialMenuActiveRow', []];";

    class controls
    {
        class ActiveBackdrop: RscText
        {
            idc = 1010;
            text = "";
            // Title + list / summary only — buttons sit below so hover reads against the world
            x = 0.26; y = 0.22;
            w = 0.48; h = 0.405;
            colorBackground[] = {0, 0, 0, 0.78};
            show = 1;
        };

        class Title: RscText
        {
            idc = 1000;
            text = "";
            x = 0.3; y = 0.25;
            w = 0.4; h = 0.04;
            colorText[] = {0.96, 0.96, 0.96, 1};
            colorBackground[] = {0, 0, 0, 0};
            shadow = 1;
        };

        class ActiveSummary: RscStructuredText
        {
            idc = 1001;
            text = "";
            x = 0.3; y = 0.30;
            w = 0.4; h = 0.3;
            show = 0;
            colorBackground[] = {0, 0, 0, 0};
        };

        class TrialList: RscListbox
        {
            idc = 1500;
            x = 0.3; y = 0.30;
            w = 0.4; h = 0.3;
            // Light list surface (inventory-style) over darker ListPanel + dim backdrop
            colorBackground[] = {0.2, 0.2, 0.2, 1};
            color[] = {0.95, 0.95, 0.95, 1};
        };

        class TrialButton: RscButton
        {
            colorBackground[] = {0.22, 0.22, 0.24, 0.95};
            colorBackgroundActive[] = {0.3, 0.3, 0.33, 1};
            colorBackgroundFocused[] = {0.22, 0.22, 0.24, 0.95};
            colorFocused[] = {0.95, 0.95, 0.95, 1};
            color[] = {0.95, 0.95, 0.95, 1};
            colorActive[] = {1, 1, 1, 1};
            // Base row is a template only (no idc): hide so RV does not spawn a stray button. Children override show.
            show = 0;
            // Vanilla CT_BUTTON can pulse text/background using period*; non-zero periodFocus reads as focus "blink".
            period = 0;
            periodFocus = 0;
            periodOver = 0;
        }

        class OkButton: TrialButton
        {
            idc = 1600;
            text = "OK";
            x = 0.3; y = 0.665;
            w = 0.18; h = 0.04;
            action = "['OK'] call GLT_Trials_fnc_trialDialogButton;";
        };

        class StopTrialButton: TrialButton
        {
            idc = 1602;
            text = "Stop trial";
            x = 0.3; y = 0.665;
            w = 0.18; h = 0.04;
            show = 0;
            action = "['STOP'] call GLT_Trials_fnc_trialDialogButton;";
        };

        class CloseButton: TrialButton
        {
            idc = 1601;
            text = "Close";
            x = 0.52; y = 0.665;
            w = 0.18; h = 0.04;
            action = "['CANCEL'] call GLT_Trials_fnc_trialDialogButton;";
            show = 1;
        };
    };
};

class RscDisplayGLT_Trials_Terminal
{
    idd = 88100;
    movingEnable = 0;
    enableSimulation = 1;
    onUnload = "GLT_Trials_terminalViewActive = false; missionNamespace setVariable ['GLT_Trials_terminalMode', 'LIVE']; missionNamespace setVariable ['GLT_Trials_terminalObject', objNull];";

    class controls
    {
        class Frame: RscText
        {
            idc = 1200;
            text = "";
            x = 0.22; y = 0.18;
            w = 0.56; h = 0.62;
            colorBackground[] = {0, 0, 0, 0.75};
        };

        class Title: RscText
        {
            idc = 1100;
            text = "Time Trials Terminal";
            x = 0.24; y = 0.20;
            w = 0.52; h = 0.04;
        };

        class LiveButton: RscButton
        {
            idc = 1602;
            text = "Live Trials";
            x = 0.24; y = 0.25;
            w = 0.16; h = 0.04;
            action = "['LIVE'] call GLT_Trials_fnc_terminalDialogButton;";
        };

        class LeaderboardButton: RscButton
        {
            idc = 1603;
            text = "Leaderboard";
            x = 0.41; y = 0.25;
            w = 0.16; h = 0.04;
            action = "['LEADERBOARD'] call GLT_Trials_fnc_terminalDialogButton;";
        };

        class CloseButton: RscButton
        {
            idc = 1604;
            text = "Close";
            x = 0.60; y = 0.25;
            w = 0.16; h = 0.04;
            action = "['CLOSE'] call GLT_Trials_fnc_terminalDialogButton;";
        };

        class Body: RscStructuredText
        {
            idc = 1101;
            text = "";
            x = 0.24; y = 0.31;
            w = 0.52; h = 0.47;
        };
    };
};

// Eden editor objects/helpers
#include "cfgTimeTrial_Core.hpp"

