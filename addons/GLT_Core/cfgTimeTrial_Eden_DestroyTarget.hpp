class Attributes
{
    #include "\z\GLT\addons\GLT_Core\cfgTimeTrial_Eden_BaseAttributes.hpp"

    class GLT_Trials_segmentIndex: GLT_Trials_Base_SegmentIndex
    {
        property = "GLT_Trials_segmentIndex_DestroyTarget_Property";
    };

    class GLT_Trials_destroyVehicleClass: GLT_Trials_Base_String
    {
        displayName = "Vehicle Class";
        tooltip = "Classname to spawn for destroy target.";
        property = "GLT_Trials_destroyVehicleClass_Property";
        defaultValue = "(""O_G_Offroad_01_armed_F"")";
        expression = "_this setVariable ['GLT_Trials_destroyVehicleClass', _value, true]";
    };

    class GLT_Trials_destroySpawnDriver: GLT_Trials_Base_YesNo
    {
        displayName = "Spawn driver";
        tooltip = "If enabled, spawn a unit in the driver seat.";
        property = "GLT_Trials_destroySpawnDriver_Property";
        expression = "_this setVariable ['GLT_Trials_destroySpawnDriver', _value, true]";
    };

    class GLT_Trials_destroySpawnGunners: GLT_Trials_Base_YesNo
    {
        displayName = "Spawn gunner / commander";
        tooltip = "If enabled, crew gunner and commander seats (not driver unless Spawn driver is also Yes).";
        property = "GLT_Trials_destroySpawnGunners_Property";
        expression = "_this setVariable ['GLT_Trials_destroySpawnGunners', _value, true]";
    };

    class GLT_Trials_destroySide
    {
        displayName = "Crew Side";
        tooltip = "Side used for spawned crew.";
        property = "GLT_Trials_destroySide_Property";
        control = "Combo";
        condition = "1";
        defaultValue = "(0)";
        typeName = "NUMBER";
        expression = "_this setVariable ['GLT_Trials_destroySide', _value, true]";
        class Values
        {
            class Opfor
            {
                name = "OPFOR";
                value = 0;
            };
            class Blufor
            {
                name = "BLUFOR";
                value = 1;
            };
            class Independent
            {
                name = "INDFOR";
                value = 2;
            };
            class Civilian
            {
                name = "Civilian";
                value = 3;
            };
        };
    };

    class GLT_Trials_destroySkill: GLT_Trials_Base_Number
    {
        displayName = "Crew skill (0..1)";
        tooltip = "AI skill used for spawned crew. 0 = weakest, 1 = strongest.";
        property = "GLT_Trials_destroySkill_Property";
        defaultValue = "(1)";
        expression = "_this setVariable ['GLT_Trials_destroySkill', _value, true]";
    };

    class GLT_Trials_destroyOptional: GLT_Trials_Base_Optional
    {
        property = "GLT_Trials_destroyOptional_Property";
    };
};
