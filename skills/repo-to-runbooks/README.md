# repo-to-runbooks

An installable agent skill that works **inside an existing software project** to create or improve a production-ready `runbooks/` directory — operational recovery guides for when something breaks in production.

## What it does

The skill executes one job, in order:

**SCAN → UNDERSTAND → IDENTIFY REAL FAILURE MODES → CREATE ONLY NECESSARY RUNBOOKS**

1. **Full project scan** — languages, frameworks, databases, auth, queues, cron jobs, CI/CD, deployments, monitoring, and more. Read-only.
2. **Production understanding** — traces how the app starts, serves requests, stores data, deploys, detects failures, and rolls back.
3. **Real incident identification** — only incidents supported by the repository. No runbooks for systems the project doesn't use.
4. **Risk prioritization** — P0/P1 runbooks first; P2 only when genuinely useful; no P3 filler.
5. **Existing runbook preservation** — updates only what is incorrect, outdated, or unsafe.
6. **Minimal structure** — no placeholder files, no generic directory trees.
7. **Consistent format** — Purpose, Impact, Symptoms, Severity, Immediate Actions, Diagnosis, Recovery, Validation, Rollback, Escalation, Do Not, Root Cause Follow-Up.
8. **Final validation** — re-checks every path, command, and env var; confirms the git diff touched only runbooks.

## Safety model

- **Documentation-only.** Never modifies code, refactors, or changes configuration/infrastructure.
- **Repository as source of truth.** Unverifiable commands/paths/services are marked `NOT VERIFIED`, never invented.
- **Secret safety.** Env var names may be documented; values never are. Detected secret exposure is flagged, not reproduced.
- **AI safety.** High-risk actions are explicitly marked `REQUIRES HUMAN APPROVAL`.

## Installation

Install with the skills CLI:

```bash
npx skills add shamiquekhan/ai-agent-skills --skill repo-to-runbooks
```

Or copy the `SKILL.md` into your agent's skills directory:

```bash
cp skills/repo-to-runbooks/SKILL.md ~/.claude/skills/repo-to-runbooks/SKILL.md
```

## Usage

From the root of the project you want documented, ask your agent:

> "Use the repo-to-runbooks skill to create runbooks for this project."

The agent will scan the repo, identify real failure modes, and write verified runbooks (typically into `runbooks/`) — without touching any other files.

## Related skill

- **[production-runbook-engineering](../production-runbook-engineering/)** — the sibling skill. Same runbook quality bar, framed for analyzing any target repository from the outside (`production-runbook-engineering` is the workflow/methodology skill; `repo-to-runbooks` is the in-project execution skill).

## License

MIT — see the repository root [LICENSE](../../LICENSE).
