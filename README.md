# NVIDIA Jetson Nano and NVIDIA Jetson AGX Xavier for Kubernetes (K8s) and machine learning (ML) for smart IoT

`Experimenting` with [**arm64**](https://en.wikipedia.org/wiki/ARM_architecture) based [**NVIDIA Jetson**](https://www.nvidia.com/de-de/autonomous-machines/embedded-systems/) (Nano and AGX Xavier) [edge devices](https://www.networkworld.com/article/3224893/what-is-edge-computing-and-how-it-s-changing-the-network.html) running [**Kubernetes**](http://kubernetes.org/) (K8s) for [**machine learning**](https://see.stanford.edu/Course/CS229) (ML) including [Jupyter Notebooks](https://jupyter.org/), [TensorFlow Training](https://www.tensorflow.org/) and [TensorFlow Serving](https://www.tensorflow.org/tfx/guide/serving) using [CUDA](https://de.wikipedia.org/wiki/CUDA) for [**smart IoT**](https://www.mdpi.com/2504-2289/2/3/26/htm).

Hints:
- Assumes an **NVIDIA Jetson [Nano](https://www.nvidia.com/en-us/autonomous-machines/embedded-systems/jetson-nano/), TX1, TX2 or [AGX Xavier](https://www.nvidia.com/en-us/autonomous-machines/embedded-systems/jetson-agx-xavier/)** as edge device.
- Assumes a **macOS workstation for development** such as [MacBook Pro](https://www.apple.com/mac/)
- Assumes access to a **bare-metal Kubernetes cluster** the Jetson devices can join e.g. set up using [Project Max](https://github.com/helmuthva/ceil/tree/max).
- Assumes basic knowledge of [**Ansible**](https://www.ansible.com/), [**Docker**](https://www.docker.com/) and Kubernetes.


## Mission

- **Evaluate feasibility** and complexity of **Kubernetes + machine learning on edge devices** for future smart IoT projects
- Provide **patterns to the Jetson community** on how to use Ansible and Kubernetes with Jetson devices for **automation** and  **orchestration**
- **Lower the entry barrier** for some machine learning **students** by using cheap edge devices available offline with this starter instead of requiring commercial clouds available online
- Provide a modern **Jupyter** based infrastructure for students of the  **Stanford CS229 course** using Octave as kernel
- Remove some personal rust regarding deep learning, multi ARM ,-) bandits, artificial intelligence in general and have **fun**

![alt text](https://raw.githubusercontent.com/helmuthva/jetson/master/doc/assets/setup.jpg "Current Setup")

## Features

- [x] basics: Prepare **hardware** including shared shopping list
- [x] basics: Automatically provision requirements on **macOS device for development**
- [x] basics: Manually provision **root os** using [**NVIDIA JetPack**](https://developer.nvidia.com/embedded/jetpack) and [**balenaEtcher**](https://www.balena.io/etcher/)
- [x] basics: Works with latest [**JetPack 4.2.1**](https://devtalk.nvidia.com/default/topic/1057580/jetson-nano/jetpack-4-2-1-l4t-r32-2-release-for-jetson-nano-jetson-tx1-tx2-and-jetson-agx-xavier/1) and default container runtime
- [ ] basics: Works with official [**NVIDIA Container Runtime**](https://github.com/NVIDIA/nvidia-container-runtime), [NGC](https://ngc.nvidia.com/) and [**`nvcr.io/nvidia/l4t-base`**](vhttps://ngc.nvidia.com/catalog/containers/nvidia:l4t-base) base image provided by NVIDIA
- [x] basics: Automatically setup **secure ssh access**
- [x] basics: Automatically setup **sudo**
- [x] basics: Automatically setup **basic packages** for development, [DevOps](https://en.wikipedia.org/wiki/DevOps) and CloudOps
- [x] basics: Automatically setup [**LXDE**](https://lxde.org/) for decreased memory consumption
- [x] basics: Automatically setup [**VNC**](https://www.realvnc.com/en/connect/download/viewer/macos/) for headless access
- [x] basics: Automatically setup [**RDP**](https://apps.apple.com/app/microsoft-remote-desktop-10/id1295203466) for headless access
- [x] basics: Automatically setup **performance mode** including persistent setting of max frequencies for CPU+GPU+EMC to boost throughput
- [X] basics: Automatically build **custom kernel** as required by Docker + Kubernetes + [**Weave networking**](https://www.weave.works/docs/net/latest/overview/) and allowing boot from USB 3.0 / SSD drive
- [x] basics: Automatically provision Jetson Xaviers (in addition to Jetson Nanos) including automatic setup of guest VM for building custom kernel and rootfs and headless oem-setup using a USB-C/serial connection from the guest VM to the Xavier device
- [x] basics: Automatically setup NVMe / **SSD drive** and use for Docker container images and volumes used by Kubernetes on Jetson Xaviers as part of provisioning
- [x] k8s: Automatically **[join](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-join/) Kubernetes cluster** `max` as worker node labeled as `jetson` - see [Project Max](https://github.com/helmuthva/ceil/tree/max) reg. `max`
- [x] k8s: Automatically build and deploy **CUDA [deviceQuery](https://github.com/NVIDIA/cuda-samples/tree/master/Samples/deviceQuery) as pod in Kubernetes cluster** to validate access to GPU and correct [labeling](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) of jetson based Kubernetes nodes
- [x] k8s: Build and deploy using [**Skaffold**](https://skaffold.dev/), a [custom remote builder](https://skaffold.dev/docs/how-tos/builders/) for Jetson devices and [**kustomize**](https://kustomize.io/) for configurable Kubernetes deployments without the need to write Go templates in [Helm](https://helm.sh/) for Tiller
- [x] k8s: Integrate [**Container Structure Tests**](https://github.com/GoogleContainerTools/container-structure-test) into workflows
- [x] ml: **Automatically repack** CUDNN, TensorRT and support **libraries** including python bindings that are bundled with JetPack on Jetson host as deb packages using **dpkg-repack** for later use in Docker builds
- [x] ml: Automatically build Docker base image **`jetson/ml-base`** including CUDA, [CUDNN](https://developer.nvidia.com/cudnn), [TensorRT](https://developer.nvidia.com/tensorrt), TensorFlow and [Anaconda](https://www.anaconda.com/) for [arm64](https://github.com/Archiconda)
- [x] ml: Automatically build and deploy **Jupyter server** for data science with support for CUDA accelerated [Octave](https://www.gnu.org/software/octave/), [Seaborn](https://seaborn.pydata.org/), TensorFlow and [Keras](https://keras.io/) as pod in Kubernetes cluster running on jetson node
- [x] ml: Automatically build Docker base image **`jetson/tensorflow-serving-base`** using [bazel](https://bazel.build/) and the latest TensorFlow core including support for CUDA capabilities of Jetson edge devices
- [x] ml: Automatically build and deploy **simple Python/[**Fast API**](https://fastapi.tiangolo.com/) based webservice as facade of TensorFlow Serving** for getting predictions inc. health check for K8s probes, interactive OAS3 API documentation, request/response validation, access of TensorFlow Serving via REST and alternatively **gRPC**
- [x] ml: Provide variants of Docker images and Kubernetes deployments for Jetson AGX Xavier using auto-activation of Skaffold profiles
- [ ] ml: Automatically setup machine learning workflows using [**Kubeflow**](https://www.kubeflow.org/docs/started/getting-started/)
- [ ] ml: Build out **end to end example application** using TensorFlow training, inference and serving using S3 provided by **minio** for deploying trained models for inference
- [x] optional: Semi-automatically setup USB 3.0 / **SSD boot drive** given existing installation on micro sd card on Jetson Nanos
- [ ] optional: Automatically **[cross-build](https://engineering.docker.com/2019/04/multi-arch-images/) arm64 Docker images on macOS** for Jetson devices using [**buildkit**](https://github.com/moby/buildkit) and [**buildx**](https://github.com/docker/buildx)
- [ ] optional: Automatically setup **firewall** on host using [`ufw`](https://wiki.ubuntu.com/UncomplicatedFirewall) for basic security
- [x] community: Publish images on [**Docker Hub**](https://hub.docker.com/u/helmuthva) and provide Skaffold profiles to pull from there instead of having to build before deploy
- [ ] community: Author a series of **blog** posts explaining how to set up ML in Kubernetes on Jetson devices based on this starter
- [ ] ml: Deploy **Polarize.AI** ml training and inference tiers on Jetson nodes (separate project)


## Hardware

### Shopping list (for Jetson Nano)

- [**Jetson Nano Developer Kit**](https://store.nvidia.com/store?Action=DisplayPage&Locale=en_US&SiteID=nvidia&id=QuickBuyCartPage) - ca. $110
- [**Power supply**](https://www.amazon.com/ALITOVE-Converter-5-5x2-1mm-100V-240V-Security/dp/B078RT3ZPS) -  ca. $14
- [**Jumper**](https://www.amazon.com/KINCREA-Housing-Connector-Adaptor-Assortment/dp/B07DF9BJKH) - ca. $12 - you need only one jumper
- [**micro SDHC card**](https://www.amazon.com/dp/B06XWMQ81P) - ca. $10
- [**Ethernet cable**](https://www.amazon.com/AmazonBasics-RJ45-Cat-6-Ethernet-Patch-Cable-5-Feet-1-5-Meters/dp/B00N2VILDM) - ca. $4
- optional: [**M.2/SATA SSD disk**](https://www.amazon.com/dp/B073SBV3XX/ref=twister_B07T7C9WG6?_encoding=UTF8&psc=1) - ca. $49
- optional: [**USB 3.0 to M.2/SATA enclosure**](https://www.amazon.com/ELUTENG-Enclosure-External-Superspeed-Compatible/dp/B07H95GRSQ) - ca. $12

Total ca. **$210** including options.

Hints:
- Assumes a **USB mouse**, **USB keyboard**, **HDMI cable** and **monitor** is given as required for initial boot of the root OS
- Assumes an **existing bare-metal Kubernetes cluster** including an Ethernet switch to connect to - have a look at [Project Max](https://github.com/helmuthva/ceil/tree/max) for how to build one with [mini PCs](https://www.amazon.com/GIGABYTE-Barebone-System-Components-GB-BACE-3000/dp/B0161UXU5Y) or [Project Ceil](https://github.com/helmuthva/ceil) for the [Raspberry PI](https://www.raspberrypi.org/) variant.
- Except for injecting the SSD into its enclosure and shortening one jumper (as described below) **no assembly is required**.


### Shopping list (for Jetson Xavier)

- [**Jetson Xavier Developer Kit**](https://store.nvidia.com/store?Action=DisplayPage&Locale=en_US&SiteID=nvidia&id=QuickBuyCartPage) - ca. $712
- [**M.2/NVMe SSD disk**](https://www.amazon.com/Blue-SN500-500GB-NVMe-Internal/dp/B07P7TFKRH/ref=sr_1_2) - ca. $65

Total ca. **$767**.

Hints:
- A **USB mouse**, **USB keyboard**, **HDMI cable** and **monitor** is *not* required for initial boot of the root OS as the headless OEM-setup is supported
- Assumes an **existing bare-metal Kubernetes cluster** including an Ethernet switch to connect to - have a look at [Project Max](https://github.com/helmuthva/ceil/tree/max) for how to build one with [mini PCs](https://www.amazon.com/GIGABYTE-Barebone-System-Components-GB-BACE-3000/dp/B0161UXU5Y) or [Project Ceil](https://github.com/helmuthva/ceil) for the [Raspberry PI](https://www.raspberrypi.org/) variant.
- Except for installing the NVMe SSD (as described below) **no assembly is required**.

#### Install NVMe SSD (required)

As the eMMC soldered onto a Xavier board is 32GB only an **SSD is required** to provide adequate disk space for Docker images and volume.

1) **Hook up** the SSD to the m2 port of the daughterboard as follows: (TBD: reference video)
2) Provisioning as described below will **automatically integrate the SSD** to provide the `/var/lib/docker` directory

## Bootstrap macOS development environment

1) Execute **`make bootstrap-environment`** to install requirements on your macOS device and setup hostnames such as `nano-one.local` in your `/etc/hosts`

Hint:
- During bootstrap you will have to enter the passsword of the current user on your macOS device to **allow software installation** multiple times
- The system / security settings of your macOS device must [allow](https://www.macworld.com/article/3094865/how-to-run-apps-that-are-not-from-the-app-store-in-macos-sierra.html) installation of software coming **from outside of the macOS AppStore**
- [**`make`**](https://en.wikipedia.org/wiki/Make_(software)) is used as a facade for all workflows triggered from the development workstation - execute **`make help`** on your macOS device to list all targets and see the `Makefile` in this directory for details
- **Ansible** is used for configuration management on macOS and nano  - all Ansible roles are [**idempotent**](https://docs.ansible.com/ansible/latest/reference_appendices/glossary.html) thus can be executed repeatedly e.g. after you make changes in the configuration in `workflow/provision/group_vars/all.yml`
- Have a look at `workflow/requirements/macOS/ansible/requirements.yml` for a **list of packages and applications** installed


## Provision Jetson devices and join Kubernetes cluster as nodes

### Part 1 (for Jetson Nanos): Manually flash root os, create `provision` account as part of oem-setup and automatically establish secure access

1) Execute **`make nano-image-download`** on your macOS device to download and unzip the NVIDIA Jetpack image into `workflow/provision/image/`
2) Start the **`balenaEtcher`** application and flash your micro sd card with the downloaded image
3) Wire the nano up with the ethernet switch of your **Kubernetes cluster**
4) Insert the designated micro sd card in your NVIDIA Jetson nano and **power up**
5) **Create a user account** with username **`provision`** and "Administrator" rights via the UI and set **`nano-one`** as hostname - wait until the login screen appears
6) Execute **`make setup-access-secure`** and enter the password you set for the `provision` user in the step above when asked - passwordless ssh access and sudo will be set up

Hints:
- The `balenaEtcher` application was installed as part of **bootstrap**  - see above
- Step 5 requires to **wire up** your nano with a USB mouse, keyboard and monitor - after that you can unplug and use the nano with headless access using ssh, VNC, RDP or http
- In case of a Jetson Nano you might experience intermittent operation - make sure to **provide an adequate power supply** - the best option is to put a [Jumper](https://www.amazon.de/gp/product/B07BTB3MC7/ref=ppx_yo_dt_b_asin_title_o05_s00?ie=UTF8&psc=1) on pins J48 and use a [DC barrel jack power supply](https://www.amazon.de/gp/product/B07NSSD9RJ/ref=ppx_yo_dt_b_asin_title_o05_s00?ie=UTF8&psc=1) (with 5.5mm OD / 2.1mm ID / 9.5mm length, center pin positive) than can supply 5V with 4A - see [NVIDIA DevTalk](https://devtalk.nvidia.com/default/topic/1048640/jetson-nano/power-supply-considerations-for-jetson-nano-developer-kit/) for a schema of the board layout.
- Depending on how the DHCP server of your cluster is configured you might have to adapt the IP address of `nano-one.local` in **`workflow/requirements/generic/ansible/playbook.yml`** - run **`make requirements-hosts`** after updating the IP address which in turn updates the `/etc/hosts` file of your mac
- SSH into your nano using **`make nano-one-ssh`** - your ssh public key was uploaded in step 6 above so no password is asked for

### Part 1 (for Jetson AGX Xaviers): Provision guest VM (Ubuntu), build custom Kernel and rootfs in guest VM, flash Xavier, create `provision` account on Xavier as part of oem-setup and automatically establish secure access

1) Execute **`make guest-sdk-manager-download`** on your macOS device and follow instructions shown to download the NVIDIA SDK Manager installer into `workflow/guest/download/` - if you fail to download the NVIDIA SDK manager you will be instructed in the next step on how to do it.
2) Execute **`make guest-build`** to automatically a) create, boot and provision a Ubuntu guest VM on your macOS device using Vagrant, Virtual Box and Ansible and b) build a custom kernel and rootfs inside the guest VM for flashing the Xavier device - **the Linux kernel is built with requirements for Kubernetes + Weave networking** - such as activating [IP sets](http://ipset.netfilter.org/) and the [Open vSwitch](https://www.openvswitch.org/) datapath module, SDK components are added to the rootfs for automatic installation during provisioning (see part 2). You will be prompted to download SDK components via the NVIDIA SDK manager that was automatically installed during provisioning of the guest VM - please do as instructed on-screen.
3) Execute **`make guest-flash`** to flash the Xavier with the custom kernel and rootfs - wire up the Xavier with your macOS device using USB-C and enter the recovery mode by powering up and pressing the buttons as described in the printed user manual that was part of your Jetson AGX Xavier shipment before execution
4) Execute **`make guest-oem-setup`** to start the headless oem-setup process. Follow the on-screen instructions to setup your locale and timezone, create a user account called `provision` and set an initial password - press the reset button of your Xavier after flashing before triggering the oem-setup.
5) Execute **`make setup-access-secure`** and enter the password you set for the user `provision` in the step above when asked - passwordless ssh access and sudo will be set up

Hints:
- There is **no** need to wire up your Xavier with a USB mouse, keyboard and monitor for oem-setup as **headless oem-setup** is implemented as described in step 4  
- Depending on how the DHCP server of your cluster is configured you might have to adapt the IP address of `xavier-one.local` in **`workflow/requirements/generic/ansible/playbook.yml`** - you can check the assigned IP after step 4 by logging in as user `provision` with the password you set, executing `ifconfig eth0 | grep 'inet'` and checking the IP address shown - run **`make requirements-hosts`** after updating the IP address which in turn updates the `/etc/hosts` file of your mac
- SSH into your nano using **`make xavier-one-ssh`** - your ssh public key was uploaded in step 5 above so no password is asked for

### Part 2 (for all Jetson devices): Automatically provision tools, services, kernel and Kubernetes on Jetson host

1) Execute **`make k8s-token-create`** to generate a valid join token for your Kubernetes cluster and update **`kubernetes.token`** in `workflow/provision/group_vars/all.yml`
2) Execute **`make provision`** - amongst others services will provisioned, kernel will be compiled (on Jetson Nanos only), Kubernetes cluster will be joined

Hints:
- For Jetson Nanos **the Linux kernel is built with requirements for Kubernetes + Weave networking** during provisioning - such as activating [IP sets](http://ipset.netfilter.org/) and the [Open vSwitch](https://www.openvswitch.org/) datapath module - thus initial provisioning takes **ca. one hour** - for Jetson Xaviers a custom kernel is built in the guest VM and flashed in part 1 (see above)
- Execute **`kubectl get nodes`** to check that your edge devices joined your cluster and are ready
- To easily inspect the Kubernetes cluster in depth execute the lovely **`click`** from the terminal which was installed as part of bootstrap - enter `nodes` to list the nodes with the nano being one of them - see [Click](https://github.com/databricks/click) for details
- VNC into your nano by starting the **VNC Viewer** application which was installed as part of bootstrap and connect to **`nano-one.local:5901`** or **`xavier-one.local:5901`** respectively - the password is `secret`
- For Xaviers the NVMe SSD is automatically integrated during provisioning to provide `/var/lib/docker`. For Jetson Nanos you can optionally use a SATA SSD as boot device as described below.
- If you want to provision **step by step** execute `make help | grep "provision-"` and execute the desired make target e.g. `make provision-kernel`
- Provisioning is implemented **idempotent** thus it is safe to repeat provisioning as a whole or individual steps

## Build and deploy services to Kubernetes cluster

1) Execute **`make nano-one-cuda-ml-deb-repack`** *once* to repack libraries bundled with the JetPack image as deb files such as CUDNN, TensorRT, TensorFlow libraries, python bindings - this will create the repository `/var/cuda-ml-local-repo` on your Nano which is used in building the **`jetson/ml-base`** image -  have a look at `workflow/deploy/tools/nano-cuda-ml-deb-repack` for details - the same goes for Xaviers using **`make xavier-one-cuda-ml-deb-repack`**
2) Execute **`make ml-base-build-and-test`** *once* to build the Docker base image **`jetson/ml-base`**, test via container structure tests and push to the private registry of your cluster, which, amongst others, includes CUDA, CUDNN, TensorRT, TensorFlow, python bindings and Anaconda - have a look at the directory `workflow/deploy/ml-base` for details - most images below derive from this image
3) Execute **`make device-query-deploy`** to build and deploy a pod into the Kubernetes cluster that **queries CUDA capabilities** thus validating GPU and [Tensor Core](https://www.nvidia.com/en-us/data-center/tensorcore/) access from inside Docker and correct labeling of Jetson/arm64 based Kubernetes nodes - execute `make device-query-log-show` to show the result after deploying
4) Execute **`make jupyter-deploy`** to build and deploy a **Jupyter server** as a Kubernetes pod running on nano supporting CUDA accelerated **TensorFlow + Keras** including support for **Octave** as an alternative Jupyter Kernel in addition to iPython - execute **`make jupyter-open`** to open a browser tab pointing to the Jupyter server to execute the bundled **Tensorflow Jupyter notebooks** for [deep learning](https://en.wikipedia.org/wiki/Deep_learning)
4) Execute **`make tensorflow-serving-base-build-and-test`** *once* to build the TensorFlow Serving base image **`jetson/tensorflow-serving-base`** test via container structure tests and push to the private registry of your cluster - have a look at the directory `workflow/deploy/tensorflow-serving-base` for details - most images below derive from this image
5) Execute **`make tensorflow-serving-deploy`** to build and deploy **TensorFlow Serving** plus a Python/Fast API based [Webservice](https://en.wikipedia.org/wiki/Web_service) for getting predictions as a Kubernetes pod running on nano - execute **`make tensorflow-serving-docs-open`** to open browser tabs pointing to the interactive OAS3 documentation Webservice API; execute **`make tensorflow-serving-health-check`** to check the health as used in K8s readiness and liveness probes; execute **`make tensorflow-serving-predict`** to get predictions

Hints:
- To target Xavier devices execute **`JETSON_MODEL=xavier`** in your shell before building or deploying which will auto-activate the matching Skaffold profiles (see below) - if `JETSON_MODEL` is not set the Nanos will be targeted
- All deployments automatically create **a private Kubernetes namespace** using the pattern `jetson-$deployment` - e.g. `jetson-jupyter` for the Jupyter deployment - thus easing inspection in the [Kubernetes dashboard](https://github.com/kubernetes/dashboard), `click` or similar
- All deployments provide a **target for deletion** such as `make device-query-delete` which will automatically delete the respective namespace, persistent volumes, pods, services, ingress and loadbalancer on the cluster
- All builds on the Jetson device run as **user `build`** which was created during provisioning - use `make nano-one-ssh-build` or `make xavier-one-ssh-build` to login as user `build` to monitor intermediate results
- Remote building on the Jetson device is implemented using **Skaffold** and a custom builder - have a look at `workflow/deploy/device-query/skaffold.yaml` and `workflow/deploy/tools/builder` for the approach
- Skaffold supports a nice [**build, deploy, tail, watch cycle**](https://skaffold.dev/docs/getting-started/) - execute `make device-query-dev` as an example
- Containers mount devices **`/dev/nv*`** at runtime to access the GPU and Tensor Cores - see `workflow/deploy/device-query/kustomize/base/deployment.yaml` for details
- Kubernetes deployments are defined using **kustomize** - you can thus define kustomize [**overlays**](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/#bases-and-overlays) for deployments on other clusters or scale-out easily
- Kustomize overlays can be easily referenced using [**Skaffold profiles**](https://skaffold.dev/docs/how-tos/profiles/) - have a look at `workflow/deploy/device-query/skaffold.yaml` and `workflow/deploy/device-query/kustomize/overlays/xavier` for an example - in this case the `xavier` profile is auto-activated respecting the `JETSOON_MODEL` environment variable (see above) with the profile in turn activating the `xavier` Kustomize overlay
- All containers provide targets for **Google container structure tests** - execute `make device-query-build-and-test` as an example
- For easier consumption all container images are published on [**Docker Hub**](https://hub.docker.com/u/helmuthva) - if you want to publish your own create a file called `.docker-hub.auth` in this directory (see `docker-hub.auth.template`) and execute the approriate make target, e.g. `make ml-base-publish`
- If you did **not** use **[Project Max](https://github.com/helmuthva/ceil/tree/max)** to provision your bare-metal Kubernetes cluster make sure your cluster provides a DNSMASQ and DHCP server, firewalling, VPN and private Docker registry as well as support for Kubernetes features such as persistent volumes, ingress and loadbalancing as required during build and in deployments - adapt occurrences of the name `max-one` accordingly to wire up with your infrastructure
- The webservice of `tensorflow-serving` accesses TensorFlow Serving via its REST or alternatively the **Python bindings of the gRPC API** - have a look at the directory `workflow/deploy/tensorflow-serving/src/webservice` for details of the implementation

## Optional: Configure swap

1) Execute **`provision-swap`**

Hints:
- You can **configure the required swap size** in `workflow/provision/group_vars/all.yml`

## Optional (Jetson Nanos only): Boot from USB 3.0 SATA SSD - for advanced users only

1) **Wire up your SATA SSD** with one of the USB 3.0 ports, unplug all other block devices connected via USB ports and reboot via `make nano-one-reboot`
2) Set the **`ssd.id_serial_short`** of the SSD in `workflow/provision/group_vars` given the info provided by executing **`make nano-one-ssd-id-serial-short-show`**  
3) Execute **`nano-one-ssd-prepare`** to assign the stable device name /dev/ssd, wipe and partition the SSD, create an ext4 filesystem and sync the micro SD card to the SSD
4) Set the **`ssd.uuid`** of the SSD in `workflow/provision/group_vars` given the info provided by executing **`make nano-one-ssd-uuid-show`**  
5) Execute **`nano-one-ssd-activate`** to configure the boot menu to use the SSD as the default boot device and reboot

Hints:
- A SATA SSD connected via USB 3.0 is more durable and typically **faster by a factor of three** relative to a micro sd card - tested using a [WD Blue M.2 SSD](https://www.amazon.de/dp/B073SBV3XX/ref=twister_B07TP4ZYNV?_encoding=UTF8&psc=1) versus a [SanDisk Extreme microSD card](https://www.amazon.de/gp/product/B07FCMKK5X/ref=ppx_yo_dt_b_asin_title_o02_s00?ie=UTF8&psc=1)
- The micro sd card is mounted as **`/mnt/mmc`** after step 5 in case you want to update the kernel later which now resides in `/mnt/mmc/boot/Image`
- ~~You can **wire up additional block devices via USB** again after step 5 as the UUID is used for referencing the SSD designated for boot~~ (wip)

## Optional: Cross-build Docker images for Jetson on macOS (wip)

1) Execute **`make l4t-deploy`** to cross-build Docker image on macOS using buildkit based on official base image from NVIDIA and deploy - functionality is identical to `device-query` - see above

Hints:
- Have a look at the **custom Skaffold builder for Mac** in `workflow/deploy/l4t/builder.mac` on how this is achieved
- A `daemon.json` switching on **experimental Docker features on your macOS device** required for this was automatically installed as part of bootstrap - see above

## Optional: Setup firewall (wip)

1) Execute **`provision-firewall`**


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
- https://syonyk.blogspot.com/2019/04/nvidia-jetson-nano-desktop-use-kernel-builds.html (boot,usb)
- https://kubeedge.io/en/ (kube,edge)
- https://towardsdatascience.com/bringing-the-best-out-of-jupyter-notebooks-for-data-science-f0871519ca29  (jupyter,data-science)
- https://github.com/jetsistant/docker-cuda-jetpack/blob/master/Dockerfile.base (cuda,deb,alternative-approach)
- https://docs.bazel.build/versions/master/user-manual.html (bazel,manual)
- https://docs.bitnami.com/google/how-to/enable-nvidia-gpu-tensorflow-serving/ (tf-serving,build,cuda)
- https://github.com/tensorflow/serving/blob/master/tensorflow_serving/tools/docker/Dockerfile.devel-gpu (tf-serving,docker)
- https://www.kubeflow.org/docs/components/serving/tfserving_new/ (kubeflow,tf-serving)
- https://www.seldon.io/open-source/ (seldon,ml)
- https://www.electronicdesign.com/industrial-automation/nvidia-egx-spreads-ai-cloud-edge (egx,edge-ai)
- https://min.io/ (s3,lambda)
- https://github.com/NVAITC/ai-lab (ai-lab,container)
- https://www.altoros.com/blog/kubeflow-automating-deployment-of-tensorflow-models-on-kubernetes/ (kubeflow)
