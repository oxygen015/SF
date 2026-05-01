local config_module = _G.SF_REQUIRE("config.lua")
local logger_module = _G.SF_REQUIRE("logger.lua")
local Config = config_module.Config
local C = config_module.C

local decompiler = {}

function decompiler.TryDecompile(scr)
    if not Config.scriptdump then return "-- scriptdump disabled" end

    if decompile then
        local result, done = nil, false
        task.spawn(function()
            local ok, src = pcall(decompile, scr)
            if ok and type(src) == "string" and #src > 0 then
                result = src
            end
            done = true
        end)
        local t0 = os.clock()
        while not done and (os.clock() - t0) < Config.decompilerTimeout do
            task.wait(0.05)
        end
        if not done then
            logger_module.Log("  [timeout] decompiler stuck — skipping script", C.AMBER)
            logger_module.UpdateStat("skipped", logger_module.Stats.skipped + 1)
            return "-- [[ Decompiler timed out after " .. Config.decompilerTimeout .. "s ]]"
        end
        if result then return result end
    end

    if getscriptbytecode then
        local ok, bc = pcall(getscriptbytecode, scr)
        if ok and type(bc) == "string" and #bc > 0 then
            return "-- [[ Bytecode only — no decompiler  len=" .. #bc .. " ]]"
        end
    end
    return "-- [[ Decompilation unavailable ]]"
end

return decompiler
