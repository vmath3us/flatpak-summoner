#########################################-flatpak on shell, if or not inside distrobox
#############################################           by vmath3us
FLT_DTB_HANDLER_DEBUG=0       ############ use any to attached process, example FLT_DTB_HANDLER_DEBUG=1 firefox 
command_not_found_handle(){ #############direct zsh version
#################################################################################################
#################################################################################################
######## if your not using distrobox (github.com/89luca89/distrobox) , remove this session
  if [  -e /run/.containerenv ] || [  -e /.dockerenv ]; then
      dhe="/usr/bin/distrobox-host-exec" ##### inside container distrobox-host-exec ever on /usr/bin
  fi
#################################################################################################
#################################################################################################
    cmd=$1 ###################-preserve input command to search
    shift ####################-remaining entry (path or parameter) on $@
########## flatpak list --app is slow, find directly on bin path
flatpak_bin_dir[1]="${HOME}/.local/share/flatpak/exports/bin"
flatpak_bin_dir[2]="/var/lib/flatpak/exports/bin" ##### -- user as precedence. Comment to disable. if there are the same names for user and system, the user's appear first
    if [ "$FLT_DTB_HANDLER_DEBUG" -eq "0" ] ; then
        path_bin=($(find ${flatpak_bin_dir[@]} -iname "*"${cmd}"*" -print 2>/dev/null))
    else
        path_bin=($(find ${flatpak_bin_dir[@]} -iname "*"${cmd}"*" -print))
    fi
    if [ "${#path_bin[@]}" -eq "1" ]; then   ##### if there is only one result ,run
        if [ "$FLT_DTB_HANDLER_DEBUG" -eq "0" ] ; then
            echo -e  "$dhe $path_bin "${@}" >/dev/null 2>/dev/null &\n"
            $dhe $path_bin "${@}" >/dev/null 2>/dev/null &  ##close stdout and stderr (>&- 2>&-) crash some programs (example, vscode)
        else
            $dhe $path_bin "${@}"
        fi
    elif [ "${#path_bin[@]}" -gt "1" ] ; then ########### else, ask why
        human_reader=(${path_bin[@]##*/})
        select choice in ${human_reader[@]}; do
            if [ "$FLT_DTB_HANDLER_DEBUG" -eq "0" ] ; then
                echo -e  "$dhe ${flatpak_bin_dir[1]}/$choice "${@}" >/dev/null 2>/dev/null &\n"
                $($dhe ${flatpak_bin_dir[1]}/$choice "${@}" >/dev/null 2&>/dev/null &) ||
                echo -e  "$dhe ${flatpak_bin_dir[1]}/$choice "${@}" >/dev/null 2>/dev/null &\n" ;
                $($dhe ${flatpak_bin_dir[2]}/$choice "${@}" >/dev/null 2>/dev/null &)
            else
                $dhe ${flatpak_bin_dir[1]}/$choice "${@}" ||
                $dhe ${flatpak_bin_dir[2]}/$choice "${@}"
            fi
            break       #### escape to select loop
        done
    else
        exit 127   ##### if not found flatpak exec, find exit 1, command not found code is 127
    fi
}
if [ -n "${ZSH_VERSION-}" ]; then       #### thanks 89luca89 on github.com/89luca89/distrobox
command_not_found_handler() {
command_not_found_handle "${@}"
}
fi
