#!/usr/bin/env bash

product="docspace"
GIT_BRANCH="develop"
DOCKER="true"

source /app/${product}/check_parameters.sh
PARAMETERS="$PARAMETERS -skiphc true";

install_curl () {
    command_exists () {
        type "$1" &> /dev/null;
    }

    if command_exists apt-get; then
        apt-get -y update
        apt-get -y -q install curl
    elif command_exists yum; then
        yum -y install curl
    fi

    if ! command_exists curl; then
        echo "command curl not found"
        exit 1;
    fi
}

healthcheck() {
    URI=( $(curl https://raw.githubusercontent.com/ONLYOFFICE/${product}/${GIT_BRANCH}/web/ASC.Web.HealthChecks.UI/appsettings.json | grep -oP 'localhost.*' | grep -o '^[^"]*') )
    NAME=( $(curl https://raw.githubusercontent.com/ONLYOFFICE/${product}/${GIT_BRANCH}/web/ASC.Web.HealthChecks.UI/appsettings.json | grep -oP 'ASC.*' | grep -o '^[^",]*') )

    for i in "${!URI[@]}"; do
        echo -n "${NAME[i]} - " && [ "$(curl -s ${URI[i]} | json status)" = "Healthy" ] && echo -e "\033[37;1;42mHealthy\033[0m" || echo -e "\033[37;1;41mUnhealthy\033[0m"
    done
}

install_product () {
    DOWNLOAD_URL_PREFIX="https://raw.githubusercontent.com/ONLYOFFICE/${product}/${GIT_BRANCH}/build/install/OneClickInstall"
    if [ "$DOCKER" == "true" ]; then 
            curl -s -O  ${DOWNLOAD_URL_PREFIX}/install-Docker.sh
            bash install-Docker.sh ${PARAMETERS}
            error_check
            rm install-Docker.sh
    else
        if [ -f /etc/redhat-release ] ; then
            curl -s -O ${DOWNLOAD_URL_PREFIX}/install-RedHat.sh
            bash install-RedHat.sh ${PARAMETERS}
            error_check
            rm install-RedHat.sh
        elif [ -f /etc/debian_version ] ; then
            curl -s -O ${DOWNLOAD_URL_PREFIX}/install-Debian.sh
            bash install-Debian.sh ${PARAMETERS}
            error_check
            rm install-Debian.sh
        fi
        if [[ -n $MYSQL_PARAMETERS ]]; then
            bash /usr/bin/${product}-configuration.sh ${MYSQL_PARAMETERS}
            error_check
        fi
        healthcheck
    fi
}

complete_installation() {
    echo -e "\e[0;32m The script is finished \e[0m"
}

error_installation () {
    echo -e "\e[0;31m The script was executed with an error\e[0m"
}

error_check (){
    if [[ $? -ne 0 ]]; then
        error_installation
        exit
    fi
}

main() {
    install_curl
    install_product
    complete_installation
}

main 
