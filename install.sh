#!/usr/bin/env bash
set -Eeuo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$DOTFILES_DIR/brewfile/Brewfile"

DRY_RUN=0
SKIP_BREW=0
SKIP_STOW=0
SKIP_PLUGINS=0
RUN_DOCTOR=1

PACKAGES=(
  alacritty
  conda
  git
  newsboat
  nvim
  scripts
  skhd
  task
  tmux
  yabai
  zsh
)

usage() {
  cat <<USAGE
Usage: ./install.sh [options]

Bootstrap this dotfiles checkout onto the current machine.

Options:
  -n, --dry-run       Print commands without changing the system
      --skip-brew     Do not run brew bundle
      --skip-stow     Do not create/update symlinks with stow
      --skip-plugins  Do not install/update zsh or tmux plugins
      --no-doctor     Do not run bin/dotfiles-doctor after install
  -h, --help          Show this help
USAGE
}

log() {
  printf '==> %s\n' "$*"
}

warn() {
  printf 'WARN: %s\n' "$*" >&2
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

run() {
  if (( DRY_RUN )); then
    printf 'DRY-RUN:'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

ensure_dir() {
  local dir="$1"
  if (( DRY_RUN )); then
    printf 'DRY-RUN: mkdir -p %q\n' "$dir"
  else
    mkdir -p "$dir"
  fi
}

parse_args() {
  while (($#)); do
    case "$1" in
      -n|--dry-run) DRY_RUN=1 ;;
      --skip-brew) SKIP_BREW=1 ;;
      --skip-stow) SKIP_STOW=1 ;;
      --skip-plugins) SKIP_PLUGINS=1 ;;
      --no-doctor) RUN_DOCTOR=0 ;;
      -h|--help) usage; exit 0 ;;
      *) die "Unknown option: $1" ;;
    esac
    shift
  done
}

prepare_directories() {
  log "Creating runtime directories"
  ensure_dir "$HOME/.config"
  ensure_dir "$HOME/.local/bin"
  ensure_dir "$HOME/.local/state/zsh"
  ensure_dir "$HOME/.cache/zsh"
  ensure_dir "$HOME/.config/tmux/plugins"
  ensure_dir "$HOME/.config/local/share/tmux/resurrect"
}

install_brew_bundle() {
  (( SKIP_BREW )) && { log "Skipping Homebrew"; return; }
  [[ -f "$BREWFILE" ]] || { warn "Brewfile not found: $BREWFILE"; return; }

  if ! command_exists brew; then
    warn "Homebrew is not installed; skipping brew bundle"
    return
  fi

  log "Running brew bundle"
  run brew bundle --file "$BREWFILE"
}

stow_packages() {
  (( SKIP_STOW )) && { log "Skipping stow"; return; }

  command_exists stow || die "stow is required. Install it or run with --skip-stow."

  log "Restowing dotfile packages"
  run stow --dir "$DOTFILES_DIR" --target "$HOME" --restow "${PACKAGES[@]}"
}

install_plugins() {
  (( SKIP_PLUGINS )) && { log "Skipping plugins"; return; }

  if command_exists git; then
    local tpm_dir="$HOME/.config/tmux/plugins/tpm"
    if [[ ! -d "$tpm_dir" ]]; then
      log "Installing tmux plugin manager"
      run git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm_dir"
    fi
    if [[ -x "$tpm_dir/bin/install_plugins" ]]; then
      log "Installing tmux plugins"
      run "$tpm_dir/bin/install_plugins"
    fi
  else
    warn "git is unavailable; skipping tmux plugin install"
  fi

  if command_exists zsh; then
    log "Syncing declared zsh plugins"
    run zsh -i -c 'zsh_sync_declared_plugins'
  else
    warn "zsh is unavailable; skipping zsh plugin sync"
  fi
}

run_doctor() {
  (( RUN_DOCTOR )) || return 0
  [[ -x "$DOTFILES_DIR/bin/dotfiles-doctor" ]] || {
    warn "Doctor command not found or not executable: $DOTFILES_DIR/bin/dotfiles-doctor"
    return
  }

  log "Running dotfiles doctor"
  run "$DOTFILES_DIR/bin/dotfiles-doctor"
}

main() {
  parse_args "$@"
  log "Dotfiles root: $DOTFILES_DIR"
  (( DRY_RUN )) && log "Dry-run mode enabled"

  prepare_directories
  install_brew_bundle
  stow_packages
  install_plugins
  run_doctor
}

main "$@"
