#!/usr/bin/env bash
# Installs the docker aliases and the dls command for the current user.
#
#   Install:    wget -qO- https://raw.githubusercontent.com/Martinski-Github/docker-aliases/main/install.sh | bash
#   Uninstall:  wget -qO- https://raw.githubusercontent.com/Martinski-Github/docker-aliases/main/install.sh | bash -s -- --uninstall
#
# Running it again updates everything to the latest version.
set -euo pipefail

# GitHub repo to install from (override with DOCKER_ALIASES_REPO / DOCKER_ALIASES_BRANCH).
REPO="${DOCKER_ALIASES_REPO:-Martinski-Github/docker-aliases}"
BRANCH="${DOCKER_ALIASES_BRANCH:-main}"
RAW_BASE="https://raw.githubusercontent.com/$REPO/$BRANCH"

ALIASES="$HOME/.docker-aliases.sh"
BIN_DIR="$HOME/.local/bin"
MARKER="# docker-aliases"
SOURCE_LINE='[ -f "$HOME/.docker-aliases.sh" ] && . "$HOME/.docker-aliases.sh"  '"$MARKER"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

fetch() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$1"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- "$1"
  else
    die "need curl or wget"
  fi
}

# When run from a clone, use the files next to this script instead of downloading.
LOCAL_DIR=''
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  LOCAL_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
fi

# get_file <path in repo> <destination>: fetch, syntax-check, then move into place.
get_file() {
  local src=$1 dest=$2 tmp
  tmp=$(mktemp)
  if [ -n "$LOCAL_DIR" ] && [ -f "$LOCAL_DIR/$src" ]; then
    cp "$LOCAL_DIR/$src" "$tmp"
  elif ! fetch "$RAW_BASE/$src" >"$tmp"; then
    rm -f "$tmp"
    die "could not download $RAW_BASE/$src - check REPO/BRANCH in install.sh"
  fi
  if ! bash -n "$tmp"; then
    rm -f "$tmp"
    die "$src has a syntax error, not installing"
  fi
  mv "$tmp" "$dest"
  info "Installed $dest"
}

# Shell rc files to hook into: .bashrc always, .zshrc if the user has one.
rc_files() {
  echo "$HOME/.bashrc"
  if [ -f "$HOME/.zshrc" ]; then
    echo "$HOME/.zshrc"
  fi
}

remove_hook() {
  local rc=$1 tmp
  [ -f "$rc" ] || return 0
  tmp=$(mktemp)
  grep -vF "$MARKER" "$rc" >"$tmp" || true
  cat "$tmp" >"$rc"   # keep the original file's permissions
  rm -f "$tmp"
}

uninstall() {
  local rc
  for rc in $(rc_files); do
    remove_hook "$rc"
  done
  rm -f "$ALIASES" "$BIN_DIR/dls"
  info "Removed docker aliases and dls. Open a new terminal to drop them from your session."
}

install() {
  local rc
  mkdir -p "$BIN_DIR"
  get_file aliases.sh "$ALIASES"
  get_file bin/dls "$BIN_DIR/dls"
  chmod +x "$BIN_DIR/dls"

  for rc in $(rc_files); do
    touch "$rc"
    if ! grep -qF "$MARKER" "$rc"; then
      printf '\n%s\n' "$SOURCE_LINE" >>"$rc"
      info "Hooked into $rc"
    fi
  done

  if ! command -v docker >/dev/null 2>&1; then
    info "Note: docker is not installed yet."
  fi
  info "Done. Run 'source ~/.docker-aliases.sh' or open a new terminal."
}

case "${1:-}" in
  --uninstall|-u) uninstall ;;
  ""|--install)   install ;;
  *)              die "unknown option: $1 (use --uninstall)" ;;
esac
