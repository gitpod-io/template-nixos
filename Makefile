# Default shell
SHELL := bash


default: all

# Help message
help:
	@echo "NixOS Project Template"
	@echo
	@echo "Target rules:"
	@echo "    all      - Compiles and generates the iso"
	@echo "    start    - Boots the iso into a virtual machine"
	@echo "    clean    - Clean the project by removing the iso"
	@echo "    help     - Prints a help message with target rules"

# Default rule
all:
	nixos-generate -c ./configuration.nix -f vm-nogui -o ./dist

# Boots the iso into a virtual machine
start: all
	printf 'cd "%s"\n' "$(GITPOD_REPO_ROOT)" > /workspace/.shellhook
	sudo -E ./dist/bin/run-nixos-vm \
		-m 8G -device virtio-balloon-pci \
		-smp 8 \
		-accel tcg \
		-nic user,hostfwd=tcp::8000-:8000,hostfwd=tcp::2222-:22 \
		-virtfs local,path=/workspace,mount_tag=host0,security_model=none,id=fs0 \

ssh:
	while ! nc -z 127.0.0.1 2222; do sleep 0.1; done
	sshpass  -p 'gitpod' ssh -o StrictHostKeychecking=no -p 2222 gitpod@127.0.0.1

# Clean the project by removing the iso
clean:
	rm -rf *.iso
