class Attributes
{
    #include "\z\GLT\addons\GLT_Core\cfgTimeTrial_Eden_BaseAttributes.hpp"

    class GLT_Trials_trialId: GLT_Trials_Base_TrialId
    {
        property = "GLT_Trials_trialId_End_Property";
    };

    class GLT_Trials_endRadius: GLT_Trials_Base_Number
    {
        displayName = "End Zone Radius (m)";
        tooltip = "Pilot must finish within this radius.";
        property = "GLT_Trials_endRadius_Property";
        defaultValue = "(30)";
        expression = "_this setVariable ['GLT_Trials_endRadius', _value, true]";
    };

    class GLT_Trials_touchMethod: GLT_Trials_Base_TouchMethod
    {
        property = "GLT_Trials_touchMethod_End_Property";
    };

    class GLT_Trials_touchPadding: GLT_Trials_Base_TouchPadding
    {
        property = "GLT_Trials_touchPadding_End_Property";
    };
};

