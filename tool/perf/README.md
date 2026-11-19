# Performance checks

Run them before a release with changes to Home, the group page, storage or startup, and compare with the numbers below. They use the **dev** flavor (`io.caravella.egm.dev`), a separate app: the store app and its data are never touched.

## Frame times (`perf_test.dart`)

Profile mode, on an emulator or a phone (screen on and unlocked for the whole run):

```sh
flutter drive --profile --no-dds --keep-app-running \
  --flavor dev --dart-define=FLAVOR=dev \
  --driver=tool/perf/perf_driver.dart --target=tool/perf/perf_test.dart \
  -d <device>
```

- The **first** run fills the dev app ("Perf 1000": 1,000 expenses, a monthly budget, pinned; five groups of 100) and stops. The **second** run measures: open the group, scroll the expenses, open Statistics and scroll. Results in `build/integration_response_data.json` (`average_frame_build_time_millis`, `90th_percentile_…`, `worst_…`, and the same for the rasterizer).
- **Always pass `--keep-app-running`.** Without it `flutter drive` stops the app at the end and tries to uninstall `io.caravella.egm` — the store app's id, not the dev one — which on a phone would remove Caravella and its data.
- `--no-dds`: without it `watchPerformance` can't reach the VM service.
- The test finds the Statistics section in the device's language.
- On an emulator the rasterizer runs on an emulated GPU: only the build (UI thread) times mean something there.

## Cold start (`cold_start.sh`)

```sh
flutter build apk --profile --flavor dev --dart-define=FLAVOR=dev
tool/perf/cold_start.sh <device> build/app/outputs/flutter-apk/app-dev-profile.apk 6
```

Time to Home ready (the launch splash stays until Home has its groups). Run it with the data from the first `perf_test` run, and alternate the builds you compare (before/after) to even out the device's drift.

## Reference (2026-11-19, 2.5 rc.17)

Emulator API 34 arm64, the data above (#767):

| Action | Build avg / p99 / worst |
|---|---|
| Open the group | 1.5 / 20 / 20 ms |
| Scroll the expenses | 0.5 / 4.3 / 26 ms |
| Statistics + scroll | 0.8 / 20 / 43 ms |

Cold start: median 849 ms (823–984, 12 runs); 914 ms before #770.

Samsung Galaxy S25 (Android 16, 120 Hz), same data:

| Action | Frames | Build avg / p99 / worst | Raster avg / p99 / worst |
|---|---|---|---|
| Open the group | 49 | 0.7 / 15 / 15 ms | 1.0 / 6.6 / 6.6 ms |
| Scroll the expenses | 1,117 | 0.6 / 6.4 / 43 ms | 1.5 / 3.7 / 9.8 ms |
| Statistics + scroll | 401 | 0.8 / 3.5 / 41 ms | 1.7 / 4.3 / 32 ms |

The few frames over budget are single builds of ~40 ms (a new week section while scrolling, the first Statistics frame).
