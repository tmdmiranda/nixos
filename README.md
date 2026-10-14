<div align="center">

# tigas-nixos

acer nitro v 15 laptop, nixos + hyprland, home manager, nvchad

![nixos](https://img.shields.io/badge/nixos-unstable-blue?style=flat&logo=nixos)
![hyprland](https://img.shields.io/badge/hyprland-wayland-00b4d8?style=flat)
![flakes](https://img.shields.io/badge/flakes-enabled-green?style=flat)

vrooo idk what im doing i stole it from [lipeeeee](https://github.com/lipeeeee/nixos) but i like my config :)

my first dotfiles that i'm tryharding lol

</div>

## showcase

my dotfiles for my laptop setup (probably gonna expand to desktop soon), got some funky shit going on especially in the graphics drivers part lol.

| desktop | desktop 2 |
| --- | --- |
| ![my desktop](./screenshots/2026-10-13-132407_hyprshot.png) | ![my desktop 2](./screenshots/2026-10-13-132543_hyprshot.png) |

### my hyprlock :3

![hyprlock](./screenshots/hyprlock-2026-10-14_01-38-19-324584009.png)

## idk stuff im running

- wm: hyprland + waybar + wofi + hyprlock
- terminal shit: kitty + tmux + bash
- editor: nvim + nvchad
- apps: brave, vesktop, spotify, steam
- system shit: nvidia drivers (pain fuck you acer), acer nitro fan control, pipewire audio, flakes + home-manager

## install

dont fuckin do this without changing the nvidia drivers and blame me if it breaks lol, but yeah:

```bash
git clone https://github.com/tmdmiranda/nixos
sudo nixos-rebuild switch --flake ~/nixos#laptop
```

## structure

```
hosts/laptop/      # laptop config + home.nix
modules/
  desktop/         # hyprland, waybar, gtk, wofi
  terminals/       # kitty, tmux
  editors/         # neovim
  apps/            # browsers, chat, gaming, media, spotify, vesktop
  dev/ cli/ tui/   # lsps, tools, btop
  system/ nixos/   # audio, bash, fonts, boot, nvidia, etc
templates/zig/     # zig + zls shell just cuz
```

## credits

wouldn't even be using nix in the first place without [lipeeeee](https://github.com/lipeeeee/nixos) i yoinked his shit and frankensteined it for my acer.
