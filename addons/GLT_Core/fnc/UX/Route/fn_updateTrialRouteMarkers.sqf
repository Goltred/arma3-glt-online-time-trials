/*
    GLT_Trials_fnc_updateTrialRouteMarkers
    Client: draw full trial route on the map.
    Params: [_route, _activeIndex]
      _route: [[kind, pos], ...] — kind is "START", "END", or segment type (e.g. CROSS_GATE)
      _activeIndex: highlighted waypoint (green scale 1); others black scale 0.5
*/

params ["_route", "_activeIndex"];

if (!hasInterface) exitWith {};
if (!(_route isEqualType []) || { (count _route) isEqualTo 0 }) exitWith {};

private _uid = getPlayerUID player;
private _n = count _route;

if (_activeIndex < 0) then { _activeIndex = 0 };
if (_activeIndex >= _n) then { _activeIndex = _n - 1 };

{
    private _i = _forEachIndex;
    private _mName = format ["GLT_Trials_wp_%1_%2", _uid, _i];
    _x params ["_kind", "_pos"];
    if ((_pos isEqualType []) && { (count _pos) >= 3 }) then {
        if (!(_mName in allMapMarkers)) then {
            createMarkerLocal [_mName, _pos];
        };
        _mName setMarkerPosLocal _pos;

        private _shape = switch (_kind) do {
            case "START": { "hd_start_noShadow" };
            case "END": { "hd_end_noShadow" };
            case "HOVER_POINT": { "selector_selectable" };
            case "LAND_POINT": { "hd_pickup_noShadow" };
            case "SLING_PICKUP": { "hd_pickup_noShadow" };
            case "SLING_DELIVER_CIRCLE";
            case "SLING_DELIVER_RECT": { "hd_destroy_noShadow" };
            case "DESTROY_TARGET": { "hd_destroy_noShadow" };
            case "DESTROY_INFANTRY": { "hd_destroy_noShadow" };
            default { "hd_destroy_noShadow" };
        };
        _mName setMarkerTypeLocal _shape;

        private _isActive = _i isEqualTo _activeIndex;
        if (_isActive) then {
            _mName setMarkerColorLocal "ColorGreen";
            _mName setMarkerSizeLocal [1, 1];
        } else {
            _mName setMarkerColorLocal "ColorBlack";
            _mName setMarkerSizeLocal [0.5, 0.5];
        };

        // Map labels: _i is 0-based segment index (same as server segmentIndex / HUD wpIndex); labels are 1-based in segmentWaypointLabel.
        private _text = [_kind, _i] call GLT_Trials_fnc_segmentWaypointLabel;
        _mName setMarkerTextLocal _text;
    };
} forEach _route;

// Remove leftover markers from a longer previous route
for "_j" from _n to 63 do {
    private _m = format ["GLT_Trials_wp_%1_%2", _uid, _j];
    if (_m in allMapMarkers) then { deleteMarkerLocal _m };
};

true
