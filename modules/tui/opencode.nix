{ pkgs, ... }:
{
  # From nixpkgs-unstable (the flake's nixpkgs input) — same channel as the old
  # fetchTarball idiom. Refresh with: nix flake update nixpkgs
  # NOTE: deliberately NOT github:dan-online/opencode-nix — verified 2026-10-11
  # that it pins 1.14.33 (stale since May) while nixpkgs already ships 1.18.35.
  home.packages = with pkgs; [
    opencode
  ];
}
