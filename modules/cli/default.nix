{ pkgs, ... }:
{
  home.packages = with pkgs; [
    tree
    zip
    unzip
    git
    stow
    wget
    curl
    traceroute
    ripgrep
    fd
    fzf
    cloc
    nmap

    cava
    pipes
    fastfetch
  ];
}
