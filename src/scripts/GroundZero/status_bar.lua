StatusBar = StatusBar or {}

-- Try to require TextGauge, assume it's available via MDK
local TextGauge = require("MDK.textgauge")

-- Configuration
local config = {
    height = "135px", -- Increased height for 4 stacked bars
    fontSize = 14,
    font = "Cascadia Code",
    fillChar = "#",
    emptyChar = "-",
    fillColor = "#ff6600",  -- Bright Deep Orange
    emptyColor = "#333333", -- Dark Metallic Grey
    overflowColor = "#ffffff",
    labelColor = "#ffffff",
}

function StatusBar.create()
    -- Create the container at the bottom
    StatusBar.container = Adjustable.Container:new({
        name = "StatusBarContainer",
        titleText = "", -- Remove title text
        x = 0,
        y = "-135px",   -- Docked to bottom (matching height)
        width = "100%",
        height = config.height,
        adjLabelstyle = "background-color:rgba(20,20,20,100%); border: 2px solid #202020;",
    })

    -- Create a console for the text gauges
    StatusBar.console = Geyser.MiniConsole:new({
        name = "StatusBarConsole",
        x = 0,
        y = 0,
        width = "100%",
        height = "100%",
        color = "black",
        fontSize = config.fontSize,
        font = config.font,
    }, StatusBar.container)

    -- Define common gauge options
    local gaugeOpts = {
        width = 50, -- Characters wide
        fillCharacter = config.fillChar,
        emptyCharacter = config.emptyChar,
        fillColor = config.fillColor,
        emptyColor = config.emptyColor,
        overflowColor = config.overflowColor,
        valueColor = config.labelColor,
        showPercent = false, -- We'll customize the format
        showPercentSymbol = false,
        format = "d",
    }

    -- Create Gauges
    StatusBar.health = TextGauge:new(gaugeOpts)
    StatusBar.mana = TextGauge:new(gaugeOpts)
    StatusBar.movement = TextGauge:new(gaugeOpts)

    -- Target gauge with red fill
    StatusBar.target = TextGauge:new({
        width = 50,
        fillCharacter = config.fillChar,
        emptyCharacter = config.emptyChar,
        fillColor = "red",
        emptyColor = config.emptyColor,
        overflowColor = config.overflowColor,
        valueColor = config.labelColor,
        showPercent = false,
        format = "d",
    })

    -- Set initial text
    StatusBar.update_all()
end

function StatusBar.update_gauge(gauge, label, current, max)
    current = tonumber(current) or 0
    max = tonumber(max) or 1
    if max == 0 then max = 1 end

    -- Custom format: "Label: Current/Max [Bar]"
    -- gauge:setValue returns the formatted string in MDK TextGauge which contains color tags
    local bar = gauge:setValue(current, max)

    -- We construct the string and print it to the console
    -- We use <255,255,255> for white to be safe with decho parsing
    local text = string.format("<180,180,180>%-4s %4d/%-4d %s", label, current, max, bar)
    return text
end

function StatusBar.get_extra_info(line_index)
    if not GZ then return "" end

    local extras = ""
    local padding = "   " -- Space between gauge and info

    if line_index == 1 then
        -- Combat Info
        if GZ.combat and GZ.combat.active then
            local targetName = GZ.combat.target_name or "Unknown"
            local targetHealth = GZ.combat.target_health or 0
            extras = string.format("<255,100,100>[Target: %s]", targetName) or ""
        end
    elseif line_index == 2 then
        -- Level Info
        if GZ.player and GZ.player.level then
            local level = GZ.player.level or 0
            local tnl = GZ.player.tnl or 0
            extras = string.format("<100,255,100>[Lvl: %d  TNL: %d]", level, tnl) or ""
        end
    elseif line_index == 3 then
        -- Mobs & AFK
        if GZ.mobs_in_room and GZ.mobs_in_room > 0 then
            local mobsInRoom = GZ.mobs_in_room or 0
            extras = string.format("<200,200,100>[Mobs: %d]", mobsInRoom) or ""
        end
        if GZ.player and GZ.player.afk then
            extras = extras .. " <255,255,0>[AFK]"
        end
    end

    if extras ~= "" then
        return padding .. extras
    else
        return ""
    end
end

function StatusBar.update_all()
    if not StatusBar.console then return end

    StatusBar.console:clear()

    -- 1. Target Line (Row 1)
    local target_line = "\n" -- Placeholder for empty line if no target
    if GZ.combat and GZ.combat.active then
        -- local name = GZ.combat.target_name or "Target"
        local name = "TGT"
        local hp_pct = tonumber(GZ.combat.target_health) or 0
        local bar = StatusBar.target:setValue(hp_pct, 100)

        -- Format: Name (truncated) Percent Bar
        -- Truncate name to 9 chars to align loosely with "HP:  123/123" (approx 14 chars)
        -- %-9.9s pads to 9, truncates at 9.
        -- <255,100,100> is a light red for the text
        target_line = string.format("<255,100,100>%-9.9s %3d%% %s\n", name, hp_pct, bar)
    end

    -- 2. Player Stats (Rows 2-4)
    local hp = StatusBar.update_gauge(StatusBar.health, "HP:", msdp.HEALTH, msdp.HEALTH_MAX) ..
        StatusBar.get_extra_info(1)
    local mp = StatusBar.update_gauge(StatusBar.mana, "MP:", msdp.MANA, msdp.MANA_MAX) .. StatusBar.get_extra_info(2)
    local mv = StatusBar.update_gauge(StatusBar.movement, "MV:", msdp.MOVEMENT, msdp.MOVEMENT_MAX) ..
        StatusBar.get_extra_info(3)

    -- Print nicely formatted lines using decho (for hex support)
    StatusBar.console:decho(target_line)
    StatusBar.console:decho(hp .. "\n")
    StatusBar.console:decho(mp .. "\n")
    StatusBar.console:decho(mv .. "\n")
end

function StatusBar.eventHandler(event, ...)
    if event == "sysConnectionEvent" or event == "sysInstall" or event == "sysProtocolEnabled" then
        StatusBar.create()
    end
    -- Trigger generic update for all related events for simplicity with text console redrawing
    StatusBar.update_all()
end

registerAnonymousEventHandler("sysProtocolEnabled", "StatusBar.eventHandler")
registerAnonymousEventHandler("sysConnectionEvent", "StatusBar.eventHandler")
registerAnonymousEventHandler("sysInstall", "StatusBar.eventHandler")
registerAnonymousEventHandler("msdp.HEALTH", "StatusBar.eventHandler")
registerAnonymousEventHandler("msdp.HEALTH_MAX", "StatusBar.eventHandler")
registerAnonymousEventHandler("msdp.MANA", "StatusBar.eventHandler")
registerAnonymousEventHandler("msdp.MANA_MAX", "StatusBar.eventHandler")
registerAnonymousEventHandler("msdp.MOVEMENT", "StatusBar.eventHandler")
registerAnonymousEventHandler("msdp.MOVEMENT_MAX", "StatusBar.eventHandler")
