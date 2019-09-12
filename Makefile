.DEFAULT_GOAL := help
SHELL := /bin/bash


help: ## This help panel.
	@IFS=$$'\n' ; \
	help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##/:/'`); \
	printf "%-30s %s\n" "DevOps console for Project Jetson" ; \
	printf "%-30s %s\n" "==================================" ; \
	printf "%-30s %s\n" "" ; \
	printf "%-30s %s\n" "Target" "Help" ; \
	printf "%-30s %s\n" "------" "----" ; \
	for help_line in $${help_lines[@]}; do \
        IFS=$$':' ; \
        help_split=($$help_line) ; \
        help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
        help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
        printf '\033[36m'; \
        printf "%-30s %s" $$help_command ; \
        printf '\033[0m'; \
        printf "%s\n" $$help_info; \
    done

%:      # thanks to chakrit
	@:    # thanks to Wi.lliam Pursell


bootstrap-environment: requirements bootstrap-environment-message ## Bootstrap development environment!

bootstrap-environment-message: ## Echo a message that Docker preferences need to be updated
	@echo ""
	@echo ""
	@echo "Welcome!"
	@echo ""
	@echo "1) Please follow the instructions to fully install and start Docker - Docker started up when its Icon ("the whale") is no longer moving."
	@echo ""
	@echo "2) Click on the Docker icon, goto Preferences / Advanced, set Memory to at least 4GiB and click Apply & Restart."
	@echo ""
	@echo ""

requirements: requirements-bootstrap requirements-ansible-galaxy requirements-packages requirements-hosts requirements-docker ## Install requirements on workstation

requirements-bootstrap: ## Bootstrap Homebrew, Ruby and Ansible
	workflow/requirements/macOS/bootstrap
	source ~/.bash_profile && rbenv install --skip-existing 2.2.

requirements-packages: ## Install packages and applications
	source ~/.bash_profile && ansible-playbook -i "localhost," workflow/requirements/macOS/ansible/playbook.yml --ask-become-pass

requirements-ansible-galaxy: ## Install ansible modules for development environment, guest VM and provisioning
	source ~/.bash_profile && ansible-galaxy install -r workflow/requirements/macOS/ansible/requirements.yml
	source ~/.bash_profile && ansible-galaxy install -r workflow/guest/requirements.yml
	source ~/.bash_profile && ansible-galaxy install -r workflow/provision/requirements.yml

requirements-hosts: ## Update /etc/hosts on workstation
	source ~/.bash_profile && ansible-playbook -i "localhost," workflow/requirements/generic/ansible/playbook.yml --tags "hosts" --ask-become-pass

requirements-docker: ## Prepare Docker on workstation
	source ~/.bash_profile && $(SHELL) -c 'cd workflow/requirements/macOS/docker; . ./daemon_check'

requirements-ansible: ## Install ansible requirements on workstation for provisioning jetson device and guest operating system
	source ~/.bash_profile && ansible-galaxy install -r workflow/provision/requirements.yml
	source ~/.bash_profile && ansible-galaxy install -r workflow/guest/requirements.yml


guest-sdk-manager-download: ## Download NVIDIA SDK Manager to workflow/guest/downloads/ **before** provisioning guest VM
	@echo "Download SDK manager after login in the browser window I opened for you and save the .deb file in workflow/guest/downloads/ ..."
	@echo "You might have to update sdk_manager.deb_filename in workflow/guest/group_vars/all.yml if a newer version is published by NVIDIA."
	python -mwebbrowser https://developer.nvidia.com/nvidia-sdk-manager

guest-build: guest-up guest-download # Build custom kernel, modules and rootfs for Xavier on guest VM - boots and provisions guest VM automatically before executing build and triggers download of CUDA packages
	cd workflow/guest && ansible-playbook -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory build-and-flash.yml --tags "build"

