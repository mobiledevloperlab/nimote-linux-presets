# NimoteCode Linux Presets

面向 **NimoteCode Local Linux Environment** 的、可版本化且可通过校验和验证的开发环境 preset。

[NimoteCode 官网](https://nimotecode.com/zh/) · [主项目](https://github.com/mobiledevloperlab/nimotecode) · [Android 本地 Linux 文档](https://nimotecode.com/zh/docs/local-linux) · [Presets 文档](https://nimotecode.com/zh/docs/local-linux/presets)

这是独立的技术仓库，负责 preset 的 manifest、安装器、验证器、schema、测试和发布打包。它不包含 NimoteCode 应用源码、Android 二进制、PRoot 二进制、Ubuntu rootfs 或专有代码。

## 用途

NimoteCode Local Linux 在支持的 Android 设备上提供基于 PRoot 的 Ubuntu 用户空间。本仓库为该环境定义可审查的可选工具集。NimoteCode 获取已声明的 manifest、验证脚本哈希、展示动作并获得确认后，才会通过本地 SSH 在 Local Linux 内执行选定 preset 的安装和验证。

Preset 不会取得 Android root 权限，不管理应用的安装状态，不替换 Local Linux runtime，也不会自动卸载共享的 APT 依赖。

## 支持环境

| 组件 | 声明的支持范围 |
| --- | --- |
| 发行版 | Ubuntu 24.04 |
| 架构 | `arm64`、`amd64` |
| Android 要求 | 通过 Local Linux runtime 支持 API 26 / Android 8 或更高版本 |
| PRoot runtime | `5.1.107.92` |
| Shell / 包管理 | Ubuntu rootfs 内的 Bash 与 APT |
| 本地连接 | NimoteCode 所有的回环 SSH |

根 [`manifest.json`](manifest.json) 是 runtime source URL、PRoot SHA-256、rootfs 输入元数据、最低应用版本与各 preset 哈希的权威来源。PRoot 是进程级 root 模拟而非虚拟机；依赖 ptrace、特殊挂载、特权网络或精确 `/proc` 行为的工具需要在目标 runtime 中测试。

## 可用 preset

| ID | 用途 | 依赖 | 状态 |
| --- | --- | --- | --- |
| [`minimal`](presets/minimal/manifest.json) | 基础命令行开发工具 | 无 | Experimental |
| [`python`](presets/python/manifest.json) | Python 3、pip 与 venv 工作流 | `minimal` | Experimental |
| [`web`](presets/web/manifest.json) | 来自 Ubuntu 软件包的 Node.js 与 npm | `minimal` | Experimental |
| [`cpp`](presets/cpp/manifest.json) | GCC、CMake、GDB 与原生构建工具 | `minimal` | Experimental |

此状态是刻意保守的：container 检查只能证明常规 Ubuntu 软件包行为，不能证明 PRoot 兼容性。只有受保护发布流程保存 ARM64 与 AMD64 的新鲜 Android PRoot 通过报告，并将 manifest 状态改为 `stable` 后，preset 才能成为稳定版。

## Manifest 与 SHA-256 校验

每个发布文件都受 [`checksums.sha256`](checksums.sha256) 覆盖。根 manifest 固定每个 preset manifest 的哈希，每个 preset manifest 又固定 `install.sh` 与 `verify.sh` 的哈希。使用某个修订前执行：

```bash
scripts/validate-manifests.sh
```

该验证会检查 JSON Schema、根 manifest 与 preset 的哈希声明、脚本哈希及完整校验和文件。运行安装器前，请阅读对应 manifest 的架构、Ubuntu 版本、依赖、网络要求和状态。

## 安装与测试模型

安装器在用户的 Local Linux Ubuntu 环境中运行，并在执行时从已配置、已签名的 APT 仓库请求软件包；它们不会下载或内置 rootfs。PRoot 会在 rootfs **内部**通常显示 UID 0，这不是 Android root；脚本不会调用 `sudo`。

静态检查覆盖严格 shell 模式、Bash 语法、ShellCheck、manifest schema、校验和与 shell policy；Ubuntu container CI 会在干净的 Ubuntu 24.04 容器中安装并验证每个 preset。Android PRoot 是单独的验证层。

本地运行完整静态测试需要 Bash、ShellCheck、Python 3 与 `jsonschema`：

```bash
scripts/test-all.sh
```

若有匹配的 PRoot runtime，设置 `NIMOTE_PROOT_BIN` 与 `NIMOTE_PROOT_ROOTFS` 后运行 `scripts/test-proot.sh PRESET`。详见[测试说明](docs/testing.md)与[运行时兼容性](docs/runtime-compatibility.md)。不要只为阅读 README 下载大型 rootfs；`scripts/fetch-runtime-bundle.sh --extract` 只接受显式提供且已固定 SHA-256 的维护者 runtime URL。

## 发布与下载

带 tag 的发布由受保护的 GitHub Actions 工作流产生。它要求 Ubuntu 检查通过、ARM64 与 AMD64 的 Android PRoot 新鲜报告通过、所有发布 preset 均为 `stable`，并使用不可变的 `vMAJOR.MINOR.PATCH` tag。工作流会在 GitHub Release 附加带版本的 preset bundle 及 SHA-256 sidecar。

本仓库不通过 R2 发布 release asset，也不会就地替换已发布 tag。精确门槛见[发布流程](docs/release-process.md)。

## 文档、许可证与贡献

- [架构](docs/architecture.md) · [preset 规范](docs/preset-spec.md) · [运行时兼容性](docs/runtime-compatibility.md) · [测试](docs/testing.md) · [NimoteCode 集成](docs/nimotecode-integration.md)
- 仓库拥有的文档、JSON 元数据和 shell/Python 片段采用 [MIT](LICENSE)；分发边界见 [NOTICE](NOTICE)。
- 本仓库不再分发 Ubuntu 包、PRoot、Android 可执行文件或 rootfs。manifest 标识的 PRoot 源为 [Termux PRoot source archive](https://github.com/termux/proot/archive/v5.1.107.92.zip)，其项目采用 GPL；这里并未 vendor PRoot 源码或二进制。
- NimoteCode 内置 Local Linux 环境的对应源码和许可证声明单独发布在[本地 Linux 对应源码与许可证](https://nimotecode.com/zh/docs/local-linux-source)。

提交修改前请阅读[贡献指南](CONTRIBUTING.md)、[行为准则](CODE_OF_CONDUCT.md)、[支持说明](SUPPORT.md)与[安全策略](SECURITY.md)。请保留 manifest/校验和约定，不要加入 rootfs 或压缩 runtime 资产，并确保 runtime 结论有文档化测试证据。
