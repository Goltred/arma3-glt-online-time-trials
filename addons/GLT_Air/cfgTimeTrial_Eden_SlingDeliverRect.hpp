class Attributes
{
    #include "\z\GLT\addons\GLT_Core\cfgTimeTrial_Eden_BaseAttributes.hpp"
    
    class GLT_Trials_trialId: GLT_Trials_Base_TrialId
    {
        property = "GLT_Trials_trialId_SlingDeliverRect_Property";
    };

    class GLT_Trials_segmentIndex: GLT_Trials_Base_SegmentIndex
    {
        property = "GLT_Trials_segmentIndex_SlingDeliverRect_Property";
    };

    class GLT_Trials_slingRectHalfWidth: GLT_Trials_Base_Number
    {
        displayName = "Half Width (m)";
        tooltip = "Distance from center to left/right edge along the object's horizontal right axis.";
        property = "GLT_Trials_slingRectHalfWidth_Property";
        defaultValue = "(10)";
        expression = "_this setVariable ['GLT_Trials_slingRectHalfWidth', _value, true]";
    };

    class GLT_Trials_slingRectHalfLength: GLT_Trials_Base_Number
    {
        displayName = "Half Length (m)";
        tooltip = "Distance from center to front/back along the object's facing direction.";
        property = "GLT_Trials_slingRectHalfLength_Property";
        defaultValue = "(15)";
        expression = "_this setVariable ['GLT_Trials_slingRectHalfLength', _value, true]";
    };

    class GLT_Trials_slingRectLightDimFar: GLT_Trials_Base_LightDimFar
    {
        property = "GLT_Trials_slingRectLightDimFar_Property";
        expression = "_this setVariable ['GLT_Trials_slingRectLightDimFar', _value, true]";
    };

    class GLT_Trials_slingRectLightDimClose: GLT_Trials_Base_LightDimClose
    {
        property = "GLT_Trials_slingRectLightDimClose_Property";
        expression = "_this setVariable ['GLT_Trials_slingRectLightDimClose', _value, true]";
    };
};
