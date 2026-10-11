{ ... }:
{
  imports = [
    /etc/nixos/hardware-configuration.nix

    ../../modules/nixos/boot-kernel.nix
    ../../modules/nixos/linuwu-sense.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/networking-locale.nix
    ../../modules/nixos/users.nix
    ../../modules/nixos/nix-settings.nix
    ../../modules/nixos/services.nix
    ../../modules/nixos/programs.nix
    ../../modules/nixos/portals.nix
    ../../modules/nixos/fonts.nix
    ../../modules/nixos/root-app.nix
    ../../modules/nixos/acer-nitro-fan-control.nix
  ];

  system.stateVersion = "26.05";
}
