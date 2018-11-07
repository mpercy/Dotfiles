# dotfiles

## Mike Percy's dot files

To install the dot files:

```bash
git clone https://github.com/mpercy/Dotfiles.git ~/Dotfiles
pip install --user dotfiles # see https://pypi.python.org/pypi/dotfiles
dotfiles --sync
```

For tmux:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins
```

For vim:

```bash
pip install --user powerline-status
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
# For YCM
cd ~/.vim/bundle/YouCompleteMe
./install.py --clang-completer
# For Command-T
cd ~/.vim/bundle/command-t/ruby/command-t/ext/command-t
ruby extconf.rb
make
```
