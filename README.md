
- [Guideline](#guideline)
- [Setup Development Environment](#setup-development-environment)
  - [Docker Installation](#docker-installation)
  - [Kubernetes Cluster Setup](#kubernetes-cluster-setup)
    - [Docker Desktop (default)](#docker-desktop-default)
    - [Minikube Installation (Optional)](#minikube-installation-optional)
  - [KubeCTL Installation](#kubectl-installation)
  - [Test Kubectl connection to cluster](#test-kubectl-connection-to-cluster)
- [Deployment](#deployment)
  - [Build docker image](#build-docker-image)
  - [Deploy with Kubectl](#deploy-with-kubectl)
- [License](#license)
- [Bugs](#bugs)

# Setup Development Environment
in order to work with your django application with k8s you need to prepare your environment for development, such as installing docker and minikube for start. so follow along the instructions and make everything.

## Docker Installation
You'll need to have [Docker installed](https://docs.docker.com/get-docker/).
It's available on Windows, macOS and most distros of Linux. 

System requirements
To install Docker Desktop successfully, your Linux host must meet the following general requirements:

- 64-bit kernel and CPU support for virtualization.
- KVM virtualization support. Follow the KVM virtualization support instructions to check if the KVM kernel modules are enabled and how to provide access to the kvm device.
- QEMU must be version 5.2 or newer. We recommend upgrading to the latest version.
- systemd init system.
- Gnome, KDE, or MATE Desktop environment.
- For many Linux distros, the Gnome environment does not support tray icons. To add support for tray icons, you need to install a Gnome extension. For example, AppIndicator.
- At least 4 GB of RAM.
- Enable configuring ID mapping in user namespaces, see File sharing.

Docker Desktop for Linux runs a Virtual Machine (VM). For more information on why, see Why Docker Desktop for Linux runs a VM.

If you're using Windows, it will be expected that you have to install wsl too. [WSL or WSL
2](https://nickjanetakis.com/blog/a-linux-dev-environment-on-windows-with-wsl-2-docker-desktop-and-more).

That's because we're going to be running shell commands. You can always modify
these commands for PowerShell if you want.


## Kubernetes Cluster Setup
in order to run the kubernetes cluster you need to install one of the following providers for dev environment
### Docker Desktop (default)
docker desktop already has support for windows,linux and mac so its already there all you have to do is to go to docker desktop settings and enable kubernetes, and wait till installation is completed. after that you will see another icon appears beside docker and shows the status of the kubernetes too.


### Minikube Installation (Optional)
Minikube is Kubernetes tool. It allows you to run Kubernetes locally on your computer. It runs as a single-node Kubernetes cluster within your local computer, making it easy to develop the Kubernetes app.
you can follow the instructions provided here to install it based on your os.

<https://minikube.sigs.k8s.io/docs/start/>

What you’ll need
- 2 CPUs or more
- 2GB of free memory
- 20GB of free disk space
- Internet connection
- Container or virtual machine manager, such as: Docker, QEMU, Hyperkit, Hyper-V, KVM, Parallels, Podman, VirtualBox, or VMware Fusion/Workstation



after installation you have to run the minikube and set it up for usage, so in order to do that just run the following command:
```shell
minikube start
```

**Note:** if you want to change the default driver for minikube you can pass the argument like this:
```shell
minikube start --driver=virtualbox
```
which will setup minikube with virtualbox as the default driver. for more information see the documentation in here: <https://minikube.sigs.k8s.io/docs/drivers/>. by default we will use docker.

when its done you will see the details of the steps and informations.

## KubeCTL Installation
The Kubernetes command-line tool, kubectl, allows you to run commands against Kubernetes clusters. You can use kubectl to deploy applications, inspect and manage cluster resources, and view logs. For more information including a complete list of kubectl operations, see the kubectl reference documentation provided here:

<https://kubernetes.io/docs/reference/kubectl/>

for installing kubectl, you can head to the link down below and choose the right os and start the installation steps:

<https://kubernetes.io/docs/tasks/tools/>

**Note:** for windows users after downloading the file you have to put it in a folder inside C directory and then just add the path to environment variables of the system. then you can access and test it with the following command: ```shell  kubectl version --client```


## Test Kubectl connection to cluster

Once you have the PATH ready, run the following command to check if your set Kubectl is ready to execute Kubernetes commands:
```shell 
kubectl cluster-info
```

# Deployment

## Build docker image
for deployment purposes you need to build the docker image, so it can be used inside the k8s deployment as a refrence.
there are two options here: 

- build locally and push to docker hub - set `$REPOSITORY_URL` equal to your dockerhub username

Run `REPOSITORY_URL="petecheslock" ./create-push-docker.sh`
to push the containers to dockerhub

- build locally and use it

For local testing, you can run these commands to build the containers.

for building django app:
```shell
docker build -t django_app -f ./dockerfiles/dev/django/Dockerfile .
```

and for nginx app:
```shell
docker build -t nginx_app -f ./dockerfiles/dev/nginx/Dockerfile .
```

## Deploy with Kubectl

Mount the shared directory
```shell
minikube mount tmp/appmap:/appmap-host  
```

Apply the k8s configs

```shell
kubectl apply -R -f ./k8s
```


```shell
$ kubectl get all
NAME                           READY   STATUS    RESTARTS   AGE
pod/django-5b74bd444-mskdm     1/1     Running   0          2m43s
pod/my-nginx-c7bb68546-64q56   1/1     Running   0          25s
pod/my-nginx-c7bb68546-qrkl2   1/1     Running   0          25s
pod/postgres-6bdb7d69c-2wn9v   1/1     Running   0          7m3s
pod/redis-67b95b7577-2jwv8     1/1     Running   0          4m1s

NAME                         TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
service/django               ClusterIP      10.110.233.36    <none>        8000/TCP       2m21s
service/kubernetes           ClusterIP      10.96.0.1        <none>        443/TCP        4d21h
service/nginx-loadbalancer   LoadBalancer   10.109.224.172   localhost     80:30362/TCP   20s
service/postgres             ClusterIP      10.97.134.246    <none>        5432/TCP       6m58s
service/redis                ClusterIP      10.98.178.118    <none>        6379/TCP       3m46s

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/django     1/1     1            1           2m43s
deployment.apps/my-nginx   2/2     2            2           25s
deployment.apps/postgres   1/1     1            1           7m3s
deployment.apps/redis      1/1     1            1           4m1s

NAME                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/django-5b74bd444     1         1         1       2m43s
replicaset.apps/my-nginx-c7bb68546   2         2         2       25s
replicaset.apps/postgres-6bdb7d69c   1         1         1       7m3s
replicaset.apps/redis-67b95b7577     1         1         1       4m1s
```


Run the following to tunnel to the LB

```shell
minikube tunnel
```

```shell
open http://localhost:8888
```

# License
MIT.


# Bugs
Feel free to let me know if something needs to be fixed. or even any features seems to be needed in this repo.
