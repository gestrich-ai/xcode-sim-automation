## Relevant Skills

| Skill | Description |
|-------|-------------|
| `interactive-xcuitest` | Defines the existing command protocol, CLI workflow, and how the AI invokes `xcuitest-control.py` |
| `creating-automated-screenshots` | Shows how the Swift package integrates into user projects |

## Background

The xcode-sim-automation project currently uses a **Python CLI** (`Tools/xcuitest-control.py`) as the bridge between Claude and the XCUITest harness. The Swift package (`XCUITestControl`) contains the `Codable` model types (`InteractiveCommand`, `InteractiveAction`, etc.) that define the JSON protocol, but the Python CLI duplicates this knowledge — it manually constructs JSON dicts that must stay in sync with the Swift structs.

Bill wants to **add a Swift CLI executable target** to the same package. This would:

1. **Share models** — The CLI and the XCUITest harness use the exact same Swift types for encoding/decoding commands, eliminating drift between Python dicts and Swift structs.
2. **Replace the Python dependency** — Claude would invoke the Swift CLI binary instead of `python3 xcuitest-control.py`, removing the Python runtime dependency.
3. **Enable future reuse** — As more features are added (deep links, batch actions, etc.), only the Swift models need to change. Both the CLI and the harness pick them up automatically.

### Key challenge

The current `XCUITestControl` library links `XCTest`, which is only available inside test bundles. A standalone CLI executable cannot import `XCTest`. This means the models (which are pure `Foundation`/`Codable`) must be **separated from the XCTest-dependent code** into their own module.

### Architecture

```
Package: XCUITestControl
├── XCUITestControlModels (library)     ← NEW: Pure Foundation models
│   ├── InteractiveCommand.swift        ← Moved from XCUITestControl
│   └── (no XCTest dependency)
│
├── XCUITestControl (library)           ← EXISTING: XCTest harness
│   ├── InteractiveControlLoop.swift
│   ├── InteractiveActionExecutor.swift
│   ├── ElementLookup.swift
│   └── depends on: XCUITestControlModels, XCTest
│
└── xcuitest-control (executable)       ← NEW: CLI tool
    ├── main.swift (or @main entry)
    └── depends on: XCUITestControlModels, swift-argument-parser
```

## Phases

## - [x] Phase 1: Extract shared models into `XCUITestControlModels`

**Completed.** All `Codable` model types extracted into a standalone `XCUITestControlModels` library with no XCTest dependency. Both `XCUITestControlModels` and `XCUITestControl` targets build successfully.

**Technical notes:**
- Added `Sendable` conformance to all model types since this is a Swift 6 package (`swift-tools-version: 6.0`)
- The `XCUITestControl` target produces pre-existing XCTest actor-isolation warnings (unrelated to this change) but compiles without errors

## - [x] Phase 2: Add Swift Argument Parser dependency and CLI target

**Completed.** Added `swift-argument-parser` (1.3.0+) dependency and `xcuitest-control` executable target with all 13 subcommands stubbed.

**Technical notes:**
- Used `.executableTarget` with `@main` entry point on `XCUITestControlCLI`
- All subcommands (tap, right-click, scroll, type, adjust, pinch, wait, screenshot, activate, done, status, reset, ready) are registered with placeholder implementations
- The executable product is also exported from the package for discoverability
- All three targets (XCUITestControlModels, XCUITestControl, xcuitest-control) build successfully

## - [x] Phase 3: Implement shared CLI infrastructure

**Completed.** Created shared infrastructure for file I/O, path resolution, and JSON output formatting that all subcommands will use.

**Technical notes:**
- `PathResolver` resolves paths from `--container` option, environment variables (`XCUITEST_COMMAND_PATH`, etc.), or `/tmp/` defaults — matching the Python's `resolve_paths` exactly
- `CommandIO` provides `writeCommand`, `readCommand`, and `waitForCompletion` with 0.2s poll interval and 30s timeout matching Python defaults
- `ResultOutput` formats JSON output with `status`, `hierarchy`, `screenshot`, `error`, and `info` keys identical to the Python CLI's `output_result`
- `GlobalOptions` (`ParsableArguments`) provides `--verbose`/`-v` and `--container`/`-c` flags to all subcommands via `@OptionGroup`
- All subcommands updated to include `@OptionGroup var globals: GlobalOptions` (still stubbed — implementation in Phase 4)
- JSON encoding uses `.prettyPrinted` and `.sortedKeys` to match Python's `indent=2, sort_keys=True`

**Files created:**
- `Sources/xcuitest-control/PathResolver.swift`
- `Sources/xcuitest-control/CommandIO.swift`
- `Sources/xcuitest-control/ResultOutput.swift`

## - [x] Phase 4: Implement action subcommands

**Completed.** All 13 subcommands fully implemented with options matching the Python CLI's interface exactly.

