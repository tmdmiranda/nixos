{ inputs, pkgs, ... }:
{
  # Same flake you used in /etc via builtins.getFlake, now a proper locked input:
  # "github:sadjow/codex-cli-nix" — native Rust binary, hourly updates.
  # Pull latest with: nix flake update codex-cli-nix
  home.packages = [
    inputs.codex-cli-nix.packages.${pkgs.system}.default
  ];
}
