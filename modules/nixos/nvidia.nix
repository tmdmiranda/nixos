{ pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;

    powerManagement = {
      enable = false;
      finegrained = true;
    };

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      amdgpuBusId = "PCI:116:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Verified-working dcn_3_1_5_dmcub.bin from the 2024-09-09 linux-firmware release.
  # Keep hash pinned; do not "update" casually.
  hardware.firmware = [
    (pkgs.runCommand "amdgpu-dmcub-override" {
      nativeBuildInputs = [ pkgs.zstd ];
    } ''
      mkdir -p $out/lib/firmware/amdgpu

      cp ${pkgs.fetchurl {
        url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/amdgpu/dcn_3_1_5_dmcub.bin?h=20240909";
        hash = "sha256-Nn55+8stpyYhIoEFvtslUOAT3P/mv0/S17YsAFLhCBA=";
      }} $out/lib/firmware/amdgpu/dcn_3_1_5_dmcub.bin

      cp $out/lib/firmware/amdgpu/dcn_3_1_5_dmcub.bin $out/lib/firmware/amdgpu/yellow_carp_dmcub.bin

      zstd -k $out/lib/firmware/amdgpu/dcn_3_1_5_dmcub.bin
      zstd -k $out/lib/firmware/amdgpu/yellow_carp_dmcub.bin
    '')
  ];

  hardware.nvidia-container-toolkit.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General.Experimental = true;
      Policy.AutoEnable = true;
    };
  };
}
