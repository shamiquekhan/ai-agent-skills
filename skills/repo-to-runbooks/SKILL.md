---
name: repo-to-runbooks
description: >-
  Work inside an existing software project to create or improve a production-ready
  runbooks/ directory. Scans the repository, traces its real production architecture,
  identifies genuine failure modes, and writes only the runbooks the project needs —
  never modifying application code, infrastructure, or configuration. Use when the
  user asks to add runbooks to a project, generate operational docs for a codebase,
  or improve an existing runbooks/ folder.
license: MIT
metadata:
  author: Shamique Khan
  version: 1.0.0
  category: devops
  tags: [runbooks, incident-response, sre, devops, documentation]
---

# Repo → Runbooks

You are working inside an **EXISTING** software project.

**GOAL:** Create or improve a production-ready `runbooks/` directory for this project.

A runbook is an operational recovery guide for developers/operators when something breaks in production.

**IMPORTANT:**

- Do **NOT** create generic files blindly.
- Do **NOT** assume technologies, services, databases, deployment systems, or failure modes that do not exist in the project.
- Do **NOT** modify application code.
- Do **NOT** refactor anything.
- Do **NOT** change production configuration.
- Do **NOT** change infrastructure.
- Do **NOT** change environment variables.
- Do **NOT** change deployment behavior.

Your job is:

**SCAN → UNDERSTAND → IDENTIFY REAL FAILURE MODES → CREATE ONLY NECESSARY RUNBOOKS**

The repository is the source of truth.

---

## PHASE 1 — FULL PROJECT SCAN

Before creating or modifying any runbook:

Scan the complete project structure. Identify:

- application type
- programming languages
- frameworks
- frontend
- backend
- APIs
- databases
- authentication / authorization
- external APIs/services
- file/storage systems
- queues
- background workers
- cron/scheduled jobs
- caching
- notifications
- payments
- scraping/data pipelines
- deployment system
- CI/CD
- Docker/container setup
- cloud infrastructure
- environment variables
- logging
- monitoring
- error handling
- migrations
- backups
- rollback mechanisms
- feature flags
- health checks
- security-sensitive systems

Also inspect:

- README files
- `docs/`
- `brain/`
- `config/`
- `.github/`
- deployment files
- infrastructure files
- package/dependency manifests
- environment templates
- existing runbooks if present

**DO NOT MODIFY ANYTHING DURING THIS PHASE.**

---

## PHASE 2 — UNDERSTAND HOW PRODUCTION WORKS

Trace the real production architecture. Understand:

- how the app starts
- where requests enter
- where data is stored
- how users authenticate
- what external systems are required
- what scheduled/background processes run
- how deployments happen
- how production failures are currently detected
- how rollback works
- what happens if a dependency becomes unavailable

Do not infer unsupported architecture. If something cannot be verified, mark it as:

`NOT VERIFIED`

Do not invent it.

---

## PHASE 3 — IDENTIFY REAL INCIDENT SCENARIOS

Identify only realistic incidents supported by the repository. Examples may include:

- application/API down
- database unavailable
- database connection failure
- migration failure
- external API unavailable
- authentication failure
- expired/revoked API key
- scheduled job failure
- queue backlog
- scraper returning zero data
- malformed upstream data
- storage unavailable
- payment webhook failure
- failed production deployment
- broken environment configuration
- rate limiting
- DNS/domain problems
- SSL/TLS problems
- high error rate
- unexpected resource usage
- cache failure
- corrupted data
- accidental secret exposure

These are examples only. Do **NOT** create runbooks for systems that the project does not use.

---

## PHASE 4 — RISK PRIORITIZATION

Classify verified incident types:

- **P0** — security breach, major data loss, complete production outage
- **P1** — serious production degradation or major feature outage
- **P2** — limited operational issue with manageable impact
- **P3** — low-risk maintenance issue

Create runbooks primarily for:

- P0
- P1

Create P2 runbooks only when they are genuinely useful. Do not create unnecessary P3 documentation.

---

## PHASE 5 — CHECK EXISTING RUNBOOKS

If `runbooks/` already exists:

- read all existing files first
- preserve useful instructions
- do not delete valid project-specific knowledge
- do not rewrite files unnecessarily
- update only incorrect, outdated, incomplete, duplicated, or unsafe content

If two runbooks cover the same incident:

- merge or consolidate only when safe and useful
- avoid duplicate documentation

---

## PHASE 6 — CREATE THE MINIMUM REQUIRED STRUCTURE

Create `runbooks/` only if it does not already exist **and** the project actually benefits from it.

Do **NOT** create a large generic directory structure. Possible examples:

```
runbooks/
application-down.md
database-failure.md
deployment-rollback.md
```

But actual filenames must be based on verified project incidents.

- Do not create empty placeholder files.
- Do not create files just to make the directory look complete.

---

## PHASE 7 — REQUIRED RUNBOOK FORMAT

