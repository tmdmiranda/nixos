{ ... }:
{
  xdg.desktopEntries."net.lutris.Lutris" = {
  name = "Lutris";
  comment = "Play and manage your games";
  exec = "nvidia-offload lutris %U";
  icon = "lutris";
  terminal = false;
  type = "Application";
  categories = [ "Game" ];
  mimeType = [ "x-scheme-handler/lutris" ];
  settings = {
    PrefersNonDefaultGPU = "true";
    X-KDE-RunOnDiscreteGpu = "true";
  };
};
}
