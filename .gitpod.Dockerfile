FROM gitpod/workspace-base

# Install Nix
ENV USER=gitpod
USER gitpod
RUN sudo sh -c 'mkdir -m 0755 /nix && chown gitpod /nix' \
  && touch .bash_profile \
  && curl https://nixos.org/releases/nix/nix-2.3.14/install | bash -s -- --no-daemon

RUN echo 'source $HOME/.nix-profile/etc/profile.d/nix.sh' >> /home/gitpod/.bashrc.d/998-nix \
  && mkdir -p $HOME/.config/nixpkgs && echo '{ allowUnfree = true; }' >> $HOME/.config/nixpkgs/config.nix \
  && . $HOME/.nix-profile/etc/profile.d/nix.sh \
  # Install cachix
  && nix-env -iA cachix -f https://cachix.org/api/v1/install \
  && cachix use cachix \
  # Install git, drenv
  && nix-env -iA nixpkgs.git nixpkgs.git-lfs nixpkgs.direnv \
  # nixos-generate
  && nix-env -f https://github.com/nix-community/nixos-generators/archive/master.tar.gz -i \
  && cd /tmp && curl -LO https://raw.githubusercontent.com/gitpod-io/template-nixos/main/configuration.nix \
  && nixos-generate -c ./configuration.nix -f vm-nogui -o ./dist \
  # Direnv config
  && mkdir -p $HOME/.config/direnv \
  && printf '%s\n' '[whitelist]' 'prefix = [ "/workspace"] ' >> $HOME/.config/direnv/config.toml \
  && printf '%s\n' 'source <(direnv hook bash)' >> $HOME/.bashrc.d/999-direnv

# Install qemu
RUN sudo install-packages qemu qemu-system-x86 linux-image-$(uname -r) libguestfs-tools sshpass netcat
