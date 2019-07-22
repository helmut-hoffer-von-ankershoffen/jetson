# NVIDIA Jetson (Nano) for Kubernetes (K8S) and machine learning (ML)

`Experimenting` with **arm64** based **NVIDIA Jetson Nano, Kubernetes (K8S) and machine learning (ML)**.

Hints:
- Assumes an **Nvidia Jetson Nano, TX1, TX2 or AGX Xavier** as embedded device, called "nano" below for simplicity.
- Assumes a **macOS device for development** such as Macbook Pro
- Assumes access to a **bare-metal Kubernetes cluster** the nano can join e.g. set up using [Project Max](https://github.com/helmuthva/ceil/tree/max).
- Assumes basic knowledge of **Ansible**, **Docker** and **Kubernetes**.


## Goals and features

- [x] basics: Prepare **hardware**
- [x] basics: Automatically provision requirements on **macOS device for development**
- [x] basics: Manually provision **root os** using **Nvidia JetPack** and **balenaEtcher**
- [x] basics: Automatically setup **secure ssh access**
- [x] basics: Automatically setup **sudo**
- [x] basics: Automatically setup **basic packages** for development, DevOps and CloudOps
- [x] basics: Automatically setup **LXDE** for decreased memory consumption
- [x] basics: Automatically setup **VNC** for headless access
- [x] basics: Automatically setup **RDP** for headless access
- [x] basics: Automatically setup **swap** given memory constraints on Jetson Nano
- [x] basics: Automatically setup **performance mode** to boost throughput
- [X] k8s: Automatically build **custom kernel** as required by Docker + Kubernetes + **Weave networking**
- [x] k8s: Automatically **join Kubernetes cluster** `max` as worker node labeled as `jetson` - see [Project Max](https://github.com/helmuthva/ceil/tree/max) reg. `max`
- [x] k8s: Automatically build and deploy **CUDA deviceQuery as pod in Kubernetes cluster** to validate access to GPU and correct labeling of jetson based Kubernetes nodes
- [x] k8s: Build and deploy using **Skaffold**, a custom remote builder for Jetson devices and **kustomize**
- [x] ml: **Automatically extract** CUDA, CUDNN, TensorRT and support **libraries** including python bindings that are bundled with JetPack from Jetson host as deb packages using **dpkg-repack** for later use in Docker builds
- [x] ml: Automatically build Docker base image **`jetson/ml-base`** including CUDA, CUDNN, TensorRT, TensorFlow and Anaconda for arm64
- [x] ml: Automatically build and deploy **Jupyter server** for data science with support for CUDA accelerated Octave, Seaborn, TensorFlow and Keras as pod in Kubernetes cluster running on jetson node
- [ ] ml: Automatically build and deploy **TensorFlow Serving** using **bazel** including simple FastAPI based application server for predictions
- [ ] basics: Update to **Jetpack 4.2.1** providing support for the official Nvidia Container Runtime, NGC et al
- [ ] ml: Experiment with **containers from NGC** such as **`nvcr.io/nvidia/l4t-base`**
- [ ] ml: Build out **example application** using TensorFlow training and serving
- [ ] security: Automatically setup **firewall** (waiting for iptables fix in Nvidia kernel sources) 
- [ ] community: Author a series of **blog** posts explaining how to set up ML in Kubernetes on Jetson devices
- [ ] ml: **Scale out** with Xaviers and deploy **Polarize.AI** ml tier (separate project)


## Bootstrap macOS development environment

1) Execute **`make bootstrap-environment`** to install requirements on your macOS device and setup hostnames such as `nano-one.local` in your `/etc/hosts`

Hint:
- **`make`** is used as a facade for all workflows - execute `make help` to list all targets and see the `Makefile` in this directory for details


## Provision Jetson device and join Kubernetes cluster as node

### Manually flash root os, create `admin` account and automatically establish secure access

1) Execute **`make image-download`** to download and unzip the Nvidia Jetpack image into `workflow/provision/image/`
2) Start the **`balenaEtcher`** application and flash your micro sd card with the downloaded image
3) Insert the designated micro sd card in your Nvidia Jetson nano and **power up**
4) **Create account** with username `admin` and "Administrator" rights via the UI
5) Execute **`make setup-access-secure`** and enter the password you set for the `admin` user the step above - passwordless ssh access and sudo will be set up

Hints:
- The `balenaEtcher` application was installed as part of **bootstrap** on your macOS device - see above
- SSH into your nano using **`make nano-one-ssh`** - your ssh public key was uploaded in step 5 above so no password is needed

### Automatically provision tools, services, kernel and Kubernetes on Jetson host

1) Execute **`make provision`** -  services will provisioned, kernel will be compiled, kubernetes cluster will be joined

Hints:
- You will have to update the **`kubernetes.token`** in `workflow/provision/group_vars/all.yml` to a valid join token of your Kubernetes cluster to successfully join - the token can be created using **`k8s-token-create`**
- VNC into your nano by starting the **VNC Viewer** application which was installed as part of bootstrap and connect to **`nano-one.local:5901`** - the password is `secret`
- If you want to provision **step by step** execute `make help | grep "provision-"` and execute the desired make target e.g. `make provision-kernel`


