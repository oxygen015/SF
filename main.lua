--[[
    SF SaveInstance v3.2 Loader (Self-Healing)
    
    This loader will automatically try to find modules locally in your workspace.
    If they are missing, it will fetch them from GitHub to ensure everything works perfectly.
--]]

local GITHUB_BASE = "https://raw.githubusercontent.com/oxygen015/SF/main/src/"

local function get_content(name)
    local cleaned_name = name:gsub("%.lua$", "")
    local tried = {}
    
    -- 1. Try local paths
    if readfile then
        local local_paths = {
            "SF/src/" .. cleaned_name .. ".lua",
            "src/" .. cleaned_name .. ".lua",
            "SF/" .. cleaned_name .. ".lua",
            cleaned_name .. ".lua",
            "SF/src/" .. name,
            "src/" .. name,
            "SF/" .. name,
            name
        }
        for _, path in ipairs(local_paths) do
            if not tried[path] then
                tried[path] = true
                local ok, content = pcall(readfile, path)
                if ok and content and #content > 0 then
                    print("[SF Loader] Loaded local: " .. path)
                    return content
                end
            end
        end
    end
    
    -- 2. Try GitHub fallback
    local github_path = GITHUB_BASE .. name
    if not github_path:find("%.lua$") then github_path = github_path .. ".lua" end
    
    print("[SF Loader] Attempting GitHub fallback: " .. name)
    local ok, content = pcall(game.HttpGet, game, github_path)
    if ok and content and #content > 0 then
        print("[SF Loader] Loaded from GitHub: " .. name)
        return content
    end
    
    error("[SF Loader] Failed to load module: " .. name .. "\nChecked local workspace and GitHub fallback.")
end

local function load_module(name)
    local content = get_content(name)
    local func, err = loadstring(content)
    if not func then
        error("[SF Loader] Syntax error in " .. name .. ": " .. tostring(err))
    end
    return func()
end

local env = (getgenv and getgenv()) or _G
env.SF_REQUIRE = load_module

print("[SF Loader] Initializing SF SaveInstance...")
load_module("init.lua")