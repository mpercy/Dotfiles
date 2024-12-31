# dotfiles

## Mike Percy's dot files

To install the dot files:

```bash
git clone https://github.com/mpercy/Dotfiles.git ~/Dotfiles
pip3 install --user dotfiles # see https://pypi.python.org/pypi/dotfiles
dotfiles --sync
```

For tmux:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins
```

For vim:

```bash
pip3 install --user powerline-status
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall
# For YCM
cd ~/.vim/plugged/YouCompleteMe
./install.py --clang-completer
# For Command-T
cd ~/.vim/plugged/command-t/lua/wincent/commandt/lib
make
```

For zsh:

```zsh
brew install fzf
git clone https://github.com/jandamm/zgenom.git "${HOME}/.zgenom"
```
