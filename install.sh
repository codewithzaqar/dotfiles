#!/usr/bin/env bash
# install.sh — link this repo into $HOME (the repo root doubles as ~/.vim)
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

WITH_DEPS=0 UNLINK=0 CHECK_ONLY=0
for arg in "$@"; do
  case "$arg" in
    --with-deps) WITH_DEPS=1 ;;
    --unlink)    UNLINK=1 ;;
    --check)     CHECK_ONLY=1 ;;
    -h|--help)   echo "usage: ./install.sh [--with-deps] [--check] [--unlink]"; exit 0 ;;
    *)           echo "unknown option: $arg" >&2; exit 1 ;;
  esac
done

has() { command -v "$1" >/dev/null 2>&1; }

backup() {
  mkdir -p "$BACKUP_DIR"
  mv "$1" "$BACKUP_DIR/"
  echo "  backup  $1 -> $BACKUP_DIR/"
}

link() { # link <src> <dest>
  local src="$1" dest="$2"
  if [ ! -e "$src" ]; then echo "  skip    $src (missing)"; return; fi
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "  ok      $dest"; return
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then backup "$dest"; fi
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "  link    $dest -> $src"
}

unlink() {
  local dest="$1"
  if [ -L "$dest" ] && [[ "$(readlink "$dest")" == "$REPO"* ]]; then
    rm "$dest"; echo "  unlink  $dest"
  fi
}

install_deps() {
  echo "Installing prerequisites (apt) ..."
  if ! has apt-get; then
    echo "  apt-get not found - install the packages from README.md manually." >&2
    return 1
  fi
  sudo apt-get update
  sudo apt-get install -y git vim-nox ruby curl
  sudo apt-get install -y ack || sudo apt-get install -y ack-grep
  sudo apt-get install -y exuberant-ctags || sudo apt-get install -y universal-ctags
  if has gem; then sudo gem install fuzzy_file_finder; fi
}

check_prereqs() {
  local failed=0
  echo "Checking prerequisites ..."

  # required
  for cmd in git vim; do
    if has "$cmd"; then echo "  ok      $cmd"
    else echo "  MISSING $cmd (required)"; failed=1; fi
  done

  # optional - each powers a specific plugin
  if has ack || has ack-grep; then echo "  ok      ack (:Ack)"
  else echo "  warn    ack missing -> :Ack disabled (apt install ack)"; fi
  if has ctags; then echo "  ok      ctags (:TlistToggle)"
  else echo "  warn    ctags missing -> taglist disabled (apt install exuberant-ctags)"; fi
  if has curl; then echo "  ok      curl"
  else echo "  warn    curl missing (only needed to fetch new files)"; fi
  if has ruby && has gem; then
    echo "  ok      ruby/gem"
    if gem list -i fuzzy_file_finder 2>/dev/null | grep -q true; then
      echo "  ok      gem fuzzy_file_finder (,t)"
    else
      echo "  warn    gem fuzzy_file_finder missing -> ,t disabled (sudo gem install fuzzy_file_finder)"
    fi
  else
    echo "  warn    ruby/gem missing -> ,t disabled (apt install ruby)"
  fi
  if has vim; then
    if vim --version 2>/dev/null | grep -q '+ruby'; then
      echo "  ok      vim +ruby (FuzzyFinderTextMate)"
    else
      echo "  warn    vim without +ruby -> ,t disabled (apt install vim-nox)"
    fi
  fi

  return "$failed"
}

# ---- main ---------------------------------------------------------------

if [ "$UNLINK" = 1 ]; then
  echo "Removing dotfile links owned by $REPO ..."
  for f in .vimrc .bashrc .gitconfig .vim; do unlink "$HOME/$f"; done
  unlink "$HOME/.config/femto/config.json"
  echo "Done. Old files are in ~/.dotfiles-backup/ if you need them."
  exit 0
fi

if [ "$WITH_DEPS" = 1 ]; then install_deps; fi

if ! check_prereqs; then
  echo "" >&2
  echo "Required prerequisites are missing. Fix them or run: ./install.sh --with-deps" >&2
  exit 1
fi
if [ "$CHECK_ONLY" = 1 ]; then exit 0; fi

echo "Installing dotfiles from $REPO"
mkdir -p "$REPO/tmp"   # swap-file dir referenced by .vimrc

for f in .vimrc .bashrc .gitconfig; do link "$REPO/$f" "$HOME/$f"; done
link "$REPO" "$HOME/.vim"                                   # repo root IS ~/.vim
link "$REPO/config/femto/config.json" "$HOME/.config/femto/config.json"

echo "Done. Run 'exec bash' (or open a new terminal) to pick everything up."
