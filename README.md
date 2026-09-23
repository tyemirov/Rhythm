# Rhythm

Rhythm is a local macOS application in the menu bar.
It provides work periods, pause reminders, resume notes, and a daily history summary.
All product timers use real elapsed time.

## Local Development

Clone the repository before you open Xcode.

```bash
git clone https://github.com/tyemirov/Rhythm.git
cd Rhythm
```
The application requires macOS 13 or later and Xcode 15 or later.
Validation used Xcode 27.0 and macOS 26.6.2.
The project uses ad-hoc signing for local execution.
It requires no external packages or developer account.

1. Open the repository folder in Xcode.
2. Select the `Rhythm` scheme.
3. Select `My Mac` as the destination.
4. Press `Command-R`.
5. Open the Rhythm icon in the menu bar.
6. Select `Start`.

Use `Command-U` to execute the tests in the same scheme.
You can also open `Rhythm.xcodeproj` directly.

The application has no Dock icon.
The first application start opens the popover.

## Local Commands

Execute these commands from the repository root.

| Command | Result |
| --- | --- |
| `make build` | Build the application for local use. |
| `make run` | Build and open the application. |
| `make test` | Execute the core tests. |
| `make lint` | Do a check of project metadata and Git whitespace. |
| `make governance` | Do a check of Governor file consistency. |
| `make docs-check` | Verify the official language reference and check technical prose. |
| `make ci` | Execute all local repository checks. |

Build output stays in the ignored `.build/` directory.
`make ci` is a local command. It does not publish the application.
The Governor commands use the installed skill under `~/.codex/skills/mprlab-governor`.
Set `GOVERNOR_SKILL` when that installation path differs.

## Daily Use

| Elapsed work | Application behavior |
| --- | --- |
| 0–60 minutes | Quiet work with elapsed time in the popover. |
| 60 minutes | One notification and an optional chime: `A pause is available` |
| 90 minutes | A separate window: `Time for a pause` |
| 120 minutes | One overrun window: `This wave has run long` |

1. Select `Pause` to show the resume note field.
2. Enter a note if needed, then select `Begin pause`.
3. When you return, read the resume note.
4. Select `Continue` to start the next wave.
5. Open `Today’s waves` to see completed waves and pauses.
6. Select `Quit Rhythm` in Settings to close the application.

The suggested pause is five minutes.
Every third completed wave that day has a suggested fifteen-minute pause.
The application resumes only when you select `Continue`.
One five-minute defer is available through minute 115.
You can close the pause reminder or select `Keep working`.

## Notifications And Focus

1. Open the gear button in the popover.
2. Select `Enable reminders`.
3. Accept the macOS notification prompt.
4. If permission is disabled, enable Rhythm under `System Settings → Notifications`.
5. To receive reminders during Focus, add Rhythm to the selected Focus allowed-app list.

The 90-minute and 120-minute windows operate independently of notification permission.
The Focus preference uses a manual service.
It does not change macOS Focus automatically.
Use `Control Center → Focus` to change Focus when you start or pause work.

## Repository Map

| Path | Responsibility |
| --- | --- |
| `Rhythm/` | Application source and icon assets. |
| `Rhythm/Core/` | State transitions, timing rules, and history. |
| `Rhythm/Services/` | Notifications, Focus, input activity, and local storage. |
| `Rhythm/Views/` | Native SwiftUI views. |
| `RhythmTests/` | Core tests. |
| `Rhythm.xcodeproj/` | Application, XCTest target, and shared Rhythm scheme. |
| `.mprlab/` | Policy, planning rules, terminology, and issue records. |
| `docs/` | Architecture and validation records. |

[Architecture](docs/ARCHITECTURE.md) describes service boundaries and saved data.
[Validation](docs/VALIDATION.md) records completed checks and their limits.

## Product Terms

Rhythm is the application and the overall pattern of work and rest.
A wave is one uninterrupted work period.
A pause is the rest period between waves.
`Today’s waves` shows the daily history.
`Where to pick up` labels the resume note field.

`Pause` opens the note field while the wave continues.
`Begin pause` ends the wave and starts rest.
`Continue` ends rest and starts a new wave with its timer at zero.

## License And Distribution

Rhythm is a personal open-source project under the [MIT license](LICENSE).
The repository contains the source code and the local Xcode project.
The application is not yet available through the Mac App Store.
[Mac App Store preparation](docs/MAC_APP_STORE.md) records the required work and account decisions.
