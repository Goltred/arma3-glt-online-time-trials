/*
    GLT_Trials_fnc_segmentWaypointLabel
    Map marker text only (HUD uses longer strings from fn_tickServer).

    Params: [_kind, _order]
      _kind: "START" | "END" | "WAIT_START" | segment type (e.g. "CROSS_GATE")
      _order: map-route index for segment waypoints (1 = first segment after Start);
              ignored for START / END / WAIT_START
*/

params ["_kind", "_order"];

switch (_kind) do {
    case "START": { "Start" };
    case "WAIT_START": { "Start" };
    case "END": { "End" };
    case "CROSS_GATE": { str _order };
    case "HOVER_POINT": { format ["Hover at %1", _order] };
    case "LAND_POINT": { format ["Land %1", _order] };
    case "SLING_PICKUP": { format ["Sling pickup %1", _order] };
    case "SLING_DELIVER_CIRCLE";
    case "SLING_DELIVER_RECT": { format ["Sling deliver %1", _order] };
    case "DESTROY_TARGET": { format ["Destroy %1", _order] };
    case "DESTROY_INFANTRY": { format ["Destroy infantry %1", _order] };
    default { format ["WP %1", _order] };
};
