  
if [ "$1" == "" ]; then
    echo -e "\e[0;33m Warning: Basic parameters are missing. The default values will be used \e[0m"
fi

while [ "$1" != "" ]; do
    case $1 in
        
        -gb | --gitbranch )
            if [ "$2" != "" ]; then
                PARAMETERS="$PARAMETERS ${1} ${2}";
                GIT_BRANCH=$2
                shift
            fi
        ;;

        -d | --docker )
            if [ "$2" != "" ]; then
                DOCKER=$2
                shift
            fi
        ;;

        -un | --username )
            if [ "$2" != "" ]; then
                PARAMETERS="$PARAMETERS ${1} ${2}";
                shift
            fi
        ;;

        -p | --password )
            if [ "$2" != "" ]; then
                PARAMETERS="$PARAMETERS ${1} ${2}";
                shift
            fi
        ;;

        -s | --status )
            if [ "$2" != "" ]; then
                PARAMETERS="$PARAMETERS ${1} ${2}";
                shift
            fi
        ;;
        
        -tag | --dockertag )
            if [ "$2" != "" ]; then
                PARAMETERS="$PARAMETERS ${1} ${2}";
                shift
            fi
        ;;

        -ep | --externalport )
            if [ "$2" != "" ]; then
                PARAMETERS="$PARAMETERS ${1} ${2}";
                shift
            fi
        ;;
        
        -di | --documentserverimage )
            if [ "$2" != "" ]; then
                PARAMETERS="$PARAMETERS ${1} ${2}";
                shift
            fi
        ;;

        -mysqld | --mysqldatabase )
            if [ "$2" != "" ]; then
                [ "$DOCKER" = "true" ] && PARAMETERS="$PARAMETERS ${1} ${2}" || MYSQL_PARAMETERS="$MYSQL_PARAMETERS ${1} ${2}"
                shift
            fi
        ;;

        -mysqlu | --mysqluser )
            if [ "$2" != "" ]; then
                [ "$DOCKER" = "true" ] && PARAMETERS="$PARAMETERS ${1} ${2}" || MYSQL_PARAMETERS="$MYSQL_PARAMETERS ${1} ${2}"
                shift
            fi
        ;;

        -mysqlp | --mysqlpassword )
            if [ "$2" != "" ]; then
                [ "$DOCKER" = "true" ] && PARAMETERS="$PARAMETERS ${1} ${2}" || MYSQL_PARAMETERS="$MYSQL_PARAMETERS ${1} ${2}"
                shift
            fi
        ;;

        -mysqlh | --mysqlhost )
            if [ "$2" != "" ]; then
                [ "$DOCKER" = "true" ] && PARAMETERS="$PARAMETERS ${1} ${2}" || MYSQL_PARAMETERS="$MYSQL_PARAMETERS ${1} ${2}"
                shift
            fi
        ;;
        
    esac
    shift
done
