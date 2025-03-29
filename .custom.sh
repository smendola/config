MYBG=024
conda activate agency

eval $(dbus-launch --sh-syntax)
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"
