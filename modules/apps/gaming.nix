{ pkgs, ... }:
{
  home.packages = with pkgs; [
    lutris
    protonup-qt
  ];
}
