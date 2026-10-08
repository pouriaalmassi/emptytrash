# Empty Trash

A native, windowless macOS app for Apple Silicon (M1 and later), requiring
macOS 12 or later. Launch from the Dock or Spotlight to permanently empty
your Trash, then quit. No confirmation prompts.

## Install

Open `dist/EmptyTrash-arm64.dmg` and drag the app into Applications.
Before launching, enable **Empty Trash** in **System Settings → Privacy &
Security → Full Disk Access**. On Monterey, use System Preferences →
Security & Privacy → Privacy. This one-time macOS permission is required
to enumerate Trash; an app cannot grant it to itself.

Drag the installed app onto the Dock or find it in Spotlight. Every launch
deletes immediately. No window, alert, notification, or Finder automation
is used. Keep the installed app in the same location after granting access.

The app empties `~/.Trash` and `.Trashes/<your user ID>` on mounted volumes.
It preserves the trash directories and other users' trash. Hidden files and
nested folders are included. Symlinks are unlinked without deleting their
targets, and symlink trash roots are refused. Locked or inaccessible items
may remain; errors are logged in Console with subsystem
`com.pouriaalmassi.emptytrash`. Items added after enumeration may remain
until the next launch. Concurrent launches while the app is running are
handled by macOS as activation of the existing app.

## Build and package

Requires Xcode or its Command Line Tools. No dependencies or Xcode project
are needed.

```sh
./scripts/test.sh
./scripts/build.sh
./scripts/make-dmg.sh
```

Build output: `build/Empty Trash.app`. DMG output:
`dist/EmptyTrash-arm64.dmg`. The DMG script builds the app automatically.
The app icon is drawn with AppKit during the build.

By default the app is ad-hoc signed for local use. For distribution outside
your Mac, use a Developer ID Application certificate and a configured
notarytool keychain profile:

```sh
SIGNING_IDENTITY='Developer ID Application: Your Name (TEAMID)' \
NOTARY_PROFILE='your-notary-profile' ./scripts/make-dmg.sh
```

This signs the app and DMG, submits the DMG for notarization, and staples
the ticket. Without Developer ID signing and notarization, Gatekeeper may
require a separate first-open approval on other Macs. Changing the signing
identity or rebuilding an ad-hoc signed app may require granting Full Disk
Access again.

Tests use temporary fixtures only; they never access your real Trash.
