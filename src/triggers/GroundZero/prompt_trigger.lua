-- Initialize global GZ table if needed
GZ = GZ or {}
GZ.player = GZ.player or {}
GZ.combat = GZ.combat or {}

-- matches[2]: AFK status (e.g. " AFK" or nil)
if matches[2] and matches[2] ~= "" then
    GZ.player.afk = true
else
    GZ.player.afk = false
end

-- matches[3]: Combat Target Name
-- matches[4]: Combat Target Health
if matches[3] and matches[3] ~= "" then
    GZ.combat.active = true
    GZ.combat.target_name = matches[3]
    GZ.combat.target_health = tonumber(matches[4])
else
    GZ.combat.active = false
    GZ.combat.target_name = nil
    GZ.combat.target_health = nil
end

-- matches[5]: Level
-- matches[6]: TNL
GZ.player.level = tonumber(matches[5])
GZ.player.tnl = tonumber(matches[6])

-- matches[7]: Mobs Count
if matches[7] and matches[7] ~= "" then
    GZ.mobs_in_room = tonumber(matches[7])
else
    GZ.mobs_in_room = 0
end

-- Force status bar update if available
if StatusBar and StatusBar.update_all then
    StatusBar.update_all()
end
