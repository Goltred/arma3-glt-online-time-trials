# Online Time Trials

Mission maker and player documentation for the **Online Time Trials** Arma 3 mod (GLT). Paste this page into the GitHub Wiki as **Home** (or split into subpages if you prefer).

---

## What this mod does

Online Time Trials lets mission makers place timed trials in any scenario (single player or multiplayer). Each trial is a course built from ordered **segment waypoints** (gates, hovers, sling loads, destroy targets, and more) that need to be completed in order, recording the total time taken on it. Pilots get in a vehicle, pick a trial, and the server tracks their run with timing, HUD feedback, and optional leaderboard persistence.

## Requirements

- **Community Base Addons ([CBA_A3](https://steamcommunity.com/workshop/filedetails/?id=450814997))** — used for the default keyboard shortcut to open the trial menu.

![Mod overview](https://raw.githubusercontent.com/Goltred/arma3-glt-online-time-trials/refs/heads/main/steam/Hero.png)

## Creating a trial (overview)

In the Eden editor, open **Empty → Online Time Trials** (and subfolders for config, trials, segments, terminals).

- Place one **Trial Definition** object (`GLT_Trials_TrialMeta`) per course. This is required for registration.
- Set the Trial Definition **Trial Id** (unique per course on the map), **Trial Name**, and optional vehicle filters (**Allowed Vehicle Classes** + heli/plane/ground/ship checkboxes).
- Place segment modules (gates, hovers, sling, destroy, etc.) and set each segment **Segment Index** (ascending order).
- In Eden, **connect/sync each segment to the Trial Definition**. Trials are built from the Trial Definition's synchronized objects.
- Optionally place the **Master** object to control leaderboard persistence (profile vs reset each mission).
- Optionally place **Terminal** objects for a “Time Trials Terminal” screen (live runs / leaderboard) in-game.

**Important:** Trial Definition helpers are editor/config objects and are automatically removed when the mission starts. That is expected.

![Eden editor placement](https://raw.githubusercontent.com/Goltred/arma3-glt-online-time-trials/refs/heads/main/steam/Eden.png)

## Defining the start and end of a trial

The first segment of a trial (ordered using Segment Index in ascending order) is considered the first waypoint of the course and will be considered the **start** of the trial. This allows you to set any of the current segments as the actual beginning of the challenge, so you can start a course from different states (landed, flying, hover, etc.). Once a trial starts, indications towards the first waypoint will be provided and the timer will commence as soon as that waypoint has been completed.

The last segment of a trial (also ordered by Segment Index) will be considered the **end** waypoint. This allows you to stop the timer using whichever segment of the course you choose.

## Segments — what each type does

Each segment shares: **Segment Index** (order). Segments are assigned to a course by being synchronized to that course's **Trial Definition**. **Destroy** segments can be marked **Optional obstacle only** — they spawn for the run but do not count as a waypoint and despawn when the run ends.

### Cross Gate

Fly through a vertical gate plane. Tuned with **Gate Radius** (horizontal) and **Plane Cross Tolerance** (how close you must be to the gate plane along its forward axis).

### Hover Point

Stay inside the hover zone for a set time while respecting altitude and (by default) hover. Attributes include **Alt Min / Alt Max** (m above the marker), **Hover Duration** (seconds), **Extra horizontal radius** (m, added to the placed helper), and optional **helper light** fade distances (full strength vs dimmest as you approach).

### Land Point

Land within **Land Radius** and remain on the ground for **Stay Duration** (seconds).

### Sling Pickup

Pick up sling cargo: set the **Cargo class** (`CfgVehicles` classname spawned for the load). The framework ensures the cargo exists for the run.

### Sling Deliver (Circle)

Deliver the load on the ground inside a **Delivery Radius** (circle). Visual cones mark the zone.

### Sling Deliver (Rectangle)

Deliver inside a rectangle aligned to the object: **Half Width** and **Half Length** (meters from center along the helper’s axes). Optional **corner light** fade distances behave like the hover helper lights.

### Destroy Target

Destroy a spawned **Vehicle** target. Options: **Spawn driver**, **Spawn gunner / commander**, **Crew side**, **Crew skill**. Can be **Optional obstacle only**.

### Destroy Infantry

Destroy a spawned infantry **squad**: **Infantry class** (must be a Man class), **Unit count**, **Squad skill**. Can be **Optional obstacle only**.

![In-game hints](https://raw.githubusercontent.com/Goltred/arma3-glt-online-time-trials/refs/heads/main/steam/Hints.png)

## Limiting which vehicles can enter a trial

On the **Trial Definition**, use **Allowed Vehicle Classes (comma-separated)** and the vehicle category checkboxes.

- **Leave Allowed Vehicle Classes empty** — category checkboxes control eligibility.
- **List classnames** — e.g. `B_Heli_Transport_01_F,B_Heli_Light_01_F` — only those classes are eligible.
- **Categories** are *Helicopter / Plane / Ground / Ship*. If no category is configured yet, default behavior is helicopter-focused.

## How the player starts a trial

- Get in an **eligible vehicle** as **driver/pilot**.
- Press **Shift + T** (CBA keybind: “Time Trials - Select Trial”) to open the trial list, choose a trial, confirm with **OK**.
- Near a placed **Terminal**, use the scroll action **Time Trials Terminal** for live/leaderboard views (separate from starting a run in the heli).

If nothing appears: wait until trials have synced from the server; you must be **driver/pilot** of an eligible vehicle; and your vehicle must match that trial's category/class filters.

## Why a trial may not appear (quick checklist)

- A **Trial Definition** object exists and has a non-empty **Trial Id**.
- Every segment intended for that trial is **synchronized to that Trial Definition**.
- Segments have valid **Segment Index** values (ordered, no accidental duplicates).
- Trial Id is **unique** per course on the map.
- Your current vehicle matches both the **category** filter and (if set) **Allowed Vehicle Classes**.
- You are in the correct seat for start flow (pilot/driver), then open the selector.

![Trial selection](https://raw.githubusercontent.com/Goltred/arma3-glt-online-time-trials/refs/heads/main/steam/Selection.png)

## UI you will see during a run

- **Trial selector dialog** — lists eligible trials by name; **OK** starts the selected run, **Cancel** closes.
- **HUD / Draw3D** — timer and guidance while a run is active (driven by the client draw loop).
- **Hover progress** — progress UI while completing a hover segment (progress bar / text in the HUD layer).
- **Sling delivery HUD** — feedback while delivering in circle or rectangle zones.
- **Course helpers** — gates, smoke, lights, and 3D/route hints tied to the active segment (visibility is managed during the run).
- **Terminal UI** — structured screen with **Live** vs **Leaderboard** style views when using a placed terminal (if the mission includes one).

![UI during a run](https://raw.githubusercontent.com/Goltred/arma3-glt-online-time-trials/refs/heads/main/steam/UI.png)

## Tips for mission makers

- Use a unique **Trial Id** per course; duplicate ids on the same map will conflict.
- Segment order is **Segment Index** ascending — gaps are fine, but duplicates for the same trial can behave unpredictably.
- Registration is driven by **Trial Definition sync links**; check that all your segments are linked to the appropriate Trial Definition.
- Start/End zones support **Touch Method** and **Touch Padding** on the Eden objects for tighter or looser hull checks (see tooltips in Eden).
- To share only the trial layout between missions, use Eden **custom compositions** or copy the mod’s helper objects between missions on the same terrain.

---

**Author:** Goltred (Online Time Trials / GLT)
