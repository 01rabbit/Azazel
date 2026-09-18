# Security Policy

This repository is the Azazel documentation and doctrine hub; product code and its own security surface live in the product repositories (Azazel-Edge, Azazel-Gadget, Azazel-Knowledge, Azazel-Fabric, Azazel-Deception, Azazel-Boot, and Azazel-Nexus).

## Reporting a Vulnerability

- Report privately via GitHub Security Advisories: https://github.com/01rabbit/Azazel/security/advisories/new
- Do NOT open public issues for suspected vulnerabilities.
- Include: affected repository/version or commit, environment, reproduction steps, impact assessment.
- No bug bounty is offered; reporters are credited in the coordinated note unless they prefer otherwise.

## Response Expectations

- Acknowledgement within 7 days; initial assessment within 14 days.
- Coordinated disclosure: please hold publication until a fix or advisory note is published.

## Scope

- This repository: site/documentation issues (e.g., content injection via the Pages site, leaked secrets in docs).
- Product vulnerabilities belong in the product repository's own policy:
  Use the affected product repository's private advisory channel. A repository that has not yet published its own `SECURITY.md` remains covered by ecosystem-wide coordination through this repository.
- Ecosystem-wide or cross-repository coordination issues may be reported here.

## Supported Versions

- The `main` branch of each repository, plus each product's latest tagged release.
