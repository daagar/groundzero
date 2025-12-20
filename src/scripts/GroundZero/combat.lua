GZ = GZ or {}
GZ.combat = GZ.combat or {}

-- Initialize strategy tables if they don't exist
GZ.combat.strategies = GZ.combat.strategies or {}
GZ.combat.strategies.openers = GZ.combat.strategies.openers or {
    "ambush",
    "bushwhack",
    "kick"
}
GZ.combat.strategies.in_combat = GZ.combat.strategies.in_combat or {
    "sword sweep",
    "bash",
    "kick"
}

--- Executes the first available skill from a given list based on level and class requirements.
-- @param skillList A table of skill names to check.
function GZ.combat.execute_strategy(skillList)
    if not skillList or #skillList == 0 then
        cecho("<red>Combat: No skills defined in this strategy list.\n")
        return
    end

    for _, skill in ipairs(skillList) do
        if GZ.canUse(skill) then
            send(skill .. " mob")
            return
        end
    end

    cecho("<yellow>Combat: No usable skills found for your current level and class in this strategy.\n")
end

--- Function to be called by the 'f' alias for opening combat.
function GZ.combat.f()
    GZ.combat.execute_strategy(GZ.combat.strategies.openers)
end

--- Function to be called by the 'ff' alias for in-combat actions.
function GZ.combat.ff()
    GZ.combat.execute_strategy(GZ.combat.strategies.in_combat)
end
