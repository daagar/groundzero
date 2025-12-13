StatusBar = StatusBar or {}

-- Configuration
local config = {
    height = "30px",
    fontSize = 12,
    font = "Bitstream Vera Sans Mono",
}

function StatusBar.get_color(percentage)
    if percentage >= 80 then
        return "green"
    elseif percentage >= 60 then
        return "yellowgreen"
    elseif percentage >= 40 then
        return "yellow"
    elseif percentage >= 20 then
        return "orange"
    else
        return "red"
    end
end

function StatusBar.create()
    -- Create the container at the bottom
    StatusBar.container = Adjustable.Container:new({
        name = "StatusBarContainer",
        titleText = "", -- Remove title text
        x = 0,
        y = -30,        -- Docked to bottom
        width = "100%",
        height = config.height,
        adjLabelstyle = "background-color:rgba(0,0,0,100%); border: 0px solid #333333;", -- Dark grey border
    })

    -- Label Styles
    local label_style = [[
        background-color: rgba(0,0,0,0);
        font-family: ']] .. config.font .. [[';
        font-size: ]] .. config.fontSize .. [[px;
        font-weight: bold;
        color: white;
        qproperty-alignment: 'AlignRight | AlignVCenter';
    ]]

    -- Health Section
    StatusBar.lblHealth = Geyser.Label:new({
        name = "StatusBarLblHealth",
        x = "0%",
        y = 0,
        width = "5%",
        height = "100%",
    }, StatusBar.container)
    StatusBar.lblHealth:echo("HP")
    StatusBar.lblHealth:setStyleSheet(label_style)

    StatusBar.health = Geyser.Gauge:new({
        name = "StatusBarHealth",
        x = "5.5%",
        y = 0,
        width = "27%",
        height = "100%",
    }, StatusBar.container)

    -- Mana Section
    StatusBar.lblMana = Geyser.Label:new({
        name = "StatusBarLblMana",
        x = "33%",
        y = 0,
        width = "5%",
        height = "100%",
    }, StatusBar.container)
    StatusBar.lblMana:echo("MP")
    StatusBar.lblMana:setStyleSheet(label_style)

    StatusBar.mana = Geyser.Gauge:new({
        name = "StatusBarMana",
        x = "38.5%",
        y = 0,
        width = "27%",
        height = "100%",
    }, StatusBar.container)

    -- Movement Section
    StatusBar.lblMovement = Geyser.Label:new({
        name = "StatusBarLblMovement",
        x = "66%",
        y = 0,
        width = "5%",
        height = "100%",
    }, StatusBar.container)
    StatusBar.lblMovement:echo("MV")
    StatusBar.lblMovement:setStyleSheet(label_style)

    StatusBar.movement = Geyser.Gauge:new({
        name = "StatusBarMovement",
        x = "71.5%",
        y = 0,
        width = "27%",
        height = "100%",
    }, StatusBar.container)

    -- Initialize styles
    local style = [[
        font-family: ']] .. config.font .. [[';
        font-weight: bold;
        color: white;
        text-shadow: 1px 1px 0 #000;
        border: 1px solid #555555;
    ]]

    StatusBar.health.front:setStyleSheet(style)
    StatusBar.mana.front:setStyleSheet(style)
    StatusBar.movement.front:setStyleSheet(style)

    -- Set initial text
    StatusBar.update_all()
end

function StatusBar.update_gauge(gauge, current, max)
    current = tonumber(current) or 0
    max = tonumber(max) or 1
    if max == 0 then max = 1 end -- Prevent division by zero

    local percentage = (current / max) * 100
    local color = StatusBar.get_color(percentage)

    gauge:setValue(current, max, string.format("%d / %d", current, max))
    gauge.front:setStyleSheet(string.format([[
        background-color: %s;
        font-family: '%s';
        font-size: %dpx;
        font-weight: bold;
        color: black;
        qproperty-alignment: 'AlignHCenter | AlignVCenter';
        border: 1px solid #555555;
    ]], color, config.font, config.fontSize))

    -- Back style usually dark
    gauge.back:setStyleSheet([[
        background-color: #333333;
    ]])
end

function StatusBar.update_all()
    StatusBar.update_gauge(StatusBar.health, msdp.HEALTH, msdp.HEALTH_MAX)
    StatusBar.update_gauge(StatusBar.mana, msdp.MANA, msdp.MANA_MAX)
    StatusBar.update_gauge(StatusBar.movement, msdp.MOVEMENT, msdp.MOVEMENT_MAX)
end

function StatusBar.eventHandler(event, ...)
    if event == "msdp.HEALTH" or event == "msdp.HEALTH_MAX" then
        StatusBar.update_gauge(StatusBar.health, msdp.HEALTH, msdp.HEALTH_MAX)
    elseif event == "msdp.MANA" or event == "msdp.MANA_MAX" then
        StatusBar.update_gauge(StatusBar.mana, msdp.MANA, msdp.MANA_MAX)
    elseif event == "msdp.MOVEMENT" or event == "msdp.MOVEMENT_MAX" then
        StatusBar.update_gauge(StatusBar.movement, msdp.MOVEMENT, msdp.MOVEMENT_MAX)
    end
end

function StatusBar.protocolHandler(event, protocol)
    if protocol == "MSDP" then
        -- Request MSDP variables
        sendMSDP("REPORT", "HEALTH")
        sendMSDP("REPORT", "HEALTH_MAX")
        sendMSDP("REPORT", "MANA")
        sendMSDP("REPORT", "MANA_MAX")
        sendMSDP("REPORT", "MOVEMENT")
        sendMSDP("REPORT", "MOVEMENT_MAX")

        StatusBar.create()
    end
end

registerAnonymousEventHandler("sysProtocolEnabled", "StatusBar.protocolHandler")
registerAnonymousEventHandler("msdp.HEALTH", "StatusBar.eventHandler")
registerAnonymousEventHandler("msdp.HEALTH_MAX", "StatusBar.eventHandler")
registerAnonymousEventHandler("msdp.MANA", "StatusBar.eventHandler")
registerAnonymousEventHandler("msdp.MANA_MAX", "StatusBar.eventHandler")
registerAnonymousEventHandler("msdp.MOVEMENT", "StatusBar.eventHandler")
registerAnonymousEventHandler("msdp.MOVEMENT_MAX", "StatusBar.eventHandler")
