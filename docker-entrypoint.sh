#!/bin/sh
set -e

if [ "$(id -u)" = '0' -a -n "${AS_USER}" ]; then
    USER=${USER:=user}
    uid=${AS_USER%%:*}
    gid=${AS_USER#*:}
    gid=${gid:-0}

    if [ -d /home/${USER} ]; then
        chown ${uid}:${gid} /home/${USER}
        WITHOUT_HOME=set
    fi

    if command -v groupadd >/dev/null 2>&1; then
        WITHOUT_HOME=${WITHOUT_HOME:--m}
        groupadd -f -g ${gid} ${USER} >/dev/null 2>&1 || true
        useradd ${WITHOUT_HOME#set} -g ${gid} -u ${uid} ${USER} >/dev/null 2>&1 || true
    else
        # Alpine
        addgroup -g ${gid} ${USER} >/dev/null 2>&1 || true
        adduser ${WITHOUT_HOME:+-H} -D -u ${uid} -G $(grep ":${gid}:$" /etc/group | cut -d: -f1) ${USER} >/dev/null 2>&1 || true
    fi

    exec su-exec ${uid}:${gid} "$@"
fi

exec "$@"
