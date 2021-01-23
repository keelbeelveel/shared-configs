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

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac
export TERM=xterm-256color

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

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
    ps1_color="yes";
else
    ps1_color="no";
    ps1_256_mode="no";
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
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias vfzf='vim $(fzf)'

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

if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    tmux attach -t default || tmux new -s default
fi

# TMUX CONFIG
tmux source-file ~/tmux.conf

# ALIASES

function generatePS1 {
    ps1_generator_blockA="";
    ps1_generator_blockB="";
    ps1_generator_blockC="";
    ps1_generator_blockD=" $ ";
    ps1_generator="";
    if [ "$ps1_show_hostname" = "yes" ]; then
        ps1_generator_blockA="[\h]";
    else
        ps1_generator_blockA="[\u]";
    fi
    if [ 0 = 0 ]; then
        ps1_generator_blockB="[\W]";
    fi
    if [ "$ps1_show_timestamps" = "yes" ]; then
        ps1_generator_blockC="[\D{%H:%M:%S}]";
    fi
    if [ "$ps1_color" = "no" ]; then
        ps1_generator="$ps1_generator_blockA$ps1_generator_blockB$ps1_generator_blockC$ps1_generator_blockD";
    else
        if [ "$ps1_256_mode" = "yes" ]; then
            ps1_generator="\[\033[38;5;118m\]$ps1_generator_blockA\[\033[0m\]\[\033[38;5;161m\]$ps1_generator_blockB\[\e[m\]\[\033[38;5;166m\]$ps1_generator_blockC\[\e[m\]$ps1_generator_blockD";
        else 
            ps1_generator="\[\e[1;36m\]$ps1_generator_blockA\[\e[m\]\[\e[1;31m\]$ps1_generator_blockB\[\e[m\]\[\e[1;00m\]$ps1_generator_blockC\[\e[m\]$ps1_generator_blockD";
        fi
    fi
    export PS1="$ps1_generator";
}

function toggleTimestamps {
    if [ "$ps1_show_timestamps" = "yes" ]; then
        ps1_show_timestamps="no";
    else
        ps1_show_timestamps="yes";
    fi
    echo "ps1_show_timestamps $ps1_show_timestamps"
    generatePS1;
}
function toggleHostname {
    if [ "$ps1_show_hostname" = "yes" ]; then
        ps1_show_hostname="no";
    else
        ps1_show_hostname="yes";
    fi
    echo "ps1_show_hostname $ps1_show_hostname"
    generatePS1;
}
function toggleColors {
    if [ "$ps1_color" = "yes" ]; then
        ps1_color="no";
    else
        ps1_color="yes";
    fi
    echo "ps1_color $ps1_color"
    generatePS1;
}
function toggle256 {
    if [ "$ps1_256_mode" = "yes" ]; then
        ps1_256_mode="no";
    else
        ps1_256_mode="yes";
    fi
    echo "ps1_256_mode $ps1_256_mode"
    generatePS1;
}
export -f toggleTimestamps
export -f toggleHostname
export -f toggleColors
export -f toggle256
export -f generatePS1

alias ll='ls -la | less'
ps1_show_hostname="no";
ps1_show_timestamps="no";
if [ "$TERM"="xterm-256color" ]; then
    ps1_256_mode="yes";
else
    ps1_256_mode="no";
fi
generatePS1;

alias lm='ls -la | more'
alias la='ls -a'
alias l='ls'

alias go='cd -P'
alias magit='vim -c MagitOnly'

alias vimtips='cmd.exe /c start http://www.alecjacobson.com/weblog/?p=443'
alias tmuxtips='cmd.exe /c start https://tmuxcheatsheet.com/'

alias clean='rm -rvf *.exe *~ *.out *.dSYM *.stackdump'
alias explore='explorer.exe .'

function openweb { cmd.exe /c start https://"$1"; }
function editrc { vim ~/.bashrc; source ~/.bashrc; }
function launch { cmd.exe /c start "$1"; }

export -f openweb
export -f editrc
export -f launch

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
# Install Ruby Gems to ~/gems
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"

git config --global --replace-all alias.root 'rev-parse --show-toplevel'
alias go='cd -P'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export CHROME_DEVEL_SANDBOX=/usr/local/sbin/chrome-devel-sandbox
alias vanillim='vim -u NONE'

alias jobs='jobs -l'
alias kill='sudo kill'

# Utility aliases
alias printHex='printf "%x\n"'
alias printDec='printf "%d\n"'
getOffset() { printf "%d\n" $(($1 & 0xFFFF)); }
export -f getOffset

[[ -s "$HOME/.local/share/marker/marker.sh" ]] && source "$HOME/.local/share/marker/marker.sh"
eval "$(starship init bash)"
