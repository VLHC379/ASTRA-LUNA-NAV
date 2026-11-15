# LUNA NAV — Lunar Landing Site Navigator

**NASA Space Apps Challenge 2026 · “Lunar Landing Site Navigator”**

> Missions to the Moon’s south pole face extreme lighting and communication constraints… create an intuitive tool that lets mission planners, educators, and the public compare landing sites and dates quickly, visualising Sun and Earth positions relative to the horizon.

LUNA NAV is that tool: a decision console over **eight terrain-backed south-pole regions and four reference sites** (Apollo 11, Chang’e 4, Chandrayaan-3, Mons Mouton), built on real 5 m LOLA terrain and SPICE ephemerides. Pick a site, pick a date, and see — in one screen — whether the Sun clears the ridge, whether Earth clears it, and what that does to power and direct-to-Earth comms.

![Plan view](docs/screenshots/plan.png)

---

## Quick start (Windows)

```powershell
py -3.12 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\run.ps1
```

`run.ps1` starts the API and opens <http://127.0.0.1:8010>. If `data/cache/` is missing it will tell you to build it first:

**No server at all:** double-click **`LUNA-NAV.html`**. It is a single 16 MB file with the console, cache, map, rasters and imagery embedded; it runs from `file://` offline.

```powershell
.\.venv\Scripts\python.exe scripts\fetch_data.py      # ~420 MB of DEMs + kernels
.\.venv\Scripts\python.exe -m lunanav.build --all     # ~4 minutes, writes data/cache
```

The repository ships with a built cache, so the first command is only needed on a fresh clone.

### Other commands

```powershell
# rebuild one site (after changing a threshold or the point-selection logic)
python -m lunanav.build --site malapert-massif

# tests
python -m pytest

# static demo bundle (no server; fixed 21 June 2030 window)
python -m lunanav.export_static
python -m http.server 8080 --directory dist
```

---

## The brief

The console opens with a three-step wizard — **mission profile → landing site → time window** — and only reveals the data once the brief is set. The profile changes the decision model:

| Profile | Priorities | Comms |
|---|---|---|
| Moon Base Construction | continuous power, stable thermal, reliable DTE | required |
| Water-Ice Prospecting | PSR within 1.38 km, power at the site | not required |
| Geological Survey | safe terrain, surface stay, varied units | secondary |

The right-hand **Mission Advisor** screens seven engineering constraints, scores 0–100 for the chosen profile, names the best alternative site and the best surface-stay window, and writes a phase plan. A first-person view uses the real horizon as a terrain silhouette, an Apollo 11 surface panorama as ground, and the Apollo 17 Blue Marble as Earth — with Sun and Earth on their true azimuth/elevation arcs.

## What you are looking at

