{ pkgs, ... }:
{
  home.packages = with pkgs; [
    lua-language-server
    nil
    pyright
    gopls
  ];
}
