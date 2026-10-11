{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # vesktop lives in apps/vesktop/vesktop.nix (package + vencord settings)
    parsec-bin
  ];
}
