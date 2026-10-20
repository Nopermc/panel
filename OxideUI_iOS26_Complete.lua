--[=[
 ╔═══════════════════════════════════════════════════════════════════╗
 ║        OXIDE UI v2.6 - iOS 26 Glassmorphism Navigation           ║
 ║          Fully Integrated Redesign (Complete Code)               ║
 ╚═══════════════════════════════════════════════════════════════════╝
 
 ALL patches fully integrated into library functions.
 Ready to use directly - no manual splicing needed.
]=]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local RunService = game:GetService("RunService")
local AssetService = game:GetService("AssetService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local Workspace = game.Workspace

local Library = {}
local Window = {}
local Tab = {}
local Section = {}
local Component = {}

-- ════════════════════════════════════════════════════════════════════
-- CONSTANTS & CONFIG
-- ════════════════════════════════════════════════════════════════════

local DEFAULT_LOGO = "rbxasset://textures/Cursor.png"
local TWEEN = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local NOTIFICATION_TWEEN = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local PROFILE_TWEEN = TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local ICONS = {
    settings = "rbxasset://textures/Cursors/MouseLockedCursor.png",
    home = "rbxasset://textures/Cursors/MouseLockedCursor.png",
    search = "rbxasset://textures/Cursors/MouseLockedCursor.png",
    favorites = "rbxasset://textures/Cursors/MouseLockedCursor.png",
    user = "rbxasset://textures/Cursors/MouseLockedCursor.png",
    chat = "rbxasset://textures/Cursors/MouseLockedCursor.png",
    notification = "rbxasset://textures/Cursors/MouseLockedCursor.png",
    bell = "rbxasset://textures/Cursors/MouseLockedCursor.png",
    gear = "rbxasset://textures/Cursors/MouseLockedCursor.png",
    star = "rbxasset://textures/Cursors/MouseLockedCursor.png",
}

local NOTIFICATION_STYLES = {
    info = {color = Color3.fromRGB(58, 135, 173), icon = "ℹ"},
    success = {color = Color3.fromRGB(76, 175, 80), icon = "✓"},
    warning = {color = Color3.fromRGB(255, 152, 0), icon = "⚠"},
    error = {color = Color3.fromRGB(244, 67, 54), icon = "✕"},
}

local C = {
    WindowBg = Color3.fromRGB(25, 25, 35),
    CardBg = Color3.fromRGB(35, 35, 45),
    Border = Color3.fromRGB(60, 60, 70),
    Element = Color3.fromRGB(45, 45, 55),
    Accent = Color3.fromRGB(167, 200, 244),
    AccentDim = Color3.fromRGB(120, 150, 200),
    White = Color3.fromRGB(255, 255, 255),
    Black = Color3.fromRGB(0, 0, 0),
    Red = Color3.fromRGB(255, 71, 87),
    Green = Color3.fromRGB(76, 175, 80),
    TextWhite = Color3.fromRGB(255, 255, 255),
    TextGray = Color3.fromRGB(180, 180, 190),
    TextDim = Color3.fromRGB(120, 120, 130),
}

local THEMES = {
    Dark = {
        WindowBg = Color3.fromRGB(25, 25, 35),
        CardBg = Color3.fromRGB(35, 35, 45),
        Accent = Color3.fromRGB(167, 200, 244),
        TextGray = Color3.fromRGB(180, 180, 190),
    },
    Light = {
        WindowBg = Color3.fromRGB(245, 245, 250),
        CardBg = Color3.fromRGB(235, 235, 245),
        Accent = Color3.fromRGB(100, 150, 255),
        TextGray = Color3.fromRGB(80, 80, 90),
    },
    OLED = {
        WindowBg = Color3.fromRGB(0, 0, 0),
        CardBg = Color3.fromRGB(15, 15, 20),
        Accent = Color3.fromRGB(180, 210, 255),
        TextGray = Color3.fromRGB(200, 200, 210),
    },
}

local TAG_BASE_URL = "https://adorable-sallyanne-fgdfgdfgd-b2d051be.koyeb.app"
local ADMIN_USER_IDS = {[2401825836] = true}

local TAG_CONFIG = {W = 200, H = 52, WORLD_HEIGHT = 3.4, FULL_DIST = 40, MAX_DISTANCE = 110}

-- ════════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ════════════════════════════════════════════════════════════════════

local function make(class, props)
    local obj = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            if k == "Parent" then continue end
            pcall(function() obj[k] = v end)
        end
        if props.Parent then obj.Parent = props.Parent end
    end
    return obj
end

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
    return c
end

local function stroke(obj, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.new(1, 1, 1)
    s.Thickness = thickness or 1
    s.Parent = obj
    return s
end

local function pad(obj, t, b, l, r)
    local p = Instance.new("UIPadding")
    p.Top = UDim.new(0, t)
    p.Bottom = UDim.new(0, b)
    p.Left = UDim.new(0, l)
    p.Right = UDim.new(0, r)
    p.Parent = obj
    return p
end

local function tween(obj, props, info)
    info = info or TWEEN
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

local function resolveIcon(input)
    if not input then return nil end
    if type(input) == "string" then
        if ICONS[string.lower(input)] then
            return "image", ICONS[string.lower(input)]
        else
            return "text", input
        end
    elseif type(input) == "table" and input.ImageId then
        return "image", input.ImageId
    end
    return nil
end

local function createIconElement(parent, iconType, iconValue, size, zindex)
    if iconType == "image" then
        local img = make("ImageLabel", {
            Image = iconValue,
            Size = UDim2.fromOffset(size, size),
            BackgroundTransparency = 1,
            ImageColor3 = C.TextGray,
            ZIndex = zindex or 1,
            Parent = parent,
        })
        return img
    else
        local txt = make("TextLabel", {
            Text = iconValue,
            Font = Enum.Font.GothamBold,
            TextSize = math.floor(size * 0.8),
            TextColor3 = C.TextGray,
            Size = UDim2.fromOffset(size, size),
            BackgroundTransparency = 1,
            ZIndex = zindex or 1,
            Parent = parent,
        })
        return txt
    end
end

-- ════════════════════════════════════════════════════════════════════
-- LIBRARY FUNCTIONS
-- ════════════════════════════════════════════════════════════════════

function Library:CreateWindow(opts)
    if type(opts) == "string" then opts = {Name = opts} end
    opts = opts or {}
    
    local name = opts.Name or "Oxide UI"
    local logo = opts.Logo or DEFAULT_LOGO
    local windowSize = opts.Size or UDim2.fromOffset(400, 500)
    
    local screenSize = UserInputService:GetMouseLocation()
    local container = make("Frame", {
        Name = "OxideWindow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = windowSize,
        BackgroundColor3 = C.WindowBg,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Parent = (Players.LocalPlayer:FindFirstChild("PlayerGui") or game:GetService("CoreGui")),
    })
    corner(container, 16)
    stroke(container, C.Border, 1)
    
    local header = make("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = C.CardBg,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Parent = container,
    })
    corner(header, 16)
    
    local logoBadge = make("ImageLabel", {
        Image = logo,
        Size = UDim2.fromOffset(32, 32),
        Position = UDim2.fromOffset(14, 14),
        BackgroundTransparency = 1,
        Parent = header,
    })
    
    local titleLabel = make("TextLabel", {
        Text = name,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = C.White,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(54, 17),
        Size = UDim2.new(1, -70, 0, 14),
        Parent = header,
    })
    
    local content = make("ScrollingFrame", {
        Position = UDim2.fromOffset(0, 60),
        Size = UDim2.new(1, 0, 1, -60),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 6,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Parent = container,
    })
    
    local contentList = make("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, -12, 0, 0),
        BackgroundTransparency = 1,
        Parent = content,
    })
    
    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = contentList,
    })
    pad(contentList, 8, 8, 8, 8)
    
    local noDrag = {container, header, logoBadge, titleLabel}
    
    local win = setmetatable({
        _container = container,
        _header = header,
        _content = content,
        _contentList = contentList,
        _tabs = {},
        _activeTab = nil,
        _hotbarInner = nil,
        _noDrag = noDrag,
    }, {__index = Window})
    
    -- ════════════════════════════════════════════════════════════════════
    -- [REDESIGNED] HOTBAR - iOS 26 Glassmorphism Style
    -- ════════════════════════════════════════════════════════════════════
    
    local HOTBAR_HEIGHT = 70
    local HOTBAR_GAP = 12
    
    -- Frosted glass background container
    local hotbarBase = make("Frame", {
        Name = "HotbarBase",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, windowSize.Y.Offset + HOTBAR_GAP),
        Size = UDim2.fromOffset(0, HOTBAR_HEIGHT),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Color3.fromRGB(10, 10, 12),
        BackgroundTransparency = 0.15,
        ClipsDescendants = false,
        Visible = true,
        ZIndex = 3,
        Parent = container,
    })
    corner(hotbarBase, 18)
    
    -- Frosted glass border effect
    local hotbarStroke = make("UIStroke", {
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 0.8,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Transparency = 0.7,
        Parent = hotbarBase,
    })
    
    -- Gradient overlay for depth
    local hotbarGradient = make("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 60)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 25)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.4),
            NumberSequenceKeypoint.new(1, 0.55),
        }),
        Parent = hotbarBase,
    })
    
    -- Inner content frame
    local hotbar = make("Frame", {
        Name = "TabHotbar",
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Visible = true,
        ZIndex = 4,
        Parent = hotbarBase,
    })
    pad(hotbar, 8, 8, 12, 12)
    
    local hotbarInner = make("Frame", {
        Name = "HotbarInner",
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        ZIndex = 4,
        Parent = hotbar,
    })
    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = hotbarInner,
    })
    
    table.insert(noDrag, hotbarBase)
    win._hotbarInner = hotbarInner
    
    return win
