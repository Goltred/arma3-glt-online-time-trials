class Attributes
{
    class GLT_Trials_persistenceMode
    {
        displayName = "Persistence Mode (0/1)";
        tooltip = "0 = leaderboard reset each mission. 1 = persist via profileNamespace.";
        property = "GLT_Trials_persistenceMode_Property";
        control = "Edit";
        condition = "1";
        defaultValue = "(0)";
        typeName = "NUMBER";
        expression = "_this setVariable ['GLT_Trials_persistenceMode', _value, true]";
    };

    class GLT_Trials_leaderboardSize
    {
        displayName = "Leaderboard Entries";
        tooltip = "How many completed runs to keep for the leaderboard.";
        property = "GLT_Trials_leaderboardSize_Property";
        control = "Edit";
        condition = "1";
        defaultValue = "(15)";
        typeName = "NUMBER";
        expression = "_this setVariable ['GLT_Trials_leaderboardSize', _value, true]";
    };

    class GLT_Trials_persistenceBackend
    {
        displayName = "Persistence Backend";
        tooltip = "Pluggable backend name. Currently supported: profileNamespace";
        property = "GLT_Trials_persistenceBackend_Property";
        control = "Edit";
        condition = "1";
        defaultValue = "(""profileNamespace"")";
        typeName = "STRING";
        expression = "_this setVariable ['GLT_Trials_persistenceBackend', _value, true]";
    };
};

