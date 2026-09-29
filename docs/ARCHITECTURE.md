# Architecture

## Application Structure

`FlowApp.swift` owns the application lifecycle through an AppKit delegate.
The delegate creates the menu bar item, popover, and application windows.
SwiftUI renders all application views.
The application runs with the accessory activation policy.
`FlowStatusIcon` supplies the menu bar images from the work state.
The application icon, header, and History use the Met public-domain Great Wave image.
The timeline marker uses the 🌊 emoji.
The [artwork record](../artwork/README.md) identifies the source and generation command.
The menu bar item shows only an icon.
Ready uses the `water.waves` system symbol.
An active Wave shows the same symbol inside a filled circle.
Pause uses pause bars.
The tooltip and accessibility label give the current state.
During a Wave or Pause, they also give elapsed time.

The popover contains the main view, Settings, and History.
The main view includes the lab mark and name.
The lab name opens `https://mprlab.com/` in the default browser after a user action.
Settings contains the same website link.
Back returns from Settings or History to the main view.
`LabContent` defines the lab name and website address.
`LabWebsiteLink` supplies the shared SwiftUI link.

`FlowModel.swift` connects the engine, timer, services, and local storage on the main actor.
The model supplies observable state and explicit user commands to the views.
The views display that state and call those commands.

`Core/WaveEngine.swift` contains the Codable state machine.
Its states are `ready`, `working`, and `pause`.
It records wave durations, pause durations, resume notes, and reminder events.
The application and XCTest target compile this same source file in one Xcode project.
The tests execute independently of the application and its saved data.

## Time And State

A one-second timer updates the model.
Active time uses monotonic uptime differences.
Calendar dates identify history entries and daily totals.
System clock changes do not advance active work thresholds.

The engine emits each threshold event once per wave.
A delayed timer emits only the most relevant intervention.
One five-minute defer is available when the deadline fits before 120 minutes.
A pause ends only through an explicit user action.

The Pause display shows `Wave paused`, the saved `Wave time`, and the current `Pause time`.
Continue starts work again at the saved Wave duration.
Restart starts a new Wave at zero and keeps the previous time in History.
The saved Wave duration stays fixed during Pause.
Continue keeps reminder state and any defer deadline.
Restart sets the reminder state for the new Wave.

The application saves state at transitions and approximately every fifteen seconds.
It also saves changes to the resume note.
On restart, an active wave becomes a pause at the last saved checkpoint.
Time while the application was closed counts as recovery time.
An abrupt stop can lose approximately fifteen seconds of active work.

Mac sleep starts a pause.
Sleep duration counts as recovery time.
Wake does not start work or force a reminder.

## Services

| Service | Boundary |
| --- | --- |
| `NotificationService` | Public UserNotifications authorization and silent notifications. |
| `FocusControlling` | The interface for Focus integration. |
| `ManualFocusService` | The explicit manual Focus implementation. |
| `ActivitySensing` | The interface for aggregate input inactivity. |
| `SystemActivityService` | The public Quartz input counter. |
| `LocalStore` | Atomic JSON persistence. |

The documented Apple Focus interface provides status access, not a general system Focus setter.
The manual service records the requested preference and supplies user instructions.
It uses no private Apple API or system preference modification.

Optional inactivity detection starts a pause after five minutes without input.
The counter contains elapsed time only.
The application captures no keystrokes, window titles, screenshots, or individual input events.
It installs no event tap and requests no Accessibility or Input Monitoring permission.
Reading and thinking can appear as inactivity.
The first five inactive minutes remain part of the wave.
Manual pause and resume controls remain available when the activity signal is unavailable.

## Local Data

State resides in `~/Library/Application Support/RhythmPrototype/history.json`.
The settings domain is `com.mprlab.RhythmPrototype`.
These fixed local identities keep existing history, preferences, and notification permission when the application name changes.
`FlowIdentity` defines the application name, data directory, local bundle identifier, and wave asset name.
The application has one storage path and one preferences domain.
The application has no network service, analytics, account, or cloud synchronization.
The lab website link sends no resume notes, History, or preferences to the browser.

Resume notes have a 2,000-character limit.
History keeps up to ninety days when an entry is completed.
A daily total allocates each completed duration by its calendar-day overlap.
Wave counts use the completion date.

A continued Wave keeps one history entry and its identifier.
That entry records its pause intervals.
Daily work totals do not include those intervals.
History includes a continued Wave's previously recorded work while its new work time increases.
The entry moves to the end of History when work stops again.
The active Wave or Pause duration appears separately from recorded totals.

A failed read preserves the existing file and displays an error.
That process then keeps new state in memory.
A failed write also displays an error.
These behaviors preserve local data at the storage boundary.

## Validation Boundary

The repository has twenty-five headless tests and a native application build.
The `FlowUITests` target checks menu bar icons through the running application.
The shared Flow scheme runs both test targets.
`make test` and `make ci` select only `FlowTests` by default.
These commands execute no desktop UI automation.
The native UI suite uses `AppTestHome` to create an application test home.
Each home contains an application copy with a unique bundle identifier and local ad-hoc signature.
The unique identifier gives each test its own UserDefaults domain.
`CFFIXED_USER_HOME` directs application files to the temporary directory.
Cleanup removes that directory and the test preferences.
The headless fixture test checks the application copy, file writes, preference separation, and cleanup.
Headless view tests measure playback controls through `NSHostingView` without an attached window.
They compare timeline marker pixels through `ImageRenderer` and find footer text through Vision.
These checks open no application window or browser.
Earlier native UI automation checked pause, resume, defer, overrun, and History behavior.
A repeatable application integration suite remains open under I001.
Core tests alone do not establish complete application acceptance.

## Public API References

- [Apple Focus status](https://developer.apple.com/documentation/intents/infocusstatuscenter)
- [Apple notification levels](https://developer.apple.com/documentation/usernotifications/unnotificationinterruptionlevel)
- [Apple Quartz input timing](https://developer.apple.com/documentation/coregraphics/cgeventsource/secondssincelasteventtype(_:eventtype:))

## Work Actions

`WaveAction` supplies the primary action label from the work state and note preparation state.
It also supplies the playback controls, system symbols, and tooltips.
Ready has one play control.
Work has restart and pause controls.
Pause has restart and play controls.
The controls keep explicit accessibility labels.
Each playback control is 28 points wide and 24 points high.
The space between controls is four points.

The work states are `ready`, `working`, and `pause`.
`WaveStage` describes the reminder threshold within a wave.
`HistoryEntry` records a completed wave or pause.
Saved history uses the `wave` entry kind and the `working` work state.
The local history conversion preserved entry identifiers, notes, dates, and durations.
