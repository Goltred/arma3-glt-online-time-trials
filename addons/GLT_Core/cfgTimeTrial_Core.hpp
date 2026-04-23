class CfgVehicles
{
    class Logic;
    class Land_MultiScreenComputer_01_black_F;
    class Sign_Arrow_Direction_Green_F;

    // Editor-only helper: holds trial name, vehicle whitelist, category toggles. Logic parent so Eden Connections / sync work reliably.
    class GLT_Trials_TrialMeta : Logic
    {
        scope = 2;
        editorCategory = "GLT_Trials";
        editorSubcategory = "GLT_Trials_Config";
        author = "GLT";
        displayName = "Time Trials - Trial Definition";
        #include "cfgTimeTrial_Eden_TrialMeta.hpp"
    };

    class GLT_Trials_Master : Logic
    {
        scope = 2;
        editorCategory = "GLT_Trials";
        editorSubcategory = "GLT_Trials_Config";
        author = "GLT";
        displayName = "Time Trials - Master";
        #include "cfgTimeTrial_Eden_Master.hpp"
    };

    class GLT_Trials_DestroyTarget : Sign_Arrow_Direction_Green_F
    {
        scope = 2;
        editorCategory = "GLT_Trials";
        editorSubcategory = "GLT_Trials_Segments";
        author = "GLT";
        displayName = "Time Trials - Destroy Target";
        #include "cfgTimeTrial_Eden_DestroyTarget.hpp"
    };

    class GLT_Trials_DestroyInfantry : Sign_Arrow_Direction_Green_F
    {
        scope = 2;
        editorCategory = "GLT_Trials";
        editorSubcategory = "GLT_Trials_Segments";
        author = "GLT";
        displayName = "Time Trials - Destroy Infantry";
        #include "cfgTimeTrial_Eden_DestroyInfantry.hpp"
    };

    class GLT_Trials_Terminal : Land_MultiScreenComputer_01_black_F
    {
        scope = 2;
        side = 8;
        faction = "BLU_F";
        ace_cargo_space = 0;
        ace_cargo_hasCargo = 0;
        ace_cargo_size = 0;
        ace_cargo_canLoad = 0;
        ace_dragging_canCarry = 0;
        ace_dragging_canDrag = 0;
        editorCategory = "GLT_Trials";
        editorSubcategory = "GLT_Trials_Terminals";
        author = "GLT";
        displayName = "Time Trials - Terminal";
    };
};
