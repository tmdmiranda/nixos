{ pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "exfat" ];

  boot.blacklistedKernelModules = [ "acer_wmi" ];
  boot.kernelModules = [ "ec_sys" "linuwu_sense" ];
  boot.kernelPackages = pkgs.linuxPackages;

  boot.extraModprobeConfig = ''
    options ec_sys write_support=1
    options nvidia NVreg_InitializeSystemPointers=0
  '';

  boot.kernelParams = [ "nvidia-drm.modeset=1" ];
  boot.initrd.kernelModules = [ ];
}
