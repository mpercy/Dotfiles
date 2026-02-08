#!/usr/bin/env bash
#
# Dotfiles install script
#
# Creates symlinks from home directory locations to files in this repo.
# Existing files are backed up to <target>.bak before symlinking.
#
# Usage: ./install.sh [--dry-run]

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
DRY_RUN=false

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "=== DRY RUN (no changes will be made) ==="
fi

MAPPINGS_FILE="$DOTFILES_DIR/mappings.conf"

if [[ ! -f "$MAPPINGS_FILE" ]]; then
  echo "ERROR: $MAPPINGS_FILE not found"
  exit 1
fi

link_item() {
  local src="$DOTFILES_DIR/$1"
  local dst="$HOME/$2"

  if [[ ! -e "$src" ]]; then
    echo "SKIP   $src (source does not exist)"
    return
  fi

  # Already correctly linked
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    echo "OK     $dst -> $src"
    return
  fi

  # Target exists and is not the right symlink — back it up
  if [[ -e "$dst" || -L "$dst" ]]; then
    if $DRY_RUN; then
      echo "BACKUP $dst -> ${dst}.bak"
    else
      mv "$dst" "${dst}.bak"
      echo "BACKUP $dst -> ${dst}.bak"
    fi
  fi

  # Ensure parent directory exists
  local parent
  parent="$(dirname "$dst")"
  if [[ ! -d "$parent" ]]; then
    if $DRY_RUN; then
      echo "MKDIR  $parent"
    else
      mkdir -p "$parent"
      echo "MKDIR  $parent"
    fi
  fi

  if $DRY_RUN; then
    echo "LINK   $dst -> $src"
  else
    ln -s "$src" "$dst"
    echo "LINK   $dst -> $src"
  fi
}

while IFS= read -r line; do
  # Skip comments and blank lines
  [[ "$line" =~ ^[[:space:]]*# ]] && continue
  [[ -z "${line// /}" ]] && continue

  # Parse "repo_path -> home_target"
  repo_path="$(echo "$line" | sed 's/[[:space:]]*->.*$//')"
  home_target="$(echo "$line" | sed 's/^.*->[[:space:]]*//')"

  link_item "$repo_path" "$home_target"
done < "$MAPPINGS_FILE"

echo ""
echo "Done. Review any .bak files and remove them when satisfied."
