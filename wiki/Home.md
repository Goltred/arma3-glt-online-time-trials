# Online Time Trials

Documentation for the **Online Time Trials** Arma 3 mod (GLT): mission setup in Eden, segment types, player controls, and troubleshooting.

## Contents

- [What this mod does](#what-this-mod-does)
- [Requirements](#requirements)
- [Creating a trial](#creating-a-trial)
- [Start and end of a trial](#start-and-end-of-a-trial)
- [Segment types](#segment-types)
- [Vehicle filters](#vehicle-filters)
- [How players start a trial](#how-players-start-a-trial)
- [Troubleshooting checklist](#troubleshooting-checklist)
- [In-game UI](#in-game-ui)
- [Tips for mission makers](#tips-for-mission-makers)

---

## What this mod does

Online Time Trials lets mission makers place timed trials in any scenario (single player or multiplayer). Each trial is a course built from ordered **segment waypoints** (gates, hovers, sling loads, destroy targets, and more), completed in sequence while the mod records total time. Pilots enter an eligible vehicle, select a trial, and the server tracks the run with timing, HUD feedback, and optional leaderboard persistence.

## Requirements

| Dependency | Notes |
|------------|--------|
| [CBA_A3](https://steamcommunity.com/workshop/filedetails/?id=450814997) | Default keybind to open the trial menu |

![Mod overview](https://raw.githubusercontent.com/Goltred/arma3-glt-online-time-trials/refs/heads/main/steam/Hero.png)

## Creating a trial

In **Eden**: `Empty` → **Online Time Trials** (subfolders: config, trials, segments, terminals).

1. Place one **Trial Definition** (`GLT_Trials_TrialMeta`) per course (required for registration).
2. On the definition: set **Trial Id** (unique on the map), **Trial Name**, and optional **Allowed Vehicle Classes** / category checkboxes.
3. Place segment modules; set **Segment Index** in ascending order.
4. **Sync each segment** to its **Trial Definition** (trials are built from that object’s synchronized segments).
5. Optional: **Master** (leaderboard persistence: profile vs per-mission reset).
6. Optional: **Terminal** objects (in-game “Time Trials Terminal”: live runs / leaderboard).

> **Important:** Trial Definition objects are editor helpers. They are removed when the mission starts; that is expected.

![Eden editor placement](https://raw.githubusercontent.com/Goltred/arma3-glt-online-time-trials/refs/heads/main/steam/Eden.png)

## Start and end of a trial

| Concept | Behavior |
|---------|----------|
| **Start** | The segment with the **lowest Segment Index** is the first waypoint. The timer starts after that segment is completed. |
| **End** | The segment with the **highest Segment Index** is the last waypoint; finishing it stops the timer. |

You can choose which segment types sit at the start and end (e.g. landed vs in-flight start).

## Segment types

Shared behavior:

- Each segment has a **Segment Index** (order).
- Assignment to a course is by **sync to the Trial Definition**.
- **Destroy** segments can be **Optional obstacle only**: they appear for the run, do **not** count as waypoints, and despawn when the run ends.

### Reference

| Type | Purpose |
|------|---------|
| **Cross Gate** | Fly through a vertical gate plane. Tune **Gate Radius** and **Plane Cross Tolerance**. |
| **Hover Point** | Hold position in zone for **Hover Duration**. **Alt Min / Alt Max**, **Extra horizontal radius**, optional helper light fade distances. |
| **Land Point** | Land inside **Land Radius**; stay down for **Stay Duration**. |
| **Sling Pickup** | Pick up cargo; **Cargo class** is a `CfgVehicles` classname (spawned for the run). |
| **Sling Deliver (Circle)** | Ground delivery inside **Delivery Radius** (cones mark the zone). |
| **Sling Deliver (Rectangle)** | Delivery in a rectangle: **Half Width**, **Half Length**; optional **corner light** fades (like hover). |
| **Destroy Target** | Destroy a spawned **Vehicle**. Options: crew spawn, sides, skill. Can be **Optional obstacle only**. |
| **Destroy Infantry** | Destroy a spawned **squad** (**Infantry class**, **Unit count**, **Squad skill**). Can be **Optional obstacle only**. |

![In-game hints](https://raw.githubusercontent.com/Goltred/arma3-glt-online-time-trials/refs/heads/main/steam/Hints.png)

## Vehicle filters

On the **Trial Definition**:

| Configuration | Effect |
|----------------|--------|
| **Allowed Vehicle Classes** empty | Category checkboxes (heli / plane / ground / ship) control eligibility. |
| **Allowed Vehicle Classes** set | Comma-separated classnames only, e.g. `B_Heli_Transport_01_F,B_Heli_Light_01_F`. |
| **Categories** | *Helicopter*, *Plane*, *Ground*, *Ship*. If none set yet, behavior defaults toward helicopters. |

## How players start a trial

1. Enter an **eligible** vehicle as **driver / pilot**.
2. Press **`Shift + T`** (CBA: **Time Trials - Select Trial**), pick a trial, **OK** to start.
3. Near a **Terminal**: scroll action **Time Trials Terminal** for live view / leaderboard (separate from starting a run from the aircraft).

If the menu is empty: wait for server sync; confirm seat role; confirm the vehicle matches that trial’s category and class filters.

## Troubleshooting checklist

- [ ] **Trial Definition** present with non-empty **Trial Id**.
- [ ] Every segment **synced** to the correct **Trial Definition**.
- [ ] **Segment Index** values valid (ordered; avoid accidental duplicates).
- [ ] **Trial Id** unique per course on the map.
- [ ] Vehicle matches **category** and (if set) **Allowed Vehicle Classes**.
- [ ] Player is **pilot/driver** before opening the selector.

![Trial selection](https://raw.githubusercontent.com/Goltred/arma3-glt-online-time-trials/refs/heads/main/steam/Selection.png)

## In-game UI

| Element | Role |
|---------|------|
| **Trial selector** | Lists eligible trials; **OK** starts run, **Cancel** closes. |
| **HUD / Draw3D** | Timer and guidance while a run is active. |
| **Hover progress** | Progress for hover segments (bar / text). |
| **Sling delivery HUD** | Feedback in circle or rectangle delivery zones. |
| **Course helpers** | Gates, smoke, lights, 3D hints for the active segment. |
| **Terminal UI** | **Live** vs **Leaderboard** views when a terminal is in the mission. |

![UI during a run](https://raw.githubusercontent.com/Goltred/arma3-glt-online-time-trials/refs/heads/main/steam/UI.png)

## Tips for mission makers

- One unique **Trial Id** per course on the map.
- Order segments with **Segment Index** ascending; gaps are OK, duplicates on the same trial are risky.
- Registration follows **Trial Definition** sync links—verify every segment is linked.
- **Touch Method** and **Touch Padding** on Eden objects tighten or loosen hull checks (see Eden tooltips).
- Reuse layouts with Eden **custom compositions** or by copying helper objects between missions on the same terrain.

---

*Author: Goltred (Online Time Trials / GLT)*
