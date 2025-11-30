gossip = gossip or {}
gossip.config = gossip.config or {
    x = "70%",
    y = "0%",
    width = "30%",
    height = "30%",
    name = "gossipContainer",
    consoleName = "gossipConsole"
}

function gossip.setup()
    -- Create the container
    gossip.container = Adjustable.Container:new({
        name = gossip.config.name,
        x = gossip.config.x,
        y = gossip.config.y,
        width = gossip.config.width,
        height = gossip.config.height,
        titleText = "Gossip",
        titleTxtColor = "white",
        padding = 5,
        adjLabelstyle = "background-color:rgba(0,0,0,100%); border: 2px solid #505050;",
    })

    -- Create a MiniConsole inside the container to hold the text
    gossip.console = Geyser.MiniConsole:new({
        name = gossip.config.consoleName,
        x = 0,
        y = 25,
        width = "100%",
        height = "-25",
        autoWrap = true,
        color = "black",
        scrollBar = true,
        fontSize = 10,
    }, gossip.container)
end

function gossip.display_line(is_start)
    if is_start then
        local timestamp = getTime(true, "hh:mm")
        gossip.console:echo("[" .. timestamp .. "] ")
    else
        gossip.console:echo("\n") -- Ensure new line for continuation
    end

    selectCurrentLine()
    copy()
    appendBuffer(gossip.config.consoleName)
end

function gossip.start_capture(name, message)
    if not gossip.console then
        gossip.setup()
    end

    -- Display the first line
    gossip.display_line(true)

    -- Check if the message ends with a quote
    -- We use string.match to check the last character
    if not string.match(message, "'$") then
        -- It's a multi-line message
        enableTrigger("Gossip Capture")
    end
end

function gossip.continue_capture(line)
    -- Display the continuation line
    gossip.display_line(false)

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
