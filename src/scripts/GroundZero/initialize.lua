msdp = msdp or {}

function initMSDP(_, protocol)
    if protocol == "MSDP" then
        sendMSDP("REPORT", "CHARACTER_NAME", "SERVER_ID", "SERVER_TIME", "SNIPPET_VERSION",
            "AFFECTS", "WAIT_TIME", "EXPERIENCE", "EXPERIENCE_MAX", "EXPERIENCE_TNL", "HEALTH", "HEALTH_MAX",
            "LEVEL", "RACE", "CLASS", "MANA", "MANA_MAX", "WIMPY", "PRACTICE", "MONEY", "MOVEMENT",
            "MOVEMENT_MAX", "HITROLL", "DAMROLL", "AC", "STR", "INT", "WIS", "DEX", "CON", "STR_PERM",
            "INT_PERM", "WIS_PERM", "DEX_PERM", "CON_PERM", "CLASS_REMORTS", "OPPONENT_HEALTH",
            "OPPONENT_HEALTH_MAX", "OPPONENT_LEVEL", "OPPONENT_NAME", "AREA_NAME", "ROOM_EXITS", "ROOM_NAME",
            "ROOM_VNUM", "TERRAIN", "CLIENT_ID", "CLIENT_VERSION", "PLUGIN_ID", "ANSI_COLORS",
            "XTERM_256_COLORS", "UTF_8", "SOUND", "MXP")
        sendMSDP("XTERM_256_COLORS", "1")
    end
end

registerAnonymousEventHandler("sysProtocolEnabled", initMSDP)

function onExit()
    saveWindowLayout()
end

registerAnonymousEventHandler("sysExitEvent", onExit)

function onLoad()
    loadWindowLayout()
end

registerAnonymousEventHandler("sysLoadEvent", onLoad)
