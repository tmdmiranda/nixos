{ config, lib, ... }:
let
  linuwu-sense-module = config.boot.kernelPackages.callPackage ({ stdenv, kernel }:
    stdenv.mkDerivation {
      pname = "linuwu-sense";
      version = "git";

      # Local checkout — intentionally absolute, no upstream pin yet.
      # Rebuild with --impure. See plan.md §5 for future inputs.linuwu-sense idea.
      src = /home/tiago/Linuwu-Sense;

      hardeningDisable = [ "pic" "format" ];
      nativeBuildInputs = kernel.moduleBuildDependencies;

      buildPhase = ''
        runHook preBuild
        make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$(pwd) modules
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out/lib/modules/${kernel.modDirVersion}/extra
        install -m 644 src/linuwu_sense.ko $out/lib/modules/${kernel.modDirVersion}/extra/
        runHook postInstall
      '';

      meta = with lib; {
        description = "Kernel module for Linuwu-Sense fan and power control";
        platforms = platforms.linux;
      };
    }) {};
in
{
  boot.extraModulePackages = [ linuwu-sense-module ];
}
