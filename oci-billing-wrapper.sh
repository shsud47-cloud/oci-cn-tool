#!/bin/bash
conf="/root/.oci-cn/daily-billing.conf"
[ -f "$conf" ] || exit 0
set_time=$(head -1 "$conf" 2>/dev/null | tr -d ' \n\r')
[ -z "$set_time" ] && exit 0
enabled=$(sed -n '2p' "$conf" 2>/dev/null | tr -d ' \n\r')
[ "$enabled" = "0" ] && exit 0
tzf="/root/.oci-cn/timezone"; tz="Asia/Shanghai"
if [ -f "$tzf" ]; then tz=$(head -1 "$tzf" 2>/dev/null); tz="${tz//[[:space:]]/}"; fi
[ -f "/usr/share/zoneinfo/$tz" ] || tz="Asia/Shanghai"
now_bj=$(TZ="$tz" date +%H:%M)
[ "$now_bj" = "$set_time" ] || exit 0
# 只有非免密码模式才传密码
if [ ! -f "/root/.oci-cn/.nopass" ] && [ -f "/root/.oci-cn/.cron_pass" ]; then
  export OCI_CN_PASS=$(cat /root/.oci-cn/.cron_pass | tr -d '\n\r')
fi
timeout 300 /usr/local/bin/oci-cn --daily-billing-tick >> /var/log/oci-billing.log 2>&1
