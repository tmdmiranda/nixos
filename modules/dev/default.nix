{ pkgs, inputs, ... }:
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
    p7zip
    gdb
    file
    binutils
    ltrace
    patchelf
    inputs.radare2.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.pwndbg.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
