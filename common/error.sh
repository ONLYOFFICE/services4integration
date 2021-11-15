# The argument is output to STDERR specifying the timestamp 
# Globals:
#   None
# Arguments:
#   $@
# Returns:
#   message to STDERR
err() {
  echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}
