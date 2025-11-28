#!/usr/bin/env python3
"""
根据 repos.json 读取每个仓库的所有 commit，整理出每个贡献者的 commit 数据
保存到对应组文件夹下的 <repo_name>.json 中
每个 json 是一个列表，每个元素是 {time, author, title}
"""
import subprocess
import os
import json
from pathlib import Path

def load_repos_from_json(json_path):
    """从 repos.json 文件加载仓库信息"""
    with open(json_path, 'r', encoding='utf-8') as f:
        repos = json.load(f)
    return repos

def get_repo_path(group_number, repo_name):
    """根据组号和仓库名构建本地路径"""
    return f"repos/{group_number}-HospitalSystem/{repo_name}"

def extract_commits(repo_path, base_dir):
    """从指定仓库提取所有 commit 信息"""
    full_path = os.path.join(base_dir, repo_path)
    if not os.path.exists(full_path):
        print(f"  跳过：路径不存在 {full_path}")
        return None
    
    # 检查是否是 git 仓库
    git_dir = os.path.join(full_path, ".git")
    if not os.path.exists(git_dir):
        print(f"  跳过：不是 git 仓库 {full_path}")
        return None
    
    try:
        # 使用 git log 获取所有 commit 信息
        # 使用不可见字符作为分隔符，避免与 commit message 中的字符冲突
        # %x1E: 记录分隔符 (Record Separator)
        # %x1F: 单元分隔符 (Unit Separator)
        # %ai: 作者日期，ISO 8601 格式
        # %an: 作者名称
        # %s: commit 标题（第一行）
        cmd = [
            "git", "log",
            "--format=%ai%x1F%an%x1F%s%x1E",
            "--all"
        ]
        result = subprocess.run(
            cmd,
            cwd=full_path,
            capture_output=True,
            text=True,
            timeout=300  # 5分钟超时
        )
        
        if result.returncode != 0:
            print(f"  ✗ git log 执行失败")
            if result.stderr:
                print(f"    错误信息: {result.stderr[:200]}")
            return None
        
        commits = []
        # 使用记录分隔符分割每个 commit
        for record in result.stdout.split('\x1E'):
            if not record.strip():
                continue
            
            # 使用单元分隔符分割字段
            parts = record.split('\x1F')
            if len(parts) >= 3:
                time_str = parts[0].strip()
                author = parts[1].strip()
                # 标题是剩余所有部分（处理标题中包含单元分隔符的情况）
                title = '\x1F'.join(parts[2:]).strip()
                
                commits.append({
                    "time": time_str,
                    "author": author,
                    "title": title
                })
            else:
                print(f"  ⚠ 警告：commit 格式异常，跳过: {record[:100]}")
                continue
        
        return commits
    
    except subprocess.TimeoutExpired:
        print(f"  ✗ 超时")
        return None
    except Exception as e:
        print(f"  ✗ 异常: {e}")
        return None

def save_commits_to_json(commits, output_path):
    """将 commit 列表保存到 JSON 文件"""
    try:
        # 确保输出目录存在
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(commits, f, ensure_ascii=False, indent=2)
        return True
    except Exception as e:
        print(f"  ✗ 保存文件失败: {e}")
        return False

def main():
    base_dir = "/Volumes/Files/se-practice"
    os.chdir(base_dir)
    
    # 从 repos.json 加载仓库信息
    json_path = os.path.join(base_dir, "repos.json")
    if not os.path.exists(json_path):
        print(f"错误：找不到 repos.json 文件: {json_path}")
        return
    
    repos = load_repos_from_json(json_path)
    
    total_repos = 0
    success_count = 0
    fail_count = 0
    
    print("开始提取 commit 信息...\n")
    
    # 按组号分组处理
    repos_by_group = {}
    for repo in repos:
        group_id = repo["group_number"]
        if group_id not in repos_by_group:
            repos_by_group[group_id] = []
        repos_by_group[group_id].append(repo)
    
    # 为每个组的每个仓库提取 commit 信息
    for group_id in sorted(repos_by_group.keys()):
        print(f"第 {group_id} 组:")
        for repo in repos_by_group[group_id]:
            total_repos += 1
            repo_name = repo["repo_name"]
            repo_path = get_repo_path(group_id, repo_name)
            print(f"  处理仓库: {repo_name}")
            
            commits = extract_commits(repo_path, base_dir)
            
            if commits is not None:
                # 构建输出路径：repos/<group_number>-HospitalSystem/<repo_name>.json
                output_path = os.path.join(base_dir, repo_path + ".json")
                if save_commits_to_json(commits, output_path):
                    print(f"  ✓ 成功提取 {len(commits)} 个 commit，保存到 {output_path}")
                    success_count += 1
                else:
                    fail_count += 1
            else:
                fail_count += 1
        print()
    
    print("=" * 50)
    print(f"总计: {total_repos} 个仓库")
    print(f"成功: {success_count} 个")
    print(f"失败: {fail_count} 个")
    print("=" * 50)

if __name__ == "__main__":
    main()

