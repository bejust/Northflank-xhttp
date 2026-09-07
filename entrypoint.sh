#!/usr/bin/env bash

# 设置默认 UUID 和 xhttp 伪装路径
UUID=${UUID:-'de04add9-5c68-8bab-950c-08cd5320df18'}
XHTTP_PATH=${XHTTP_PATH:-'/xhttp'}

# 替换 Nginx 配置文件里的伪装路径
sed -i "s#XHTTP_PATH#${XHTTP_PATH}#g" /etc/nginx/nginx.conf

# 动态生成 Xray 的 xhttp 服务端配置
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

# 创建并写入环保主题伪装网页
mkdir -p /usr/share/nginx/html
cat <<'EOF' > /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>EcoEarth - For a Greener Tomorrow</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; color: #2d3748; background: #f7fafc; line-height: 1.6; }
    header { background: #2f855a; color: #fff; padding: 5rem 1.5rem; text-align: center; }
    header h1 { font-size: 2.8rem; margin-bottom: 1rem; }
    header p { font-size: 1.25rem; max-width: 600px; margin: 0 auto; opacity: 0.9; }
    .container { max-width: 960px; margin: 3rem auto; padding: 0 1.5rem; }
    .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 1.5rem; }
    .card { background: #fff; padding: 2rem; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
    .card h3 { color: #276749; margin-bottom: 0.75rem; font-size: 1.3rem; }
    footer { text-align: center; padding: 2.5rem; background: #edf2f7; color: #718096; font-size: 0.9rem; margin-top: 4rem; }
  </style>
</head>
<body>
  <header>
    <h1>EcoEarth Initiative</h1>
    <p>Empowering communities worldwide to restore natural ecosystems and combat climate change.</p>
  </header>
  <div class="container">
    <div class="grid">
      <div class="card">
        <h3>Reforestation</h3>
        <p>Planting native trees to rebuild natural habitats, prevent soil erosion, and capture atmospheric carbon.</p>
      </div>
      <div class="card">
        <h3>Ocean Cleanups</h3>
        <p>Removing plastic pollutants from coastlines and promoting sustainable, biodegradable alternatives.</p>
      </div>
      <div class="card">
        <h3>Clean Energy</h3>
        <p>Advocating for the rapid adoption of wind, solar, and decentralized renewable power systems.</p>
      </div>
    </div>
  </div>
  <footer>
    <p>&copy; 2026 EcoEarth Initiative. All rights reserved. Building a sustainable future.</p>
  </footer>
</body>
</html>
EOF

# 如果设置了哪吒探针环境变量则自动安装
TLS=${NEZHA_TLS:+'--tls'}
[ -n "${NEZHA_SERVER}" ] && [ -n "${NEZHA_PORT}" ] && [ -n "${NEZHA_KEY}" ] && wget https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh -O nezha.sh && chmod +x nezha.sh && echo '0' | ./nezha.sh install_agent ${NEZHA_SERVER} ${NEZHA_PORT} ${NEZHA_KEY} ${TLS}

# 启动 Nginx 和 Xray
nginx
/usr/bin/xray run -c /etc/xray_config.json
