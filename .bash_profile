# To the extent possible under law, the author(s) have dedicated all 
# copyright and related and neighboring rights to this software to the 
# public domain worldwide. This software is distributed without any warranty. 
# You should have received a copy of the CC0 Public Domain Dedication along 
# with this software. 
# If not, see <http://creativecommons.org/publicdomain/zero/1.0/>. 

# base-files version 4.2-3

# ~/.bash_profile: executed by bash(1) for login shells.

# The latest version as installed by the Cygwin Setup program can
# always be found at /etc/defaults/etc/skel/.bash_profile

# Modifying /etc/skel/.bash_profile directly will prevent
# setup from updating it.

# The copy in your home directory (~/.bash_profile) is yours, please
# feel free to customise it to create a shell
# environment to your liking.  If you feel a change
# would be benifitial to all, please feel free to send
# a patch to the cygwin mailing list.

# User dependent .bash_profile file

# source the users bashrc if it exists
if [ -f "${HOME}/.bashrc" ] ; then
  source "${HOME}/.bashrc"
fi

# Set PATH so it includes user's private bin if it exists
# if [ -d "${HOME}/bin" ] ; then
#   PATH="${HOME}/bin:${PATH}"
# fi

# Set MANPATH so it includes users' private man if it exists
# if [ -d "${HOME}/man" ]; then
#   MANPATH="${HOME}/man:${MANPATH}"
# fi

# Set INFOPATH so it includes users' private info if it exists
# if [ -d "${HOME}/info" ]; then
#   INFOPATH="${HOME}/info:${INFOPATH}"
# fi

## only ask for my SSH key passphrase once!
#use existing ssh-agent if possible
if [ -f ${HOME}/.ssh-agent ]; then
   . ${HOME}/.ssh-agent > /dev/null
fi
if [ -z "$SSH_AGENT_PID" -o -z "`/usr/bin/ps -a|/usr/bin/egrep \"^[ ]+$SSH_AGENT_PID\"`" ]; then
   /usr/bin/ssh-agent > ${HOME}/.ssh-agent
   . ${HOME}/.ssh-agent > /dev/null
fi
ssh-add ~/.ssh/id_rsa

function ..()
{
    cd ..
}

function vs()
{
    cmd /C start /b "" "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\devenv.exe" $1
}

function housekeeping()
{
    git branch --merged | egrep -v "(^\*|master|dev)" | xargs git branch -d && git remote prune origin
}

function build() 
{
    cd build && scriptcs build.csx -- build && cd ..
}

function init() 
{
    cd build && scriptcs build.csx -- init && cd ..
}

function testrun() 
{
    cd build && scriptcs build.csx -- test && cd ..
}

function paket()
{
    .paket/paket.exe $1
}

function fixrepo() 
{
    chmod -f +x *.bat *.exe Build/*.exe Build/*.bat build/*.exe build/*.bat .paket/*.exe
}

function update_title()
{
  if git rev-parse &> /dev/null;
      then windowTitle=`basename $(git rev-parse --show-toplevel)``parse_git_branch`
      else windowTitle=`pwd`
  fi
  echo -en '\033]2;'$windowTitle'\007'
}

function cd()
{
    [[ -z "$*" ]] && builtin cd $HOME
    [[ -n "$*" ]] && builtin cd "$*"
    update_title
}

function parse_git_branch() 
{
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\[\033[34m\]\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] \n$ "


function dipsclone()
{
    git clone ssh://vd-tfs03:22/tfs/DefaultCollection/DIPS/_git/$1
}

_dipsclone_repo_list()
{
    local password
    password=`openssl rsautl -decrypt -oaep -inkey ~/.ssh/id_rsa -in ~/.ssh/pass.txt.enc`

    curl -s -u hhe:$password --ntlm http://vd-tfs03:8080/tfs/DefaultCollection/_apis/git/repositories/ | jq '.value[].name' | sed 's/"//g' | tr '[:upper:]' '[:lower:]' > ~/.dipsclone_repositories
}

_dipsclone_complete() 
{
    local cur_word type_list

    # COMP_WORDS is an array of words in the current command line.
    # COMP_CWORD is the index of the current word (the one the cursor is
    # in). So COMP_WORDS[COMP_CWORD] is the current word.
    cur_word="${COMP_WORDS[COMP_CWORD]}"

    # Find list of possible repositories
    type_list=`cat ~/.dipsclone_repositories`

    # COMPREPLY is the array of possible completions, generated with
    # the compgen builtin.
    COMPREPLY=( $(compgen -W "${type_list}" -- ${cur_word}) )
    return 0
}
# Register _dipsclone_complete to provide completion for the dipsclone command
_dipsclone_repo_list
complete -F _dipsclone_complete dipsclone
