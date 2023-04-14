{ pkgs, ... }: {

  system.stateVersion = "22.11";

  networking.firewall.enable = false;
  # config.networking.nftables.enable =  false;

  # Not rootless
  virtualisation.docker = {
    enable = true;
    # setSocketVariable = true;
  };

  # SSH server
  services.openssh = {
    openFirewall = true;
    enable = true;
    listenAddresses = [{
      addr = "0.0.0.0";
      port = 22;
    }];
    settings.PasswordAuthentication = true;
  };

  # Get package names from https://search.nixos.org/packages
  # These system packages will be installed
  environment.systemPackages = with pkgs; [
    curl
    gitAndTools.gitFull
    htop
    sudo
    tmux
    vim
    python3
  ];

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  users = {
    groups.gitpod = {
      gid = 33333;
      members = [ "gitpod" ];
    };

    users = {
      root.password = "root";
      gitpod = {
          extraGroups = [ "gitpod" "wheel" ];
          uid = 33333;
          group = "gitpod";
          isNormalUser = true;
          password = "gitpod";
        };
    };

  };

  # Auto console login
  services.getty.autologinUser = "gitpod";

  # Auto cd to $GITPOD_REPO_ROOT inside guest
  # Mount host /workspace inside guest
  system.activationScripts.workspaceLogin = {
    text = ''
      string="source /workspace/.shellhook"
      for home in /home/gitpod /root; do
        file="$home/.bash_profile"
        if ! grep -q "$string" "$file" 2>/dev/null; then
          echo "$string" >> "$file"
        fi
      done
      mkdir -m 0755 -p /workspace
      chown -h gitpod:gitpod /workspace
      mount -t 9p -o trans=virtio,version=9p2000.L,rw host0 /workspace
    '';
  };

  # Mount host /workspace inside guest
  # systemd.mounts = [
  #   {
  #     what = "host0";
  #     where = "/workspace";
  #     type = "9p";
  #     options = "trans=virtio,version=9p2000.L,rw";
  #     wantedBy = [ "multi-user.target" ];
  #     after = [ "getty.target" ];
  #   }
  # ];

  # system.build.toplevelActivation = "root";

}
