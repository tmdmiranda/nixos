local startup = {}

startup.setup = function(hl)
  hl.on("hyprland.start", function()
	  hl.exec_cmd("systemctl --user start hyprpolkitagent.service")
	  hl.exec_cmd("waybar")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/wallch.sh")
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")
  end)
end

return startup

