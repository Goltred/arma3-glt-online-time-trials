/*
    GLT_Trials_fnc_openTrialMenu
    Client-side trial selection UI (non-modal display on mission display 46).
    Params: [_vehicle, _eligibleTrials, _activeRow]
        _vehicle: helicopter object
        _eligibleTrials: array of [trialId, trialName]
        _activeRow: optional public HUD row (see tickServer); non-empty => in-trial layout
*/

params ["_vehicle", "_eligible", ["_activeRow", []]];
if (!hasInterface) exitWith {};
if (isNull _vehicle) exitWith {};
if (isNil "_eligible") exitWith {};

private _activeMode = (count _activeRow) > 0;
if (!_activeMode && { count _eligible isEqualTo 0 }) exitWith {};

// createDialog blocks player movement; createDisplay on 46 does not (BIKI createDisplay / GUI Tutorial).
private _parent = findDisplay 46;
if (isNull _parent) exitWith {
    hintSilent "Time Trials: trial menu needs the in-game display (try again from the mission).";
};
private _prev = findDisplay 88000;
if (!isNull _prev) then { _prev closeDisplay 0; };

missionNamespace setVariable ["GLT_Trials_trialVehicle", _vehicle];
missionNamespace setVariable ["GLT_Trials_trialEligible", _eligible];
missionNamespace setVariable ["GLT_Trials_trialMenuActiveRow", if (_activeMode) then { +_activeRow } else { [] }];

private _disp = _parent createDisplay "RscDisplayGLT_Trials_Selector";
if (isNull _disp) exitWith {
    hintSilent "Time Trials: could not open trial menu.";
};

private _ctrlBackdrop = _disp displayCtrl 1010;
private _ctrlTitle = _disp displayCtrl 1000;
private _ctrlSummary = _disp displayCtrl 1001;
private _ctrlList = _disp displayCtrl 1500;
private _ctrlOk = _disp displayCtrl 1600;
private _ctrlStop = _disp displayCtrl 1602;

_ctrlBackdrop ctrlShow true;

if (_activeMode) then {
    private _trialName = _activeRow param [5, "Trial"];
    private _segmentDesc = _activeRow param [6, ""];
    private _elapsed = _activeRow param [7, 0];
    if (!(_elapsed isEqualType 0)) then { _elapsed = parseNumber (str _elapsed); };
    if (_elapsed < 0) then { _elapsed = 0; };
    private _elapsedStr = [_elapsed] call BIS_fnc_secondsToString;
    private _body = format [
        "<t size='1' color='#00e5ff'>%1</t><br/><t size='0.85' color='#d0d0d0'>%2</t><br/><t size='0.9' color='#e8e8e8'>Elapsed: %3</t>",
        _trialName,
        _segmentDesc,
        _elapsedStr
    ];
    _ctrlTitle ctrlSetText format ["Trials — Active Run: %1", _trialName];
    _ctrlSummary ctrlSetStructuredText parseText _body;
    _ctrlSummary ctrlShow true;
    _ctrlList ctrlShow false;
    _ctrlList ctrlEnable false;
    _ctrlOk ctrlShow false;
    _ctrlOk ctrlEnable false;
    _ctrlStop ctrlShow true;
    _ctrlStop ctrlEnable true;
} else {
    _ctrlTitle ctrlSetText "Trials";
    _ctrlSummary ctrlSetStructuredText parseText "";
    _ctrlSummary ctrlShow false;
    _ctrlList ctrlShow true;
    _ctrlList ctrlEnable true;
    _ctrlOk ctrlShow true;
    _ctrlOk ctrlEnable true;
    _ctrlStop ctrlShow false;
    _ctrlStop ctrlEnable false;
    lbClear _ctrlList;
    {
        private _trialId = _x select 0;
        private _trialName = _x select 1;
        private _idx = _ctrlList lbAdd _trialName;
        _ctrlList lbSetData [_idx, _trialId];
    } forEach _eligible;
};
