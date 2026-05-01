local config_module = _G.SF_REQUIRE("config.lua")
local Config = config_module.Config

local file_utils = {}

function file_utils.EnsureSavePath()
    if not Config.savepath or not makefolder then return end
    local built = ""
    for part in Config.savepath:gmatch("[^/]+") do
        built = built == "" and part or (built .. "/" .. part)
        pcall(makefolder, built)
    end
end

function file_utils.GetFileName()
    if Config.filename then return Config.filename end
    local ok, info = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    end)
    local pname = (ok and info and type(info.Name)=="string")
        and info.Name:gsub("[^%w%s%-_]",""):gsub("%s+","_"):sub(1,40)
        or  "Place_"..tostring(game.PlaceId)
    return pname.."_"..os.date("%Y%m%d_%H%M%S")
end

function file_utils.SafeFullName(inst)
    local ok, s = pcall(function() return inst:GetFullName() end)
    return ok and s or ("unknown_"..tostring(inst))
end

function file_utils.SafeChildren(inst)
    local ok, c = pcall(function() return inst:GetChildren() end)
    return ok and c or {}
end

return file_utils
