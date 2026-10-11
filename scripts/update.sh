#!/usr/bin/env bash
set -euo pipefail
# Pull latest pinned versions (nixpkgs carries opencode, codex-cli-nix tracks
# hourly upstream), then rebuild. Run weekly or whenever you want newest builds.
nix flake update nixpkgs home-manager codex-cli-nix
sudo nixos-rebuild switch --flake ~/nixos/#laptop --impure
