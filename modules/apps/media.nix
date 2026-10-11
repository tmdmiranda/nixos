{ pkgs, ... }:
{
  home.packages = with pkgs; [
    mpd
    mpvpaper
  ];
}
