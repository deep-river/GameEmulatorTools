# -*- coding: utf-8 -*-
"""
generate_psx_cues.py

在当前目录下遍历所有**一级子文件夹**（视为每个游戏的文件夹）。
为其中满足条件的 .bin 游戏文件自动生成最简 .cue：
    FILE "<binname>" BINARY
      TRACK 01 MODE2/2352
        INDEX 01 00:00:00

安全规则：
- 若文件名包含 "bios"（不区分大小写），跳过。
- 若 .bin 文件大小 < 50MB，跳过。
- 若目录内已经存在任意 .cue，跳过该目录（认为已有正确的 cue）。
- 仅当目标 .bin 没有同名 .cue 时，才生成。
- 不识别/处理多轨场景（若有多轨但无 .cue，此脚本不会自动拼多轨 .cue）。

会在脚本所在目录创建/追加 changelog.txt，记录日期与生成的文件列表。
"""

import os
import sys
from datetime import datetime

MIN_BIN_SIZE_BYTES = 50 * 1024 * 1024  # 50MB


def has_any_cue(files):
    return any(f.lower().endswith('.cue') for f in files)


def looks_like_bios(filename):
    return 'bios' in filename.lower()


def should_skip_bin(bin_path):
    """根据启发式判断是否跳过该 .bin"""
    name = os.path.basename(bin_path)
    if looks_like_bios(name):
        return True
    try:
        size = os.path.getsize(bin_path)
    except OSError:
        return True
    if size < MIN_BIN_SIZE_BYTES:
        return True
    return False


def cue_path_for_bin(bin_path):
    base, _ = os.path.splitext(bin_path)
    return base + '.cue'


def make_simple_cue_content(bin_filename):
    # 使用与目录中实际文件名严格一致的大小写/中文名
    lines = [
        f'FILE "{bin_filename}" BINARY',
        '  TRACK 01 MODE2/2352',
        '    INDEX 01 00:00:00',
        ''
    ]
    return '\n'.join(lines)


def write_changelog(root, created_paths):
    log_path = os.path.join(root, 'changelog.txt')
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    with open(log_path, 'a', encoding='utf-8') as fp:
        fp.write(f'[{timestamp}] 生成 .cue 文件 {len(created_paths)} 个：\n')
        if created_paths:
            for p in created_paths:
                rel = os.path.relpath(p, root)
                fp.write(f'  - {rel}\n')
        else:
            fp.write('  （无变更）\n')
        fp.write('\n')
    return log_path


def main():
    root = os.getcwd()
    created = []

    # 遍历一级子目录
    for entry in os.listdir(root):
        entry_path = os.path.join(root, entry)
        if not os.path.isdir(entry_path):
            continue

        try:
            files = os.listdir(entry_path)
        except OSError:
            continue

        # 若目录下已有任意 .cue，跳过整个目录
        if has_any_cue(files):
            continue

        # 遍历 .bin
        for fname in files:
            if not fname.lower().endswith('.bin'):
                continue
            bin_path = os.path.join(entry_path, fname)

            # 启发式跳过 BIOS/过小文件
            if should_skip_bin(bin_path):
                continue

            # 若已有同名 .cue，则跳过
            out_cue = cue_path_for_bin(bin_path)
            if os.path.exists(out_cue):
                continue

            # 生成最简 .cue
            content = make_simple_cue_content(fname)
            try:
                with open(out_cue, 'w', encoding='utf-8', newline='\n') as fp:
                    fp.write(content)
                created.append(out_cue)
            except OSError as e:
                print(f'写入失败: {out_cue} -> {e}', file=sys.stderr)

    log_path = write_changelog(root, created)

    print(f'完成。新增 .cue 文件：{len(created)} 个。')
    if created:
        print('示例：')
        for p in created[:5]:
            print('  ', os.path.relpath(p, root))
        if len(created) > 5:
            print('  ...')
    print(f'变更已记录至: {os.path.relpath(log_path, root)}')


if __name__ == "__main__":
    main()
