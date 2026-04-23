class Attributes
{
    #include "\z\GLT\addons\GLT_Core\cfgTimeTrial_Eden_BaseAttributes.hpp"

    class GLT_Trials_trialId: GLT_Trials_Base_TrialId
    {
        property = "GLT_Trials_trialId_TrialMeta_Property";
        tooltip = "Unique trial id. In Eden use Connections to link every segment waypoint with this object (either direction). Set Segment Index on each segment. One Trial Definition per id (first wins if duplicates).";
    };

    class GLT_Trials_trialName: GLT_Trials_Base_TrialName
    {
        property = "GLT_Trials_trialName_TrialMeta_Property";
    };

    class GLT_Trials_allowedHelis: GLT_Trials_Base_AllowedHelis
    {
        property = "GLT_Trials_allowedHelis_TrialMeta_Property";
    };

    class GLT_Trials_catHelicopter: GLT_Trials_Base_CatHelicopter
    {
        property = "GLT_Trials_catHelicopter_TrialMeta_Property";
    };

    class GLT_Trials_catPlane: GLT_Trials_Base_CatPlane
    {
        property = "GLT_Trials_catPlane_TrialMeta_Property";
    };

    class GLT_Trials_catGround: GLT_Trials_Base_CatGround
    {
        property = "GLT_Trials_catGround_TrialMeta_Property";
    };

    class GLT_Trials_catShip: GLT_Trials_Base_CatShip
    {
        property = "GLT_Trials_catShip_TrialMeta_Property";
    };
};
