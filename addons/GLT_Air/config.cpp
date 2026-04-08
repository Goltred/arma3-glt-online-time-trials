class CfgPatches
{
    class GLT_Air
    {
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.0;
        requiredAddons[] = {
            "GLT_Core",
            "A3_Structures_F_Training",
            "A3_Structures_F_Mil_Helipads",
            "A3_Signs_F"
        };
        author = "Goltred";
    };
};

class CfgFunctions
{
    class GLT_Trials_Air
    {
        tag = "GLT_Trials";

        class Register
        {
            file = "\z\GLT\addons\GLT_Air\fnc\Register";
            class registerSegments_CrossGate {};
            class registerSegments_HoverPoint {};
            class registerSegments_LandPoint {};
            class registerSegments_SlingPickup {};
            class registerSegments_SlingDeliverCircle {};
            class registerSegments_SlingDeliverRect {};
        };
    };
};

#include "cfgTimeTrial_Air.hpp"
