local config_module = SF_REQUIRE("config.lua")
local ui_helpers = SF_REQUIRE("ui_helpers.lua")
local Config = config_module.Config
local C = config_module.C

local mkFrame = ui_helpers.mkFrame
local mkLabel = ui_helpers.mkLabel
local mkCorner = ui_helpers.mkCorner
local mkStroke = ui_helpers.mkStroke
local padFrame = ui_helpers.padFrame

local TweenService = game:GetService("TweenService")

local ui_config = {}

function ui_config.BuildConfigPanel(GUI)
    local pad = GUI.cfgPad

    local function sectionLabel(txt, order)
        local l = mkLabel(pad, txt, Enum.Font.GothamBold, 9, C.RED,
            UDim2.new(1,0,0,14), nil, Enum.TextXAlignment.Left, 4)
        l.LayoutOrder = order
        return l
    end

    local function divider(order)
        local d = mkFrame(pad, C.BORDER, UDim2.new(1,0,0,1), nil, 3)
        d.LayoutOrder = order
    end

    local function MakeToggle(labelTxt, configKey, order)
        local row = mkFrame(pad, C.BG_CARD, UDim2.new(1,0,0,36), nil, 3)
        row.LayoutOrder = order
        mkCorner(row, 5)
        mkStroke(row, C.BORDER, 1)
        padFrame(row, 0, 0, 12, 12)

        mkLabel(row, labelTxt, Enum.Font.GothamBold, 11, C.TEXT_HI,
            UDim2.new(0.6,0,1,0), nil, Enum.TextXAlignment.Left, 4)

        local track = mkFrame(row, C.TOGGLE_OFF, UDim2.new(0,44,0,22), UDim2.new(1,-56,0.5,-11), 4)
        mkCorner(track, 11)
        mkStroke(track, C.BORDER, 1)

        local knob = mkFrame(track, C.TEXT_HI, UDim2.new(0,16,0,16), UDim2.new(0,3,0,3), 5)
        mkCorner(knob, 8)

        local function refreshToggle(animate)
            local on = Config[configKey]
            local targetTrack = on and C.TOGGLE_ON or C.TOGGLE_OFF
            local targetKnob  = on and UDim2.new(0,25,0,3) or UDim2.new(0,3,0,3)
            if animate then
                TweenService:Create(track, TweenInfo.new(0.18), {BackgroundColor3=targetTrack}):Play()
                TweenService:Create(knob,  TweenInfo.new(0.18), {Position=targetKnob}):Play()
            else
                track.BackgroundColor3 = targetTrack
                knob.Position          = targetKnob
            end
        end
        refreshToggle(false)

        track.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                Config[configKey] = not Config[configKey]
                refreshToggle(true)
            end
        end)
        return row
    end

    local function MakeSlider(labelTxt, configKey, minVal, maxVal, order)
        local row = mkFrame(pad, C.BG_CARD, UDim2.new(1,0,0,52), nil, 3)
        row.LayoutOrder = order
        mkCorner(row, 5)
        mkStroke(row, C.BORDER, 1)
        padFrame(row, 6, 6, 12, 12)

        local topRow = mkFrame(row, C.BG_CARD, UDim2.new(1,0,0,18), nil, 3)
        topRow.BackgroundTransparency = 1
        mkLabel(topRow, labelTxt, Enum.Font.GothamBold, 11, C.TEXT_HI,
            UDim2.new(0.7,0,1,0), nil, Enum.TextXAlignment.Left, 4)
        local valLabel = mkLabel(topRow, tostring(Config[configKey]),
            Enum.Font.GothamBold, 11, C.RED,
            UDim2.new(0.3,0,1,0), UDim2.new(0.7,0,0,0), Enum.TextXAlignment.Right, 4)

        local track = mkFrame(row, C.BG_INSET, UDim2.new(1,0,0,6), UDim2.new(0,0,0,26), 4)
        mkCorner(track, 3)
        mkStroke(track, C.BORDER, 1)
        local fill = mkFrame(track, C.RED, UDim2.new(0,0,1,0), nil, 5)
        mkCorner(fill, 3)
        local handle = mkFrame(track, C.TEXT_HI, UDim2.new(0,10,0,10), UDim2.new(0,0,0.5,-5), 6)
        mkCorner(handle, 5)

        local function setVal(v)
            v = math.clamp(math.floor(v + 0.5), minVal, maxVal)
            Config[configKey] = v
            valLabel.Text = tostring(v)
            local pct = (v - minVal) / math.max(maxVal - minVal, 1)
            TweenService:Create(fill,   TweenInfo.new(0.08), {Size=UDim2.new(pct,0,1,0)}):Play()
            TweenService:Create(handle, TweenInfo.new(0.08), {Position=UDim2.new(pct,-5,0.5,-5)}):Play()
        end
        setVal(Config[configKey])

        local dragging = false
        track.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        track.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        track.InputChanged:Connect(function(inp)
            if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
                or inp.UserInputType == Enum.UserInputType.Touch) then
                local abs = track.AbsolutePosition.X
                local w   = track.AbsoluteSize.X
                local pct = math.clamp((inp.Position.X - abs) / w, 0, 1)
                setVal(minVal + pct * (maxVal - minVal))
            end
        end)
        return row
    end

    sectionLabel("GENERAL", 1)
    MakeToggle("Script Dump (decompile scripts)", "scriptdump", 2)
    MakeToggle("Prettify Output (indentation)",   "prettify",   3)
    MakeToggle("Write Log File",                  "logtofile",  4)
    divider(5)

    sectionLabel("PERFORMANCE", 6)
    MakeSlider("Instance Chunk Size",    "chunkSize",       25, 300,  7)
    MakeSlider("Yield Every N Instances","yieldEvery",      50, 500,  8)
    MakeSlider("Decompiler Timeout (s)", "decompilerTimeout", 1, 15,  9)
    MakeSlider("Parent Timeout (s)",     "timeout",          1, 30, 10)
    MakeSlider("Max Depth",              "maxdepth",        64, 1024, 11)
    divider(12)

    sectionLabel("SAVE PATH", 13)
    local pathCard = mkFrame(pad, C.BG_CARD, UDim2.new(1,0,0,36), nil, 3)
    pathCard.LayoutOrder = 14
    mkCorner(pathCard, 5)
    mkStroke(pathCard, C.BORDER, 1)
    padFrame(pathCard, 0, 0, 12, 12)
    mkLabel(pathCard, "Path: " .. tostring(Config.savepath),
        Enum.Font.Code, 10, C.TEXT_MID,
        UDim2.new(1,0,1,0), nil, Enum.TextXAlignment.Left, 4)
    divider(15)

    sectionLabel("SERVICES TO SAVE", 16)
    for idx, svcName in ipairs(Config.saveservices) do
        local svcRow = mkFrame(pad, C.BG_CARD, UDim2.new(1,0,0,30), nil, 3)
        svcRow.LayoutOrder = 16 + idx
        mkCorner(svcRow, 4)
        mkStroke(svcRow, C.BORDER, 1)
        padFrame(svcRow, 0, 0, 12, 12)
        mkLabel(svcRow, svcName, Enum.Font.Code, 10, C.TEXT_MID,
            UDim2.new(1,0,1,0), nil, Enum.TextXAlignment.Left, 4)
    end
end

return ui_config
