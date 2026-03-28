class Attributes
{
    #include "\z\GLT\addons\GLT_Core\cfgTimeTrial_Eden_BaseAttributes.hpp"

    class GLT_Trials_trialId: GLT_Trials_Base_TrialId
    {
        property = "GLT_Trials_trialId_Property";
    };

    class GLT_Trials_segmentIndex: GLT_Trials_Base_SegmentIndex
    {
        property = "GLT_Trials_segmentIndex_CrossGate_Property";
    };

    class GLT_Trials_gateRadius : GLT_Trials_Base_Number
    {
        displayName = "Gate Radius (m)";
        tooltip = "When the heli passes through the gate within this horizontal radius, the segment completes.";
        property = "GLT_Trials_gateRadius_CrossGate_Property";
        defaultValue = "(8)";
        expression = "_this setVariable ['GLT_Trials_gateRadius', _value, true]";
    };

    class GLT_Trials_gateCrossTolerance : GLT_Trials_Base_Number
    {
        displayName = "Plane Cross Tolerance (m)";
        tooltip = "How close to the gate plane (along the gate's forward axis) the heli must be to count as crossing.";
        property = "GLT_Trials_gateCrossTolerance_CrossGate_Property";
        defaultValue = "(3)";
        expression = "_this setVariable ['GLT_Trials_gateCrossTolerance', _value, true]";
    };
};

