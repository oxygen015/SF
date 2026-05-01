--[[
    SF SaveInstance v3.1 Loader
    Modular Refactor by Antigravity
    
    This script loads the SF system from the /src directory.
--]]

local BASE_PATH = "SF/src/" -- Adjust this if your folder name is different

local function load_module(name)
    local path = BASE_PATH .. name
    if not readfile then
        error("Executor does not support readfile. Modular SF requires readfile.")
    end
    
    local ok, content = pcall(readfile, path)
    if not ok or not content then
        -- Try without the SF/ prefix just in case
        path = "src/" .. name
        ok, content = pcall(readfile, path)
        if not ok or not content then
            error("Could not find module: " .. name .. " at " .. path)
        end
    end
    
    local func, err = loadstring(content)
    if not func then
        error("Error compiling module " .. name .. ": " .. tostring(err))
    end
    
    return func()
end

-- Define global require for modules to use
_G.SF_REQUIRE = load_module

-- Start the system
load_module("init.lua")