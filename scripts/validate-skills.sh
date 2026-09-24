#!/usr/bin/env bash
# Validates that every skill in skills/ has valid frontmatter, a README,
# and a matching entry in catalog/skills.yaml.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CATALOG="$ROOT/catalog/skills.yaml"
fail=0

if [[ ! -f "$CATALOG" ]]; then
  echo "ERROR: catalog/skills.yaml not found"
  exit 1
fi

for skill_dir in "$ROOT"/skills/*/; do
  [[ -d "$skill_dir" ]] || continue
  name="$(basename "$skill_dir")"
  skill_md="$skill_dir/SKILL.md"
  readme="$skill_dir/README.md"

  echo "Checking skill: $name"

  if [[ ! -f "$skill_md" ]]; then
    echo "  ERROR: missing SKILL.md"
    fail=1
    continue
  fi

  if [[ ! -f "$readme" ]]; then
    echo "  ERROR: missing README.md"
    fail=1
  fi

  # Frontmatter must open with --- and contain name and description
  if [[ "$(head -n1 "$skill_md")" != "---" ]]; then
    echo "  ERROR: SKILL.md does not start with frontmatter (---)"
    fail=1
  elif ! head -n 20 "$skill_md" | grep -q '^name: '; then
    echo "  ERROR: SKILL.md frontmatter missing 'name:'"
    fail=1
  elif ! head -n 20 "$skill_md" | grep -q '^description: '; then
    echo "  ERROR: SKILL.md frontmatter missing 'description:'"
    fail=1
  fi

  # name: in frontmatter must equal the folder name
  fm_name="$(head -n 20 "$skill_md" | grep '^name: ' | head -n1 | sed 's/^name: *//' | tr -d '"' | tr -d "'")"
  if [[ "$fm_name" != "$name" ]]; then
    echo "  ERROR: frontmatter name '$fm_name' does not match folder name '$name'"
    fail=1
  fi

  # Must be registered in the catalog
  if ! grep -q "name: $name" "$CATALOG"; then
    echo "  ERROR: not registered in catalog/skills.yaml"
    fail=1
  fi
done

# Every catalog entry must have a matching folder
while IFS= read -r entry; do
  entry_name="$(echo "$entry" | sed 's/.*name: *//' | tr -d '"' | tr -d "'")"
  if [[ -n "$entry_name" && ! -d "$ROOT/skills/$entry_name" ]]; then
    echo "ERROR: catalog entry '$entry_name' has no skills/$entry_name/ folder"
    fail=1
  fi
done < <(grep -E '^\s*- name: ' "$CATALOG")

if [[ "$fail" -eq 0 ]]; then
  echo "All skills valid."
else
  echo "Validation failed."
  exit 1
fi
