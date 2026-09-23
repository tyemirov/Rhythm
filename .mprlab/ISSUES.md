# ISSUES

Entries record newly discovered requests or changes.

Read `AGENTS.md` and its task-specific references before changes.

Format: `- [ ] [B042] (P1) {I007} Title`

## BugFixes

## Improvements

- [ ] [I001] (P2) Add repeatable application integration coverage
  Goal:
  Verify the existing user flow through the native application entry point.

  Requirements:
  - Add an integration target with the real engine, model, and views.
  - Inject a controlled clock through the test target.
  - Keep test controls outside the visible application.
  - Cover Start, Pause, Begin pause, Continue, defer, overrun, persistence, and wave history.
  - Keep notification delivery qualification separate from controlled service tests.

  Deliverables:
  - A repeatable integration command in the Makefile.
  - Integration coverage in the local CI command.

  Validation:
  - Execute the integration command from a clean primary checkout.
  - Verify observable results through the application entry point.
  - Execute `make ci` after the final change.


- [ ] [I002] (P2) Explore input activity as a signal for pause reminder timing
  Goal:
  Evaluate whether local input activity can help Rhythm select a natural moment for a pause reminder.
  This issue records an exploratory idea, not approval to implement monitoring.

  Requirements:
  - Evaluate aggregate keyboard and pointer activity without analysis of input content.
  - Evaluate microphone use separately from detection of the user speaking.
  - Identify public macOS APIs, required permissions, accuracy limits, and resource costs for each signal.
  - Keep elapsed Wave time separate from interaction level and recovery time.
  - Treat interaction as a possible engagement signal, not a measurement of mental effort or productivity.
  - Include quiet reading, reasoning, video study, routine typing, and meeting participation in the evaluation.
  - Evaluate a short, bounded wait for an interaction lull after the 60-minute reminder threshold.
  - Preserve the 90-minute pause intervention and the overrun boundary regardless of interaction level.
  - Keep quiet work distinct from a confirmed pause.
  - Require explicit user choice for any future activity collection.
  - Keep aggregate processing local and define minimal retention.
  - Exclude stored keystrokes, audio recordings, transcripts, and input content from the proposed design.
  - Explain whether speech detection requires transient audio processing, even when no recording is stored.

  Deliverables:
  - A feasibility note with signal limitations, permission requirements, and a proposed reminder policy.
  - A recommendation to proceed, narrow the idea, or retain the current behavior.
  - Open decisions for the maximum reminder delay, microphone scope, retention, and user controls.
  - A separate implementation proposal if the evaluation supports further work.

  Validation:
  - Support API feasibility claims with current official Apple documentation.
  - Compare the proposed policy with elapsed-time reminders across the listed scenarios.
  - Confirm that sustained input cannot postpone reminders indefinitely.
  - Confirm that absent input does not establish rest or low mental effort.
  - Review the proposed data flow for content collection and retention.


