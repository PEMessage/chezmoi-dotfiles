#!/bin/bash
# plugin to set "generic shellrc" proxy settings for ProxyMan
# shellrc - ~/.bashrc, ~/.zshrc, /etc/environment
# privileges has to be set by the process which starts this script

# This is required for Elementary OS which contains ~/.bashrc without \n

# Internal use function
# ===========================================
get_file() {
    if [ "$1" = '/dev/stdout' ] ;then
        env | grep -i 'proxy='
    else
        cat "$1"
    fi
}

sed_file() {
    if [ "$2" = '/dev/stdout' ] ;then
        echo "unset ${1}" >> '/dev/stdout'
    else
        [ -e "$2" ] || return 1
        sed -i "/export ${1}\=/d" "$2"
    fi
}

# Public use function
# ===========================================
list_proxy() {
    echo
    echo "${bold}Shell proxy settings : $SHELLRC ${normal}"
    lines="$(get_file $SHELLRC | grep -i 'proxy=' | wc -l)"
    if [ "$lines" -gt 0 ]; then
        get_file $SHELLRC | grep -i 'proxy='
    else
        echo "${red}None${normal}"
    fi
}

unset_proxy() {
    if [ ! -e "$SHELLRC" ]; then
        return
    fi
    # extra effort required to avoid removing custom environment variables set
    # by the user for personal use
    for proxytype in "http" "https" "ftp" "rsync" "no"; do
        sed_file "${proxytype}_proxy" "$SHELLRC"
    done
    for PROTOTYPE in "HTTP" "HTTPS" "FTP" "RSYNC" "NO"; do
        sed_file "${PROTOTYPE}_PROXY" "$SHELLRC"
    done
}

set_proxy() {
    unset_proxy
    if [ ! -e "$SHELLRC" ]; then
        touch "$SHELLRC"
    fi

    local stmt=""
    if [ "$use_auth" = "y" ]; then
        stmt="${username}:${password}@"
    fi

    # caution: do not use / after stmt
    echo "export http_proxy=\"http://${stmt}${http_host}:${http_port}/\""     >> "$SHELLRC"
    # $https_proxy at the end
    echo "export ftp_proxy=\"ftp://${stmt}${ftp_host}:${ftp_port}/\""         >> "$SHELLRC"
    echo "export rsync_proxy=\"rsync://${stmt}${rsync_host}:${rsync_port}/\"" >> "$SHELLRC"
    echo "export no_proxy=\"${no_proxy}\""                                    >> "$SHELLRC"
    echo "export HTTP_PROXY=\"http://${stmt}${http_host}:${http_port}/\""     >> "$SHELLRC"
    # $HTTPS_PROXY at the end
    echo "export FTP_PROXY=\"ftp://${stmt}${ftp_host}:${ftp_port}/\""         >> "$SHELLRC"
    echo "export RSYNC_PROXY=\"rsync://${stmt}${rsync_host}:${rsync_port}/\"" >> "$SHELLRC"
    echo "export NO_PROXY=\"${no_proxy}\""                                    >> "$SHELLRC"

    if [ "$USE_HTTP_PROXY_FOR_HTTPS" = "true" ]; then
        echo "export https_proxy=\"http://${stmt}${http_host}:${http_port}/\"" >> "$SHELLRC"
        echo "export HTTPS_PROXY=\"http://${stmt}${http_host}:${http_port}/\"" >> "$SHELLRC"
    else
        echo "export https_proxy=\"https://${stmt}${https_host}:${https_port}/\"" >> "$SHELLRC"
        echo "export HTTPS_PROXY=\"https://${stmt}${https_host}:${https_port}/\"" >> "$SHELLRC"
    fi
}


# export SHELLRC=$2


# what_to_do=$1
# case $what_to_do in
#     set) set_proxy
#          ;;
#     unset) unset_proxy
#            ;;
#     list) list_proxy
#            ;;
#     *)
#            ;;
# esac