## Build and deploy services to Kubernetes cluster

1) Execute **`make device-query-deploy`** to build and deploy a pod into the Kubernetes cluster that **queries CUDA capabilities** thus validating GPU and Tensor Core access from inside Docker and correct labeling of Jetson/arm64 based Kubernetes nodes - execute `make device-query-log-show` to show the result after deploying
2) Execute **`make jupyter-deploy`** to build and deploy a **Jupyter server** supporting CUDA accelerated **TensorFlow + Keras** as a Kubernetes pod running on nano - execute `make jupyter-open` to open a browser tab pointing to the Jupyter server
3) Execute **`make tensorflow-serving-deploy`** to build and deploy **TensorFlow Serving** plus a **FastAPI based REST API** for accessing predictions as a Kubernetes pod running on nano - execute `make tensorflow-serving-open` to open a browser tab pointing to the REST API

Hints:
- Remote building on nano is implemented using **Skaffold** and a custom builder - have a look at `workflow/deploy/device-query/skaffold.yaml` and `workflow/deploy/tools/builder` for the approach
- Skaffold supports a nice **build, deploy, tail, watch cycle** - execute `make device-query-dev` as an example
- Most containers derive from the Docker base image **`jetson/ml-base`** which, amongst others, includes CUDA, CUDNN, TensorRT, TensorFlow libraries, python bindings and Anaconda - have a look at the directory `workflow/deploy/ml-base` for details
- For the base image **libraries bundled with JetPack have to be extracted** from the nano host to be used in Docker builds - execute `make nano-cuda-deb-extract` to extract and download and have a look at `workflow/deploy/tools/nano-cuda-deb-extract` for how the extraction is done automatically
- Containers mount **device drivers** - such as `usr/lib/aarch64-linux-gnu/tegra/*` as well as devices **`/dev/nv*`** at runtime to access the GPU and Tensor Cores - see `workflow/deploy/device-query/kustomize/base/deployment.yaml` for details
- Kubernetes deployments are defined using **kustomize** - you can thus define overlays for deployments on other clusters or scale-out easily
- To easily inspect the Kubernetes cluster execute the lovely **`click`** which was installed as part of bootstrap - see [Click README](https://github.com/databricks/click) for details
- If you did **not** use **[Project Max](https://github.com/helmuthva/ceil/tree/max)** to provision your bare-metal Kubernetes cluster make sure your cluster provides a private Docker registry as well as support for persistent volumes, ingress and loadbalancing as required during build and in deployments - adapt occurrences of the name `max-one` accordingly to wire up 


## Additional labeled references

- https://developer.nvidia.com/embedded/learn/get-started-jetson-nano-devkit (intro)
- https://developer.nvidia.com/embedded/jetpack (jetpack)
- https://blog.hackster.io/getting-started-with-the-nvidia-jetson-nano-developer-kit-43aa7c298797  (jetpack,vnc)
- https://devtalk.nvidia.com/default/topic/1051327/jetson-nano-jetpack-4-2-firewall-broken-possible-kernel-compilation-issue-missing-iptables-modules/ (jetpack,firewall,ufw,bug)
- https://devtalk.nvidia.com/default/topic/1052748/jetson-nano/egx-nvidia-docker-runtime-on-nano/ (docker,nvidia,missing)
- https://github.com/NVIDIA/nvidia-docker/wiki/NVIDIA-Container-Runtime-on-Jetson#mount-plugins (docker,nvidia)
- https://blog.hypriot.com/post/nvidia-jetson-nano-build-kernel-docker-optimized/ (docker,workaround)
- https://github.com/Technica-Corporation/Tegra-Docker (docker,workaround)
- https://medium.com/@jerry**liang/deploy-gpu-enabled-kubernetes-pod-on-nvidia-jetson-nano-ce738e3bcda9 (k8s)
- https://gist.github.com/buptliuwei/8a340cc151507cb48a071cda04e1f882 (k8s)
- https://github.com/dusty-nv/jetson-inference/ (ml)
- https://docs.nvidia.com/deeplearning/frameworks/install-tf-jetson-platform/index.html (tensorflow)
- https://devtalk.nvidia.com/default/topic/1043951/jetson-agx-xavier/docker-gpu-acceleration-on-jetson-agx-for-ubuntu-18-04-image/post/5296647/#5296647 (docker,tensorflow)
- https://towardsdatascience.com/deploying-keras-models-using-tensorflow-serving-and-flask-508ba00f1037 (tensorflow,keras,serving)
- https://jkjung-avt.github.io/build-tensorflow-1.8.0/ (bazel,build)
- https://oracle.github.io/graphpipe/#/ (tensorflow,serving,graphpipe)
- https://towardsdatascience.com/how-to-deploy-jupyter-notebooks-as-components-of-a-kubeflow-ml-pipeline-part-2-b1df77f4e5b3 (kubeflow,jupyter)
- https://rapids.ai/start.html (rapids ai)
- https://github.com/JetsonHacksNano/rootOnUSB (rootfs,usb3-sata-ssd)