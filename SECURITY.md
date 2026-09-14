# Security policy

## Supported versions

Security fixes are applied to the latest release and, before the first release,
the default branch.

## Reporting a vulnerability

Report vulnerabilities privately to [nimotecode@gmail.com](mailto:nimotecode@gmail.com).
Include the affected version or commit, reproduction steps, impact, and any
relevant logs with credentials and personal data removed. Do not open a public
issue containing credentials, SSH keys, device details, or an exploit proof
that could affect users.

Presets may only change the current Ubuntu environment. They must not request
Android root, use `sudo`, access another app's data, start public services,
collect project data, exfiltrate environment variables or SSH keys, or modify
NimoteCode itself. Network downloads must have a declared source and integrity
check before execution.
