# dotfiles

## Mike Percy's dot files

To install:

```bash
git clone https://github.com/mpercy/Dotfiles.git ~/Dotfiles
pip install --user dotfiles # see https://pypi.python.org/pypi/dotfiles
dotfiles --sync
```

For Vim:

```bash
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
# For YCM
cd ~/.vim/bundle/YouCompleteMe
./install.py --clang-completer
# For Command-T
cd ~/.vim/bundle/command-t/ruby/command-t
ruby extconf.rb
make
```
