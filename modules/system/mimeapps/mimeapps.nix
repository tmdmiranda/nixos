{ ... }:
{
  xdg.configFile."mimeapps.list" = {
    target = "mimeapps.list";
    source = ./mimeapps.list;
    force = true;
  };
}
