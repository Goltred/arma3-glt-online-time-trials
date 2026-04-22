/*
    GLT_Trials_fnc_segmentWaypointLabel
    Map marker text only (HUD uses longer strings from fn_tickServer).

    Params: [_kind, _order]
      _kind: "START" | "END" | segment type (e.g. "CROSS_GATE")
      _order: 0-based map-route / segment index (same as server segmentIndex); ignored for START / END.
      Display numbers are 1-based to match fn_tickServer HUD strings (_segIdx + 1).
*/

params ["_kind", "_order"];

private _n = _order + 1;

switch (_kind) do {
    case "START": { "Start" };
    case "END": { "End" };
    case "CROSS_GATE": { str _n };
    case "HOVER_POINT": { format ["Hover at %1", _n] };
    case "LAND_POINT": { format ["Land %1", _n] };
    case "SLING_PICKUP": { format ["Sling pickup %1", _n] };
    case "SLING_DELIVER_CIRCLE";
    case "SLING_DELIVER_RECT": { format ["Sling deliver %1", _n] };
    case "DESTROY_TARGET": { format ["Destroy %1", _n] };
    case "DESTROY_INFANTRY": { format ["Destroy infantry %1", _n] };
    default { format ["WP %1", _n] };
};