guest-flash: guest-up # Flash custom kernel, modules and rootfs from guest VM to Xavier - preconditions: Xavier in recovery mode, connected to host via USB, USB device filter activated in guest VM
	cd workflow/guest && ansible-playbook -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory build-and-flash.yml --tags "flash"

guest-oem-setup: guest-up # Trigger oem-setup on xavier by dialing out to Xavier - preconditions: Xavier reset after flash, connected to host via USB, USB device filter activated in guest VM
	VAGRANT_CWD=workflow/guest vagrant ssh -- -t 'xavier-dialout'


guest-up: ## Boot guest VM with Ubuntu Bionic as required for executing Xavier SDK manager on workstation and cross-compiling L4T Kernel. Automatically triggers provisioning on **first** boot.
	VAGRANT_CWD=workflow/guest vagrant up

guest-download: guest-up # Download SDK components via SDK manager
	cd workflow/guest && ansible-playbook -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory download.yml --tags "download"

guest-ssh: # SSH into guest VN
	VAGRANT_CWD=workflow/guest vagrant ssh

guest-host-usb-list: ## List usb devices on host
	vboxmanage list usbhost

guest-provision: ## (Re)provision guest VM **after** first boot by installing basics, Ubunutu Desktop, SDK Manager, Linux for Tegra, kernel sources and Linaro toolchain for aarch64 cross-compiling
	VAGRANT_CWD=workflow/guest vagrant provision

guest-reload: ## Reload guest VM after configuration change in workflow/guest/vagrantfile
	VAGRANT_CWD=workflow/guest vagrant reload

guest-halt: ## Halt guest VM
	VAGRANT_CWD=workflow/guest vagrant halt

guest-destroy: ## Destroy guest VM
	VAGRANT_CWD=workflow/guest vagrant destroy --force


nano-image-download: ## Download NVIDIA Jetpack into workflow/provision/image
	cd workflow/provision/image && wget -N -O jetson-nano-sd.zip https://developer.nvidia.com/jetson-nano-sd-card-image-r322 && unzip -o *.zip && rm -f jetson-nano-sd.zip


setup-access-secure: ## Allow passwordless ssh and sudo, disallow ssh with password - you will have to enter the password you set for user "provisison" twice per node
	ssh-copy-id -i ~/.ssh/id_rsa provision@nano-one.local || true
	ssh-copy-id -i ~/.ssh/id_rsa provision@xavier-one.local || true
	cd workflow/provision && ansible-playbook main.yml --tags "access_secure" -b -K


provision: ## Provision the Nvidia Jetson Nanos and Xaviers
	cd workflow/provision && ansible-playbook main.yml --tags "provision"

provision-nanos: ## Provision the Nvidia Jetson Nanos
	cd workflow/provision && ansible-playbook main.yml --tags "provision" -l "nanos"

provision-xaviers: ## Provision the Nvidia Jetson Xaviers
	cd workflow/provision && ansible-playbook main.yml --tags "provision" -l "xaviers"

provision-base: ## Provision base on Jetson Nanos and Xaviers
	cd workflow/provision && ansible-playbook main.yml --tags "base"

provision-kernel: ## Compile custom kernel for Docker and Kubernetes on Jetson Nanos - takes ca. 60 minutes
	cd workflow/provision && ansible-playbook main.yml --tags "kernel"

provision-sdk-components-install: ## Install SDK components
	cd workflow/provision && ansible-playbook main.yml --tags "sdk_components_install"

provision-firewall: ## Provision firewall on Jetson Nanos and Xaviers
	cd workflow/provision && ansible-playbook main.yml --tags "firewall"

provision-lxde: ## Provision LXDE on Jetson Nanos and Xaviers
	cd workflow/provision && ansible-playbook main.yml --tags "lxde"

provision-vnc: ## Provision VNC on Jetson Nanos and Xaviers
	cd workflow/provision && ansible-playbook main.yml --tags "vnc"

