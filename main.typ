#set page(paper: "a4")
#set text(font: "Songti SC", lang: "zh")
#set heading(numbering: "1.")

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
    caption: [#repo.repo_name]
  )
}
#let group-git-graphs(group_num) = {
  let num = str(group_num)
  for repo in repos.at(num) {
    git-graph-svg(repo)
  }
}

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