# GitHub Actions 可复用工作流集合

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-2088FF?style=flat&logo=github-actions&logoColor=white)](https://github.com/features/actions)

为 Go 应用、Docker 构建和企业微信通知提供的可复用 GitHub Actions 工作流集合。

## 🚀 快速开始

```yaml
# .github/workflows/ci.yaml
name: CI/CD 流水线

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    uses: qxsugar/actions/.github/workflows/build-app.yaml@main
  
  build-image:
    needs: build
    if: github.event_name == 'push'
    uses: qxsugar/actions/.github/workflows/build-image.yaml@main
    with:
      docker_registry: ghcr.io/username/project
    secrets: inherit
  
  notify:
    needs: [build, build-image]
    if: always()
    uses: qxsugar/actions/.github/workflows/wechat-notify.yaml@main
    with:
      bot_key: ${{ secrets.WECHAT_BOT_KEY }}
```

## 📦 可用工作流

### 🔨 构建 Go 应用

构建、测试和打包 Go 应用程序，包含完整的 CI 功能。

**工作流：** `qxsugar/actions/.github/workflows/build-app.yaml@main`

#### 功能特性
- ✅ 设置 Go 1.22 环境并启用模块缓存
- ✅ 下载依赖包
- ✅ 运行测试（启用竞态检测和覆盖率统计）
- ✅ 上传覆盖率报告到 Codecov
- ✅ 构建优化的 Linux 二进制文件
- ✅ 上传构建产物（保留 30 天）

#### 使用方法
```yaml
jobs:
  build:
    uses: qxsugar/actions/.github/workflows/build-app.yaml@main
```

#### 环境要求
- 包含 `go.mod` 文件的 Go 项目
- 可选：`CODECOV_TOKEN` 密钥用于覆盖率报告

---

### 🐳 构建 Docker 镜像

构建并推送 Docker 镜像，支持高级缓存和智能标签。

**工作流：** `qxsugar/actions/.github/workflows/build-image.yaml@main`

#### 功能特性
- ✅ 检出代码并设置 Docker Buildx
- ✅ 登录到 Docker 注册表
- ✅ 生成智能标签和元数据
- ✅ 使用 GitHub Actions 缓存构建
- ✅ 推送到注册表并应用多个标签

#### 输入参数

| 参数                | 描述                                  | 必填 | 默认值      |
|-------------------|-------------------------------------|----|----------|
| `docker_registry` | Docker 注册表地址（如：`ghcr.io/user/repo`） | ✅  | -        |
| `docker_tag`      | 镜像的额外标签                             | ❌  | `latest` |

#### 使用方法
```yaml
jobs:
  build-image:
    uses: qxsugar/actions/.github/workflows/build-image.yaml@main
    with:
      docker_registry: ghcr.io/username/project
      docker_tag: v1.0.0
    secrets: inherit
```

#### 必需密钥
- `DOCKER_USER`：Docker 注册表用户名
- `DOCKER_PASSWORD`：Docker 注册表密码/令牌

#### 生成的标签
- `branch-sha`（分支推送）
- `pr-123`（拉取请求）
- 输入的自定义标签
- 运行 ID（用于唯一标识）

---

### 📱 企业微信通知

发送丰富的部署通知到企业微信。

**工作流：** `qxsugar/actions/.github/workflows/wechat-notify.yaml@main`

#### 功能特性
- ✅ 发送包含部署详情的成功通知
- ✅ 发送包含错误信息的失败警告
- ✅ 包含提交信息、作者和构建日志
- ✅ 支持自定义消息和环境标识

#### 输入参数

| 参数               | 描述                 | 必填 | 默认值          |
|------------------|--------------------|----|--------------|
| `bot_key`        | 企业微信机器人 Webhook 密钥 | ✅  | -            |
| `custom_message` | 要附加的自定义消息          | ❌  | `''`         |
| `environment`    | 部署环境               | ❌  | `production` |

#### 使用方法
```yaml
jobs:
  notify:
    uses: qxsugar/actions/.github/workflows/wechat-notify.yaml@main
    with:
      bot_key: ${{ secrets.WECHAT_BOT_KEY }}
      environment: staging
      custom_message: "🚀 部署完成"
```

#### 必需密钥
- `WECHAT_BOT_KEY`：企业微信机器人 Webhook 密钥

#### 通知功能
- 📊 部署状态（成功/失败）
- 👤 提交作者和时间戳
- 🔗 构建日志直达链接
- 📝 提交消息预览
- 🏷️ 环境和分支信息

---

## 💡 完整示例

### 基础 Go 项目 CI

```yaml
name: 持续集成

on: [push, pull_request]

jobs:
  test:
    name: 测试 Go 应用
    uses: qxsugar/actions/.github/workflows/build-app.yaml@main
```

### 发布版本的 Docker 构建

```yaml
name: 发布版本

on:
  push:
    tags: ['v*']

jobs:
  build-image:
    name: 构建并推送 Docker 镜像
    uses: qxsugar/actions/.github/workflows/build-image.yaml@main
    with:
      docker_registry: ghcr.io/${{ github.repository }}
      docker_tag: ${{ github.ref_name }}
    secrets: inherit
```

### 完整的 CI/CD 流水线

```yaml
name: 部署流水线

on:
  push:
    branches: [main, develop]

env:
  REGISTRY: ghcr.io/${{ github.repository }}
  ENVIRONMENT: ${{ github.ref_name == 'main' && 'production' || 'staging' }}

jobs:
  build:
    name: 构建应用
    uses: qxsugar/actions/.github/workflows/build-app.yaml@main
    
  build-image:
    name: 构建 Docker 镜像
    needs: build
    uses: qxsugar/actions/.github/workflows/build-image.yaml@main
    with:
      docker_registry: ${{ env.REGISTRY }}
      docker_tag: ${{ env.ENVIRONMENT }}
    secrets: inherit
    
  notify:
    name: 发送通知
    needs: [build, build-image]
    if: always()
    uses: qxsugar/actions/.github/workflows/wechat-notify.yaml@main
    with:
      bot_key: ${{ secrets.WECHAT_BOT_KEY }}
      environment: ${{ env.ENVIRONMENT }}
      custom_message: ${{ env.ENVIRONMENT == 'production' && '🚀 生产环境部署' || '🧪 测试环境部署' }}
```

## ⚙️ 配置说明

### 仓库密钥设置

在仓库设置中配置以下密钥：

```yaml
# Docker 构建必需
DOCKER_USER: 你的Docker用户名
DOCKER_PASSWORD: 你的Docker令牌

# 企业微信通知必需
WECHAT_BOT_KEY: 你的企业微信机器人Webhook密钥

# 覆盖率报告可选
CODECOV_TOKEN: 你的Codecov令牌
```
