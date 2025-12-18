GZ = GZ or {}
GZ.affects = GZ.affects or {}
GZ.player = GZ.player or {}

local config = {
    name = "AffectsWindow",
    title = "ACTIVE AFFECTS",
    x = "66%",
    y = 0,
    width = "33%",
    height = "300px",
    color = "black",
    font = "Consolas",
    fontSize = 10,
}

function GZ.affects.create()
    -- Use Adjustable.Container for consistency and reliability
    if not GZ.affects.container then
        GZ.affects.container = Adjustable.Container:new({
            name = "GZAffectsContainer",
            titleText = config.title,
            titleTxtColor = "#ff6600",
            x = config.x,
            y = config.y,
            width = config.width,
            height = config.height,
            adjLabelstyle = "background-color:rgba(20,20,20,100%); border: 2px solid #202020;",
        })

        GZ.affects.console = Geyser.MiniConsole:new({
            name = "GZAffectsConsole",
            x = 0,
            y = 25,
            width = "100%",
            height = "-25",
            color = config.color,
            fontSize = config.fontSize,
            font = config.font,
        }, GZ.affects.container)

        GZ.affects.console:cecho("<green>Affects Capture Ready.\n")
    end
end

function GZ.affects.start_capture()
    GZ.affects.capturing = true
    GZ.affects.current_data = {
        stats = {},
        spells = {},
        keys_seen = {} -- To prevent duplication during capture
    }
end

function GZ.affects.process_header(matches)
    GZ.affects.start_capture()
end

function GZ.affects.process_line(key, value)
    if not GZ.affects.capturing then return end
    key = string.trim(key)

    -- De-duplication check for ghost handlers
    if GZ.affects.current_data.keys_seen[key] then return end
    GZ.affects.current_data.keys_seen[key] = true

    GZ.player[key] = value
    table.insert(GZ.affects.current_data.stats, { key = key, value = value })
end

function GZ.affects.process_spell(details)
    if not GZ.affects.capturing then return end

    -- De-duplication check for ghost handlers
    if GZ.affects.current_data.keys_seen[details] then return end
    GZ.affects.current_data.keys_seen[details] = true

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

-- Event Handlers (Renamed to clear ghost string-based registrations)
function GZ.affects.handle_header(event, matches)
    GZ.affects.process_header(matches)
end

function GZ.affects.handle_line(event, key, value)
    GZ.affects.process_line(key, value)
end

function GZ.affects.handle_spell(event, spell)
    GZ.affects.process_spell(spell)
end

function GZ.affects.handle_end()
    GZ.affects.end_capture()
end

-- Initialization and Registration
function GZ.affects.init()
    GZ.affects.create()

    -- Register handlers using function objects
    if GZ.affects.handler_ids then
        for _, id in ipairs(GZ.affects.handler_ids) do
            killAnonymousEventHandler(id)
        end
    end

    GZ.affects.handler_ids = {
        registerAnonymousEventHandler("GZ.affects_header", GZ.affects.handle_header),
        registerAnonymousEventHandler("GZ.affects_line", GZ.affects.handle_line),
        registerAnonymousEventHandler("GZ.affects_spell", GZ.affects.handle_spell),
        registerAnonymousEventHandler("GZ.affects_end", GZ.affects.handle_end)
    }
end

-- Hook Cleanup of old/wrongly named handlers if they exist from previous sessions
function GZ.affects.purge_ghosts()
    -- This is a one-time purge for this session
    GZ.affects.on_header = nil
    GZ.affects.on_line = nil
    GZ.affects.on_spell = nil
    GZ.affects.on_end = nil
end

registerAnonymousEventHandler("sysLoadEvent", GZ.affects.init)
registerAnonymousEventHandler("sysInstall", GZ.affects.init)

-- Create immediately
GZ.affects.purge_ghosts()
GZ.affects.init()
