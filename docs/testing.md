# Brewmap testing

Brewmap uses three layers of automated checks: **unit and widget tests**, **BDD on the VM** (acceptance flows, offline), and **optional BDD on a device** (same scenarios). All commands below use **FVM** (`fvm flutter …`).

## Prerequisites

```bash
fvm flutter pub get
```

For device BDD: start an emulator or connect a physical device (`fvm flutter devices`).

---

## What we have

### 1. Unit and widget tests (`test/core`, `test/features`)

Fast VM tests with mocks and fakes. They do not launch the full app on a device.

| Area | File | Focus |
|------|------|--------|
| Network | `test/core/network/dio_client_test.dart` | Dio configuration |
| Network | `test/core/network/api_client_test.dart` | HTTP client |
| Storage | `test/core/storage/hive_storage_service_test.dart` | Hive favorites and theme mode persistence |
| Utils | `test/core/utils/url_launcher_helper_test.dart` | Phone/URL formatting |
| Utils | `test/core/utils/url_launcher_launch_test.dart` | `launchExternalUrl` + SnackBar |
| Utils | `test/core/utils/error_message_test.dart` | User-facing error messages |
| Theme | `test/core/theme/theme_test.dart` | `BrewColors` and theme |
| Service | `test/features/breweries/services/brewery_api_service_test.dart` | API parsing and errors |
| Domain | `test/features/breweries/utils/brewery_list_filter_test.dart` | Filter, pagination (`page: 0`), lookup |
| State | `test/features/breweries/controllers/brewery_cubit_test.dart` | `BreweryCubit` — search, `clearSearch` during loading, concurrent toggles |
| State | `test/features/breweries/controllers/brewery_state_test.dart` | `didSearchPresentationChange` |
| Model | `test/features/breweries/models/brewery_model_test.dart` | JSON parsing |
| Screens | `test/features/breweries/widgets/map_screen_test.dart` | Map explore flow (needs `BREWMAP_BDD_TEST`) |
| Screens | `test/features/breweries/widgets/favorite_screen_test.dart` | Favorites list and removal |
| Screens | `test/features/about/about_screen_test.dart` | About content and back navigation |
| Components | `test/features/breweries/components/*` | Smoke + extended coverage for `components/` |
| Map | `test/features/breweries/components/brewery_map_panel_test.dart` | Map panel stub and error overlay |

Roughly **102 test cases** in total (with map tests enabled).

### 1b. Opt-in live API (`test/integration`)

| File | Focus |
|------|--------|
| `test/integration/brewery_api_live_test.dart` | Real Open Brewery DB request (skipped unless `BREWMAP_LIVE_API_TEST=true`) |

```bash
fvm flutter test test/integration --dart-define=BREWMAP_LIVE_API_TEST=true
```

`test/flutter_test_config.dart` configures offline Google Fonts for the whole `test/` tree.

### 2. BDD / acceptance (Gherkin)

Scenarios live under `features/bdd/` and drive UI flows with fake dependencies (`integration_test/bdd/`).

| Feature | Scenario |
|---------|----------|
| `search.feature` | API failure shows an error state |
| `favorites.feature` | User favorites a search result |
| `favorites.feature` | Favorite persists after app restart |

**3 scenarios.** Two runners execute the same steps:

| Runner | Entrypoint | Where it runs |
|--------|------------|---------------|
| VM (default for daily work) | `test/bdd/bdd_suite_test.dart` | Host machine, no device |
| Device (optional) | `integration_test/bdd_suite_test.dart` | Emulator or physical device |

The `integration_test/` folder uses Flutter’s official integration-test package for on-device runs. In this repo it only contains this BDD suite—there are no separate “real API” or non-Gherkin E2E tests.

### `BREWMAP_BDD_TEST` flag

BDD must be run with:

```bash
--dart-define=BREWMAP_BDD_TEST=true
```

This enables map stubs and stable UI behavior during scenarios (see `lib/core/config/brewmap_flags.dart`).

---

## How to run

### Unit and widget tests only

Pass `BREWMAP_BDD_TEST` so map-related widget tests run (map stub, no tile network):

```bash
fvm flutter test test/core test/features --dart-define=BREWMAP_BDD_TEST=true
```

A single file:

```bash
fvm flutter test test/features/breweries/controllers/brewery_cubit_test.dart
```

With coverage:

```bash
fvm flutter test test/core test/features --coverage
```

### BDD on the VM (recommended)

```bash
fvm flutter test test/bdd/bdd_suite_test.dart --dart-define=BREWMAP_BDD_TEST=true
```

### BDD on a device (optional)

```bash
fvm flutter devices
fvm flutter test integration_test/bdd_suite_test.dart -d <device_id> --dart-define=BREWMAP_BDD_TEST=true
```

### Full suite (manual)

```bash
fvm flutter test test/core test/features --dart-define=BREWMAP_BDD_TEST=true
fvm flutter test test/bdd/bdd_suite_test.dart --dart-define=BREWMAP_BDD_TEST=true
```

Avoid bare `fvm flutter test` for routine checks: it includes BDD **without** the flag and skips map widget tests.

### brewmap-devkit (MCP in Cursor)

| Tool | What it runs |
|------|----------------|
| `flutter_test` | `test/core` + `test/features` with `BREWMAP_BDD_TEST=true` by default |
| `flutter_bdd` | VM BDD with `BREWMAP_BDD_TEST` |
| `quality_preflight` | `analyze` → unit tests (with `BREWMAP_BDD_TEST`) → BDD → (optional) coverage summary |

Setup, all tools, and troubleshooting: [mcp-brewmap-devkit.md](mcp-brewmap-devkit.md).

---

## Folder layout

```text
test/
├── core/              # unit tests (network, storage, utils, theme)
├── features/          # unit tests (cubit, filters)
├── bdd/               # VM BDD entrypoint
└── flutter_test_config.dart

integration_test/
├── bdd_suite_test.dart
└── bdd/               # world, steps, pump (shared with test/bdd)

features/bdd/
├── search.feature
└── favorites.feature
```

---

## Quick reference

| Type | Location | Count | Main command |
|------|----------|-------|----------------|
| Unit / widget | `test/core`, `test/features` | ~102 | `fvm flutter test test/core test/features --dart-define=BREWMAP_BDD_TEST=true` |
| Live API (opt-in) | `test/integration` | 1 | `fvm flutter test test/integration --dart-define=BREWMAP_LIVE_API_TEST=true` |
| BDD (VM) | `test/bdd` + `features/bdd` | 3 scenarios | `fvm flutter test test/bdd/bdd_suite_test.dart --dart-define=BREWMAP_BDD_TEST=true` |
| BDD (device) | `integration_test` | 3 scenarios (same) | `fvm flutter test integration_test/bdd_suite_test.dart -d <id> --dart-define=BREWMAP_BDD_TEST=true` |
