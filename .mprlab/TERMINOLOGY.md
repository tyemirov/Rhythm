# Repository Terminology

This file contains the approved technical nouns and technical verbs for repository documentation.

Use this file with `.mprlab/AGENTS.DOCS.md` and ASD-STE100 Simplified Technical English, Issue 9.

Do not add a general dictionary word to this file. Use the ASD-STE100 dictionary for general words.

Give each term one meaning. Use the same term for the same concept in all documents.

## MPR Lab Technical Nouns

- `DNS`: The system that resolves a hostname to its network destination.
- `TLS`: The protocol that protects communication between a client and a server.

- `emulator`: Software that reproduces a device runtime for application tests.
- `physical device`: Hardware used to run an application or do a device test.
- `simulator`: Software that models a device environment for application tests.
- `acceptance criteria`: Conditions that show that a change has the necessary behavior.
- `active issue tracker`: The canonical file that contains current work.
- `ADR`: An architecture decision record.
- `adapter`: A code unit that connects a core module to an external system.
- `agent guide`: A file that gives binding instructions to an agent.
- `API`: A repository-owned application programming interface.
- `API contract`: The canonical schema and behavior of an API.
- `ASD-STE100`: The Simplified Technical English standard for technical documentation.
- `architecture`: The structure, boundaries, and ownership of a software system.
- `App Store Connect`: The Apple service that receives and manages Apple store artifacts.
- `artifact`: A file or image that a build, release, or generator creates.
- `backlog`: The set of unresolved issues in the active issue tracker.
- `backend client`: A code unit that sends requests to a backend.
- `browser frontend`: A user interface that operates in a web browser.
- `build`: A process or output that converts source code into an artifact.
- `changelog`: A file that records completed changes for releases.
- `characterization test`: An integration test that records current public behavior before a refactor.
- `CI`: The repository continuous-integration system.
- `CLI`: A command-line interface.
- `code path`: A sequence of operations in source code.
- `config`: Source-controlled configuration data.
- `container`: An isolated runtime package with an application and its dependencies.
- `contract`: A binding definition of behavior, data, or ownership.
- `credential`: A private value that an external service uses to authenticate an identity.
- `documentation`: Technical information in repository documents.
- `coverage`: Evidence that tests exercise specified behavior.
- `dependency`: An external or internal component that a system requires.
- `dependency injection`: A design that supplies a component's dependencies from outside that component.
- `deployment`: An operation that changes a runtime environment.
- `domain type`: A type that represents validated domain data.
- `EAS`: Expo Application Services for hosted build, submission, and update operations.
- `endpoint`: One HTTP API address and its operation.
- `end user`: The person who requests or receives the agent work.
- `environment file`: A private file that contains environment variable assignments.
- `environment variable`: A named process input.
- `Expo`: A framework and source config system for React Native mobile clients.
- `Expo CLI`: The Expo command-line tool for local development and native project generation.
- `file permission mode`: A number or symbol that gives filesystem access bits.
- `Google Play`: The Google service that receives and manages Android store artifacts.
- `GitHub Pages`: The GitHub service that hosts a static website from a repository branch.
- `issue`: One tracked unit of work.
- `issue tracker`: A file or system that contains issues.
- `integration test`: A test of real product logic and component interactions through a public entry point, with controlled dependencies when necessary.
- `inverted test pyramid`: The MPR Lab test strategy with integration tests as the primary layer and focused unit tests where useful.
- `language checker`: A tool that finds specified language errors.
- `language review`: An agent-owned examination of text against language rules and terminology.
- `manifest`: A source-controlled file that declares resources or configuration.
- `mobile client`: An application for a mobile platform.
- `mobile store artifact`: A signed `.ipa` or `.aab` file for store publication.
- `native toolchain`: The platform tools that build and sign a mobile store artifact.
- `payload`: Structured data that crosses a system boundary.
- `PDF`: A file that uses the Portable Document Format.
- `PRD`: A product requirement document.
- `private input channel`: A documented process environment, anonymous pipe, or private file input.
- `production code`: Source code that implements repository behavior outside the test suite.
- `producing agent`: The agent that creates or changes technical prose.
- `public entry point`: An interface through which a user or caller uses repository behavior.
- `pull request`: A proposed Git change for review and merge.
- `repository`: A source-controlled project and its files.
- `reference cache`: A private local directory that stores a verified official reference.
- `route`: An API or user-interface address and its handler.
- `runbook`: A technical procedure for an operator or agent.
- `runtime`: An operating instance of a service or application.
- `schema`: A machine-readable definition of structured data.
- `SHA-256`: A cryptographic digest that identifies the verified official reference.
- `source code`: Human-readable instructions that define software behavior.
- `source blocker`: A failure that prevents access to a necessary official source.
- `stack guide`: An agent guide for one language, framework, or runtime.
- `STE reference`: The verified official ASD-STE100 PDF that controls a language review.
- `store publisher`: A repository-owned tool that submits a mobile store artifact directly to its store.
- `static website`: A browser frontend that uses generated files without a website server runtime.
- `technical document`: A repository document that contains technical information or instructions.
- `technical noun`: A subject-field noun that the repository approves.
- `technical prose`: English technical text outside code and source-controlled literals.
- `technical verb`: A subject-field verb that the repository approves.
- `test-driven development`: A coding sequence that uses a failing integration test before a production code change.
- `unit test`: A test that isolates one code unit from its collaborators.
- `validation`: Evidence that a change obeys its current contract.
- `worktree`: A Git checkout that has its own working directory.
- `website hostname`: The hostname that identifies a public static website.

