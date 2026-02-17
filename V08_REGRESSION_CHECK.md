# v0.8 Regression Checklist

## Environment
- Device: iPhone 17 Pro Simulator
- Build: `main` branch after merging `feat/v0.8-usability`

## Home
- [ ] Open Home and verify the content starts from the top area (no center-only compression)
- [ ] Tap input and verify title/input move naturally with keyboard
- [ ] Tap `Paste` and verify clipboard text is inserted
- [ ] Tap `Generate and Save` with valid config and verify it auto-navigates to Detail

## Detail
- [ ] Verify generated markdown content is visible
- [ ] Verify supported markdown markers (`#`, `##`, `###`, `-`, `---`) are rendered without raw symbols
- [ ] Verify H1/H2/H3/body typography hierarchy is obvious
- [ ] Verify heading highlight uses soft background colors and stays stable for same heading text
- [ ] Tap `Copy` and verify content can be pasted elsewhere

## Settings Markdown Transfer
- [ ] Tap `Export to Files` and verify file is created in selected location
- [ ] Tap `Import Replace`, select a markdown file, and verify local entries are replaced

## Existing Core Flow
- [ ] Search still loads titles and can open Detail
- [ ] Review still loads and can open Detail
- [ ] Delete flow in Search still works
