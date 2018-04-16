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
#if [ -f "${HOME}/.bashrc" ] ; then
#  source "${HOME}/.bashrc"
#fi

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

function repo()
{
    cd ~/work/$1
}

function ..()
{
    cd ..
}

function vs()
{
    cmd.exe /C start /b "" "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\devenv.exe" $1
}

function housekeeping()
{
    git branch --merged | egrep -v "(^\*|master|dev)" | xargs git branch -d && git remote prune origin
}

function buildwindow() 
{
   cmd.exe /C buildwindow.bat 
}

function build() 
{
    cmd.exe /C buildwindow.bat build 
}

function init() 
{
    cmd.exe /C buildwindow.bat init
}

function testrun() 
{
    cmd.exe /C buildwindow.bat test
}

function fixrepo() 
{
    chmod -f +x *.bat *.exe Build/*.exe Build/*.bat build/*.exe build/*.bat .paket/*.exe
}

function dbpasswordreset()
{
    ~/work/DIPS.PassWordUtility/tools/DIPS.PasswordUtility.exe --password dips1234 --datasource $1 --username DIPS-HHE
}

function paket() 
{
    if [ ! -f ".paket/paket.exe" ] ; then
        ".paket/paket.bootstrapper.exe"
    fi

    .paket/paket.exe $@
}

function gs()
{
    git status
}

function killpaket()
{
    ps -W | awk '$0~v,NF=1' v=paket.exe | xargs taskkill /F /pid
}

function createPR()
{
    # Get repository push url
    local pushurl=`git remote -v 2> /dev/null | sed -e '/(fetch)$/d' -e 's/^origin\s*//' -e 's/\s(push)$//'`
    local teamurl=`echo $pushurl | sed -e 's/\/_git/\/Musk\/_git/g'`

    # Use https instead of ssh
    local url=`echo $teamurl | sed -e 's/ssh:\/\//http:\/\//g' -e 's/:22/:8080/g'`

    # Add sub URI including branch name (with escaped ampersands)
    url+="/pullrequests?sourceRef="
    url+=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/*\s//'`
    url+="^&targetRef=master^&_a=createnew"
    cmd.exe /C start $url
}

function cd()
{
    [[ -z "$*" ]] && builtin cd $HOME
    [[ -n "$*" ]] && builtin cd "$*"
    update_title
}

function findgrep()
{
    find $0 -name $1 -exec grep $2 {} +;
}

function certificateinfo()
{
    echo | openssl s_client -showcerts -servername $0 -connect $0:443 2>/dev/null | openssl x509 -inform pem -noout -text
}

function update_title()
{
  if git rev-parse &> /dev/null;
      then windowTitle=`basename $(git rev-parse --show-toplevel)``parse_git_branch`
      else windowTitle=`pwd`
  fi
  echo -en '\033]2;'$windowTitle'\007'
  # echo -en '\033k'$windowTitle'\033\\' # if the above doesn't work
}

function parse_git_branch() 
{
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

function dipsclone()
{
    git clone ssh://vd-tfs03:22/tfs/DefaultCollection/DIPS/_git/$@ && cd $@
}

_dipsclone_repo_list()
{
    local password
    # Save your password in plaintext with 'echo "secret" > pass.txt'
    # then run 'openssl rsautl -encrypt -oaep -pubin -inkey <(ssh-keygen -e -f ~/.ssh/id_rsa.pub -m PKCS8) -in pass.txt -out pass.txt.enc' 
    # on your pass.txt, and place the resulting file in the .ssh folder. Remove the plaintext pass.txt file afterwards.
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

alias ls="ls --color=auto"
LS_COLORS="di=32:ln=36;1:ex=31;1:*~=31;1:*.cs=94:*.xaml=95:*.csproj=96:*.sln=96"
export LS_COLORS

# For setting bash prompt to 'user@hostname workingdirectory (branchIfGitRepo)
export PS1="\[\033[34m\]\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] \n$ "

