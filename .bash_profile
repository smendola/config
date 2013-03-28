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
