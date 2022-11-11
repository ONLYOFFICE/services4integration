#############################################################################################
# Configuration jwt secret in documentserver
# Globals:
#   JWT_SECRET, JWT_ENV
# Arguments:
#   None
# Outputs:
#   None
#############################################################################################
jwt_configuration() {
  if [ "${JWT_ENABLED}" == 'false' ]; then
    JWT_ENV='JWT_ENABLED=false';
  else
    JWT_ENV='JWT_SECRET='$JWT_SECRET
  fi
}