Every runbook should use a consistent practical structure. Use this format where applicable:

```
# Incident: <clear incident name>

## Purpose
What this runbook is for.

## Impact
What users or systems are affected.

## Symptoms
Observable signs such as:
- HTTP status codes
- errors
- logs
- failed jobs
- missing data
- health-check failures

Only include verified/project-relevant symptoms.

## Severity
P0 / P1 / P2 / P3

## Immediate Actions
Safe first actions to reduce impact.
Do not include destructive actions unless absolutely necessary and verified.

## Diagnosis
Step-by-step checks. Prefer actual project commands, paths, dashboards, logs, and services.
Do not invent commands.

## Recovery
Safest recovery procedure. Prefer reversible actions.

## Validation
How to confirm the system is healthy again. Examples:
- health endpoint succeeds
- expected tests pass
- error rate returns to normal
- database connectivity restored
- scheduled job runs successfully

Only use checks supported by the actual project.

## Rollback
How to revert a failed recovery or deployment.
If rollback does not exist, explicitly state:
"No verified rollback mechanism found."

## Escalation
When automated or normal recovery should stop and human intervention is required.

## Do Not
List dangerous actions relevant to the incident. For example:
- do not delete production data
- do not rotate unrelated credentials
- do not bypass security controls
- do not deploy untested changes

Only include relevant warnings.

## Root Cause Follow-Up
Post-incident checks or improvements that should happen after recovery.
```

---

## PHASE 8 — COMMAND SAFETY

Any command placed in a runbook must be verified against the project.

Do not fabricate:

- CLI commands
- file paths
- service names
- environment variables
- deployment commands
- cloud commands
- database commands

If a command cannot be verified, describe the action conceptually instead.

Never include dangerous commands such as destructive database resets unless the project explicitly requires them and there is a safe backup/recovery procedure.

---

## PHASE 9 — PRODUCTION SAFETY

This task is **documentation-only**. You must NOT:

- modify source code
- modify database schema
- run migrations
- deploy anything
- restart production
- rotate credentials
- change DNS
- change cloud infrastructure
- modify CI/CD
- change environment variables
- delete files
- modify user data
- change permissions
- change authentication
- alter production state

Do not perform operational actions. Only document procedures.

---

## PHASE 10 — SECRET SAFETY

Never write real:

- passwords
- API keys
- access tokens
- private keys
- database credentials
- OAuth secrets
- webhook secrets
- session secrets

You may document environment variable **names**. Example: `DATABASE_URL`. Never document its actual value.

If secrets are found in the repository:

- do **NOT** reproduce them
- only note: `Potential secret exposure detected in <file/path>.`

---

## PHASE 11 — SOURCE-OF-TRUTH CHECK

Documentation may be outdated. Do not blindly trust:

- README
- `docs/`
- `brain/`
- comments

Verify important operational instructions against:

- actual code
- deployment files
- CI workflows
- infrastructure configuration
- package scripts
- environment usage

If documentation conflicts with implementation, prefer verified current implementation. Do not change code to match stale documentation.

---

## PHASE 12 — AI SAFETY

Runbooks must not instruct future AI agents to blindly modify production.

Where relevant, clearly distinguish:

`SAFE AUTOMATION`

from:

`REQUIRES HUMAN APPROVAL`

High-risk actions such as:

- deleting data
- restoring production databases
- changing credentials
- changing infrastructure
- modifying access control
- force-pushing
- bypassing security systems

must require explicit human approval.

---

## PHASE 13 — TOKEN / CONTEXT EFFICIENCY

Keep runbooks concise and operational.

- Do **NOT** repeat full architecture explanations in every file.
- Reference existing project documentation when appropriate.
- Each runbook should contain only information required to diagnose and recover from that incident.
- Avoid: generic theory, long tutorials, duplicated setup instructions, filler content.

Optimize for: **"Production is broken. What do I check and do right now?"**

---

## PHASE 14 — FINAL VALIDATION

After creating/updating runbooks:

Re-scan relevant project files. Verify:

- every referenced path exists
- every command is valid
- every environment variable exists where claimed
- every service actually exists
- no secret values were included
- no non-runbook files were modified
- no duplicate runbooks were created
- runbooks match current architecture
- destructive actions are clearly guarded

Check the final git diff. Only runbooks/documentation files should have changed.

---

## FINAL OUTPUT

At completion, provide:

1. Project systems identified
2. Production failure modes identified
3. Runbooks created
4. Runbooks updated
5. Files intentionally NOT created and why
6. P0/P1 incidents covered
7. Operational areas that could not be verified
8. Confirmation that application code/config/infrastructure was not modified

**CRITICAL RULE:**

Do not optimize for number of files. Optimize for:

- accurate
- minimal
- project-specific
- safe
- actionable
- maintainable

runbooks. If the project only requires 3 runbooks, create 3. If it genuinely requires 10, create 10. Never create generic documentation just to fill the folder.
