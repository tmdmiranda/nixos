{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard
    hyprpicker
    cliphist
    brightnessctl
    kitty
    grim
    slurp
    hyprshot
    hyprlock
    wofi
    networkmanagerapplet
    bibata-cursors
    awww
    mpvpaper
  ];

  home.file.".config/hypr" = {
    target = ".config/hypr";
    source = ./config;
    recursive = true;
    force = true;
  };
}
