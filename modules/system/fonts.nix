{ pkgs, ... }:
{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    brightnessctl
    nerd-fonts.jetbrains-mono
  ];
}