end

-- ════════════════════════════════════════════════════════════════════
-- WINDOW FUNCTIONS
-- ════════════════════════════════════════════════════════════════════

function Window:AddTab(opts)
    if type(opts) == "string" then opts = {Name = opts} end
    opts = opts or {}
    
    local name = opts.Name or "Tab"
    local iconInput = opts.Icon
    local win = self
    
    local iconType, iconValue = resolveIcon(iconInput)
    if not iconType then
        local autoKey = string.lower(name)
        if ICONS[autoKey] then
            iconType = "image"
            iconValue = ICONS[autoKey]
        else
            iconType = "text"
            iconValue = string.upper(string.sub(name, 1, 1))
        end
    end
    
    -- ════════════════════════════════════════════════════════════════════
    -- [REDESIGNED] iOS-style pill button with icon + label vertical stack
    -- ════════════════════════════════════════════════════════════════════
    
    local hBtn = make("TextButton", {
        Text = "",
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = C.WindowBg,
        BackgroundTransparency = 0.85,
        ZIndex = 5,
        Parent = self._hotbarInner,
    })
    hBtn.LayoutOrder = #self._hotbarInner:GetChildren()
    corner(hBtn, 12)
    
    local hBtnStroke = stroke(hBtn, C.Accent)
    hBtnStroke.Thickness = 0.6
    hBtnStroke.Transparency = 0.8
    
    pad(hBtn, 6, 6, 12, 12)
    table.insert(win._noDrag, hBtn)
    
    -- Content layout: Icon on top, Text below (iOS vertical stack)
    local hCol = make("Frame", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0),
        ZIndex = 5,
        Parent = hBtn,
    })
    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = hCol,
    })
    
    -- Icon badge (top)
    local iconBadge = make("Frame", {
        Size = UDim2.fromOffset(22, 22),
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        ZIndex = 6,
        Parent = hCol,
    })
    local hIconElement = createIconElement(iconBadge, iconType, iconValue, 16, 7)
    
    -- Label (bottom)
    local hLabel = make("TextLabel", {
        Text = name,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = C.TextGray,
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 0, 12),
        LayoutOrder = 2,
        ZIndex = 6,
        Parent = hCol,
    })
    
    -- Dot indicator below button (iOS style)
    local hDot = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 1, 6),
        Size = UDim2.fromOffset(4, 3),
        BackgroundColor3 = C.Accent,
        BackgroundTransparency = 1,
        ZIndex = 6,
        Parent = hBtn,
    })
    corner(hDot, 2)
    
    -- Page content
    local page = make("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = self._content,
    })
    
    local header = make("Frame", {
        Size = UDim2.new(1, 0, 0, 88),
        BackgroundTransparency = 1,
        Parent = page,
    })
    
    -- Header icon
    local headerBadge = make("Frame", {
        Size = UDim2.fromOffset(32, 32),
        Position = UDim2.fromOffset(14, 14),
        BackgroundTransparency = 1,
        Parent = header,
    })
    local headerIconElement = createIconElement(headerBadge, iconType, iconValue, 26, 3)
    if headerIconElement:IsA("ImageLabel") then
        headerIconElement.ImageColor3 = C.White
    elseif headerIconElement:IsA("TextLabel") then
        headerIconElement.TextColor3 = C.White
    end
    
    -- Header text
    make("TextLabel", {
        Text = name,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = C.White,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(54, 17),
        Size = UDim2.new(1, -70, 0, 14),
        Parent = header,
    })
    
    make("TextLabel", {
        Text = opts.Subtitle or "",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = C.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(54, 33),
        Size = UDim2.new(1, -70, 0, 12),
        Parent = header,
    })
    
    local pagesHolder = make("Frame", {
        Position = UDim2.fromOffset(0, 88),
        Size = UDim2.new(1, 0, 1, -88),
        BackgroundTransparency = 1,
        Parent = page,
    })
    
    local tab = setmetatable({
        _window = win,
        _hBtn = hBtn,
        _hLabel = hLabel,
        _hDot = hDot,
        _hIconElement = hIconElement,
        _page = page,
        _pagesHolder = pagesHolder,
        _sections = {},
    }, {__index = Tab})
    
    -- Hover animation - glassmorphic effect
    hBtn.MouseEnter:Connect(function()
        if win._activeTab ~= tab then
            tween(hBtn, {BackgroundTransparency = 0.6})
            tween(hLabel, {TextColor3 = C.White})
            if hIconElement:IsA("ImageLabel") then
                tween(hIconElement, {ImageColor3 = C.White})
            elseif hIconElement:IsA("TextLabel") then
                tween(hIconElement, {TextColor3 = C.White})
            end
        end
    end)
    
    hBtn.MouseLeave:Connect(function()
        if win._activeTab ~= tab then
            tween(hBtn, {BackgroundTransparency = 0.85})
            tween(hLabel, {TextColor3 = C.TextGray})
            if hIconElement:IsA("ImageLabel") then
                tween(hIconElement, {ImageColor3 = C.TextGray})
            elseif hIconElement:IsA("TextLabel") then
                tween(hIconElement, {TextColor3 = C.TextGray})
            end
        end
    end)
    
    hBtn.MouseButton1Click:Connect(function()
        win:_selectTab(tab)
    end)
    
    table.insert(self._tabs, tab)
    if not self._activeTab then
        self:_selectTab(tab)
    end
    
    return tab
