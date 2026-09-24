# Contributing to ai-agent-skills

Thanks for contributing! This library enforces a consistent structure and quality bar so every skill is trustworthy, safe, and installable.

## Adding a new skill

1. Create a new folder under `skills/`:

   ```
   skills/<skill-name>/
   ├── SKILL.md      # required — the installable skill
   └── README.md     # required — human-readable overview
   ```

2. `SKILL.md` must start with frontmatter containing at least:

   ```yaml
   ---
   name: kebab-case-skill-name
   description: One or two sentences describing what the skill does and when to use it.
   ---
   ```

3. Register the skill in `catalog/skills.yaml`:

   ```yaml
   skills:
     - name: <skill-name>
       category: <category>
       description: >
         Short description.
   ```

4. Add a row to the skills table in the root `README.md`.

## Naming conventions

- Folder name, `name` frontmatter, and catalog entry must match exactly.
- Use lowercase `kebab-case` (e.g. `production-runbook-engineering`).
- Names should describe the skill's function, not the technology it happens to use.

## Quality bar

A skill is accepted when it:

- **Grounds everything in the target repository.** Commands, paths, and services must be verified or explicitly marked `NOT VERIFIED`.
- **Is documentation-only** where it touches production systems. No operational actions, no state changes.
- **Is minimal.** No placeholder files, no filler sections, no generic theory.
- **Protects secrets.** Document env var names only, never values.
- **Marks high-risk actions** as `REQUIRES HUMAN APPROVAL`.
- **Defines a validation phase** that re-checks paths, commands, and the final diff.

## Skill writing guidelines

- Write instructions to the agent, not prose for humans ("Scan the project structure", not "This skill scans…").
- Prefer imperative checklists over paragraphs.
- Include explicit "Do Not" sections where dangerous actions are relevant.
- Keep each skill focused on one job. Split large workflows into separate skills.

## Submitting

1. Fork, branch (`feat/<skill-name>`), and open a PR.
2. CI must pass (frontmatter validation, structure checks).
3. A maintainer reviews for grounding, safety, and minimalism.
4. Squash-merge with a conventional commit message (`feat: add <skill-name>`).

## Skill promotion rule

- Prompt/config-only skill → lives here as a folder.
- Skill that grows substantial code, tests, data, or infrastructure → promote it to its own repository and link it from the catalog.
