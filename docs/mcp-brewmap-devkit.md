# brewmap-devkit MCP server

**brewmap-devkit** is a local [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) server for the Brewmap Flutter repo. It exposes quality tools (analyze, tests, BDD, coverage) so AI agents in **Cursor** can run the same checks you would run in the terminal—always via **FVM** (`fvm flutter …`).

For what the app tests cover and shell commands, see [testing.md](testing.md).

---

## What it does

| Goal | How |
|------|-----|
| Consistent Flutter commands | Every tool shells out to `fvm`, not a global `flutter` |
| Structured results for agents | JSON envelope with `ok`, `summary`, `data`, `errors`, and `raw` stdout/stderr |
| Split unit vs BDD | Unit/widget tests and BDD run separately; BDD always uses `BREWMAP_BDD_TEST` |
| Pre-PR gate | `quality_preflight` chains analyze → unit tests → BDD → optional coverage read |

The server uses **stdio** transport (stdin/stdout): Cursor spawns `node server.mjs` and talks MCP over JSON-RPC.

---

## Repository layout

```text
tools/brewmap-devkit/
├── server.mjs              # MCP server implementation
├── package.json
├── package-lock.json
├── tools/                  # Tool JSON schemas (descriptors for docs/validation)
│   ├── flutter_analyze.json
│   ├── flutter_test.json
│   ├── flutter_bdd.json
│   ├── coverage_summary.json
│   └── quality_preflight.json
└── resources/
    └── manifest.json       # MCP resource metadata
```

Default working directory for all tools is the **repo root** (`brewmap/`), resolved as two levels above `tools/brewmap-devkit/`.

---

## Prerequisites

1. **Node.js** (LTS recommended) — runs the MCP server.
2. **FVM** — Flutter SDK pinned for this project.
3. **Dependencies installed** for the devkit:

```bash
cd tools/brewmap-devkit
npm install
```

4. **Flutter deps** in the app:

```bash
fvm flutter pub get
```

`fvm` must be on your `PATH` when Cursor starts the MCP process (same as in your terminal).

---

## Registering in Cursor

Add the server under **Cursor Settings → MCP** (or edit your MCP config file). Example:

```json
{
  "mcpServers": {
    "brewmap-devkit": {
      "command": "node",
      "args": [
        "/absolute/path/to/brewmap/tools/brewmap-devkit/server.mjs"
      ]
    }
  }
}
```

Replace `/absolute/path/to/brewmap` with your clone path.

Alternative (run via npm from the devkit folder):

```json
{
  "mcpServers": {
    "brewmap-devkit": {
      "command": "npm",
      "args": ["start"],
      "cwd": "/absolute/path/to/brewmap/tools/brewmap-devkit"
    }
  }
}
```

After changing `server.mjs` or tool behavior, **restart the MCP server** (or reload the Cursor window) so the agent picks up updates.

---

## Response format

Every tool returns a single JSON object (pretty-printed text content):

| Field | Meaning |
|-------|---------|
| `ok` | Whether the tool considers the run successful |
| `tool` | Tool name (e.g. `flutter_test`) |
| `timestamp` | ISO-8601 UTC time |
| `summary` | One-line human summary |
| `data` | Tool-specific payload (counts, scenarios, steps, etc.) |
| `errors` | List of `{ kind, message, … }` when failed |
| `raw` | `{ command, exitCode, stdout, stderr }` from the underlying process |

Agents should read `ok` and `summary` first, then `data` for details.

---

## Tools

### `flutter_analyze`

Runs static analysis.

```bash
fvm flutter analyze
```

| Argument | Type | Default | Description |
|----------|------|---------|-------------|
| `workingDirectory` | string | repo root | Working directory for the command |

**Success:** exit code 0 and zero analyzer **errors** (warnings may still exist).

**`data`:** `counts` (`info`, `warning`, `error`) and `issues[]` with `severity`, `message`, `file`, `line`, `column`, `rule`.

---

### `flutter_test`

Runs unit and widget tests only (not BDD).

```bash
fvm flutter test test/core test/features --dart-define=BREWMAP_BDD_TEST=true
```

| Argument | Type | Default | Description |
|----------|------|---------|-------------|
| `workingDirectory` | string | repo root | Working directory |
| `paths` | string[] | `test/core`, `test/features` | Test files or directories |
| `coverage` | boolean | `false` | Pass `--coverage` |
| `tags` | string[] | — | Repeated `--tags` filters |
| `dartDefines` | string[] | `BREWMAP_BDD_TEST=true` | Repeated `--dart-define` values (map widget stubs) |

**`data`:** `passed`, `failed`, `skipped`, `failures[]`.

---

### `flutter_bdd`

Runs the VM BDD suite with the Brewmap test flag.

```bash
fvm flutter test test/bdd/bdd_suite_test.dart --dart-define=BREWMAP_BDD_TEST=true
```

| Argument | Type | Default | Description |
|----------|------|---------|-------------|
| `workingDirectory` | string | repo root | Working directory |
| `entrypoint` | string | `test/bdd/bdd_suite_test.dart` | BDD entry file |

