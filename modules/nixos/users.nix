{ pkgs, ... }:
{
  users.users.tiago = {
    isNormalUser = true;
    description = "Tiago";
    extraGroups = [ "networkmanager" "wheel" "docker" "wireshark" ];
    packages = with pkgs; [ ];
  };

  users.extraGroups.vboxusers.members = [ "tiago" ];
}
