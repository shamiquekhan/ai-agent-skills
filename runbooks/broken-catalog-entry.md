# Incident: Catalog and skill folder out of sync (missing or renamed skill)

## Purpose

Recover when `catalog/skills.yaml` and the `skills/` directory disagree — a skill folder exists without a catalog entry, or the catalog references a folder that does not exist — breaking validation and hiding the skill from the README directory.

## Impact

- `scripts/validate-skills.sh` fails, and the `Validate Skills` CI workflow goes red.
- A missing catalog entry leaves the skill invisible in the README skills table and any future automated directory built from the catalog.
- A dangling catalog entry advertises a skill that cannot be installed.

## Symptoms

- `bash scripts/validate-skills.sh` prints `ERROR: not registered in catalog/skills.yaml` or `ERROR: catalog entry '<name>' has no skills/<name>/ folder`.
- `Validate Skills` workflow fails on push/PR.
- A new skill is missing from the README table after merge.

## Severity

P1 — library integrity/introspection broken; installs of other skills still work.

## Immediate Actions

1. Run `bash scripts/validate-skills.sh` and note which direction the mismatch goes (folder without entry, or entry without folder).
2. Check `git status` / `git log --oneline -5` for a rename or partial copy (e.g. folder renamed without the catalog update).

## Diagnosis

1. List actual folders: `ls skills/`.
2. List catalog entries: `grep -E '^\s*- name: ' catalog/skills.yaml`.
3. Compare the two lists — every folder must have exactly one entry, and every entry must have a folder.
4. Determine intent: was the folder added without registering (incomplete change) or was a skill intentionally removed/renamed (incomplete removal)?

## Recovery

1. **Folder exists, entry missing** — append to `catalog/skills.yaml`:

   ```yaml
     - name: <skill-name>
       category: <category>
       description: >
         Short description.
   ```

2. **Entry exists, folder missing** — either restore the folder (e.g. `git checkout -- skills/<skill-name>/`) or remove the stale entry from `catalog/skills.yaml` if the removal was intentional.
3. Run `bash scripts/validate-skills.sh` — it must end with `All skills valid.`

## Validation

- `bash scripts/validate-skills.sh` exits 0 with `All skills valid.`
- The skill appears in the README skills table (or its removal no longer leaves a dangling row).

## Rollback

`git checkout -- catalog/skills.yaml skills/` reverts both sides of the mismatch. No deployed artifact exists to roll back.

## Escalation

Stop and get human review if the mismatch spans many skills (bulk deletion/renaming) or if git history does not show which state was intended.

## Do Not

- Do not delete a skill folder to "fix" a dangling entry without confirming the removal was intentional.
- Do not re-register a skill under a new name without also renaming the folder, updating the README table, and updating any cross-links in sibling skill READMEs.
- Do not edit the catalog by hand while a bulk rename tool is mid-run; wait and re-run the validator.

## Root Cause Follow-Up

- The catalog and README table are currently updated by hand — consider a CI step that syncs the README table from `catalog/skills.yaml` to prevent recurrence.
- Check whether the PR that introduced the mismatch skipped the `Validate Skills` check.
