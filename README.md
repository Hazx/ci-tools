# CI-Tools

CI-Tools 又名 CI-Base，是一个用于 Gitlab CI/CD 阶段的工具镜像，包含常用的工具及特定的环境。如果你有需要可以拿去参考使用。

对应镜像及版本：`hazx/citools:0.4`

## 镜像所包含的组件及环境

- Ubuntu: 20.04.6 LTS
- Docker cli: 20.10.23
- Kaniko: v1.9.1
- Kubectl: 1.21.14
- Node.js: v18.16.1
- JDK: 1.8.0_352
- Maven: 3.9.3

## 默认工作目录

```
/ci_workdir
```

# 使用镜像

你可以直接下载使用我打包好的镜像 `hazx/citools:0.4`，你也可以按照自己的使用环境修改并自行打包镜像。
 

# 打包新镜像

*需要注意，编译和打包阶段需要 Docker 环境，且依赖互联网来安装运行环境。*

执行命令开始打包：

```shell
bash start_make.sh
```

镜像构建完成后，将保存至当前目录下。