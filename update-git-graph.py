#!/usr/bin/env python3
"""
使用 git-graph 为每个仓库生成 git graph 可视化 SVG 文件
将 SVG 文件保存在对应小组文件夹的仓库外，文件名为 <仓库名>.svg
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

def get_repo_name(repo_path):
    """从路径中提取仓库名称"""
    return os.path.basename(repo_path)

def generate_git_graph_svg(repo_path, base_dir):
    """为指定仓库生成 git graph SVG 文件"""
    full_path = os.path.join(base_dir, repo_path)
    if not os.path.exists(full_path):
        print(f"  跳过：路径不存在 {full_path}")
        return False
    
    # 检查是否是 git 仓库
    git_dir = os.path.join(full_path, ".git")
    if not os.path.exists(git_dir):
        print(f"  跳过：不是 git 仓库 {full_path}")
        return False
    
    # 获取仓库名称和输出路径
    repo_name = get_repo_name(repo_path)
    # 输出文件应该在仓库外的对应小组文件夹中
    parent_dir = os.path.dirname(full_path)
    output_file = os.path.join(parent_dir, f"{repo_name}.svg")
    
    try:
        # 使用 nix develop 来运行 git-graph --svg
        # 将输出捕获并写入文件
        cmd = [
            "nix", "develop", base_dir, "--command", "bash", "-c",
            f"cd {full_path} && git-graph --svg"
        ]
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=60
        )
        
        if result.returncode == 0:
            # 将 SVG 内容写入文件
            if result.stdout and result.stdout.strip():
                with open(output_file, 'w', encoding='utf-8') as f:
                    f.write(result.stdout)
                print(f"  ✓ 成功生成 {output_file}")
                return True
            else:
                print(f"  ✗ 输出为空 {output_file}")
                if result.stderr:
                    print(f"    错误信息: {result.stderr}")
                return False
        else:
            print(f"  ✗ 生成失败 {output_file}")
            if result.stderr:
                print(f"    错误信息: {result.stderr}")
            if result.stdout:
                print(f"    输出: {result.stdout[:200]}...")  # 只显示前200个字符
            return False
    except subprocess.TimeoutExpired:
        print(f"  ✗ 超时 {output_file}")
        return False
    except Exception as e:
        print(f"  ✗ 异常 {output_file}: {e}")
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
    
    print("开始生成 git graph SVG 文件...\n")
    
    # 按组号分组处理
    repos_by_group = {}
    for repo in repos:
        group_id = repo["group_number"]
        if group_id not in repos_by_group:
            repos_by_group[group_id] = []
        repos_by_group[group_id].append(repo)
    
    # 为每个组的每个仓库生成 git graph SVG
    for group_id in sorted(repos_by_group.keys()):
        print(f"第 {group_id} 组:")
        for repo in repos_by_group[group_id]:
            total_repos += 1
            repo_name = repo["repo_name"]
            repo_path = get_repo_path(group_id, repo_name)
            print(f"  处理仓库: {repo_name}")
            
            if generate_git_graph_svg(repo_path, base_dir):
                success_count += 1
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

