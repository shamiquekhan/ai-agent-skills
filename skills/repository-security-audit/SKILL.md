---
name: repository-security-audit
description: >-
  Audit the security of a repository itself — CI/CD pipelines, dependency and
  supply-chain risk, secrets hygiene, container and infrastructure-as-code
  configuration, artifact publishing, and repo settings — complementing code-level
  audits which do not cover these. Produces a severity-ordered, evidence-backed
  findings report with concrete hardening steps. Use when the user asks to review
  repository security, harden CI/CD, check GitHub Actions safety, review supply
  chain risk, audit Dockerfiles/IaC, or prepare a repo for open-sourcing.
license: MIT
metadata:
  author: Shamique Khan
  version: 1.0.0
  category: security
  tags: [security, supply-chain, cicd, github-actions, docker, dependencies]
---

# Repository Security Audit

Audit the security posture of a repository itself — not the application code inside it. Modern breaches increasingly target the **plumbing around the code**: the CI pipeline that runs on every PR, the dependencies pulled at build time, the container image shipped to production, the tokens handed to workflows, and the repo settings that decide who can do all of the above.

The repository is the source of truth. Every finding must cite file paths and line numbers and be verified against the actual configuration before it is reported. Suspicions that cannot be confirmed are marked `NOT VERIFIED` — never invented.

This skill pairs with `app-security-audit` (application code) — together they cover the full exposure surface. Run that skill for code-level findings; run this one for everything around it.

**Workflow:** SCAN → MAP PIPELINE → AUDIT SEVEN DOMAINS → PRIORITIZE → REPORT

**Core rules:**

- Read-only by default. You inspect and report; remediation is a separate, user-approved task.
- Evidence-based. No findings without file/line citations.
- No scanner worship. Tools produce leads; verification happens by reading the actual configuration.

---

## PHASE 1 — FULL PROJECT SCAN

Before making any claims, scan the repository structure. Identify:

- languages, frameworks, and package ecosystems (npm, pip, cargo, go modules, maven, etc.)
- lockfiles present or missing (per ecosystem)
- CI/CD system and all pipeline definitions
- Docker/container files (Dockerfile, docker-compose, .containerignore)
- infrastructure-as-code (Terraform, CloudFormation, Pulumi, Kubernetes manifests, Helm)
- Git hooks and local dev tooling
- artifact publishing configuration (npm publish, PyPI, Docker registries, GitHub Releases)
- `.github/` contents: workflows, dependabot config, CODEOWNERS, templates
- repository settings visible in config (branch protection cannot be read from files — mark `NOT VERIFIED` if unknown)
- environment templates and where configuration is expected
- existing security documentation (SECURITY.md, audit reports)
- git history signals (large or suspicious history is a lead, not a finding)

**DO NOT MODIFY ANYTHING DURING THIS PHASE.**

---

## PHASE 2 — MAP THE PIPELINE

Trace the actual build-and-deploy path before auditing it:

- Which workflows exist, and what triggers each (push, PR, schedule, workflow_dispatch, workflow_run, release)?
- Which workflows run on `pull_request_target` or check out PR head code?
- What permissions does each workflow grant (`permissions:` blocks, defaults, job-level overrides)?
- What secrets does each workflow consume, and are they scoped to the environments that need them?
- What does the build produce and where does it go (registries, releases, deployments)?
- Which jobs run third-party Actions, and are they pinned?
- Where would a malicious PR, dependency, or base image execute code?

If a behavior depends on repository settings that live outside the repo (branch protection, required reviewers, runner configuration), mark it `NOT VERIFIED` and note what to check in repo settings.

---

## PHASE 3 — AUDIT THE SEVEN DOMAINS

Check every domain. Each is a place AI-generated and human repos alike predictably fail:

### 1. CI/CD pipeline security

- **`pull_request_target` abuse:** does any workflow use `pull_request_target` (or `workflow_run`) while checking out and executing PR head code? That lets a forked PR run privileged code. This is the single most dangerous CI pattern.
- **Script injection:** do workflows interpolate user-controlled values (`github.event.pull_request.title`, branch names, commit messages, PR bodies) directly into `run:` shell blocks? `${{ }}` expansion into bash is a code-execution vector.
- **Permission hygiene:** are workflows granted broad `permissions:` (especially `contents: write`, `id-token: write`) when they only need read? Prefer top-level deny-by-default plus per-job grants.
- **Credential exposure:** are secrets passed to untrusted steps, echoed into logs, or written into build artifacts? Are secrets used in PRs from forks (where they may not be available — or worse, are)?
- **Pinning:** are third-party Actions pinned to full-length commit SHAs, or floating tags (`@v3`, `@main`) that can be repointed? Note mutable-tag findings separately from unverified-action findings.
- **Self-hosted runners:** do they execute workflows from forks? Public repos + self-hosted runners is a known compromise path.
- **Deployment triggers:** can a PR (not just a maintainer merge) trigger a deployment with production credentials?

### 2. Dependency and supply-chain risk

