map = map or {}
map.room_info = map.room_info or {}
map.prev_info = map.prev_info or {}
map.aliases = map.aliases or {}

local defaults = {
    -- using Geyser to handle the mapper in this, since this is a totally new script
    mapper = { x = "-31%", y = 0, width = "30%", height = "50%" }
}

local terrain_types = {
    -- used to make rooms of different terrain types have different colors
    -- add a new entry for each terrain type, and set the color with RGB values
    -- each id value must be unique, terrain types not listed here will use mapper default color
    ["Inside"]   = { id = 1, r = 130, g = 130, b = 130 },
    ["Moutains"] = { id = 2, r = 200, g = 200, b = 200 },
    ["Field"]    = { id = 3, r = 0, g = 170, b = 0 },
    ["Forest"]   = { id = 4, r = 0, g = 122, b = 0 },
    ["Hills"]    = { id = 5, r = 122, g = 69, b = 0 },
    ["Smooth"]   = { id = 6, r = 40, g = 40, b = 40 },
    ["Swamp"]    = { id = 7, r = 42, g = 64, b = 49 },
    ["Tundra"]   = { id = 8, r = 96, g = 99, b = 38 },
    ["Water"]    = { id = 9, r = 51, g = 114, b = 145 },
    ["Desert"]   = { id = 10, r = 173, g = 143, b = 54 },
}

-- list of possible movement directions and appropriate coordinate changes
local move_vectors = {
    north = { 0, 1, 0 },
    south = { 0, -1, 0 },
    east = { 1, 0, 0 },
    west = { -1, 0, 0 },
    northwest = { -1, 1, 0 },
    northeast = { 1, 1, 0 },
    southwest = { -1, -1, 0 },
    southeast = { 1, -1, 0 },
    up = { 0, 0, 1 },
    down = { 0, 0, -1 }
}

-- used to convert short dirs for full dirs
local exits = {
    n = "north",
    s = "south",
    w = "west",
    e = "east",
    nw = "northwest",
    ne = "northeast",
    sw = "southwest",
    se = "southeast",
    u = "up",
    d = "down"
}

local exitmap = {
    [1] = "north",
    [2] = "northeast",
    [3] = "northwest",
    [4] = "east",
    [5] = "west",
    [6] = "south",
    [7] = "southeast",
    [8] = "southwest",
    [9] = "up",
    [10] = "down",
    [11] = "in",
    [12] = "out",
}

local function parseDirections(str)
    local exit_map = {}
    if not str then return exit_map end
    for key, value in string.gmatch(str, "(%w+)%s*=%s*(%d+)") do
        exit_map[key] = tonumber(value)
    end
    return exit_map
end

local function resolve_dir(dir)
    if not dir then return nil end
    dir = string.lower(dir)
    return exits[dir] or dir
end

local function update_exits(vnum, exit_list)
    for dir, id in pairs(exit_list) do
        local long_dir = resolve_dir(dir)
        if long_dir then
            if getRoomName(id) then
                setExit(vnum, id, long_dir)
            else
                setExitStub(vnum, long_dir, true)
            end
        end
    end
end

local function make_room()
    local info = map.room_info
    if not info or not info.vnum then return end

    local coords = { 0, 0, 0 }
    addRoom(info.vnum)
    setRoomName(info.vnum, info.name)
    local areas = getAreaTable()
    local areaID = areas[info.area]
    if not areaID then
        areaID = addAreaName(info.area)
    elseif map.prev_info and map.prev_info.vnum and getRoomName(map.prev_info.vnum) then
        coords = { getRoomCoordinates(map.prev_info.vnum) }
        local shift = { 0, 0, 0 }
        local found = false

        -- try to find backlink
        for k, v in pairs(info.exits) do
            local dir = resolve_dir(k)
            if v == map.prev_info.vnum and dir and move_vectors[dir] then
                shift = move_vectors[dir]
                found = true
                break
            end
        end

        -- try to find forward link
        if not found and map.prev_info.exits then
            for k, v in pairs(map.prev_info.exits) do
                local dir = resolve_dir(k)
                if v == info.vnum and dir and move_vectors[dir] then
                    local vec = move_vectors[dir]
                    shift = { -vec[1], -vec[2], -vec[3] }
                    found = true
                end
            end
        end

        for n = 1, 3 do
            coords[n] = coords[n] - shift[n]
        end

        -- map stretching
        local overlap = getRoomsByPosition(areaID, coords[1], coords[2], coords[3])
        if found and not table.is_empty(overlap) then
            local rooms = getAreaRooms(areaID)
            local rcoords
            for _, id in ipairs(rooms) do
                rcoords = { getRoomCoordinates(id) }
                local modified = false
                for n = 1, 3 do
                    if shift[n] ~= 0 and (rcoords[n] - coords[n]) * shift[n] <= 0 then
                        rcoords[n] = rcoords[n] - shift[n]
                        modified = true
                    end
                end
                if modified then
                    setRoomCoordinates(id, rcoords[1], rcoords[2], rcoords[3])
                end
            end
        end
    end
    setRoomArea(info.vnum, areaID)
    setRoomCoordinates(info.vnum, coords[1], coords[2], coords[3])

    if terrain_types[info.terrain] then
        setRoomEnv(info.vnum, terrain_types[info.terrain].id + 16)
    end

    update_exits(info.vnum, info.exits)

    -- Bidirectional linking with previous room
    if map.prev_info and map.prev_info.vnum and getRoomName(map.prev_info.vnum) then
        -- Link Previous -> Current
        if map.prev_info.exits then
            for k, v in pairs(map.prev_info.exits) do
                if v == info.vnum then
                    local dir = resolve_dir(k)
                    if dir then
                        setExit(map.prev_info.vnum, info.vnum, dir)
                    end
                end
            end
        end

        -- Link Current -> Previous (Force specific exit to be a link instead of stub)
        for k, v in pairs(info.exits) do
            if v == map.prev_info.vnum then
                local dir = resolve_dir(k)
                if dir then
                    setExit(info.vnum, map.prev_info.vnum, dir)
                end
            end
        end
    end
