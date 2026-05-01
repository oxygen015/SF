-- SF SaveInstance v3.1 Init
-- Modular Entry Point

local config_module = SF_REQUIRE("config.lua")
local logger_module = SF_REQUIRE("logger.lua")
local ui_main       = SF_REQUIRE("ui_main.lua")
local ui_config     = SF_REQUIRE("ui_config.lua")
local saver         = SF_REQUIRE("saver.lua")

local Config = config_module.Config
local C      = config_module.C
local Stats  = logger_module.Stats
local Live   = logger_module.Live

local TweenService = game:GetService("TweenService")

local GUI = ui_main.CreateGUI()
logger_module.GUI = GUI
ui_config.BuildConfigPanel(GUI)

local running = false

local function RunSave()
    if running then
        logger_module.Log("Already running.", C.AMBER)
        return
    end
    running = true
    logger_module.ResetAll()
    logger_module.SetStatus("Counting instances...", C.TEXT_MID)
    logger_module.Log("------- SF SaveInstance v3.1 started -------", C.TEXT_HI)
    logger_module.Log(string.format(
        "scriptdump=%s  prettify=%s  timeout=%ds  chunkSize=%d  yieldEvery=%d  path=%s",
        tostring(Config.scriptdump), tostring(Config.prettify),
        Config.timeout, Config.chunkSize, Config.yieldEvery,
        tostring(Config.savepath or "default")), C.TEXT_LOW)

    task.spawn(function()
        local ok, err = pcall(function()
            local total = saver.CountAll()
            Live.total     = total
            Live.startTime = os.clock()
            if GUI then GUI.metricLabels.instances.Text = "0 / "..total end
            logger_module.Log("Total instances: "..total, C.TEXT_MID)

            local fpath = saver.BuildOutput()

            if Config.logtofile and writefile then
                local lname = saver.GetFileName()..".log"
                pcall(writefile, (Config.savepath or "")..lname, table.concat({
                    "SF SaveInstance Log  v3.1",
                    os.date(),
                    "Place:   "..tostring(game.PlaceId),
                    "Saved:   "..Stats.saved,
                    "Skipped: "..Stats.skipped,
                    "Scripts: "..Stats.scripts,
                    "Errors:  "..Stats.errors,
                    "Chunks:  "..Live.chunkCount,
                    "Size:    "..logger_module.FmtBytes(Live.bytes),
                    "Time:    "..logger_module.FmtTime(os.clock()-Live.startTime),
                }, "\n"))
                logger_module.Log("Log written.", C.TEXT_LOW)
            end

            logger_module.SetProgress(1)
            logger_module.SetChunkProgress(1)
            logger_module.UpdateMetrics()
            local elapsed = logger_module.FmtTime(os.clock()-Live.startTime)
            logger_module.SetStatus(string.format(
                "Done — %d saved  %d errors  %s  %s",
                Stats.saved, Stats.errors, logger_module.FmtBytes(Live.bytes), elapsed), C.GREEN)
            
            pcall(function()
                if GUI then
                    GUI.curLabel.Text  = "Complete."
                    GUI.copyLabel.Text = "All done!"
                end
            end)
            logger_module.Log(string.format(
                "--- Done  saved=%d  scripts=%d  errors=%d  chunks=%d  size=%s  time=%s ---",
                Stats.saved, Stats.scripts, Stats.errors,
                Live.chunkCount, logger_module.FmtBytes(Live.bytes), elapsed), C.GREEN)
        end)

        if not ok then
            logger_module.SetStatus("Error: "..tostring(err), C.RED)
            logger_module.Log("Fatal: "..tostring(err), C.RED)
        end
        running = false
    end)
end

-- Tab switching logic
local function showTab(which)
    GUI.savePage.Visible = (which == "save")
    GUI.cfgPage.Visible  = (which == "cfg")

    TweenService:Create(GUI.tabRunBtn, TweenInfo.new(0.12), {
        BackgroundColor3 = which=="save" and C.RED_DARK or C.BG_CARD,
        TextColor3       = which=="save" and C.RED_GLOW  or C.TEXT_MID,
    }):Play()
    TweenService:Create(GUI.tabCfgBtn, TweenInfo.new(0.12), {
        BackgroundColor3 = which=="cfg"  and C.RED_DARK or C.BG_CARD,
        TextColor3       = which=="cfg"  and C.RED_GLOW  or C.TEXT_MID,
    }):Play()
end

GUI.tabRunBtn.MouseButton1Click:Connect(function() showTab("save") end)
GUI.tabCfgBtn.MouseButton1Click:Connect(function() showTab("cfg")  end)

GUI.runBtn.MouseButton1Click:Connect(function()
    showTab("save")
    RunSave()
end)

GUI.closeBtn.MouseButton1Click:Connect(function()
    if running then
        logger_module.Log("Cannot close — save in progress.", C.RED)
        return
    end
    TweenService:Create(GUI.overlay,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad),
        {BackgroundTransparency=1}):Play()
    TweenService:Create(GUI.win,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad),
        {BackgroundTransparency=1}):Play()
    task.delay(0.35, function() GUI.sg:Destroy() end)
end)

GUI.clearBtn.MouseButton1Click:Connect(function()
    for _, v in ipairs(GUI.logScroll:GetChildren()) do
        if v:IsA("TextLabel") then v:Destroy() end
    end
    GUI.logEntryCount = 0
    GUI.logCount.Text = "0 entries"
    logger_module.Log("Log cleared.", C.TEXT_LOW)
end)

logger_module.Log("SF SaveInstance v3.1 loaded (Modular).", C.TEXT_HI)
logger_module.Log("Parented to CoreGui — renders above Roblox menu.", C.BLUE)

return {}
