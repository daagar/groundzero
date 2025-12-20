GZ = GZ or {}
GZ.player = GZ.player or {}
GZ.combat = GZ.combat or {}
GZ.levelUpdates = GZ.levelUpdates or {}

function GZ.onLevelUpMessage()
    local currentLevel = tonumber(msdp.LEVEL or (GZ.player and GZ.player.level) or 0)
    local nextLevel = currentLevel + 1
    local class = string.lower(msdp.CLASS or "")

    if class == "" then
        -- If class is unknown, we might not be able to find skills yet
        -- We'll mark it as pending and try again when the prompt/msdp updates
        GZ.levelUpdates.pending = true
        return
    end

    GZ.checkAndQueueSkills(class, nextLevel)
    send("wimp full") -- set wimpy to half hit points
end

function GZ.checkAndQueueSkills(class, level)
    local skills = GZ.classSkills[class]
    if not skills then return end

    local newSkills = {}
    for skill, reqLevel in pairs(skills) do
        if reqLevel == level then
            table.insert(newSkills, skill)
        end
    end

    if #newSkills > 0 then
        GZ.levelUpdates.pendingSkills = newSkills
        GZ.levelUpdates.level = level

        if not (GZ.combat and GZ.combat.active) then
            GZ.announceLevelSkills()
        end
    end
end

function GZ.announceLevelSkills()
    if not GZ.levelUpdates.pendingSkills or #GZ.levelUpdates.pendingSkills == 0 then
        return
    end

    local skillsList = table.concat(GZ.levelUpdates.pendingSkills, ", ")
    local level = GZ.levelUpdates.level or "new"

    cecho(string.format("\n<yellow>Congratulations on level %s! Newly gained skills: <white>%s\n", level, skillsList))

    -- Clear pending
    GZ.levelUpdates.pendingSkills = nil
    GZ.levelUpdates.level = nil
    GZ.levelUpdates.pending = false
end

function GZ.handleCombatEnd()
    if GZ.levelUpdates.pendingSkills then
        GZ.announceLevelSkills()
    end
end

registerAnonymousEventHandler("GZ.combat_ended", "GZ.handleCombatEnd")
