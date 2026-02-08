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

# Newer go-lang.
export PATH=/usr/lib/go-1.10/bin:$PATH

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

######################################
# Custom stuff below.
######################################

# Allow core dumps
ulimit -c unlimited

# Workaround for Intellij input issue on IBus < 1.5.11: https://youtrack.jetbrains.com/issue/IDEA-78860
export IBUS_ENABLE_SYNC_MODE=1

# Try to get the gpg agent to work.
export GPGKEY=66F2054B
export GPG_TTY=$(tty)
export GPG_AGENT_INFO

PATH=$HOME/applications/google_appengine:$PATH
PATH="/usr/local/heroku/bin:$PATH"

# For pip install --user.
PATH=$HOME/.local/bin:$PATH

# For bpftrace
PATH=$HOME/applications/bpftrace/bin:$PATH
export MANPATH=$MANPATH:$HOME/applications/bpftrace/man

# VTune.
if [ -f "/opt/intel/vtune_amplifier_xe/amplxe-vars.sh" ]; then
  source "/opt/intel/vtune_amplifier_xe/amplxe-vars.sh" "quiet"
fi

# For bundler.
# TODO: FIXME: bionic barfing on this?
#if which ruby >/dev/null && which gem >/dev/null; then
#  PATH="$(ruby -rubygems -e 'puts Gem.user_dir')/bin:$PATH"
#fi

# For Chromium and breakpad
#PATH=$HOME/src/depot_tools:$PATH

# For Kudu
PATH=$HOME/src/kudu/thirdparty/installed/common/bin:$PATH
PATH=$HOME/bin/llvm-system-bin:$PATH
PATH=$HOME/src/kudu/thirdparty/clang-toolchain/bin:$PATH
PATH=/usr/lib/ccache:$PATH
PATH=$HOME/bin/ccache:$PATH  # My preferred ccache stuff.

export PATH

# Allow for a local .profile
LOCAL_PROFILE=$HOME/.profile.local
if [ -f $LOCAL_PROFILE ]; then
  source $LOCAL_PROFILE
fi
unset LOCAL_PROFILE

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/mpercy/.lmstudio/bin"
# End of LM Studio CLI section

