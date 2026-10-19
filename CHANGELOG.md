# Changelog

## Unreleased

- Added image clipping support on macOS. When the clipboard holds an image
  (PNG or TIFF) and no text, Flycut now keeps it in the history. If both text
  and an image are present, the text is kept as before. The skip-types filters
  (password, transient, concealed and so on) also apply to images.
  - Each image is saved as a PNG under
    `~/Library/Application Support/Flycut/Images/`. The history stores only
    the file name, in a separate local `imageStore` preference, so image bytes
    never go into the saved history. Histories saved by earlier versions load
    unchanged.
  - Image files are deleted when their clipping is deleted, trimmed by the
    history limit, or cleared. Images larger than 20 MB as PNG are skipped.
  - The menu and bezel show image clippings as `[Image 1280×720]`, with a small
    thumbnail in the menu. Search matches that label.
  - Pasting an image clipping puts PNG and TIFF data on the clipboard.
  - "Save" and autosave of an image clipping write a `.png` file.
  - Image clippings are never synced through iCloud. Only text is synced, and
    syncing never deletes local images. The iOS app ignores image entries.
- Replaced the deprecated `NSStringPboardType` with `NSPasteboardTypeString`.
- Clipboard polling now checks `changeCount` first and reads the clipboard
  types only after a change. The read still happens off the main thread, so
  large Remote Desktop copies don't block.
- "Merge" now skips image clippings.

## 1.9.7 (2026-08-04)

First release since 1.9.6 (2020). Focused on crash fixes and modern-macOS
compatibility.

- Fixed a crash on macOS 26 when copying large content from Microsoft Remote
  Desktop Connection (the menu-bar icon update ran off the main thread). (#262, #279)
- Fixed an intermittent crash when a copy was quickly followed by a paste — the
  clipboard store was being modified from a background thread while the UI read
  it. Clipboard capture is now serialized on the main thread.
- Fixed pasting on non-QWERTY keyboard layouts (Russian, Dvorak, and others),
  where the synthesized ⌘V could fail or trigger the wrong action. (#264)
- Fixed a guaranteed crash when lowering the "Save" preference below "After each
  clip" while iCloud Clippings Sync was enabled.
- Fixed the menu search field returning wrong or stale results. (#290)
- Fixed a crash when enabling iCloud sync in unsigned/local builds that lack
  iCloud entitlements; sync now degrades gracefully instead. (#321)
- The project again builds cleanly on current Xcode.

Credits: menu-search fix by @chzhc; several fixes adapted from the
actively-maintained community fork (haad/Flycut) and from contributor pull
requests (#314, #322, #323).