provision-xrdp: ## Provision XRDP on Jetson Nanos and Xaviers
	cd workflow/provision && ansible-playbook main.yml --tags "xrdp"

provision-nvme-ssd-integrate: ## DANGER: (re)partitions M2/NVME SSD, (re)mounts, (re)synchs and (re)links if SSD not already providing /var/lib/docker on Jetson Xaviers
	cd workflow/provision && ansible-playbook main.yml --tags "nvme_ssd_integrate"

provision-k8s: ## Provision Kubernetes on Jetson Nanos and Xaviers
	cd workflow/provision && ansible-playbook main.yml --tags "k8s"

provision-build: ## Provision build environment on Jetson Nanos and Xaviers
	cd workflow/provision && ansible-playbook main.yml --tags "build"

provision-cuda-ml-repo: ## Repack CUDA ml libraries into CUDA ml repo residing in /var/local/cuda-ml-local-repo
	cd workflow/provision && ansible-playbook main.yml --tags "cuda_ml_repo"

provision-swap: ## Provision swap on Jetson Nanos
	cd workflow/provision && ansible-playbook main.yml --tags "swap"

provision-performance-mode: ## Set performace mode on Jetson Nanos
	cd workflow/provision && ansible-playbook main.yml --tags "performance_mode"

provision-test: ## Install tools for testing on Jetson Nanos and Xaviers
	cd workflow/provision && ansible-playbook main.yml --tags "test"

provision-sdk-components-sync: ## Sync SDK components from workflow/guest/downloads to Xavier devices
	cd workflow/provision && ansible-playbook main.yml --tags "sdk_components_sync"


nano-one-ssh: ## ssh to nano-one as user provision
	ssh provision@nano-one.local

nano-one-ssh-build: ## ssh to nano-one as user build
	ssh build@nano-one.local

nano-one-reboot: ## reboot nano-one
	ssh build@nano-one.local "sudo shutdown -r now"

nano-one-exec: ## exec command on nano-one - you must pass in arguments e.g. tegrastats
	ssh build@nano-one.local $(filter-out $@,$(MAKECMDGOALS))


nano-one-ssd-id-serial-short-show: ## Show short serial id of /dev/sda assuming the USB3/SSD is the only block device connected to the nano via USB
	ssh provision@nano-one.local "udevadm info /dev/sda | grep ID_SERIAL_SHORT"

nano-one-ssd-prepare: ## DANGER: Assign stable device name to USB3/SSD, reboot, wipe SSD, create boot partition, create ext4 filesystem
	cd workflow/provision && ansible-playbook main.yml --tags "sata_ssd_prepare"

nano-one-ssd-uuid-show: ## Show UUID of /dev/ssd1
	ssh provision@nano-one.local "udevadm info /dev/ssd1 | grep ID_FS_UUID_ENC"

nano-one-ssd-activate: ## DANGER: Update the boot menu to include the USB3/SSD as default boot device and reboot
	cd workflow/provision && ansible-playbook main.yml --tags "sata_ssd_activate"


xavier-one-ssh: ## ssh to xavier-one as user provision
	ssh provision@xavier-one.local

xavier-one-ssh-build: ## ssh to xavier-one as user build
	ssh build@xavier-one.local

xavier-one-reboot: ## reboot xavier-one
	ssh build@xavier-one.local "sudo shutdown -r now"

xavier-one-exec: ## exec command on xavier-one - you must pass in arguments e.g. tegrastats
	ssh build@xavier-one.local $(filter-out $@,$(MAKECMDGOALS))


k8s-proxy: ## Open proxy
	kubectl proxy

k8s-dashboard-bearer-token-show: ## Show dashboard bearer token
	workflow/k8s/dashboard-bearer-token-show

k8s-dashboard-open: ## Open Dashboard
	python -mwebbrowser http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/overview?namespace=default


