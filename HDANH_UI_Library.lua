-- ╔══════════════════════════════════════════════════════════════╗
-- ║          HDANH HUB  •  UI Library  •  v3.0 (2026)          ║
-- ║   Drop-in replacement for Chilli Library — full API compat  ║
-- ║   Fixes: missing Finalize, GetDefaultTab, CreateState,      ║
-- ║           CreateExclusiveGroup, GetState, SetOptions,       ║
-- ║           FieldSignal, Watch on all control handles         ║
-- ╚══════════════════════════════════════════════════════════════╝
return function(_configKey)
    -- ── Services ──────────────────────────────────────────────
    local Players        = game:GetService("Players")
    local TweenService   = game:GetService("TweenService")
    local UIS            = game:GetService("UserInputService")
    local RunService     = game:GetService("RunService")

    -- ── Theme ─────────────────────────────────────────────────
    local T = {
        bg      = Color3.fromRGB(10, 12, 22),
        panel   = Color3.fromRGB(17, 20, 35),
        card    = Color3.fromRGB(24, 28, 47),
        raised  = Color3.fromRGB(32, 37, 60),
        hover   = Color3.fromRGB(44, 50, 80),
        text    = Color3.fromRGB(238, 242, 255),
        muted   = Color3.fromRGB(140, 150, 178),
        line    = Color3.fromRGB(55, 62, 90),
        purple  = Color3.fromRGB(148, 82, 255),
        blue    = Color3.fromRGB(72, 138, 255),
        cyan    = Color3.fromRGB(56, 218, 230),
        pink    = Color3.fromRGB(255, 75, 185),
        green   = Color3.fromRGB(56, 220, 140),
        red     = Color3.fromRGB(255, 65, 90),
        gold    = Color3.fromRGB(255, 195, 60),
    }

    -- ── Helpers ───────────────────────────────────────────────
    local function new(class, props, parent)
        local o = Instance.new(class)
        for k, v in pairs(props or {}) do
            pcall(function() o[k] = v end)
        end
        if parent then o.Parent = parent end
        return o
    end

    local function corner(o, r)
        new("UICorner", { CornerRadius = UDim.new(0, r or 9) }, o)
    end

    local function stroke(o, c, a, th)
        new("UIStroke", {
            Color        = c or T.line,
            Transparency = a or 0.3,
            Thickness    = th or 1,
        }, o)
    end

    local function tw(o, t, props)
        if o and o.Parent then
            pcall(function()
                TweenService:Create(
                    o,
                    TweenInfo.new(t or 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                    props
                ):Play()
            end)
        end
    end

    local function safe(f, ...)
        if type(f) == "function" then
            local ok, e = pcall(f, ...)
            if not ok then warn("[HDANH HUB] " .. tostring(e)) end
        end
    end

    local function makeLabel(parent, txt, size, color, font, xa, ya)
        local l = new("TextLabel", {
            BackgroundTransparency = 1,
            Text                   = tostring(txt or ""),
            Font                   = font or Enum.Font.Gotham,
            TextSize               = size or 12,
            TextColor3             = color or T.text,
            TextXAlignment         = xa or Enum.TextXAlignment.Left,
            TextYAlignment         = ya or Enum.TextYAlignment.Center,
            TextWrapped            = true,
        }, parent)
        return l
    end

    local function makeBtn(parent, txt, size, color)
        local b = new("TextButton", {
            AutoButtonColor = false,
            Text            = txt or "",
            Font            = Enum.Font.GothamMedium,
            TextSize        = 11,
            TextColor3      = T.text,
            BackgroundColor3= color or T.raised,
            BorderSizePixel = 0,
            Size            = size or UDim2.new(0, 90, 0, 30),
        }, parent)
        corner(b, 8)
        return b
    end

    local function makeScroll(parent, props)
        local f = new("ScrollingFrame", props, parent)
        f.BackgroundTransparency  = 1
        f.BorderSizePixel         = 0
        f.CanvasSize              = UDim2.new()
        f.AutomaticCanvasSize     = Enum.AutomaticSize.Y
        f.ScrollBarThickness      = 3
        f.ScrollBarImageColor3    = T.purple
        new("UIListLayout", {
            Padding    = UDim.new(0, 7),
            SortOrder  = Enum.SortOrder.LayoutOrder,
        }, f)
        return f
    end

    local function getRoot()
        if typeof(gethui) == "function" then
            local ok, r = pcall(gethui)
            if ok and typeof(r) == "Instance" then return r end
        end
        return game:GetService("CoreGui")
    end

    -- ── Signal helper (lightweight) ───────────────────────────
    local function makeSignal()
        local cbs, n = {}, 0
        local sig = {}
        function sig:Connect(fn)
            n = n + 1
            local id = n
            cbs[id] = fn
            return {
                Disconnect = function()
                    cbs[id] = nil
                end,
                Connected = true,
            }
        end
        function sig:Fire(...)
            for _, fn in pairs(cbs) do
                pcall(fn, ...)
            end
        end
        return sig
    end

    -- ── Connection tracking ───────────────────────────────────
    local function trackConn(obj, conn)
        obj._conns = obj._conns or {}
        table.insert(obj._conns, conn)
        return conn
    end
    local function cleanConns(obj)
        for _, c in ipairs(obj._conns or {}) do
            pcall(function() c:Disconnect() end)
        end
        obj._conns = {}
    end

    -- ══════════════════════════════════════════════════════════
    --  Control base — every UI element returned to the script
    -- ══════════════════════════════════════════════════════════
    local Control = {}
    Control.__index = Control

    function Control:Get()
        return self.Value
    end

    function Control:Set(v, silent)
        local kind = self.Kind
        if kind == "toggle" then
            v = (v == true)
        elseif kind == "slider" then
            v = math.clamp(tonumber(v) or self._min, self._min, self._max)
            local inc = tonumber(self._inc) or 0
            if inc > 0 then
                v = self._min + math.floor((v - self._min) / inc + 0.5) * inc
            end
        elseif kind == "input" then
            v = tostring(v or "")
            if self._maxLen then v = v:sub(1, self._maxLen) end
        elseif kind == "dropdown" then
            local found = false
            for _, x in ipairs(self.Options or {}) do
                if x == v then found = true break end
            end
            if not found then v = (self.Options or {})[1] end
        elseif kind == "multidropdown" then
            v = type(v) == "table" and v or {}
        elseif kind == "state" then
            -- accepts any value
        end
        local old = self.Value
        self.Value = v
        if self._refresh then pcall(self._refresh) end
        if not silent then
            safe(self.Callback, v)
        end
        -- fire FieldSignal/Watch listeners
        if old ~= v then
            self._changed:Fire(v)
        end
        return v
    end

    -- FieldSignal: subscribe to a specific field path (used by chili.lua for
    -- table values inside MultiDropdown).  We subscribe to our own changed
    -- signal and forward the value at `field` inside the table.
    function Control:FieldSignal(field)
        local sub = makeSignal()
        self._changed:Connect(function(newVal)
            if type(newVal) == "table" then
                sub:Fire(newVal[field])
            else
                sub:Fire(newVal)
            end
        end)
        return sub
    end

    -- Watch: alias used by some save/load shims in chili.lua
    Control.Watch = Control.FieldSignal

    -- SetOptions: called by chili.lua on Dropdown/MultiDropdown handles
    -- to update the option list dynamically (egg type lists, etc.)
    function Control:SetOptions(newOpts, _defaultOverride, _silent)
        if type(newOpts) ~= "table" then return end
        self.Options = newOpts
        if self._rebuildMenu then
            pcall(self._rebuildMenu, newOpts)
        end
    end

    function Control:Destroy()
        cleanConns(self)
        if self.Instance and self.Instance.Parent then
            pcall(function() self.Instance:Destroy() end)
        end
    end

    -- ══════════════════════════════════════════════════════════
    --  LIBRARY (top-level object returned to chili.lua)
    -- ══════════════════════════════════════════════════════════
    local Library = {
        ManualQuickDefaults = {},
        _states  = {},
        _exclGrp = {},
    }

    -- ── Window ────────────────────────────────────────────────
    local WindowMeta = {}
    WindowMeta.__index = WindowMeta

    function Library:CreateWindow(opt)
        opt = opt or {}
        local W = setmetatable({
            Name       = opt.Name or "HDANH HUB",
            DefaultTab = opt.DefaultTab or "Main",
            Tabs       = {},
            _tabArr    = {},
            _active    = nil,
            _min       = false,
            _dead      = false,
            _conns     = {},
            _states    = {},
        }, WindowMeta)

        -- Root ScreenGui
        local gui = new("ScreenGui", {
            Name              = "HDANH_HUB_UI",
            ResetOnSpawn      = false,
            ZIndexBehavior    = Enum.ZIndexBehavior.Sibling,
            DisplayOrder      = 950,
            IgnoreGuiInset    = true,
        }, getRoot())
        W.Gui = gui

        -- Main window frame
        local main = new("Frame", {
            Name             = "Window",
            AnchorPoint      = Vector2.new(0.5, 0.5),
            Position         = UDim2.new(0.5, 0, 0.5, 20),
            Size             = UDim2.new(0, 840, 0, 550),
            BackgroundColor3 = T.bg,
            BorderSizePixel  = 0,
            ClipsDescendants = true,
        }, gui)
        corner(main, 16)
        stroke(main, T.purple, 0.15, 1.5)
        new("UIGradient", {
            Color    = ColorSequence.new(T.bg, Color3.fromRGB(20, 13, 38)),
            Rotation = 30,
        }, main)
        W.Main = main

        -- Top accent bar (RGB gradient)
        local accentBar = new("Frame", {
            Size             = UDim2.new(1, 0, 0, 3),
            BackgroundColor3 = T.purple,
            BorderSizePixel  = 0,
        }, main)
        new("UIGradient", { Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,    T.purple),
            ColorSequenceKeypoint.new(0.33, T.blue),
            ColorSequenceKeypoint.new(0.66, T.cyan),
            ColorSequenceKeypoint.new(1,    T.pink),
        }) }, accentBar)

        -- Header
        local header = new("Frame", {
            Position         = UDim2.new(0, 0, 0, 3),
            Size             = UDim2.new(1, 0, 0, 60),
            BackgroundColor3 = T.panel,
            BorderSizePixel  = 0,
        }, main)

        -- Logo mark
        local logoBox = new("Frame", {
            Position         = UDim2.new(0, 14, 0, 11),
            Size             = UDim2.new(0, 38, 0, 38),
            BackgroundColor3 = T.purple,
            BorderSizePixel  = 0,
        }, header)
        corner(logoBox, 11)
        new("UIGradient", {
            Color    = ColorSequence.new(T.purple, T.blue),
            Rotation = 40,
        }, logoBox)
        local logoLbl = makeLabel(logoBox, "H", 22, Color3.new(1,1,1), Enum.Font.GothamBlack,
            Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
        logoLbl.Size = UDim2.fromScale(1, 1)

        -- Title
        local titleLbl = makeLabel(header, W.Name, 16, T.text, Enum.Font.GothamBold)
        titleLbl.Position = UDim2.new(0, 62, 0, 7)
        titleLbl.Size     = UDim2.new(1, -155, 0, 24)

        local subLbl = makeLabel(header, "HDANH HUB  •  PREMIUM CONTROL CENTER", 9, T.muted, Enum.Font.GothamMedium)
        subLbl.Position = UDim2.new(0, 63, 0, 31)
        subLbl.Size     = UDim2.new(1, -155, 0, 16)

        -- Minimize / Close buttons
        local function ctrlBtn(label, xOff)
            local b = makeBtn(header, label, UDim2.new(0, 28, 0, 28), T.raised)
            b.Position       = UDim2.new(1, xOff, 0, 16)
            b.TextColor3     = T.muted
            b.Font           = Enum.Font.GothamBold
            stroke(b, T.line, 0.5)
            b.MouseEnter:Connect(function() tw(b, 0.1, { BackgroundColor3 = T.hover }) end)
            b.MouseLeave:Connect(function() tw(b, 0.1, { BackgroundColor3 = T.raised }) end)
            return b
        end
        local minBtn   = ctrlBtn("—", -65)
        local closeBtn = ctrlBtn("×", -33)
        closeBtn.TextSize = 17

        -- Sidebar nav
        local nav = new("Frame", {
            Position         = UDim2.new(0, 12, 0, 74),
            Size             = UDim2.new(0, 178, 1, -86),
            BackgroundColor3 = T.panel,
            BorderSizePixel  = 0,
        }, main)
        corner(nav, 12)
        stroke(nav, T.line, 0.5)

        local navHead = makeLabel(nav, "NAVIGATION", 8, T.muted, Enum.Font.GothamBold)
        navHead.Position = UDim2.new(0, 11, 0, 8)
        navHead.Size     = UDim2.new(1, -22, 0, 18)

        local navList = makeScroll(nav, {
            Name              = "NavList",
            Position          = UDim2.new(0, 6, 0, 30),
            Size              = UDim2.new(1, -12, 1, -38),
            ScrollBarThickness= 2,
        })

        -- Content shell
        local shell = new("Frame", {
            Position         = UDim2.new(0, 202, 0, 74),
            Size             = UDim2.new(1, -216, 1, -86),
            BackgroundColor3 = T.panel,
            BorderSizePixel  = 0,
            ClipsDescendants = true,
        }, main)
        corner(shell, 12)
        stroke(shell, T.line, 0.5)

        W.ContentTitle = makeLabel(shell, W.DefaultTab, 17, T.text, Enum.Font.GothamBold)
        W.ContentTitle.Position = UDim2.new(0, 14, 0, 7)
        W.ContentTitle.Size     = UDim2.new(1, -28, 0, 26)

        W.ContentSub = makeLabel(shell, "HDANH HUB  •  CONTROL CENTER", 8, T.muted)
        W.ContentSub.Position = UDim2.new(0, 15, 0, 33)
        W.ContentSub.Size     = UDim2.new(1, -30, 0, 15)

        local pagesHolder = new("Frame", {
            Position         = UDim2.new(0, 8, 0, 55),
            Size             = UDim2.new(1, -16, 1, -63),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
        }, shell)
        W.Pages = pagesHolder
        W.Nav   = navList

        -- Entrance animation
        local targetPos = UDim2.new(0.5, 0, 0.5, 0)
        tw(main, 0.24, { Position = targetPos })

        -- Minimize
        trackConn(W, minBtn.Activated:Connect(function()
            W._min = not W._min
            if W._min then
                nav.Visible   = false
                shell.Visible = false
                tw(main, 0.2, { Size = UDim2.new(0, 840, 0, 64) })
            else
                tw(main, 0.2, { Size = UDim2.new(0, 840, 0, 550) })
                task.delay(0.15, function()
                    if not W._dead then
                        nav.Visible   = true
                        shell.Visible = true
                    end
                end)
            end
        end))

        -- Close
        trackConn(W, closeBtn.Activated:Connect(function()
            W:Destroy()
        end))

        -- Drag
        local dragging, dragOrigin, dragStart = false, nil, nil
        trackConn(W, header.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                dragging  = true
                dragOrigin= i.Position
                dragStart = main.Position
            end
        end))
        trackConn(W, UIS.InputChanged:Connect(function(i)
            if dragging and (
                i.UserInputType == Enum.UserInputType.MouseMovement
                or i.UserInputType == Enum.UserInputType.Touch
            ) then
                local d = i.Position - dragOrigin
                main.Position = UDim2.new(
                    dragStart.X.Scale, dragStart.X.Offset + d.X,
                    dragStart.Y.Scale, dragStart.Y.Offset + d.Y
                )
            end
        end))
        trackConn(W, UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end))

        -- Toggle key
        local toggleKey = (opt.ToggleKey) or Enum.KeyCode.Insert
        trackConn(W, UIS.InputBegan:Connect(function(i, proc)
            if not proc and i.KeyCode == toggleKey and not W._dead then
                gui.Enabled = not gui.Enabled
            end
        end))

        return W
    end

    -- ── Window methods ─────────────────────────────────────────
    function WindowMeta:CreateTab(opt)
        opt = opt or {}
        local name = tostring(opt.Name or ("Tab " .. (#self._tabArr + 1)))
        if self.Tabs[name] then return self.Tabs[name] end

        local TabMeta = {}
        TabMeta.__index = TabMeta
        local T_obj = setmetatable({
            Name     = name,
            Window   = self,
            Sections = {},
            _conns   = {},
        }, TabMeta)

        -- Page (ScrollingFrame for this tab's controls)
        local page = makeScroll(self.Pages, {
            Name              = "Page_" .. name:gsub("%W", "_"),
            Size              = UDim2.fromScale(1, 1),
            Visible           = false,
            ScrollBarThickness= 3,
        })
        T_obj.Page = page

        -- Nav button
        local nb = makeBtn(self.Nav, "   " .. name, UDim2.new(1, -2, 0, 36), T.card)
        nb.LayoutOrder       = #self._tabArr + 1
        nb.TextXAlignment    = Enum.TextXAlignment.Left
        nb.TextSize          = 11
        nb.TextColor3        = T.muted
        stroke(nb, T.line, 0.7)
        T_obj.NavButton = nb

        self.Tabs[name] = T_obj
        table.insert(self._tabArr, T_obj)

        trackConn(T_obj, nb.Activated:Connect(function()
            self:SwitchTab(name)
        end))
        trackConn(T_obj, nb.MouseEnter:Connect(function()
            if self._active ~= T_obj then
                tw(nb, 0.1, { BackgroundColor3 = T.raised })
            end
        end))
        trackConn(T_obj, nb.MouseLeave:Connect(function()
            if self._active ~= T_obj then
                tw(nb, 0.1, { BackgroundColor3 = T.card })
            end
        end))

        if name == self.DefaultTab or #self._tabArr == 1 then
            task.defer(function()
                if not self._dead then
                    self:SwitchTab(name, true)
                end
            end)
        end

        -- Attach Section builder inside tab closure
        function TabMeta:CreateSection(sOpt)
            sOpt = sOpt or {}
            local SectionMeta = {}
            SectionMeta.__index = SectionMeta

            local sec = setmetatable({
                Name     = tostring(sOpt.Name or "Section"),
                Expanded = sOpt.Expanded ~= false,
                Tab      = self,
                Controls = {},
                _conns   = {},
            }, SectionMeta)

            local card = new("Frame", {
                Name            = "Sec_" .. sec.Name:gsub("%W", "_"),
                Size            = UDim2.new(1, -2, 0, 42),
                AutomaticSize   = Enum.AutomaticSize.Y,
                BackgroundColor3= T.card,
                BorderSizePixel = 0,
            }, page)
            corner(card, 10)
            stroke(card, T.line, 0.45)
            sec.Instance = card

            local secHead = makeBtn(card, "", UDim2.new(1, 0, 0, 38), T.card)
            secHead.BackgroundTransparency = 1
            sec.Header = secHead

            local secTitle = makeLabel(secHead, sec.Name, 12, T.text, Enum.Font.GothamBold)
            secTitle.Position = UDim2.new(0, 11, 0, 0)
            secTitle.Size     = UDim2.new(1, -44, 1, 0)

            local arrow = makeLabel(secHead, sec.Expanded and "−" or "+", 17, T.cyan, Enum.Font.GothamBold,
                Enum.TextXAlignment.Center)
            arrow.Position = UDim2.new(1, -31, 0, 0)
            arrow.Size     = UDim2.new(0, 22, 1, 0)
            sec.Arrow = arrow

            local body = new("Frame", {
                Position         = UDim2.new(0, 7, 0, 40),
                Size             = UDim2.new(1, -14, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Visible          = sec.Expanded,
            }, card)
            new("UIListLayout", {
                Padding   = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }, body)
            new("UIPadding", {
                PaddingBottom = UDim.new(0, 8),
                PaddingTop    = UDim.new(0, 2),
            }, body)
            sec.Body = body

            trackConn(sec, secHead.Activated:Connect(function()
                sec.Expanded = not sec.Expanded
                body.Visible = sec.Expanded
                arrow.Text   = sec.Expanded and "−" or "+"
            end))

            table.insert(self.Sections, sec)

            -- ── Control factory helpers (scoped inside Section) ──
            local function makeRow(opt2, h)
                opt2 = opt2 or {}
                local rowH = h or (opt2.Note and 56 or 42)
                local r = new("Frame", {
                    Name             = "Row_" .. tostring(opt2.Name or ""):gsub("%W", "_"),
                    Size             = UDim2.new(1, 0, 0, rowH),
                    BackgroundColor3 = T.raised,
                    BorderSizePixel  = 0,
                }, sec.Body)
                corner(r, 8)

                local yOff = opt2.Note and 3 or 0
                local lbl = makeLabel(r, opt2.Name or "", 11, T.text, Enum.Font.GothamMedium)
                lbl.Position = UDim2.new(0, 10, 0, yOff)
                lbl.Size     = UDim2.new(0.55, 0, 0, opt2.Note and 18 or rowH)

                if opt2.Note then
                    local n = makeLabel(r, opt2.Note, 9, T.muted)
                    n.Position         = UDim2.new(0, 10, 0, 21)
                    n.Size             = UDim2.new(0.75, 0, 0, 28)
                    n.TextYAlignment   = Enum.TextYAlignment.Top
                    n.TextWrapped      = true
                end
                return r
            end

            local function makeCtrl(kind, opt2, value, row, refresh)
                local c = setmetatable({
                    Name     = opt2.Name,
                    Kind     = kind,
                    Value    = value,
                    Default  = opt2.Default,
                    Callback = opt2.Callback,
                    Options  = opt2.Options or {},
                    _min     = tonumber(opt2.Min) or 0,
                    _max     = tonumber(opt2.Max) or 100,
                    _inc     = opt2.Increment,
                    _maxLen  = opt2.MaxLength,
                    Instance = row,
                    Section  = sec,
                    _refresh = refresh,
                    _conns   = {},
                    _changed = makeSignal(),
                }, Control)
                -- expose FieldSignal directly on the control
                c.FieldSignal = Control.FieldSignal
                c.Watch       = Control.FieldSignal
                table.insert(sec.Controls, c)
                return c
            end

            -- ── Toggle ─────────────────────────────────────────
            function SectionMeta:CreateToggle(opt2)
                opt2 = opt2 or {}
                local on = opt2.Default == true
                local r  = makeRow(opt2)

                local sw = new("TextButton", {
                    Text             = "",
                    AutoButtonColor  = false,
                    AnchorPoint      = Vector2.new(1, 0.5),
                    Position         = UDim2.new(1, -9, 0.5, 0),
                    Size             = UDim2.new(0, 42, 0, 22),
                    BackgroundColor3 = on and T.purple or Color3.fromRGB(48, 54, 74),
                    BorderSizePixel  = 0,
                }, r)
                corner(sw, 12)

                local dot = new("Frame", {
                    Position         = on and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                    Size             = UDim2.new(0, 16, 0, 16),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel  = 0,
                }, sw)
                corner(dot, 10)

                local c
                local function refresh()
                    local v = c and c.Value or on
                    tw(sw, 0.13, {
                        BackgroundColor3 = v and T.purple or Color3.fromRGB(48, 54, 74),
                    })
                    tw(dot, 0.13, {
                        Position = v
                            and UDim2.new(1, -20, 0.5, -8)
                            or  UDim2.new(0, 3, 0.5, -8),
                    })
                end

                c = makeCtrl("toggle", opt2, on, r, refresh)
                trackConn(c, sw.Activated:Connect(function()
                    c:Set(not c.Value)
                end))
                return c
            end

            -- ── Button ─────────────────────────────────────────
            function SectionMeta:CreateButton(opt2)
                opt2 = opt2 or {}
                local r  = makeRow(opt2)
                local originalText = opt2.ButtonText or opt2.Name or "Run"

                local b = makeBtn(r, originalText, UDim2.new(0, 108, 0, 27), T.purple)
                b.AnchorPoint = Vector2.new(1, 0.5)
                b.Position    = UDim2.new(1, -8, 0.5, 0)
                b.TextSize    = 10
                new("UIGradient", {
                    Color    = ColorSequence.new(T.purple, T.blue),
                    Rotation = 90,
                }, b)
                stroke(b, T.purple, 0.6)

                local c = makeCtrl("button", opt2, false, r)
                trackConn(c, b.Activated:Connect(function()
                    safe(opt2.Callback)
                    b.Text = opt2.ConfirmText or "✓ Done"
                    task.delay(1.2, function()
                        if b.Parent then b.Text = originalText end
                    end)
                end))
                b.MouseEnter:Connect(function()
                    tw(b, 0.1, { BackgroundColor3 = T.blue })
                end)
                b.MouseLeave:Connect(function()
                    tw(b, 0.1, { BackgroundColor3 = T.purple })
                end)
                return c
            end

            -- ── Slider ─────────────────────────────────────────
            function SectionMeta:CreateSlider(opt2)
                opt2 = opt2 or {}
                local mn  = tonumber(opt2.Min) or 0
                local mx  = tonumber(opt2.Max) or 100
                if mx < mn then mn, mx = mx, mn end
                local def = math.clamp(tonumber(opt2.Default) or mn, mn, mx)
                local r   = makeRow(opt2, opt2.Note and 75 or 60)

                local valLbl = makeLabel(r, tostring(def), 10, T.cyan, Enum.Font.GothamBold,
                    Enum.TextXAlignment.Right)
                valLbl.Position = UDim2.new(1, -98, 0, 3)
                valLbl.Size     = UDim2.new(0, 88, 0, 17)

                local track = new("Frame", {
                    Position         = UDim2.new(0, 10, 1, -12),
                    Size             = UDim2.new(1, -20, 0, 5),
                    BackgroundColor3 = Color3.fromRGB(50, 56, 78),
                    BorderSizePixel  = 0,
                }, r)
                corner(track, 4)

                local fill = new("Frame", {
                    Size             = UDim2.new(mx == mn and 0 or (def-mn)/(mx-mn), 0, 1, 0),
                    BackgroundColor3 = T.cyan,
                    BorderSizePixel  = 0,
                }, track)
                corner(fill, 4)
                new("UIGradient", {
                    Color    = ColorSequence.new(T.blue, T.cyan),
                    Rotation = 90,
                }, fill)

                local hit = new("TextButton", {
                    Text             = "",
                    AutoButtonColor  = false,
                    BackgroundTransparency = 1,
                    Position         = UDim2.new(0, 0, 0, -10),
                    Size             = UDim2.new(1, 0, 0, 25),
                }, track)

                local c
                local function fmt(v)
                    if opt2.AllowDecimals then
                        return string.format("%.2f", v)
                    end
                    return tostring(math.floor(v + 0.5))
                end
                local function refresh()
                    local v = c and c.Value or def
                    local pct = mx == mn and 0 or math.clamp((v-mn)/(mx-mn), 0, 1)
                    tw(fill, 0.05, { Size = UDim2.new(pct, 0, 1, 0) })
                    valLbl.Text = fmt(v)
                end

                c = makeCtrl("slider", opt2, def, r, refresh)
                c._min = mn; c._max = mx; c._inc = opt2.Increment

                local dragging = false
                local function update(ax)
                    local rel = (ax - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1)
                    c:Set(mx == mn and mn or mn + (mx-mn) * math.clamp(rel, 0, 1))
                end

                trackConn(c, hit.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1
                    or i.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        update(i.Position.X)
                    end
                end))
                trackConn(c, UIS.InputChanged:Connect(function(i)
                    if dragging and (
                        i.UserInputType == Enum.UserInputType.MouseMovement
                        or i.UserInputType == Enum.UserInputType.Touch
                    ) then
                        update(i.Position.X)
                    end
                end))
                trackConn(c, UIS.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1
                    or i.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end))

                refresh()
                return c
            end

            -- ── Dropdown (shared logic) ─────────────────────────
            local function buildDropdown(sectionSelf, opt2, multi)
                opt2 = opt2 or {}
                local options = type(opt2.Options) == "table" and opt2.Options or {}
                local value
                if multi then
                    value = {}
                    if type(opt2.Default) == "table" then
                        for k, v in pairs(opt2.Default) do
                            if type(k) == "number" then value[v] = true
                            elseif v then value[k] = true end
                        end
                    end
                else
                    value = opt2.Default
                    if value == nil then value = options[1] end
                end

                local r    = makeRow(opt2, opt2.Note and 58 or 44)
                local pick = makeBtn(r,
                    multi and "Choose items  ▾" or (tostring(value or "Select...") .. "  ▾"),
                    UDim2.new(0, 158, 0, 27),
                    T.panel
                )
                pick.AnchorPoint  = Vector2.new(1, 0.5)
                pick.Position     = UDim2.new(1, -7, 0.5, 0)
                pick.TextSize     = 9
                pick.TextColor3   = T.text
                pick.TextXAlignment = Enum.TextXAlignment.Left
                stroke(pick, T.line, 0.4)
                new("UIPadding", { PaddingLeft = UDim.new(0, 7) }, pick)

                local c, menu
                local function closeMenu()
                    if menu then
                        menu:Destroy()
                        menu = nil
                    end
                end

                local function refreshPick()
                    if not c then return end
                    if multi then
                        local arr = {}
                        for k, v in pairs(c.Value) do
                            if v then table.insert(arr, k) end
                        end
                        table.sort(arr)
                        local st = #arr == 0 and "Choose items" or table.concat(arr, ", ")
                        if #st > 24 then st = st:sub(1, 21) .. "..." end
                        pick.Text = st .. "  ▾"
                    else
                        local txt = tostring(c.Value or "Select...")
                        if #txt > 22 then txt = txt:sub(1, 19) .. "..." end
                        pick.Text = txt .. "  ▾"
                    end
                end

                -- Rebuild menu options (called from SetOptions)
                local function rebuildMenu(newOptions)
                    if not menu then return end
                    -- Destroy and reopen (stateless rebuild)
                    closeMenu()
                end

                c = makeCtrl(multi and "multidropdown" or "dropdown", opt2, value, r, refreshPick)
                c._rebuildMenu = rebuildMenu

                local function openMenu()
                    local opts   = c.Options or {}
                    local count  = math.min(#opts, 8)
                    local mh     = count * 28 + 8

                    menu = new("Frame", {
                        Position         = UDim2.new(0, 5, 1, 3),
                        Size             = UDim2.new(1, -10, 0, 0),
                        BackgroundColor3 = T.panel,
                        BorderSizePixel  = 0,
                        ZIndex           = 22,
                        ClipsDescendants = true,
                    }, r)
                    corner(menu, 8)
                    stroke(menu, T.purple, 0.2)
                    tw(menu, 0.13, { Size = UDim2.new(1, -10, 0, mh) })

                    local sc = new("ScrollingFrame", {
                        Size                = UDim2.fromScale(1, 1),
                        BackgroundTransparency = 1,
                        BorderSizePixel     = 0,
                        CanvasSize          = UDim2.new(),
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        ScrollBarThickness  = 3,
                        ZIndex              = 23,
                    }, menu)
                    new("UIListLayout", { Padding = UDim.new(0, 2) }, sc)

                    for _, v in ipairs(opts) do
                        local isSelected = multi
                            and (c.Value[v] == true)
                            or  (c.Value == v)

                        local ob = makeBtn(sc, tostring(v), UDim2.new(1, 0, 0, 26),
                            isSelected and Color3.fromRGB(60, 40, 95) or T.card)
                        ob.ZIndex   = 24
                        ob.TextSize = 10
                        ob.TextXAlignment = Enum.TextXAlignment.Left
                        new("UIPadding", { PaddingLeft = UDim.new(0, 8) }, ob)

                        local function recolor()
                            local sel = multi and (c.Value[v] == true) or (c.Value == v)
                            ob.BackgroundColor3 = sel
                                and Color3.fromRGB(60, 40, 95)
                                or  T.card
                        end

                        ob.MouseEnter:Connect(function()
                            if ob.BackgroundColor3 ~= Color3.fromRGB(60, 40, 95) then
                                tw(ob, 0.08, { BackgroundColor3 = T.raised })
                            end
                        end)
                        ob.MouseLeave:Connect(function()
                            recolor()
                        end)

                        ob.Activated:Connect(function()
                            if multi then
                                local nv = {}
                                for k, x in pairs(c.Value) do nv[k] = x end
                                nv[v] = not nv[v]
                                c:Set(nv)
                                recolor()
                            else
                                c:Set(v)
                                closeMenu()
                            end
                        end)
                    end

                    -- Close on outside click
                    local outsideConn
                    outsideConn = UIS.InputBegan:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 then
                            task.defer(function()
                                if menu then closeMenu() end
                                if outsideConn then
                                    outsideConn:Disconnect()
                                    outsideConn = nil
                                end
                            end)
                        end
                    end)
                end

                c.CloseMenu = closeMenu

                trackConn(c, pick.Activated:Connect(function()
                    if menu then closeMenu() else openMenu() end
                end))

                refreshPick()
                return c
            end

            function SectionMeta:CreateDropdown(opt2)
                return buildDropdown(self, opt2, false)
            end

            function SectionMeta:CreateMultiDropdown(opt2)
                return buildDropdown(self, opt2, true)
            end

            -- ── Input ──────────────────────────────────────────
            function SectionMeta:CreateInput(opt2)
                opt2 = opt2 or {}
                local r = makeRow(opt2, opt2.Note and 68 or 52)

                local box = new("TextBox", {
                    AnchorPoint      = Vector2.new(1, 0.5),
                    Position         = UDim2.new(1, -7, 0.5, 0),
                    Size             = UDim2.new(0, 162, 0, 27),
                    BackgroundColor3 = T.panel,
                    BorderSizePixel  = 0,
                    Text             = tostring(opt2.Default or ""),
                    PlaceholderText  = opt2.Placeholder or "Enter value...",
                    PlaceholderColor3= T.muted,
                    TextColor3       = T.text,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 10,
                    ClearTextOnFocus = false,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                }, r)
                corner(box, 7)
                stroke(box, T.line, 0.35)
                new("UIPadding", {
                    PaddingLeft  = UDim.new(0, 7),
                    PaddingRight = UDim.new(0, 6),
                }, box)

                box.Focused:Connect(function()
                    tw(box, 0.1, { BackgroundColor3 = T.raised })
                    stroke(box, T.purple, 0.3)
                end)
                box.FocusLost:Connect(function()
                    tw(box, 0.1, { BackgroundColor3 = T.panel })
                end)

                local c  = makeCtrl("input", opt2, tostring(opt2.Default or ""), r)
                c._maxLen = opt2.MaxLength
                c._refresh = function() box.Text = tostring(c.Value) end

                trackConn(c, box.FocusLost:Connect(function()
                    c:Set(box.Text)
                end))
                return c
            end

            -- ── Label ──────────────────────────────────────────
            function SectionMeta:CreateLabel(opt2)
                opt2 = opt2 or {}
                local r = new("Frame", {
                    Name             = "LblRow",
                    Size             = UDim2.new(1, 0, 0, 26),
                    BackgroundTransparency = 1,
                }, sec.Body)

                local l = makeLabel(r, opt2.Text or opt2.Name or "", 10, T.muted)
                l.Position = UDim2.new(0, 7, 0, 0)
                l.Size     = UDim2.new(1, -14, 1, 0)

                local c  = makeCtrl("label", opt2, opt2.Text or opt2.Name or "", r)
                c.Label  = l
                c._refresh = function() l.Text = tostring(c.Value) end
                -- override Set for label (no callback needed)
                function c:Set(v)
                    self.Value = tostring(v or "")
                    l.Text = self.Value
                    self._changed:Fire(self.Value)
                end
                return c
            end

            function SectionMeta:Destroy()
                cleanConns(self)
                for _, ctrl in ipairs(self.Controls) do
                    ctrl:Destroy()
                end
                if self.Instance then
                    pcall(function() self.Instance:Destroy() end)
                end
            end

            return sec
        end -- CreateSection

        return T_obj
    end -- CreateTab

    function WindowMeta:SwitchTab(name, instant)
        local t = self.Tabs[name]
        if not t or self._dead then return end

        if self._active then
            self._active.Page.Visible = false
            self._active.NavButton.TextColor3 = T.muted
            tw(self._active.NavButton, 0.12, { BackgroundColor3 = T.card })
        end

        self._active            = t
        t.Page.Visible          = true
        t.NavButton.TextColor3  = T.text
        tw(t.NavButton, 0.15, { BackgroundColor3 = Color3.fromRGB(44, 30, 72) })

        if not instant then
            t.Page.Position = UDim2.new(0, 8, 0, 0)
            tw(t.Page, 0.16, { Position = UDim2.new(0, 0, 0, 0) })
        end

        if self.ContentTitle then
            self.ContentTitle.Text = t.Name
        end
        if self.ContentSub then
            self.ContentSub.Text = "HDANH HUB  •  " .. string.upper(t.Name)
        end
    end

    -- GetDefaultTab: used by chili.lua immediately after CreateWindow
    function WindowMeta:GetDefaultTab()
        return self.Tabs[self.DefaultTab] or self._tabArr[1]
    end

    -- CreateState: lightweight key-value store attached to window
    -- (chili.lua uses it for flags like "Anti Guard Enabled",
    --  "Steal Panel Open", "FPS and Ping Position")
    function WindowMeta:CreateState(opt)
        opt = opt or {}
        local s = setmetatable({
            Name     = opt.Name or "State",
            Kind     = "state",
            Value    = opt.Default,
            Callback = opt.Callback,
            _conns   = {},
            _changed = makeSignal(),
        }, Control)
        s.FieldSignal = Control.FieldSignal
        s.Watch       = Control.FieldSignal
        self._states[opt.Name or "State"] = s
        return s
    end

    -- GetState: retrieve a previously created state by name
    function WindowMeta:GetState(name)
        return self._states[name]
    end

    -- CreateExclusiveGroup: used for "Chilli Combat Targets" — returns
    -- a group object whose controls enforce MaxActive mutual exclusion.
    function WindowMeta:CreateExclusiveGroup(opt)
        opt = opt or {}
        local grp = {
            Name      = opt.Name or "ExclusiveGroup",
            MaxActive = opt.MaxActive or 1,
            _items    = {},
            _conns    = {},
            _changed  = makeSignal(),
        }
        -- CreateToggle on the group
        function grp:CreateToggle(tOpt)
            tOpt = tOpt or {}
            local c = setmetatable({
                Name     = tOpt.Name,
                Kind     = "toggle",
                Value    = tOpt.Default == true,
                Callback = tOpt.Callback,
                _conns   = {},
                _changed = makeSignal(),
                Group    = grp,
            }, Control)
            c.FieldSignal = Control.FieldSignal
            c.Watch       = Control.FieldSignal
            table.insert(grp._items, c)

            -- Override Set to enforce mutual exclusion
            local baseSet = Control.Set
            function c:Set(v, silent)
                if v == true then
                    local active = 0
                    for _, item in ipairs(grp._items) do
                        if item ~= self and item.Value == true then
                            active = active + 1
                            if active >= grp.MaxActive then
                                item.Value = false
                                if item._refresh then pcall(item._refresh) end
                                safe(item.Callback, false)
                                item._changed:Fire(false)
                            end
                        end
                    end
                end
                return baseSet(self, v, silent)
            end
            return c
        end
        table.insert(self._exclGrp, grp)
        return grp
    end

    function WindowMeta:Destroy()
        if self._dead then return end
        self._dead = true
        cleanConns(self)
        for _, t in ipairs(self._tabArr) do
            cleanConns(t)
            for _, s in ipairs(t.Sections) do
                s:Destroy()
            end
        end
        if self.Gui and self.Gui.Parent then
            pcall(function() self.Gui:Destroy() end)
        end
    end

    -- ══════════════════════════════════════════════════════════
    --  Finalize — REQUIRED by chili.lua assertion
    --  Called as: v:Finalize({ Window = v2, MainTab = defaultTab,
    --                           ShowMainTab = true })
    -- ══════════════════════════════════════════════════════════
    function Library:Finalize(opt)
        opt = opt or {}
        local win = opt.Window
        if not win then return end

        -- If ShowMainTab is true, switch to MainTab or DefaultTab
        if opt.ShowMainTab then
            local target = opt.MainTab
            if target and target.Name then
                win:SwitchTab(target.Name, true)
            elseif win.DefaultTab then
                win:SwitchTab(win.DefaultTab, true)
            end
        end

        -- Animate the window to its resting position
        if win.Main then
            tw(win.Main, 0.22, { Position = UDim2.new(0.5, 0, 0.5, 0) })
        end
    end

    function Library:Destroy()
        local root = getRoot()
        for _, g in ipairs(root:GetChildren()) do
            if g:IsA("ScreenGui") and g.Name == "HDANH_HUB_UI" then
                pcall(function() g:Destroy() end)
            end
        end
    end

    return Library
end