**Technical notes:**
- Each subcommand extracted to its own file under `Sources/xcuitest-control/Commands/`
- Action subcommands (tap, right-click, scroll, type, adjust, pinch, wait, screenshot, activate, done) follow the write-command → poll → output pattern via `CommandIO` and `ResultOutput`
- Local-only subcommands (status, reset, ready) have custom implementations matching Python's JSON output format
- `InteractiveTargetType` and `InteractiveScrollDirection` extended with `ExpressibleByArgument` conformance in the CLI target for use as `@Option` types
- Short flags match Python exactly: `-t` (target), `-T` (target-type), `-V` (value/velocity), `-d` (direction), `-s` (scale), `-i` (index)
- `ready` uses `-t` for `--timeout` (no conflict since it doesn't take a target)
- Stubbed subcommands removed from `XCUITestControlCLI.swift` — only `GlobalOptions`, the `@main` entry point, and `ExpressibleByArgument` extensions remain

**Files created:**
- `Sources/xcuitest-control/Commands/TapCommand.swift`
- `Sources/xcuitest-control/Commands/RightClickCommand.swift`
- `Sources/xcuitest-control/Commands/ScrollCommand.swift`
- `Sources/xcuitest-control/Commands/TypeCommand.swift`
- `Sources/xcuitest-control/Commands/AdjustCommand.swift`
- `Sources/xcuitest-control/Commands/PinchCommand.swift`
- `Sources/xcuitest-control/Commands/WaitCommand.swift`
- `Sources/xcuitest-control/Commands/ScreenshotCommand.swift`
- `Sources/xcuitest-control/Commands/ActivateCommand.swift`
- `Sources/xcuitest-control/Commands/DoneCommand.swift`
- `Sources/xcuitest-control/Commands/StatusCommand.swift`
- `Sources/xcuitest-control/Commands/ResetCommand.swift`
- `Sources/xcuitest-control/Commands/ReadyCommand.swift`

## - [x] Phase 5: Build and manual smoke test

**Completed.** All smoke tests passed. The Swift CLI builds cleanly and produces JSON output identical to the Python CLI.

**Technical notes:**
- `swift build` completes with no errors (all three targets: models, library, CLI)
- `--help` lists all 13 subcommands with correct descriptions
- `reset` produces JSON with `status`, `removed`, and `message` keys — exact match with Python output
- `status` produces JSON with `command`, `hierarchy`, `screenshot`, `hierarchy_exists`, `screenshot_exists` keys — exact match with Python output
- `tap --target "test_button" -c /tmp` writes a valid `{"action":"tap","status":"pending","target":"test_button"}` command file, then times out as expected (no harness running), returning error JSON with exit code 1
- Side-by-side JSON comparison (sorted keys) of `reset`, `status`, and `tap` command files between Python and Swift CLIs: all match exactly

## - [x] Phase 6: Create wrapper script with auto-build

**Completed.** Created `Tools/xcuitest-control` bash wrapper script that auto-builds the Swift CLI in release mode when source files have changed, then execs the binary with all arguments passed through.

**Technical notes:**
- Script resolves package root relative to its own location (`$SCRIPT_DIR/..`)
- Uses `find ... -newer "$BINARY" -print -quit` for efficient staleness detection against all files under `Sources/` and `Package.swift`
- Build output goes to stderr (only the last line via `tail -1`) to avoid polluting JSON stdout
- Uses `--product xcuitest-control` to build only the CLI target, not the full package
- Verified: first run triggers build, second run skips it, touching a source file triggers rebuild

**Files created:**
- `Tools/xcuitest-control`

## - [ ] Phase 7: Update skill documentation

**Skills to read**: `interactive-xcuitest`, `creating-automated-screenshots`

Update the skill files so the AI uses `Tools/xcuitest-control` (the wrapper script) instead of the Python CLI.

**Tasks:**
- Update `.claude/skills/interactive-xcuitest/SKILL.md` and `plugin/skills/interactive-xcuitest/SKILL.md`:
  - Replace `python3 xcuitest-control.py` invocations with the wrapper script path
  - Document that the wrapper auto-builds on first run and when sources change — no manual build step needed
  - The Swift CLI accepts the same flags as the Python CLI
  - Keep `xcuitest-control.py` in the repo as a fallback (e.g., if Swift toolchain isn't available)
- Update `plugin/skills/interactive-xcuitest/cli-reference.md` with the new invocation pattern
- Update `plugin/tools/xcuitest-control.py` reference if the plugin metadata points to it

**Files to modify:**
- `.claude/skills/interactive-xcuitest/SKILL.md`
- `plugin/skills/interactive-xcuitest/SKILL.md`
- `plugin/skills/interactive-xcuitest/cli-reference.md`

## - [ ] Phase 8: Validation

**Tasks:**
- `swift build -c release` succeeds with no errors for all three targets (models, library, CLI)
- Running `Tools/xcuitest-control --help` triggers a build (first time) and shows all subcommands with correct flags
- Running `Tools/xcuitest-control --help` again does NOT rebuild (binary is up-to-date)
- Touch a source file, run again — confirm it rebuilds
- `reset` and `status` subcommands produce valid JSON matching Python format
- `ready` with `--timeout 0` returns immediately with correct JSON
- Verify the `XCUITestControlModels` library can be imported independently (no XCTest dependency leaks)
- Run `python3 Tools/xcuitest-control.py reset` and `Tools/xcuitest-control status` to confirm the Swift CLI can read files written by the Python CLI (and vice versa) — confirming JSON format compatibility
