#!/bin/bash
#======================================[ FUNCTIONS ]======================================

notification ()
{
    current_time="$(date)"
    echo "=============================="
    echo "date:   $current_time"
    echo "Domain: $3"
    echo "Email:  $1"
    echo "Status: $2"
    echo "=============================="
    echo "Logs have been created at user /logs home directory"
    logs $4 $1 $2 "$5"
}

logs ()
{
    #File Location
    usr_uid="$(id -u $1)"
    usr_gud="$(id -g $1)"
    user_path="$(grep $1 /etc/passwd | awk '{gsub("'$1':x:'$usr_uid':'$usr_gud'::",""); print}' | awk '{gsub(":/usr/local/cpanel/bin/jailshell",""); print}')"
    touch "$user_path/logs/mail_suspension.log"
    echo "[$(date +%F) $(date +%H):$(date +%M):$(date +%S)] $2 $3 for $4 by $(whoami)" >> $user_path/logs/mail_suspension.log;
    # chown *:*  $
    #echo $(date +%F) $(date +%H):$(date +%M):$(date +%S)] dan@dstier2.com SUSPENDED for REASON
}

mail_api ()
{
    uapi --user=$1 Email $2 email=$3
    clear
    notification $3 $4 $5 $1 "$6"
}
error_message ()
{
    clear
    echo "================================="
    echo "$1"
    echo "================================="
}
#=========================================================================================
clear
echo --------------------------------------------------
echo Welcome to UAPI Suspend Mail
echo This is still in beta version
echo Talk to Dan.D for further question
echo --------------------------------------------------
echo
echo "Enter the domain"
read domain
if [ -z "$domain" ]
    then
        clear
        echo "!Domain must not be empty"
    else
    find_domain="$(grep $domain /etc/localdomains)"
    if [ -z "$find_domain" ]
    then
        error_message "DOMAIN NOT FOUND ON SERVER"
    else
        clear
        username="$(/scripts/whoowns $domain)"
        echo "Enter what you want to execute"
        options=("Suspend Specific Mail" "Activate Specific Mail" "Suspend all outgoing" "Activate all outgoing" "Quit")
        select opt in "${options[@]}"
        do
            case $opt in
                "Suspend Specific Mail")
                clear
                echo "Enter usermail"
                read usrmail
                validate_mail="$(ls -lah /home*/$username/mail/ | grep $domain/$usrmail)"
                if [ -z "$validate_mail" ]
                    then
                        error_message "$usrmail@$domain not found"
                        break
                    else
                        echo "Enter Reason"
                        read reason
                        if [ -z "$reason" ]
                            then
                                error_message "Must input a reason"
                                break
                            else
                                mail_api "${username}" "suspend_login" "$usrmail@$domain" "SUSPENDED" "$domain" "$reason"
                                break
                            fi
                        fi
                        ;;
                        "Activate Specific Mail")
                        clear
                        echo "Enter usermail"
                        read usrmail
                        validate_mail="$(ls -lah /home*/$username/mail/ | grep $domain/$usrmail)"
                        if [ -z "$validate_mail" ]
                            then
                                error_message "$usrmail@$domain not found"
                                break
                            else
                                mail_api "${username}" "unsuspend_login" "$usrmail@$domain" "ACTIVATED" "$domain" "SUPPORT REQUEST"
                            break
                        fi
                        ;;
                *) echo invalid option;;
            esac
        done
    fi
fi
