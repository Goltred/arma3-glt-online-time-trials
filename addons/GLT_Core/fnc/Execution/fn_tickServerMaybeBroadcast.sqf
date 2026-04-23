/*
    GLT_Trials_fnc_tickServerMaybeBroadcast
    Server: throttled publicVariable for active/recent run HUD tables.
    Params: [_now, _broadcastInterval]
*/

params ["_now", "_broadcastInterval"];

if ((_now - GLT_Trials_lastBroadcastTime) >= _broadcastInterval) then {
    publicVariable "GLT_Trials_activeRunsPublic";
    if (GLT_Trials_recentRunsDirty) then {
        publicVariable "GLT_Trials_recentRunsPublic";
        GLT_Trials_recentRunsDirty = false;
    };
    GLT_Trials_lastBroadcastTime = _now;
};
