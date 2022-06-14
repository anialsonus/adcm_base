#!/usr/bin/env sh
set -eu

cd /


apk add --update --no-cache --virtual .pynacl_deps build-base python3-dev libffi-dev openssl-dev linux-headers libxslt-dev rust cargo
# LDAP
apk add --update --no-cache openldap-dev
apk add --update --no-cache libffi openssl libxslt libstdc++ bash
apk add --update --no-cache nginx sshpass runit openssh-keygen openssh-client git dcron logrotate curl rsync
apk upgrade --no-cache

ln -s /usr/lib/libldap.so /usr/lib/libldap_r.so

/build_venv.sh
rm -f /build_venv.sh

apk del git
apk del .pynacl_deps
rm /etc/nginx/http.d/default.conf
