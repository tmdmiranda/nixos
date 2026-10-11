{ pkgs, ... }:
{
  home.packages = with pkgs; [
    playerctl
    wiremix
    pulseaudio
    pavucontrol
  ];
}