end

-- ════════════════════════════════════════════════════════════════════
-- [REDESIGNED] Tab Selection with Smooth Animations
-- ════════════════════════════════════════════════════════════════════

function Window:_selectTab(tab)
    if self._activeTab == tab then return end
    
    local prev = self._activeTab
    self._activeTab = tab
    
    if prev then
        prev._page.Visible = false
        tween(prev._hBtn, {BackgroundTransparency = 0.85})
        tween(prev._hLabel, {TextColor3 = C.TextGray})
        if prev._hDot then
            tween(prev._hDot, {BackgroundTransparency = 1})
        end
        if prev._hIconElement then
            if prev._hIconElement:IsA("ImageLabel") then
                tween(prev._hIconElement, {ImageColor3 = C.TextGray})
            elseif prev._hIconElement:IsA("TextLabel") then
                tween(prev._hIconElement, {TextColor3 = C.TextGray})
            end
        end
    end
    
    tab._page.Visible = true
    tween(tab._hBtn, {BackgroundTransparency = 0.35})
    tween(tab._hLabel, {TextColor3 = C.White})
    if tab._hDot then
        tween(tab._hDot, {BackgroundTransparency = 0})
    end
    if tab._hIconElement then
        if tab._hIconElement:IsA("ImageLabel") then
            tween(tab._hIconElement, {ImageColor3 = C.White})
        elseif tab._hIconElement:IsA("TextLabel") then
            tween(tab._hIconElement, {TextColor3 = C.White})
        end
    end
