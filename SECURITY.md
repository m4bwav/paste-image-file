# Security

Report a vulnerability through GitHub's private reporting: the **Security** tab of this repository, then **Report a vulnerability**. Please do not open a public issue for it.

Worth knowing before you install: the menu entry runs a PowerShell script copied to `%LOCALAPPDATA%\paste-image-file`, with `-ExecutionPolicy Bypass` for that one process. Anyone who can write to that folder can change what the menu runs; by default only you and administrators can. The script downloads an image only when the clipboard holds HTML with an `http(s)` image URL.


