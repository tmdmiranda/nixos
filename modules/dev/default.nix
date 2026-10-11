{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gcc
    gnumake
    python3
    python3Packages.pip
    docker-compose
    docker-buildx
    android-tools
    vagrant
    nodejs_22
    uv
    zig
  ];
}
