# in non-interactive shells, do not do any of this stuff
# output from .bashrc etc. causes scp to fail
if [[ $PS1 ]]
then
# cywin does not automatically read .bashrc
# but MINGW does.
if [[ $(uname) = CYGWIN* ]]
then
    # source the users bashrc if it exists
    if [ -f "${HOME}/.bashrc" ] ; then
      source "${HOME}/.bashrc"
    fi
fi
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
