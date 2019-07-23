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

requirements: requirements-bootstrap ## Install requirements on workstation

requirements-bootstrap: ## Prepare basic packages on workstation
	workflow/requirements/macOS/bootstrap
	source ~/.bash_profile && rbenv install --skip-existing 2.2.
	source ~/.bash_profile && ansible-galaxy install -r workflow/requirements/macOS/ansible/requirements.yml
	ansible-playbook -i "localhost," workflow/requirements/generic/ansible/playbook.yml --tags "hosts" --ask-become-pass
	source ~/.bash_profile && ansible-playbook -i "localhost," workflow/requirements/macOS/ansible/playbook.yml --ask-become-pass
	source ~/.bash_profile && $(SHELL) -c 'cd workflow/requirements/macOS/docker; . ./daemon_check.sh'

requirements-docker: ## Prepare Docker on workstation
	source ~/.bash_profile && $(SHELL) -c 'cd workflow/requirements/macOS/docker; . ./daemon_check.sh'

requirements-hosts: ## Prepare /etc/hosts on workstation
	ansible-playbook -i "localhost," workflow/requirements/generic/ansible/playbook.yml --tags "hosts" --ask-become-pass

requirements-packages: ## Install packages on workstation
	ansible-playbook -i "localhost," workflow/requirements/macOS/ansible/playbook.yml --ask-become-pass

requirements-ansible: ## Install ansible requirements on workstation for provisioning jetson
	ansible-galaxy install -r workflow/provision/requirements.yml

bootstrap-environment-message: ## Echo a message that the app installation is happening now
	@echo ""
	@echo ""
	@echo "Welcome!"
	@echo ""
	@echo "1) Please follow the instructions to fully install and start Docker - Docker started up when its Icon ("the whale") is no longer moving."
	@echo ""
	@echo "2) Click on the Docker icon, goto Preferences / Advanced, set Memory to at least 4GiB and click Apply & Restart."
	@echo ""
	@echo ""


image-download: ## Download Nvidia Jetpack into workflow/provision/image
	cd workflow/provision/image && wget -N -O jetson-nano-sd.zip https://developer.nvidia.com/jetson-nano-sd-card-image-r322 && unzip -o *.zip && rm -f jetson-nano-sd.zip

setup-access-secure: ## Allow passwordless ssh and sudo, disallow ssh with password
	ssh-copy-id -i ~/.ssh/id_rsa provision@nano-one.local
	cd workflow/provision && ansible-playbook main.yml --tags "access_secure" -b -K


provision: ## Provision the Nvidia Jetson Nano
	cd workflow/provision && ansible-playbook main.yml --tags "provision"

provision-base: ## Provision base
	cd workflow/provision && ansible-playbook main.yml --tags "base"

provision-kernel: ## Compile custom kernel for docker - takes ca. 60 minutes
	cd workflow/provision && ansible-playbook main.yml --tags "kernel"

provision-firewall: ## Provision firewall
	cd workflow/provision && ansible-playbook main.yml --tags "firewall"

provision-lxde: ## Provision LXDE
	cd workflow/provision && ansible-playbook main.yml --tags "lxde"

provision-vnc: ## Provision VNC
	cd workflow/provision && ansible-playbook main.yml --tags "vnc"

provision-xrdp: ## Provision XRDP
	cd workflow/provision && ansible-playbook main.yml --tags "xrdp"

provision-k8s: ## Provision Kubernetes
	cd workflow/provision && ansible-playbook main.yml --tags "k8s"

provision-build: ## Provision build environment
	cd workflow/provision && ansible-playbook main.yml --tags "build"

provision-swap: ## Provision swap
	cd workflow/provision && ansible-playbook main.yml --tags "swap"

provision-performance-mode: ## Set performace mode
	cd workflow/provision && ansible-playbook main.yml --tags "performance_mode"


nano-one-ssh: ## ssh to nano-one as user provision
	ssh provision@nano-one.local

nano-one-ssh-build: ## ssh to nano-one as user build
	ssh build@nano-one.local

nano-one-reboot: ## reboot nano-one
	ssh build@nano-one.local "sudo shutdown -r now"

nano-one-exec: ## exec command on nano-one - you must pass in arguments e.g. tegrastats
	ssh build@nano-one.local $(filter-out $@,$(MAKECMDGOALS))

nano-one-cuda-ml-deb-repack: ## Repack libcudnn and TensorRT libraries inc. python bindings on nano and create local repository
	workflow/deploy/tools/nano-cuda-ml-deb-repack


nano-one-ssd-id-serial-short-show: ## Show short serial id of /dev/sda assuming the SSD is the only block device connected to the nano via USB
	ssh provision@nano-one.local "udevadm info /dev/sda | grep ID_SERIAL_SHORT"

