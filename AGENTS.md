# Dotfiles Repository

This repo manages dotfiles via symlinks from `$HOME` into `~/Dotfiles`.

## Structure

- **Flat files** (e.g. `bashrc`, `vimrc`): Stored without the leading dot. Symlinked as `~/.bashrc`, `~/.vimrc`, etc.
- **Directories** (e.g. `nvim/`): Stored as subdirectories. Symlinked as `~/.config/nvim`, etc.
- **`install.sh`**: The single source of truth for all mappings between repo paths and home directory targets.

## How to add a new dotfile

1. Copy or move the file into this repo.
2. Add a mapping entry to `mappings.conf` in the format `repo_path -> home_target`.
3. Run `./install.sh` to create the symlink (or `./install.sh --dry-run` to preview).

## How to install on a new machine

```bash
git clone https://github.com/mpercy/Dotfiles.git ~/Dotfiles
cd ~/Dotfiles
./install.sh
```

Then follow the post-install steps in `README.md` for tmux, vim, neovim, and zsh plugin setup.

## Important notes

- Never commit secrets, credentials, or tokens to this repo.
- `nvim/lazy-lock.json` and `nvim/undo/` are gitignored.
- The `p10k.zsh` theme config is not tracked; regenerate it with `p10k configure`.
- When editing dotfiles, edit the files in `~/Dotfiles/` (the symlink targets), not the symlinks themselves. Both work, but keeping the mental model consistent helps.
