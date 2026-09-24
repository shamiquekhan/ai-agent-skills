---
name: app-security-audit
description: >-
  Perform a structured security audit of an application repository, with a focus
  on the predictable failure modes of AI-generated ("vibe-coded") apps. Produces a
  severity-ordered findings report with concrete remediation for each issue —
  exposing secrets, broken multi-user data isolation, missing server-side
  validation, unsafe dependencies, missing auth middleware, and over-permissive
  agent-granted permissions. Use when the user asks for a security review,
  vulnerability scan, OWASP check, or "is my app secure" assessment of a codebase.
license: MIT
metadata:
  author: Shamique Khan
  version: 1.0.0
  category: security
  tags: [security, audit, owasp, secrets, rls, authentication]
---

# App Security Audit

Audit an application repository for security issues and produce a severity-ordered findings report. The repository is the source of truth: every finding must cite file paths and line numbers, and every claim must be verified against the actual code before it is reported.

This skill exists because AI-generated applications fail in **specific, predictable, patterned ways** — not randomly. A structured checklist audit catches most of the category. "The app works" is not evidence that it is secure: most security problems are invisible through normal browser testing.

**Workflow:** SCAN → MAP ATTACK SURFACE → HUNT KNOWN FAILURE MODES → SEQUENCING/CONCURRENCY CHECK → PRIORITIZE → REPORT

**Core rules:**

- Documentation-first. You may run read-only analysis and project-provided scans; you do not change code unless the user explicitly asks for remediation as a separate step.
- Evidence-based. Findings without file/line evidence are marked `NOT VERIFIED`, never invented.
- No scanner worship. Automated tools are guardrails, not proof of security.

---

## PHASE 1 — FULL PROJECT SCAN

Before making any claims:

Scan the complete project structure. Identify:

- application type (web app, API, mobile wrapper, background worker)
- programming languages and frameworks
- frontend and backend boundaries
- APIs (public, internal, admin)
- databases and data stores
- authentication / authorization mechanisms
- external APIs/services
- file/storage systems and upload handling
- queues, background workers, cron/scheduled jobs
- caching layers
- notifications
- payments
- deployment system, CI/CD, Docker/container setup
- cloud infrastructure
- environment variables and configuration
- logging, monitoring, error handling
- backups
- security-sensitive systems

Also inspect:

- README files
- `docs/`
- `config/`
- `.github/`
- deployment and infrastructure files
- package/dependency manifests
- environment templates
- existing security audits or SECURITY.md if present

**DO NOT MODIFY ANYTHING DURING THIS PHASE.**

---

## PHASE 2 — MAP THE ATTACK SURFACE

Trace how the app is actually exposed:

- What endpoints exist and which are public vs authenticated?
- Where do requests enter? Which routes lack middleware entirely?
- Where is data stored, and who can theoretically reach it?
- How do users authenticate? Where are tokens/sessions stored and checked?
- What external systems hold credentials or send callbacks (webhooks)?
- What is exposed in the frontend bundle (keys, endpoints, admin routes)?
- What database access rules exist (RLS policies, direct connection strings, CORS)?
- What do the deployment and infrastructure expose (ports, buckets, dashboards)?

If something cannot be verified from the repository, mark it `NOT VERIFIED`. Do not invent it.

---

## PHASE 3 — HUNT THE SIX CORE FAILURE MODES

Check every one of these. Each is where AI-generated code predictably fails:

### 1. Exposed environment variables and API keys

- Search the repo for hardcoded secrets: passwords, API keys, tokens, private keys, connection strings (check `.env*` committed by accident, frontend source, config files, git history if accessible).
- Check `.gitignore` actually excludes secret-bearing files.
- Check whether any secret appears in frontend code or client-shipped bundles.
- Check whether CI logs, fixtures, or test files contain real credentials.

### 2. Missing or broken row-level isolation (RLS / tenant filtering)

- If the database enforces RLS: read every policy. Look for policies that are technically present but have edge-case bypasses (wrong `auth` function, missing `WITH CHECK`, permissive `USING` clauses).
- If the app filters by customer/tenant ID: verify the filter exists on **every** query path that touches multi-user data, including list, detail, update, delete, search, and export endpoints — not just the happy path.
- Test-by-reading: can user A read or modify user B's data by changing an ID in the URL or request body? Trace the exact code path that prevents or allows it.

### 3. No server-side validation (trusting the frontend)

- Check every endpoint for server-side validation of input, regardless of what the UI enforces.
- Hidden UI is not authorization: verify permissions are enforced **on the server**, not by hiding buttons, routes, or menu items.
- Check forms, uploads, and API inputs for type, length, format, and range checks.
- Check upload handling: is file type verified by content (e.g. magic bytes), not just filename or extension?

### 4. Outdated, vulnerable, or hallucinated packages

