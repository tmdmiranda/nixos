{ lib, stdenv, fetchFromGitHub, pkg-config, makeWrapper, dbus, wayland, wayland-scanner, wayland-protocols, libglvnd, libgbm, libx11, libxrandr, vulkan-headers, vulkan-loader, python3, fontconfig, steam-run }:
stdenv.mkDerivation {
  pname = "wallpiper";
  version = "unstable-2026-11-21";
  src = fetchFromGitHub {
    owner = "ejalxndr";
    repo = "wallpiper";
    rev = "6319fe337cf2d4081e5d82d59ff9887c7089292e";
    hash = "sha256-bBNRVOWQGp6wgJaIC4GsHZC1ktckvQu2jjugxcqj6As=";
  };
  nativeBuildInputs = [ pkg-config makeWrapper wayland-scanner ];
  buildInputs = [ dbus wayland wayland-protocols libglvnd libgbm libx11 libxrandr vulkan-headers vulkan-loader ];
  makeFlags = [ "build-core" "build-hyprland" ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/wallpiper $out/bin
    cp build/release/{wallpiperd,wallpiperctl,wallpiper-portal-hyprland,*.so,dwmapi.dll} $out/lib/wallpiper/
    for bin in wallpiperd wallpiperctl; do
      makeWrapper ${(steam-run.override { privateTmp = false; })}/bin/steam-run $out/bin/$bin \
        --add-flags $out/lib/wallpiper/$bin \
        --prefix PATH : ${lib.makeBinPath [ python3 fontconfig ]} \
        --set-default WALLPIPER_PORTAL hyprland
    done
    runHook postInstall
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    $out/lib/wallpiper/wallpiperd --help
    $out/lib/wallpiper/wallpiperctl --help
    test -s $out/lib/wallpiper/dwmapi.dll
    test -s $out/lib/wallpiper/libVkLayer_wallpiper_capture.so
    test -s $out/lib/wallpiper/libwallpiper-preload.so
    test -x $out/lib/wallpiper/wallpiper-portal-hyprland
  '';
  meta = {
    description = "Wallpaper Engine translation layer with the Hyprland portal";
    homepage = "https://github.com/ejalxndr/wallpiper";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "wallpiperd";
  };
}
