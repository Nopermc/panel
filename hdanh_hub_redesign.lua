-- ╔═══════════════════════════════════════════════════════════════╗
-- ║         HDANH HUB - Modern Redesign v2.0                    ║
-- ║     Completely Redesigned with Modern UI/Effects             ║
-- ║  https://hdanh.qzz.io | https://discord.gg/shinmod           ║
-- ╚═══════════════════════════════════════════════════════════════╝

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════════
-- MODERN COLOR PALETTE
-- ═══════════════════════════════════════════════════════════════

local THEME = {
	-- Primary Gradient
	Primary1 = Color3.fromRGB(139, 0, 255),    -- Vibrant Purple
	Primary2 = Color3.fromRGB(0, 191, 255),    -- Cyan Blue
	Primary3 = Color3.fromRGB(255, 0, 127),    -- Hot Pink
	
	-- Secondary
	Secondary1 = Color3.fromRGB(0, 255, 150),  -- Mint Green
	Secondary2 = Color3.fromRGB(255, 100, 0),  -- Orange
	Secondary3 = Color3.fromRGB(100, 200, 255), -- Light Blue
	
	-- Dark Mode
	BG_Dark = Color3.fromRGB(10, 10, 20),
	BG_DarkAlt = Color3.fromRGB(15, 15, 35),
	BG_Card = Color3.fromRGB(20, 20, 40),
	
	-- Text
	Text_Primary = Color3.fromRGB(255, 255, 255),
	Text_Secondary = Color3.fromRGB(180, 180, 200),
	Text_Muted = Color3.fromRGB(120, 120, 140),
	
	-- Accent
	Accent_Glow = Color3.fromRGB(0, 255, 200),
	Accent_Warning = Color3.fromRGB(255, 150, 0),
	Accent_Success = Color3.fromRGB(0, 255, 100),
	
	-- Borders
	Border = Color3.fromRGB(60, 60, 100),
	Border_Light = Color3.fromRGB(80, 80, 120),
}

-- ═══════════════════════════════════════════════════════════════
-- CREATE MAIN HUB UI
-- ═══════════════════════════════════════════════════════════════

