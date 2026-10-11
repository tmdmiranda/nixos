{ pkgs, ... }:
let
  rootApp = pkgs.appimageTools.wrapType2 {
    pname = "root-app";
    version = "1.0.0";

    src = pkgs.fetchurl {
      url = "https://installer.rootapp.com/installer/Linux/X64/Root.AppImage";
      sha256 = "sha256-6Sy5bgylIntzlGp+GBwRzj9Lp/LnK4ZKhLoDhBBl3dY=";
    };

    extraPkgs = pkgs: with pkgs; [
      glib
      gsettings-desktop-schemas
      gtk3
      dconf
      dbus
      libnotify
      xdg-utils
      xdg-user-dirs
    ];

    extraBwrapArgs = [
      "--bind-try" "/run/user" "/run/user"
      "--setenv" "GTK_USE_PORTAL" "1"
      "--setenv" "GIO_USE_VFS" "local"
      "--setenv" "XDG_PICTURES_DIR" "$HOME/Pictures"
      "--setenv" "XDG_DOWNLOAD_DIR" "$HOME/Downloads"
      "--setenv" "XDG_DOCUMENTS_DIR" "$HOME"
    ];

    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cat > $out/share/applications/root.desktop <<EOF
      [Desktop Entry]
      Type=Application
      Name=Root
      Exec=env GTK_USE_PORTAL=1 root-app --enable-features=UseOzonePlatform --ozone-platform=wayland
      Icon=root
      Categories=Network;Chat;
      EOF
    '';
  };
in
{
  environment.systemPackages = [ rootApp ];
}
