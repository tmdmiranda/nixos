local binds = {}


binds.terminal = "kitty"
binds.mod = "SUPER"
binds.menu = "wofi --show drun"

binds.setup = function(hl)

  print("Setting up keybindings...")
  -- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
  hl.bind(binds.mod .. " + Q", hl.dsp.exec_cmd(binds.terminal))
  local closeWindowBind = hl.bind(binds.mod .. " + C", hl.dsp.window.close())
  -- closeWindowBind:set_enabled(false)
  hl.bind(binds.mod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
  hl.bind(binds.mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
  hl.bind(binds.mod .. " + R", hl.dsp.exec_cmd(binds.menu))
  hl.bind(binds.mod .. " + P", hl.dsp.window.pseudo())
  hl.bind(binds.mod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle only

  -- Move focus with binds.mod + arrow keys
  hl.bind(binds.mod .. " + left",  hl.dsp.focus({ direction = "left" }))
  hl.bind(binds.mod .. " + right", hl.dsp.focus({ direction = "right" }))
  hl.bind(binds.mod .. " + up",    hl.dsp.focus({ direction = "up" }))
  hl.bind(binds.mod .. " + down",  hl.dsp.focus({ direction = "down" }))

  -- Switch workspaces with binds.mod + [0-9]
  -- Move active window to a workspace with binds.mod + SHIFT + [0-9]
  for i = 1, 10 do
      local key = i % 10 -- 10 maps to key 0
      hl.bind(binds.mod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
      hl.bind(binds.mod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
  end

  -- Example special workspace (scratchpad)
  hl.bind(binds.mod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
  hl.bind(binds.mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic", follow = false }))

  -- Scroll through existing workspaces with binds.mod + scroll
  hl.bind(binds.mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
  hl.bind(binds.mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

  -- Move/resize windows with binds.mod + LMB/RMB and dragging
  hl.bind(binds.mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
  hl.bind(binds.mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

  -- Laptop multimedia keys for volume and LCD brightness
  hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
  hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
  hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
  hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
  hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
  hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
  hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
  hl.bind(binds.mod .. " + Print", hl.dsp.exec_cmd("hyprshot -m output -o ~/screenshots"))
  hl.bind(binds.mod .. " + SHIFT + Print", hl.dsp.exec_cmd([[mkdir -p ~/screenshots && grim ~/screenshots/hyprlock-$(date +%Y-%m-%d_%H-%M-%S-%N).png]]), { locked = true })

  -- Requires playerctl
  hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
  hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
  hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
  hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

  hl.bind(binds.mod .. " + SHIFT + W", hl.dsp.exec_cmd("/home/tiago/.config/hypr/scripts/wallch.sh"))
  hl.bind(binds.mod .. " + L", hl.dsp.exec_cmd("hyprlock"))

end

return binds