| Panel | What it answers |
|---|---|
| **Lunar South Pole Map** | Where the terrain-backed regions sit, with an edge pointer for off-map reference sites |
| **Selected site / horizon profile** | What the skyline looks like from the candidate point, 0–360° |
| **Surface panorama** | The horizon profile drawn as a skyline, with Sun and Earth at their true azimuth/elevation — including “behind the ridge” states |
| **Sun & Earth position** | Azimuth, elevation, range, disk-visible fraction and link state at the selected instant |
| **Local sky view** | The 24-hour track of both bodies against the terrain silhouette |
| **Sun · Earth · Moon** | The three-body geometry, with Earth rotating on a 23.44°-tilted axis and the Moon on a 5.15°-inclined orbit |
| **Visibility timeline** | 14 days × 24 h of “sun / Earth / both / neither”, one row per day |
| **Illumination & terrain** | Modelled annual illumination, Horn slope, Earth line-of-sight, roughness |
| **Site comparison** | Sun %, Earth %, joint %, score and assessment for every site on the same date |
| **First-person view** | Eye-level panorama with real terrain silhouette, Apollo surface texture and a real Earth image; Sun / Earth / North / Split headings; drag to look, scroll to zoom |
| **3D site view** | Real 5 m DEM mesh in the Terrain tab; drag to orbit, scroll to zoom, real Sun/Earth directions |
| **Plan tabs** | Overview / Windows / Terrain / 3D orbit — one workspace at a time, with collapsible EC table |
| **Site dropdown** | Jump to any of the 12 sites from the plan header, without leaving the visual |
| **ASTRA landing key** | One screen: 3D Moon + clickable south-pole points; no wizard, no site dropdown required |
| **ASTRA profiles** | Base / Ice / Geology chips before entry, switchable again in the console |
| **Public story mode** | Lens → General public: one full-screen visual, one paragraph, three numbers, plus a sunniest-site challenge |
| **Scenarios** | Artemis scouting, commercial ice run, geology traverse; results appear only after Run |
| **Ask LUNA** | Grounded Q&A over the site catalog, advisor and window search; answers cite their source |
| **Guide** | Panel explanations, EC definitions, live formulas and honest limits |
| **Focus mode** | After the briefing only the map, POV, advisor and timeline remain; one click restores the rail |
| **3D orbit** | Full-screen Sun/Earth/Moon modal: drag to orbit, scroll to zoom, focus Moon/Earth |
| **Mission advisor** | Profile-aware EC screening, risk, recommendation and phase plan |
| **Side-by-side** | Overlay two horizons and compare sun, Earth, joint windows and score with deltas |
| **Event strip** | Time remaining to the next sunrise/sunset and Earthrise/Earthset |
| **Window picker** | 14 days, one lunar day (29.5 d) or 90 days of visibility |
| **Audience lens** | A one-line brief and a shortcut that changes the console’s framing for planners, educators or the public |

Views: **Plan** (workflow), **Compare** (site × date matrix, trade space, best windows), **Analysis** (layer deep-dive, site facts, 24 h track), **Data** (provenance, API, validation), **About** (method, limits, challenge).

The **Lens** selector changes the explanatory text for mission planners, educators or the general public.

---

## Method (short version)

1. **Terrain.** PGDA 5 m/px LOLA DEMs (Barker et al. 2021) are combined with the 80 m polar DEM for far-field terrain. From each candidate point we march 1,440 azimuths out to 40 km and record the maximum elevation angle, applying lunar curvature `drop = r² / 2R` (719 m at 50 km). The result is a 0.25°-resolution horizon mask.
2. **Point selection.** Each published 16 × 16 km ROI is sampled on a 12 × 12 grid; the six best candidates by coarse illumination are re-scored with the full 1,440-bin horizon, subject to a 10° slope gate.
3. **Ephemerides.** SPICE DE440s with the `MOON_ME_DE440_ME421` frame, light-time and aberration corrected. Azimuth is from north, clockwise; elevation is above the local terrain horizon.
4. **Visibility.** A body is visible when its **disk** clears the terrain, not merely its centre. Illumination integrates the visible fraction of the solar disk, and Earth occultation of the Sun is handled as a separate eclipse term.
5. **Power.** Beam irradiance × incidence angle. A horizontal panel at 2° solar elevation collects `sin(2°) ≈ 3.5%` of the beam; a vertical tracking array collects ≈100%. The default index is a vertical tracking 1 m² array at 28% cell efficiency.
6. **Comm.** Direct-to-Earth requires the Earth disk to clear the terrain; the link budget is an explicitly illustrative X-band calculation (5 W, 0.3 m lander antenna, 34 m ground station).
7. **Score.** `0.40 × safeness + 0.30 × power + 0.30 × comm`, with safeness = 0.5 slope + 0.3 PSR access + 0.2 roughness and a hard 10° slope gate. Weights are visible in `lunanav/config.py` and returned by the API.

### Accuracy and validation

| Check | Result |
|---|---|
| SPICE frame resolution | `MOON_ME_DE440_ME421` = 31009, kernels load cleanly |
| Solar elevation at 89.9°S | stays inside ±1.75° over a full year (physics bound: ±1.54° plus libration) |
| Earth elevation | ±6.7° libration reproduced; ±10.8° at 86°S as geometry requires |
| Horizon vs analytic cliff | within 1.2° (bilinear edge smearing), plane test exact |
| Annual illumination vs LOLA `AVGVISIB_85S_060M` | bias **+4.2 pp**, RMS **11.1 pp** across the eight terrain-backed sites |
| Annual Earth visibility vs the same product | bias **−5.6 pp**, RMS **16.0 pp** (libration-sensitive) |

