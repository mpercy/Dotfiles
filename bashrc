# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Source global definitions, if they exist.
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
if which notify-send > /dev/null 2>&1; then
  alias alert='notify-send --urgency=critical -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
else
  alias alert=echo
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


#########################################################################
# Custom stuff below.
#########################################################################


if [ -n "$DISPLAY" -a "$TERM" == "xterm" ]; then
  export TERM=xterm-256color
fi

# turn off shell flow control to allow for mapping CTRL-s keybindings in Vim
stty -ixon -ixoff

# for Flume
export MAVEN_OPTS="-Xms512m -Xmx1024m"

export EDITOR=vim

#############################################
# For Kudu
#############################################

# Usually this is where we want the www files served from.
export KUDU_HOME=$HOME/src/kudu

export GLOG_colorlogtostderr=1

# For Kudu HEAPCHECK builds.
#export PPROF_PATH=/home/mpercy/src/kudu/thirdparty/installed/bin/pprof

# For Kudu ASAN builds.
#export LLVM_DIR=/usr/local/llvm
#export LLVM_DIR=/usr/local/lib/ccache # use ccache for clang
#export LLVM_DIR=$HOME/bin/ccache # use ccache for clang

# Get all the deadlock stack traces from TSAN in LLVM 3.5
export TSAN_OPTIONS=second_deadlock_stack=1

# So ASAN does all the work of symbolization / c++filt for us.
#export ASAN_SYMBOLIZER_PATH=$KUDU_HOME/thirdparty/clang-toolchain/bin/llvm-symbolizer
#export ASAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer-3.6

# Run fast tests in dev.
export KUDU_ALLOW_SLOW_TESTS=0

export NO_REBUILD_THIRDPARTY=1
export NO_REMOVE_THIRDPARTY_ARCHIVES=1

# The run-test.sh script overrides ulimit.
export KUDU_TEST_ULIMIT_CORE=unlimited

# Disable building java code and tests by default.
export BUILD_JAVA=0

# mlcomp datasets directory for use with sklearn.datasets.load_mlcomp()
export MLCOMP_DATASETS_HOME=~/data/mlcomp

export GOPATH=$HOME/gocode

export DIST_TEST_MASTER=http://dist-test.cloudera.org
export ISOLATE_SERVER=http://isolate.cloudera.org:4242/

# For Impala
#if [ -d "/usr/lib/jvm/java-7-oracle" ]; then
#  export JAVA_HOME=/usr/lib/jvm/java-7-oracle
#elif [ -d "/usr/lib/jvm/java-8-oracle" ]; then
#  export JAVA_HOME=/usr/lib/jvm/java-8-oracle
#fi

# For Hadoop
export HADOOP_PROTOC_PATH=$HOME/applications/protobuf-2.5.0/bin/protoc

# Allow for a local .bashrc
LOCAL_BASHRC=$HOME/.bashrc.local
if [ -f $LOCAL_BASHRC ]; then
  source $LOCAL_BASHRC
fi
unset LOCAL_BASHRC
