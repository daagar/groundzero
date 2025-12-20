GZ = GZ or {}
GZ.last_dir = GZ.last_dir or "n"

local directions = {
    n = "n",
    s = "s",
    e = "e",
    w = "w",
    u = "u",
    d = "d",
    north = "n",
    south = "s",
    east = "e",
    west = "w",
    up = "u",
    down = "d"
}

function GZ.on_send_command(event, command)
    -- This event fires with the command string.
    -- We want to see if it's a simple direction.
    local cmd = string.lower(command):trim()
    if directions[cmd] then
        GZ.last_dir = cmd
    end
end

-- register the event handler
if GZ.send_handler_id then
    killAnonymousEventHandler(GZ.send_handler_id)
end
GZ.send_handler_id = registerAnonymousEventHandler("sysDataSendRequest", "GZ.on_send_command")

function GZ.on_door_closed(event, door)
    if GZ.last_dir then
        GZ.last_door = door
        send("open " .. door)
        send(GZ.last_dir)
    end
end

function GZ.on_door_locked()
    -- Check if we have the pick lock skill and have a door/direction to use
    if GZ.canUse("pick lock") and GZ.last_door and GZ.last_dir then
        send("pick " .. GZ.last_door)
        -- A successful pick lock now automatically opens the door, so send the move command
        send(GZ.last_dir)
    end
end

registerAnonymousEventHandler("GZ.door_closed", "GZ.on_door_closed")
registerAnonymousEventHandler("GZ.door_locked", "GZ.on_door_locked")