**`data`:** `entrypoint`, `scenarios[]` each with `name`, `status` (`passed` \| `failed` \| `skipped` \| `unknown`), optional `error`, and `steps[]` (Gherkin keyword + text + status).

Scenario parsing is best-effort from Gherkin-style output in stdout/stderr.

**Not supported by this tool:** device BDD (`integration_test/bdd_suite_test.dart`). Run that manually with `-d <device_id>` (see [testing.md](testing.md)).

---

### `coverage_summary`

Reads and parses an LCOV file; it does **not** run tests.

| Argument | Type | Default | Description |
|----------|------|---------|-------------|
| `workingDirectory` | string | repo root | Base path for relative `lcovPath` |
| `lcovPath` | string | `coverage/lcov.info` | LCOV file path |
| `topN` | integer | `10` | Lowest-coverage files to return |

Generate coverage first, for example:

```bash
fvm flutter test test/core test/features --coverage
```

**`data`:** `total` (`linesHit`, `linesFound`, `percent`), `worstFiles[]`, `uncoveredFiles[]`.

---

### `quality_preflight`

Runs a fixed quality pipeline suitable before a PR or merge.

| Step | Command (conceptually) | Default |
|------|------------------------|---------|
| 1. `analyze` | `fvm flutter analyze` | always |
| 2. `tests` | `fvm flutter test test/core test/features` | always |
| 3. `bdd` | `fvm flutter test <entrypoint> --dart-define=BREWMAP_BDD_TEST=true` | when `runBdd` is true |
| 4. `coverage` | parse `lcovPath` | when `runCoverageSummary` is true |

| Argument | Type | Default | Description |
|----------|------|---------|-------------|
| `workingDirectory` | string | repo root | Working directory |
| `runBdd` | boolean | `true` | Run BDD step |
| `bddEntrypoint` | string | `test/bdd/bdd_suite_test.dart` | BDD entry file |
| `runCoverageSummary` | boolean | `true` | Parse LCOV after tests |
| `lcovPath` | string | `coverage/lcov.info` | LCOV path |
| `minCoveragePercent` | number | `0` | Fail gate if total coverage is below this (only when greater than 0) |

**`data`:** `gateOk`, `steps[]` (`name`, `ok`, `summary`), optional `coverage` (`percent`, `minRequiredPercent`).

**Notes:**

- The coverage step only **reads** existing LCOV; preflight does not pass `--coverage` on the test step. Generate `coverage/lcov.info` beforehand, or set `runCoverageSummary: false` until you have a file.
- BDD is not run twice: unit tests exclude `test/bdd/`.

**Example agent prompts:**

- “Run quality preflight on Brewmap.”
- “Run quality preflight without coverage.” → `runCoverageSummary: false`
- “Run quality preflight without BDD.” → `runBdd: false`

---

## How tools map to the test pyramid

```text
                    ┌─────────────────────┐
                    │  quality_preflight   │
                    │  (orchestrates all)  │
                    └──────────┬──────────┘
           ┌───────────────────┼───────────────────┐
           ▼                   ▼                   ▼
   flutter_analyze      flutter_test         flutter_bdd
   (static)         (unit/widget)          (Gherkin VM)
                           │
                           └── optional: coverage_summary
                               (after manual --coverage)
```

---

## Manual smoke test

Without Cursor, you can verify the server starts:

```bash
cd tools/brewmap-devkit
npm start
```

The process should stay running and wait on stdio (no HTTP port). Stop with Ctrl+C.

To exercise Flutter the same way the tools do:

```bash
cd /path/to/brewmap
fvm flutter analyze
fvm flutter test test/core test/features
fvm flutter test test/bdd/bdd_suite_test.dart --dart-define=BREWMAP_BDD_TEST=true
```

---

## Troubleshooting

| Issue | What to check |
|-------|----------------|
| MCP tools missing in Cursor | Server enabled in MCP settings; path to `server.mjs` is correct |
| `fvm: command not found` | FVM on PATH for GUI apps (macOS: launch Cursor from a shell or fix PATH) |
| Preflight coverage step fails | Run tests with `--coverage` first, or disable `runCoverageSummary` |
| BDD fails via MCP but passes in terminal | Same repo root? MCP uses `BREWMAP_BDD_TEST`; bare `flutter test` does not |
| Changes to tools not reflected | Restart MCP server / reload Cursor |
| `npm install` errors | Run inside `tools/brewmap-devkit` |

---

## Implementation notes

- **SDK:** [`@modelcontextprotocol/sdk`](https://www.npmjs.com/package/@modelcontextprotocol/sdk) with `StdioServerTransport`.
- **Server name / version:** `brewmap-devkit` `0.1.0` (see `server.mjs`).
- **Process spawning:** `child_process.spawn` with `fvm` as the executable; no shell wrapper.
- **BDD parsing:** `parseGherkinBdd()` scans output for `Scenario:` lines and Given/When/Then steps.

---

## Related docs

- [testing.md](testing.md) — test types, features, and shell commands
- `lib/core/config/brewmap_flags.dart` — `BREWMAP_BDD_TEST` compile-time flag
