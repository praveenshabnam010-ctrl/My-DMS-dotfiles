#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/praveenshabnam010-ctrl/My-DMS-dotfiles.git"
DEFAULT_CLONE="${XDG_DATA_HOME:-$HOME/.local/share}/My-DMS-dotfiles"

SELF="${BASH_SOURCE[0]:-}"
REPO_DIR=""
if [[ -n "$SELF" && -f "$SELF" ]]; then
  REPO_DIR="$(cd -- "$(dirname -- "$SELF")" >/dev/null 2>&1 && pwd)"
fi

if [[ -z "$REPO_DIR" || ! -d "$REPO_DIR/home" ]]; then
  echo "Fetching My-DMS-dotfiles from GitHub..."
  REPO_DIR="$DEFAULT_CLONE"
  if [[ ! -d "$REPO_DIR/.git" ]]; then
    git clone --depth 1 "$REPO_URL" "$REPO_DIR"
  else
    git -C "$REPO_DIR" pull --ff-only
  fi
fi

HOME_SRC="$REPO_DIR/home"
MODE="copy"
INSTALL_PACKAGES=0
WITH_WALLPAPERS=1
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage: install.sh [OPTIONS]

Copies the My-DMS-dotfiles configuration into $HOME, backing up any file
that is replaced. Existing unmanaged files are left alone.

Options:
  --packages       Install packages from packages.txt with yay/paru/pacman
  --no-wallpapers  Do not copy Pictures/Wallpapers
  --dry-run        Show what would be installed without changing files
  -h, --help       Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --packages) INSTALL_PACKAGES=1 ;;
    --no-wallpapers) WITH_WALLPAPERS=0 ;;
    --dry-run) DRY_RUN=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
  shift
done

BACKUP="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
if [[ "$DRY_RUN" -eq 0 ]]; then
  mkdir -p "$BACKUP"
fi

install_packages() {
  local pkgs=()
  while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    pkgs+=("$line")
  done < "$REPO_DIR/packages.txt"

  if command -v yay >/dev/null 2>&1; then
    yay -S --needed --noconfirm "${pkgs[@]}"
  elif command -v paru >/dev/null 2>&1; then
    paru -S --needed --noconfirm "${pkgs[@]}"
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm "${pkgs[@]}"
  else
    echo "No supported package manager found. See packages.txt." >&2
    return 1
  fi
}

if [[ "$INSTALL_PACKAGES" -eq 1 ]]; then
  install_packages
fi

prepare_gtk4() {
  local dir="$HOME/.config/gtk-4.0"
  [[ -L "$dir" ]] || return 0
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "would replace symlink $dir"
    return 0
  fi
  mkdir -p "$BACKUP/.config"
  cp -a "$dir" "$BACKUP/.config/gtk-4.0"
  rm -f "$dir"
}

install_tree() {
  local src rel dest
  while IFS= read -r -d '' src; do
    rel="${src#"$HOME_SRC"/}"
    if [[ "$WITH_WALLPAPERS" -eq 0 && "$rel" == Pictures/Wallpapers/* ]]; then
      continue
    fi
    dest="$HOME/$rel"

    if [[ "$DRY_RUN" -eq 0 && ( -e "$dest" || -L "$dest" ) ]]; then
      mkdir -p "$BACKUP/$(dirname "$rel")"
      cp -a "$dest" "$BACKUP/$rel"
    fi

    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "would install $rel"
      continue
    fi

    mkdir -p "$(dirname "$dest")"
    cp -a "$src" "$dest"

    if grep -Iq . "$dest" 2>/dev/null; then
      sed -i "s|__HOME__|$HOME|g" "$dest"
    fi
  done < <(find "$HOME_SRC" -type f -print0)
}

prepare_gtk4
install_tree

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "Dry run complete."
  exit 0
fi

cat <<EOF

Installed My-DMS-dotfiles.

Backups: $BACKUP
Next steps:
  1. Log out and back in so niri/DMS reload the configuration.
  2. Open the wallpaper picker with Mod+Y (or DMS settings with Mod+Comma)
     and choose a wallpaper from ~/Pictures/Wallpapers.
  3. Reinstall DMS plugins from the Plugins page if you use them.

No browser is installed by this repo. Generated theme files (dank-*.conf,
dank-colors.css, dms/*.kdl, dms.lua, firewatch.lua, DankMatugen*.colors,
dank-zed-theme.json) are refreshed by DankMaterialShell whenever the
wallpaper changes.
EOF
