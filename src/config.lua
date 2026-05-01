local Config = {
    timeout         = 10,
    scriptdump      = true,
    prettify        = true,
    savepath        = "workspace/SF/",
    filename        = nil,
    decompilerTimeout = 3,       -- seconds before we skip a stuck script
    chunkSize       = 75,        -- write to file every N instances
    yieldEvery      = 200,       -- task.wait() every N instances
    logtofile       = false,
    maxdepth        = 512,
    ignorelist      = {
        "CoreGui", "CoreScript",
    },
    saveservices    = {
        "Workspace",
        "ReplicatedStorage",
        "ReplicatedFirst",
        "ServerScriptService",
        "ServerStorage",
        "StarterGui",
        "StarterPack",
        "StarterPlayer",
        "Teams",
        "SoundService",
        "Lighting",
    },
}

local C = {
    RED         = Color3.fromRGB(220, 38,  38),
    RED_DIM     = Color3.fromRGB(127, 29,  29),
    RED_DARK    = Color3.fromRGB(69,  10,  10),
    RED_GLOW    = Color3.fromRGB(239, 68,  68),
    BLACK       = Color3.fromRGB(0,   0,   0),
    BG_WIN      = Color3.fromRGB(6,   6,   6),
    BG_HEADER   = Color3.fromRGB(10,  10,  10),
    BG_CARD     = Color3.fromRGB(13,  13,  13),
    BG_INSET    = Color3.fromRGB(4,   4,   4),
    BORDER      = Color3.fromRGB(22,  22,  22),
    BORDER_RED  = Color3.fromRGB(80,  15,  15),
    TEXT_HI     = Color3.fromRGB(240, 240, 240),
    TEXT_MID    = Color3.fromRGB(110, 110, 110),
    TEXT_LOW    = Color3.fromRGB(48,  48,  48),
    GREEN       = Color3.fromRGB(52,  211, 100),
    AMBER       = Color3.fromRGB(217, 160, 40),
    BLUE        = Color3.fromRGB(59,  130, 246),
    TOGGLE_ON   = Color3.fromRGB(34,  197, 94),
    TOGGLE_OFF  = Color3.fromRGB(39,  39,  39),
}

return {
    Config = Config,
    C = C,
    ICON_ID = "rbxassetid://83424694432344",
    INDENT = "    "
}
