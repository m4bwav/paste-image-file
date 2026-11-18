# paste-image-file: continue prompt

1. Read ai-docs/HANDOFF.md, AGENTS.md and ai-docs/log.md in D:/m4bwa/Claude/Projects/Ai/paste-image-file.
2. Waits on Mark: the first wiki page click (https://github.com/m4bwav/paste-image-file/wiki/_new) and the social preview upload (Settings, .github/images/social-preview.jpg). Check with `git ls-remote https://github.com/m4bwav/paste-image-file.wiki.git`.
3. If the wiki repo exists, run `tools/Publish-Wiki.ps1` and confirm every page at https://github.com/m4bwav/paste-image-file/wiki loads. If not, stop: nothing else is blocked.
4. Otherwise pick from HANDOFF's ideas only if Mark asked; run the tests in both powershell and pwsh after any script change.
5. Stop points: never publish to a package registry; tag and release yourself after tests pass.
6. End by updating ai-docs/HANDOFF.md and printing the same start command: `Execute D:/m4bwa/Claude/Projects/Ai/paste-image-file/ai-docs/plans/2026-11-18-paste-image-file-continue-prompt.md`
