GZ = GZ or {}

function GZ.onDeath()
    cecho("<red>Death detected! Running recovery sequence...\n")

    -- Send "1" to reconnect/re-enter
    send("1")

    -- standard recovery
    send("retrieve corpse")
    send("get all from corpse")
    send("wear all")
    send("get all from bag")

    -- Class-specific recovery
    if GZ.canUse("bark skin") then
        send("bark skin")
    end
    if GZ.canUse("invigorate") then
        send("invig")
    end
end

-- Register the event handler
if GZ.death_handler_id then
    killAnonymousEventHandler(GZ.death_handler_id)
end
GZ.death_handler_id = registerAnonymousEventHandler("GZ_onDeath", "GZ.onDeath")
