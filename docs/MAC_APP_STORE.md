# Mac App Store Preparation

Assessment date: September 23, 2026.

Rhythm can be prepared for Mac App Store review.
Apple determines acceptance after submission.
The current project supports local development only.

## Current Source Evidence

| Area | Current state | Required work |
| --- | --- | --- |
| App Sandbox | `ENABLE_APP_SANDBOX = NO` | Enable App Sandbox and do a test of all services. |
| Signing | Manual ad-hoc signing | Select the Apple team and configure store signing. |
| Identity | `com.mprlab.RhythmPrototype` | Select and register the permanent personal bundle identifier. |
| Saved data | Application Support and UserDefaults | Do a test of storage inside the sandbox and decide how to import existing local data. |
| Idle detection | Public Quartz aggregate counter | Verify its behavior inside the sandbox. Keep manual pause controls available. |
| Focus | Manual service | Keep the preference and instructions accurate about manual operation. |
| Notes | Local text with macOS Dictation help | Verify Dictation behavior and describe the actual permission boundary. |
| Chimes | Local generated audio | Do a test of sound output and settings inside the sandbox. |
| Release automation | No store build declaration | Configure the macOS cloud workflow and shared Gateway operation. |

The existing identifier also controls saved preferences.
A new identifier requires an explicit decision about existing local data.
The application uses UserDefaults and system uptime.
Review these APIs against Apple's required-reason API list before submission.
Add the applicable privacy manifest declarations.

## Preparation Sequence

1. Confirm the Apple Developer Program account and the intended seller identity.
2. Select the permanent bundle identifier, category, version, and build number.
3. Enable App Sandbox with only the necessary entitlements.
4. Do a test of notes, history, idle detection, sleep, notifications, Focus behavior, and chimes in the sandboxed application.
5. Complete the application integration coverage recorded in I001.
6. Publish support and privacy policy pages.
7. Add the privacy policy link inside the application.
8. Prepare screenshots, the description, age rating, privacy answers, and review notes in App Store Connect.
9. Configure `.mprlab/apple-build.json` and the selected deployment manifest for the shared macOS cloud operation.
10. Build and sign the store artifact through the declared workflow.
11. Upload the artifact to App Store Connect and test it through TestFlight.
12. Submit the selected build for review after authorization.

The current repository Apple guide assigns macOS distribution to Xcode Cloud and the shared Gateway operation.
This is a repository workflow requirement, not an Apple requirement.
Software tests on macOS are sufficient for the repository validation boundary.

Review notes must explain the menu-bar icon, the first popover, and the long reminder intervals.
The store description must distinguish optional chimes from notification delivery through Focus.
The source has no analytics or application server.
Confirm the final build's data practices before the privacy answers are submitted.

## Account And Cost

Apple lists Developer Program membership at 99 USD per year, with local prices where available.
Individual enrollment uses the person's legal name as the seller name.
An open-source project can have a free store price.
The GitHub license and the App Store price are separate decisions.

## Open Decisions

- Existing Apple membership and team identity.
- Permanent bundle identifier.
- Free store price and distribution regions.
- Support contact and privacy policy address.
- Import of existing local notes and history into the sandbox.

## Official References

- [Apple Developer Program enrollment](https://developer.apple.com/programs/enroll/): membership and individual seller identity.
- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/): sandbox, public APIs, privacy, and review requirements.
- [Preparing an app for distribution](https://developer.apple.com/documentation/xcode/preparing-your-app-for-distribution): identity and distribution settings.
- [Required-reason APIs](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api): privacy manifest declarations.
- [macOS distribution](https://developer.apple.com/macos/distribution/): store distribution and TestFlight.
