{ pkgs, lib, ... }:
{
  programs.ssh.startAgent = true;

  programs.hyprland.enable = true;
  # UWSM: launch Hyprland as a full systemd user session so
  # graphical-session.target (portal, xhost-local, waybar unit) activates.
  # Login flow becomes: uwsm start hyprland.desktop  (instead of start-hyprland)
  programs.hyprland.withUWSM = true;
  programs.uwsm.enable = true;
  programs.waybar.enable = true;
  # The bar is autostarted by Hyprland's startup.lua in ALL flows (uwsm and
  # start-hyprland) — don't also auto-start the package's systemd unit,
  # or you get two stacked bars.
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

  # Bootstrap minimum only — everything user-facing lives in home.packages modules.
  environment.systemPackages = with pkgs; [
    vim
    git
    xhost
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
