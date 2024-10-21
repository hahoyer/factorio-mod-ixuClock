local mod_gui = require("mod-gui")
require("util")

local play_time_seconds = -1

function FormatPlaytimeInformation(player)
    local ticks = game.tick
    local daytime = player.surface.daytime + 0.5
    local crashdays = game.tick / player.surface.ticks_per_day

    local seconds = math.floor(ticks / 60)
    local minutes = math.floor(seconds / 60)
    local hours = math.floor(minutes / 60)
    local days = math.floor(hours / 24)
    local hourString = ""
    if hours > 0 then hourString = string.format("%d:", hours % 24) end
    local dayString = ""
    if days > 0 then dayString = string.format("%d.", days) end
    local playtimeString = string.format("%02d:%02d", minutes % 60, seconds % 60)

    local crashdaysString = string.format("%d", crashdays);

    local dayminutes = math.floor(daytime * 24 * 60) % 60
    local dayhour = math.floor(daytime * 24) % 24
    local daytimeString = string.format("%02d:%02d", dayhour, dayminutes)

    return dayString .. hourString .. playtimeString .. " " .. crashdaysString .. " "
        .. daytimeString
end

local Clock = {
    left = { Next = "top" },
    top = { Next = "left" },
    transparent = { Next = "opaque" },
    opaque = { Next = "transparent" },
}

function EnsureClockLocation(index)
    if not storage.ixuClock then storage.ixuClock = {} end
    if not storage.ixuClock[index] then storage.ixuClock[index] = {} end
    if not storage.ixuClock[index].Location then storage.ixuClock[index].Location = "left" end
    if not storage.ixuClock[index].Variant then storage.ixuClock[index].Variant = "transparent" end
    return Clock[storage.ixuClock[index].Location]
end

function Clock.left.Area(player) return mod_gui.get_frame_flow(player) end

function Clock.top.Area(player) return player.gui.top end

function GetGui(variant)
    return {
        type = variant.Variant == "transparent" and "label" or "button",
        name = "ixuClock",
        tooltip = "try left or right mouse click",
    }
end

function EnsureClock(index)
    local result = GetClock(index)
    if result then return result end

    local variant = EnsureClockLocation(index)
    local result = variant.Area(game.players[index]).add(GetGui(storage.ixuClock[index]))
    if storage.ixuClock[index].Location == "float" then
        result.location = storage.ixuClock[index].GuiLocation
    end
    return result
end

function GetClock(index)
    local variant = EnsureClockLocation(index)
    local area = variant.Area(game.players[index])
    return area.ixuClock
end

function ShowFormatPlaytimeInformation(event)
    local previous = play_time_seconds

    play_time_seconds = math.floor(game.tick / 60)

    if previous == play_time_seconds then return end

    for i, player in pairs(game.connected_players) do
        local ixuClock = EnsureClock(player.index)
        local value = FormatPlaytimeInformation(player)
        ixuClock.caption = value
    end
end

function OnClick(event)                      --
    local index = event.player_index
    if event.element == GetClock(index) then --
        GetClock(index).destroy()
        if event.button == defines.mouse_button_type.left then
            storage.ixuClock[index].Location = Clock[storage.ixuClock[index].Location].Next
        elseif event.button == defines.mouse_button_type.right then
            storage.ixuClock[index].Variant = Clock[storage.ixuClock[index].Variant].Next
        end
        EnsureClock(index)
    end
end

script.on_event(defines.events.on_gui_click, OnClick)
