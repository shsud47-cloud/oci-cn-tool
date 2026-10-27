# oci-cn

甲骨文云（Oracle Cloud）中文管理工具，中英双语界面。基于官方 `oci-cli` 的单文件 Bash 脚本，代码完全透明可审计。

Oracle Cloud Infrastructure management tool with Chinese/English bilingual UI. Single-file Bash script based on official `oci-cli` — fully transparent and auditable.

[完整中文教程](README_zh.md) | [Full Tutorial (Chinese)](README_zh.md)

## 功能 Features

- **实例管理 Instance**: 创建、开机/关机/重启、改配置（Flex）、改名、删除、换 IP、挂 IPv6
- **实时机型 Real-time shapes**: 每个可用域从 OCI API 实时读取可用机型
- **免费额度感知 Free-tier aware**: 超出免费额度（4核/24G内存/200G存储）前警告
- **存储 Storage**: 引导卷+块存储卷，扩容、挂载/卸载、删除未挂载盘
- **网络 Network**: VCN/子网管理、安全列表规则、开放/关闭端口
- **账单 Billing**: 成本分析、预算告警、配额查询、流量统计、定时每日账单推送（默认 Asia/Shanghai 12:00；租户和时区可选）
- **Cloudflare**: 换 IP 后自动更新 DNS（A/AAAA 可配）
- **推送 Notifications**: 钉钉推送所有操作
- **双语 Bilingual**: 中文 / English（系统配置 → 7 语言）
- **安全 Secure**: 单文件 Bash 脚本，代码完全可审计；API 密钥默认加密存储（可切换为明文），运行时解密到内存、退出即焚；连续 5 次输错密码会删除整个 `~/.oci-cn` 配置目录及账号数据；不开放任何端口，无 Web 面板攻击面

---
## 截图 Screenshots

### 钉钉推送 DingTalk Notifications


所有操作自动推送到钉钉：实例创建/删除/开关机、换 IP、存储变更；账单支持按日明细查询（自动识别币种）；存储统计含免费额度预警（200G），未挂载卷单独列出提醒释放。

All operations push to DingTalk automatically: instance create/delete/start/stop, IP change, storage changes; billing with daily breakdown (auto currency); storage stats with free-tier alerts (200G) and unattached volume warnings.

### 账号功能页 Account Dashboard


租户详情、实例管理、引导卷、虚拟云网络、流量统计、配额查询、成本分析——一个账号的所有功能一页直达。

### 创建实例：全自定义 Create Instance


可用域、机型从 API 实时读取；OCPU/内存手动输入（无误导性默认值）；系统镜像按发布时间倒序任选（Ubuntu/Oracle Linux/Debian）；VCN网段、子网网段、名称前缀均可自定义。

### 主菜单 Main Menu


### 系统配置 System Config


## 小白友好 Beginner Friendly

- **全中文菜单**：不用啃英文文档，不用记 `oci` 命令参数
- **一步一提示**：创建实例全程引导——选可用域→选机型→输配置→选系统→确认，每步都有说明
- **防呆设计**：关键操作二次确认；任何输入界面按 `0` 随时取消；免费额度超限提前警告
- **实时选项**：可用域、机型、镜像全部从 API 实时读取列出，照着编号选就行，不用查文档
- **开箱即用**：一条命令安装，`sudo oci-cn` 直接进菜单

- **Chinese UI**: no English docs, no memorizing `oci` CLI flags
- **Guided flows**: instance creation walks you through every step with explanations
- **Foolproof**: confirmations on destructive actions; press `0` to cancel anywhere; free-tier warnings before overage
- **Live options**: availability domains, shapes, images all fetched live — just pick a number
- **Zero config**: one-line install, `sudo oci-cn` and you're in

---
## 为什么不用 Web 面板 Why No Web Panel

| | oci-cn（终端） | Web API 管理面板 |
| 开放端口 | **0 个** | 至少 1 个（HTTP/HTTPS） |
| 攻击面 | 无网络监听，扫不到 | 端口扫描、爆破、0day 直接目标 |
| 密钥存储 | 磁盘加密，内存解密，退出即焚 | 常驻服务端，多一份泄露风险 |
| 代码审计 | 单文件 Bash，逐行可读 | 前后端分离，黑盒依赖多 |
| 部署依赖 | 一个脚本 + oci-cli | Web 服务 + 数据库 + 反代 |
| 适用场景 | 管理员本地/跳板机操作 | 多人协作、远程访问 |

