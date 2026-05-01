local function get_content(path)
    if not readfile then return nil end
    local ok, content = pcall(readfile, path)
    if ok and content and #content > 0 then
        return content
    end
    return nil
end

local function load_module(name)
    local tried = {}
    local cleaned_name = name:gsub("%.lua$", "")
    local paths = {
        "SF/src/" .. cleaned_name .. ".lua",
        "src/" .. cleaned_name .. ".lua",
        "SF/" .. cleaned_name .. ".lua",
        cleaned_name .. ".lua",
        "SF/src/" .. name,
        "src/" .. name,
        "SF/" .. name,
        name
    }

    for _, path in ipairs(paths) do
        if not tried[path] then
            tried[path] = true
            table.insert(tried, path)
            local content = get_content(path)
            if content then
                local func, err = loadstring(content)
                if not func then
                    error("Error compiling module " .. name .. " (" .. path .. "): " .. tostring(err))
                end
                return func()
            end
        end
    end

    error("Could not find module: " .. name .. "\n\nMake sure the 'SF' folder is in your workspace and contains 'src'.\n\nAttempted paths:\n - " .. table.concat(tried, "\n - "))
end

local env = (getgenv and getgenv()) or _G
env.SF_REQUIRE = load_module

load_module("init.lua")