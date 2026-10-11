{ pkgs, ... }:
{
  # You never had any GTK theming (empty gtk-4.0 dir, no gtk-3.0 settings) so
  # tray menus fell back to broken white-on-white defaults. Dark everywhere:
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  # libadwaita / gtk4 apps follow this instead of a theme name
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  home.packages = with pkgs; [
    gnome-themes-extra
    papirus-icon-theme
    adwaita-icon-theme
  ];
}
