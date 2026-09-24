# production-runbook-engineering

An installable agent skill that analyzes an existing repository and creates minimal, verified, production-safe incident runbooks based strictly on the project's actual architecture, deployment, dependencies, and failure modes.

## What it does

The skill follows a rigorous workflow:

**SCAN → UNDERSTAND → IDENTIFY → PRIORITIZE → DOCUMENT → VERIFY**

1. **Full project scan** — languages, frameworks, databases, auth, queues, cron jobs, CI/CD, deployments, monitoring, and more. Read-only.
2. **Production understanding** — traces how the app starts, serves requests, stores data, deploys, detects failures, and rolls back.
3. **Real incident identification** — only incidents supported by the repository. No runbooks for systems the project doesn't use.
4. **Risk prioritization** — P0/P1 runbooks first; P2 only when genuinely useful; no P3 filler.
5. **Existing runbook preservation** — updates only what is incorrect, outdated, or unsafe.
6. **Minimal structure** — no placeholder files, no generic directory trees.
7. **Consistent format** — Purpose, Impact, Symptoms, Severity, Immediate Actions, Diagnosis, Recovery, Validation, Rollback, Escalation, Do Not, Root Cause Follow-Up.

## Safety model

- **Documentation-only.** The skill never modifies code, infrastructure, or production state.
- **Repository as source of truth.** Unverifiable commands/paths/services are marked `NOT VERIFIED`, never invented.
- **Secret safety.** Env var names may be documented; values never are. Detected secret exposure is flagged, not reproduced.
- **AI safety.** High-risk actions are explicitly marked `REQUIRES HUMAN APPROVAL`.

## Installation

Install with the skills CLI:

```bash
npx skills add shamiquekhan/ai-agent-skills --skill production-runbook-engineering
```

Or copy the `SKILL.md` into your agent's skills directory:

```bash
cp skills/production-runbook-engineering/SKILL.md ~/.claude/skills/production-runbook-engineering/SKILL.md
```

## Usage

Ask your agent, for example:

> "Use the production-runbook-engineering skill to create runbooks for this repository."

The agent will scan the repo, identify real failure modes, and write verified runbooks (typically into `runbooks/`) — without touching any other files.

## Example output

For a project with a Node.js API, Postgres, and GitHub Actions deploys, you might get:

```
runbooks/
├── application-down.md
├── database-connection-failure.md
└── deployment-rollback.md
```

Exactly the runbooks the project needs — nothing more.

## Related skill

- **[repo-to-runbooks](../repo-to-runbooks/)** — the in-project execution skill. Same workflow and safety model, framed for running directly inside an existing project to create or improve its `runbooks/` directory.

## License

MIT — see the repository root [LICENSE](../../LICENSE).
