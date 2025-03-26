gen_password() {
SYMBOLS=""
for symbol in {A..Z} {a..z} {0..9}; do SYMBOLS=$SYMBOLS$symbol; done
SYMBOLS=$SYMBOLS'*-+_=<>.,'
: ${PWD_LENGTH:=16}  # password length
PASSWORD=""    # variable to store password
RANDOM=256     # initializing the random number generator
for i in `seq 1 $PWD_LENGTH`
do
PASSWORD=$PASSWORD${SYMBOLS:$(expr $RANDOM % ${#SYMBOLS}):1}
done
echo 'Login: '$login'
Password: '$PASSWORD'
' > /var/lib/connector_pwd
}
