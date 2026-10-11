{ pkgs, ... }:

let
  nitroFanHelper = pkgs.writeShellScriptBin "acer-nitro-fan-set" ''
    if [ "$#" -ne 2 ]; then
      echo "usage: acer-nitro-fan-set CPU GPU (0-100)" >&2
      exit 2
    fi

    for speed in "$@"; do
      case "$speed" in
        0|[1-9]|[1-9][0-9]|100) ;;
        *)
          echo "fan speeds must be whole numbers from 0 to 100" >&2
          exit 2
          ;;
      esac
    done

    fan_path=/sys/devices/platform/acer-wmi/nitro_sense/fan_speed
    if [ ! -w "$fan_path" ]; then
      echo "Linuwu-Sense fan_speed sysfs node is unavailable" >&2
      exit 1
    fi
    printf '%s,%s\n' "$1" "$2" > "$fan_path"
  '';
in
{
  environment.systemPackages = [ nitroFanHelper ];

  security.sudo.extraRules = [
    {
      users = [ "tiago" ];
      commands = [
        {
          command = "${nitroFanHelper}/bin/acer-nitro-fan-set";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