- Lockfiles: present per ecosystem? Committed? If builds resolve dependencies without a lockfile, builds are not reproducible and version pinning is illusory.
- Known vulnerabilities: run the ecosystem's audit command (verify it exists for the stack first — `npm audit`, `pip-audit`, `cargo audit`, `go vulncheck`...). Report verified output, not guessed CVEs.
- Unpinned ranges, `latest` tags, git dependencies, and postinstall scripts that fetch remote code.
- Typosquat/hallucinated package exposure: verify each unusual or AI-introduced dependency actually exists and is the intended, maintained package. Attackers register plausible names.
- Publishing pipeline: does publishing require provenance/signing? Are publish tokens scoped and stored as secrets, not inline?

### 3. Secrets hygiene

- Grep the repo for hardcoded credentials: API keys, tokens, passwords, private keys, connection strings — in source, config, fixtures, scripts, and CI files.
- Check `.gitignore` covers `.env*`, key files, and local config; check for committed files that match ignore patterns (ignore rules don't untrack files already committed).
- Check git history if accessible: a secret removed in HEAD still exists in history. Recommend rotation for anything found, and note that history rewriting is `REQUIRES HUMAN APPROVAL`.
- Check CI logs/config for secrets passed where forks or debug output can capture them.
- Verify secret *usage* pattern: are secrets referenced by environment variable name in workflows, or constructed inline?

### 4. Container security

- Base image: pinned by digest or floating tag? Official/verified image or random Docker Hub account? `latest` is a finding.
- Running as root: missing `USER` directive.
- Multi-stage builds absent where build tooling ships in the final image.
- `COPY . .` without `.dockerignore` — leaks `.env`, `.git`, credentials into the image.
- Secrets baked into layers (ARG secrets, ENV credentials, build-time downloads with embedded tokens).
- Missing healthchecks/labels are hardening notes, not security findings — keep them P3.

### 5. Infrastructure-as-code security

- Over-permissive IAM roles and policies (`Action: "*"`, `Resource: "*"`, wildcard principals).
- Public exposure defaults: public S3/GCS buckets, public security group ingress (`0.0.0.0/0` on sensitive ports), unauthenticated endpoints.
- Secrets or credentials defined in IaC files instead of a secrets manager.
- Encryption flags absent on storage/database resources.
- Missing state-file hygiene: Terraform state with secrets committed to the repo; state backends without locking/encryption.

### 6. Repo configuration and process

- SECURITY.md present? (Responsible disclosure path; its absence is P3.)
- CODEOWNERS present and covering security-sensitive paths?
- Branch protection and required reviews: cannot be verified from files — check via API/CLI if the user permits, otherwise mark `NOT VERIFIED` with instructions.
- Dependabot/config for automated dependency updates present?
- Release process: are releases built by CI from tagged commits, or hand-assembled artifacts?
- Contributor trust model: can external PRs trigger workflows with secrets (ties back to Domain 1)?

### 7. AI-generated content risks

Where the repo is substantially AI-generated, add these checks:

- Workflows, Dockerfiles, or IaC generated wholesale by an agent — review as untrusted input, same as third-party code.
- Over-permissive defaults agents favor: broad `permissions:`, wildcard IAM, `0.0.0.0/0` ingress, "works on my machine" base images.
- Hallucinated Actions or packages referenced in CI (verify every `uses:` and dependency actually exists).
- Multi-step setup scripts the author cannot fully explain — these bypass normal review intuition.

---

## PHASE 4 — PRIORITIZATION

Classify findings:

- **P0 — Critical:** fork-executable privileged CI (`pull_request_target` running PR code), leaked production credentials, container/IaC exposing a database or admin interface to the internet, wildcard IAM on production resources.
- **P1 — High:** script injection in workflows, secrets in git history, unpinned third-party Actions in privileged workflows, missing lockfile on a published package, `.dockerignore` missing with secrets in build context, public data stores.
- **P2 — Medium:** over-broad workflow permissions, floating base image tags, missing Dependabot, verbose build logs, missing CODEOWNERS, unverified unusual dependencies.
- **P3 — Low:** missing SECURITY.md, missing healthchecks, documentation gaps, defense-in-depth additions.

Do not pad the report with P3 noise when P0s exist. Same class of issue → same severity, consistently.

---

## PHASE 5 — REQUIRED REPORT FORMAT

Produce a findings report with a consistent, practical structure:

```markdown
# Repository Security Audit: <repo name>
Date: <date> | Scope: <paths audited> | Verifier: <agent/model, tool versions>

## Executive Summary
- Overall risk: P0/P1/P2/P3 (highest finding severity)
- Count: X critical, Y high, Z medium, W low
- One-paragraph characterization of the repo's security posture.

## Verified Findings (ordered by severity)
For each finding:
### F<#>: <Title> — P<0-3>
- **Location:** `path/to/file.yml`, lines 10-25
- **Domain:** <CI/CD / supply-chain / secrets / container / IaC / repo-config / AI-content>
- **Evidence:** the exact config observed, quoted or excerpted
- **Impact:** what an attacker could do, concretely (who needs what access to exploit it)
- **Remediation:** the specific fix — corrected config snippet, verified command, or settings change
- **Verification:** how to confirm the fix (re-run audit command, inspect new config, CI check)

## Potential Findings (unverified)
Suspicions that could not be confirmed from the repository, each marked NOT VERIFIED
with what would confirm or refute it (e.g. branch protection, runner config, registry
settings — things that live outside the repo).

## What the Repo Does Well
Controls already correctly implemented — so they are not "fixed" unnecessarily.

## Recommended Tooling / CI Additions
Concrete, verified suggestions: pinned Actions, Dependabot config, secret scanning,
dependency audit in CI, OpenSSF Scorecard. With the exact config to add.

## Audit Limitations
What could not be checked from the repo alone: branch protection, runner infrastructure,
registry configuration, org-level settings, runtime behavior. Note where independent
review is advisable before open-sourcing or production launch.
```

---

## PHASE 6 — COMMAND AND TOOL SAFETY

Any command run must be verified against the project's actual stack.

Do not fabricate:

- audit commands for the wrong ecosystem
- file paths
- registry or cloud commands

If a command cannot be verified, describe the check conceptually instead.

**Never** during this audit:

- push, force-push, or rewrite git history (recommend it as `REQUIRES HUMAN APPROVAL` only)
- trigger workflows or deployments
- modify repo settings, secrets, or branch protection
- publish or delete packages/artifacts
- run DAST/exploit tools against live infrastructure

---

## PHASE 7 — PRODUCTION SAFETY

This audit is **read-only by default**. You must NOT:

- modify workflow files, Dockerfiles, or IaC (unless remediation was explicitly requested as a separate task)
- change repository settings, secrets, or access controls
- create, delete, or modify branches, tags, or releases
- install or remove dependencies
- run pipelines, migrations, or deployments
- alter production state in any way

Only report and recommend.

---

## PHASE 8 — SECRET SAFETY

Never write real secret values into the report:

- passwords, API keys, access tokens, private keys
- database credentials, OAuth secrets, webhook secrets, CI secrets

Refer to them by name and location only. Example: `AWS access key committed in deploy/deploy.sh:18`.

If secrets are found:

- do **NOT** reproduce them
- report: `Potential secret exposure detected in <file/path>` with rotation steps
- a leaked key must be **rotated**, not just deleted — treat it as already compromised
- git history rewriting is `REQUIRES HUMAN APPROVAL`; rotation works without it

---

## PHASE 9 — SOURCE-OF-TRUTH CHECK

Documentation may be outdated or aspirational. Do not blindly trust:

- README badges and security claims
- comments in workflows ("this is safe because...")
- generated architecture descriptions

Verify against the actual workflow YAML, Dockerfiles, manifests, lockfiles, and scripts. If documentation conflicts with configuration, prefer the verified configuration. Do not change files to match stale documentation.

---

## PHASE 10 — AI SAFETY

The report must not instruct future AI agents to blindly modify infrastructure or CI.

- Distinguish `SAFE AUTOMATION` (opening a PR that pins an Action, adding Dependabot config) from `REQUIRES HUMAN APPROVAL` (rotating credentials, changing branch protection, rewriting history, altering production infrastructure).
- Note where an independent human review is advisable: open-sourcing a repo, enabling self-hosted runners, or handling regulated data.

---

## PHASE 11 — TOKEN / CONTEXT EFFICIENCY

Keep the report concise and operational.

- Reference the pipeline map once; findings cite it rather than re-explaining.
- Each finding contains only what's needed to understand, reproduce, and fix it.
- Avoid generic security theory and filler warnings.

Optimize for: **"What could an attacker do through the repo's plumbing, where exactly is it, and how do I fix it?"**

---

## PHASE 12 — FINAL VALIDATION

Before delivering the report, re-verify:

- every finding cites a real path and line that currently shows the problem
- every quoted config excerpt is copied, not paraphrased
- every recommended command is valid for this repo's ecosystems
- every `uses:` reference and dependency named in findings was checked to exist
- no secret values appear anywhere in the report
- severities are consistent across findings
- unverified suspicions are clearly separated from verified findings
- no repository files were modified (unless remediation was explicitly requested)

---

## FINAL OUTPUT

At completion, provide:

1. Pipeline and infrastructure map
2. Verified findings, ordered by severity, across the seven domains
3. Potential findings marked NOT VERIFIED
4. Controls the repo already does well
5. Recommended hardening steps in priority order
6. Tooling/CI recommendations with exact config
7. What could not be verified (settings/infrastructure outside the repo) and what independent review is advisable

**CRITICAL RULE:**

Do not optimize for the number of findings. Optimize for findings that are:

- real (evidence-backed)
- exploitable (concrete attack path)
- fixable (concrete remediation)
- prioritized (P0s first, no noise)

A repo with a leaked key and a fork-executable workflow has two findings that matter more than forty hardening notes. Never pad the report, and never soften a verified P0.
