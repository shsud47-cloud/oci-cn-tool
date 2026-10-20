#!/usr/bin/env bash
# oci-cn 一键安装脚本
# 用法: bash -c "$(curl -fsSL https://raw.githubusercontent.com/shsud47-cloud/oci-cn-tool/master/install.sh)"
set -e

REPO="shsud47-cloud/oci-cn-tool"
INSTALL_PATH="/usr/local/bin/oci-cn"
GITHUB_RAW="https://raw.githubusercontent.com/$REPO/master"

echo "=== oci-cn 一键安装 ==="
echo ""

# 1. 检查系统
if [ "$(id -u)" -ne 0 ]; then
  echo "请用 sudo 运行: sudo bash install.sh"
  exit 1
fi

# 2. 安装依赖
echo "[1/4] 检查依赖..."
for cmd in jq openssl curl; do
  if ! command -v $cmd >/dev/null 2>&1; then
    echo "  安装 $cmd..."
    if command -v apt >/dev/null 2>&1; then apt update -qq && apt install -y -qq $cmd
    elif command -v yum >/dev/null 2>&1; then yum install -y -q $cmd
    else echo "  无法自动安装 $cmd，请手动安装"; exit 1
    fi
  else
    echo "  $cmd 已安装"
  fi
done

# 3. 安装 oci-cli
echo "[2/4] 检查 oci-cli..."
if ! command -v oci >/dev/null 2>&1; then
  echo "  正在安装 oci-cli（约需 2-5 分钟）..."
  bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)" -- --accept-all-defaults
  ln -sf ~/bin/oci /usr/local/bin/oci 2>/dev/null || true
  echo "  oci-cli 安装完成"
else
  echo "  oci-cli 已安装: $(oci --version 2>/dev/null | head -1)"
fi

# 4. 下载 oci-cn
echo "[3/4] 下载 oci-cn..."
curl -fsSL "$GITHUB_RAW/oci-cn" -o "$INSTALL_PATH"
chmod 755 "$INSTALL_PATH"
echo "  已安装到 $INSTALL_PATH"
echo "  版本: $(grep -m1 'VERSION=' "$INSTALL_PATH" | cut -d'"' -f2)"

# 5. 语言选择
echo "[4/4] 语言设置..."
echo "  1) 中文"
echo "  2) English"
read -rp "选择语言 [1]: " lang_choice
lang_choice="${lang_choice:-1}"
mkdir -p /root/.oci-cn
if [ "$lang_choice" = "2" ]; then
  SCRIPT_DIR="$(dirname "$INSTALL_PATH")"
  mkdir -p "$SCRIPT_DIR/lang"
  curl -fsSL "$GITHUB_RAW/lang/en.sh" -o "$SCRIPT_DIR/lang/en.sh"
  echo "en" > /root/.oci-cn/lang
  echo "  Language set to English (language pack downloaded)"
else
  echo "zh" > /root/.oci-cn/lang
  echo "  语言设为中文"
fi

echo ""
echo "=== 安装完成 ==="
echo "运行: sudo oci-cn"
echo ""
echo "首次使用: 系统配置 → 1 添加账号，按提示粘贴 OCI API 配置和私钥"
