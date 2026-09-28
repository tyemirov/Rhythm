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
| Open repository folder in Xcode | Selected `Flow.xcodeproj`, scheme `Flow`, and destination `My Mac`. |
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

## I004 Preparation Checks

Validation date: September 23, 2026.

`make ci` passed after the preparation changes.
The check included the native build, twelve core tests, privacy manifest, cloud request, Governor, and technical prose.
The initial privacy check failed because the built application had no `PrivacyInfo.xcprivacy` resource.
The check passed after the manifest was added to the application resources.

`make cloud-plan` validated the `MACOS` request with `APP_STORE_ELIGIBLE` through the installed Gateway runtime.
The command made no provider calls.
It did not verify Apple account registration or the existence of the cloud workflow.

The first CI run found a new Python profile from the privacy checker.
The checker now uses Swift and Foundation.
Governor and the final CI run passed with the existing repository profiles.

The new prose passed the mechanical check.
Language review covered the changed preparation notes and the new privacy, support, and submission documents.
The official reference passed its pinned digest check.
The review used the applicable Part 1 rules and Part 2 dictionary entries.

I004 remains blocked by I001 and the absent Gateway lifecycle resource for macOS store distribution.
The application identity, sandbox state, and existing user data did not change.
Native sandbox validation, final screenshots, asset rights approval, and the one-time import decision remain pending.
No signed build, upload, TestFlight operation, or submission was performed.

## Lab Project Links

Validation date: September 28, 2026.
Validation used Xcode 27.0 and the macOS 27.0 software environment on Apple silicon.

The main popover now contains the lab mark, lab attribution, and `More from the lab`.
Settings contains `About Flow & the lab`.
Both controls open the same lab project page.
The page contains Gravity Notes, Countdown Calendar, Hecate, and the full project catalog link.

The two native application tests failed before the required controls were added.
`make test-ui` passed after the application changes.
The final `make ci` run passed the build, privacy check, and all fourteen tests.
The test count includes twelve core tests and two native application tests.
The native tests verified project addresses, Back navigation, and the resume note after navigation.

Native interface review covered the footer and project page in dark appearance.
The full catalog link opened `https://mprlab.com/#projects` in Chrome, the default browser.
The three featured project websites returned HTTP 200 during the link check.
Flow makes no request for project content.

The full CI command then failed in the existing `cloud-plan` target.
The installed `apple-cloud-operation` command rejected `--source-commit` as an unknown flag.
A separate `make governance` check also failed.
The managed contents of `.mprlab/POLICY.md` and `.mprlab/issues-md-format.md` differ from the installed Governor contract.
These existing build plan and governance failures remain outside the lab interface change.
The technical documents passed the mechanical language check.
The language review covered the changed prose against the verified official reference.

## Menu Bar Icons

Validation date: September 28, 2026.
Validation used Xcode 27.0 and the macOS 27.0 software environment on Apple silicon.

An obsolete application copy was also running from an earlier build directory.
That copy was closed through its Quit control.
The application from this checkout is the current local build.

The menu bar item has an empty visible title in Ready, Wave, and Pause.
Ready shows a plain waveform icon.
An active Wave shows a filled waveform circle.
Pause shows pause bars.
The tooltip and accessibility label give the current state.

The new native test failed before the Wave state indication was added.
The test passed after the application change.
It verified different icon images across Ready, Wave, and Pause.
It also verified the Wave icon after Continue and the empty visible title through all transitions.
XCTest supplied an isolated home directory for the test application.
The test removed that directory after the application closed.
Product timers used real elapsed time.

The final repository run passed the build, privacy check, and all fifteen tests.
The test count includes twelve core tests and three native application tests.
Full CI then stopped at the existing unsupported `--source-commit` flag in `cloud-plan`.
The previously recorded governance drift also remains unresolved.

## Pause Time Display

Validation date: September 28, 2026.

