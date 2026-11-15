# Method and validation

## Pipeline

1. **Representative point** — each published 16 × 16 km ROI is sampled on a
   12 × 12 grid; the six best candidates by coarse illumination are re-scored
   with the full 1,440-bin horizon, subject to a 10° slope gate.
2. **Horizon** — for each of 1,440 azimuths, march the DEM to 40 km and keep
   the maximum elevation angle, applying lunar curvature `drop = r²/2R`
   (719 m at 50 km). 0.25° bins.
3. **Ephemerides** — SPICE DE440s in `MOON_ME_DE440_ME421`, with light-time
   and stellar aberration. Azimuth from north, clockwise.
4. **Visibility** — a body counts as visible when its **disk** clears the
   terrain; illumination integrates the visible fraction of the solar disk and
   subtracts Earth-eclipse obscuration.
5. **Power** — beam irradiance × incidence angle. Vertical tracking is the
   polar default; horizontal panels are modelled for comparison.
6. **Communication** — Earth disk above the terrain; illustrative X-band link
   budget (5 W, 0.3 m lander antenna, 34 m ground station).
7. **Decision** — transparent weights, hard slope gate, assessment label.

## Validation against published products

`AVGVISIB_85S_060M_201608` is a 60 m, 2009–2013 average illumination map.
Sampling it at each representative point and comparing with the modelled 2030
annual mean gives:

| Site | Sun (ours) | Sun (LOLA) | Δ | Earth (ours) | Earth (LOLA) | Δ |
|---|---|---|---|---|---|---|
| Shackleton | 38.6 | 43.2 | −4.7 | 26.0 | 42.7 | −16.7 |
| Connecting | 43.7 | 48.6 | −5.0 | 50.7 | 34.3 | +16.4 |
| de Gerlache | 34.0 | 44.9 | −10.9 | 42.2 | 44.7 | −2.5 |
| Peak | 52.0 | 39.8 | +12.2 | 21.2 | 59.5 | −38.3 |
| Malapert | 37.1 | 32.3 | +4.8 | 36.7 | 39.9 | −3.2 |
| Nobile | 53.9 | 46.1 | +7.8 | 53.4 | 54.6 | −1.3 |
| Leibnitz | 48.8 | 42.3 | +6.5 | 53.0 | 50.2 | +2.8 |
| G–K Massif | 50.1 | 26.7 | +23.3 | 42.5 | 44.7 | −2.2 |

Sun bias **+4.2 pp**, RMS **11.1 pp**. Differences are expected: four-year
average vs one year, 60 m vs 5 m terrain, and a point sample vs a pixel
average. Earth is more sensitive to libration and to local peaks that the
60 m product smooths.

## Internal checks

`pytest` covers projection round-trips and orientation, an analytic cliff
horizon, polar Sun-elevation bounds, libration bounds, eclipse geometry,
link-budget monotonicity, score gating, and an API smoke test including a
raster fetch.
