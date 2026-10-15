#!/usr/bin/env bash
set -euo pipefail
git -C "$HOME/nixos" add .
sudo nixos-rebuild switch --flake ~/nixos/#laptop --impure
