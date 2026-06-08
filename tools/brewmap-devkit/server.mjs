import { spawn } from "node:child_process";
import { constants } from "node:fs";
import { access, readFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { CallToolRequestSchema, ListToolsRequestSchema } from "@modelcontextprotocol/sdk/types.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const defaultRepoRoot = path.resolve(__dirname, "..", ".."); // tools/brewmap-devkit -> repo root

/** Unit/widget tests only; BDD runs separately with BREWMAP_BDD_TEST. */
const defaultUnitTestPaths = ["test/core", "test/features"];
/** Enables map stubs in widget tests (see lib/core/config/brewmap_flags.dart). */
const defaultTestDartDefines = ["BREWMAP_BDD_TEST=true"];
const defaultProcessTimeoutMs = 15 * 60 * 1000;
const analyzeProcessTimeoutMs = 5 * 60 * 1000;

function nowIso() {
  return new Date().toISOString();
}

function envelope({ ok, tool, summary, data, errors = [], raw }) {
  return {
    ok,
    tool,
    timestamp: nowIso(),
    summary,
    data: data ?? {},
    errors,
    raw: raw ?? { command: "", exitCode: -1, stdout: "", stderr: "" },
  };
}

function assertWithinRepoRoot(resolvedPath) {
  const root = path.resolve(defaultRepoRoot);
  const cwd = path.resolve(resolvedPath);
  if (cwd !== root && !cwd.startsWith(`${root}${path.sep}`)) {
    throw new Error(`workingDirectory must be inside ${root}`);
  }
}

async function resolveWorkingDirectory(workingDirectory) {
  const resolved = workingDirectory
    ? path.resolve(String(workingDirectory))
    : defaultRepoRoot;

  assertWithinRepoRoot(resolved);
  await access(resolved, constants.R_OK | constants.W_OK);
  await access(path.join(resolved, "pubspec.yaml"), constants.R_OK);

  return resolved;
}

function runProcess({ cwd, command, args, timeoutMs = defaultProcessTimeoutMs }) {
  return new Promise((resolve) => {
    const child = spawn(command, args, {
      cwd,
      env: process.env,
      stdio: ["ignore", "pipe", "pipe"],
    });

    let stdout = "";
    let stderr = "";
    let timedOut = false;

    const timer = setTimeout(() => {
      timedOut = true;
      child.kill("SIGTERM");
    }, timeoutMs);

    child.stdout.on("data", (d) => (stdout += d.toString()));
    child.stderr.on("data", (d) => (stderr += d.toString()));

    child.on("close", (code) => {
      clearTimeout(timer);
      if (timedOut) {
        stderr += `\n[brewmap-devkit] Process timed out after ${timeoutMs}ms`;
      }
      resolve({
        exitCode: timedOut ? -2 : typeof code === "number" ? code : -1,
        stdout,
        stderr,
        timedOut,
      });
    });
  });
}

function parseFlutterAnalyze(output) {
  // Typical line:
  // info • Unused import • lib/foo.dart:12:1 • unused_import
  const issues = [];
  const lines = output.split(/\r?\n/);
  for (const line of lines) {
    const m = line.match(/^(info|warning|error)\s+•\s+(.*?)\s+•\s+(.+?):(\d+):(\d+)\s+•\s+(.+)\s*$/);
    if (!m) continue;
    issues.push({
      severity: m[1],
      message: m[2],
      file: m[3],
      line: Number(m[4]),
      column: Number(m[5]),
      rule: m[6],
    });
  }

  const counts = { info: 0, warning: 0, error: 0 };
  for (const i of issues) counts[i.severity] += 1;
  return { counts, issues };
}

function appendDartDefines(cmdArgs, dartDefines) {
  for (const define of dartDefines) {
    cmdArgs.push("--dart-define", define);
  }
}

function resolveDartDefines(args, fallback = defaultTestDartDefines) {
  if (Array.isArray(args.dartDefines)) {
    return args.dartDefines.map(String);
  }
  return [...fallback];
}

function parseFlutterTestSummary(output) {
  // Common progress pattern: "00:03 +12 -1: ..."
  // End-of-run often contains: "+123 -2" final.
  let passed = 0;
  let failed = 0;
  let skipped = 0;

  const lastProgress = [
    ...output.matchAll(/\+(\d+)(?:\s+~(\d+))?(?:\s+-(\d+))?/g),
  ].pop();
  if (lastProgress) {
    passed = Number(lastProgress[1]);
    skipped = Number(lastProgress[2] || 0);
    failed = Number(lastProgress[3] || 0);
  }
  const failures = [];
  return { passed, failed, skipped, failures };
}

function parseGherkinBdd(output) {
  // Tries to extract: Feature/Scenario headers, step lines, and infer pass/fail.
  // Works reasonably even if the runner output changes slightly, since it keys off Gherkin keywords.
  const lines = output.split(/\r?\n/);
  const scenarios = [];
  let current = null;

  const flush = () => {
    if (!current) return;
    // If any step failed, scenario failed.
    if (current.steps.some((s) => s.status === "failed")) current.status = "failed";
    // If we have no steps, keep unknown unless already failed.
    scenarios.push(current);
    current = null;
  };

  const isScenarioLine = (l) => /^Scenario( Outline)?:\s+/.test(l);
  const scenarioName = (l) => l.replace(/^Scenario( Outline)?:\s+/, "").trim();

  const stepMatch = (l) => {
    const m = l.match(/^\s*(Given|When|Then|And|But)\s+(.*)$/);
    if (!m) return null;
    return { keyword: m[1], text: m[2].trim() };
  };

  const looksLikeFailure = (l) =>
    /\b(FAILED|FAIL|Exception|Error)\b/.test(l) || l.includes("✗") || l.includes("×");
  const looksLikeSkip = (l) => /\bSKIP(PED)?\b/.test(l) || l.includes("⤼") || l.includes("↷");
  const looksLikePass = (l) => l.includes("✓") || l.includes("✔");

  for (let i = 0; i < lines.length; i++) {
    const raw = lines[i];
    const l = raw.trimEnd();

    if (isScenarioLine(l.trim())) {
      flush();
      current = {
        name: scenarioName(l.trim()),
        status: "passed",
        error: undefined,
        steps: [],
      };
      continue;
    }

    if (!current) continue;

    const sm = stepMatch(l);
    if (sm) {
      // If runner prints status markers on the same line, infer it.
      let status = "unknown";
      if (looksLikePass(l)) status = "passed";
      else if (looksLikeSkip(l)) status = "skipped";
      else if (looksLikeFailure(l)) status = "failed";
      current.steps.push({ keyword: sm.keyword, text: sm.text, status });
      continue;
    }

    // Try to attach first failure-ish line as scenario error.
    if (!current.error && looksLikeFailure(l)) {
      current.error = l.trim();
      current.status = "failed";
    }
  }

  flush();

  // If we didn't find scenario lines but the run failed, return a single "unknown" scenario
  // so the consumer has something structured.
  return scenarios;
}

async function parseLcov(lcovText, { topN }) {
  // LCOV groups by file: SF:<path> ... LF:<n> LH:<n>
  const perFile = new Map();
  let current = null;

  for (const line of lcovText.split(/\r?\n/)) {
    if (line.startsWith("SF:")) {
      current = line.slice(3).trim();
      if (!perFile.has(current)) perFile.set(current, { linesFound: 0, linesHit: 0 });
    } else if (line.startsWith("LF:") && current) {
      perFile.get(current).linesFound = Number(line.slice(3).trim());
    } else if (line.startsWith("LH:") && current) {
      perFile.get(current).linesHit = Number(line.slice(3).trim());
    } else if (line === "end_of_record") {
      current = null;
    }
  }

  const files = [];
  let totalFound = 0;
  let totalHit = 0;
  const uncoveredFiles = [];

  for (const [p, v] of perFile.entries()) {
    totalFound += v.linesFound;
    totalHit += v.linesHit;
    const percent = v.linesFound > 0 ? (v.linesHit / v.linesFound) * 100 : 100;
    files.push({ path: p, linesHit: v.linesHit, linesFound: v.linesFound, percent: Number(percent.toFixed(2)) });
    if (v.linesFound > 0 && v.linesHit === 0) uncoveredFiles.push(p);
  }

  files.sort((a, b) => a.percent - b.percent);
  const worstFiles = files.slice(0, Math.max(0, topN ?? 10));
  const totalPercent = totalFound > 0 ? (totalHit / totalFound) * 100 : 100;

  return {
    total: { linesHit: totalHit, linesFound: totalFound, percent: Number(totalPercent.toFixed(2)) },
    worstFiles,
    uncoveredFiles,
  };
}

const server = new Server(
  { name: "brewmap-devkit", version: "0.1.0" },
  { capabilities: { tools: {} } }
);

server.setRequestHandler(ListToolsRequestSchema, async () => {
  // Keep names aligned with tools/*.json descriptors.
  return {
    tools: [
      {
        name: "flutter_analyze",
        description: "Runs `fvm flutter analyze` and returns structured diagnostics.",
        inputSchema: {
          type: "object",
          properties: { workingDirectory: { type: "string" } },
        },
      },
      {
        name: "flutter_test",
        description:
          "Runs `fvm flutter test` for unit/widget tests (default: test/core, test/features). BDD is not included; use flutter_bdd.",
        inputSchema: {
          type: "object",
          properties: {
            workingDirectory: { type: "string" },
            paths: { type: "array", items: { type: "string" } },
            coverage: { type: "boolean" },
            tags: { type: "array", items: { type: "string" } },
            dartDefines: {
              type: "array",
              items: { type: "string" },
              description:
                "Optional --dart-define values. Defaults to BREWMAP_BDD_TEST=true for map widget stubs.",
            },
          },
        },
      },
      {
        name: "flutter_bdd",
        description:
          "Runs Brewmap BDD suite on the VM (offline-safe) with BREWMAP_BDD_TEST and returns scenario results.",
        inputSchema: {
          type: "object",
          properties: {
            workingDirectory: { type: "string" },
            entrypoint: { type: "string" },
          },
        },
      },
      {
        name: "coverage_summary",
        description: "Parses `coverage/lcov.info` and returns coverage summary.",
        inputSchema: {
          type: "object",
          properties: {
            workingDirectory: { type: "string" },
            lcovPath: { type: "string" },
            topN: { type: "integer" },
          },
        },
      },
      {
        name: "quality_preflight",
        description: "Runs analyze, tests, optional BDD, optional coverage summary.",
        inputSchema: {
          type: "object",
          properties: {
            workingDirectory: { type: "string" },
            runBdd: { type: "boolean" },
            bddEntrypoint: { type: "string" },
            runCoverageSummary: { type: "boolean" },
            lcovPath: { type: "string" },
            minCoveragePercent: { type: "number" },
          },
        },
      },
    ],
  };
});

server.setRequestHandler(CallToolRequestSchema, async (req) => {
  const name = req.params.name;
  const args = req.params.arguments ?? {};

  const asTextResult = (obj) => ({
    content: [{ type: "text", text: JSON.stringify(obj, null, 2) }],
  });

  let cwd;
  try {
    cwd = await resolveWorkingDirectory(args.workingDirectory);
  } catch (e) {
    const message = e instanceof Error ? e.message : String(e);
    return asTextResult(
      envelope({
        ok: false,
        tool: name,
        summary: message,
        data: {},
        errors: [{ kind: "invalid_working_directory", message }],
        raw: { command: "", exitCode: 1, stdout: "", stderr: message },
      })
    );
  }

  if (name === "flutter_analyze") {
    const raw = await runProcess({
      cwd,
      command: "fvm",
      args: ["flutter", "analyze"],
      timeoutMs: analyzeProcessTimeoutMs,
    });
    const data = parseFlutterAnalyze(raw.stdout + "\n" + raw.stderr);
    const ok = raw.exitCode === 0 && data.counts.error === 0;
    const summary = ok
      ? `Analyze OK (${data.counts.error} errors, ${data.counts.warning} warnings).`
      : `Analyze failed (${data.counts.error} errors, ${data.counts.warning} warnings).`;

    return asTextResult(
      envelope({
        ok,
        tool: "flutter_analyze",
        summary,
        data,
        errors: ok ? [] : [{ kind: "analyze_failed", message: summary }],
        raw: { command: "fvm flutter analyze", exitCode: raw.exitCode, stdout: raw.stdout, stderr: raw.stderr },
      })
    );
  }

  if (name === "flutter_test") {
    const coverage = Boolean(args.coverage);
    const paths =
      Array.isArray(args.paths) && args.paths.length > 0
        ? args.paths.map(String)
        : [...defaultUnitTestPaths];
    const tags = Array.isArray(args.tags) ? args.tags.map(String) : [];
    const dartDefines = resolveDartDefines(args);

    const cmdArgs = ["flutter", "test", ...paths];
    if (coverage) cmdArgs.push("--coverage");
    for (const t of tags) cmdArgs.push("--tags", t);
    appendDartDefines(cmdArgs, dartDefines);

    const raw = await runProcess({ cwd, command: "fvm", args: cmdArgs });
    const data = parseFlutterTestSummary(raw.stdout + "\n" + raw.stderr);
    const ok = raw.exitCode === 0 && data.failed === 0;
    const summary = ok ? `Tests OK (+${data.passed}).` : `Tests failed (+${data.passed} -${data.failed}).`;

    return asTextResult(
      envelope({
        ok,
        tool: "flutter_test",
        summary,
        data,
        errors: ok ? [] : [{ kind: "test_failed", message: summary }],
        raw: { command: `fvm ${cmdArgs.join(" ")}`, exitCode: raw.exitCode, stdout: raw.stdout, stderr: raw.stderr },
      })
    );
  }

  if (name === "flutter_bdd") {
    const entrypoint = args.entrypoint
      ? String(args.entrypoint)
      : "test/bdd/bdd_suite_test.dart";
    const raw = await runProcess({
      cwd,
      command: "fvm",
      args: [
        "flutter",
        "test",
        entrypoint,
        "--dart-define=BREWMAP_BDD_TEST=true",
      ],
    });

    const output = `${raw.stdout}\n${raw.stderr}`;
    const scenarios = parseGherkinBdd(output);
    const ok = raw.exitCode === 0;

    // If command failed but we couldn't parse anything, provide one fallback scenario.
    const normalizedScenarios =
      scenarios.length > 0
        ? scenarios
        : [
            {
              name: "Unknown scenario",
              status: ok ? "unknown" : "failed",
              error: ok ? undefined : "BDD failed (no scenarios parsed).",
              steps: [],
            },
          ];

    const failedCount = normalizedScenarios.filter((s) => s.status === "failed").length;
    const passedCount = normalizedScenarios.filter((s) => s.status === "passed").length;
    const unknownCount = normalizedScenarios.filter((s) => s.status === "unknown").length;

    const summary = ok
      ? `BDD OK (${passedCount} passed, ${unknownCount} unknown).`
      : `BDD failed (${failedCount} failed, ${passedCount} passed, ${unknownCount} unknown).`;

    return asTextResult(
      envelope({
        ok,
        tool: "flutter_bdd",
        summary,
        data: { entrypoint, scenarios: normalizedScenarios },
        errors: ok ? [] : [{ kind: "bdd_failed", message: summary }],
        raw: {
          command: `fvm flutter test ${entrypoint} --dart-define=BREWMAP_BDD_TEST=true`,
          exitCode: raw.exitCode,
          stdout: raw.stdout,
          stderr: raw.stderr,
        },
      })
    );
  }

  if (name === "coverage_summary") {
    const lcovPath = args.lcovPath ? String(args.lcovPath) : "coverage/lcov.info";
    const topN = Number.isFinite(args.topN) ? Number(args.topN) : 10;
    const resolved = path.isAbsolute(lcovPath) ? lcovPath : path.resolve(cwd, lcovPath);

    try {
      const lcovText = await readFile(resolved, "utf8");
      const parsed = await parseLcov(lcovText, { topN });
      const summary = `Coverage ${parsed.total.percent}% (${parsed.total.linesHit}/${parsed.total.linesFound}).`;
      return asTextResult(
        envelope({
          ok: true,
          tool: "coverage_summary",
          summary,
          data: { lcovPath, ...parsed },
          raw: { command: `read ${resolved}`, exitCode: 0, stdout: "", stderr: "" },
        })
      );
    } catch (e) {
      const msg = `Failed to read/parse LCOV at ${resolved}.`;
      return asTextResult(
        envelope({
          ok: false,
          tool: "coverage_summary",
          summary: msg,
          data: { lcovPath, total: { linesHit: 0, linesFound: 0, percent: 0 }, worstFiles: [], uncoveredFiles: [] },
          errors: [{ kind: "lcov_read_failed", message: `${msg} ${(e && e.message) || String(e)}` }],
          raw: { command: `read ${resolved}`, exitCode: 1, stdout: "", stderr: "" },
        })
      );
    }
  }

  if (name === "quality_preflight") {
    const runBdd = args.runBdd === undefined ? true : Boolean(args.runBdd);
    const bddEntrypoint = args.bddEntrypoint
      ? String(args.bddEntrypoint)
      : "test/bdd/bdd_suite_test.dart";
    const runCoverageSummary = args.runCoverageSummary === undefined ? true : Boolean(args.runCoverageSummary);
    const lcovPath = args.lcovPath ? String(args.lcovPath) : "coverage/lcov.info";
    const minCoveragePercent = Number(args.minCoveragePercent ?? 0);

    const steps = [];
    let gateOk = true;

    const analyzeRaw = await runProcess({ cwd, command: "fvm", args: ["flutter", "analyze"] });
    const analyzeData = parseFlutterAnalyze(analyzeRaw.stdout + "\n" + analyzeRaw.stderr);
    const analyzeOk = analyzeRaw.exitCode === 0 && analyzeData.counts.error === 0;
    steps.push({
      name: "analyze",
      ok: analyzeOk,
      summary: analyzeOk
        ? `OK (${analyzeData.counts.error} errors).`
        : `FAILED (${analyzeData.counts.error} errors).`,
    });
    gateOk = gateOk && analyzeOk;

    const unitTestArgs = ["flutter", "test", ...defaultUnitTestPaths];
    if (runCoverageSummary) unitTestArgs.push("--coverage");
    appendDartDefines(unitTestArgs, defaultTestDartDefines);
    const testRaw = await runProcess({ cwd, command: "fvm", args: unitTestArgs });
    const testData = parseFlutterTestSummary(testRaw.stdout + "\n" + testRaw.stderr);
    const testOk = testRaw.exitCode === 0 && testData.failed === 0;
    steps.push({
      name: "tests",
      ok: testOk,
      summary: testOk
        ? `OK (${defaultUnitTestPaths.join(", ")}).`
        : `FAILED (-${testData.failed}).`,
    });
    gateOk = gateOk && testOk;

    if (runBdd) {
      const bddRaw = await runProcess({
        cwd,
        command: "fvm",
        args: [
          "flutter",
          "test",
          bddEntrypoint,
          "--dart-define=BREWMAP_BDD_TEST=true",
        ],
      });
      const bddOk = bddRaw.exitCode === 0;
      steps.push({ name: "bdd", ok: bddOk, summary: bddOk ? "OK." : "FAILED." });
      gateOk = gateOk && bddOk;
    }

    let coverage = undefined;
    if (runCoverageSummary) {
      const resolved = path.isAbsolute(lcovPath) ? lcovPath : path.resolve(cwd, lcovPath);
      try {
        const lcovText = await readFile(resolved, "utf8");
        const parsed = await parseLcov(lcovText, { topN: 10 });
        const percent = parsed.total.percent;
        const covOk = minCoveragePercent > 0 ? percent >= minCoveragePercent : true;
        coverage = { percent, minRequiredPercent: minCoveragePercent };
        steps.push({
          name: "coverage",
          ok: covOk,
          summary: covOk ? `OK (${percent}%).` : `FAILED (${percent}% < ${minCoveragePercent}%).`,
        });
        gateOk = gateOk && covOk;
      } catch (e) {
        steps.push({ name: "coverage", ok: false, summary: "FAILED (lcov read/parse error)." });
        gateOk = false;
      }
    }

    const summary = gateOk ? "Preflight OK." : "Preflight FAILED.";
    return asTextResult(
      envelope({
        ok: gateOk,
        tool: "quality_preflight",
        summary,
        data: { gateOk, steps, ...(coverage ? { coverage } : {}) },
        errors: gateOk ? [] : [{ kind: "preflight_failed", message: summary }],
        raw: { command: "quality_preflight", exitCode: gateOk ? 0 : 1, stdout: "", stderr: "" },
      })
    );
  }

  return asTextResult(
    envelope({
      ok: false,
      tool: name,
      summary: `Unknown tool: ${name}`,
      data: {},
      errors: [{ kind: "unknown_tool", message: `Unknown tool: ${name}` }],
      raw: { command: "", exitCode: 1, stdout: "", stderr: "" },
    })
  );
});

const transport = new StdioServerTransport();
await server.connect(transport);

