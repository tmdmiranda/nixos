{pkgs, ...}:

{
  home.packages = with pkgs; [
  wofi
  ];

  home.file.".config/wofi" = {
    target = ".config/wofi";
    source = ./config;
    recursive = true;
    force = true;

  };
}
