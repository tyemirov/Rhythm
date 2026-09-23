# Validation

## Repository Organization

The source repository is `tyemirov/Rhythm`.
The repository uses Git with `master` as its initial branch.
The application source and assets retain their previous contents.
One Xcode project contains the application and its core tests.

Governor created the policy, planning rules, stack guides, terminology, and recurring issue records.
Its detected profiles are `apple` and `mobile` because the repository contains a native Xcode project.
Only macOS development is currently in scope.
The root agent guide defines that boundary.

The README contains local setup and user instructions.
The architecture and validation documents reside under `docs/`.
The Makefile provides local build and validation commands.
Build output resides under the ignored `.build/` directory.

## Local Validation

Validation date: September 23, 2026.

| Operation | Result |
| --- | --- |
| `make ci` | Passed: metadata, build, twelve core tests, Governor, and technical prose checks. |
| Governor consistency | Passed after the managed policy and ignore rules were updated. |
| Project metadata and Git whitespace | Passed. |
| Native application build | Passed for Apple silicon and Intel targets. |
| Core test suite | Twelve tests passed through the shared Xcode scheme. |
| Open repository folder in Xcode | Selected `Rhythm.xcodeproj`, scheme `Rhythm`, and destination `My Mac`. |
| Technical prose checks | Passed. |

The official ASD-STE100 Issue 9 reference passed its pinned digest verification.
Language review covered the new repository instructions, architecture, validation record, terminology additions, and I001.
The review used the applicable Part 1 rules and Part 2 dictionary entries.
The mechanical checker also examined the generated guidance.
These results do not constitute independent certification of the complete language standard.

## Environment

Validation used Xcode 27.0 (27A266a) and macOS 26.6.2 (25G83).
The compiler was Swift 6.4 in Swift 5 language mode.
The application deployment target is macOS 13.0.
The application uses local ad-hoc signing.
It has no third-party dependencies.

The build reports that App Intents metadata extraction was skipped.
The application has no AppIntents dependency.
This message does not prevent the native build.

## Behavior Evidence

Core tests cover the 60-minute, 90-minute, and 120-minute boundaries.
They also cover defer expiry, repeated events, pause history, resume notes, restart behavior, midnight, and daylight-saving changes.

Earlier native UI automation exercised the same application source before the repository move.
Those checks covered the popover, Settings, pause, resume, defer, overrun, notes, and History.
The latest UI revision uses real elapsed time and contains no visible test controls.

I001 records the remaining work for a repeatable application integration suite.
The current core tests and native build do not replace that suite.
The original scheme rejected the Xcode test action because it had no test configuration.
The shared scheme now supports the native test action.
No application behavior changed during repository organization.

## Remaining Qualification

macOS reported notification permission disabled during UI validation.
Actual banner delivery and delivery through Focus remain unverified.
The reminder state and intervention windows passed earlier UI checks.
The Focus service remains an explicit manual implementation.

System sleep was not induced during validation.
The earlier checks exercised the aggregate activity signal and automatic-pause path with controlled input.
Validation did not await five minutes of real inactivity.

Runtime checks used Apple silicon and the host's dark appearance.
Intel and macOS 13 were compilation targets, not separate runtime environments.
Local software environments are sufficient for this repository's device validation.

The public source publication does not constitute a signed application release.
Mac App Store preparation remains separate, as described in `MAC_APP_STORE.md`.