nano-one-ssd-prepare: ## DANGER: Assign stable device name to SSD, reboot, wipe SSD, create boot partition, create ext4 filesystem
	cd workflow/provision && ansible-playbook main.yml --tags "ssd_prepare"

nano-one-ssd-uuid-show: ## Show UUID of /dev/ssd1
	ssh provision@nano-one.local "udevadm info /dev/ssd1 | grep ID_FS_UUID_ENC"

nano-one-ssd-activate: ## DANGER: Update the boot menu to include the SSD as default boot device and reboot
	cd workflow/provision && ansible-playbook main.yml --tags "ssd_activate"


k8s-proxy: ## Open proxy
	kubectl proxy

k8s-dashboard-bearer-token-show: ## Show dashboard bearer token
	workflow/k8s/dashboard-bearer-token-show

k8s-dashboard-open: ## Open Dashboard
	python -mwebbrowser http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/overview?namespace=default

k8s-token-create: ## Create token to join cluster
	ssh root@max-one.local kubeadm token create


ml-base-build-and-push: ## Build and push ml base image for Docker on nano with cuda and tensorflow
	cd workflow/deploy/ml-base && skaffold build


device-query-deploy: ## Build and deploy device query
	kubectl create namespace jetson-device-query || true
	cd workflow/deploy/device-query && skaffold run

device-query-log-show: ## Show log of pod
	workflow/deploy/tools/log-show device-query

device-query-dev: ## Enter build, deploy, tail, watch cycle for device query
	kubectl create namespace jetson-device-query || true
	cd workflow/deploy/device-query && skaffold dev

device-query-delete: ## Delete device query deployment
	cd workflow/deploy/device-query && skaffold delete
	kubectl delete namespace jetson-device-query || true


jupyter-deploy: ## Build and deploy jupyter
	kubectl create namespace jetson-jupyter || true
	kubectl create secret generic jupyter.polarize.ai --from-file workflow/deploy/jupyter/.basic-auth --namespace=jetson-jupyter || true
	cd workflow/deploy/jupyter && skaffold run

jupyter-open: ## Open browser pointing to jupyter notebook
	python -mwebbrowser http://jupyter.nano-one.local/

jupyter-log-show: ## Show log of pod
	workflow/deploy/tools/log-show jupyter

jupyter-dev: ## Enter build, deploy, tail, watch cycle for jupyter
	kubectl create namespace jetson-jupyter || true
	kubectl create secret generic jupyter.polarize.ai --from-file workflow/deploy/jupyter/.basic-auth --namespace=jetson-jupyter || true
	cd workflow/deploy/jupyter && skaffold dev

jupyter-delete: ## Delete jupyter deployment
	cd workflow/deploy/jupyter && skaffold delete
	kubectl delete namespace jetson-jupyter || true


tensorflow-serving-deploy: ## Build and deploy tensorflow-serving
	kubectl create namespace jetson-tensorflow-serving || true
	kubectl create secret generic tensorflow-serving.polarize.ai --from-file workflow/deploy/tensorflow-serving/.basic-auth --namespace=jetson-tensorflow-serving || true
	cd workflow/deploy/tensorflow-serving && skaffold run

tensorflow-serving-open: ## Open browser pointing to tensorflow-serving notebook
	python -mwebbrowser http://tensorflow-serving.nano-one.local/

tensorflow-serving-log-show: ## Show log of pod
	workflow/deploy/tools/log-show tensorflow-serving

tensorflow-serving-dev: ## Enter build, deploy, tail, watch cycle for tensorflow-serving
	kubectl create namespace jetson-tensorflow-serving || true
	kubectl create secret generic tensorflow-serving.polarize.ai --from-file workflow/deploy/tensorflow-serving/.basic-auth --namespace=jetson-tensorflow-serving || true
	cd workflow/deploy/tensorflow-serving && skaffold dev

tensorflow-serving-delete: ## Delete tensorflow-serving deployment
	cd workflow/deploy/tensorflow-serving && skaffold delete
	kubectl delete namespace jetson-tensorflow-serving || true


l4t-deploy: ## Cross-build l4t on macOS and deploy
	kubectl create namespace jetson-l4t || true
	cd workflow/deploy/l4t && skaffold run

l4t-open: ## Open browser pointing to l4t notebook
	python -mwebbrowser http://l4t.nano-one.local/

l4t-log-show: ## Show log of pod
	workflow/deploy/tools/log-show l4t

l4t-dev: ## Enter cross-build, deploy, tail, watch cycle for l4t
	kubectl create namespace jetson-l4t || true
	cd workflow/deploy/l4t && skaffold dev

l4t-delete: ## Delete l4t deployment
	cd workflow/deploy/l4t && skaffold delete
	kubectl delete namespace jetson-l4t || true
