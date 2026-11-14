#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p tmp

for f in .vimrc .bashrc .gitconfig; do
  [ -f "$f" ] || continue
  [ -e "$HOME/$f" ] && mv "$HOME/$f" "$HOME/$f.bak"
  ln -s "$PWD/$f" "$HOME/$f"
done

[ -e "$HOME/.vim" ] && mv "$HOME/.vim" "$HOME/.vim.bak"
ln -s "$PWD" "$HOME/.vim"

mkdir -p "$HOME/.config/femto"
ln -sf "$PWD/config/femto/config.json" "$HOME/.config/femto/config.json"
echo "dotfiles installed ✔"