- [ ] [I003] (P2) Polish the Rhythm interface with native macOS controls
  Goal:
  Make every Rhythm view clear, consistent, accessible, and quiet during work.
  Use standard SwiftUI and AppKit controls wherever they meet the product requirements.

  Evidence:
  - Source review on September 20, 2026 covered `Rhythm/Views/RhythmViews.swift` and `Rhythm/RhythmApp.swift`.
  - `NoteEditor` draws a custom border and focus indicator around a plain text field.
  - `WaveTimeline` uses fixed positions, 10-point labels, and a 60-point action area.
  - Settings and history use fixed content heights of 500 and 440 points.
  - Several actions use plain button styles, while the primary action uses a custom fixed color.
  - The microphone opens Dictation instructions rather than starting speech input.
  - Pause preparation resides in local view state, which can reset when navigation recreates the main view.
  - The source already uses native buttons, a grouped Form, toggles, and reduced-motion detection.
  - These findings identify review targets. They do not establish a failure in every appearance or accessibility configuration.

  Requirements:
  - Preserve the single menu-bar popover, internal Settings and history pages, Back navigation, and icon-only page headers.
  - Preserve the continuous color timeline, small elapsed time, wave marker, and compact working view.
  - Keep one primary control with these transitions: ready → Start, working → Pause, note preparation → Stop, resting → Continue.
  - Keep the action label and its behavior under one explicit state contract.
  - Preserve the note and pending action through internal navigation and popover dismissal.
  - Keep Quit Rhythm in Settings and the microphone inside the note field.
  - Prefer standard button styles, control sizes, text editing, selection, scrolling, focus indicators, and system text styles.
  - Use semantic system colors and materials for ordinary controls and surfaces.
  - Reserve custom drawing for the timeline and approved wave identity.
  - Record a reason for each remaining custom control treatment.
  - Align icons, text, spacing, and action sizes across all pages and intervention views.
  - Adapt content height to the available screen area and provide scrolling when necessary.
  - Keep Back visible while detail content scrolls.
  - Prevent clipping, overlapping text, unwanted horizontal scrolling, and layout jumps during navigation or timer updates.
  - Keep the timeline marker within its bounds at zero, each threshold, and beyond 120 minutes.
  - Expose elapsed time and reminder state through text and accessibility values as well as color.
  - Provide clear keyboard focus, a logical traversal order, accessible control names, and useful help text.
  - Preserve native text editing, undo, selection, and macOS Dictation in the note field.
  - Make the microphone purpose explicit before activation. Distinguish Dictation help from actual microphone capture.
  - Keep this issue independent of a new speech service or new microphone permissions.
  - Preserve reminder timing, local data, manual Focus behavior, and all existing user actions.

  Deliverables:
  - A control inventory with native replacements and reasons for retained custom views.
  - Updated views with a small shared set of spacing, typography, and control-size rules.
  - A transition table covering labels, actions, note visibility, and navigation persistence.
  - Before-and-after images for the main states, Settings, history, and intervention views.
  - Updated user instructions and repeatable UI checks coordinated with I001.

  Validation:
  - Verify the real application through native UI automation with controlled clocks only in test targets.
  - Cover ready, active, note preparation, resting, continued work, reminder thresholds, and overrun states.
  - Cover empty history, populated history, long notes, storage errors, and notification permission states.
  - Verify Settings → Back and Today’s waves → Back without loss of note or pending action.
  - Verify keyboard-only operation, VoiceOver labels, text editing, and Dictation availability.
  - Examine light and dark appearances, increased contrast, reduced transparency, and reduced motion.
  - Examine larger text settings and available screen heights, including 768 points.
  - Record actual runtime evidence and any unverified system integration separately.
  - Use local macOS software validation without physical-device prerequisites.
  - Run `make ci` after the final implementation change.

  References:
  - Apple Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/designing-for-macos
  - Apple accessibility guidance: https://developer.apple.com/design/human-interface-guidelines/accessibility
  - Related issue: I001 covers the broader application integration suite.

## Maintenance

- [ ] [M400R] (P2) Backlog hygiene and archive
  Goal:
  Keep the issue tracker reliable, readable, and focused on active work while preserving resolved history in the appropriate archive.

  Requirements:
  - Cadence: run weekly during active development and before each release cut.
  - Validate section names, identifier prefixes, recurrence suffixes, priority markers, dependencies, and duplicate IDs against the current `issues-md-format.md`.
  - Reconcile stale statuses, duplicate issues, broken references, obsolete instructions, and entries filed in the incorrect section.
  - Before archival, update source documents with durable results from each resolved non-recurring issue.
  - Preserve the complete issue entry and its ID in the repository archive.
  - Keep active, blocked, planning, and recurring entries visible in `ISSUES.md`.

  Deliverables:
  - Normalized `ISSUES.md` structure and statuses.
  - Updated archive with complete entries removed from the active tracker.
  - A short `Last run:` note summarizing the cleanup and any follow-up issues filed.

  Validation:
  - Read `ISSUES.md` after edits and confirm that each issue is in the correct section.
  - Confirm that each issue has a unique section-aware ID.
  - Confirm recurring entries remain open and keep the `R` suffix.
  - Confirm no active, blocked, recurring, or planning work was archived.