ml-base-build-and-test: ## Build, push and test ml base image for Docker on Jetson device with cuda and tensorflow
	cd workflow/deploy/ml-base && skaffold build
	workflow/deploy/tools/container-structure-test ml-base

ml-base-publish: ## Publish latest ml base image on Jetson device to Docker Hub given credentials in .docker-hub.auth
	workflow/deploy/tools/publish ml-base $(shell sed '1q;d' .docker-hub.auth)  $(shell sed '2q;d' .docker-hub.auth) $(filter-out $@,$(MAKECMDGOALS))


device-query-build-and-test: ## Build and test device-query
	cd workflow/deploy/device-query && skaffold build
	workflow/deploy/tools/container-structure-test device-query

device-query-deploy: ## Build and deploy device-query
	kubectl create namespace jetson-device-query || true
	cd workflow/deploy/device-query && skaffold run

device-query-deploy-docker-hub-parent: ## Build and deploy device-query, pull ml-base image from Docker Hub
	kubectl create namespace jetson-device-query || true
	cd workflow/deploy/device-query && skaffold run -p parent-docker-hub

device-query-deploy-docker-hub: ## Deploy device-query, pull image from Docker Hub
	kubectl create namespace jetson-device-query || true
	cd workflow/deploy/device-query && skaffold run -p docker-hub

device-query-log-show: ## Show log of pod device-query
	workflow/deploy/tools/log-show device-query

device-query-dev: ## Enter build, deploy, tail, watch cycle for device-query
	kubectl create namespace jetson-device-query || true
	cd workflow/deploy/device-query && skaffold dev

device-query-dev-docker-hub-parent: ## Enter build, deploy, tail, watch cycle for device-query, pull ml-base image from Docker Hub
	kubectl create namespace jetson-device-query || true
	cd workflow/deploy/device-query && skaffold dev -p docker-hub-parent

device-query-publish: ## Publish latest device query image on Jetson device to Docker Hub given credentials in .docker-hub.auth
	workflow/deploy/tools/publish device-query $(shell sed '1q;d' .docker-hub.auth)  $(shell sed '2q;d' .docker-hub.auth) $(filter-out $@,$(MAKECMDGOALS))

device-query-delete: ## Delete device query deployment
	cd workflow/deploy/device-query && skaffold delete
	kubectl delete namespace jetson-device-query || true


jupyter-build-and-test: ## Build and test jupyter
	cd workflow/deploy/jupyter && skaffold build
	workflow/deploy/tools/container-structure-test jupyter

jupyter-deploy: ## Build and deploy jupyter
	kubectl create namespace jetson-jupyter || true
	kubectl create secret generic jupyter.polarize.ai --from-file workflow/deploy/jupyter/.basic-auth --namespace=jetson-jupyter || true
	cd workflow/deploy/jupyter && skaffold run

jupyter-deploy-docker-hub-parent: ## Build and deploy jupyter, pull ml-base image from Docker Hub
	kubectl create namespace jetson-jupyter || true
	cd workflow/deploy/jupyter && skaffold run -p parent-docker-hub

jupyter-deploy-docker-hub: ## Deploy jupyter, pull image from Docker Hub
	kubectl create namespace jetson-jupyter || true
	cd workflow/deploy/jupyter && skaffold run -p docker-hub

jupyter-open: ## Open browser pointing to jupyter notebook
	python -mwebbrowser http://jupyter.local/notebooks/tutorials/_index.ipynb

jupyter-log-show: ## Show log of pod
	workflow/deploy/tools/log-show jupyter

jupyter-dev: ## Enter build, deploy, tail, watch cycle for jupyter
	kubectl create namespace jetson-jupyter || true
	kubectl create secret generic jupyter.polarize.ai --from-file workflow/deploy/jupyter/.basic-auth --namespace=jetson-jupyter || true
	cd workflow/deploy/jupyter && skaffold dev

