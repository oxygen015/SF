local TweenService = game:GetService("TweenService")
local config_module = _G.SF_REQUIRE("config.lua")
local C = config_module.C

local Logger = {
    GUI = nil,
    Stats = {saved=0, skipped=0, scripts=0, errors=0},
    Live = {bytes=0, total=0, processed=0, startTime=0, chunkCount=0, chunkProgress=0}
}

function Logger.Log(msg, color)
    local GUI = Logger.GUI
    if not GUI then return end
    GUI.logEntryCount = (GUI.logEntryCount or 0) + 1
    GUI.logCount.Text = GUI.logEntryCount .. " entries"
    local l = Instance.new("TextLabel")
    l.Text                   = os.date("[%H:%M:%S] ") .. tostring(msg)
    l.Font                   = Enum.Font.Code
    l.TextSize               = 10
    l.TextColor3             = color or C.TEXT_MID
    l.BackgroundTransparency = 1
    l.Size                   = UDim2.new(1,-4,0,13)
    l.TextXAlignment         = Enum.TextXAlignment.Left
    l.TextTruncate           = Enum.TextTruncate.AtEnd
    l.ZIndex                 = 4
    l.LayoutOrder            = tick()
    l.Parent                 = GUI.logScroll
end

function Logger.SetStatus(msg, col)
    local GUI = Logger.GUI
    if GUI then
        GUI.statusLabel.Text       = tostring(msg)
        GUI.statusLabel.TextColor3 = col or C.TEXT_MID
    end
end

function Logger.SetProgress(pct)
    local GUI = Logger.GUI
    if not GUI then return end
    pct = math.clamp(pct, 0, 1)
    TweenService:Create(GUI.barFill,
        TweenInfo.new(0.06, Enum.EasingStyle.Quad),
        {Size=UDim2.new(pct, 0, 1, 0)}):Play()
    GUI.barPct.Text = math.floor(pct * 100) .. "%"
end

function Logger.SetChunkProgress(pct)
    local GUI = Logger.GUI
    if not GUI then return end
    pct = math.clamp(pct, 0, 1)
    TweenService:Create(GUI.chunkFill,
        TweenInfo.new(0.05),
        {Size=UDim2.new(pct, 0, 1, 0)}):Play()
end

function Logger.UpdateStat(key, value)
    Logger.Stats[key] = value
    local GUI = Logger.GUI
    if GUI and GUI.statLabels[key] then
        GUI.statLabels[key].Text = tostring(value)
    end
end

function Logger.UpdateMetrics()
    local GUI = Logger.GUI
    local Live = Logger.Live
    if not GUI then return end
    
    local ml      = GUI.metricLabels
    local elapsed = os.clock() - Live.startTime
    ml.instances.Text = Live.processed .. " / " .. Live.total
    ml.filesize.Text  = Logger.FmtBytes(Live.bytes)
    ml.elapsed.Text   = Logger.FmtTime(elapsed)
    
    if elapsed > 0 then
        ml.speed.Text = tostring(math.floor(Live.processed / math.max(elapsed, 0.001)))
    end
    
    if Live.processed > 0 and Live.total > 0 then
        local rate = Live.processed / math.max(elapsed, 0.001)
        if rate > 0 then
            ml.eta.Text = Logger.FmtTime((Live.total - Live.processed) / rate)
        end
    else
        ml.eta.Text = "--"
    end
    
    GUI.chunkInfoLabel.Text = string.format(
        "Chunk %d  |  %d written so far",
        Live.chunkCount, Live.processed)
end

function Logger.FmtBytes(b)
    if b < 1024 then
        return b .. " B"
    elseif b < 1048576 then
        return string.format("%.1f KB", b / 1024)
    else
        return string.format("%.2f MB", b / 1048576)
    end
end

function Logger.FmtTime(s)
    s = math.floor(s)
    if s < 60 then return s .. "s" end
    return math.floor(s / 60) .. "m " .. string.format("%02d", s % 60) .. "s"
end

function Logger.ResetAll()
    local GUI = Logger.GUI
    local Live = Logger.Live
    local Stats = Logger.Stats
    
    for k in pairs(Stats) do Logger.UpdateStat(k, 0) end
    Live.bytes         = 0
    Live.total         = 0
    Live.processed     = 0
    Live.startTime     = os.clock()
    Live.chunkCount    = 0
    Live.chunkProgress = 0
    
    if GUI then
        GUI.metricLabels.instances.Text = "0 / 0"
        GUI.metricLabels.filesize.Text  = "0 B"
        GUI.metricLabels.speed.Text     = "0"
        GUI.metricLabels.elapsed.Text   = "0s"
        GUI.metricLabels.eta.Text       = "--"
        GUI.curLabel.Text               = "--"
        GUI.copyLabel.Text              = "--"
        GUI.chunkInfoLabel.Text         = "Chunk: waiting..."
    end
    Logger.SetProgress(0)
    Logger.SetChunkProgress(0)
end

return Logger