end

-- ════════════════════════════════════════════════════════════════════
-- TAB FUNCTIONS
-- ════════════════════════════════════════════════════════════════════

function Tab:AddSection(opts)
    if type(opts) == "string" then opts = {Name = opts} end
    opts = opts or {}
    
    local title = opts.Name or "Section"
    local sectionFrame = make("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = C.CardBg,
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        Parent = self._pagesHolder,
    })
    corner(sectionFrame, 12)
    
    local titleLabel = make("TextLabel", {
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = C.Accent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        Parent = sectionFrame,
    })
    pad(titleLabel, 4, 0, 12, 12)
    
    local content = make("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Parent = sectionFrame,
    })
    pad(content, 0, 12, 12, 12)
    
    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = content,
    })
    
    local section = setmetatable({
        _parent = sectionFrame,
        _content = content,
    }, {__index = Section})
    
    table.insert(self._sections, section)
    return section
end

-- ════════════════════════════════════════════════════════════════════
-- SECTION FUNCTIONS
-- ════════════════════════════════════════════════════════════════════

function Section:AddLabel(text)
    local label = make("TextLabel", {
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = C.TextGray,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Parent = self._content,
    })
    return label
end

function Section:AddButton(opts)
    if type(opts) == "string" then opts = {Name = opts} end
    opts = opts or {}
    
    local button = make("TextButton", {
        Text = opts.Name or "Button",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = C.White,
        BackgroundColor3 = C.Accent,
        BackgroundTransparency = 0.15,
        Size = UDim2.new(1, 0, 0, 32),
        Parent = self._content,
    })
    corner(button, 8)
    
    button.MouseButton1Click:Connect(function()
        if opts.Callback then opts.Callback() end
    end)
    
    return button
