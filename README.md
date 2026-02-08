# dotfiles

## Mike Percy's dot files

### Install

```bash
git clone https://github.com/mpercy/Dotfiles.git ~/Dotfiles
cd ~/Dotfiles
./install.sh        # creates symlinks; backs up existing files to *.bak
./install.sh --dry-run  # preview without making changes
```

The mapping between repo files and their home directory targets is defined
in `install.sh`.

### Post-install setup

#### Zsh

```bash
brew install fzf
git clone https://github.com/jandamm/zgenom.git "${HOME}/.zgenom"
```

Then open a new zsh shell. Zgenom will auto-install plugins on first run.

#### Powerlevel10k prompt

The `p10k.zsh` config is not tracked (it's large and easily regenerated).
To configure:

```zsh
p10k configure
```

#### Tmux

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins
```

#### Vim

```bash
pip3 install --user powerline-status
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall
# For YCM
cd ~/.vim/plugged/YouCompleteMe
./install.py --clang-completer
# For Command-T
cd ~/.vim/plugged/command-t/lua/wincent/commandt/lib
make
```

#### Neovim

Neovim plugins are managed by `lazy.nvim` and will auto-install on first launch:

```bash
nvim  # lazy.nvim bootstraps itself and installs plugins
```

LSP servers are managed by Mason and will auto-install when you first open
a file of a supported language.
