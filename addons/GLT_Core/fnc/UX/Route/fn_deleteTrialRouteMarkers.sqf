/*
    GLT_Trials_fnc_deleteTrialRouteMarkers
    Client: remove all local route waypoint markers for this player.
*/

if (!hasInterface) exitWith {};

private _uid = getPlayerUID player;
for "_i" from 0 to 63 do {
    private _m = format ["GLT_Trials_wp_%1_%2", _uid, _i];
    if (_m in allMapMarkers) then { deleteMarkerLocal _m };
};

true
