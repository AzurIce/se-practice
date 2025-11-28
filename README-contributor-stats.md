# 贡献者统计分析

## 概述

这个项目包含用于提取和可视化 Git 仓库贡献者统计数据的脚本。

## 文件说明

### 1. `extract-contributor-commits.py`

提取每个仓库的贡献者 commit 数据。

**功能：**
- 读取 `repos.json` 中的仓库配置
- 遍历每个仓库，提取所有 commit 信息
- 按贡献者分组统计
- 生成 JSON 文件保存到对应组文件夹

**输出格式：**
```json
[
  {
    "name": "贡献者名称",
    "commits": [
      {
        "date": "2025-10-20",
        "title": "commit 标题"
      }
    ]
  }
]
```

**使用方法：**
```bash
python3 extract-contributor-commits.py
```

### 2. `main.typ`

Typst 文档，用于生成包含贡献者统计图表的 PDF 报告。

**功能：**
- 显示所有仓库的基本信息表格
- 为每个仓库生成：
  - Git 提交图（SVG）
  - 贡献者提交数量直方图
  - 每周提交趋势柱状图

**使用方法：**
```bash
typst compile main.typ
```

## 图表说明

### 贡献者提交数量统计
- 横轴：贡献者名称
- 纵轴：提交数量
- 按提交数量降序排列

### 每周提交趋势
- 横轴：周（YYYY-WW 格式）
- 纵轴：提交数量
- 显示项目开发活跃度随时间的变化

## 依赖

- Python 3
- Git
- Typst
- Typst 包：
  - `@preview/cuti:0.4.0`
  - `@preview/lilaq:0.5.0`

## 数据结构

所有数据存储在 `/Volumes/Files/se-practice/repos/` 目录下：

```
repos/
├── 1-HospitalSystem/
│   ├── hcmu-hospital-frontend/
│   ├── hcmu-hospital-frontend.json  # 贡献者数据
│   └── hcmu-hospital-frontend.svg   # Git 图
├── 2-HospitalSystem/
│   └── ...
└── ...
```

## 注意事项

1. 确保所有仓库已克隆到正确的位置
2. 脚本会自动切换到指定分支
3. 周标签会自动精简以避免图表拥挤
4. 贡献者按提交数量降序排列
