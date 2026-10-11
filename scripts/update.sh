#!/usr/bin/env bash
set -euo pipefail
nix flake update nixpkgs home-manager codex-cli-nix
sudo nixos-rebuild switch --flake ~/nixos/#laptop --impure
