# jetson

Experimenting with Nvidia Jetson Nano, Kubernetes and ML.

Hints:
- Assumes an Nvidia Jetson Nano, TX2 or AGX Xavier as embedded device, called "nano" below for simplicity.
- Assumes a macOS device for development
- Assumes access to a bare-metal Kubernetes cluster the nano can join e.g. set up using https://github.com/helmuthva/ceil/tree/max.
- Assumes basic knowledge of Ansible, Docker and Kubernetes (k8s).


## Features

- [x] basics: Automatically provision requirements on macOS device for development
- [x] basics: Prepare hardware
- [x] basics: Manually provision os
- [x] basics: Automatically provision secure ssh access
- [x] basics: Automatically provision passwordless sudo
- [x] basics: Automatically install basic packages
- [x] basics: Automatically setup LXDE 
- [x] basics: Automatically setup VNC
- [x] basics: Automatically setup RDP (optional)
- [x] basics: Automatically setup swap
- [x] basics: Automatically set performance mode
- [X] k8s: Automatically build custom kernel as required by Docker + Kubernetes + Weave networking
- [x] k8s: Automatically join Kubernetes cluster `max` as worker node labeled as `jetson` - see https://github.com/helmuthva/ceil/tree/max reg. `max`
- [x] k8s: Automatically build and deploy CUDA deviceQuery as pod in k8s cluster to validate access to GPU and correct labeling of jetson nodes
- [x] k8s: Build and deploy using Skaffold and kustomize
- [ ] basics: Update to Jetpack 4.2.1 providing support for NGC et al (waiting for release)
- [ ] security: Automatically setup firewall (waiting for iptables fix in Nvidia kernel sources) 
- [x] ml: Use Archiconda - the arm flavor of Anacoda - for building Docker containers for arm64
- [x] ml: Automatically build and deploy Jupyter server with support for CUDA accelerated tensorflow and keras as pod in k8s cluster running on jetson node
- [ ] ml: Experiment with containers from NGC
- [ ] community: Author a blog post explaining how to set up ML in Kubernetes on Jetson devices
- [ ] ml: Scale out with Xaviers and deploy Polarize AI core (separate project)


## Bootstrap

1) Execute `make bootstrap-environment` to install requirements on your macOS device and setup hostnames such as `nano-one.local` in your `/etc/hosts`


## Provision

### Manually flash base os, create `admin` account and establish secure access

1) Execute `make image-download` to download and unzip the Nvidia Jetpack image into `workflow/provision/image/`
2) Start the `balenaEtcher` application and flash your micro sd card with the downloaded image
3) Insert the designated micro sd card in your Nvidia Jetson nano and power up
4) Create account with username `admin` and "Administrator" rights via the UI
5) Execute `make setup-access-secure` and enter the password you set for the `admin` user the step above - passwordless ssh access and sudo will be set up

Hints:
* The `balenaEtcher` application was installed as part of bootstrap on your macOS device

### Automatically provision services, kernel, k8s

1) Execute `make provision` -  services will provisioned, kernel will be compiled, kubernetes cluster will be joined

Hints:
* If you want to provision step by step execute `make help | grep "provision-"` and execute the desired make target e.g. `make provision-kernel`
* SSH into your nano using `make nano-one-ssh` - your ssh public key was uploaded during provisioning so no password is needed
* VNC into your nano by starting the VNC Viewer application which was installed as part of bootstrap and connect to `nano-one.local:5901` - the password is `secret`
* You will have to update the `kubernetes.token` in `workflow/provision/group_vars/all.yml` to a valid join token that can be created using `make k8s-token-create` in `max` cluster


## Build and deploy

1) Execute `make device-query-deploy` to build and deploy a pod into the k8s cluster that queries CUDA capabilities thus validating GPU access from k8s - execute `make device-query-log-show` to show the result after deploying
2) Execute `make jupyter-deploy` to build and deploy a Jupyter server supporting CUDA accelerated TensorFlow + Keras as a k8s pod running on nano - execute `make jupyter-open` to open a browser tab pointing to the Jupyter server

Hints:
- Remote building on nano is implemented using Skaffold and a custom builder: E.g. use `make device-query-dev` to enter a build, deploy, tail, watch cycle.
- Deployments are defined using kustomize - you can thus define overlays for deployments on other clusters easily.
- Archiconda - the arm flavor of Anaconda - is used for installation inside Docker containers, see the Dockerfile of the Jupyter deployment
- To easily inspect the cluster execute the lovely `click` which was installed as part of bootstrap.
- Execute `make help` to show other targets that can be built and deployed


## Additional references

- https://developer.nvidia.com/embedded/learn/get-started-jetson-nano-devkit (intro)
- https://developer.nvidia.com/embedded/jetpack (jetpack)
- https://blog.hackster.io/getting-started-with-the-nvidia-jetson-nano-developer-kit-43aa7c298797  (jetpack,vnc)
- https://devtalk.nvidia.com/default/topic/1051327/jetson-nano-jetpack-4-2-firewall-broken-possible-kernel-compilation-issue-missing-iptables-modules/ (jetpack,firewall,ufw,bug)
- https://devtalk.nvidia.com/default/topic/1052748/jetson-nano/egx-nvidia-docker-runtime-on-nano/ (docker,nvidia,missing)
- https://blog.hypriot.com/post/nvidia-jetson-nano-build-kernel-docker-optimized/ (docker,workaround)
- https://github.com/Technica-Corporation/Tegra-Docker (docker,workaround)
- https://medium.com/@jerry_liang/deploy-gpu-enabled-kubernetes-pod-on-nvidia-jetson-nano-ce738e3bcda9 (k8s)
- https://gist.github.com/buptliuwei/8a340cc151507cb48a071cda04e1f882 (k8s)
- https://github.com/dusty-nv/jetson-inference/ (ml)
- https://docs.nvidia.com/deeplearning/frameworks/install-tf-jetson-platform/index.html (tensorflow)
- https://devtalk.nvidia.com/default/topic/1043951/jetson-agx-xavier/docker-gpu-acceleration-on-jetson-agx-for-ubuntu-18-04-image/post/5296647/#5296647 (docker,tensorflow)