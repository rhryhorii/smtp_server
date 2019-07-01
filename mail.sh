#!/bin/bash

set -e

domain=`echo $user | cut -d'@' -f 2`

[[ -z $user ]]   && echo "missing user env var" && exit -1
[[ -z $pass ]]   && echo "missing pass env var" && exit -2
[[ -z $domain ]] && echo "could not extract domain from user, prolly missing the '@'." && exit -3

echo "User:   $user"
echo "Domain: $domain"

echo $domain > /etc/mailname

# configure Postfix

echo -e "
biff = no
append_dot_mydomain = no
recipient_delimiter = +
inet_interfaces = all
relayhost = [smtp.gmail.com]:587

#smtpd_client_restrictions = permit_sasl_authenticated,reject
smtpd_sasl_auth_enable=yes
#smtpd_sender_restrictions= permit_sasl_authenticated,reject
broken_sasl_auth_clients=yes
" > /etc/postfix/main.cf

postconf -e "myhostname=$myhostname"
postconf -e "mydestination=$mydestination"
postconf -e "mynetworks=$networks"
postconf -e "alias_database=hash:/etc/aliases"
postconf -e "alias_maps=hash:/etc/aliases"


echo "[smtp.gmail.com]:587 $user:$pass" \
>> /etc/postfix/saslpass

postmap /etc/postfix/saslpass

adduser alpha --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
echo "alpha:alpha" | sudo chpasswd

adduser beta --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
echo "beta:beta" | sudo chpasswd

adduser gamma --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
echo "gamma:gamma" | sudo chpasswd

adduser delta --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
echo "delta:delta" | sudo chpasswd

adduser omega --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
echo "omega:omega" | sudo chpasswd


echo "$ARG"
#USER=`echo "$ARG" | cut -d":" -f1`
USER=manu
echo "    >> adding user: $USER"
useradd -s /bin/bash $USER
echo "manu:manu" | chpasswd
if [ ! -d /var/spool/mail/$USER ]
then
  mkdir /var/spool/mail/$USER
fi
chown -R $USER:mail /var/spool/mail/$USER
chmod -R a=rwx /var/spool/mail/$USER
chmod -R o=- /var/spool/mail/$USER

service rsyslog start
service saslauthd start
service postfix start
#
#
#service rsyslog start > /dev/null
#service postfix start > /dev/null
sleep 5
tail -f /var/log/mail.log

#sleep infinity
