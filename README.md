# Xray VLESS + REALITY 服务端

基于 Docker 的 Xray VLESS + REALITY 代理服务端，支持自动部署。

## 特性

- **协议**: VLESS + XTLS Vision
- **传输**: TCP + REALITY
- **自动生成**: `private_key`（通过 `xray x25519`）和 `client_id`（通过 `xray uuid`），每次容器首次启动时重新生成
- **热启动**: 若 `config.json` 已存在则跳过生成，直接启动 xray
- **路由规则**: 默认屏蔽中国大陆 IP、BT 协议，放行 byr.pt

## 快速开始

### 构建镜像

```bash
docker build -t xray-reality .
```

### 运行容器

```bash
docker run -d \
  --name xray \
  -p 443:443 \
  -e DEST="www.adobe.com:443" \
  -e SHORT_ID="501cdef45181abcd" \
  xray-reality
```

### 查看日志

```bash
docker logs xray
```

容器启动时会输出生成的 `client_id` 和 `private_key`，用于配置客户端。

## 环境变量

| 变量 | 必填 | 说明 |
|------|------|------|
| `DEST` | ✅ | REALITY 目标地址，格式 `host:port`，如 `www.adobe.com:443` |
| `SHORT_ID` | ✅ | REALITY short ID，用于客户端与服务端握手验证 |

以下变量由容器自动生成，无需手动配置：

| 变量          | 生成方式      |
|---------------|---------------|
| `PRIVATE_KEY` | `xray x25519` |
| `CLIENT_ID`   | `xray uuid`   |

## 项目结构

```
.
├── Dockerfile              # 镜像构建文件
├── entrypoint.sh           # 容器启动脚本
├── config.template.json    # Xray 配置模板
└── .gitignore
```

## 客户端配置

在客户端中配置以下信息（从容器启动日志中获取）：

- **地址**: 你的服务器 IP/域名
- **端口**: 443
- **协议**: vless
- **UUID**: 日志中的 `client_id`
- **Flow**: `xtls-rprx-vision`
- **传输**: tcp
- **安全**: reality
- **SNI**: `DEST` 中的 host 部分（如 `www.adobe.com`）
- **Public Key**: `xray x25519` 输出中 `PrivateKey` 对应的 `PublicKey`
- **Short ID**: 运行时传入的 `SHORT_ID`

## 📢 注意

本项目仅供学习和研究使用，不用于任何商业或非法目的。

- 使用者应自行承担使用本项目带来的一切风险和法律责任
- 本项目作者不对因使用本项目造成的任何直接或间接损失负责
- 使用本项目即表示您已阅读并同意本免责声明
