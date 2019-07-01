
FROM ubuntu:14.04

RUN apt-get update
RUN apt-get install -y vim
RUN apt-get install -y telnet
RUN apt-get install -y mailutils
RUN echo "postfix postfix/mailname string gmail.com" | debconf-set-selections
RUN echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
RUN apt-get install -y postfix


# pre config
RUN echo mail > /etc/hostname; \
    echo "postfix postfix/main_mailer_type string Internet site" > preseed.txt; \
    echo "postfix postfix/mailname string mail.example.com" >> preseed.txt

# load pre config for apt
RUN debconf-set-selections preseed.txt

# lang
RUN apt-get update

# install
RUN apt-get install -y \
#    opendkim \
#    mailutils \
#    opendkim-tools \
#    sasl2-bin \
#    telnet \
    rsyslog

RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y postfix sasl2-bin vim

# Config Sasl2
RUN sed -i 's/^START=.*/START=yes/g' /etc/default/saslauthd; \
    sed -i 's/^MECHANISMS=.*/MECHANISMS="shadow"/g' /etc/default/saslauthd

RUN echo "pwcheck_method: saslauthd" > /etc/postfix/sasl/smtpd.conf; \
    echo "mech_list: PLAIN LOGIN" >> /etc/postfix/sasl/smtpd.conf; \
    echo "saslauthd_path: /var/run/saslauthd/mux" >> /etc/postfix/sasl/smtpd.conf

# add user postfix to sasl group
RUN adduser postfix sasl

# chroot saslauthd fix
RUN sed -i 's/^OPTIONS=/#OPTIONS=/g' /etc/default/saslauthd; \
    echo 'OPTIONS="-c -m /var/spool/postfix/var/run/saslauthd"' >> /etc/default/saslauthd

ADD mail.sh /mail.sh
RUN chmod +x /mail.sh

EXPOSE 25
EXPOSE 465
EXPOSE 587

ENTRYPOINT ["/mail.sh"]