end

function Section:AddToggle(opts)
    if type(opts) == "string" then opts = {Name = opts} end
    opts = opts or {}
    
    local toggleFrame = make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 32),
        Parent = self._content,
    })
    
    local label = make("TextLabel", {
        Text = opts.Name or "Toggle",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = C.TextGray,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = toggleFrame,
    })
    
    local toggleBtn = make("TextButton", {
        Text = "",
        BackgroundColor3 = C.Element,
        Size = UDim2.fromOffset(40, 24),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Parent = toggleFrame,
    })
    corner(toggleBtn, 12)
    
    local toggleDot = make("Frame", {
        BackgroundColor3 = C.Accent,
        Size = UDim2.fromOffset(18, 18),
        Position = UDim2.fromOffset(2, 3),
        Parent = toggleBtn,
    })
    corner(toggleDot, 8)
    
    local state = opts.Default or false
    
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        local newPos = state and UDim2.fromOffset(20, 3) or UDim2.fromOffset(2, 3)
        tween(toggleDot, {Position = newPos})
        if opts.Callback then opts.Callback(state) end
    end)
    
    return toggleFrame
end

-- ════════════════════════════════════════════════════════════════════
-- LIBRARY FUNCTIONS (continued)
-- ════════════════════════════════════════════════════════════════════

function Library:SetTheme(themeName)
    local theme = THEMES[themeName]
    if not theme then return end
    
    for k, v in pairs(theme) do
        C[k] = v
    end
end

function Library:Notify(opts)
    if type(opts) == "string" then opts = {Title = opts} end
    opts = opts or {}
    
    local style = NOTIFICATION_STYLES[opts.Style or "info"]
    local duration = opts.Duration or 3
    
    local notif = make("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -16, 0, 16),
        Size = UDim2.fromOffset(300, 80),
        BackgroundColor3 = C.CardBg,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Parent = game:GetService("CoreGui"):FindFirstChild("RobloxGui") or game:GetService("CoreGui"),
    })
    corner(notif, 12)
    stroke(notif, style.color, 1)
    
    local titleLabel = make("TextLabel", {
        Text = opts.Title or "Notification",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = C.White,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -32, 0, 20),
        Position = UDim2.fromOffset(16, 12),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif,
    })
    
    local descLabel = make("TextLabel", {
        Text = opts.Description or "",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = C.TextGray,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -32, 0, 40),
        Position = UDim2.fromOffset(16, 32),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = notif,
    })
    
    task.delay(duration, function()
        tween(notif, {Position = UDim2.new(1, -16, 0, -100)}, NOTIFICATION_TWEEN)
        task.wait(0.18)
        notif:Destroy()
    end)
end

return Library
