# repository-security-audit

An installable agent skill that audits the security of a **repository itself** — the CI/CD pipelines, dependency supply chain, secrets hygiene, container and infrastructure-as-code configuration, and repo settings around the code — and produces a severity-ordered, evidence-backed findings report with concrete hardening steps.

Modern breaches increasingly target the plumbing around the code: the workflow that runs on every PR, the dependencies pulled at build time, the container image shipped to production, the tokens handed to CI, and the repo settings that decide who can do all of the above. Code-level reviews don't cover these. This skill does.

## The seven audit domains

1. **CI/CD pipeline security** — `pull_request_target` fork-execution, `${{ }}` script injection, over-broad `permissions:`, floating Action tags, secrets in fork-visible steps, self-hosted runners on public repos.
2. **Dependency & supply-chain risk** — missing/committed lockfiles, known CVEs, unpinned ranges and `latest` tags, postinstall code fetch, typosquat/hallucinated packages, publish-token scoping.
3. **Secrets hygiene** — hardcoded credentials, `.gitignore` gaps, secrets already in git history, secrets in build artifacts or logs.
4. **Container security** — floating base images, root user, missing `.dockerignore` leaking `.env`/`.git` into build context, secrets baked into layers.
5. **Infrastructure-as-code** — wildcard IAM, public buckets/security groups, secrets in IaC files, unencrypted storage, committed Terraform state.
6. **Repo configuration & process** — SECURITY.md, CODEOWNERS, Dependabot, release integrity, branch protection (marked `NOT VERIFIED` where it can't be read from files).
7. **AI-generated content risks** — agent-authored workflows/IaC reviewed as untrusted input, over-permissive agent defaults, hallucinated Actions and packages.

## What it produces

A findings report with:

- Executive summary and overall risk level
- **Verified findings** ordered by severity — each with file/line evidence, a concrete attack path, specific remediation (corrected config included), and how to confirm the fix
- **Potential findings** explicitly marked `NOT VERIFIED` (branch protection, runner config, registry settings — things that live outside the repo)
- **What the repo does well**, so correct controls aren't "fixed" unnecessarily
- Tooling/CI recommendations (pinned Actions, Dependabot, secret scanning, OpenSSF Scorecard) with exact config
- Audit limitations

## Safety model

- **Read-only by default.** Reports and recommends; remediation is a separate, user-approved task.
- **Evidence-based.** Every finding cites file/line; suspicions are separated from facts.
- **Secret safety.** Secrets referenced by name/location only; leaked keys flagged for *rotation*; history rewriting is always `REQUIRES HUMAN APPROVAL`.
- **No live actions.** Never triggers workflows, deployments, publishes, or history rewrites during an audit.

## Installation

```bash
npx skills add shamiquekhan/ai-agent-skills --skill repository-security-audit
```

Or copy the `SKILL.md` into your agent's skills directory:

```bash
cp skills/repository-security-audit/SKILL.md ~/.claude/skills/repository-security-audit/SKILL.md
```

## Usage

> "Use the repository-security-audit skill to audit this repo's CI/CD and supply chain."

Works on any repo with CI, containers, or dependencies — and is especially valuable **before open-sourcing a repository** or enabling third-party PRs. Note: if your agent authored the workflows itself, this skill reviews them as untrusted input — which is exactly when it's most useful.

## Related skills

- **[app-security-audit](../app-security-audit/)** — the code-level counterpart. Run both together for the full exposure surface: app code *and* the plumbing around it.
- **[production-runbook-engineering](../production-runbook-engineering/)** — turn verified failure modes into incident runbooks.
- **[repo-to-runbooks](../repo-to-runbooks/)** — the in-project runbook execution skill.

## License

MIT — see the repository root [LICENSE](../../LICENSE).
