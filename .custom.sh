# PortAudio fix for microphone access
export PORTAUDIO_DEVICE_ID="pulse"
export PA_ALSA_PLUGHW=1
export PULSE_LATENCY_MSEC=60
export ALSA_DEFAULT_PCM="pulse"
export ALSA_DEFAULT_CTL="pulse"
export PULSE_PROP="media.role=audio application.id=portaudio-app application.name=\"PortAudio App\""

MYBG=024

eval $(dbus-launch --sh-syntax)
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"

export CONDAENVDIR=""
cd() {
    builtin cd "$@" &&
    if [ -f $PWD/.conda_env ]; then
        export CONDAENVDIR=$PWD
        conda activate $(cat .conda_env)
    elif [ "$CONDAENVDIR" ]; then
        if [[ $PWD != *"$CONDAENVDIR"* ]]; then
            export CONDAENVDIR=""
            conda deactivate
        fi
    fi
}

conda activate booking_agent
