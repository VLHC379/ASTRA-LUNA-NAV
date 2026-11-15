# LUNA NAV — Lunar Landing Site Navigator

**NASA Space Apps Challenge 2026 · “Lunar Landing Site Navigator”**

> *Where to land. When to land. See the bigger picture.*

| | |
|---|---|
| **Team** | LUNA NAV — _add member names here_ |
| **Event** | _add local event / Universal Event_ |
| **Challenge** | [Lunar Landing Site Navigator](https://www.spaceappschallenge.org/2026/challenges/lunar-landing-site-navigator/) |
| **Stack** | Python 3.12 · FastAPI · SPICE · LOLA · vanilla JS · Three.js |
| **Licence** | MIT (code); data under NASA/PDS terms |

---

## The problem

At the Moon’s south pole the Sun never climbs more than about 1.6° above the
ideal horizon. A 300 m ridge 10 km away subtends 1.7°, so **terrain — not
latitude — decides whether a lander has power**. Earth is similarly low and
swings ±6.7° with libration, turning direct-to-Earth communication into a
terrain problem too.

Existing tools (QuickMap, Moon Trek, JPL Horizons) expose the data but not the
decision. LUNA NAV turns the same physics into a comparison surface: pick a
site, pick a date, see power and comm windows, and compare alternatives when
the schedule moves.

## What the judges can do in two minutes

1. Open the console at `http://127.0.0.1:8010`.
2. The **mission briefing** opens: choose a profile (Moon Base, Water-Ice
   Prospecting, Geological Survey), a landing site, and a time window.
3. Launch the console. The first-person view shows the real horizon, Apollo
   surface texture and the Apollo 17 Earth, with the Sun/Earth on their true arcs.
4. Watch the right-hand **Mission Advisor** screen the site against EC-01…EC-07,
   score it for the chosen profile, and recommend a site and window.
5. Press **Apply** to shift to the recommended site/window, then open **Compare**
   for the site × date matrix, trade space, best windows and A/B horizons.
6. Switch the lens to **Educator** or **Public** for a different framing.

## Feature checklist against the challenge objectives

| Objective | Where it lives |
|---|---|
| ASTRA key | One-screen 3D Moon and clickable south-pole points; no wizard, no dropdown required |
| Mission-specific decision model | Base: power/thermal/DTE · Ice: PSR ≤1.38 km · Geology: safety/stay/variety |
| Decision brief | Verdict (GO / CONDITIONAL / NO-GO), score, failing ECs, next plan and apply action |
| Plan tabs | Overview / Windows / Terrain / 3D orbit — one area at a time |
| Site dropdown | Jump to any site from the plan header, with the full map/POV updating |
| Public story mode | One full-screen visual, one paragraph, three numbers; no dashboard |
| Scenarios | Artemis scouting, commercial ice run, geology traverse — results only after Run |
| Grounded Q&A | Ask LUNA answers from the catalog, advisor and window search, with sources |
| Guide + formulas | Panel explanations, EC definitions and live curvature/incidence/score formulas |
| Mission-specific decision model | Base: power/thermal/DTE · Ice: PSR ≤1.38 km · Geology: safety/stay/variety |
| Engineering constraints | EC-01 slope, EC-02 roughness, EC-03 obstacles, EC-04 power, EC-05 DTE, EC-06 PSR, EC-07 stay |
| AI-style summary | Advisor narrative, risk level, recommendation, phase plan |
| Interactive site selection, curated list | 8 PGDA 5 m regions + Apollo 11, Chang’e 4, Chandrayaan-3, Mons Mouton |
| Custom lunar coordinates | Custom form; full terrain inside tiles, exact geometry elsewhere |
| Side-by-side / sequential comparison | Compare → Side-by-side (overlaid horizons, deltas) |
| Date and time flexibility | Date/time picker, 14 d / lunar day / 90 d windows, site × date matrix |
| Sun & Earth relative to the horizon | First-person view, Sun/Earth cards, horizon profile, sky dome |
| Power generation potential | Incidence-angle power, solar array readout, illumination raster |
| Direct-to-Earth windows | Earth visibility, link margin, timeline bands, best windows |
| Time before sunset / Earthset | Event strip (“Earthset in 128 h”, “Sunset in 302 h”) |
| Terrain extremes | Slope, roughness, annual illumination, Earth-LOS rasters |
| 3D site view | Real 5 m DEM mesh: drag to orbit, scroll to zoom, real Sun/Earth direction |
| Multiple visualizations | First-person view, map, sky dome, orrery, charts |
| Temporal dynamics | Play/scrub, lunar-day window, date matrix |
| Accessibility across skill levels | Planner / Educator / Public lens |
| No atmosphere, libration, ephemeris | Hard-shadow ray casting, libration readout, SPICE DE440 |
| Rapid replanning | Advisor re-run + matrix + best-window search + A/B deltas |

## Run it

**No server at all (recommended for a quick look)**

Double-click `LUNA-NAV.html`. It is a single 16 MB file with the console, the
precomputed cache, the map, rasters and imagery embedded. It opens from
`file://` in any modern browser and works offline.

**Windows**

```powershell
.\run.ps1
```

**macOS / Linux**

```bash
chmod +x run.sh
./run.sh
```

Both create a virtual environment, install `requirements.txt`, and start the
API plus console at <http://127.0.0.1:8010>. The precomputed cache is included,
so no DEM download or build step is needed.

**Static demo (no server logic):**

```bash
python -m http.server 8080 --directory dist
```

## Architecture

```
web/ (compiled) ──► FastAPI (lunanav/api.py) ──► lunanav/science.py
   app.min.js            │                         ├─ ephemeris.py  (SPICE DE440)
   app.min.css           │                         ├─ terrain.py    (horizon ray-march)
   three.min.js          │                         └─ layers.py     (rasters)
                         │
                    data/cache/  ◄── lunanav/build.py ◄── data/raw/ (LOLA 5 m DEMs)
```

* **Terrain** — 1,440 azimuths to 40 km, curvature `r²/2R`, 0.25° bins.
* **Ephemerides** — SPICE `MOON_ME_DE440_ME421`, light-time and aberration.
* **Visibility** — disk-resolved, not centre-only; solar-disk fraction and
  Earth-eclipse obscuration included.
* **Power** — beam × incidence; vertical tracking array is the polar default
  (a horizontal panel at 2° collects 3.5%).
* **Score** — `0.40 safeness + 0.30 power + 0.30 comm`, hard 10° slope gate.

## Data & provenance

* LOLA 5 m/px site DEMs — PGDA/NASA GSFC, Barker et al. 2021, P&SS 203, 105119.
* LOLA 80 m polar DEM — PDS LRO-L-LOLA-4-GDR.
* SPICE kernels — NAIF/JPL (DE440s, lunar PCK/FK).
* Validation — LOLA `AVGVISIB_85S_060M_201608` (Mazarico et al. 2011).
* Artemis candidate regions — NASA.

## Validation

Across the eight terrain-backed sites, annual illumination agrees with the
published LOLA average-visibility map at **+4.2 pp bias / 11.1 pp RMS**;
Earth visibility at **−5.6 pp / 16.0 pp** (libration-sensitive). The Data view
shows the full per-site table and the reasons for divergence.

## Known limits

* 5 m DEMs cover 16 × 16 km per region; far-field horizon uses 80 m terrain.
* Analysis rasters use a 48 × 48 horizon grid (≈330 m cells).
* Boulder-scale hazards are below DEM resolution; roughness is a proxy.
* Reference sites have no 5 m DEM: exact geometry, spherical horizon, and are
  excluded from the ranking.
* Link budget is an illustrative X-band planning index, not flight-certified.

## Two-minute demo script

| Time | Beat |
|---|---|
| 0:00 | The 1.6° problem: a ridge decides power; Earth hides behind the same ridge |
| 0:15 | Briefing: choose Moon Base, Malapert, 14 days |
| 0:35 | First-person view: real horizon, Apollo surface, Earth on its true arc |
| 0:55 | Advisor: EC-05 fails, risk MEDIUM, recommend Leibnitz + window |
| 1:15 | Apply recommendation, then Compare: matrix flips a site from 20% to 96% |
| 1:40 | Validation and honest limits |

## Repository map

```
lunanav/      backend (API + science + build pipeline)
web/          compiled console (app.min.js, app.min.css, vendor)
LUNA-NAV.html single-file console (no server, no network)
data/cache/   precomputed horizons, rasters, catalog
dist/         static demo build
docs/         method, validation, screenshots
tests/        18 pytest checks
scripts/      data fetch, validation, frontend build
```

## Licence

Code MIT. Data remains under the terms of NASA/PDS and the cited authors.
