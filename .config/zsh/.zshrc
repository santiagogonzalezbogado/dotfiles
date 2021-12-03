#zmodload zsh/zprof # Uncomment to enable stats for Zsh with zprof command

# zsh-defer
# git clone --depth=1 https://github.com/romkatv/zsh-defer
source "${ZDOTDIR}/zsh-defer/zsh-defer.plugin.zsh"

autoload -Uz colors && colors
HISTFILE=~/.config/zsh/.zshHistory
HISTSIZE=600000
SAVEHIST=600000

# Completion
typeset -A __DOTS

__DOTS[ITALIC_ON]=$'\e[3m'
__DOTS[ITALIC_OFF]=$'\e[23m'

zstyle ':completion:*' format %F{yellow}-- %B%U%{$__DOTS[ITALIC_ON]%}%d%{$__DOTS[ITALIC_OFF]%}%b%u --%f
zstyle ':compinstall:filename' '/home/st/.config/zsh/.zshrc'
zstyle ':completion:*:*:*:*:*' menu select=3 # If there's less than 3 items it will use normal tabs
zstyle ':completion:*:history-words' menu yes # Activate menu
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':autocomplete:*' min-delay 0.0  # float
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|?=** r:|?=**'
zstyle -e ':completion:*' special-dirs '[[ $PREFIX = (../)#(..) ]] && reply=(..)'
zstyle ':completion:*' matcher-list '' '+m:{[:lower:]}={[:upper:]}' '+m:{[:upper:]}={[:lower:]}' '+m:{_-}={-_}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

setopt multios
setopt prompt_subst # Let the prompt substite variables, without this the prompt will not work
setopt brace_ccl # Allow brace character class list expansion
setopt complete_in_word # Complete from both ends of a word.
setopt always_to_end # Move cursor to the end of a completed word.
setopt correct # Turn on corrections
setopt extendedglob nomatch menucomplete
setopt interactive_comments # Enable comments in interactive shell
setopt hash_list_all # Whenever a command completion is attempted, make sure the entire command path is hashed first.
setopt rm_star_wait

# History
setopt inc_append_history # Ensure that commands are added to the history immediately
setopt hist_save_no_dups # Do not write a duplicate event to the history file.
setopt hist_expire_dups_first
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_verify
setopt autoparamslash
setopt share_history

# Directories
setopt auto_cd # Automatically cd into typed directory.
setopt auto_pushd # Push the current directory visited on the stack.
setopt pushd_ignore_dups # Do not store duplicates in the stack.
setopt pushd_silent # Do not print the directory stack after pushd or popd.

# Unset the annoying bell
unsetopt beep # No soud on error

# Jobs
setopt auto_resume # Attempt to resume existing job before creating a new process.
setopt notify # Report status of background jobs immediately.
setopt no_hup # Don't kill jobs on shell exit.
unsetopt bg_nice # Don't run all background jobs at a lower priority.

# Automatically remove duplicates from these arrays
typeset -U path PATH cdpath CDPATH fpath FPATH manpath MANPATH

watch=(notme root) # watch for everyone but me and root

autoload -Uz compinit # Basic auto/tab complete:
for dump in $ZDOTDIR/.zcompdump(N.mh+24); do # Twice a day it's updated
	compinit
done
compinit -C

_comp_options+=(globdots) # Include hidden files.
zmodload zsh/complist
zmodload zsh/parameter
zmodload zsh/deltochar
zmodload zsh/mathfunc
autoload zcalc
autoload zmv

# Load aliases and functions
zsh-defer source "${ZDOTDIR}/.zshAliasFunrc"

# Vi-mode
source "${ZDOTDIR}/.zshvi"

# Exit error code of the last command
function check_last_exit_code() {
	local LAST_EXIT_CODE=$?
	if [[ $LAST_EXIT_CODE -ne 0 ]]; then
		local EXIT_CODE_PROMPT=' '
		EXIT_CODE_PROMPT+="%{$fg[red]%}❰%{$reset_color%}"
		EXIT_CODE_PROMPT+="%{$fg_bold[red]%}$LAST_EXIT_CODE%{$reset_color%}"
		EXIT_CODE_PROMPT+="%{$fg[red]%}❱%{$reset_color%}"
		echo "$EXIT_CODE_PROMPT"
	fi
}
zle -N check_last_exit_code
autoload -Uz check_last_exit_code

function comple_kitty() {
	if [[ "$TERM" == "xterm-kitty" ]]; then
	COMM="kitty + complete setup zsh"
	eval $COMM >/dev/null
	fi
}
zsh-defer comple_kitty
# zle -N comple_kitty
# autoload -Uz comple_kitty

# Enabling shift-tab for completion
bindkey -M menuselect '^[[Z' reverse-menu-complete

# Change title of the window to the working directory
function change_title() {
	case $TERM in
		xterm*)
			precmd () {print -Pn - '\e]0;%~\a'}
			;;
	esac
}
zle -N change_title
# autoload -Uz change_title
change_title

# Plugins

# z
zsh-defer source /usr/share/z/z.sh

# Load nvm
# zsh-defer source /usr/share/nvm/init-nvm.sh

# Git Status
gitstatus () {
	autoload -Uz vcs_info
	# enable only git
	zstyle ':vcs_info:*' enable git svn

	# setup a hook that runs before every ptompt.
	precmd_vcs_info(){vcs_info}
	precmd_functions+=(precmd_vcs_info)

	zstyle ':vcs_info:git*+set-message:*' hooks git-untracked

	+vi-git-untracked(){
	if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
		git status --porcelain | grep '??' &> /dev/null ; then
			hook_com[staged]+='!' # signify new files with a bang
	fi
	}

	zstyle ':vcs_info:*' check-for-changes true
	zstyle ':vcs_info:git:*' formats " %{$fg[blue]%}❰%{$fg[red]%}%m%u%c%{$fg[yellow]%}%{$fg[magenta]%} %b%{$fg[blue]%}❱"
}
zsh-defer gitstatus

# fzf-tab
# git clone --depth=1 https://github.com/Aloxaf/fzf-tab
zsh-defer source "${ZDOTDIR}/fzf-tab/fzf-tab.plugin.zsh"

# zsh-fzf
zsh-defer source /usr/share/fzf/completion.zsh
zsh-defer source /usr/share/fzf/key-bindings.zsh

# zsh-autosuggestions
zsh-autosuggestions-enable() {
	source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh # Arch Linux
	source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh # Toolbox
	bindkey -M vicmd '^[a' autosuggest-accept
	bindkey -M viins '^[a' autosuggest-execute
}
zsh-defer zsh-autosuggestions-enable

# zsh-autopairs
# git clone --depth=1 https://github.com/hlissner/zsh-autopair
zsh-defer source "${ZDOTDIR}/zsh-autopair/autopair.zsh"

# fast-syntax-highlighting
# git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting
zsh-defer source "${ZDOTDIR}/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"

# PS1="%n%F{white}@%f%{$reset_color%}%m%F{white} %3~%f%{$reset_color%} \$ %{$reset_color%}"
PS1="%n%F{white}@%f%{$reset_color%}%m%F{white} %3~%f%{$reset_color%}   %{$reset_color%}"
RPS1='$(check_last_exit_code) ${vi_mode}'
RPS1+='$vcs_info_msg_0_'

# if [[ ! -z $TOOLBOX_PATH ]]; then
# 	PS1="⬢ $PS1"
# fi
if [[ ! -z $TOOLBOX_PATH ]]; then
	PS1=" 節 $PS1"
fi

#zprof # To time up the zsh load time
