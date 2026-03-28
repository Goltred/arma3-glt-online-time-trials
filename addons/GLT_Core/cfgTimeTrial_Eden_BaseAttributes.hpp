
class GLT_Trials_Base_String
{
    control = "Edit";
    condition = "1";
    typeName = "STRING";
    defaultValue = "("""")";
}

class GLT_Trials_Base_Number
{
    control = "Edit";
    condition = "1";
    defaultValue = "(0)";
    typeName = "NUMBER";
}

class GLT_Trials_Base_TrialId: GLT_Trials_Base_String
{
    displayName = "Trial Id (must match start)";
    tooltip = "Id of the trial that this belongs to. Must match the Trial Id on the Trial Start object.";
    defaultValue = "(""trial_1"")";
    expression = "_this setVariable ['GLT_Trials_trialId', _value, true]";
}

class GLT_Trials_Base_TouchMethod: GLT_Trials_Base_Number
{
    displayName = "Touch Method";
    tooltip = "0=OBB_HULL (recommended), 1=SPHERE_HULL, 2=CENTER_2D (legacy).";
    expression = "_this setVariable ['GLT_Trials_touchMethod', _value, true]";
};

class GLT_Trials_Base_TouchPadding: GLT_Trials_Base_Number
{
    displayName = "Touch Padding (m)";
    tooltip = "Extra padding added to the heli hull when checking touch.";
    expression = "_this setVariable ['GLT_Trials_touchPadding', _value, true]";
};

class GLT_Trials_Base_SegmentIndex: GLT_Trials_Base_Number
{
    displayName = "Segment Index (order)";
    tooltip = "Higher segments come later in the trial.";
    expression = "_this setVariable ['GLT_Trials_segmentIndex', _value, true]";
};

class GLT_Trials_Base_LightDimFar: GLT_Trials_Base_Number
{
    displayName = "Lights — full strength beyond (m)";
    tooltip = "Eye-to-waypoint distance: farther than this = helper lights at full brightness. Closer = they fade toward the minimum.";
    defaultValue = "(95)";
};

class GLT_Trials_Base_LightDimClose: GLT_Trials_Base_Number
{
    displayName = "Lights — dimmest within (m)";
    tooltip = "Inside this distance (eye to waypoint center), lights stay at minimum brightness (still visible). Should be smaller than 'full strength beyond'.";
    defaultValue = "(32)";
};

class GLT_Trials_Base_YesNo: GLT_Trials_Base_Number
{
    control = "Combo";
    condition = "1";
    defaultValue = "(0)";
    typeName = "NUMBER";
    class Values
    {
        class No
        {
            name = "No";
            value = 0;
        };
        class Yes
        {
            name = "Yes";
            value = 1;
        };
    };
};

class GLT_Trials_Base_Optional: GLT_Trials_Base_YesNo
{
    displayName = "Optional obstacle only";
    tooltip = "If enabled: spawns at run start, does not count as waypoint, despawns when run ends.";
    expression = "_this setVariable ['GLT_Trials_optional', _value, true]";
};