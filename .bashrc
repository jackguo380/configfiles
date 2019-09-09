# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

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
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"


# Enable Vi mode
set -o vi

# use jj to escape insert mode
#bind '"jj":"\e"'

# cd up a directory with Ctrl-u
bind '"\C-g":"cd ..\n"'

# Bash Prompt
# [user@hostname][~/workdir]
# [N] $
color_reset='\[\033[0m\]'
user_color='\[\033[1;92m\]'
ssh_color='\[\033[1;95m\]'
sep_color='\[\033[1;90m\]'
dir_color='\[\033[1;94m\]'

_prompt_command() {
    # Args
    status=$1

    # Set title of terminal window to /bin/bash: /path/to/work/dir
    start_title=$'\033]0;'
    end_title=$'\a'

    echo -n "${start_title} ${SHELL}: ${PWD} ${end_title}"

    unset start_title end_title

    # Print [failed: N] for commands returning non-zero
    color_reset=$'\033[0m'
    sep_color=$'\033[1;90m'
    fail_b_color=$'\033[1;91m'
    fail_color=$'\033[91m'

    if [ "$status" -ne 0 ]; then
        output="${color_reset}${sep_color}["
        output="$output${fail_b_color}failed: "
        output="$output${color_reset}${fail_color}${status}"
        output="$output${sep_color}]${color_reset}"

        echo "$output"
    fi

    unset status output color_reset sep_color fail_b_color fail_color
}

PROMPT_COMMAND='_prompt_command $?'

# Reset the any colors from before
PS1="${color_reset}"
# [failed: N]
#PS1="$PS1"'$(_print_line_on_fail_command $? $_)'
# [username@host]
PS1="$PS1${sep_color}["
PS1="$PS1${user_color}\u@\h"
PS1="$PS1${sep_color}]"
# [ssh@ip]
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    PS1="$PS1${sep_color}["
    PS1="$PS1${ssh_color}ssh@${SSH_CLIENT%% *}"
    PS1="$PS1${sep_color}]"
fi
# [/path/to/work/dir]
PS1="$PS1${sep_color}["
PS1="$PS1${dir_color}\w"
PS1="$PS1${sep_color}]"
# $
PS1="$PS1\n${sep_color} \$${color_reset} "

# Add color to the multiline prompt
PS2="${color_reset} ${sep_color}>${color_reset}"

unset color_reset user_color ssh_color sep_color dir_color

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

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

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

export PATH="$HOME/.local/bin:$PATH"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
