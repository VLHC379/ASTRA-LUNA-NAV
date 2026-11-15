# LUNA NAV — code review notes

This is the source for the v6 console. It is the same code that produced
`LUNA-NAV.html` and the submission bundle.

## Start here

| File | What it does |
|---|---|
| `lunanav/config.py` | 12 sites, constants, scoring weights |
| `lunanav/terrain.py` | DEM loading and 1,440-azimuth horizon ray-march |
| `lunanav/ephemeris.py` | SPICE wrapper (Sun/Earth, libration, eclipse) |
| `lunanav/science.py` | state, timeline, power, comms, windows, score |
| `lunanav/advisor.py` | mission profiles, EC checks, verdict/recommendation |
| `lunanav/api.py` | FastAPI routes |
| `lunanav/build.py` | offline cache builder |
| `web/js/app.js` | console controller, tabs, public mode, scenarios, guide |
| `web/js/globe.js` | ASTRA one-screen 3D Moon landing key + clickable polar map |
| `web/js/pov.js` | first-person renderer |
| `web/js/scene.js` | DEM 3D site mesh + Sun/Earth/Moon orrery |
| `web/js/advisor.js` | advisor panel |
| `web/js/ask.js` | grounded Q&A intent router |
| `web/js/wizard.js` | three-step briefing |
| `scripts/build_singlefile.py` | builds the one-file HTML |
| `lunanav/export_static.py` | builds `dist/` and the static data |

## Run

```powershell
py -3.12 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\run.ps1
```

The cache is not included in this source zip; run `scripts/fetch_data.py` and
`python -m lunanav.build --all`, or use the full submission zip which includes
`data/cache`.

## What changed in v6

- Three-second hero and readable wizard type.
- Left rail restored; site dropdown in the plan header.
- Plan tabs: Overview / Windows / Terrain / 3D orbit.
- Advisor verdict (GO / CONDITIONAL / NO-GO), collapsed EC table, next plan.
- Public story mode (lens selector), scenarios, guide with formulas.
- Grounded Ask LUNA, no LLM, tool/data-backed.
- 3D site view from the real 5 m DEM (`scene.js` terrain mesh + orbit camera).

## Known limits

- 8 terrain-backed sites + 4 reference sites.
- Map is a LOLA hillshade; LROC 6082 mosaic was rate-limited.
- POV is a 2D projection of the measured horizon, not a full 3D mesh; the
  Terrain tab has the real 3D DEM mesh.
- Advisor is deterministic; Ask is an intent router, not a language model.
- Single-file demo fixes the date to 21 June 2030 and cannot evaluate custom
  coordinates; the server version can.

## Data

- LOLA 5 m DEMs: PGDA/NASA GSFC.
- SPICE kernels: NAIF/JPL.
- Imagery: Apollo 11 panorama (NASA/JSC), Apollo 17 Blue Marble (NASA),
  Clementine south-polar mosaic (NASA/JPL/USGS).
