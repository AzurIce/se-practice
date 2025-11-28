#import "@preview/cuti:0.4.0": show-cn-fakebold
#import "@preview/lilaq:0.5.0" as lq
#set page(paper: "a4", margin: 16pt)
#set text(font: "LXGW Bright", lang: "zh")

#show: show-cn-fakebold

// 按组号分组仓库的函数
#let group-by-number(repos) = {
  let groups = (:)
  for repo in repos {
    let num = str(repo.group_number)
    if groups.keys().contains(num) {
      groups.insert(num, groups.at(num) + (repo,))
    } else {
      groups.insert(num, (repo,))
    }
  }
  groups
}

// 从 JSON 文件加载仓库信息
// #let repos = json("repos.json")
// str -> [repo]
#let repos = group-by-number(json("repos.json"))

// 生成贡献者提交统计图表
#let contributor-charts(repo) = {
  let data = json("repos/" + str(repo.group_number) + "-HospitalSystem/" + repo.repo_name + ".json")

  // 1. 贡献者提交数量直方图
  let x-positions = ()
  let y-values = ()
  let labels = ()

  for (i, contributor) in data.enumerate() {
    x-positions.push(i + 1)
    y-values.push(contributor.commits.len())
    labels.push(contributor.name)
  }

  if x-positions.len() > 0 {
    figure(
      lq.diagram(
        width: 80%,
        height: 2cm,
        xaxis: (label: "贡献者", ticks: x-positions.zip(labels)),
        yaxis: (label: "提交数量"),
        lq.bar(
          x-positions,
          y-values,
          width: 0.6,
          fill: rgb("#4CAF50"),
        ),
      ),
      caption: [#repo.repo_name - 贡献者提交数量统计],
    )
  }

  // 2. 按周统计的提交趋势柱状图（每个贡献者一条柱）
  let weekly-data = (:)
  let all-weeks = ()

  // 为每个贡献者统计每周的提交
  for contributor in data {
    let contributor-weekly = (:)

    for commit in contributor.commits {
      // 解析日期并计算周数
      let date-parts = commit.date.split("-")
      let year = int(date-parts.at(0))
      let month = int(date-parts.at(1))
      let day = int(date-parts.at(2))

      // 简化：使用 YYYY-WW 格式表示周
      let week-key = /*date-parts.at(0) + "-W" + */ str(calc.floor((month - 1) * 4.33 + day / 7))

      if week-key not in all-weeks {
        all-weeks.push(week-key)
      }

      if week-key in contributor-weekly {
        contributor-weekly.insert(week-key, contributor-weekly.at(week-key) + 1)
      } else {
        contributor-weekly.insert(week-key, 1)
      }
    }

    weekly-data.insert(contributor.name, contributor-weekly)
  }

  // 排序所有周
  all-weeks = all-weeks.sorted()

  if all-weeks.len() > 0 {
    let colors = (rgb("#2196F3"), rgb("#4CAF50"), rgb("#FF9800"), rgb("#E91E63"), rgb("#9C27B0"), rgb("#00BCD4"), rgb("#FFEB3B"), rgb("#795548"))
    let week-labels = ()

    // 只显示部分标签以避免拥挤
    for (i, week) in all-weeks.enumerate() {
      if calc.rem(i, calc.max(1, calc.floor(all-weeks.len() / 10))) == 0 {
        week-labels.push((i + 1, week))
      }
    }

    let bars = ()
    for (idx, contributor) in data.enumerate() {
      let y-counts = ()
      for week in all-weeks {
        if week in weekly-data.at(contributor.name) {
          y-counts.push(weekly-data.at(contributor.name).at(week))
        } else {
          y-counts.push(0)
        }
      }

      bars.push(lq.bar(
        range(1, all-weeks.len() + 1),
        y-counts,
        width: 0.8 / data.len(),
        offset: (idx - data.len() / 2.0 + 0.5) * 0.8 / data.len(),
        fill: colors.at(calc.rem(idx, colors.len())),
        label: contributor.name,
      ))
    }


    figure(
      lq.diagram(
        width: 80%,
        height: 2cm,
        xaxis: (label: "周", ticks: week-labels),
        yaxis: (label: "提交数量"),
        legend: (position: (100% + 1em, 0%)),
        ..bars,
      ),
      caption: [#repo.repo_name - 每周提交趋势（按贡献者）],
    )
  }
}

// 生成表格行
#let generate-table-rows(repos) = {
  let rows = ([*组号*], [*仓库地址*], [*分支*])

  // 按组号顺序处理
  for num in repos.keys() {
    if repos.keys().contains(num) {
      let group-repos = repos.at(num)
      let count = group-repos.len()
      let first = true
      for repo in group-repos {
        if first {
          rows += (
            table.cell(rowspan: count)[#num],
            [#repo.git_url],
            [#repo.git_branch],
          )
          first = false
        } else {
          rows += (
            [#repo.git_url],
            [#repo.git_branch],
          )
        }
      }
    }
  }
  rows
}

= 仓库信息

#table(
  columns: (auto, 1fr, auto),
  align: (center + horizon, left, center),
  ..generate-table-rows(repos),
)

== 详细信息

#let git-graph-svg(repo) = {
  figure(
    rotate(-90deg, reflow: true, image(
      "repos/" + str(repo.group_number) + "-HospitalSystem/" + repo.repo_name + ".svg",
    )),
    numbering: none,
    caption: [#repo.repo_name - Git 提交图],
  )
}

#let group-git-graphs(group_num) = {
  let num = str(group_num)
  for repo in repos.at(num) {
    box(width: 100%, stroke: 1pt + rgb("#a6a6a6"), inset: 10pt, radius: 4pt)[
      #git-graph-svg(repo)
      // pagebreak(weak: true)
      #contributor-charts(repo)
    ]
  }
  pagebreak(weak: true)
}

#pagebreak(weak: true)

=== 第1组

*后端*：Spring Boot 3.5.6 + Java 17 + MyBatis Plus

*前端*：Vue 3 + TypeScript + Vite + Arco Design

*小程序*：微信小程序

#group-git-graphs(1)

=== 第2组

*后端*：Spring Boot 3.4.5 + Java + JEECG Boot

*前端*：Vue 3 + TypeScript + Ant Design Vue

#group-git-graphs(2)

=== 第3组

*后端*：Spring Boot 3.5.6 + Java 17 + MyBatis

*前端*：Vue 3 + TypeScript + Vite + Element Plus（管理端：hgy-administer-frontend，医生端：HRS_DoctorUI）

*小程序*：uni-app（患者端：HRS_hospital_patient_frontend）

#group-git-graphs(3)

=== 第4组

*后端*：Spring Boot 2.7.15 + Java

*前端*：Vue 3 + Element Plus

#group-git-graphs(4)

=== 第5组

*后端*：Python + FastAPI + SQLAlchemy

*前端*：Vue 3 + TypeScript + Vite + Tailwind CSS（管理端：hospital-admin-frontend）

*小程序*：uni-app（医生端：doctor-fronted，患者端：hospital-patient-frontend）

#group-git-graphs(5)

=== 第6组

*后端*：Spring Boot 3.5.7 + Java 17

*前端*：Vue 3 + TypeScript + Element Plus

#group-git-graphs(6)

=== 第7组

*后端*：Spring Boot 3.2.0 + Java 21

*前端*：Vue 3 + Element Plus

*小程序*：uni-app

#group-git-graphs(7)

=== 第8组

*后端*：Node.js + Express + MySQL

#group-git-graphs(8)

=== 第9组

*后端*：Spring Boot 3.5.5 + Java 21

*前端*：Vue 3 + Element Plus

#group-git-graphs(9)

=== 第10组

*后端*：Spring Boot 2.7.15 + Java

*前端*：Vue 3 + Element Plus

#group-git-graphs(10)

=== 第11组

*后端*：Node.js + Express + MySQL

*小程序*：微信小程序

#group-git-graphs(11)

=== 第12组

*后端*：Python + Django

*前端*：Vue 3 + Element Plus

#group-git-graphs(12)

=== 第13组

*后端*：Spring Boot 3.5.6 + Java 17

*前端*：Vue 3 + TypeScript + Vite + Element Plus

*小程序*：uni-app（hospital-phoneApp）

#group-git-graphs(13)
