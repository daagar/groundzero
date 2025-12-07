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
    ["Inside"] = { id = 1, r = 130, g = 130, b = 130 },
    ["City"]   = { id = 2, r = 200, g = 200, b = 200 },
    ["Field"]  = { id = 3, r = 0, g = 170, b = 0 },
    ["Forest"] = { id = 4, r = 0, g = 122, b = 0 },
    ["Hills"]  = { id = 5, r = 122, g = 69, b = 0 },
    ["Smooth"] = { id = 6, r = 40, g = 40, b = 40 },
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

local function make_room()
    local info = map.room_info
    local coords = { 0, 0, 0 }
    addRoom(info.vnum)
    setRoomName(info.vnum, info.name)
    local areas = getAreaTable()
    local areaID = areas[info.area]
    if not areaID then
        areaID = addAreaName(info.area)
    else
        coords = { getRoomCoordinates(map.prev_info.vnum) }
        local shift = { 0, 0, 0 }
        for k, v in pairs(info.exits) do
            if v == map.prev_info.vnum and move_vectors[k] then
                shift = move_vectors[k]
                break
            end
        end
        for n = 1, 3 do
            coords[n] = coords[n] - shift[n]
        end
        -- map stretching
        local overlap = getRoomsByPosition(areaID, coords[1], coords[2], coords[3])
        if not table.is_empty(overlap) then
            local rooms = getAreaRooms(areaID)
            local rcoords
            for _, id in ipairs(rooms) do
                rcoords = { getRoomCoordinates(id) }
                for n = 1, 3 do
                    if shift[n] ~= 0 and (rcoords[n] - coords[n]) * shift[n] <= 0 then
                        rcoords[n] = rcoords[n] - shift[n]
                    end
                end
                setRoomCoordinates(id, rcoords[1], rcoords[2], rcoords[3])
            end
        end
    end
    setRoomArea(info.vnum, areaID)
    setRoomCoordinates(info.vnum, coords[1], coords[2], coords[3])
    if terrain_types[info.terrain] then
        setRoomEnv(info.vnum, terrain_types[info.terrain].id)
    end
    for dir, id in pairs(info.exits) do
        -- need to see how special exits are represented to handle those properly here
        if getRoomName(id) then
            setExit(info.vnum, id, dir)
        else
            setExitStub(info.vnum, dir, true)
        end
    end
end

local function shift_room(dir)
    local ID = map.room_info.vnum
    local x, y, z = getRoomCoordinates(ID)
    local x1, y1, z1 = unpack(move_vectors[dir])
    x = x + x1
    y = y + y1
    z = z + z1
    setRoomCoordinates(ID, x, y, z)
    updateMap()
end

local function set_terrain(terrain, vnum)
    if terrain_types[terrain] then
        setRoomEnv(vnum, terrain_types[terrain].id + 16)
    end
end

local function handle_move()
    local info = map.room_info

    if not getRoomName(info.vnum) then
        make_room()
    else
        for dir, id in pairs(info.exits) do
            -- need to see how special exits are represented to handle those properly here
            if getRoomName(id) then
                setExit(info.vnum, id, dir)
            else
                setExitStub(info.vnum, dir, true)
            end
        end
    end
    set_terrain(info.terrain, info.vnum)
    centerview(map.room_info.vnum)
end

local function config()
    sendMSDP("REPORT", "ROOM_VNUM")
    sendMSDP("REPORT", "ROOM_NAME")
    sendMSDP("REPORT", "AREA_NAME")
    sendMSDP("REPORT", "ROOM_EXITS")
    sendMSDP("REPORT", "TERRAIN")

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
        map.prev_info = map.room_info
        map.room_info = {
            vnum = tonumber(msdp.ROOM_VNUM),
            area = msdp.AREA_NAME,
            name = msdp.ROOM_NAME,
            exits = msdp.ROOM_EXITS,
            terrain = msdp.TERRAIN
        }
        map.room_info.exits = parseDirections(map.room_info.exits)
        -- for k,v in pairs(directions) do
        -- map.room_info.exits[k] = tonumber(v)
        -- end
        handle_move()
    elseif event == "shiftRoom" then
        local dir = exits[arg[1]] or arg[1]
        if not table.contains(exits, dir) then
            echo("Error: Invalid direction '" .. dir .. "'.")
        else
            shift_room(dir)
        end
    elseif event == "sysConnectionEvent" then
        config()
    end
end

function parseDirections(str)
    local map = {}
    -- %w+ matches one or more alphanumeric characters (the key)
    -- %d+ matches one or more digits (the value)
    for key, value in string.gmatch(str, "(%w+)%s*=%s*(%d+)") do
        map[key] = tonumber(value) -- store the numeric value
    end
    return map
end

registerAnonymousEventHandler("onNewRoom", "map.eventHandler")
-- registerAnonymousEventHandler("msdp.ROOM_VNUM","map.eventHandler")
-- registerAnonymousEventHandler("msdp.TERRAIN","map.eventHandler")
registerAnonymousEventHandler("shiftRoom", "map.eventHandler")
registerAnonymousEventHandler("sysConnectionEvent", "map.eventHandler")
