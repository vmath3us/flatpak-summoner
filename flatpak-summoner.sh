#########################################-flatpak on shell, if or not inside distrobox
#by vmath3us
FLT_DTB_HANDLER_DEBUG=0       ############ use any to attached process, example FLT_DTB_HANDLER_DEBUG=1 firefox 
command_not_found_handle(){ #############direct zsh version
    if [ $FLT_DTB_HANDLER_DEBUG -eq "0" ] ; then
        end_command='>/dev/null 2>/dev/null &'   #### detached process, not output, close terminal not kill program. close std(out/err) using 1>&- 2>&- crash vscode and others, redirect to dev/null by default
    fi
flatpak_command="flatpak run"
#################################################################################################
#################################################################################################
#################################################################################################
#################################################################################################
######## if your not using distrobox (github.com/89luca89/distrobox) , remove this session
  if [ ! -e /run/.containerenv ] && [ ! -e /.dockerenv ]; then
      flatpak_command="flatpak run"     ### on host using flatpak
  else # 3
      dhe="$(which distrobox-host-exec)" ##### is possible install distrobox on /usr/local,/usr, or ~/.local/bin
      $dhe "${@}" 2>/dev/null || flatpak_command="$dhe flatpak run" #if on container, try on host, or on host using flatpak
  fi
#################################################################################################
#################################################################################################
#################################################################################################
#################################################################################################
    cmd=$1 ###################-preserve name command to search
    shift ####################-remaining entry (path or parameter) on $@
    args=(${@})     ###### needed to zsh. https://stackoverflow.com/a/72144680
    for i in ${args[@]}; do
        entry="${entry} \"${i}\""
    done   ####### escape special characters, on links or files. eval try expand = , ?, etc
########## flatpak list --app is slow, find directly on bin path
flatpak_bin_dir[1]="${HOME}/.local/share/flatpak/exports/bin"
flatpak_bin_dir[2]="/var/lib/flatpak/exports/bin" ##### -- user as precedence. Comment to disable. if there are the same names for user and system, the user's appear first
    if [ "$FLT_DTB_HANDLER_DEBUG" -eq "0" ] ; then
        path_bin=($(find ${flatpak_bin_dir[@]} -maxdepth 1 -iname "*"${cmd}"*" -printf '%P\n' 2>/dev/null)) ##### search command ,stderror closed by default
    else
        path_bin=($(find ${flatpak_bin_dir[@]} -maxdepth 1 -iname "*"${cmd}"*" -printf '%P\n'))
    fi
    if [ "${#path_bin[@]}" -eq "1" ]; then   ##### if there is only one result ,run
      final_command="$flatpak_command ${path_bin} ${entry} $end_command" #### create command
       printf "$final_command%s\n" ###### show command
      eval ${final_command} ####### finally run
    elif [ "${#path_bin[@]}" -gt "1" ] ; then ########### else, ask why
        select choice in ${path_bin[@]}; do
        final_command="$flatpak_command ${path_bin} "${entry}" $end_command" #### create command
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
command_not_found_handle "${@}"
}
fi
