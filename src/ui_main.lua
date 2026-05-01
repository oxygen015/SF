local config_module = SF_REQUIRE("config.lua")
local ui_helpers = SF_REQUIRE("ui_helpers.lua")
local C = config_module.C
local ICON_ID = config_module.ICON_ID

local mkFrame = ui_helpers.mkFrame
local mkLabel = ui_helpers.mkLabel
local mkCorner = ui_helpers.mkCorner
local mkStroke = ui_helpers.mkStroke
local padFrame = ui_helpers.padFrame

local ui_main = {}

function ui_main.CreateGUI()
    local TargetParent = game:GetService("CoreGui")
    if TargetParent:FindFirstChild("SF_SaveInstance") then
        TargetParent.SF_SaveInstance:Destroy()
    end

    local sg = Instance.new("ScreenGui")
    sg.Name            = "SF_SaveInstance"
    sg.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
    sg.ResetOnSpawn    = false
    sg.IgnoreGuiInset  = true
    sg.DisplayOrder    = 9999
    sg.Parent          = TargetParent

    local overlay = mkFrame(sg, C.BLACK, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), 1)
    overlay.Name = "Overlay"
    overlay.BackgroundTransparency = 0.45

    local win = mkFrame(sg, C.BG_WIN, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), 2)
    win.Name = "Window"

    local topBar = mkFrame(win, C.BG_HEADER, UDim2.new(1,0,0,52), UDim2.new(0,0,0,0), 3)
    mkStroke(topBar, C.BORDER_RED, 1)
    mkFrame(topBar, C.RED, UDim2.new(1,0,0,2), UDim2.new(0,0,1,-2), 5)

    local iconBox = mkFrame(topBar, C.RED_DARK, UDim2.new(0,36,0,36), UDim2.new(0,12,0,8), 5)
    mkCorner(iconBox, 5)
    mkStroke(iconBox, C.RED_DIM, 1)
    local iconImg = Instance.new("ImageLabel")
    iconImg.Size                 = UDim2.new(1,-6,1,-6)
    iconImg.Position             = UDim2.new(0,3,0,3)
    iconImg.BackgroundTransparency = 1
    iconImg.Image                = ICON_ID
    iconImg.ScaleType            = Enum.ScaleType.Fit
    iconImg.ZIndex               = 6
    iconImg.Parent               = iconBox

    mkLabel(topBar, "SF", Enum.Font.GothamBlack, 22, C.TEXT_HI,
        UDim2.new(0,40,0,28), UDim2.new(0,56,0,11), Enum.TextXAlignment.Left, 5)
    mkLabel(topBar, "SaveInstance", Enum.Font.Gotham, 11, C.TEXT_LOW,
        UDim2.new(0,150,0,16), UDim2.new(0,100,0,18), Enum.TextXAlignment.Left, 5)
    mkLabel(topBar, "v3.1", Enum.Font.GothamBold, 10, C.RED,
        UDim2.new(0,50,0,16), UDim2.new(1,-68,0,18), Enum.TextXAlignment.Right, 5)

    local tabRunBtn  = Instance.new("TextButton")
    tabRunBtn.Size             = UDim2.new(0,70,0,24)
    tabRunBtn.Position         = UDim2.new(1,-160,0,14)
    tabRunBtn.BackgroundColor3 = C.RED_DARK
    tabRunBtn.BorderSizePixel  = 0
    tabRunBtn.Font             = Enum.Font.GothamBold
    tabRunBtn.TextSize         = 10
    tabRunBtn.TextColor3       = C.RED_GLOW
    tabRunBtn.Text             = "SAVE"
    tabRunBtn.AutoButtonColor  = false
    tabRunBtn.ZIndex           = 6
    tabRunBtn.Parent           = topBar
    mkCorner(tabRunBtn, 4)
    mkStroke(tabRunBtn, C.RED_DIM, 1)

    local tabCfgBtn  = Instance.new("TextButton")
    tabCfgBtn.Size             = UDim2.new(0,70,0,24)
    tabCfgBtn.Position         = UDim2.new(1,-82,0,14)
    tabCfgBtn.BackgroundColor3 = C.BG_CARD
    tabCfgBtn.BorderSizePixel  = 0
    tabCfgBtn.Font             = Enum.Font.GothamBold
    tabCfgBtn.TextSize         = 10
    tabCfgBtn.TextColor3       = C.TEXT_MID
    tabCfgBtn.Text             = "CONFIG"
    tabCfgBtn.AutoButtonColor  = false
    tabCfgBtn.ZIndex           = 6
    tabCfgBtn.Parent           = topBar
    mkCorner(tabCfgBtn, 4)
    mkStroke(tabCfgBtn, C.BORDER, 1)

    local content = mkFrame(win, C.BG_WIN, UDim2.new(1,0,1,-52), UDim2.new(0,0,0,52), 3)
    content.BackgroundTransparency = 1

    local savePage = mkFrame(content, C.BG_WIN, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), 3)
    savePage.BackgroundTransparency = 1

    local leftPane = mkFrame(savePage, C.BG_WIN, UDim2.new(0.38,-1,1,0), UDim2.new(0,0,0,0), 3)
    leftPane.BackgroundTransparency = 1
    local rightPane = mkFrame(savePage, C.BG_WIN, UDim2.new(0.62,-1,1,0), UDim2.new(0.38,1,0,0), 3)
    rightPane.BackgroundTransparency = 1
    mkFrame(savePage, C.BORDER, UDim2.new(0,1,1,0), UDim2.new(0.38,0,0,0), 5)

    local leftPad = mkFrame(leftPane, C.BG_WIN, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), 3)
    leftPad.BackgroundTransparency = 1
    padFrame(leftPad, 14, 14, 14, 14)

    local leftLayout = Instance.new("UIListLayout")
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Padding   = UDim.new(0, 8)
    leftLayout.Parent    = leftPad

    local warnBar = mkFrame(leftPad, C.RED_DARK, UDim2.new(1,0,0,34), nil, 3)
    warnBar.LayoutOrder = 0
    mkCorner(warnBar, 4)
    mkStroke(warnBar, C.RED_DIM, 1)
    mkLabel(warnBar, "!", Enum.Font.GothamBlack, 14, C.RED,
        UDim2.new(0,22,1,0), UDim2.new(0,8,0,0), Enum.TextXAlignment.Center, 4)
    mkLabel(warnBar, "DO NOT LEAVE WHILE SAVING",
        Enum.Font.GothamBold, 10, C.RED,
        UDim2.new(1,-36,1,0), UDim2.new(0,32,0,0), Enum.TextXAlignment.Left, 4)

    local statusCard = mkFrame(leftPad, C.BG_CARD, UDim2.new(1,0,0,42), nil, 3)
    statusCard.LayoutOrder = 1
    mkCorner(statusCard, 4)
    mkStroke(statusCard, C.BORDER, 1)
    mkLabel(statusCard, "STATUS", Enum.Font.GothamBold, 8, C.TEXT_LOW,
        UDim2.new(1,0,0,14), UDim2.new(0,8,0,5), Enum.TextXAlignment.Left, 4)
    local statusLabel = mkLabel(statusCard, "Ready. Press RUN to begin.",
        Enum.Font.Gotham, 11, C.TEXT_MID,
        UDim2.new(1,-16,0,18), UDim2.new(0,8,0,20), Enum.TextXAlignment.Left, 4)
    statusLabel.TextTruncate = Enum.TextTruncate.AtEnd

    local barCard = mkFrame(leftPad, C.BG_CARD, UDim2.new(1,0,0,42), nil, 3)
    barCard.LayoutOrder = 2
    mkCorner(barCard, 4)
    mkStroke(barCard, C.BORDER, 1)

    local barTop = mkFrame(barCard, C.BG_CARD, UDim2.new(1,0,0,20), nil, 3)
    barTop.BackgroundTransparency = 1
    mkLabel(barTop, "PROGRESS", Enum.Font.GothamBold, 8, C.TEXT_LOW,
        UDim2.new(1,0,1,0), UDim2.new(0,8,0,0), Enum.TextXAlignment.Left, 4)
    local barPct = mkLabel(barTop, "0%", Enum.Font.GothamBold, 11, C.TEXT_MID,
        UDim2.new(0,40,1,0), UDim2.new(1,-48,0,0), Enum.TextXAlignment.Right, 4)

    local barTrack = mkFrame(barCard, C.BG_INSET, UDim2.new(1,-16,0,6), UDim2.new(0,8,0,26), 4)
    mkCorner(barTrack, 3)
    mkStroke(barTrack, C.BORDER, 1)
    local barFill = mkFrame(barTrack, C.RED, UDim2.new(0,0,1,0), UDim2.new(0,0,0,0), 5)
    mkCorner(barFill, 3)

    local chunkTrack = mkFrame(barCard, C.BG_INSET, UDim2.new(1,-16,0,3), UDim2.new(0,8,0,35), 4)
    mkCorner(chunkTrack, 2)
    local chunkFill = mkFrame(chunkTrack, C.BLUE, UDim2.new(0,0,1,0), UDim2.new(0,0,0,0), 5)
    mkCorner(chunkFill, 2)

    local metricsLabel = mkLabel(leftPad, "LIVE METRICS", Enum.Font.GothamBold, 9, C.TEXT_LOW,
        UDim2.new(1,0,0,13), nil, Enum.TextXAlignment.Left, 3)
    metricsLabel.LayoutOrder = 3

    local metricsGrid = mkFrame(leftPad, C.BG_WIN, UDim2.new(1,0,0,65), nil, 3)
    metricsGrid.BackgroundTransparency = 1
    metricsGrid.LayoutOrder = 4

    local mgLayout = Instance.new("UIGridLayout")
    mgLayout.CellSize    = UDim2.new(0.5,-5,0,28)
    mgLayout.CellPadding = UDim2.new(0,5,0,5)
    mgLayout.SortOrder   = Enum.SortOrder.LayoutOrder
    mgLayout.Parent      = metricsGrid

    local metricDefs = {
        {key="instances", lbl="INSTANCES", val="0 / 0"},
        {key="filesize",  lbl="FILE SIZE",  val="0 B"},
        {key="speed",     lbl="INST/SEC",   val="0"},
        {key="elapsed",   lbl="ELAPSED",    val="0s"},
    }
    local metricLabels = {}
    for i, def in ipairs(metricDefs) do
        local card = mkFrame(metricsGrid, C.BG_CARD, UDim2.new(0,0,0,0), nil, 3)
        card.LayoutOrder = i
        mkCorner(card, 4)
        mkStroke(card, C.BORDER, 1)
        mkLabel(card, def.lbl, Enum.Font.GothamBold, 7, C.TEXT_LOW,
            UDim2.new(1,-8,0,11), UDim2.new(0,4,0,3), Enum.TextXAlignment.Left, 4)
        local vl = mkLabel(card, def.val, Enum.Font.GothamBold, 11, C.TEXT_HI,
            UDim2.new(1,-8,0,15), UDim2.new(0,4,0,13), Enum.TextXAlignment.Left, 4)
        metricLabels[def.key] = vl
    end

    local etaCard = mkFrame(leftPad, C.BG_CARD, UDim2.new(1,0,0,28), nil, 3)
    etaCard.LayoutOrder = 5
    mkCorner(etaCard, 4)
    mkStroke(etaCard, C.BORDER, 1)
    mkLabel(etaCard, "ETA", Enum.Font.GothamBold, 8, C.TEXT_LOW,
        UDim2.new(0,40,1,0), UDim2.new(0,8,0,0), Enum.TextXAlignment.Left, 4)
    local etaLabel = mkLabel(etaCard, "--", Enum.Font.GothamBold, 13, C.TEXT_HI,
        UDim2.new(1,-56,1,0), UDim2.new(0,50,0,0), Enum.TextXAlignment.Left, 4)
    metricLabels["eta"] = etaLabel

    mkLabel(leftPad, "COUNTERS", Enum.Font.GothamBold, 9, C.TEXT_LOW,
        UDim2.new(1,0,0,13), nil, Enum.TextXAlignment.Left, 3).LayoutOrder = 6

    local statsRow = mkFrame(leftPad, C.BG_WIN, UDim2.new(1,0,0,42), nil, 3)
    statsRow.BackgroundTransparency = 1
    statsRow.LayoutOrder = 7

    local sgLayout2 = Instance.new("UIGridLayout")
    sgLayout2.CellSize    = UDim2.new(0.25,-4,0,42)
    sgLayout2.CellPadding = UDim2.new(0,4,0,0)
    sgLayout2.SortOrder   = Enum.SortOrder.LayoutOrder
    sgLayout2.Parent      = statsRow

    local statDefs = {
        {key="saved",   lbl="SAVED",   col=C.GREEN},
        {key="skipped", lbl="SKIPPED", col=C.TEXT_MID},
        {key="scripts", lbl="SCRIPTS", col=C.AMBER},
        {key="errors",  lbl="ERRORS",  col=C.RED},
    }
    local statLabels = {}
    for i, def in ipairs(statDefs) do
        local card = mkFrame(statsRow, C.BG_CARD, UDim2.new(0,0,0,0), nil, 3)
        card.LayoutOrder = i
        mkCorner(card, 4)
        mkStroke(card, C.BORDER, 1)
        mkLabel(card, def.lbl, Enum.Font.GothamBold, 7, C.TEXT_LOW,
            UDim2.new(1,0,0,12), UDim2.new(0,0,0,3), Enum.TextXAlignment.Center, 4)
        local vl = mkLabel(card, "0", Enum.Font.GothamBlack, 16, def.col,
            UDim2.new(1,0,0,22), UDim2.new(0,0,0,16), Enum.TextXAlignment.Center, 4)
        statLabels[def.key] = vl
    end

    local chunkInfoLabel = mkLabel(leftPad, "Chunk: waiting...", Enum.Font.Code, 9, C.TEXT_LOW,
        UDim2.new(1,0,0,12), nil, Enum.TextXAlignment.Left, 3)
    chunkInfoLabel.LayoutOrder = 8

    local btnRow = mkFrame(leftPad, C.BG_WIN, UDim2.new(1,0,0,30), nil, 3)
    btnRow.BackgroundTransparency = 1
    btnRow.LayoutOrder = 9

    local btnLayout = Instance.new("UIListLayout")
    btnLayout.FillDirection = Enum.FillDirection.Horizontal
    btnLayout.Padding       = UDim.new(0,5)
    btnLayout.SortOrder     = Enum.SortOrder.LayoutOrder
    btnLayout.Parent        = btnRow

    local function MakeBtn(txt, order, flex, red)
        local b = Instance.new("TextButton")
        b.Size             = UDim2.new(flex, 0, 1, 0)
        b.BackgroundColor3 = red and C.RED_DARK or C.BG_CARD
        b.BorderSizePixel  = 0
        b.Font             = Enum.Font.GothamBold
        b.TextSize         = 11
        b.TextColor3       = red and C.RED_GLOW or C.TEXT_MID
        b.Text             = txt
        b.AutoButtonColor  = false
        b.ZIndex           = 4
        b.LayoutOrder      = order
        b.Parent           = btnRow
        mkCorner(b, 4)
        mkStroke(b, red and C.RED_DIM or C.BORDER, 1)
        
        local TweenService = game:GetService("TweenService")
        local idleBg  = red and C.RED_DARK or C.BG_CARD
        local hoverBg = red and Color3.fromRGB(100,15,15) or Color3.fromRGB(20,20,20)
        b.MouseEnter:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3=hoverBg}):Play()
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3=idleBg}):Play()
        end)
        return b
    end

    local runBtn   = MakeBtn("RUN",   1, 0.44, true)
    local clearBtn = MakeBtn("CLEAR", 2, 0.28, false)
    local closeBtn = MakeBtn("CLOSE", 3, 0.28, false)

    local rightPad = mkFrame(rightPane, C.BG_WIN, UDim2.new(1,0,1,0), nil, 3)
    rightPad.BackgroundTransparency = 1
    padFrame(rightPad, 14, 14, 14, 14)

    local logHeader = mkFrame(rightPad, C.BG_WIN, UDim2.new(1,0,0,22), nil, 3)
    logHeader.BackgroundTransparency = 1
    mkLabel(logHeader, "ACTIVITY LOG", Enum.Font.GothamBold, 9, C.TEXT_LOW,
        UDim2.new(0.5,0,1,0), nil, Enum.TextXAlignment.Left, 4)
    local logCount = mkLabel(logHeader, "0 entries", Enum.Font.Gotham, 9, C.TEXT_LOW,
        UDim2.new(0.5,0,1,0), UDim2.new(0.5,0,0,0), Enum.TextXAlignment.Right, 4)

    mkFrame(rightPad, C.BORDER, UDim2.new(1,0,0,1), UDim2.new(0,0,0,22), 3)

    local curStrip = mkFrame(rightPad, C.BG_INSET, UDim2.new(1,0,0,20), UDim2.new(0,0,0,29), 3)
    mkCorner(curStrip, 3)
    mkStroke(curStrip, C.BORDER, 1)
    mkLabel(curStrip, ">", Enum.Font.GothamBold, 9, C.RED,
        UDim2.new(0,14,1,0), UDim2.new(0,5,0,0), Enum.TextXAlignment.Left, 4)
    local curLabel = mkLabel(curStrip, "--", Enum.Font.Code, 10, C.TEXT_MID,
        UDim2.new(1,-22,1,0), UDim2.new(0,18,0,0), Enum.TextXAlignment.Left, 4)
    curLabel.TextTruncate = Enum.TextTruncate.AtEnd

    local copyStrip = mkFrame(rightPad, C.BG_INSET, UDim2.new(1,0,0,18), UDim2.new(0,0,0,53), 3)
    mkCorner(copyStrip, 3)
    mkStroke(copyStrip, C.BORDER, 1)
    mkLabel(copyStrip, "✓", Enum.Font.GothamBold, 9, C.GREEN,
        UDim2.new(0,14,1,0), UDim2.new(0,5,0,0), Enum.TextXAlignment.Left, 4)
    local copyLabel = mkLabel(copyStrip, "--", Enum.Font.Code, 9, C.GREEN,
        UDim2.new(1,-22,1,0), UDim2.new(0,18,0,0), Enum.TextXAlignment.Left, 4)
    copyLabel.TextTruncate = Enum.TextTruncate.AtEnd

    local logScroll = Instance.new("ScrollingFrame")
    logScroll.Size                 = UDim2.new(1,0,1,-76)
    logScroll.Position             = UDim2.new(0,0,0,76)
    logScroll.BackgroundColor3     = C.BG_INSET
    logScroll.BorderSizePixel      = 0
    logScroll.ScrollBarThickness   = 2
    logScroll.ScrollBarImageColor3 = C.RED_DIM
    logScroll.CanvasSize           = UDim2.new(0,0,0,0)
    logScroll.ZIndex               = 3
    logScroll.Parent               = rightPad
    mkCorner(logScroll, 4)
    mkStroke(logScroll, C.BORDER, 1)

    local logPadUI = Instance.new("UIPadding")
    logPadUI.PaddingLeft   = UDim.new(0, 7)
    logPadUI.PaddingTop    = UDim.new(0, 5)
    logPadUI.PaddingBottom = UDim.new(0, 5)
    logPadUI.Parent        = logScroll

    local logLayout = Instance.new("UIListLayout")
    logLayout.SortOrder = Enum.SortOrder.LayoutOrder
    logLayout.Padding   = UDim.new(0, 1)
    logLayout.Parent    = logScroll

    logLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        logScroll.CanvasSize     = UDim2.new(0,0,0, logLayout.AbsoluteContentSize.Y + 10)
        logScroll.CanvasPosition = Vector2.new(0, math.huge)
    end)

    local cfgPage = mkFrame(content, C.BG_WIN, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), 3)
    cfgPage.BackgroundTransparency = 1
    cfgPage.Visible = false

    local cfgScroll = Instance.new("ScrollingFrame")
    cfgScroll.Size                 = UDim2.new(1,0,1,0)
    cfgScroll.BackgroundTransparency = 1
    cfgScroll.BorderSizePixel      = 0
    cfgScroll.ScrollBarThickness   = 2
    cfgScroll.ScrollBarImageColor3 = C.RED_DIM
    cfgScroll.CanvasSize           = UDim2.new(0,0,0,0)
    cfgScroll.ZIndex               = 3
    cfgScroll.Parent               = cfgPage

    local cfgPad = mkFrame(cfgScroll, C.BG_WIN, UDim2.new(1,0,1,0), nil, 3)
    cfgPad.BackgroundTransparency = 1
    padFrame(cfgPad, 18, 18, 24, 24)

    local cfgList = Instance.new("UIListLayout")
    cfgList.SortOrder = Enum.SortOrder.LayoutOrder
    cfgList.Padding   = UDim.new(0, 10)
    cfgList.Parent    = cfgPad

    cfgList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        cfgScroll.CanvasSize = UDim2.new(0,0,0, cfgList.AbsoluteContentSize.Y + 36)
    end)

    return {
        sg              = sg,
        overlay         = overlay,
        win             = win,
        savePage        = savePage,
        cfgPage         = cfgPage,
        cfgPad          = cfgPad,
        cfgList         = cfgList,
        cfgScroll       = cfgScroll,
        statusLabel     = statusLabel,
        barFill         = barFill,
        barPct          = barPct,
        chunkFill       = chunkFill,
        chunkInfoLabel  = chunkInfoLabel,
        metricLabels    = metricLabels,
        statLabels      = statLabels,
        curLabel        = curLabel,
        copyLabel       = copyLabel,
        logScroll       = logScroll,
        logLayout       = logLayout,
        logCount        = logCount,
        closeBtn        = closeBtn,
        runBtn          = runBtn,
        clearBtn        = clearBtn,
        tabRunBtn       = tabRunBtn,
        tabCfgBtn       = tabCfgBtn,
        logEntryCount   = 0,
    }
end

return ui_main
