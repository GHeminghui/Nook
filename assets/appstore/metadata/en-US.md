# App Store Metadata · English (en-US)

> Character counts follow Apple's limits. See `../SUBMISSION_CHECKLIST.md` for the submission steps.

## Basics

| Field | Value | Limit | Count |
|---|---|---|---|
| App Name | KnowStack | 30 | 9 |
| Subtitle | Organize study materials fast | 30 | 29 |
| Promotional Text | A local-first library for slides, exams and notes. Nested folders, tags, full-text search, and PDF markup with the system preview. | 170 | 130 |
| Keywords | study library,notes,pdf,slides,exam,organizer,folders,tags,search,annotate,teacher,student | 100 | 90 |
| Primary Category | Education | — | — |
| Secondary Category | Productivity | — | — |
| Age Rating | 4+ | — | — |
| Price | Free (TBC) | — | — |
| Copyright | © 2026 KnowStack | — | — |
| Support URL | https://gheminghui.github.io/Nook/support.html | — | — |
| Marketing URL | https://gheminghui.github.io/Nook/ | — | — |
| Privacy Policy URL | https://gheminghui.github.io/Nook/privacy.html | — | — |

> The app name is **KnowStack** (Simplified Chinese: 知栈). The subtitle carries the "efficient study library" positioning.

## Description

```
KnowStack is a local-first library for teachers and students. Keep slides, exams, mistake logs, essay notes and web pages together — instead of scattered across chats, cloud drives and photo albums.

■ Organize efficiently
Nested folders for everything: create, rename, move and delete, or drag to reorder. Files are stored as real documents, so the structure matches what you already do on a computer.

■ Tags and search
Add multiple tags to a document and filter by folder, tag and keyword. Search covers file names plus the text inside PDFs and HTML pages.

■ Open and annotate
Preview PDFs, images and web slides inside the app. PDFs open in the system preview, where you can handwrite, add shapes and signatures; changes are saved in place. HTML slides render in a WebView so formulas, tables and layout stay intact.

■ Bring files in without detours
Import several files from the Files app, or save them from any other app through the system share sheet. Print or share them again when needed.

■ Your data stays yours
Files live in the app's Documents folder and are visible in Files under "KnowStack". With iCloud enabled, they sync through your own iCloud Drive. No account, no ads, no third-party analytics.

■ English and Simplified Chinese
The interface follows your system language.

Built for:
· Teachers organizing slides, exams and lesson plans by subject, grade and chapter
· Students keeping mistake logs, notes, essay material and listening scripts
· Parents storing school notices and reports

Notes:
· Scanned PDFs are not OCR'd; image-only PDFs cannot be found by full-text search
· HTML pages that reference external resources may render partially offline
· Requires iPadOS 17 or later
```

## Review Notes

```
iPad-only app. No sign-in, no demo account required.

Test path:
1. Launch shows "All Materials"; the Import button (top right) opens the system file picker for PDF / image / HTML.
2. Long-press an item to rename, edit tags, move it to another folder, or delete it.
3. Tap a PDF to open the system preview; the markup button supports handwriting, shapes and signatures.
4. Tap an HTML file to render it inside the app.
5. The sidebar supports creating nested folders and tags.

No accounts, ads, in-app purchases or third-party analytics. iCloud sync activates only when the device is signed in to iCloud; otherwise data stays local.
```

## App Privacy

- Data collection: **Data Not Collected**
- Tracking: No
- Third-party SDKs: None
- Rationale: files are stored on the user's device and in the user's own iCloud Drive; the developer cannot access them.

## Localization

- Source language: Simplified Chinese
- Supported: Simplified Chinese and English (String Catalog, follows the system language)
- App Store localizations: zh-Hans and en-US, each with its own metadata and screenshots

## Export Compliance

- No custom encryption; only system HTTPS / iCloud.
- Add `ITSAppUsesNonExemptEncryption = NO` to Info.plist.

## TODO

- [x] Support URL and Privacy Policy URL
- [ ] Contact email in site pages
- [ ] Copyright holder
- [ ] Price
