#!/bin/sh

set -e 

if [ -z "${DKIM_SHORTDOMAIN}" ]; then
    echo "No DKIM Short domain provided. Exiting ..."
    exit 1
fi

if [ -z "${POSTFIX_DOMAIN}" ]; then
    echo "No Domain provided. Exiting ... "
    exit 1
fi

if [ ! -f "/etc/opendkim/signing.table" ]; then

    cat << EOT > /etc/opendkim.conf
# This is a basic configuration that can easily be adapted to suit a standard
# installation. For more advanced options, see opendkim.conf(5) and/or
# /usr/share/doc/opendkim/examples/opendkim.conf.sample.

# Log to syslog
Syslog          yes
# Required to use local socket with MTAs that access the socket as a non-
# privileged user (e.g. Postfix)
UMask           002
# OpenDKIM user
# Remember to add user postfix to group opendkim
UserID          opendkim

# Map domains in From addresses to keys used to sign messages
KeyTable        /etc/opendkim/key.table
SigningTable    refile:/etc/opendkim/signing.table

# Hosts to ignore when verifying signatures
ExternalIgnoreList  /etc/opendkim/trusted.hosts
InternalHosts       /etc/opendkim/trusted.hosts

# Commonly-used options; the commented-out versions show the defaults.
Canonicalization    relaxed/simple
Mode            sv
SubDomains      no
AutoRestart     yes
AutoRestartRate     10/1M
Background      yes
DNSTimeout      5
SignatureAlgorithm  rsa-sha256

OversignHeaders     From

EOT

    echo "Configuring dkim dir permissions"
    chmod u=rw,go=r /etc/opendkim.conf
    mkdir -p /etc/opendkim/keys


    echo "Creating DKIM signing table"

    cat <<EOT > /etc/opendkim/signing.table
*@${POSTFIX_DOMAIN} ${DKIM_SHORTDOMAIN}
EOT

    echo "Creating Key Table for DKIM"
    cat <<EOT > /etc/opendkim/key.table
${DKIM_SHORTDOMAIN}    ${POSTFIX_DOMAIN}  201701:/etc/opendkim/keys/${DKIM_SHORTDOMAIN}.private
EOT

    echo "Creating DKIM trusted"
    cat <<EOT > /etc/opendkim/trusted.hosts
127.0.0.1
::1
localhost
${MAIL_DOMAIN}
${DKIM_SHORTDOMAIN}
${POSTFIX_DOMAIN}
EOT

    chown -R opendkim:opendkim /etc/opendkim
    chmod go-rw /etc/opendkim/keys

    if [ ! -f "/etc/openkdim/${DKIM_SHORTDOMAIN}.private" ]; then
        echo "Generating OpenDkim Keys"
        opendkim-genkey -b 2048 -h rsa-sha256 -r -s 201701 -d "${POSTFIX_DOMAIN}" -v
        mv 201701.private /etc/opendkim/"${DKIM_SHORTDOMAIN}".private
        mv 201701.txt /etc/opendkim/"${DKIM_SHORTDOMAIN}".txt
        echo "The Txt was created. Now you need to put the following value in your DNS:"
        cat /etc/opendkim/"${DKIM_SHORTDOMAIN}".txt
    fi
fi

exec /usr/sbin/opendkim -f -x /etc/opendkim.conf -u opendkim -P /tmp/opendkim.pid -p inet:5500

