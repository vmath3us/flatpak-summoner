#!/bin/sh
dir=$(pwd)
case "$SHELL" in
    /bin/bash)
        printf "source $dir/flatpak-summoner.sh\n" >> ${HOME}/.bashrc
        exec $SHELL
    ;;
    /bin/zsh)
        printf "source $(pwd)/flatpak-summoner.sh\n" >> ${HOME}/.zshrc
        exec $SHELL
    ;;
    *)
        printf ""$SHELL" not supported, tested only on bash and zsh.
            source $(pwd)/flatpak-summoner.sh
            on shell config%s\n"
    ;;
esac
