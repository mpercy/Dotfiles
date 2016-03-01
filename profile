# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

######################################
# Custom stuff below.
######################################

# Allow core dumps
ulimit -c unlimited

# For Kudu
PATH=$PATH:$HOME/src/kudu/thirdparty/clang-toolchain/bin
PATH=$PATH:$HOME/src/kudu/thirdparty/installed/bin
PATH=$HOME/.local/bin:$PATH # pip install --user
PATH=$HOME/bin/llvm-system-bin:$PATH
PATH=/usr/lib/ccache:$PATH
PATH=$HOME/bin/ccache:$PATH  # My preferred ccache stuff.

# For bundler.
if which ruby >/dev/null && which gem >/dev/null; then
  PATH="$(ruby -rubygems -e 'puts Gem.user_dir')/bin:$PATH"
fi

PATH=$HOME/applications/google_appengine:$PATH

export PATH
