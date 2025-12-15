GZ = GZ or {}
GZ.affects = GZ.affects or {}
GZ.player = GZ.player or {}

local config = {
    name = "AffectsWindow",
    title = "Active Affects",
    x = "66%", -- Initial placement, can be moved
    y = 0,
    width = "33%",
    height = "300px",
    color = "black",
    font = "Consolas",
    fontSize = 12,
}

function GZ.affects.create()
    if GZ.affects.window then return end

    GZ.affects.window = Geyser.UserWindow:new({
        name = config.name,
        titleText = config.title,
        x = config.x,
        y = config.y,
        width = config.width,
        height = config.height,
        dockedWith = "mapper", -- Try to dock if mapper exists, otherwise float
        dockPosition = "bottom",
    })

    GZ.affects.console = Geyser.MiniConsole:new({
        name = config.name .. "Console",
        x = 0,
        y = 0,
        width = "100%",
        height = "100%",
        color = config.color,
        fontSize = config.fontSize,
        font = config.font,
    }, GZ.affects.window)

    GZ.affects.console:cecho("<green>Affects Capture Ready.\n")
end

function GZ.affects.start_capture()
    GZ.affects.capturing = true
    GZ.affects.current_data = {
        stats = {},
        spells = {}
    }
end

function GZ.affects.process_header(matches)
    GZ.affects.start_capture()
    -- matches might contain the full line. We don't necessarily need to parse the Str/Int/etc since we have MSDP
    -- But if the user wants them in GZ.player, we could.
    -- Assuming matches[1] is full line.
end

function GZ.affects.process_line(key, value)
    if not GZ.affects.capturing then return end
    key = string.trim(key)
    -- Store in GZ.player for general use
    GZ.player[key] = value
    -- Store in current data for display
    table.insert(GZ.affects.current_data.stats, { key = key, value = value })
end

function GZ.affects.process_spell(details)
    if not GZ.affects.capturing then return end
    table.insert(GZ.affects.current_data.spells, details)
end

function GZ.affects.end_capture()
    if not GZ.affects.capturing then return end
    GZ.affects.capturing = false
    GZ.affects.update_display()
end

function GZ.affects.update_display()
    if not GZ.affects.console or not GZ.affects.current_data then return end

    GZ.affects.console:clear()

    local c = GZ.affects.console

    c:cecho("<OrangeRed>Stats:\n")
    for _, item in ipairs(GZ.affects.current_data.stats) do
        c:cecho(string.format("  <DeepSkyBlue>%-15s : <white>%s\n", item.key, item.value))
    end

    c:cecho("\n<OrangeRed>Spells:\n")
    for _, spell in ipairs(GZ.affects.current_data.spells) do
        if spell then
            c:cecho(string.format("  <yellow>%s\n", spell))
        end
    end
end

-- Hook creation
registerAnonymousEventHandler("sysLoadEvent", GZ.affects.create)
registerAnonymousEventHandler("sysInstall", GZ.affects.create)
-- Also create immediately if script is reloaded
if not GZ.affects.window then GZ.affects.create() end