local function createMainUI()
	-- Main Screen GUI
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "HDANHHubUI"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 1000
	screenGui.Parent = CoreGui
	
	-- Background with gradient effect
	local background = Instance.new("Frame")
	background.Name = "Background"
	background.BackgroundColor3 = THEME.BG_Dark
	background.BorderSizePixel = 0
	background.Size = UDim2.new(1, 0, 1, 0)
	background.Position = UDim2.new(0, 0, 0, 0)
	background.Parent = screenGui
	
	-- Animated gradient overlay
	local gradientOverlay = Instance.new("Frame")
	gradientOverlay.Name = "GradientOverlay"
	gradientOverlay.BackgroundColor3 = THEME.BG_Dark
	gradientOverlay.BorderSizePixel = 0
	gradientOverlay.Size = UDim2.new(1, 0, 1, 0)
	gradientOverlay.Parent = background
	
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, THEME.Primary1),
		ColorSequenceKeypoint.new(0.5, THEME.BG_Dark),
		ColorSequenceKeypoint.new(1, THEME.Primary2),
	})
	gradient.Rotation = 45
	gradient.Parent = gradientOverlay
	gradientOverlay.BackgroundTransparency = 0.95
	
	-- ═══════════════════════════════════════════════════════════════
	-- HEADER SECTION
	-- ═══════════════════════════════════════════════════════════════
	
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.BackgroundColor3 = THEME.BG_DarkAlt
	header.BorderSizePixel = 0
	header.Size = UDim2.new(1, 0, 0, 100)
	header.Position = UDim2.new(0, 0, 0, 0)
	header.Parent = screenGui
	
	-- Header border glow
	local headerBorder = Instance.new("Frame")
	headerBorder.Name = "HeaderBorder"
	headerBorder.BackgroundColor3 = THEME.Primary2
	headerBorder.BorderSizePixel = 0
	headerBorder.Size = UDim2.new(1, 0, 0, 2)
	headerBorder.Position = UDim2.new(0, 0, 1, 0)
	headerBorder.Parent = header
	
	-- Logo/Title Container
	local logoContainer = Instance.new("Frame")
	logoContainer.Name = "LogoContainer"
	logoContainer.BackgroundTransparency = 1
	logoContainer.Size = UDim2.new(0, 300, 1, 0)
	logoContainer.Position = UDim2.new(0, 20, 0, 0)
	logoContainer.Parent = header
	
	-- Logo circle with glow
	local logoBg = Instance.new("Frame")
	logoBg.Name = "LogoBg"
	logoBg.BackgroundColor3 = THEME.Primary1
	logoBg.BorderSizePixel = 0
	logoBg.Size = UDim2.new(0, 60, 0, 60)
	logoBg.Position = UDim2.new(0, 0, 0.5, -30)
	logoBg.Parent = logoContainer
	
	local logoCorner = Instance.new("UICornerRadius")
	logoCorner.CornerRadius = UDim.new(0, 15)
	logoCorner.Parent = logoBg
	
	local logoStroke = Instance.new("UIStroke")
	logoStroke.Color = THEME.Primary2
	logoStroke.Thickness = 2
	logoStroke.Parent = logoBg
	
	-- Logo text "HD"
	local logoText = Instance.new("TextLabel")
	logoText.Name = "LogoText"
	logoText.Text = "H"
	logoText.TextSize = 32
	logoText.TextColor3 = THEME.Text_Primary
	logoText.BackgroundTransparency = 1
	logoText.Font = Enum.Font.GothamBold
	logoText.Size = UDim2.new(1, 0, 1, 0)
	logoText.Parent = logoBg
	
	-- Main title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Text = "HDANH HUB"
	title.TextSize = 28
	title.TextColor3 = THEME.Text_Primary
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.Size = UDim2.new(0, 200, 0, 40)
	title.Position = UDim2.new(0, 75, 0, 20)
	title.Parent = logoContainer
	title.TextXAlignment = Enum.TextXAlignment.Left
	
	-- Subtitle
	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.Text = "Modern Gaming Tools"
	subtitle.TextSize = 14
	subtitle.TextColor3 = THEME.Text_Secondary
	subtitle.BackgroundTransparency = 1
	subtitle.Font = Enum.Font.Gotham
	subtitle.Size = UDim2.new(0, 200, 0, 20)
	subtitle.Position = UDim2.new(0, 75, 0, 55)
	subtitle.Parent = logoContainer
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	
	-- ═══════════════════════════════════════════════════════════════
	-- DISCORD BUTTON (Header Right)
	-- ═══════════════════════════════════════════════════════════════
	
	local discordBtn = Instance.new("TextButton")
	discordBtn.Name = "DiscordButton"
	discordBtn.Text = "📱 DISCORD"
	discordBtn.TextSize = 14
	discordBtn.TextColor3 = THEME.Text_Primary
	discordBtn.BackgroundColor3 = THEME.Primary2
	discordBtn.BorderSizePixel = 0
	discordBtn.Font = Enum.Font.GothamBold
	discordBtn.Size = UDim2.new(0, 140, 0, 50)
	discordBtn.Position = UDim2.new(1, -160, 0.5, -25)
	discordBtn.Parent = header
	
	local discordCorner = Instance.new("UICornerRadius")
	discordCorner.CornerRadius = UDim.new(0, 12)
	discordCorner.Parent = discordBtn
	
	local discordStroke = Instance.new("UIStroke")
	discordStroke.Color = THEME.Accent_Glow
	discordStroke.Thickness = 1
	discordStroke.Parent = discordBtn
	
	-- Discord button hover effect
	discordBtn.MouseEnter:Connect(function()
		local tween = TweenService:Create(
			discordBtn,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = THEME.Accent_Glow}
		)
		tween:Play()
	end)
	
	discordBtn.MouseLeave:Connect(function()
		local tween = TweenService:Create(
			discordBtn,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = THEME.Primary2}
		)
		tween:Play()
	end)
	
	discordBtn.MouseButton1Click:Connect(function()
		setclipboard("https://discord.gg/shinmod")
		print("✓ Discord link copied: https://discord.gg/shinmod")
	end)
	
	-- ═══════════════════════════════════════════════════════════════
	-- MAIN CONTENT AREA
	-- ═══════════════════════════════════════════════════════════════
	
	local contentArea = Instance.new("ScrollingFrame")
	contentArea.Name = "ContentArea"
	contentArea.BackgroundTransparency = 1
	contentArea.BorderSizePixel = 0
	contentArea.Size = UDim2.new(1, 0, 1, -120)
	contentArea.Position = UDim2.new(0, 0, 0, 110)
	contentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
	contentArea.ScrollingDirection = Enum.ScrollingDirection.Y
	contentArea.ScrollBarThickness = 8
	contentArea.Parent = screenGui
	
	local scrollBarImage = Instance.new("UICornerRadius")
	scrollBarImage.CornerRadius = UDim.new(0, 4)
	scrollBarImage.Parent = contentArea
	
	-- Navigation Tabs
	local navFrame = Instance.new("Frame")
	navFrame.Name = "NavFrame"
	navFrame.BackgroundColor3 = THEME.BG_Card
	navFrame.BorderSizePixel = 0
	navFrame.Size = UDim2.new(0.25, -10, 1, 0)
	navFrame.Position = UDim2.new(0, 10, 0, 0)
	navFrame.Parent = contentArea
	
	local navCorner = Instance.new("UICornerRadius")
	navCorner.CornerRadius = UDim.new(0, 16)
	navCorner.Parent = navFrame
	
	local navStroke = Instance.new("UIStroke")
	navStroke.Color = THEME.Border_Light
	navStroke.Thickness = 1
	navStroke.Parent = navFrame
	
	-- Navigation Label
	local navLabel = Instance.new("TextLabel")
	navLabel.Name = "NavLabel"
	navLabel.Text = "MENU"
	navLabel.TextSize = 16
	navLabel.TextColor3 = THEME.Primary2
	navLabel.BackgroundTransparency = 1
	navLabel.Font = Enum.Font.GothamBold
	navLabel.Size = UDim2.new(1, 0, 0, 40)
	navLabel.Position = UDim2.new(0, 15, 0, 15)
	navLabel.TextXAlignment = Enum.TextXAlignment.Left
	navLabel.Parent = navFrame
	
	-- Nav List
	local navList = {
		"🏠 Home",
		"⚙️ Settings",
		"🎮 Features",
		"📊 Stats",
		"🛠️ Tools",
		"ℹ️ About",
	}
	
	for i, navItem in ipairs(navList) do
		local navBtn = Instance.new("TextButton")
		navBtn.Name = "NavItem_" .. i
		navBtn.Text = navItem
		navBtn.TextSize = 13
		navBtn.TextColor3 = THEME.Text_Secondary
		navBtn.BackgroundColor3 = THEME.BG_Card
		navBtn.BorderSizePixel = 0
		navBtn.Font = Enum.Font.Gotham
		navBtn.Size = UDim2.new(1, -30, 0, 38)
		navBtn.Position = UDim2.new(0, 15, 0, 60 + (i - 1) * 45)
		navBtn.Parent = navFrame
		navBtn.TextXAlignment = Enum.TextXAlignment.Left
		
		local navBtnCorner = Instance.new("UICornerRadius")
		navBtnCorner.CornerRadius = UDim.new(0, 10)
		navBtnCorner.Parent = navBtn
		
		-- Hover effect
		navBtn.MouseEnter:Connect(function()
			local tween = TweenService:Create(
				navBtn,
				TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{BackgroundColor3 = THEME.BG_DarkAlt}
			)
			tween:Play()
		end)
		
		navBtn.MouseLeave:Connect(function()
			local tween = TweenService:Create(
				navBtn,
				TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{BackgroundColor3 = THEME.BG_Card}
			)
			tween:Play()
		end)
	end
	
	-- ═══════════════════════════════════════════════════════════════
	-- MAIN CONTENT CARDS
	-- ═══════════════════════════════════════════════════════════════
	
	local mainContent = Instance.new("Frame")
	mainContent.Name = "MainContent"
	mainContent.BackgroundTransparency = 1
	mainContent.Size = UDim2.new(0.73, -20, 1, 0)
	mainContent.Position = UDim2.new(0.25, 10, 0, 0)
	mainContent.Parent = contentArea
	
	-- Card data
	local cardData = {
		{Icon = "🚀", Title = "Quick Tools", Desc = "Fast access to gaming tools"},
		{Icon = "💫", Title = "Performance", Desc = "Optimized for smooth gameplay"},
		{Icon = "🎨", Title = "Customization", Desc = "Personalize your experience"},
		{Icon = "⚡", Title = "Speed Boost", Desc = "Enhanced performance mode"},
		{Icon = "🔐", Title = "Safe & Secure", Desc = "Protected execution environment"},
		{Icon = "🌟", Title = "Premium Features", Desc = "Unlock advanced tools"},
	}
	
	for i, cardInfo in ipairs(cardData) do
		local row = math.floor((i - 1) / 2)
		local col = ((i - 1) % 2)
		
		local card = Instance.new("Frame")
		card.Name = "Card_" .. i
		card.BackgroundColor3 = THEME.BG_Card
		card.BorderSizePixel = 0
		card.Size = UDim2.new(0.48, 0, 0, 140)
		card.Position = UDim2.new(col * 0.51, 0, row * 0.35, 0)
		card.Parent = mainContent
		
		local cardCorner = Instance.new("UICornerRadius")
		cardCorner.CornerRadius = UDim.new(0, 14)
		cardCorner.Parent = card
		
		local cardStroke = Instance.new("UIStroke")
		cardStroke.Color = THEME.Border
		cardStroke.Thickness = 1
		cardStroke.Parent = card
		
		-- Gradient accent
		local cardGradient = Instance.new("Frame")
		cardGradient.Name = "GradientAccent"
		cardGradient.BackgroundColor3 = THEME.BG_Card
		cardGradient.BorderSizePixel = 0
		cardGradient.Size = UDim2.new(1, 0, 0, 3)
		cardGradient.Position = UDim2.new(0, 0, 0, 0)
		cardGradient.Parent = card
		
		local gradAccent = Instance.new("UIGradient")
		gradAccent.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, THEME.Primary1),
			ColorSequenceKeypoint.new(1, THEME.Primary2),
		})
		gradAccent.Parent = cardGradient
		
		-- Icon
		local icon = Instance.new("TextLabel")
		icon.Name = "Icon"
		icon.Text = cardInfo.Icon
		icon.TextSize = 32
		icon.BackgroundTransparency = 1
		icon.Size = UDim2.new(0, 50, 0, 50)
		icon.Position = UDim2.new(0, 10, 0, 15)
		icon.Parent = card
		
		-- Title
		local cardTitle = Instance.new("TextLabel")
		cardTitle.Name = "Title"
		cardTitle.Text = cardInfo.Title
		cardTitle.TextSize = 14
		cardTitle.TextColor3 = THEME.Text_Primary
		cardTitle.BackgroundTransparency = 1
		cardTitle.Font = Enum.Font.GothamBold
		cardTitle.Size = UDim2.new(0.5, -20, 0, 25)
		cardTitle.Position = UDim2.new(0, 70, 0, 15)
		cardTitle.TextXAlignment = Enum.TextXAlignment.Left
		cardTitle.Parent = card
		
		-- Description
		local desc = Instance.new("TextLabel")
		desc.Name = "Description"
		desc.Text = cardInfo.Desc
		desc.TextSize = 11
		desc.TextColor3 = THEME.Text_Secondary
		desc.BackgroundTransparency = 1
		desc.Font = Enum.Font.Gotham
		desc.Size = UDim2.new(1, -20, 0, 40)
		desc.Position = UDim2.new(0, 10, 0, 55)
		desc.TextXAlignment = Enum.TextXAlignment.Left
		desc.TextWrapped = true
		desc.Parent = card
		
		-- Hover effect
		card.MouseEnter:Connect(function()
			local tween = TweenService:Create(
				cardStroke,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Color = THEME.Primary2}
			)
			tween:Play()
		end)
		
		card.MouseLeave:Connect(function()
			local tween = TweenService:Create(
				cardStroke,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Color = THEME.Border}
			)
			tween:Play()
		end)
	end
	
	-- ═══════════════════════════════════════════════════════════════
	-- FOOTER
	-- ═══════════════════════════════════════════════════════════════
	
	local footer = Instance.new("Frame")
	footer.Name = "Footer"
	footer.BackgroundColor3 = THEME.BG_DarkAlt
	footer.BorderSizePixel = 0
	footer.Size = UDim2.new(1, 0, 0, 20)
	footer.Position = UDim2.new(0, 0, 1, -20)
	footer.Parent = screenGui
	
	local footerText = Instance.new("TextLabel")
	footerText.Name = "FooterText"
	footerText.Text = "© 2024 HDANH Hub | Version 2.0 | Website: hdanh.qzz.io"
	footerText.TextSize = 11
	footerText.TextColor3 = THEME.Text_Muted
	footerText.BackgroundTransparency = 1
	footerText.Font = Enum.Font.Gotham
	footerText.Size = UDim2.new(1, 0, 1, 0)
	footerText.Parent = footer
	footerText.TextXAlignment = Enum.TextXAlignment.Center
	
	-- ═══════════════════════════════════════════════════════════════
	-- ANIMATION LOOPS
	-- ═══════════════════════════════════════════════════════════════
	
	local animationAngle = 0
	RunService.RenderStepped:Connect(function()
		animationAngle = animationAngle + 1
		gradient.Rotation = animationAngle * 0.5
	end)
	
	-- ═══════════════════════════════════════════════════════════════
	-- CLOSE/DRAG FUNCTIONALITY
	-- ═══════════════════════════════════════════════════════════════
	
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Text = "✕"
	closeBtn.TextSize = 18
	closeBtn.TextColor3 = THEME.Text_Secondary
	closeBtn.BackgroundColor3 = THEME.BG_DarkAlt
	closeBtn.BorderSizePixel = 0
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Size = UDim2.new(0, 40, 0, 40)
	closeBtn.Position = UDim2.new(1, -60, 0, 30)
	closeBtn.Parent = header
	
	local closeCorner = Instance.new("UICornerRadius")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeBtn
	
	closeBtn.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)
	
	closeBtn.MouseEnter:Connect(function()
		closeBtn.TextColor3 = THEME.Accent_Warning
	end)
	
	closeBtn.MouseLeave:Connect(function()
		closeBtn.TextColor3 = THEME.Text_Secondary
	end)
	
	return screenGui
end

-- ═══════════════════════════════════════════════════════════════
-- INIT
-- ═══════════════════════════════════════════════════════════════

pcall(function()
	createMainUI()
	print("✓ HDANH Hub loaded successfully | Discord: https://discord.gg/shinmod")
end)
