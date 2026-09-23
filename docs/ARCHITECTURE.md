# Architecture

## Application Structure

`RhythmApp.swift` owns the application lifecycle through an AppKit delegate.
The delegate creates the menu bar item, popover, and application windows.
SwiftUI renders all application views.
The application runs with the accessory activation policy.

`RhythmModel.swift` connects the engine, timer, services, and local storage on the main actor.
The model supplies observable state and explicit user commands to the views.
The views display that state and call those commands.

`Core/RhythmEngine.swift` contains the Codable state machine.
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
These application identifiers remain stable when the source repository moves.
The application has no network service, analytics, account, or cloud synchronization.

Resume notes have a 2,000-character limit.
History keeps up to ninety days when an entry is completed.
A daily total allocates each completed duration by its calendar-day overlap.
Wave counts use the completion date.
The current segment appears separately from completed totals.

A failed read preserves the existing file and displays an error.
That process then keeps new state in memory.
A failed write also displays an error.
These behaviors preserve local data at the storage boundary.

## Validation Boundary

The repository has twelve core tests and a native application build.
Earlier native UI automation checked pause, resume, defer, overrun, and History behavior.
A repeatable application integration suite remains open under I001.
Core tests alone do not establish complete application acceptance.

## Public API References

- [Apple Focus status](https://developer.apple.com/documentation/intents/infocusstatuscenter)
- [Apple notification levels](https://developer.apple.com/documentation/usernotifications/unnotificationinterruptionlevel)
- [Apple Quartz input timing](https://developer.apple.com/documentation/coregraphics/cgeventsource/secondssincelasteventtype(_:eventtype:))

## Work Actions

`WaveAction` supplies the primary action label from the work state and note preparation state.
The work states are `ready`, `working`, and `pause`.
`WaveStage` describes the reminder threshold within a wave.
`HistoryEntry` records a completed wave or pause.
Saved history uses the `wave` entry kind and the `working` work state.
The local history conversion preserved entry identifiers, notes, dates, and durations.
