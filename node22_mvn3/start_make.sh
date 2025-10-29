#!/bin/bash

base_img="ubuntu:jammy-20251001"
kanico_img="gcr.io/kaniko-project/executor:v1.9.1"
dest_img="citools"   # 不能是路径，不能带 /
dest_tag="node22_mvn3_v1"

if [[ $(id -u) -ne 0 ]];then
    echo "必须在root账户下运行，请尝试使用 sudo -i 切换账户。" 
    exit 1
fi

# 构建镜像 Part.1
docker pull ${base_img}
cat <<EOF >> ./Dockerfile
FROM ${base_img}
LABEL maintainer="hazx632823367@gmail.com"
LABEL Version="${dest_tag}"
ADD init_script /init_script.sh
RUN bash /init_script.sh
ENV NODE_HOME="/opt/nodejs"
ENV M2_HOME="/opt/maven"
ENV MAVEN_HOME="/opt/maven"
ENV PATH="$PATH:/opt/nodejs/bin:/opt/maven/bin"
WORKDIR /ci_workdir
EOF
docker build -t ${dest_img}:${dest_tag}-p1 .
if [ "$?" != 0 ];then
    exit 1
fi
rm -f ./Dockerfile

# 构建镜像 Part.2 - kaniko
docker pull ${kanico_img}
cat <<EOF >> ./Dockerfile
FROM ${kanico_img} AS kaniko
FROM ${dest_img}:${dest_tag}-p1
LABEL maintainer="hazx632823367@gmail.com"
LABEL Version="${dest_tag}"
COPY --from=kaniko /kaniko /kaniko
RUN ln -s /kaniko/executor /usr/bin/kaniko
EOF
docker build -t ${dest_img}:${dest_tag}-p2 .
if [ "$?" != 0 ];then
    exit 1
fi
rm -f ./Dockerfile

rm -f ./${dest_img}-${dest_tag}.tar
docker tag ${dest_img}:${dest_tag}-p2 ${dest_img}:${dest_tag}
docker rmi ${dest_img}:${dest_tag}-p1 ${dest_img}:${dest_tag}-p2
docker save -o ./${dest_img}-${dest_tag}.tar ${dest_img}:${dest_tag}

echo -e "\n镜像构建完毕！\n镜像名：${dest_img}:${dest_tag}\n导出镜像：${dest_img}-${dest_tag}.tar\n"