- Run the project's dependency audit command if one exists (verify it against package manifests first).
- Check dependencies against known vulnerability databases.
- Verify every imported package actually exists and is the intended one (AI tools sometimes import packages that don't exist — and attackers register those names).
- Flag pinning problems: wildcards, `latest`, unpinned versions.

### 5. Missing or unused authentication middleware

- Enumerate every route/endpoint. For each, determine: is auth middleware applied, is it applied **in the correct order**, and is it actually active (middleware registered but not used is a common AI failure)?
- Check admin and privileged routes specifically — unprotected admin routes are a top vibe-coded app exposure.
- Verify middleware order: authentication → tenant/status validation → permission checks → authorization. A middleware defined but never mounted protects nothing.

### 6. Over-permissive agent-granted permissions

- Audit service accounts, API clients, and database users for admin-scope grants where read/write subsets would suffice.
- Check API clients that can read more than they write.
- Check RLS policies and IAM roles created "to be safe" with `*` scopes.
- Check feature flags, cron jobs, and worker configs granted broader access than needed.

---

## PHASE 4 — SEQUENCING, CONCURRENCY, AND LOGIC CHECKS

These are the edge cases generic scans miss. For each, look for the abuse case in code:

- **Cross-user access:** can one user access another user's data by changing an ID or URL? Are permissions enforced server-side, or only hidden in the UI?
- **Cross-org/tenant access:** same question at the organization/tenant boundary.
- **Concurrent transactions:** are money/data-changing operations race-safe (e.g. double-spend, duplicate submission, lost update)? Look for read-then-write patterns without locking, transactions, or idempotency keys.
- **Auth flow abuse:** password reset (token predictability, missing expiry, user enumeration via error messages), login (rate limiting, lockouts), session handling (expiry, invalidation on password change).
- **Payment webhooks:** are webhook signatures verified? Can a forged webhook grant a subscription or trigger fulfillment?
- **Public interface abuse:** rate limits on auth and expensive endpoints, retry limits, unauthenticated database writes, DoS-able operations (unbounded queries, N+1 amplification, large uploads without limits).
- **Database rule enforcement:** do actual DB rules/policies restrict access, or does the app rely on application code alone?
- **CORS:** is it open (`*`) with credentials, or restricted to known origins?
- **Security headers:** check for CSP, HSTS, X-Frame-Options, X-Content-Type-Options, and whether cookies are HTTP-only/secure/same-site.

---

## PHASE 5 — TOOLING SUPPORT (OPTIONAL, VERIFIED)

Scanners are guardrails, not proof. If the user wants automated checks, recommend or run — after verifying the tool and commands against the project's actual stack:

- **SAST:** Semgrep, SonarQube
- **SCA/dependencies:** Dependabot, Trivy, `npm audit`/`pip-audit`/equivalent for the stack
- **Secret scanning:** GitHub secret scanning, gitleaks, trufflehog
- **DAST:** OWASP ZAP, Burp Suite (requires a running instance; never point DAST at production)
- **Container/infra scanning:** Trivy, cloud provider security tooling (AWS/GCP/Azure native)

Rules for tooling:

- Verify the tool is appropriate for the project's languages before suggesting install commands.
- Never paste real secret values into third-party scanners.
- Treat tool output as leads to verify by reading code, not as final truth. A clean scan is not a clean bill of health: business-logic and multi-tenant isolation flaws are invisible to most scanners.
- Suggest CI integration (security checks on every PR) as the durable fix.

---

## PHASE 6 — RISK PRIORITIZATION

Classify findings:

- **P0 — Critical:** exposed production secrets, publicly accessible database, authentication bypass, cross-tenant data exposure, forged-payment acceptance.
- **P1 — High:** missing server-side authorization on sensitive endpoints, unverified webhooks, unprotected admin routes, known-vulnerable dependencies with public exploits, injectable inputs.
- **P2 — Medium:** missing rate limiting, weak headers, verbose errors leaking internals, missing audit logging on sensitive actions, over-permissive service accounts.
- **P3 — Low:** hardening improvements, defense-in-depth additions, documentation gaps.

Fix recommendations follow the same order. Do not pad the report with P3 noise when P0s exist.

---

## PHASE 7 — REQUIRED REPORT FORMAT

Produce a findings report with a consistent, practical structure:

```markdown
# Security Audit Report: <project name>
Date: <date> | Scope: <repos/paths audited> | Verifier: <agent/model, tool versions>

## Executive Summary
- Overall risk: P0/P1/P2/P3 (highest finding severity)
- Count: X critical, Y high, Z medium, W low
- One-paragraph characterization of where the app stands.

## Verified Findings (ordered by severity)
For each finding:
### F<#>: <Title> — P<0-3>
- **Location:** `path/to/file.py`, lines 40-55
- **Category:** <one of the six failure modes / concurrency / headers / etc.>
- **Evidence:** the exact code or config observed, quoted or excerpted
- **Impact:** what an attacker could do, concretely
- **Abuse case:** step-by-step how an attacker would exploit it
- **Remediation:** the specific fix, with a verified-code-level example where possible
- **Verification:** how the user can confirm the fix works (test, command, header check)

## Potential Findings (unverified)
Suspicions that could not be confirmed from the repository, each marked NOT VERIFIED
with what evidence would confirm or refute it.

## What the App Does Well
Controls that are correctly implemented, so they are not "fixed" unnecessarily.

## Attacks Tested and Prevented
The abuse cases traced end-to-end that the app DOES defend against.

## Recommended Tooling / CI Additions
Concrete, verified suggestions (e.g. add Semgrep + secret scanning to CI), with
the exact workflow changes needed.

## Audit Limitations
What could not be checked (runtime behavior, third-party services, infrastructure
outside the repo) and what independent review is still advisable before launch.
```

---

## PHASE 8 — COMMAND AND TOOL SAFETY

Any command the agent runs must be verified against the project.

Do not fabricate:

- audit/scan commands for the wrong stack
- file paths
- service names
- cloud or database commands

If a command cannot be verified, describe the check conceptually instead.

**Never** during an audit:

- run exploits against a live deployment
- exfiltrate, download, or copy real secret values out of the repository
- run destructive database operations (resets, deletes, migrations) to "test" behavior
- point DAST scanners at production

---

## PHASE 9 — PRODUCTION SAFETY

This audit is **read-only by default**. You must NOT:

- modify source code (unless remediation was explicitly requested as a separate task)
- modify database schema or RLS policies
- run migrations
- deploy anything
- restart production services
- rotate credentials
- change DNS, cloud infrastructure, CI/CD, or environment variables
- delete files
- change permissions or authentication
- alter production state

Only report and recommend. Remediation is a separate, user-approved task.

---

## PHASE 10 — SECRET SAFETY

Never write real secret values into the report:

- passwords, API keys, access tokens, private keys
- database credentials, OAuth secrets, webhook secrets, session secrets

Refer to them by name and location only. Example: `STRIPE_API_KEY hardcoded in config/payments.py:12`.

If secrets are found in the repository:

- do **NOT** reproduce them
- report: `Potential secret exposure detected in <file/path>` with recommended rotation steps
- remind the user that a leaked key must be **rotated**, not just deleted — it is already compromised

---

## PHASE 11 — SOURCE-OF-TRUTH CHECK

Documentation may be outdated or aspirational. Do not blindly trust:

- README security claims
- `docs/`
- code comments ("this is secure because...")
- generated architecture descriptions

Verify security-relevant claims against:

- actual middleware and route registration
- actual database policies
- actual dependency manifests and lockfiles
- actual CI workflows and deployment configuration

If documentation conflicts with implementation, prefer the verified implementation. Do not change code to match stale documentation.

---

## PHASE 12 — AI SAFETY

The audit report must not instruct future AI agents to blindly modify production or disable controls.

- Distinguish clearly between `SAFE AUTOMATION` (adding a scanner to CI, opening a PR with a fix) and `REQUIRES HUMAN APPROVAL` (rotating credentials, changing RLS policies on live data, altering infrastructure, force-pushing).
- Never recommend "just ask the AI that built it if it's secure" as a control — the report should list specific abuse cases the app must demonstrably prevent.
- Note where an independent human review is still advisable (real customer data, payments, or anything regulatory).

---

## PHASE 13 — TOKEN / CONTEXT EFFICIENCY

Keep the report concise and operational.

- Do not repeat full architecture explanations per finding; reference the attack-surface map once.
- Each finding contains only what's needed to understand, reproduce, and fix it.
- Avoid: generic security theory, long tutorials, filler warnings the app doesn't need.

Optimize for: **"What could an attacker actually do, where exactly is it, and how do I fix it?"**

---

## PHASE 14 — FINAL VALIDATION

Before delivering the report, re-verify:

- every finding cites a real path and line that currently shows the problem
- every quoted code excerpt is copied, not paraphrased
- every recommended command is valid for this project's stack
- no secret values are included anywhere in the report
- severities are consistent (same class of issue → same severity)
- unverified suspicions are clearly separated from verified findings
- no non-report files were modified (unless remediation was explicitly requested)
- the abuse cases in "Attacks Tested and Prevented" were actually traced, not assumed

---

## FINAL OUTPUT

At completion, provide:

1. Systems and attack surface mapped
2. Verified findings, ordered by severity
3. Potential findings marked NOT VERIFIED
4. Controls the app already does well
5. Abuse cases tested and prevented
6. Recommended remediations in priority order
7. Tooling/CI recommendations
8. What could not be verified and what independent review is advisable

**CRITICAL RULE:**

Do not optimize for the number of findings. Optimize for findings that are:

- real (evidence-backed)
- exploitable (concrete abuse case)
- fixable (concrete remediation)
- prioritized (P0s first, no noise)

A report with 3 verified critical findings is worth more than 50 speculative ones. Never pad the report, and never soften a verified P0.
