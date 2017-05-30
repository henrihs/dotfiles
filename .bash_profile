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
    cmd /C start /b "" "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\devenv.exe" $1
}

function housekeeping()
{
    git branch --merged | egrep -v "(^\*|master|dev)" | xargs git branch -d && git remote prune origin
}

function buildwindow() 
{
   cmd /C buildwindow.bat 
}

function build() 
{
    cmd /C buildwindow.bat build 
}

function init() 
{
    cmd /C buildwindow.bat init
}

function testrun() 
{
    cmd /C buildwindow.bat test
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

    # Use https instead of ssh
    local url=`echo $pushurl | sed -e 's/ssh:\/\//http:\/\//g' -e 's/:22/:8080/g'`

    # Add sub URI including branch name (with escaped ampersands)
    url+="/pullrequests?sourceRef="
    url+=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/*\s//'`
    url+="^&targetRef=master^&_a=createnew"
    
    cmd /C start $url
}

function dipsclone()
{
    git clone http://vd-tfs03:8080/tfs/DefaultCollection/DIPS/_git/$@
}

parse_git_branch() 
{
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\[\033[34m\]\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] \n$ "

