class Attributes
{
    #include "\z\GLT\addons\GLT_Core\cfgTimeTrial_Eden_BaseAttributes.hpp"
    
    class GLT_Trials_trialId: GLT_Trials_Base_TrialId
    {
        property = "GLT_Trials_trialId_SlingDeliver_Property";
    };

    class GLT_Trials_segmentIndex: GLT_Trials_Base_SegmentIndex
    {
        property = "GLT_Trials_segmentIndex_SlingDeliver_Property";
    };

    class GLT_Trials_slingRadius: GLT_Trials_Base_Number
    {
        displayName = "Delivery Radius (m)";
        tooltip = "Cargo must be on the ground inside this circle (not on the hook). Four cones mark the radius.";
        property = "GLT_Trials_slingRadius_SlingDeliver_Property";
        defaultValue = "(8)";
        expression = "_this setVariable ['GLT_Trials_slingRadius', _value, true]";
    };
};
