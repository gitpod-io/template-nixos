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
	nix-shell --command 'nixos-generate -c ./configuration.nix -f vm-nogui -o ./dist'

# Boots the iso into a virtual machine
start: all
	sudo ./dist/bin/run-nixos-vm \
		-m 4096M \
		-smp 8 \
		-nic user,hostfwd=tcp::2222-:22 \

ssh:
	while ! nc -z 127.0.0.1 2222; do sleep 0.1; done
	sshpass  -p 'password' ssh -o StrictHostKeychecking=no -p 2222 nixos@127.0.0.1				

# Clean the project by removing the iso
clean:
	rm -rf *.iso