- `keychain`: A macOS database that holds credentials and controls private key access.
- `PKCS#12 file`: A file that contains a certificate and its private key.
- `provisioning profile`: An Apple authorization record that connects an application identifier to a certificate and distribution method.
- `signing identity`: A certificate and its corresponding private key for code signing.
- `preparation digest`: A content hash of the recorded inputs for a generated native project.

## Repository Technical Nouns

- `App Sandbox`: The macOS boundary that restricts application access to system resources.
- `TestFlight`: The Apple service for application tests before public store distribution.
- `bundle identifier`: The unique identifier of an Apple application.
- `privacy manifest`: The Apple declaration of specified API use and data practices.
- `entitlement`: A signed declaration of an application capability.
- `UserDefaults`: The Apple API for saved application preferences.

- `Rhythm`: The local macOS application and the overall pattern of work and pauses.
- `Wave`: One continuous work period in Rhythm.
- `Pause`: A recovery period between waves.
- `History`: The summary of completed waves and pauses.
- `Focus`: The macOS feature that controls notification delivery.
- `AppKit`: The Apple framework for native macOS windows and controls.
- `SwiftUI`: The Apple framework for declarative user interfaces.
- `Xcode`: The Apple application development tool.
- `Xcode scheme`: The shared definition of build, run, and test actions.
- `menu bar`: The macOS surface that contains the Rhythm status item.
- `popover`: The temporary window below the Rhythm status item.
- `resume note`: The user text that identifies the next work step.
- `checkpoint`: A saved copy of the current application state.
- `uptime`: The monotonic system time used for active duration calculations.
- `JSON`: The text format used for saved application state.
- `Quartz`: The Apple framework that provides the aggregate input counter.
- `Make`: The tool that executes the repository command targets.
- `Governor`: The MPR Lab skill that manages repository guidance.
- `ad-hoc signing`: Local application signing without a distribution identity.
- `XCTest`: The Apple framework used by the core test suite.

```text
- `term`: Definition with one meaning.
```

## MPR Lab Technical Verbs

- `sign`: Apply a cryptographic signature to an artifact with a private key.

- `archive`: Move completed history from the active issue tracker to durable storage.
- `authenticate`: Confirm the identity of a client or user.
- `authorize`: Confirm that an identity can do an operation on a resource.
- `build`: Convert source code into an executable or generated artifact.
- `cache`: Store a verified reference outside a target repository for repeated use.
- `commit`: Record a Git change in repository history.
- `configure`: Set source-controlled values that control system behavior.
- `deploy`: Change a runtime environment to use a specified artifact and configuration.
- `file`: Add an issue to the active issue tracker.
- `generate`: Create an artifact from its canonical source.
- `lint`: Use static rules to find source or document errors.
- `merge`: Add the changes from a pull request to its target branch.
- `normalize`: Change a file to obey one canonical format or contract.
- `parse`: Convert input data into a typed internal value.
- `publish`: Make an artifact available outside the source repository.
- `refactor`: Change code structure without a change to public behavior.
- `regenerate`: Create a generated artifact again from its canonical source.
- `redistribute`: Provide a third-party reference outside its approved distribution method.
- `render`: Convert source data into a visible or machine-readable output.
- `retrieve`: Get an official reference from its approved source.
- `review`: Examine an artifact against its requirements and record the result.
- `scan`: Use an automated process to find specified source patterns.
- `serialize`: Convert a typed value into a transport or storage representation.
- `validate`: Confirm that an input or artifact obeys its contract.
- `verify`: Confirm a result at its public or runtime boundary.

Use the simple present, simple past, simple future, imperative, or infinitive form of these verbs.

## Repository Technical Verbs

Add repository-specific technical verbs below this line.

```text
- `term`: Definition with one meaning and the approved verb forms.
```
