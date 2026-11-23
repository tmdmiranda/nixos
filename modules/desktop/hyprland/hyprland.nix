{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (callPackage ../wallpiper.nix { })
    wl-clipboard
    hyprpicker
    cliphist
    brightnessctl
    kitty
    grim
    slurp
    hyprshot
    hyprlock
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
