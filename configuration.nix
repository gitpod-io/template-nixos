{ pkgs, ... }: {

  system.stateVersion = "22.11";

  networking.firewall.enable = false;

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

  # Mount host /workspace inside guest
  system.activationScripts.workspaceLogin = {
    text = ''
      mkdir -m 0755 -p /workspace
      chown -h gitpod:gitpod /workspace
      mount -t 9p -o trans=virtio,version=9p2000.L,rw host0 /workspace
    '';
  };

  environment.etc."prompt_command".text = ''
    if test $stty_times -gt 3; then {
      PROMPT_COMMAND="$(sed "s|reset||" <<<"$PROMPT_COMMAND")"
    } fi
    stty_times=$((stty_times+1))
    (old="$(stty -g)";stty raw -echo min 0 time 5;printf '\0337\033[r\033[999;999H\033[6n\0338'>/dev/tty; IFS='[;R' read -r _ rows cols _ < /dev/tty;stty "$old";stty cols "$cols" rows "$rows") >/dev/null 2>&1
  '';

  environment.shellInit = ''
    stty_times=1
    alias reset="source /etc/prompt_command"
    PROMPT_COMMAND='reset'
  '';

  # Auto cd to $GITPOD_REPO_ROOT inside guest
  environment.extraInit = ''
      source /workspace/.shellhook
  '';

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
