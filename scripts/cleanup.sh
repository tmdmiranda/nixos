#!/usr/bin/env bash
set -euo pipefail
# Clean old generations manually (weekly nix.gc already handles the routine case)
sudo nix-collect-garbage -d