jupyter-dev-docker-hub-parent: ## Enter build, deploy, tail, watch cycle for jupyter, pull ml-base image from Docker Hub
	kubectl create namespace jupyter-query || true
	cd workflow/deploy/jupyter && skaffold dev -p docker-hub-parent

jupyter-publish: ## Publish latest jupyter image on Jetson device to Docker Hub given credentials in .docker-hub.auth
	workflow/deploy/tools/publish jupyter $(shell sed '1q;d' .docker-hub.auth)  $(shell sed '2q;d' .docker-hub.auth) $(filter-out $@,$(MAKECMDGOALS))

jupyter-delete: ## Delete jupyter deployment
	cd workflow/deploy/jupyter && skaffold delete
	kubectl delete namespace jetson-jupyter || true



tensorflow-serving-base-build-and-test: ## Build, push and test ml tensorflow-serving image for Docker on Jetson device extending ml-base with TensorFlow *Serving*
	cd workflow/deploy/tensorflow-serving-base && skaffold build
	workflow/deploy/tools/container-structure-test tensorflow-serving-base

tensorflow-serving-base-publish: ## Publish latest tensorflow-serving base image on Jetson device to Docker Hub given credentials in .docker-hub.auth
	workflow/deploy/tools/publish tensorflow-serving-base $(shell sed '1q;d' .docker-hub.auth)  $(shell sed '2q;d' .docker-hub.auth) $(filter-out $@,$(MAKECMDGOALS))



tensorflow-serving-build-and-test: ## Build and test tensorflow-serving
	cd workflow/deploy/tensorflow-serving && skaffold build
	workflow/deploy/tools/container-structure-test tensorflow-serving

tensorflow-serving-deploy: ## Build and deploy tensorflow-serving
	kubectl create namespace jetson-tensorflow-serving || true
	kubectl create secret generic tensorflow-serving.polarize.ai --from-file workflow/deploy/tensorflow-serving/.basic-auth --namespace=jetson-tensorflow-serving || true
	cd workflow/deploy/tensorflow-serving && skaffold run

tensorflow-serving-deploy-docker-hub-parent: ## Build and deploy tensorflow-serving, pull ml-base image from Docker Hub
	kubectl create namespace jetson-jupyter || true
	cd workflow/deploy/tensorflow-serving && skaffold run -p parent-docker-hub

tensorflow-serving-deploy-docker-hub: ## Deploy tensorflow-serving, pull image from Docker Hub
	kubectl create namespace jetson-jupyter || true
	cd workflow/deploy/tensorflow-serving && skaffold run -p docker-hub

tensorflow-serving-health-check: ## Check health
	@echo "Checking health via Webservice API ..."
	@curl http://tensorflow-serving.local/api/v1/health/healthz
	@echo ""

tensorflow-serving-docs-open: ## Open browser tabs showing API documentation of the webservice
	@echo "Opening OpenAPI documentation of Webservice API ..."
	python -mwebbrowser http://tensorflow-serving.local/docs
	python -mwebbrowser http://tensorflow-serving.local/redoc
	@curl http://tensorflow-serving.local/api/v1/openapi.json
	@echo ""

tensorflow-serving-predict: ## Send prediction REST and webservice requests
	@echo "Predicting via TFS REST API ..."
	@curl -d '{"instances": [1.0, 2.0, 5.0, 10.0]}' -X POST http://tensorflow-serving.local:8501/v1/models/half_plus_two:predict
	@echo ""
	@echo "Predicting via Webservice API accessing REST endpoint of TFS ..."
	@curl -d '{"instances": [1.0, 2.0, 5.0, 10.0]}' -X POST http://tensorflow-serving.local/api/v1/prediction/predict
	@echo ""
	@echo "Predicting via Webservice API accessing gRPC endpoint of TFS ..."
	@curl -d '{"instances": [1.0, 2.0, 5.0, 10.0]}' -X POST http://tensorflow-serving.local/api/v1/prediction/grpc/predict
	@echo ""

