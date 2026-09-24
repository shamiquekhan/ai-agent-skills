# ai-agent-skills

**Shamique Khan — AI Agent Skills Library**

A curated, tested library of installable agent skills. Each folder in [`skills/`](skills/) is an independently installable skill with its own `SKILL.md`, designed to be grounded, minimal, and production-safe.

## Skills

| Skill | Category | Purpose |
| ----- | -------- | ------- |
| [production-runbook-engineering](skills/production-runbook-engineering/) | DevOps | Analyze a repository and create minimal, verified, production-safe incident runbooks |
| [repo-to-runbooks](skills/repo-to-runbooks/) | DevOps | In-project execution skill: create or improve a production-ready `runbooks/` directory for an existing codebase |
| [app-security-audit](skills/app-security-audit/) | Security | Structured security audit targeting AI-generated app failure modes; produces an evidence-backed, severity-ordered findings report |
| [repository-security-audit](skills/repository-security-audit/) | Security | Audit the repo itself: CI/CD, supply chain, secrets hygiene, containers, IaC; evidence-backed findings report |

## Install a skill

```bash
npx skills add shamiquekhan/ai-agent-skills --skill production-runbook-engineering
```

Or copy any skill's `SKILL.md` into your agent's skills directory, e.g.:

```bash
cp skills/production-runbook-engineering/SKILL.md ~/.claude/skills/production-runbook-engineering/SKILL.md
```

## Repository layout

```
ai-agent-skills/
├── README.md
├── CONTRIBUTING.md
├── LICENSE
├── catalog/
│   └── skills.yaml
├── scripts/
│   └── validate-skills.sh
├── runbooks/
│   └── *.md                    # operational runbooks for this repository
├── skills/
│   ├── production-runbook-engineering/
│   │   ├── SKILL.md
│   │   └── README.md
│   ├── repo-to-runbooks/
│   │   ├── SKILL.md
│   │   └── README.md
│   ├── app-security-audit/
│   │   ├── SKILL.md
│   │   └── README.md
│   └── repository-security-audit/
│       ├── SKILL.md
│       └── README.md
└── .github/
    └── workflows/
```

## Design principles

Every skill in this library follows the same rules:

1. **Repository as source of truth.** Skills verify against the actual codebase; nothing unverifiable is invented (it's marked `NOT VERIFIED` instead).
2. **Documentation-only safety model.** Skills document procedures; they do not modify code, infrastructure, or production state.
3. **Minimalism over file count.** Skills create only what the project genuinely needs.
4. **Secret safety.** Environment variable names, never values. Detected exposures are flagged, not reproduced.
5. **AI safety.** High-risk actions are marked `REQUIRES HUMAN APPROVAL`, never automated blindly.

## Adding a skill

See [CONTRIBUTING.md](CONTRIBUTING.md). Short version: add a folder under `skills/` with a `SKILL.md` (frontmatter: `name` + `description`) and a `README.md`, then register it in `catalog/skills.yaml` and the table above.

## Naming rule

- Prompt/config-only skill → one folder in this skill library.
- Skill + substantial code/tests/data/infrastructure → its own separate repository.

## License

[MIT](LICENSE)
