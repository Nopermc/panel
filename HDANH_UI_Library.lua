-- HDANH HUB • UI Library replacement
-- Compatible surface: CreateWindow, CreateTab, CreateSection, CreateToggle,
-- CreateButton, CreateSlider, CreateDropdown, CreateMultiDropdown, CreateInput, CreateLabel.
-- UI layer only: callbacks supplied by the main script remain responsible for feature logic.
return function(_)
    local Players=game:GetService("Players")
    local TweenService=game:GetService("TweenService")
    local UIS=game:GetService("UserInputService")
    local Theme={bg=Color3.fromRGB(12,14,25),panel=Color3.fromRGB(19,22,38),card=Color3.fromRGB(27,31,51),raised=Color3.fromRGB(36,41,65),text=Color3.fromRGB(242,245,255),muted=Color3.fromRGB(155,164,188),line=Color3.fromRGB(61,68,95),purple=Color3.fromRGB(155,91,255),blue=Color3.fromRGB(78,145,255),cyan=Color3.fromRGB(63,224,235),pink=Color3.fromRGB(255,83,190)}
    local function new(class,props,parent)
        local o=Instance.new(class); for k,v in pairs(props or {}) do pcall(function() o[k]=v end) end; o.Parent=parent; return o
    end
    local function corner(o,r) new("UICorner",{CornerRadius=UDim.new(0,r or 9)},o) end
    local function stroke(o,c,a) new("UIStroke",{Color=c or Theme.line,Transparency=a or .35,Thickness=1},o) end
    local function tween(o,t,p) if o and o.Parent then pcall(function() TweenService:Create(o,TweenInfo.new(t or .16,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),p):Play() end) end end
    local function connect(obj,event,fn) obj._connections=obj._connections or {}; table.insert(obj._connections,event:Connect(fn)) end
    local function disconnect(obj) for _,c in ipairs(obj._connections or {}) do pcall(function() c:Disconnect() end) end; obj._connections={} end
    local function safe(f,...) if type(f)=="function" then local ok,e=pcall(f,...); if not ok then warn("[HDANH HUB UI] "..tostring(e)) end end end
    local function label(parent,txt,size,color,font)
        return new("TextLabel",{BackgroundTransparency=1,Text=tostring(txt or ""),Font=font or Enum.Font.Gotham,TextSize=size or 12,TextColor3=color or Theme.text,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,TextWrapped=true},parent)
    end
    local function button(parent,txt,size,color)
        local b=new("TextButton",{AutoButtonColor=false,Text=txt or "",Font=Enum.Font.GothamMedium,TextSize=11,TextColor3=Theme.text,BackgroundColor3=color or Theme.raised,BorderSizePixel=0,Size=size or UDim2.new(0,90,0,30)},parent); corner(b,8); stroke(b,Theme.line,.5)
        connect(b,b.MouseEnter,function() tween(b,.12,{BackgroundColor3=Theme.raised}) end); connect(b,b.MouseLeave,function() tween(b,.12,{BackgroundColor3=color or Theme.card}) end); return b
    end
    local function getRoot()
        local gh=getgenv and getgenv() or _G; local fn=gh.gethui or rawget(_G,"gethui")
        if type(fn)=="function" then local ok,r=pcall(fn); if ok and typeof(r)=="Instance" then return r end end
        return game:GetService("CoreGui")
    end
    local function list(parent,props)
        local f=new("ScrollingFrame",props,parent); f.BackgroundTransparency=1; f.BorderSizePixel=0; f.CanvasSize=UDim2.new(); f.AutomaticCanvasSize=Enum.AutomaticSize.Y; f.ScrollBarThickness=3; f.ScrollBarImageColor3=Theme.purple
        new("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},f); return f
    end
    local Library={}; local Window={}; Window.__index=Window; local Tab={}; Tab.__index=Tab; local Section={}; Section.__index=Section; local Control={}; Control.__index=Control
    function Control:Get() return self.Value end
    function Control:Set(v,silent)
        if self.Kind=="toggle" then v=(v==true)
        elseif self.Kind=="slider" then v=math.clamp(tonumber(v) or self.Min,self.Min,self.Max); local inc=tonumber(self.Increment) or 0; if inc>0 then v=self.Min+math.floor((v-self.Min)/inc+.5)*inc end
        elseif self.Kind=="input" then v=tostring(v or ""); if self.MaxLength then v=v:sub(1,self.MaxLength) end
        elseif self.Kind=="dropdown" then local found=false; for _,x in ipairs(self.Options) do if x==v then found=true end end; if not found then v=self.Options[1] end
        elseif self.Kind=="multidropdown" then v=type(v)=="table" and v or {} end
        self.Value=v; if self.Refresh then pcall(self.Refresh) end; if not silent then safe(self.Callback,v) end; return v
    end
    function Control:Destroy() disconnect(self); if self.Instance then pcall(function() self.Instance:Destroy() end) end end
    function Library:CreateWindow(opt)
        opt=opt or {}; local w=setmetatable({Name=opt.Name or "HDANH HUB",DefaultTab=opt.DefaultTab or "Farm",Tabs={},_connections={},_dead=false},Window)
        local gui=new("ScreenGui",{Name="HDANH_HUB_UI",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=900},getRoot()); w.Gui=gui
        local main=new("Frame",{Name="Window",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,14),Size=UDim2.new(0,820,0,535),BackgroundColor3=Theme.bg,BorderSizePixel=0,ClipsDescendants=true},gui); w.Main=main; corner(main,16); stroke(main,Theme.purple,.18)
        new("UIGradient",{Color=ColorSequence.new(Theme.bg,Color3.fromRGB(26,17,43)),Rotation=25},main)
        local bar=new("Frame",{Size=UDim2.new(1,0,0,3),BackgroundColor3=Theme.purple,BorderSizePixel=0},main); new("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Theme.purple),ColorSequenceKeypoint.new(.5,Theme.cyan),ColorSequenceKeypoint.new(1,Theme.pink)})},bar)
        local head=new("Frame",{Position=UDim2.new(0,0,0,3),Size=UDim2.new(1,0,0,63),BackgroundColor3=Theme.panel,BorderSizePixel=0},main)
        local logo=new("Frame",{Position=UDim2.new(0,16,0,12),Size=UDim2.new(0,39,0,39),BackgroundColor3=Theme.purple,BorderSizePixel=0},head); corner(logo,11); new("UIGradient",{Color=ColorSequence.new(Theme.purple,Theme.blue),Rotation=35},logo)
        local mark=label(logo,"H",22,Color3.new(1,1,1),Enum.Font.GothamBlack); mark.Size=UDim2.fromScale(1,1); mark.TextXAlignment=Enum.TextXAlignment.Center
        local title=label(head,w.Name,17,Theme.text,Enum.Font.GothamBold); title.Position=UDim2.new(0,65,0,8); title.Size=UDim2.new(1,-160,0,25)
        local sub=label(head,"PREMIUM CONTROL CENTER  •  HDANH HUB",9,Theme.muted,Enum.Font.GothamMedium); sub.Position=UDim2.new(0,66,0,33); sub.Size=UDim2.new(1,-160,0,16)
        local minimize=button(head,"—",UDim2.new(0,29,0,29),Theme.card); minimize.Position=UDim2.new(1,-69,0,17)
        local close=button(head,"×",UDim2.new(0,29,0,29),Theme.card); close.Position=UDim2.new(1,-35,0,17); close.TextSize=18
        local nav=new("Frame",{Position=UDim2.new(0,13,0,77),Size=UDim2.new(0,176,1,-90),BackgroundColor3=Theme.panel,BorderSizePixel=0},main); corner(nav,12); stroke(nav,Theme.line,.55)
        local navhead=label(nav,"NAVIGATION",9,Theme.muted,Enum.Font.GothamBold); navhead.Position=UDim2.new(0,12,0,9); navhead.Size=UDim2.new(1,-24,0,20)
        w.Nav=list(nav,{Name="Navigation",Position=UDim2.new(0,7,0,34),Size=UDim2.new(1,-14,1,-42),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2}); w.Nav.LayoutOrder=0
        local shell=new("Frame",{Position=UDim2.new(0,201,0,77),Size=UDim2.new(1,-214,1,-90),BackgroundColor3=Theme.panel,BorderSizePixel=0,ClipsDescendants=true},main); corner(shell,12); stroke(shell,Theme.line,.55)
        w.ContentTitle=label(shell,w.DefaultTab,18,Theme.text,Enum.Font.GothamBold); w.ContentTitle.Position=UDim2.new(0,16,0,8); w.ContentTitle.Size=UDim2.new(1,-32,0,28)
        w.ContentSub=label(shell,"HDANH HUB  •  CONTROL CENTER",9,Theme.muted); w.ContentSub.Position=UDim2.new(0,17,0,36); w.ContentSub.Size=UDim2.new(1,-34,0,16)
        w.Pages=new("Frame",{Position=UDim2.new(0,10,0,59),Size=UDim2.new(1,-20,1,-69),BackgroundTransparency=1,ClipsDescendants=true},shell)
        local original=main.Size; w._minimized=false
        connect(w,minimize,minimize.Activated:Connect(function() w._minimized=not w._minimized; if w._minimized then nav.Visible=false; shell.Visible=false; tween(main,.2,{Size=UDim2.new(original.X.Scale,original.X.Offset,0,67)}) else tween(main,.2,{Size=original}); task.delay(.16,function() if not w._dead then nav.Visible=true; shell.Visible=true end end) end end))
        connect(w,close,close.Activated:Connect(function() w:Destroy() end))
        local dragging,origin,start=false,nil,nil
        connect(w,head,head.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; origin=i.Position; start=main.Position end end))
        connect(w,UIS,UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-origin; main.Position=UDim2.new(start.X.Scale,start.X.Offset+d.X,start.Y.Scale,start.Y.Offset+d.Y) end end))
        connect(w,UIS,UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end))
        local key=opt.ToggleKey or Enum.KeyCode.Insert; connect(w,UIS,UIS.InputBegan:Connect(function(i,processed) if not processed and i.KeyCode==key and not w._dead then gui.Enabled=not gui.Enabled end end))
        tween(main,.22,{Position=UDim2.new(.5,0,.5,0)}); return w
    end
    function Window:CreateTab(opt)
        opt=opt or {}; local name=tostring(opt.Name or ("Tab "..tostring(#self.Tabs+1))); if self.Tabs[name] then return self.Tabs[name] end
        local t=setmetatable({Name=name,Window=self,Sections={},_connections={}},Tab)
        t.Page=list(self.Pages,{Name="Page_"..name:gsub("%W",""),Size=UDim2.fromScale(1,1),Visible=false,BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3}); t.Page.AutomaticCanvasSize=Enum.AutomaticSize.Y
        local nav=button(self.Nav,name,UDim2.new(1,-2,0,37),Theme.panel); nav.LayoutOrder=#self.Tabs+1; nav.TextXAlignment=Enum.TextXAlignment.Left; nav.TextSize=11; nav.TextColor3=Theme.muted; nav.Text="   "..name; t.NavButton=nav
        self.Tabs[name]=t; table.insert(self.Tabs,t); connect(t,nav,nav.Activated:Connect(function() self:SwitchTab(name) end))
        if name==self.DefaultTab or #self.Tabs==1 then task.defer(function() if not self._dead then self:SwitchTab(name,true) end end) end; return t
    end
    function Window:SwitchTab(name,instant)
        local t=self.Tabs[name]; if not t or self._dead then return end
        if self._active then self._active.Page.Visible=false; self._active.NavButton.TextColor3=Theme.muted; tween(self._active.NavButton,.12,{BackgroundColor3=Theme.panel}) end
        self._active=t; t.Page.Visible=true; t.Page.Position=UDim2.new(0,instant and 0 or 7,0,0); tween(t.Page,instant and 0 or .17,{Position=UDim2.new(0,0,0,0)})
        self.ContentTitle.Text=t.Name; self.ContentSub.Text="HDANH HUB  •  "..string.upper(t.Name); t.NavButton.TextColor3=Theme.text; tween(t.NavButton,.15,{BackgroundColor3=Color3.fromRGB(48,35,76)})
    end
    function Window:GetDefaultTab() return self.Tabs[self.DefaultTab] or self.Tabs[1] end
    function Window:Destroy() if self._dead then return end; self._dead=true; disconnect(self); for _,t in ipairs(self.Tabs) do disconnect(t); for _,s in ipairs(t.Sections) do s:Destroy() end end; if self.Gui then self.Gui:Destroy() end end
    function Tab:CreateSection(opt)
        opt=opt or {}; local s=setmetatable({Name=tostring(opt.Name or "Section"),Expanded=opt.Expanded~=false,Tab=self,Controls={},_connections={}},Section)
        local card=new("Frame",{Name="Section_"..s.Name:gsub("%W",""),Size=UDim2.new(1,-2,0,43),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=Theme.card,BorderSizePixel=0},self.Page); corner(card,10); stroke(card,Theme.line,.5); s.Instance=card
        local head=button(card,"",UDim2.new(1,0,0,39),Theme.card); head.BackgroundTransparency=1; head.Text=""; s.Header=head
        local title=label(head,s.Name,12,Theme.text,Enum.Font.GothamBold); title.Position=UDim2.new(0,12,0,0); title.Size=UDim2.new(1,-45,1,0)
        s.Arrow=label(head,s.Expanded and "−" or "+",18,Theme.cyan,Enum.Font.GothamBold); s.Arrow.Position=UDim2.new(1,-32,0,0); s.Arrow.Size=UDim2.new(0,22,1,0); s.Arrow.TextXAlignment=Enum.TextXAlignment.Center
        s.Body=new("Frame",{Position=UDim2.new(0,8,0,41),Size=UDim2.new(1,-16,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Visible=s.Expanded},card); new("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},s.Body); new("UIPadding",{PaddingBottom=UDim.new(0,9),PaddingTop=UDim.new(0,2)},s.Body)
        connect(s,head,head.Activated:Connect(function() s.Expanded=not s.Expanded; s.Body.Visible=s.Expanded; s.Arrow.Text=s.Expanded and "−" or "+" end)); table.insert(self.Sections,s); return s
    end
    local function row(s,opt,h)
        opt=opt or {}; local r=new("Frame",{Name="Control_"..tostring(opt.Name or "Item"):gsub("%W",""),Size=UDim2.new(1,0,0,h or 43),BackgroundColor3=Theme.raised,BorderSizePixel=0},s.Body); corner(r,8)
        local y=opt.Note and 3 or 0; local l=label(r,opt.Name or "Control",11,Theme.text,Enum.Font.GothamMedium); l.Position=UDim2.new(0,10,0,y); l.Size=UDim2.new(1,-20,0,opt.Note and 18 or (h or 43))
        if opt.Note then local n=label(r,opt.Note,9,Theme.muted); n.Position=UDim2.new(0,10,0,22); n.Size=UDim2.new(1,-20,0,30); n.TextYAlignment=Enum.TextYAlignment.Top end; return r
    end
    local function makeControl(s,kind,opt,value,r,refresh)
        local c=setmetatable({Name=opt.Name,Kind=kind,Value=value,Default=opt.Default,Callback=opt.Callback,Options=opt.Options or {},Min=tonumber(opt.Min) or 0,Max=tonumber(opt.Max) or 100,Increment=opt.Increment,MaxLength=opt.MaxLength,Instance=r,Section=s,Refresh=refresh,_connections={}},Control); table.insert(s.Controls,c); return c
    end
    function Section:CreateToggle(opt)
        opt=opt or {}; local r=row(self,opt,opt.Note and 58 or 42); local on=opt.Default==true
        local sw=new("TextButton",{Text="",AutoButtonColor=false,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-9,.5,0),Size=UDim2.new(0,40,0,21),BackgroundColor3=on and Theme.purple or Color3.fromRGB(54,59,78),BorderSizePixel=0},r); corner(sw,12)
        local dot=new("Frame",{Position=on and UDim2.new(1,-18,.5,-7) or UDim2.new(0,3,.5,-7),Size=UDim2.new(0,14,0,14),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0},sw); corner(dot,10); local c
        local function refresh() local v=c and c.Value or on; tween(sw,.13,{BackgroundColor3=v and Theme.purple or Color3.fromRGB(54,59,78)}); tween(dot,.13,{Position=v and UDim2.new(1,-18,.5,-7) or UDim2.new(0,3,.5,-7)}) end
        c=makeControl(self,"toggle",opt,on,r,refresh); connect(c,sw,sw.Activated:Connect(function() c:Set(not c.Value) end)); return c
    end
    function Section:CreateButton(opt)
        opt=opt or {}; local r=row(self,opt,opt.Note and 58 or 42); local b=button(r,opt.ButtonText or opt.Name or "Run",UDim2.new(0,105,0,27),Theme.purple); b.AnchorPoint=Vector2.new(1,.5); b.Position=UDim2.new(1,-8,.5,0); b.BackgroundColor3=Theme.purple; b.TextSize=10
        local c=makeControl(self,"button",opt,false,r); connect(c,b,b.Activated:Connect(function() safe(opt.Callback); local old=opt.ButtonText or opt.Name or "Run"; b.Text=opt.ConfirmText or "✓ Done"; task.delay(1,function() if b.Parent then b.Text=old end end) end)); return c
    end
    function Section:CreateSlider(opt)
        opt=opt or {}; local mn,mx=tonumber(opt.Min) or 0,tonumber(opt.Max) or 100; if mx<mn then mn,mx=mx,mn end; local def=math.clamp(tonumber(opt.Default) or mn,mn,mx); local r=row(self,opt,opt.Note and 77 or 61)
        local value=label(r,tostring(def),10,Theme.cyan,Enum.Font.GothamBold); value.Position=UDim2.new(1,-95,0,3); value.Size=UDim2.new(0,85,0,17); value.TextXAlignment=Enum.TextXAlignment.Right
        local trackbar=new("Frame",{Position=UDim2.new(0,10,1,-14),Size=UDim2.new(1,-20,0,5),BackgroundColor3=Color3.fromRGB(55,61,82),BorderSizePixel=0},r); corner(trackbar,4)
        local fill=new("Frame",{Size=UDim2.new(mx==mn and 0 or (def-mn)/(mx-mn),0,1,0),BackgroundColor3=Theme.cyan,BorderSizePixel=0},trackbar); corner(fill,4)
        local hit=new("TextButton",{Text="",AutoButtonColor=false,BackgroundTransparency=1,Position=UDim2.new(0,0,0,-10),Size=UDim2.new(1,0,0,25)},trackbar); local c
        local function fmt(v) if opt.AllowDecimals then return string.format("%.2f",v) end; return tostring(math.floor(v+.5)) end
        local function refresh() local v=c and c.Value or def; tween(fill,.05,{Size=UDim2.new(mx==mn and 0 or math.clamp((v-mn)/(mx-mn),0,1),0,1,0)}); value.Text=fmt(v) end
        c=makeControl(self,"slider",opt,def,r,refresh); c.Min=mn;c.Max=mx; local dragging=false
        local function update(x) c:Set(mx==mn and mn or mn+(mx-mn)*math.clamp((x-trackbar.AbsolutePosition.X)/math.max(trackbar.AbsoluteSize.X,1),0,1)) end
        connect(c,hit,hit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true;update(i.Position.X) end end)); connect(c,UIS,UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then update(i.Position.X) end end)); connect(c,UIS,UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)); refresh(); return c
    end
    local function dropdown(s,opt,multi)
        opt=opt or {}; local options=type(opt.Options)=="table" and opt.Options or {}; local value
        if multi then value={}; if type(opt.Default)=="table" then for k,v in pairs(opt.Default) do if type(k)=="number" then value[v]=true elseif v then value[k]=true end end end else value=opt.Default; if value==nil then value=options[1] end end
        local r=row(s,opt,58); local pick=button(r,multi and "Choose items  ▾" or tostring(value or "Select...").."  ▾",UDim2.new(0,155,0,27),Theme.panel); pick.AnchorPoint=Vector2.new(1,.5); pick.Position=UDim2.new(1,-7,.5,0); pick.TextSize=9; local c,menu
        local function close() if menu then menu:Destroy();menu=nil end end
        local function refresh() if not c then return end; if multi then local a={};for k,v in pairs(c.Value) do if v then table.insert(a,k) end end;table.sort(a);local st=#a==0 and "Choose items" or table.concat(a,", ");if #st>22 then st=st:sub(1,19).."..." end;pick.Text=st.."  ▾" else pick.Text=tostring(c.Value or "Select...").."  ▾" end end
        c=makeControl(s,multi and "multidropdown" or "dropdown",opt,value,r,refresh)
        connect(c,pick,pick.Activated:Connect(function() if menu then close();return end; local height=math.min(#options,7)*27+8; menu=new("Frame",{Position=UDim2.new(0,6,1,2),Size=UDim2.new(1,-12,0,0),BackgroundColor3=Theme.panel,BorderSizePixel=0,ZIndex=20,ClipsDescendants=true},r); corner(menu,8);stroke(menu,Theme.purple,.2);tween(menu,.13,{Size=UDim2.new(1,-12,0,height)})
            local sc=new("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ZIndex=21},menu);new("UIListLayout",{Padding=UDim.new(0,2)},sc)
            for _,v in ipairs(options) do local b=button(sc,tostring(v),UDim2.new(1,0,0,25),Theme.card);b.ZIndex=22;b.TextSize=10;local function recolor() b.BackgroundColor3=(multi and c.Value[v]) and Color3.fromRGB(66,43,103) or Theme.card end;recolor();connect(c,b,b.Activated:Connect(function() if multi then local n={};for k,x in pairs(c.Value) do n[k]=x end;n[v]=not n[v];c:Set(n);recolor() else c:Set(v);close() end end)) end
        end)); c.CloseMenu=close;refresh();return c
    end
    function Section:CreateDropdown(opt) return dropdown(self,opt,false) end
    function Section:CreateMultiDropdown(opt) return dropdown(self,opt,true) end
    function Section:CreateInput(opt)
        opt=opt or {};local r=row(self,opt,opt.Note and 69 or 53);local box=new("TextBox",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-7,.5,0),Size=UDim2.new(0,160,0,27),BackgroundColor3=Theme.panel,BorderSizePixel=0,Text=tostring(opt.Default or ""),PlaceholderText=opt.Placeholder or "Enter value...",PlaceholderColor3=Theme.muted,TextColor3=Theme.text,Font=Enum.Font.Gotham,TextSize=10,ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left},r);corner(box,7);stroke(box,Theme.line,.4);new("UIPadding",{PaddingLeft=UDim.new(0,7),PaddingRight=UDim.new(0,6)},box)
        local c=makeControl(self,"input",opt,tostring(opt.Default or ""),r);c.MaxLength=opt.MaxLength;c.Refresh=function() box.Text=tostring(c.Value) end;connect(c,box,box.FocusLost:Connect(function() c:Set(box.Text) end));return c
    end
    function Section:CreateLabel(opt)
        opt=opt or {};local r=new("Frame",{Name="Label",Size=UDim2.new(1,0,0,28),BackgroundTransparency=1},self.Body);local l=label(r,opt.Text or opt.Name or "",10,Theme.muted);l.Position=UDim2.new(0,7,0,0);l.Size=UDim2.new(1,-14,1,0);local c=makeControl(self,"label",opt,opt.Text or opt.Name or "",r);c.Label=l;function c:Set(v) self.Value=tostring(v or "");self.Label.Text=self.Value end;return c
    end
    function Section:Destroy() disconnect(self);for _,c in ipairs(self.Controls) do c:Destroy() end;if self.Instance then self.Instance:Destroy() end end
    -- The original script may pass SubOf to attach controls to a specific section.
    for _,name in ipairs({"CreateToggle","CreateButton","CreateSlider","CreateDropdown","CreateMultiDropdown","CreateInput","CreateLabel"}) do local original=Section[name];Section[name]=function(self,opt) opt=opt or {};local target=opt.SubOf;if type(target)=="table" and target.Body and target.Controls then return original(target,opt) end;return original(self,opt) end end
    function Library:Destroy() for _,g in ipairs(getRoot():GetChildren()) do if g:IsA("ScreenGui") and g.Name=="HDANH_HUB_UI" then g:Destroy() end end end
    return Library
end
