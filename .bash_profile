# cywin does not automatically read .bashrc
# but MINGW does.
if [[ $(uname) = CYGWIN* ]]
then
    # source the users bashrc if it exists
    if [ -f "${HOME}/.bashrc" ] ; then
      source "${HOME}/.bashrc"
    fi
fi