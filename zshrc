# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# History
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# load zgenom
source "${HOME}/.zgenom/zgenom.zsh"

# Check for plugin and zgenom updates every 7 days
# This does not increase the startup time.
# (Run `zgenom update` to manually update.)
zgenom autoupdate

# if the init script doesn't exist
if ! zgenom saved; then

  # specify plugins here
  zgenom load romkatv/powerlevel10k powerlevel10k
  zgenom load zsh-users/zsh-autosuggestions
  zgenom load zsh-users/zsh-syntax-highlighting
  zgenom load softmoth/zsh-vim-mode

  # generate the init script from plugins above
  zgenom save
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# For building Kudu
export PKG_CONFIG_PATH="$(brew --prefix openssl@1.1)/lib/pkgconfig:$PKG_CONFIG_PATH"

####################################################
# PATH
####################################################
# Add Homebrew
export PATH=/opt/homebrew/opt/ccache/libexec:$PATH

# Add rustup stable toolchain instead of homebrew rust to the path
#export PATH=/opt/homebrew/opt/rust/bin:$PATH
export PATH=$HOME/.rustup/toolchains/stable-aarch64-apple-darwin/bin:$PATH

# Add "go install" GOPATH/bin/
export PATH=$HOME/go/bin:$PATH

# ~/bin
export PATH=$HOME/bin:$PATH



# Added by Windsurf
#export PATH="/Users/mpercy/.codeium/windsurf/bin:$PATH"

# Ensure we start in home directory
# Some zgenom plugins mess up cwd
cd "$HOME"

alias ll="ls -al"
alias chrome="open -a 'Google Chrome'"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/mpercy/.lmstudio/bin"
# End of LM Studio CLI section