- [ ] [M401R] (P2) Polish open issues
  Goal:
  Keep unresolved work executable by making each open issue concrete, ordered, and testable.

  Requirements:
  - Cadence: run weekly during active development and before handing a repo to automated execution.
  - Review every unresolved non-recurring issue for missing context, dependencies, repro steps, acceptance criteria, and validation expectations.
  - Make priorities concrete and make sure that each open issue has actionable deliverables.
  - Merge duplicate open issues or add explicit dependency links when separate entries must remain.
  - Do not close or implement issues as part of this polish pass unless that work is separately requested.

  Deliverables:
  - Open issues with enough detail for a person or agent to execute without rediscovery.
  - New or updated dependency markers where ordering matters.
  - A short `Last run:` note listing the number of issues polished and any blockers found.

  Validation:
  - Sample the open entries after the pass and confirm each has clear next actions and validation expectations.
  - Confirm that no recurring runbook has a closed status.
  - Confirm duplicates were merged or explicitly cross-referenced.

- [ ] [M402R] (P2) Architecture and policy review
  Goal:
  Catch architecture, policy, and workflow drift before it becomes hidden maintenance debt.

  Requirements:
  - Cadence: run monthly, before large refactors, and after major framework or runtime changes.
  - Review the codebase, docs, and workflow against `AGENTS.md`, `POLICY.md`, stack guides, and the current architecture notes.
  - Look for drift from forward-only contracts, edge-validation boundaries, smart-constructor usage, testing policy, and module ownership.
  - Classify each finding by its requested outcome. Record concrete scope, priority, and validation.
  - Close the pass with a no-action note only when the review finds no actionable drift.

  Deliverables:
  - Correctly classified issues for each actionable architecture or policy drift finding.
  - Updated notes on areas reviewed and areas intentionally left unchanged.
  - A short `Last run:` note with the review scope and outcome.

  Validation:
  - Confirm every finding is represented as an issue with owner-readable context and validation criteria.
  - Confirm no implementation changes were mixed into the review runbook unless separately requested.
  - Confirm all recurring runbooks remain open.

- [ ] [M403R] (P1) Dependency and security audit
  Goal:
  Keep third-party dependencies, runtime versions, and security-sensitive configuration within the current supported contract.

  Requirements:
  - Cadence: run weekly for active apps and before each release cut.
  - Inspect package managers, lockfiles, language toolchains, container bases, and generated clients for known vulnerabilities or stale direct dependencies.
  - Review auth, secret, CORS, CSP, SQL, network, and service-authorization configuration for drift from the current contract.
  - Prefer current supported dependencies.
  - Do not add compatibility shims for obsolete dependency behavior.
  - File each actionable vulnerability, unsupported runtime, or security-contract gap under its outcome-based issue section.

  Deliverables:
  - Documented audit commands or data sources used for the pass.
  - Updated issues for each actionable dependency or security finding.
  - A short `Last run:` note with clean result or follow-up issue IDs.

  Validation:
  - Rerun the repository-native audit, lint, or dependency checks used for the pass.
  - Confirm every finding is either filed, fixed under a separate issue, or explicitly marked not applicable with evidence.
  - Confirm no secrets or private payloads were written into the tracker.

- [ ] [M404R] (P1) CI, release, and artifact health
  Goal:
  Keep the repository's validation, release, publication, and generated artifact surfaces trustworthy.

  Requirements:
  - Cadence: run before every release, publish, or deploy, and weekly for critical services.
  - Verify repository-native CI, lint, format, coverage, release, publish, Docker image, Pages, and artifact workflows still match the documented contract.
  - Do a check of generated artifacts, release tags, published images, and Pages outputs for source-to-public drift.
  - File concrete follow-up issues for failing gates, stale artifacts, missing release prerequisites, or undocumented workflow changes.
  - Do a production deployment only when the operator explicitly requests it.

  Deliverables:
  - Recorded gate status and artifact surfaces inspected.
  - Follow-up issues for each reproducible CI, release, publish, or artifact drift problem.
  - A short `Last run:` note with commands run and any skipped surfaces.

  Validation:
  - Use repository-native `make` targets or documented release helpers for checks.
  - Confirm release and deployment ownership boundaries remain separate.
  - Confirm public or published artifacts match the intended source revision when that surface is inspected.