Web 面板为了"方便"常驻监听端口——你的云 API 密钥就躺在那台 24 小时暴露在公网的机器上。oci-cn 反其道而行：**用完即走，不留痕迹**。没有端口，就没有入口；没有常驻，就没有偷窃窗口。

| | oci-cn (Terminal) | Web API Panel |
| Open ports | **Zero** | At least 1 (HTTP/HTTPS) |
| Attack surface | No listener, unscannable | Port scans, brute force, 0days |
| Key storage | Encrypted at rest, memory-only at runtime, wiped on exit | Lives on server 24/7 |
| Auditability | Single Bash file, line-by-line readable | Frontend + backend + deps, opaque |
| Dependencies | One script + oci-cli | Web server + DB + reverse proxy |

## 一键安装 Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/shsud47-cloud/oci-cn-tool/master/install.sh | sudo bash
sudo oci-cn
```

## 手动安装 Manual Install

```bash
# 1. 安装依赖 Install dependencies
sudo apt install -y jq openssl curl

# 2. 安装 oci-cli
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"

# 3. 下载 oci-cn
sudo curl -fsSL https://raw.githubusercontent.com/shsud47-cloud/oci-cn-tool/master/oci-cn -o /usr/local/bin/oci-cn
sudo mkdir -p /usr/local/bin/lang
sudo curl -fsSL https://raw.githubusercontent.com/shsud47-cloud/oci-cn-tool/master/lang/en.sh -o /usr/local/bin/lang/en.sh
sudo chmod 755 /usr/local/bin/oci-cn

# 4. 运行 Run
sudo oci-cn
```

## 卸载 Uninstall

三种方式任选 / Three options:

1. 主菜单选 `3 卸载`，可选择连配置目录和 oci-cli 一起卸。
   Main menu option `3 Uninstall` — optionally removes the config directory and oci-cli too.

2. 一键卸载脚本（通用版：自动查找常见安装位置，包括 /tmp 下的拷贝；带日期的备份文件不会误删）：
   Universal uninstall script (auto-finds common install locations, incl. copies under /tmp; dated backup files are kept):

```bash
curl -fsSL https://raw.githubusercontent.com/shsud47-cloud/oci-cn-tool/master/uninstall.sh | sudo bash
```

全自动（程序+配置+oci-cli 全卸，不询问）/ Fully automatic (program + config + oci-cli, no prompts):

```bash
curl -fsSL https://raw.githubusercontent.com/shsud47-cloud/oci-cn-tool/master/uninstall.sh | sudo bash -s -- -y
```

## 日常使用 Daily Usage

每次使用只需一条命令（需 sudo，因为配置文件和 API 密钥存放在 `/root/.oci-cn`）：

```bash
sudo oci-cn
```

脚本会自动解锁密钥库（输入解密密码），退出时内存中的密钥即焚毁。

Each time, just run (sudo required — config and API keys live in `/root/.oci-cn`):

```bash
sudo oci-cn
```

The script unlocks the keystore with your decryption password; keys are wiped from memory on exit.

## 首次使用 First Use

1. 系统配置 → 1 添加账号 (System Config → Add Account)
2. 粘贴 OCI API 配置 `[DEFAULT]` 段，另起一行输入 `END`
3. 粘贴 API 私钥（含 BEGIN/END），另起一行输入 `END`
4. 设置解密密码（加密所有 API 私钥）

## 备份 Backup

```bash
sudo tar czf ~/oci-cn-full-$(date +%Y%m%d-%H%M).tar.gz -C /root .oci-cn -C /usr/local/bin oci-cn
```

备份包 + 解密密码，两个都有才能恢复。

## 需求 Requirements

- Linux（推荐 Ubuntu/Debian）
- `oci-cli`、`jq`、`openssl`、`curl`
- OCI API 密钥

## License

MIT
