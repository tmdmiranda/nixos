{ pkgs, ... }:
{
  services.pulseaudio.enable = false;
  services.blueman.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      AllowTcpForwarding = true;
    };
  };
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.power-profiles-daemon.enable = true;
  services.nfs.server.enable = true;
  powerManagement.enable = true;
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    gutenprint
    hplip
    brlaser
  ];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
