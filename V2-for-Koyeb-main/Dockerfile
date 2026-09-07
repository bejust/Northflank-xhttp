FROM alpine:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apk update && apk add --no-cache \
    curl \
    wget \
    bash \
    unzip \
    nginx

# 下载并安装支持 xhttp 的最新版 Xray
RUN wget -qO- https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip | busybox unzip - -d /usr/bin/ xray \
    && chmod +x /usr/bin/xray

COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]