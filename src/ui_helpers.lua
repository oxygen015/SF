local config_module = SF_REQUIRE("config.lua")
local C = config_module.C

local UIHelpers = {}

function UIHelpers.mkCorner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 4)
    c.Parent = p
end

function UIHelpers.mkStroke(p, col, thick)
    local s = Instance.new("UIStroke")
    s.Color     = col   or C.BORDER
    s.Thickness = thick or 1
    s.Parent    = p
end

function UIHelpers.mkFrame(p, bg, sz, pos, z)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = bg  or C.BG_CARD
    f.BorderSizePixel  = 0
    f.Size     = sz  or UDim2.new(1, 0, 0, 20)
    f.Position = pos or UDim2.new(0, 0, 0, 0)
    f.ZIndex   = z   or 3
    f.Parent   = p
    return f
end

function UIHelpers.mkLabel(p, text, font, size, color, sz, pos, alignX, z)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text           = text   or ""
    l.Font           = font   or Enum.Font.Gotham
    l.TextSize       = size   or 12
    l.TextColor3     = color  or C.TEXT_MID
    l.Size           = sz     or UDim2.new(1, 0, 1, 0)
    l.Position       = pos    or UDim2.new(0, 0, 0, 0)
    l.TextXAlignment = alignX or Enum.TextXAlignment.Left
    l.ZIndex         = z      or 4
    l.Parent         = p
    return l
end

function UIHelpers.padFrame(parent, t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.Parent        = parent
end

return UIHelpers
