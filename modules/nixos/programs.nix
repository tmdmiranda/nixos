{ pkgs, lib, ... }:
{
  programs.ssh.startAgent = true;

  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  programs.uwsm.enable = true;
  programs.waybar.enable = true;
  systemd.user.services.waybar.wantedBy = lib.mkForce [ ];
  programs.steam.enable = true;
  programs.wireshark.enable = true;
  programs.nix-ld.enable = true;
  programs.firefox.enable = true;
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };

  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };

  virtualisation.docker = {
    enable = true;
    daemon.settings.features.buildkit = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    xhost
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
