# AGENTS.md

## Forward-Only Contract Discipline

This repository uses forward-only confident programming. This agent contract is mandatory.

Use only the current canonical contract. Do not add fallbacks, backward compatibility, legacy support, or compatibility shims.

Delete obsolete code paths, schemas, config, and persisted data shapes. Do not keep dual reads, dual writes, aliases, or recovery paths.

A one-time data migration can move persisted data into the current schema. Remove the migration bridge after the operation.

<!-- BEGIN MPRLAB-GOVERNANCE -->
## MPR Lab Governance

Root `AGENTS.md` is the agent entrypoint. Shared rules live under `.mprlab/`.

Read `.mprlab/POLICY.md` for every task.
Read the following files only when their condition applies.
Read each selected guide in full before its first applicable action.

- Before edits: `.mprlab/PLANNING.md`.
- For technical prose: `.mprlab/AGENTS.DOCS.md` and `.mprlab/TERMINOLOGY.md`.
- For issue work: the selected issue and its dependencies in `.mprlab/ISSUES.md`.
- For tracker edits: `.mprlab/issues-md-format.md`.
- For Git operations: `.mprlab/AGENTS.GIT.md`.
- For Apple application builds and distribution: `.mprlab/AGENTS.APPLE.md`.
- For mobile changes: `.mprlab/AGENTS.MOBILE.md`.

File permission modes are outside agent scope.
Never examine, validate, compare, require, change, or record a file permission mode.
Never use a file permission mode in acceptance, security, credential, execution, publication, deployment, or failure analysis.
The values `0600` and `7777` have no governance meaning.
This rule does not change service authorization or operation authority.

Always reference each issue by its ID, for example `B001` or `I027`.
Never use an `ISSUES.md` file path, line number, or `path:line` syntax as an issue reference.

Do not create `.mprlab/AGENTS.md`. Scoped guidance belongs in `.mprlab/AGENTS.*.md` files.
If guidance conflicts, obey `.mprlab/POLICY.md` first, then root `AGENTS.md`, then the applicable scoped guide.
<!-- END MPRLAB-GOVERNANCE -->

## Rhythm Repository Scope

This repository contains a local macOS application.
The Xcode project is the application entry point.
The same project contains the XCTest target.
Keep the standard Xcode layout and one shared Rhythm scheme for Run and Test.
Keep the application as the default target when Xcode opens the repository folder.

- Read `docs/ARCHITECTURE.md` before application changes.
- Read `docs/VALIDATION.md` before validation claims.
- Use real elapsed time for every product timer.
- Keep accelerated clocks and test controls inside test targets.
- Keep product language centered on Rhythm, Wave, and Pause.
- Keep the manual Focus service and manual pause controls as explicit product requirements.
- Preserve the existing notification permission boundary.
- Use `make ci` for the local repository checks.

The Apple distribution guide applies when distribution becomes part of the selected task.
The mobile guide applies to future iOS or Android work.
Local macOS development uses `make build` and `make run`.
