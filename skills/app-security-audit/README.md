# app-security-audit

An installable agent skill that performs a structured security audit of an application repository — with a focus on the **predictable, patterned failure modes of AI-generated ("vibe-coded") apps** — and produces a severity-ordered findings report with concrete remediation for each issue.

## Why this skill exists

AI-generated applications don't fail randomly. Their security mistakes cluster in specific, predictable places, which makes a checklist audit unusually effective: one structured hour catches most of the category. And "the app works" is not proof it's secure — most security problems are invisible through normal browser testing.

## What it checks

### The six core failure modes

1. **Exposed environment variables and API keys** — hardcoded secrets, missing `.gitignore`, secrets in frontend bundles or git history.
2. **Missing or broken row-level isolation** — RLS policies with edge-case bypasses, or tenant filters missing on some query paths; cross-user access by changing an ID.
3. **No server-side validation** — trusting the frontend; permissions hidden in UI instead of enforced on the server; unverified uploads.
4. **Outdated, vulnerable, or hallucinated packages** — known CVEs, packages that don't actually exist, unpinned versions.
5. **Missing or unused authentication middleware** — unprotected admin routes, middleware defined but never mounted, wrong pipeline order.
6. **Over-permissive agent-granted permissions** — admin-scope service accounts, wildcard IAM/RLS grants, API clients that can read more than they write.

### The checks scanners miss

- **Concurrency/sequencing** — double-spend, duplicate submission, lost updates (read-then-write without locking or idempotency).
- **Auth flow abuse** — password reset token predictability, user enumeration, missing rate limits.
- **Payment webhook verification** — can a forged webhook grant a subscription?
- **Cross-user/cross-org access** — traced end-to-end at the code level.
- **CORS, security headers, cookie flags.**

## What it produces

A findings report with:

- Executive summary and overall risk level
- **Verified findings** ordered by severity (each with file/line evidence, an attacker abuse case, concrete remediation, and how to verify the fix)
- **Potential findings** explicitly marked `NOT VERIFIED` (never presented as fact)
- **What the app does well** — so correct controls aren't "fixed" unnecessarily
- **Attacks tested and prevented**
- Tooling/CI recommendations and audit limitations

## Safety model

- **Read-only by default.** Reports and recommends; remediation is a separate, user-approved task. Never runs exploits against live deployments, never points DAST at production, never copies real secret values into reports.
- **Evidence-based.** Findings without file/line evidence are marked `NOT VERIFIED`.
- **Secret safety.** Secrets are referenced by name and location only — and leaked keys are flagged for *rotation*, not just deletion.
- **AI safety.** Distinguishes `SAFE AUTOMATION` from `REQUIRES HUMAN APPROVAL`; never treats "ask the AI that built it" as a security control.

## Installation

```bash
npx skills add shamiquekhan/ai-agent-skills --skill app-security-audit
```

Or copy the `SKILL.md` into your agent's skills directory:

```bash
cp skills/app-security-audit/SKILL.md ~/.claude/skills/app-security-audit/SKILL.md
```

## Usage

> "Use the app-security-audit skill to audit this repository."

For best results, give the agent your architecture, trust boundaries, authentication flow, data model, and deployment setup — not just "is this secure?". The skill instructs the agent to verify every claim against actual code, and to give you specific abuse cases rather than generic warnings.

**Important:** a clean scan is not a clean bill of health. Business-logic and multi-tenant isolation flaws are invisible to most scanners — that's exactly why this skill traces them in code. For anything handling real customer data or payments, get an independent human review before launch.

## Related skills

- **[repository-security-audit](../repository-security-audit/)** — the repo-level counterpart. Run both together for the full exposure surface: application code *and* the CI/CD, supply chain, containers, and repo settings around it.
- **[production-runbook-engineering](../production-runbook-engineering/)** — after the audit, turn verified failure modes into incident runbooks.
- **[repo-to-runbooks](../repo-to-runbooks/)** — the in-project runbook execution skill.

## License

MIT — see the repository root [LICENSE](../../LICENSE).
