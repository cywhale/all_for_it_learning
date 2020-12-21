# DAY1
# Q1: docker build by dockerfile, no network connection, cannot apt-get update, and got error: 111 connection refused to any mirror.
# Ans1:...... after try many methods from stackoverflow, finally found just use --network host, and it works

docker build --network host -t testxx ./

# Q2: ERROR occrur and break your docker build, got <none> for repository and tag
# Ans2: docker commit

docker images
## REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
## <none>              <none>              fb0285591702        2 minutes ago       1.53GB

docker ps -a
## CONTAINER ID        IMAGE                COMMAND                   CREATED             STATUS                         PORTS               NAMES
## 5d09b7a80c7a        f0534d5e11ec         "/bin/sh -c 'R -e \"r…"   About an hour ago   Exited (1) About an hour ago                       inter

docker commit 5d09b7a80c7a testxx:tagxx

# Q3: docker run container lost changes after exit exec bash
# ....... Note: Still 111 connection refused during docker run, use --net=host 
# Ans3: docker commit

docker run -it --net=host --name testxx testxx:tagxx /bin/bash
## $ (bash command-line inside docker)
# apt-get update
# apt-get install -y #what you want here
# exit

docker commit testxx testxx:tagxx

# DAY2 install SSH inside docker container
# ref: https://docs.docker.com/engine/examples/running_ssh_service/
docker run -it --name testxx your_container:tagxx /bin/bash
# -------------------- in container -----------------------
## root@$
apt-get update && apt-get install -y netstat openssh-server
mkdir -p /var/run/sshd

# echo 'root:YOUR_PASS' | chpasswd
sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config

mkdir root/.ssh
echo '#!/bin/bash' > /run.sh
echo '/usr/sbin/sshd -D' >> /run.sh
chmod u+x run.sh
exit
# -------------------- exit container -----------------------

docker commit -c "EXPOSE 22" testxx your_container:tagxx
docker stop testxx
docker rm testxx

# NOW you can run for ssh 
docker run -p YOUR_PORT:22 -d --name testxx your_container:tagxx /run.sh

# Login from remote, BUT it's may not safe due to root login
ssh root@your_localhost_ip -p YOUR_PORT






