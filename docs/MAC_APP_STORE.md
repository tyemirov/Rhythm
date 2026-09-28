# Mac App Store Preparation

Assessment date: September 23, 2026.

Flow can be prepared for Mac App Store review.
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
| Release automation | Store cloud declaration and request check | Complete the Gateway store lifecycle contract. |

The existing identifier also controls saved preferences.
A new identifier requires an explicit decision about existing local data.
The privacy manifest declares UserDefaults with reason `CA92.1` and system uptime with reason `35F9.1`.
UserDefaults stores preferences for this application.
System uptime measures elapsed time for Wave and Pause timers.
The source audit found no calls for file timestamps, disk capacity, or active keyboard information.
The application declares no data collection or tracking.
`make privacy-check` verifies the privacy manifest in the built application.

The initial check failed because the application bundle had no privacy manifest.
After the resource change, the same check passed.

## I004 Preparation Results

The [submission materials](STORE_MATERIALS.md) contain proposed metadata, review notes, privacy answers, and an asset inventory.
The [privacy draft](PRIVACY.md) and [support draft](SUPPORT.md) describe the current application.
Public page publication remains a separate operation.

The other local applications identify Apple team `Z9ZW6HDGML` and support contact `support@mprlab.com`.
The proposed permanent identifier is `com.mprlab.Flow`.
Apple registration of that identifier remains unverified.
The application project still uses the prototype identifier until the owner selects the data import procedure.

`.mprlab/apple-build.json` declares `Release Flow`, platform `MACOS`, and distribution `APP_STORE_ELIGIBLE`.
`scripts/build-macos.sh` passes the request to the installed Gateway runtime.
`make cloud-plan` passed without provider calls.
This result validates the request shape, not an Apple workflow or a signed build.

The current Gateway lifecycle has no selected resource for a macOS store application.
Its `macos_application` resource selects `DEVELOPER_ID` and publishes through GitHub Releases.
Its cloud operation accepts a separate store target.
The selected manifest and lifecycle commands remain pending a Gateway contract for macOS store distribution.
Do not use the direct-download resource for the store artifact.

This result comes from the local `MPRLab-Gateway` source:

- `docs/apple-cloud-build.md` defines the store cloud target and the direct-download resource.
- `deploy/ansible/playbooks/tasks/build-selected-release-macos.yml` requires `DEVELOPER_ID`.
- `deploy/ansible/playbooks/tasks/publish-selected-release-macos.yml` checks the same distribution value.

## Remaining Implementation

- Complete the application integration suite in I001.
- Select the one-time import of prototype notes, History, and preferences.
- Change the application identity and storage together after that decision.
- Enable App Sandbox and verify all application services through I001.
- Configure store signing with the established Apple team.
- Add the public privacy address to Settings after the address is selected.
- Complete the final screenshots and asset rights evidence.
- Add the selected manifest after Gateway supports the macOS store lifecycle.

The other repositories do not establish a Flow data import decision or a Flow privacy address.
No prototype data was changed during this preparation.

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

- Apple account registration of `com.mprlab.Flow` under team `Z9ZW6HDGML`.
- Free store price and distribution regions.
- Public support and privacy addresses.
- Import of existing local notes and history into the sandbox.

## Operational Runbook

1. Complete the remaining implementation and I001 validation.
2. Run `make ci` from the primary checkout.
3. Register the permanent identifier in the established Apple account.
4. Create the Flow macOS record in App Store Connect.
5. Connect the repository to Xcode Cloud.
6. Create workflow `Release Flow` with project `Flow.xcodeproj` and shared scheme `Flow`.
7. Select a macOS Release archive action with `APP_STORE_ELIGIBLE` distribution.
8. Set the cloud build number above every build already uploaded for this version.
9. Commit the release version before the cloud request.
10. Provide the canonical private inputs through `configs/.env.flow`.
11. Run the Governor check before the selected manifest or release operation.
12. After release authorization, use the supported Gateway lifecycle.
13. Retain the source commit, workflow, provider build identifier, artifact identity, and cloud receipt.
14. Verify the signed artifact identity, entitlements, version, build number, and privacy manifest.
15. Record TestFlight results separately from local tests.
16. After submission authorization, submit the selected build with the completed store materials.
17. Record Apple review and public availability as separate results.

Gateway owns these private input names:

```text
APP_STORE_CONNECT_API_ISSUER_ID
APP_STORE_CONNECT_API_KEY_ID
APP_STORE_CONNECT_API_KEY_PATH
```

The key path identifies the Apple `.p8` key.
These credentials authorize provider calls.
They are not a local signing identity.
The preparation commands require no provider credentials.
No provider authentication, build upload, or publication was attempted.

If a build submission has an uncertain result, inspect its provider state before another request.
Use the existing build identifier with Gateway recovery after its source and workflow are verified.
Keep `apple-cloud-intent.json`, `apple-cloud.json`, and downloaded artifacts with the release evidence.

## Official References

- [Apple Developer Program enrollment](https://developer.apple.com/programs/enroll/): membership and individual seller identity.
- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/): sandbox, public APIs, privacy, and review requirements.
- [Preparing an app for distribution](https://developer.apple.com/documentation/xcode/preparing-your-app-for-distribution): identity and distribution settings.
- [Required-reason APIs](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api): privacy manifest declarations.
- [macOS distribution](https://developer.apple.com/macos/distribution/): store distribution and TestFlight.
