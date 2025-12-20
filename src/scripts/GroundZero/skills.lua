GZ = GZ or {}
GZ.classSkills = GZ.classSkills or {}

GZ.classSkills.ranger = {
    ["kick"] = 1,
    ["natures renewal"] = 1,
    ["shoot"] = 1,
    ["sneak"] = 1,
    ["swordplay"] = 1,
    ["pick lock"] = 2,
    ["cure light"] = 3,
    ["rescue"] = 5,
    ["track"] = 5,
    ["first aid"] = 6,
    ["bash"] = 9,
    ["catseye"] = 9,
    ["dual wield"] = 9,
    ["hide"] = 9,
    ["animal spirit"] = 12,
    ["create water"] = 12,
    ["detect poison"] = 12,
    ["bushwhack"] = 15,
    ["invigorate"] = 15,
    ["remove curse"] = 15,
    ["remove poison"] = 15,
    ["bark skin"] = 15,
    ["ambush"] = 16,
    ["heal"] = 16,
    ["grapple"] = 20,
    ["control weather"] = 25,
    ["parry"] = 25,
    ["sword sweep"] = 30,
}

--- Checks if a character can use a specific skill based on their class and level.
-- @param skillName The name of the skill to check (case-insensitive).
-- @param class (Optional) The class to check against. Defaults to msdp.CLASS.
-- @param level (Optional) The level to check against. Defaults to msdp.LEVEL.
-- @return boolean True if the skill can be used, false otherwise.
function GZ.canUse(skillName, class, level)
    local skill = string.lower(skillName)
    local charClass = string.lower(class or msdp.CLASS or "")
    local charLevel = tonumber(level or msdp.LEVEL or 0)

    if not GZ.classSkills[charClass] then
        return false
    end

    local requiredLevel = GZ.classSkills[charClass][skill]
    if not requiredLevel then
        return false
    end

    return charLevel >= requiredLevel
end
