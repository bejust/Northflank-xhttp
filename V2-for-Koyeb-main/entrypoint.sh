#!/usr/bin/env bash

# 设置默认 UUID 和 xhttp 伪装路径（在 Koyeb 环境变量里设置同名变量可覆盖）
UUID=${UUID:-'de04add9-5c68-8bab-950c-08cd5320df18'}
XHTTP_PATH=${XHTTP_PATH:-'/xhttp'}

# 替换 Nginx 配置文件里的伪装路径
sed -i "s#XHTTP_PATH#${XHTTP_PATH}#g" /etc/nginx/nginx.conf

# 动态生成 Xray 的 xhttp 服务端配置（监听本地 10000 端口）
cat <<EOF > /etc/xray_config.json
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 10000,
      "listen": "127.0.0.1",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${UUID}",
            "level": 0
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "xhttp",
        "xhttpSettings": {
          "path": "${XHTTP_PATH}",
          "mode": "auto"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
EOF

# 如果设置了哪吒探针环境变量则自动安装
TLS=${NEZHA_TLS:+'--tls'}
[ -n "${NEZHA_SERVER}" ] && [ -n "${NEZHA_PORT}" ] && [ -n "${NEZHA_KEY}" ] && wget https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh -O nezha.sh && chmod +x nezha.sh && echo '0' | ./nezha.sh install_agent ${NEZHA_SERVER} ${NEZHA_PORT} ${NEZHA_KEY} ${TLS}

# 启动 Nginx
nginx

# 启动 Xray
/usr/bin/xray run -c /etc/xray_config.json