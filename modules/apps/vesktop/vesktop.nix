{ pkgs, ... }:
{
  home.packages = with pkgs; [
    vesktop
  ];

  home.file.".config/vesktop/settings.json" = {
    target = ".config/vesktop/settings.json";
    source = ./config/settings.json;
    force = true;
  };
  home.file.".config/vesktop/settings/settings.json" = {
    target = ".config/vesktop/settings/settings.json";
    source = ./config/settings/settings.json;
    force = true;
  };
  home.file.".config/vesktop/settings/quickCss.css" = {
    target = ".config/vesktop/settings/quickCss.css";
    source = ./config/settings/quickCss.css;
    force = true;
  };
}
