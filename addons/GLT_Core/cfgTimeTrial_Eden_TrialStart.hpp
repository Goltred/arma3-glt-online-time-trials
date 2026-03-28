class Attributes
{
    #include "\z\GLT\addons\GLT_Core\cfgTimeTrial_Eden_BaseAttributes.hpp"

    class GLT_Trials_trialId: GLT_Trials_Base_TrialId
    {
        displayName = "Trial Id (unique)";
        tooltip = "Used to link this start object to its end + all segment objects.";
        property = "GLT_Trials_trialId_Property";
    };

    class GLT_Trials_trialName: GLT_Trials_Base_String
    {
        displayName = "Trial Name (friendly name)";
        tooltip = "Display name for HUD/menus.";
        property = "GLT_Trials_trialName_Property";
        defaultValue = "(""Trial 1"")";
        expression = "_this setVariable ['GLT_Trials_trialName', _value, true]";
    };

    class GLT_Trials_allowedHelis: GLT_Trials_Base_String
    {
        displayName = "Allowed Heli Classes (comma-separated)";
        tooltip = "Leave empty to allow ANY helicopter. Otherwise list classnames, e.g. 'B_Heli_Transport_01_F,PTF_UH1Y'.";
        property = "GLT_Trials_allowedHelis_Property";
        expression = "_this setVariable ['GLT_Trials_allowedHelis', _value, true]";
    };

    class GLT_Trials_startRadius: GLT_Trials_Base_Number
    {
        displayName = "Start Zone Radius (m)";
        tooltip = "Pilot must be within this radius to start the trial timer.";
        property = "GLT_Trials_startRadius_Property";
        defaultValue = "(30)";
        expression = "_this setVariable ['GLT_Trials_startRadius', _value, true]";
    };

    class GLT_Trials_touchMethod: GLT_Trials_Base_TouchMethod
    {
        property = "GLT_Trials_touchMethod_Start_Property";
    };

    class GLT_Trials_touchPadding: GLT_Trials_Base_TouchPadding
    {
        property = "GLT_Trials_touchPadding_Start_Property";
    };
};

