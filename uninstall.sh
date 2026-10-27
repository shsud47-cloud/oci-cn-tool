#!/usr/bin/env bash
# oci-cn 通用卸载脚本 / Universal uninstaller for oci-cn
# 用法 Usage: bash -c "$(curl -fsSL https://raw.githubusercontent.com/shsud47-cloud/oci-cn-tool/master/uninstall.sh)"
# 参数 Args: -y 跳过所有确认，程序+配置+oci-cli 全卸 / skip all prompts, remove everything
set +e

ASSUME_YES=0
{ [ "$1" = "-y" ] || [ "$1" = "--yes" ]; } && ASSUME_YES=1

rmf(){ if [ -e "$1" ] || [ -L "$1" ]; then rm -rf "$1" 2>/dev/null && echo "  removed: $1"; fi; }
ask(){ # $1=question; returns 0=yes
  [ "$ASSUME_YES" = 1 ] && return 0
  if [ -r /dev/tty ]; then printf '%s' "$1"; read -r _a < /dev/tty || return 1; else return 0; fi
  case "$_a" in y|Y|yes|YES) return 0;; *) return 1;; esac
}

echo "=== oci-cn 卸载 / uninstall ==="
[ "$(id -u)" -ne 0 ] && { echo "请用 sudo 运行 / Please run with sudo"; exit 1; }

# 候选路径：标准位置 + PATH 查找 + 常见临时/家目录拷贝（不碰带日期的备份文件）
CANDS="/usr/local/bin/oci-cn /usr/bin/oci-cn /opt/oci-cn"
_p="$(command -v oci-cn 2>/dev/null)"; [ -n "$_p" ] && CANDS="$CANDS $_p"
for _d in /tmp/ /var/tmp/ "$HOME/" /root/ /home/*/; do
  for _n in oci-cn oci-cn.new oci-cn.sh; do [ -f "$_d$_n" ] && CANDS="$CANDS $_d$_n"; done
done
CANDS="$(echo $CANDS | tr ' ' '\n' | sort -u)"

_found=0
for _f in $CANDS; do [ -f "$_f" ] && { echo "found: $_f"; _found=1; }; done
[ "$_found" = 0 ] && echo "未在常见位置找到 oci-cn 本体 / oci-cn program not found in common locations"

if ask "卸载 oci-cn 本体？/ Uninstall oci-cn program? [y/N]: "; then
  for _f in $CANDS; do _dir="$(dirname "$_f")"; rmf "$_f"; rmf "$_dir/lang"; done
else
  echo "已取消 / cancelled"; exit 0
fi

if ask "删除配置目录（含账号与加密密钥，不可恢复）？/ Delete config dirs (accounts & keys, unrecoverable)? [y/N]: "; then
  rmf /root/.oci-cn
  rmf "$HOME/.oci-cn"
  for _h in /home/*; do [ -d "$_h" ] && rmf "$_h/.oci-cn"; done
fi

if ask "同时卸载 oci-cli？/ Also uninstall oci-cli? [y/N]: "; then
  rmf /usr/local/bin/oci
  for _h in /root /home/*; do
    [ -d "$_h" ] || continue
    rmf "$_h/bin/oci"; rmf "$_h/lib/oracle-cli"; rmf "$_h/.oci"
  done
fi

hash -r 2>/dev/null
echo "=== 完成 / done ==="
exit 0
