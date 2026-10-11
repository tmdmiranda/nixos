{ pkgs, ... }:
{
  home.packages = with pkgs; [
    kitty
  ];

  home.file.".config/kitty" = {
    target = ".config/kitty";
    source = ./config;
    recursive = true;
    force = true;
  };
}
