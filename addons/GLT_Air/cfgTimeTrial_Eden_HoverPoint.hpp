class Attributes
{
    #include "\z\GLT\addons\GLT_Core\cfgTimeTrial_Eden_BaseAttributes.hpp"

    class GLT_Trials_segmentIndex: GLT_Trials_Base_SegmentIndex
    {
        property = "GLT_Trials_segmentIndex_HoverPoint_Property";
    };

    class GLT_Trials_hoverAltitudeMin: GLT_Trials_Base_Number
    {
        displayName = "Alt Min (m above marker)";
        tooltip = "Minimum height above the hover circle center (world). Default 0.";
        property = "GLT_Trials_hoverAltitudeMin_HoverPoint_Property";
        expression = "_this setVariable ['GLT_Trials_hoverAltitudeMin', _value, true]";
    };

    class GLT_Trials_hoverAltitudeMax: GLT_Trials_Base_Number
    {
        displayName = "Alt Max (m above marker)";
        tooltip = "Maximum height above the hover circle center (world). Default 5.";
        property = "GLT_Trials_hoverAltitudeMax_HoverPoint_Property";
        defaultValue = "(5)";
        expression = "_this setVariable ['GLT_Trials_hoverAltitudeMax', _value, true]";
    };

    class GLT_Trials_hoverSeconds: GLT_Trials_Base_Number
    {
        displayName = "Hover Duration (seconds)";
        tooltip = "Time to stay within the circle, altitude band, and hover. Decimals allowed (e.g. 2.5). Default 4.";
        property = "GLT_Trials_hoverSeconds_HoverPoint_Property";
        defaultValue = "(4)";
        expression = "_this setVariable ['GLT_Trials_hoverSeconds', _value, true]";
    };

    class GLT_Trials_hoverRadiusExtra: GLT_Trials_Base_Number
    {
        displayName = "Horizontal radius (m)";
        tooltip = "Added to the size of the placed VR circle (2D distance to center). Positive = more lenient position; negative = tighter. Vertical limits are only Alt Min / Alt Max.";
        property = "GLT_Trials_hoverRadiusExtra_HoverPoint_Property";
        defaultValue = "(5)";
        expression = "_this setVariable ['GLT_Trials_hoverRadiusExtra', _value, true]";
    };

    class GLT_Trials_hoverLightDimFar: GLT_Trials_Base_LightDimFar
    {
        property = "GLT_Trials_hoverLightDimFar_HoverPoint_Property";
        expression = "_this setVariable ['GLT_Trials_hoverLightDimFar', _value, true]";
    };

    class GLT_Trials_hoverLightDimClose: GLT_Trials_Base_LightDimClose
    {
        property = "GLT_Trials_hoverLightDimClose_HoverPoint_Property";
        expression = "_this setVariable ['GLT_Trials_hoverLightDimClose', _value, true]";
    };
};

