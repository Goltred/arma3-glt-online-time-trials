/*
    GLT_Trials_fnc_resolveSegmentCourseObject
    Params: [_trialId, _segRow, _courseObjs]
    _segRow: segment array from registration (select 0 = type string, select 1 = Eden segment index)
    Returns: Eden object or objNull
*/

params ["_trialId", "_segRow", "_courseObjs"];
if (_trialId isEqualTo "") exitWith { objNull };
if (isNil "_segRow" || { count _segRow < 2 }) exitWith { objNull };

private _stype = _segRow select 0;
private _sidx = _segRow select 1;
private _hit = objNull;
private _ci = 0;
private _n = count _courseObjs;

while { _ci < _n && { isNull _hit } } do {
    private _x = _courseObjs select _ci;
    _ci = _ci + 1;
    if (!isNull _x) then {
        if ((_x getVariable ["GLT_Trials_trialId", ""]) isEqualTo _trialId) then {
            if ((_x getVariable ["GLT_Trials_segmentIndex", -999]) isEqualTo _sidx) then {
                private _oType = switch (true) do {
                    case (_x isKindOf "GLT_Trials_CrossGate"): { "CROSS_GATE" };
                    case (_x isKindOf "GLT_Trials_HoverPoint"): { "HOVER_POINT" };
                    case (_x isKindOf "GLT_Trials_LandPoint"): { "LAND_POINT" };
                    case (_x isKindOf "GLT_Trials_SlingPickup"): { "SLING_PICKUP" };
                    case (_x isKindOf "GLT_Trials_SlingDeliver"): { "SLING_DELIVER_CIRCLE" };
                    case (_x isKindOf "GLT_Trials_SlingDeliverRect"): { "SLING_DELIVER_RECT" };
                    case (_x isKindOf "GLT_Trials_DestroyTarget"): { "DESTROY_TARGET" };
                    case (_x isKindOf "GLT_Trials_DestroyInfantry"): { "DESTROY_INFANTRY" };
                    default { "" };
                };
                if (_oType isEqualTo _stype) then {
                    _hit = _x;
                };
            };
        };
    };
};

_hit
