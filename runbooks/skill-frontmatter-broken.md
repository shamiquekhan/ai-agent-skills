# Incident: Malformed SKILL.md frontmatter breaks skill installs and validation

## Purpose

Recover when a skill's `SKILL.md` has missing or incorrect YAML frontmatter (e.g. `name` missing, or `name` not matching the folder name), causing the `npx skills add` install to fail and `scripts/validate-skills.sh` to report errors.

## Impact

- The affected skill cannot be installed by users.
- The `Validate Skills` GitHub Actions workflow fails on push/PR.
- Other skills in the library are unaffected.

## Symptoms

- `npx skills add shamiquekhan/ai-agent-skills --skill <name>` fails with a frontmatter parse error or "name/description missing".
- CI (`Validate Skills` workflow) shows `ERROR: SKILL.md does not start with frontmatter (---)` or `ERROR: frontmatter name '<x>' does not match folder name '<y>'`.
- Local run of `bash scripts/validate-skills.sh` exits non-zero.

## Severity

P1 — installable artifact broken; library itself still functions.

## Immediate Actions

1. Run `bash scripts/validate-skills.sh` to identify which skill failed.
2. Open the named skill's `SKILL.md` and inspect the YAML block between the two `---` lines at the top.

## Diagnosis

1. Confirm the failure via `bash scripts/validate-skills.sh` — it names the skill and the specific error (missing `---`, missing `name:`, missing `description:`, or name mismatch).
2. Open `skills/<skill-name>/SKILL.md` and compare its frontmatter against a known-good sibling (e.g. `skills/repo-to-runbooks/SKILL.md`):
   - file starts with `---` on line 1
   - `name:` present and exactly equals the folder name
   - `description:` present (one or two sentences)
3. Common causes: frontmatter deleted during an edit; `name:` edited without renaming the folder; a tool reformatted or stripped YAML.

## Recovery

1. Restore the frontmatter block in `skills/<skill-name>/SKILL.md`:

   ```yaml
   ---
   name: <skill-name>        # must exactly equal the folder name
   description: >-
     One or two sentences describing what the skill does and when to use it.
   ---
   ```

2. If the folder was renamed but `name:` was not (or vice versa), align both to the same kebab-case value.
3. Run `bash scripts/validate-skills.sh` — it must end with `All skills valid.`

## Validation

- `bash scripts/validate-skills.sh` exits 0 with `All skills valid.`
- `npx skills add shamiquekhan/ai-agent-skills --skill <skill-name>` completes successfully.

## Rollback

`git checkout -- skills/<skill-name>/SKILL.md` restores the last committed copy. No other rollback mechanism exists; there is no deployed artifact to revert.

## Escalation

Stop and get human review if multiple skills fail at once (suggests a tooling/formatting change affected the whole library) or if the catalog registration is also broken (see `broken-catalog-entry.md`).

## Do Not

- Do not rename a skill folder without updating `catalog/skills.yaml` and the README table in the same change.
- Do not "fix" a name mismatch by editing only the frontmatter or only the folder — both must match.
- Do not delete the SKILL.md and start over; preserve the skill body content.

## Root Cause Follow-Up

- Verify the edit that introduced the breakage and whether CI should have caught it before merge (the `Validate Skills` workflow runs on push/PR to `main`).
- Consider adding a test install (`npx skills add` against the branch) to CI if frontmatter issues recur.
