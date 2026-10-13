{pkgs, ...}:

{
  home.packages = [
    (pkgs.spotify.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
      postFixup = (old.postFixup or "") + ''
        wrapProgram $out/bin/spotify \
          --unset NIXOS_OZONE_WL \
          --add-flags "--ozone-platform=x11"
      '';
    }))
  ];
}
