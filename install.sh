#!/usr/bin/env bash
# dotfiles-personal/install.sh — entry point for personal machines.
#
# On a fresh machine:
#   git clone <this-repo> ~/.dotfiles/personal
#   ~/.dotfiles/personal/install.sh
#
# The common dotfiles repo will be cloned automatically if not already present.
#
# Usage:
#   ./install.sh              # packages + link + defaults
#   ./install.sh --packages   # packages only
#   ./install.sh --link       # stow + generate configs only
#   ./install.sh --defaults   # macOS defaults only (requires prior --link run)
#
# Override defaults with environment variables before running:
#   DOTFILES_COMMON_DIR=/path/to/common ./install.sh
#   DOTFILES_COMMON_REPO=https://... ./install.sh

set -euo pipefail

DOTFILES_PERSONAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_COMMON_DIR="${DOTFILES_COMMON_DIR:-$HOME/.dotfiles/common}"

# URL of the public common dotfiles repo — update this to your actual repo URL.
DOTFILES_COMMON_REPO="${DOTFILES_COMMON_REPO:-https://github.com/bmfurtado/dotfiles-common.git}"

# ── Bootstrap: ensure common repo is present ─────────────────────────────────

if [[ ! -d "$DOTFILES_COMMON_DIR" ]]; then
  echo "==> Cloning common dotfiles to $DOTFILES_COMMON_DIR ..."
  git clone "$DOTFILES_COMMON_REPO" "$DOTFILES_COMMON_DIR"
fi

# ── Load common framework ─────────────────────────────────────────────────────

# shellcheck source=/dev/null
source "$DOTFILES_COMMON_DIR/lib/utils.sh"
# shellcheck source=/dev/null
source "$DOTFILES_COMMON_DIR/lib/os.sh"
# shellcheck source=/dev/null
source "$DOTFILES_COMMON_DIR/lib/hooks.sh"
# shellcheck source=/dev/null
source "$DOTFILES_COMMON_DIR/lib/apps.sh"
# shellcheck source=/dev/null
source "$DOTFILES_COMMON_DIR/lib/packages.sh"
# shellcheck source=/dev/null
source "$DOTFILES_COMMON_DIR/lib/link.sh"
# shellcheck source=/dev/null
source "$DOTFILES_COMMON_DIR/lib/macos.sh"

# ── Repo order: common first, then this profile ───────────────────────────────

DOTFILES_REPOS=("$DOTFILES_COMMON_DIR" "$DOTFILES_PERSONAL_DIR")

# ── Argument parsing ──────────────────────────────────────────────────────────

DO_PACKAGES=false
DO_LINK=false
DO_DEFAULTS=false
_any_flag=false

for arg in "$@"; do
  case "$arg" in
    --packages) DO_PACKAGES=true; _any_flag=true ;;
    --link)     DO_LINK=true;     _any_flag=true ;;
    --defaults) DO_DEFAULTS=true; _any_flag=true ;;
    --help|-h)
      echo "Usage: $0 [--packages] [--link] [--defaults]"
      echo "  (no flags)   Run all phases: packages + link + defaults"
      echo "  --packages   Install packages only"
      echo "  --link       Stow configs and regenerate .gitconfig only"
      echo "  --defaults   Apply macOS defaults only (requires prior --link run)"
      exit 0
      ;;
    *) die "Unknown argument: $arg" ;;
  esac
done

if [[ "$_any_flag" == false ]]; then
  DO_PACKAGES=true
  DO_LINK=true
  DO_DEFAULTS=true
fi

# ── Main ──────────────────────────────────────────────────────────────────────

main() {
  log "OS: $(detect_os) / $(detect_arch)"
  log "Active repos:"
  for repo in "${DOTFILES_REPOS[@]}"; do printf "  - %s\n" "$repo"; done

  run_hooks "pre-install"

  if [[ "$DO_PACKAGES" == true ]]; then
    log "Installing packages..."
    install_all_packages
  fi

  if [[ "$DO_LINK" == true ]]; then
    log "Linking config files..."
    stow_all
    generate_gitconfig
  fi

  if [[ "$DO_DEFAULTS" == true ]]; then
    log "Applying macOS defaults..."
    apply_macos_defaults
  fi

  run_hooks "post-install"
  ok "Done."
}

main
