{ pkgs, ... }:
{
  systemd.user.services.xhost-local = {
    Unit = {
      Description = "Grant local Docker access to x11";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.xhost}/bin/xhost +local:";
      RemainAfterExit = true;
    };
  };
}
