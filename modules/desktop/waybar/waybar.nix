{ pkgs, ... }:
{
  home.packages = with pkgs; [
    waybar
  ];

  home.file.".config/waybar" = {
    target = ".config/waybar";
    source = ./config;
    recursive = true;
    force = true;
  };
}
