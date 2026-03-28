class Attributes
{
    #include "\z\GLT\addons\GLT_Core\cfgTimeTrial_Eden_BaseAttributes.hpp"
    
    class GLT_Trials_trialId: GLT_Trials_Base_TrialId
    {
        property = "GLT_Trials_trialId_LandPoint_Property";
    };

    class GLT_Trials_segmentIndex: GLT_Trials_Base_SegmentIndex
    {
        property = "GLT_Trials_segmentIndex_LandPoint_Property";
    };

    class GLT_Trials_landRadius: GLT_Trials_Base_Number
    {
        displayName = "Land Radius (m)";
        tooltip = "Distance from the point to count as landing.";
        property = "GLT_Trials_landRadius_LandPoint_Property";
        defaultValue = "(8)";
        expression = "_this setVariable ['GLT_Trials_landRadius', _value, true]";
    };

    class GLT_Trials_landStaySeconds: GLT_Trials_Base_Number
    {
        displayName = "Stay Duration (seconds)";
        tooltip = "Time required to remain landed (touching ground) within the landing radius.";
        property = "GLT_Trials_landStaySeconds_LandPoint_Property";
        defaultValue = "(3)";
        expression = "_this setVariable ['GLT_Trials_landStaySeconds', _value, true]";
    };
};