The Wave duration stops when Pause starts.
Pause time includes time while Flow is closed.
Continue starts a new Wave at zero.
The display now shows `Wave paused`, `Pause time`, and `Continue starts a new Wave.`
Time calculation did not change.

A headless integration test saves a one-hour Wave and restores a Pause after 95 hours.
The test verifies that Pause time advances and the completed Wave duration stays fixed.
It also verifies that Continue starts a new Wave at zero and preserves the resume note.
A format test checks the Pause text, including `Pause time: 95:08:49`.
The tests use an isolated file through the real local storage boundary.

The operator selected verification without screen interaction.
`make test` and `make ci` now select the headless `FlowTests` target by default.
The final run passed the build, privacy check, and fourteen headless tests.
Full CI then stopped at the existing unsupported `--source-commit` flag in `cloud-plan`.

The initial desktop test failed because the Pause explanation was absent.
Later desktop test attempts failed at unavailable controls or a text-value assertion.
Those tests were removed from the selected validation lane after the operator selected headless tests.
The final display has no visual acceptance claim.

## Review Fixes

Validation date: September 28, 2026.

The cloud request no longer supplies the unsupported `--source-commit` flag.
`make cloud-plan` passed through the installed Gateway runtime without provider calls.
The submission instructions now name the `Begin pause` control.

Both native UI test suites use the shared `AppTestHome` fixture.
Each test receives an application copy with a unique bundle identifier and a local ad-hoc signature.
`CFFIXED_USER_HOME` directs application files to the application test home.
The unique identifier gives each test its own preferences.
Cleanup removes the application files and test preferences.

The initial headless test failed when the home directory was not changed.
Further checks showed that the home setting alone did not give UserDefaults a separate domain.
The final test passed with the unique test identifier.
The test verified application metadata, Foundation file writes, UserDefaults, and cleanup through a background executable.
The test opened no application window and used no screen interaction.

The final `make ci` run passed metadata checks, the application build, the privacy check, fifteen headless tests, and the cloud request.
It then stopped at the existing Governor drift in `.mprlab/POLICY.md` and `.mprlab/issues-md-format.md`.
Those managed files differ from the installed Governor contract.
The technical documents passed the separate mechanical language check.
The language review covered the changed prose against the verified official reference.

## Flow Name And Great Wave Icons

Validation date: September 28, 2026.

Flow is the application name.
Wave identifies one continuous work period.
Pause and Continue remain ordinary control labels.
The initial work control now shows `Start wave`.
Source types, directories, Xcode targets, and the shared scheme use the current vocabulary.
The built application is `Flow.app`.
The source repository address remains unchanged.

The fixed local bundle identifier and data directory remain unchanged.
This choice keeps existing history, preferences, and notification permission.
The saved state schema remains unchanged.
The application uses one storage path and one preferences domain.

The application icon uses the Met public-domain Great Wave image.
The [artwork record](../artwork/README.md) gives the source, rights evidence, digest, and generation command.
The menu bar uses a wave crest when ready and the crest inside a filled circle during work.
Pause uses pause bars.
The menu bar remains an icon without a visible application name.
Obsolete screenshots were removed because they show the previous identity.

The fourteen engine and persistence tests passed before the source refactor.
The new built-application test failed because the requested application name and assets were absent.
The action label test failed before `Start wave` was added.
The headless tests verify built metadata, icon resources, fixed data identities, and distinct state icon pixels.
They use the real engine transitions and local persistence.
These tests open no application window and use no screen interaction.

The final `make ci` run passed metadata, build, privacy, seventeen headless tests, and the cloud request.
It then stopped at the existing Governor drift in `.mprlab/POLICY.md` and `.mprlab/issues-md-format.md`.
Those two files were unchanged by this task.
The separate document check passed.
Language review covered the changed prose against the verified Part 1 rules and Part 2 dictionary.
The vocabulary scan found only fixed local identities and existing repository addresses with the previous name.