- [ ] [M405R] (P1) Code contract and static hygiene
  Goal:
  Keep source contracts explicit, current, and statically guarded against policy drift.

  Requirements:
  - Cadence: run monthly and before large refactors.
  - Scan for dead code, unused exports, duplicated literals, silent fallbacks, legacy aliases, compatibility reads, and zero-but-invalid domain states.
  - Do a check of static analysis, coverage, schema, and contract guards that prevent drift.
  - File each concrete violation under its outcome-based issue section.
  - Keep only the current canonical contract.
  - Preserve obsolete behavior only when a current product requirement explicitly specifies it.

  Deliverables:
  - Issue entries for each actionable static hygiene or contract violation.
  - Notes on static tools, searches, and contract guards used during the pass.
  - A short `Last run:` note with clean result or follow-up issue IDs.

  Validation:
  - Rerun the relevant static checks, contract tests, or repository searches used to identify drift.
  - Confirm every finding has a narrow follow-up issue and does not duplicate existing backlog work.
  - Confirm no implementation changes were mixed into the audit unless separately requested.

- [ ] [M406R] (P1) Production drift and health
  Goal:
  Detect drift between runtime state and the intended repository contract.

  Requirements:
  - Cadence: run weekly for deployed services and after each publish or deploy.
  - Compare current source, runtime configuration, published images, public routes, scheduled jobs, and health checks for drift.
  - Inspect real operator-facing surfaces rather than assuming merged source is deployed.
  - File follow-up issues for stale images, stale Pages output, missing routes, failed monitors, invalid production config, or undocumented runtime differences.
  - Stop before production deploy or destructive operator actions unless the operator explicitly requests them.

  Deliverables:
  - Recorded source revision, public artifact, route, image, or health surfaces inspected.
  - Follow-up issues for each source-to-runtime drift finding.
  - A short `Last run:` note with evidence links or commands used.

  Validation:
  - Verify inspected production or public surfaces directly where access is available.
  - Confirm any deploy-required finding is filed with the exact publish/deploy boundary and owner.
  - Confirm no production state was changed by the audit unless explicitly requested.

- [ ] [M407R] (P2) Documentation and runbook hygiene
  Goal:
  Keep durable documentation and runbooks aligned with the current behavior users and operators actually rely on.

  Requirements:
  - Cadence: run before release cuts and after merge bursts that change user-facing or operator-facing behavior.
  - Review README, ARCHITECTURE, PRD, CHANGELOG, docs, runbooks, setup guides, and local workflow notes for stale behavior or missing new contracts.
  - Review changed English technical prose against `.mprlab/AGENTS.DOCS.md` and the official ASD-STE100 standard.
  - Add approved repository terms to `.mprlab/TERMINOLOGY.md`.
  - Update docs when closed issues changed durable behavior, public APIs, operator workflows, release semantics, or deployment expectations.
  - Remove or rewrite stale instructions instead of preserving obsolete alternatives.
  - File separate issues for documentation gaps that require product or implementation decisions.

  Deliverables:
  - Updated documentation or filed follow-up issues for each gap.
  - A short `Last run:` note listing docs inspected and changes made.
  - Cross-references from archived issue history to durable docs when useful.

  Validation:
  - Run the skill `prepare-ste-reference` script and use its verified official PDF.
  - Run the skill `check-ste` script on each English technical document that changed.
  - Review the changed text against Part 1 writing rules and the Part 2 dictionary.
  - Confirm that the producing agent completed the review without end-user work.
  - Do a check of links, command names, paths, and public contract descriptions changed by the pass.
  - Confirm docs describe the current canonical path only.
  - Confirm issue archive and active tracker references remain consistent.

## Features

## Planning
