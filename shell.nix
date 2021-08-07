let 
  pkgs = import <nixpkgs> {};
  nixos-generators = import (builtins.fetchTarball https://github.com/nix-community/nixos-generators/archive/master.tar.gz);

in with pkgs;
mkShell {

  nativeBuildInputs = [
    direnv
    niv
    nixos-generators
  ];

  NIX_ENFORCE_PURITY = true;

  shellHook = ''
  '';
}
