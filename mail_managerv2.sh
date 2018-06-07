#! /bin/bash
#Mail Manager
#Author: Dan.D

#-------------[ Funcations ]--------------------
err_msg ()
{
    clear
    echo 
    echo $1
    echo
}

usr_mail_api ()
{
    # $1 - username | $2 - function $3 - email account | $4 - notification
    #
    #
    uapi --user=$1 Email $2 email=$3
    clear
    write_logs $1 $2 $3 $5
    break
}

write_logs ()

{
    usr_uid="$(id -u $1)"
  	usr_gud="$(id -g $1)"
    user_path="$(grep $1 /etc/passwd | awk '{gsub("'$1':x:'$usr_uid':'$usr_gud'::",""); print}' | awk '{gsub(":/usr/local/cpanel/bin/jailshell",""); print}')"
  	touch "$user_path/logs/mail_suspension.log"
  	if [ "$2" == "suspend_login" ]
    then
        echo [$(date +%F) $(date +%H):$(date +%M):$(date +%S)] $3 "SUSPENDED" for "$4" "BY" "$(whoami)" >> $user_path/logs/mail_suspension.log;
        clear 
        err_msg "$3 is already SUSPENDED"
    else
        echo [$(date +%F) $(date +%H):$(date +%M):$(date +%S)] $3 "ACTIVATED" "by" "$(whoami)" >> $user_path/logs/mail_suspension.log;
        err_msg "$3 is already ACTIVATED"
    fi
}

#-------------[ Static Variable ]---------------
valid=^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$
#-----------------------------------------------
clear
echo "Enter Email:"
read email 


if [[ "$email" =~ $valid ]]
then
    clear
    domain="${email#*@}"
    uname="${email%@*}"
    username="$(/scripts/whoowns $domain)"
    find_domain="$(grep $domain /etc/localdomains)"
    if [ -z "$find_domain" ]
    then
        err_msg "Domain not found on server"
    else
        validate_mail="$(ls -lah /home*/$username/mail/ | grep $domain/$uname)"
        if [ -z "$validate_mail" ]
        then
            echo "$uname@$domain not found"
        else
            err_msg "Please input a reason"
            read reason
            if [ -z "$reason" ]
            then
                err_msg "Reason must not be empty"
            else
                clear
                echo "Enter what you want to execute"
                options=("Suspend Specific Mail" "Activate Specific Mail" "Quit")
                select opt in "${options[@]}"
                do
                    case $opt in
                        "Suspend Specific Mail")
                            usr_mail_api $username "suspend_login" $email "$email already suspended" "$reason"
                        ;;
                        "Activate Specific Mail")
                            usr_mail_api $username "unsuspend_login" $email "$email already activated" "$reason"
                        ;;
                        "Quit")
                            clear
                            break
                        ;;
                        *) echo invalid option;;
                    esac
                done
            fi
        fi
    fi
else
    err_msg "Invalid email"
fi
