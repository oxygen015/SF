local config_module = SF_REQUIRE("config.lua")
local logger_module = SF_REQUIRE("logger.lua")
local serializer    = SF_REQUIRE("serializer.lua")
local decompiler    = SF_REQUIRE("decompiler.lua")
local file_utils    = SF_REQUIRE("file_utils.lua")

local Config = config_module.Config
local C      = config_module.C
local INDENT = config_module.INDENT
local Stats  = logger_module.Stats
local Live   = logger_module.Live

local saver = {}

local IGNORED_SET = {}
for _, cn in ipairs(Config.ignorelist) do IGNORED_SET[cn] = true end

local UNSERIALIZABLE_SET = {
    PackageLink=true, ScriptDebugger=true,
    PluginGui=true, PluginAction=true,
    AssetService=true, ContentProvider=true,
}

local function IsIgnored(inst)
    local ok, cn = pcall(function() return inst.ClassName end)
    if not ok then return true end
    return IGNORED_SET[cn] or UNSERIALIZABLE_SET[cn] or false
end

-- Optimization: CountAll with yields to prevent freezing
function saver.CountAll()
    local n = 0
    for _, svcName in ipairs(Config.saveservices) do
        local ok, svc = pcall(function() return game:GetService(svcName) end)
        if ok and svc then
            local ok2, desc = pcall(function() return svc:GetDescendants() end)
            n = n + (ok2 and #desc or 0) + 1
        end
        task.wait() -- Yield between services to keep UI responsive
    end
    return n
end

function saver.BuildOutput()
    local fpath      = (Config.savepath or "") .. file_utils.GetFileName() .. ".lua"
    local chunkBuf   = {}
    local chunkBytes = 0
    local yieldCounter = 0

    file_utils.EnsureSavePath()

    local function w(line)
        table.insert(chunkBuf, line)
        chunkBytes  = chunkBytes + #line + 1
        Live.bytes  = Live.bytes + #line + 1
    end

    local function flushChunk(force)
        if #chunkBuf == 0 then return end
        if force or Live.processed % Config.chunkSize == 0 then
            Live.chunkCount = Live.chunkCount + 1
            local text = table.concat(chunkBuf, "\n")
            chunkBuf   = {}
            chunkBytes = 0

            local ok, err
            if appendfile then
                ok, err = pcall(appendfile, fpath, text .. "\n")
            elseif writefile and Live.chunkCount == 1 then
                ok, err = pcall(writefile, fpath, text .. "\n")
            else
                return
            end

            if not ok then
                logger_module.Log("Chunk write failed: " .. tostring(err), C.RED)
            else
                logger_module.Log(string.format("  ✓ Chunk %d flushed  (%s total)",
                    Live.chunkCount, logger_module.FmtBytes(Live.bytes)), C.BLUE)
            end
            logger_module.SetChunkProgress(0)
        end
    end

    if writefile then
        pcall(writefile, fpath, "")
    end

    w("--Made With <3 by @699488 on Roblox!")
    w("--[[ Place: "..tostring(game.PlaceId).."  |  "..os.date().." ]]")
    w("")
    w("local Instances = {}")
    w("")
    flushChunk(true)

    local function Dump(inst, depth)
        if depth > Config.maxdepth then
            logger_module.UpdateStat("skipped", Stats.skipped + 1)
            return
        end

        local aliveOk = pcall(function() return inst.ClassName end)
        if not aliveOk then
            logger_module.UpdateStat("skipped", Stats.skipped + 1)
            return
        end

        if IsIgnored(inst) then
            logger_module.UpdateStat("skipped", Stats.skipped + 1)
            local children = file_utils.SafeChildren(inst)
            for _, child in ipairs(children) do
                pcall(Dump, child, depth + 1)
            end
            return
        end

        local waited = 0
        while waited < Config.timeout do
            local ok2, hasParent = pcall(function() return inst.Parent ~= nil end)
            if not ok2 or hasParent then break end
            task.wait(0.05)
            waited = waited + 0.05
        end

        local ok_cn, cn       = pcall(function() return inst.ClassName end)
        local ok_nm, instName = pcall(function() return inst.Name end)
        if not ok_cn then logger_module.UpdateStat("errors", Stats.errors+1); return end
        if not ok_nm then instName = cn end

        local fullName = file_utils.SafeFullName(inst)
        local pad2     = Config.prettify and string.rep(INDENT, depth) or ""
        local var      = "i_"..fullName:gsub("[^%w]","_")

        w(pad2..'local '..var..' = Instance.new("'..cn..'")')

        local ok_props, props = pcall(serializer.GetProperties, inst)
        if ok_props and props then
            for _, pair in ipairs(props) do
                if pair[1] ~= "Name" then
                    pcall(w, pad2..var..'["'..pair[1]..'"] = '..pair[2])
                end
            end
        end

        local safeName = instName:gsub("\\","\\\\"):gsub('"','\\"')
        w(pad2..var..'.Name = "'..safeName..'"')

        local isScript = false
        pcall(function()
            isScript = inst:IsA("BaseScript") or inst:IsA("ModuleScript")
        end)

        if isScript then
            logger_module.UpdateStat("scripts", Stats.scripts + 1)
            logger_module.Log("  Decompiling: "..instName, C.AMBER)
            local ok_dc, src = pcall(decompiler.TryDecompile, inst)
            src = ok_dc and src or "-- [[ Decompile threw an error ]]"
            w(pad2..var..'.Source = [==[')
            for line in (src.."\n"):gmatch("([^\n]*)\n") do
                w(pad2..line)
            end
            w(pad2..']==]')
        end

        w(pad2..'Instances['..string.format("%q", fullName)..'] = '..var)
        w("")

        Live.processed = Live.processed + 1
        logger_module.UpdateStat("saved", Stats.saved + 1)
        logger_module.SetProgress(Live.processed / math.max(Live.total, 1))

        local chunkPos = Live.processed % Config.chunkSize
        logger_module.SetChunkProgress(chunkPos / Config.chunkSize)

        logger_module.SetStatus("Copying "..cn.." › "..instName, C.TEXT_MID)
        pcall(function()
            local GUI = logger_module.GUI
            if GUI then
                GUI.curLabel.Text  = fullName
                GUI.copyLabel.Text = "["..cn.."]  "..instName
            end
        end)
        logger_module.UpdateMetrics()

        yieldCounter = yieldCounter + 1
        if yieldCounter % Config.yieldEvery == 0 then
            task.wait()
        end

        flushChunk(false)

        local children = file_utils.SafeChildren(inst)
        for _, child in ipairs(children) do
            local ok_dump, dump_err = pcall(Dump, child, depth + 1)
            if not ok_dump then
                logger_module.Log("  Skip child: "..serializer.SafeStr(dump_err), C.AMBER)
                logger_module.UpdateStat("errors", Stats.errors + 1)
            end
        end
    end

    for _, svcName in ipairs(Config.saveservices) do
        local ok, svc = pcall(function() return game:GetService(svcName) end)
        if ok and svc then
            logger_module.Log("-> "..svcName, C.TEXT_MID)
            local ok2, err2 = pcall(Dump, svc, 0)
            if not ok2 then
                logger_module.Log("✗ Service dump failed: "..serializer.SafeStr(err2), C.RED)
                logger_module.UpdateStat("errors", Stats.errors + 1)
            end
        else
            logger_module.Log("✗ Not found: "..svcName, C.AMBER)
        end
    end

    w("return Instances")
    flushChunk(true)

    if not appendfile then
        logger_module.Log("appendfile unavailable — single write at end.", C.AMBER)
        local text = table.concat(chunkBuf, "\n")
        if writefile then
            local ok, err = pcall(writefile, fpath, text)
            if not ok then
                logger_module.Log("Write failed: "..tostring(err), C.RED)
            else
                logger_module.Log("Saved (single write): "..fpath, C.GREEN)
            end
        else
            logger_module.Log("writefile unavailable — output to console.", C.AMBER)
            print(text)
        end
    else
        logger_module.Log("Saved: "..fpath, C.GREEN)
    end

    return fpath
end

return saver
