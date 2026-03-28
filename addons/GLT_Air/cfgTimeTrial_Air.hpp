class CfgVehicles
{
    class Sign_Circle_F;
    class VR_Area_01_Circle_4_Yellow_F;
    class Land_HelipadCircle_F;
    class Sign_Arrow_Direction_Green_F;
    class Land_HelipadEmpty_F;

    class GLT_Trials_CrossGate : Sign_Circle_F
    {
        scope = 2;
        editorCategory = "GLT_Trials";
        editorSubcategory = "GLT_Trials_Segments";
        author = "GLT";
        displayName = "Time Trials - Cross Gate";
        #include "cfgTimeTrial_Eden_CrossGate.hpp"
    };

    class GLT_Trials_HoverPoint : VR_Area_01_Circle_4_Yellow_F
    {
        scope = 2;
        editorCategory = "GLT_Trials";
        editorSubcategory = "GLT_Trials_Segments";
        author = "GLT";
        displayName = "Time Trials - Hover Point";
        #include "cfgTimeTrial_Eden_HoverPoint.hpp"
    };

    class GLT_Trials_LandPoint : Land_HelipadCircle_F
    {
        scope = 2;
        editorCategory = "GLT_Trials";
        editorSubcategory = "GLT_Trials_Segments";
        author = "GLT";
        displayName = "Time Trials - Land Point";
        #include "cfgTimeTrial_Eden_LandPoint.hpp"
    };

    class GLT_Trials_SlingPickup : Sign_Arrow_Direction_Green_F
    {
        scope = 2;
        editorCategory = "GLT_Trials";
        editorSubcategory = "GLT_Trials_Segments";
        author = "GLT";
        displayName = "Time Trials - Sling Pickup";
        #include "cfgTimeTrial_Eden_SlingPickup.hpp"
    };

    class GLT_Trials_SlingDeliver : Land_HelipadEmpty_F
    {
        scope = 2;
        editorCategory = "GLT_Trials";
        editorSubcategory = "GLT_Trials_Segments";
        author = "GLT";
        displayName = "Time Trials - Sling Deliver (Circle)";
        #include "cfgTimeTrial_Eden_SlingDeliver.hpp"
    };

    class GLT_Trials_SlingDeliverRect : Sign_Arrow_Direction_Green_F
    {
        scope = 2;
        editorCategory = "GLT_Trials";
        editorSubcategory = "GLT_Trials_Segments";
        author = "GLT";
        displayName = "Time Trials - Sling Deliver (Rectangle)";
        #include "cfgTimeTrial_Eden_SlingDeliverRect.hpp"
    };
};
