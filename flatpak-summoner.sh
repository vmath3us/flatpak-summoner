#########################################-flatpak on shell, if or not inside distrobox
FLT_DTB_HANDLER_DEBUG=0       ############ use any to attached process, example FLT_DTB_HANDLER_DEBUG=1 firefox 
command_not_found_handle() {
    ###### if command not exists on path, run
    #
flatpak_and_distrobox_aux_bin_handler "${@}"
# don't run if not in a container
}
flatpak_and_distrobox_aux_bin_handler(){ #############direct zsh version
    if [ $FLT_DTB_HANDLER_DEBUG -eq "0" ] ; then
        end_command='>/dev/null 2>/dev/null &'   #### detached process, not output, close terminal not kill program.
        #####close std(out/err) using 1>&- 2>&- crash vscode and others, redirect to dev/null by default
    fi
#################################################################################################
#################################################################################################
#################################################################################################
#################################################################################################
######## if your not using distrobox (github.com/89luca89/distrobox) , preserve line 2
  if [ ! -e /run/.containerenv ] && [ ! -e /.dockerenv ]; then # 1
      flatpak_command="flatpak run"     ### on host using flatpak # 2
  else # 3
      dhe="$(which distrobox-host-exec)" ##### is possible install distrobox on /usr/local,/usr, or ~/.local/bin # 4
      $dhe "${@}" 2>/dev/null || flatpak_command="$dhe flatpak run" #if on container, try on host, or on host using flatpak # 5
  fi # 6
#################################################################################################
#################################################################################################
#################################################################################################
#################################################################################################
    cmd=$1 ###################-preserve name command to search
    shift ####################-remaining entry (path or parameter) on $@
########## flatpak list --app is slow, find directly on bin path
flatpak_bin_dir[1]="${HOME}/.local/share/flatpak/exports/bin"
flatpak_bin_dir[2]="/var/lib/flatpak/exports/bin" ##### -- user as precedence . Edit to using only user, or only system . if there are the same names for user and system, the user's appear first
    path_bin=($(find $flatpak_bin_dir -maxdepth 1 -iname "*"${cmd}"*" -printf '%P\n')) ##### search command
    if [ "${#path_bin[@]}" -eq "1" ]; then   ##### if there is only one result ,run
        final_command="$flatpak_command ${path_bin} "${@}" $end_command" #### create command
       printf "$final_command%s\n" ###### show command
       eval ${final_command} ####### finally run
    elif [ "${#path_bin[@]}" -gt "1" ] ; then ########### else, ask why
        select choice in ${path_bin[@]}; do
            final_command="$flatpak_command $choice "${@}" $end_command"  ### create command
            printf "$final_command%s\n" ###### show command
            eval ${final_command} ############ finally run
            break       #### escape to select loop
        done
    else
        exit 127   ##### if not found flatpak exec, find exit 1, command not found code is 127
    fi
}
if [ -n "${ZSH_VERSION-}" ]; then       #### thanks 89luca89 on github.com/89luca89/distrobox
  command_not_found_handler() {
    command_not_found_handle "$@"
 }
fi
