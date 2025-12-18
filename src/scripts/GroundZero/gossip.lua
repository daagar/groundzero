gossip = gossip or {}
gossip.config = gossip.config or {
    x = "70%",
    y = "0%",
    width = "30%",
    height = "30%",
    consoleName = "GossipEMCO"
}

-- Try to require EMCO, assume it's available via MDK
local EMCO = require("MDK.emco")

function gossip.setup()
    -- Create the Adjustable Container
    gossip.container = Adjustable.Container:new({
        name = "gossipContainer",
        x = gossip.config.x,
        y = gossip.config.y,
        width = gossip.config.width,
        height = gossip.config.height,
        titleText = "GOSSIP", -- Caps for that industrial feel
        titleTxtColor = "#ff6600",
        adjLabelstyle = "background-color:rgba(20,20,20,100%); border: 2px solid #202020;",
    })

    -- Create the EMCO object inside the container
    gossip.emco = EMCO:new({
        name = gossip.config.consoleName,
        x = 0,
        y = 25,
        width = "100%",
        height = "-25",
        allTab = true,
        allTabName = "All",
        timestamp = true,
        timestampFormat = "HH:mm",
        consoleColor = "black",
        activeTabFGColor = "black",     -- Black text on orange bg
        inactiveTabFGColor = "#ff6600", -- Orange text on dark bg
        activeTabBGColor = "#ff6600",   -- Bright Deep Orange
        inactiveTabBGColor = "#202020", -- Dark Grey
        -- Ensure text is readable
        font = "Bitstream Vera Sans Mono",
        fontSize = 10,
        gap = 2, -- Slight gap between tabs
        tabBold = true,
    }, gossip.container)

    -- Add the Gossip tab
    gossip.emco:addTab("Gossip")
end

function gossip.start_capture(name, message)
    if not gossip.emco then
        gossip.setup()
    end

    -- Append the current line to the Gossip tab (and All tab)
    gossip.emco:append("Gossip")

    -- Check if the message ends with a quote
    if not string.match(message, "'$") then
        -- It's a multi-line message
        enableTrigger("Gossip Capture")
    end
end

function gossip.continue_capture(line)
    if not gossip.emco then
        gossip.setup()
    end

    -- Append the continuation line
    gossip.emco:append("Gossip")

    -- Check if this line ends the message
    if string.match(line, "'$") then
        disableTrigger("Gossip Capture")
    end
end

function gossip.init()
    gossip.setup()
end

-- Initialize on load
registerAnonymousEventHandler("sysLoadEvent", "gossip.init")
registerAnonymousEventHandler("sysInstall", "gossip.init")

function gossip.on_start(event, name, message)
    gossip.start_capture(name, message)
end

function gossip.on_message(event, line)
    gossip.continue_capture(line)
end

registerAnonymousEventHandler("GZ.gossip_start", "gossip.on_start")
registerAnonymousEventHandler("GZ.gossip_message", "gossip.on_message")
