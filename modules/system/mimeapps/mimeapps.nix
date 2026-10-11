{ ... }:
{
  # Copied from live ~/.config/mimeapps.list (NOT the stale tigdotfiles copy:
  # live uses brave-browser.desktop + rootapp handler, tigdotfiles still has the
  # flatpak com.brave.Browser ID and no rootapp entry).
  xdg.configFile."mimeapps.list" = {
    target = "mimeapps.list";
    source = ./mimeapps.list;
    force = true;
  };
}
