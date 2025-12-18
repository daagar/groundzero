GZ = GZ or {}

function GZ.on_bark_skin_faded()
    local mv = tonumber(msdp.MOVEMENT) or 0
    send("afx")

    if mv > 30 then
        send("bark skin")
        send("afx")
    else
        cecho("<red>Warning: Cannot refresh bark skin (MV: " .. mv .. ", need > 30).<reset>\n")
    end
end

function GZ.on_bark_skin_started()
    send("afx")
end

registerAnonymousEventHandler("GZ.bark_skin_faded", "GZ.on_bark_skin_faded")
registerAnonymousEventHandler("GZ.bark_skin_started", "GZ.on_bark_skin_started")
