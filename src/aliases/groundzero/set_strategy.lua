local type = matches[2]
local list_str = matches[3]
local list = {}

for skill in string.gmatch(list_str, "([^,]+)") do
    table.insert(list, string.trim(skill))
end

if type == "openers" then
    GZ.combat.strategies.openers = list
    cecho("<green>Combat: Openers updated to: <white>" .. table.concat(list, ", ") .. "\n")
elseif type == "in-combat" then
    GZ.combat.strategies.in_combat = list
    cecho("<green>Combat: In-combat skills updated to: <white>" .. table.concat(list, ", ") .. "\n")
end
