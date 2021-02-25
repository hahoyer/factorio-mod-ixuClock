local mod_gui = require("mod-gui")
for _, player in pairs(game.players) do
    local gui = mod_gui.get_frame_flow(player).hwclock
    if gui then
        gui.destroy() 
        player.print("[ixuClock] migration 0.2.4")
    end  
end