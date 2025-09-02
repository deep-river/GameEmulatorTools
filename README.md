# Emu-Scripts

游戏模拟器辅助配置工具集合，用于在不同平台（Windows / Android 等）下辅助配置和维护游戏模拟器环境。  
本仓库会根据部署平台进行分类，例如 `windows/`、`android/` 目录。

---

## 已收录工具与脚本

### 1. generate_psx_cues.py （PS1_Tools）

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

### 2. Batch CIA 3DS Decryptor （3DS_Tools）

- **适用平台**  
  - Windows

- **目标模拟器**  
  - Azahar Emulator  
  - Citra Emulator  

- **解决的问题**  
  - 一些 `.3ds` / `.cia` 游戏镜像为加密格式，模拟器无法直接加载。  
  - 需要解密并转换为 `.cci` 格式（NCSD 容器），Azahar/Citra 才能正常识别。  

- **功能**  
  - 批量解密 `.3ds` / `.cia` 文件。  
  - `.3ds` → 直接生成同名 `.cci` 文件。  
  - `.cia` → 自动判断类型（游戏 / Patch / DLC）：  
    - 游戏 CIA → 转换为 `.cci`  
    - Patch / DLC CIA → 输出可在 Citra 安装的解密 CIA  
  - 保留原始文件，输出文件以 `.cci` 扩展名区分。  
  - 生成 `log.txt` 记录详细过程，生成 `changelog.txt` 记录新创建的文件。

- **使用方法**  
  1. 将 `Batch CIA 3DS Decryptor.bat`、`ctrtool.exe`、`decrypt.exe`、`makerom.exe` 放在同一目录。  
  2. 将待处理的 `.3ds` / `.cia` 游戏文件放入该目录。  
  3. 双击运行 `Batch CIA 3DS Decryptor.bat`，等待处理完成。  
  4. 转换结果可在同目录找到，过程与结果记录在 `log.txt` 和 `changelog.txt` 中。  

- **致谢**  
  - 脚本基于 gbatemp 论坛用户 [matif](https://gbatemp.net/threads/batch-cia-3ds-decryptor-a-simple-batch-file-to-decrypt-cia-3ds.512385/) 的原始工作进行改进。  

---