The last row is deliberately honest: the published map averages 2009–2013 at 60 m, while LUNA NAV integrates a single year at 5 m for a specific point. Differences are expected and discussed in the Data view.

### Known limitations

- The 5 m DEMs cover 16 × 16 km per region; beyond the tile edge the horizon uses 80 m terrain.
- The analysis rasters are computed on a 48 × 48 horizon grid (≈330 m cells) with 16 azimuth bins — good for comparison, not for certifying a touchdown ellipse.
- Boulder-scale hazards are below DEM resolution; roughness is an RMS proxy only.
- The link budget is a planning index, not a flight link budget.
- The Analysis rasters are annual/epoch products; the 24-hour sky track follows the selected time, but the raster itself does not.\n- The four reference sites (Apollo 11, Chang’e 4, Chandrayaan-3, Mons Mouton) have no 5 m DEM in this dataset: their Sun/Earth geometry is exact but their horizon is spherical, and they are excluded from the ranking.
- A fixed “representative point” is used per region; real missions will re-run the analysis for their own coordinates (the API supports this).

---

## API

Interactive docs: <http://127.0.0.1:8010/docs>

| Method | Path | Returns |
|---|---|---|
| GET | `/api/meta` | provenance, kernels, defaults, units |
| GET | `/api/sites` | 12-site catalog (8 terrain-backed, 4 reference) |
| GET | `/api/sites/{id}` | horizon, stats, layers, terrain metadata |
| GET | `/api/sites/{id}/state?at=` | Sun/Earth geometry, power, link |
| GET | `/api/sites/{id}/timeline?start=&hours=&step_min=` | series, summary, windows |
| GET | `/api/sites/{id}/sky?at=` | 24 h Sun/Earth tracks + horizon |
| GET | `/api/sites/{id}/best-windows?days=&span_days=` | best surface-stay windows |
| GET | `/api/sites/{id}/layers/{name}.png` | illumination, slope, los, roughness, hillshade, thumb |
| GET | `/api/sites/{id}/export.csv` | timeline as CSV |
| GET | `/api/validation` | modelled vs published LOLA visibility, per site |
| GET | `/api/compare?at=&days=` | decision table |
| GET | `/api/matrix?start=&count=&step_days=` | site × date matrix |
| POST | `/api/custom` | evaluate `{lat, lon}` inside a 5 m tile |

All responses are JSON except the PNG and CSV endpoints. A static bundle (`python -m lunanav.export_static`) reproduces the console without a server for the default window.

---

## Repository layout

```
lunanav/
  config.py        sites, constants, weights, provenance
  frames.py        polar stereographic + ENU
  ephemeris.py     SPICE Sun/Earth, libration, eclipse
  terrain.py       DEM sampling, horizon ray-march, slope, hillshade
  science.py       visibility, power, comm, timelines, scoring
  layers.py        analysis rasters + PNG rendering
  build.py         offline cache builder
  api.py           FastAPI service
  export_static.py static demo bundle
web/               console (vanilla JS + Three.js for the orrery)
scripts/           fetch_data, validation, QA screenshots
tests/             projection, horizon, science, API
data/              raw DEMs + kernels (not committed) and cache
```

---

## Data credits

- **LOLA 5 m/px DEMs**, PGDA/NASA GSFC — Barker et al. 2021, *Improved LOLA Elevation Maps for South Pole Landing Sites*, P&SS 203, 105119.
- **LOLA 80 m polar DEM**, PDS LRO-L-LOLA-4-GDR.
- **SPICE kernels**, NAIF/JPL — DE440s, `moon_pa_de440_200625.bpc`, `moon_de440_250416.tf`.
- **Artemis candidate regions**, NASA.
- **Validation maps**, LOLA `AVGVISIB_85S_060M_201608` (Mazarico et al. 2011).

Built for the NASA Space Apps Challenge 2026, 14–15 November. Code MIT; data under the terms of their providers.
