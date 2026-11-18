# Security

Report a vulnerability through GitHub's private reporting: the **Security** tab of this repository, then **Report a vulnerability**. Please do not open a public issue for it.

Worth knowing before you install: the menu entry runs a PowerShell script from wherever you put this repository, with `-ExecutionPolicy Bypass` for that one process. Anyone who can write to that folder can change what the menu runs, so keep it somewhere only you can write to. The script downloads an image only when the clipboard holds HTML with an `http(s)` image URL.
