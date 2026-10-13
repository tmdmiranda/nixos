{ pkgs, ... }:
{
  home.packages = [
    (pkgs.vesktop.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
      postFixup = (old.postFixup or "") + ''
        wrapProgram $out/bin/vesktop \
          --unset NIXOS_OZONE_WL \
          --add-flags "--ozone-platform=x11"
      '';
    }))
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
