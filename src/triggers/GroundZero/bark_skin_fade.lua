local mv = tonumber(msdp.MOVEMENT) or 0
send("afx")

if mv > 30 then
    send("bark skin")
    send("afx")
else
    cecho("<red>Warning: Cannot refresh bark skin (MV: " .. mv .. ", need > 30).<reset>\n")
end
