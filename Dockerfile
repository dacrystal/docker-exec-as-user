ARG TARGET=alpain

FROM alpine as alpain-base
RUN apk add --no-cache su-exec

FROM phusion/holy-build-box-64 as linux64
ENV CFLAGS="${CFLAGS} -Wall -Werror  -Os -flto"
ENV LFLAGS="${LFLAGS} -Wl,-O2 -Wl,--discard-all -Wl,--strip-all -Wl,--as-needed -Wl,--gc-sections"
RUN curl -O https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c
RUN /hbb_exe/activate-exec gcc ${CFLAGS} su-exec.c -o /bin/su-exec ${LFLAGS}

FROM ${TARGET}
copy --from=alpain-base /sbin/su-exec /bin/su-exec.alpain
copy --from=linux64 /bin/su-exec /bin/su-exec.linux64
RUN test -f "/etc/alpine-release" && ln -s /bin/su-exec.alpain /bin/su-exec || true
RUN [ ! -f "/etc/alpine-release" ] && ln -s /bin/su-exec.linux64 /bin/su-exec || true
ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
