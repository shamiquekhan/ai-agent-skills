# Incident: Validate Skills CI workflow failing on push or PR

## Purpose

Recover when the `Validate Skills` GitHub Actions workflow fails, blocking confidence in merged changes to the skill library.

## Impact

- Red CI on `main` and PRs; merges lose their structural safety net.
- Contributors are blocked from trusting that new skills are installable.
- No user-facing outage — the library is a content repository.

## Symptoms

- Red X on the commit/PR from the `Validate Skills` workflow.
- Workflow log shows the validator script failing (`Validation failed.`, exit code 1) or the checkout step failing.

## Severity

P2 — limited operational issue with manageable impact; no production system is affected.

## Immediate Actions

1. Open the failing run in the GitHub Actions tab and identify which step failed: checkout, or `Validate skill structure`.
2. If the checkout step failed, this is an infra/GitHub issue — retry the run once.

## Diagnosis

1. Read the failing step's log output; the validator prints a specific `ERROR:` line per skill (missing SKILL.md, missing README.md, frontmatter problems, catalog mismatch).
2. Reproduce locally: `bash scripts/validate-skills.sh` — local behavior mirrors CI exactly (same script, same bash).
3. Match the error to its runbook: frontmatter errors → `skill-frontmatter-broken.md`; catalog/folder mismatch → `broken-catalog-entry.md`.
4. If the script itself fails with a bash error (e.g. after an edit to `scripts/validate-skills.sh`), run `bash -n scripts/validate-skills.sh` to check syntax.

## Recovery

1. Fix the underlying skill/structure issue per the matched runbook above, or fix the script regression.
2. Run `bash scripts/validate-skills.sh` locally until it prints `All skills valid.`
3. Commit the fix and push; confirm the workflow goes green.

## Validation

- `Validate Skills` workflow completes green on the fix commit/PR.
- `bash scripts/validate-skills.sh` exits 0 locally.

## Rollback

`git revert <commit>` of the offending change. There is no deployed service to roll back; the workflow definition itself lives in `.github/workflows/validate.yml` and can be reverted the same way.

## Escalation

Stop and get human review if the workflow fails for infrastructure reasons (GitHub Actions outage, runner/checkout failures) that persist across retries, or if the validator script itself needs a structural change.

## Do Not

- Do not disable the workflow or add `continue-on-error` to make CI green — validation is the library's only structural safety net.
- Do not merge with failing checks; the failure indicates an installable artifact is broken.
- Do not edit the workflow to skip the failing skill rather than fixing it.

## Root Cause Follow-Up

- Confirm the PR that broke CI had the check enabled on its branch.
- If failures are frequent, consider running the validator as a pre-commit hook for contributors.
