#!/usr/bin/env python3
"""
提取每个仓库的贡献者 commit 数据
"""
import json
import subprocess
from pathlib import Path
from datetime import datetime
from collections import defaultdict

def get_commits(repo_path: Path, branch: str) -> list:
    """获取仓库的所有 commit 信息"""
    try:
        # 切换到指定分支
        subprocess.run(
            ["git", "checkout", branch],
            cwd=repo_path,
            capture_output=True,
            check=True
        )
        
        # 获取 commit 信息：作者名、日期、commit 标题
        result = subprocess.run(
            [
                "git", "log",
                "--all",
                "--format=%an|%ai|%s"
            ],
            cwd=repo_path,
            capture_output=True,
            text=True,
            check=True
        )
        
        commits = []
        for line in result.stdout.strip().split('\n'):
            if line:
                parts = line.split('|', 2)
                if len(parts) == 3:
                    author, date_str, title = parts
                    # 解析日期并格式化为 YYYY-MM-DD
                    date = datetime.fromisoformat(date_str.replace(' +', '+').replace(' -', '-'))
                    commits.append({
                        "author": author.strip(),
                        "date": date.strftime("%Y-%m-%d"),
                        "title": title.strip()
                    })
        
        return commits
    except subprocess.CalledProcessError as e:
        print(f"Error processing {repo_path}: {e}")
        return []

def group_commits_by_author(commits: list) -> list:
    """按作者分组 commit"""
    author_commits = defaultdict(list)
    
    for commit in commits:
        author_commits[commit["author"]].append({
            "date": commit["date"],
            "title": commit["title"]
        })
    
    # 转换为列表格式，并按日期排序
    result = []
    for author, commits_list in author_commits.items():
        sorted_commits = sorted(commits_list, key=lambda x: x["date"])
        result.append({
            "name": author,
            "commits": sorted_commits
        })
    
    # 按 commit 数量降序排序
    result.sort(key=lambda x: len(x["commits"]), reverse=True)
    
    return result

def main():
    # 读取仓库配置
    repos_json_path = Path("/Volumes/Files/se-practice/repos.json")
    with open(repos_json_path, 'r', encoding='utf-8') as f:
        repos = json.load(f)
    
    base_path = Path("/Volumes/Files/se-practice/repos")
    
    for repo_info in repos:
        group_num = repo_info["group_number"]
        repo_name = repo_info["repo_name"]
        branch = repo_info["git_branch"]
        
        # 构建仓库路径
        repo_path = base_path / f"{group_num}-HospitalSystem" / repo_name
        
        if not repo_path.exists():
            print(f"⚠️  仓库不存在: {repo_path}")
            continue
        
        print(f"📊 处理仓库: {repo_name} (组 {group_num}, 分支 {branch})")
        
        # 获取 commits
        commits = get_commits(repo_path, branch)
        
        if not commits:
            print(f"   ⚠️  未找到 commits")
            continue
        
        # 按作者分组
        contributors = group_commits_by_author(commits)
        
        # 保存到 JSON 文件
        output_path = repo_path.parent / f"{repo_name}.json"
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(contributors, f, ensure_ascii=False, indent=2)
        
        print(f"   ✅ 已保存 {len(contributors)} 位贡献者的数据到 {output_path}")
        print(f"   📈 总计 {len(commits)} 个 commits")

if __name__ == "__main__":
    main()
