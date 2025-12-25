GZ = GZ or {}
GZ.player = GZ.player or {}
GZ.combat = GZ.combat or {}

function GZ.on_prompt(event, matches)
    -- matches[2]: AFK status (e.g. " AFK" or nil)
    if matches[2] and matches[2] ~= "" then
        GZ.player.afk = true
    else
        GZ.player.afk = false
    end

    -- matches[3]: Combat Target Name
    -- matches[4]: Combat Target Health
    local was_combat = GZ.combat.active
    if matches[3] and matches[3] ~= "" then
        GZ.combat.active = true
        GZ.combat.target_name = matches[3]
        GZ.combat.target_health = tonumber(matches[4])
    else
        GZ.combat.active = false
        GZ.combat.target_name = nil
        GZ.combat.target_health = nil
    end

    if was_combat and not GZ.combat.active then
        raiseEvent("GZ.combat_ended")
    end

    -- matches[5]: Level
    -- matches[6]: TNL
    GZ.player.level = tonumber(matches[5])
    GZ.player.tnl = tonumber(matches[6])

    -- matches[7]: Mobs Count
    local new_mobs = tonumber(matches[7]) or 0
    local now = getEpoch()

    -- Only update from prompt if enough time has passed since a manual kill,
    -- OR if the new value is actually lower than our current manual estimate.
    if not GZ.last_mob_death_time or (now - GZ.last_mob_death_time > 1.5) then
        GZ.mobs_in_room = new_mobs
    else
        -- Recently died, only trust the prompt if it shows even FEWER mobs than our current estimate
        if new_mobs < (GZ.mobs_in_room or 0) then
            GZ.mobs_in_room = new_mobs
        end
    end

    GZ.player.wait = matches[8]
    

    -- Close affects capture if active
    raiseEvent("GZ.affects_end")

    -- Signal UI update
    raiseEvent("GZ.update_ui")
end

function GZ.on_exp_received(event, amount)
    if GZ.mobs_in_room and GZ.mobs_in_room > 0 then
        GZ.mobs_in_room = GZ.mobs_in_room - 1
        -- Record timestamp of death to prevent prompt overwrite for 1.5 seconds
        GZ.last_mob_death_time = getEpoch()
    end

    -- Signal UI update
    raiseEvent("GZ.update_ui")
end

registerAnonymousEventHandler("GZ.prompt_received", "GZ.on_prompt")
registerAnonymousEventHandler("GZ.exp_received", "GZ.on_exp_received")
