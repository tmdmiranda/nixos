{ pkgs, ... }:
{
  home.packages = with pkgs; [
    btop
  ];

  programs.btop = {
    enable = true;
    settings = {
      vim_keys = true;
      update_ms = 1000;
    };
  };
}
