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

docker run -it -d --net=host --name testxx -p 8000:80 testxx:tagxx
## WARNING: Published ports are discarded when using host network mode
## 8f451f75473eb4c6cc43ce189d820255499fb0cb07862b54ef3c357c6f70ad87

docker exec -it 8f451f75473eb4c6cc43ce189d820255499fb0cb07862b54ef3c357c6f70ad87 bash
## $ (bash command-line inside docker)
# apt-get update
# apt-get install -y #what you want here
# exit

docker commit 8f451f75473eb4c6cc43ce189d820255499fb0cb07862b54ef3c357c6f70ad87 testxx:tagxx