end

local function shift_room(dir)
    local ID = map.room_info.vnum
    if not ID or not getRoomName(ID) then return end

    local x, y, z = getRoomCoordinates(ID)
    local vector = move_vectors[dir]
    if vector then
        x = x + vector[1]
        y = y + vector[2]
        z = z + vector[3]
        setRoomCoordinates(ID, x, y, z)
        updateMap()
    end
end

local function set_terrain(terrain, vnum)
    if terrain_types[terrain] then
        setRoomEnv(vnum, terrain_types[terrain].id + 16)
    end
end

local function handle_move()
    local info = map.room_info
    if not info or not info.vnum then return end

    if not getRoomName(info.vnum) then
        make_room()
    else
        update_exits(info.vnum, info.exits)
    end
    set_terrain(info.terrain, info.vnum)
    centerview(map.room_info.vnum)
end

local function config()
    -- setting terrain colors
    for k, v in pairs(terrain_types) do
        setCustomEnvColor(v.id + 16, v.r, v.g, v.b, 255)
    end
    -- making mapper window
    local info = defaults.mapper
    map.container = Adjustable.Container:new({
        name = "mapContainer",
        x = info.x,
        y = info.y,
        width = info.width,
        height = info.height,
        adjLabelstyle = "background-color:rgba(50,50,50,100%); border: 2px solid #505050;",
    })
    Geyser.Mapper:new({ name = "myMap", x = 0, y = 0, width = "100%", height = "100%" }, map.container)

    -- clearing existing aliases if they exist
    for k, v in pairs(map.aliases) do
        killAlias(v)
    end
    map.aliases = {}
    -- making an alias to let the user shift a room around via command line
    table.insert(map.aliases, tempAlias([[^shift (\w+)$]], [[raiseEvent("shiftRoom",matches[2])]]))
    table.insert(map.aliases, tempAlias([[^make_room$]], [[make_room()]]))
end

function map.eventHandler(event, ...)
    if event == "onNewRoom" then
        map.prev_info = map.room_info or {}
        map.room_info = {
            vnum = tonumber(msdp.ROOM_VNUM),
            area = msdp.AREA_NAME,
            name = msdp.ROOM_NAME,
            exits = msdp.ROOM_EXITS,
            terrain = msdp.TERRAIN
        }
        map.room_info.exits = parseDirections(map.room_info.exits or "")
        handle_move()
    elseif event == "shiftRoom" then
        local dir = resolve_dir(arg[1])
        if not dir then
            echo("Error: Invalid direction '" .. (arg[1] or "") .. "'.")
        else
            shift_room(dir)
        end
    elseif event == "sysConnectionEvent" or event == "sysInstall" then
        config()
    end
end

-- Event Handler Registration with cleanup
map.handlerIDs = map.handlerIDs or {}
local events = { "onNewRoom", "shiftRoom", "sysConnectionEvent", "sysInstall" }
for _, event in ipairs(events) do
    if map.handlerIDs[event] then
        killAnonymousEventHandler(map.handlerIDs[event])
    end
    map.handlerIDs[event] = registerAnonymousEventHandler(event, "map.eventHandler")
end
