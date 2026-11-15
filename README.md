# dotfiles

My config, in the style of codewithzaqar's original 2010 `~/.vim` repo - the repo
root *is* `!/.vim`. Vim + pathogen, bash, git.

## Installation

```sh
git clone https://github.com/codewithzaqar/dotfiles.git ~/dotfiles
~/dotfiles/install.sh               # link everything (backs up existing files)
~/dotfiles/install.sh --with-deps   # also install vim-nox, ruby, ack, ctags + gem
```

Safe to re-num: correct symlinks are kept, everything else is moved to
`~/.dotfiles-backup/<timestamp>/`.

## Updating

```sh
cd ~/dotfiles && git pull   # symlinks pick up changes instantly
```

## Uninstall

```sh
~/dotfiles/install.sh --unlink  # removes only links owned by this repo
```

## Prerequisites

| Package | Powers | Required? |
|---|---|---|
| `git` | clone / pull this repo | **yes** |
| `vim` with `+ruby` (`vim-nox`) | the editor; `+ruby` for FuzzyFinderTextMate |
| `ruby` + `rubygems` | `fuzzy_file_finder` gem | for `,t` |
| `fuzzy_file_finder` (gem) | `,t` file finder | for `,t` |
| `ack` / `ack-grep` | `:Ack` project search | optional |
| `exuberant-ctags` / `universal-ctags` | `:TlistToggle` taglist | optional |
| `curl` | fetching new files | optional |

```sh
./install.sh --check     # audit this machine, change nothing
./install.sh --with-deps # install everything (Debian/Ubuntu)
```
