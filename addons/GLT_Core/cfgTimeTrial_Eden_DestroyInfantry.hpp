class Attributes
{
    #include "\z\GLT\addons\GLT_Core\cfgTimeTrial_Eden_BaseAttributes.hpp"

    class GLT_Trials_segmentIndex: GLT_Trials_Base_SegmentIndex
    {
        property = "GLT_Trials_segmentIndex_DestroyInfantry_Property";
    };

    class GLT_Trials_destroyInfClass: GLT_Trials_Base_String
    {
        displayName = "Infantry Class";
        tooltip = "Infantry classname to spawn (must be a CfgVehicles Man class).";
        property = "GLT_Trials_destroyInfClass_Property";
        defaultValue = "(""O_Soldier_F"")";
        expression = "_this setVariable ['GLT_Trials_destroyInfClass', _value, true]";
    };

    class GLT_Trials_destroyInfCount: GLT_Trials_Base_Number
    {
        displayName = "Unit Count";
        tooltip = "How many units are spawned in the squad.";
        property = "GLT_Trials_destroyInfCount_Property";
        defaultValue = "(6)";
        expression = "_this setVariable ['GLT_Trials_destroyInfCount', _value, true]";
    };

    class GLT_Trials_destroyInfSkill: GLT_Trials_Base_Number
    {
        displayName = "Squad skill (0..1)";
        tooltip = "AI skill used for spawned infantry squad. 0 = weakest, 1 = strongest.";
        property = "GLT_Trials_destroyInfSkill_Property";
        defaultValue = "(0.8)";
        expression = "_this setVariable ['GLT_Trials_destroyInfSkill', _value, true]";
    };

    class GLT_Trials_destroyInfOptional: GLT_Trials_Base_Optional
    {
        property = "GLT_Trials_destroyInfOptional_Property";
    };
};
