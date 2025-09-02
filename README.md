# Emu-Scripts

游戏模拟器辅助配置工具集合，用于在不同平台（Windows / Android 等）下辅助配置和维护游戏模拟器环境。  
本仓库会根据部署平台进行分类，例如 `windows/`、`android/` 目录。

---

## 已收录脚本

### 1. generate_psx_cues.py

- **适用平台**  
  - Windows / Android / Linux （任何可运行 Python 3 的环境）

- **目标模拟器**  
  - DuckStation  
  - RetroArch（Beetle PSX / SwanStation 内核）

- **解决的问题**  
  - PS1 模拟器通常需要 `.cue` 文件来正确识别 `.bin` 光盘镜像。  
  - 一些 ROM 目录只有 `.bin` 文件而缺少 `.cue`，导致模拟器无法加载或缺失音轨。  

- **功能**  
  - 自动遍历当前目录下的**一级游戏子目录**。  
  - 为没有 `.cue` 的 `.bin` 镜像生成最简 `.cue` 文件（单轨模式）。  
  - 跳过以下情况：  
    - 已存在 `.cue` 的目录  
    - 文件名包含 `bios` 的 `.bin`  
    - 文件小于 50MB 的 `.bin`（避免误处理 BIOS / 碎片文件）  
  - 在脚本所在目录生成 `changelog.txt`，记录生成的 `.cue` 文件列表和日期。

- **使用方法**  
  1. 将 `generate_psx_cues.py` 放在 PS1 ROM 的根目录（各游戏子目录所在的那一层）。  
  2. 运行：  
     ```bash
     python generate_psx_cues.py
     ```  
  3. 执行后，缺失 `.cue` 的 `.bin` 将被自动补齐，生成的文件会记录到 `changelog.txt`。  

---

## 后续计划

- 添加更多平台的实用脚本（如自动批量转换 `.bin/.cue` → `.chd`）。  
- 针对 Windows / Android 模拟器环境，提供一键部署和整理工具。  
