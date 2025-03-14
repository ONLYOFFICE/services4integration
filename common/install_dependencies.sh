#####################################################
# Install the necessary dependencies on the host
# Arguments:
#   None
#####################################################
install_dependencies() {
  apt-get update && apt-get install -y apt-transport-https curl wget ca-certificates software-properties-common gnupg2 ntp net-tools unzip
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  apt update
  apt install -y docker-ce docker-ce-cli
  systemctl start docker
  curl -L "https://github.com/docker/compose/releases/download/v2.0.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
}