tensorflow-serving-log-show: ## Show log of pod
	workflow/deploy/tools/log-show tensorflow-serving

tensorflow-serving-dev: ## Enter build, deploy, tail, watch cycle for tensorflow-serving
	kubectl create namespace jetson-tensorflow-serving || true
	kubectl create secret generic tensorflow-serving.polarize.ai --from-file workflow/deploy/tensorflow-serving/.basic-auth --namespace=jetson-tensorflow-serving || true
	cd workflow/deploy/tensorflow-serving && skaffold dev

tensorflow-serving-dev-docker-hub-parent: ## Enter build, deploy, tail, watch cycle for tensorflow-serving, pull ml-base image from Docker Hub
	kubectl create namespace jupyter-tensorflow-serving || true
	cd workflow/deploy/jupyter && skaffold dev -p docker-hub-parent

tensorflow-serving-publish: ## Publish latest tensorflow-serving image on Jetson device to Docker Hub given credentials in .docker-hub.auth
	workflow/deploy/tools/publish tensorflow-serving $(shell sed '1q;d' .docker-hub.auth)  $(shell sed '2q;d' .docker-hub.auth) $(filter-out $@,$(MAKECMDGOALS))

tensorflow-serving-delete: ## Delete tensorflow-serving deployment
	cd workflow/deploy/tensorflow-serving && skaffold delete
	kubectl delete namespace jetson-tensorflow-serving || true


l4t-build-and-test: ## Cross-build l4t on macOS and test on Jetson device
	cd workflow/deploy/l4t && skaffold build
	workflow/deploy/l4t/container-structure-test.mac l4t

l4t-deploy: ## Cross-build l4t on macOS and deploy
	kubectl create namespace jetson-l4t || true
	cd workflow/deploy/l4t && skaffold run

l4t-open: ## Open browser pointing to l4t notebook
	python -mwebbrowser http://l4t.local/

l4t-log-show: ## Show log of pod
	workflow/deploy/tools/log-show l4t

l4t-dev: ## Enter cross-build, deploy, tail, watch cycle for l4t
	kubectl create namespace jetson-l4t || true
	cd workflow/deploy/l4t && skaffold dev

l4t-publish: ## Publish latest lt4 image on Jetson device to Docker Hub given credentials in .docker-hub.auth
	workflow/deploy/tools/publish l4t $(shell sed '1q;d' .docker-hub.auth) $(shell sed '2q;d' .docker-hub.auth) $(filter-out $@,$(MAKECMDGOALS))

l4t-delete: ## Delete l4t deployment
	cd workflow/deploy/l4t && skaffold delete
	kubectl delete namespace jetson-l4t || true

publish-all: ## Publish all images to DockerHub
	JETSON_MODEL=nano make ml-base-publish $(filter-out $@,$(MAKECMDGOALS))
	JETSON_MODEL=nano make device-query-publish $(filter-out $@,$(MAKECMDGOALS))
	JETSON_MODEL=nano make jupyter-publish $(filter-out $@,$(MAKECMDGOALS))
	JETSON_MODEL=nano make tensorflow-serving-base-publish $(filter-out $@,$(MAKECMDGOALS))
	JETSON_MODEL=nano make tensorflow-serving-publish $(filter-out $@,$(MAKECMDGOALS))
	JETSON_MODEL=xavier make ml-base-publish $(filter-out $@,$(MAKECMDGOALS))
	JETSON_MODEL=xavier make device-query-publish $(filter-out $@,$(MAKECMDGOALS))
	JETSON_MODEL=xavier make jupyter-publish $(filter-out $@,$(MAKECMDGOALS))
	JETSON_MODEL=xavier make tensorflow-serving-base-publish $(filter-out $@,$(MAKECMDGOALS))
	JETSON_MODEL=xavier make tensorflow-serving-publish $(filter-out $@,$(MAKECMDGOALS))
