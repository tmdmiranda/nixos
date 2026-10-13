{ config, pkgs, inputs, lib, ... }:

let
  moduleRoot = ../../modules;
  M = path: import (moduleRoot + "/${path}");
in
{
  home.username = "tiago";
  home.homeDirectory = "/home/tiago";
  home.stateVersion = "26.05";

  imports = [
    (M "desktop/hyprland/hyprland.nix")
    (M "desktop/waybar/waybar.nix")
    (M "desktop/gtk/gtk.nix")

    (M "terminals/kitty/kitty.nix")
    (M "terminals/tmux/tmux.nix")

    (M "editors/neovim.nix")

    (M "cli/default.nix")

    (M "dev/default.nix")
    (M "dev/lsps.nix")

    (M "tui/btop/btop.nix")
    (M "tui/opencode.nix")
    (M "tui/codex.nix")

    (M "apps/browsers.nix")
    (M "apps/chat.nix")
    (M "apps/vesktop/vesktop.nix")
    (M "apps/gaming.nix")
    (M "apps/media.nix")

    (M "system/bash.nix")
    (M "system/fonts.nix")
    (M "system/audio.nix")
    (M "system/xhost.nix")
    (M "system/steam-entry.nix")
    (M "system/mimeapps/mimeapps.nix")
  ];

  home.packages = with pkgs; [
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    setSessionVariables = true;

    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";

    desktop = null;
    music = null;
    templates = null;
    pictures = null;
    videos = null;
    publicShare = null;
  };

  programs.home-manager.enable = true;
}
