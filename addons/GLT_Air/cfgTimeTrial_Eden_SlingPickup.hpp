class Attributes
{
    #include "\z\GLT\addons\GLT_Core\cfgTimeTrial_Eden_BaseAttributes.hpp"

    class GLT_Trials_segmentIndex: GLT_Trials_Base_SegmentIndex
    {
        property = "GLT_Trials_segmentIndex_SlingPickup_Property";
    };

    class GLT_Trials_slingPickupCargoClass: GLT_Trials_Base_String
    {
        displayName = "Cargo class";
        tooltip = "Classname to spawn for sling pickup cargo.";
        property = "GLT_Trials_slingPickupCargoClass_Property";
        defaultValue = "(""Land_FoodSacks_01_cargo_white_idap_F"")";
        expression = "_this setVariable ['GLT_Trials_slingPickupCargoClass', _value, true]";
    };
};
