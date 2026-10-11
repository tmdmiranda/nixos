{ inputs, pkgs, ... }:
{
  home.packages = [
    inputs.codex-cli-nix.packages.${pkgs.system}.default
  ];
}
