-- ╔═══════════════════════════════════════════════════════════════╗
-- ║    HDANH HUB - Discord Popup v2.0                            ║
-- ║         Modern Design with Animations                         ║
-- ╚═══════════════════════════════════════════════════════════════╝

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- Configuration
local DISCORD_INVITE = "https://discord.gg/shinmod"
local DISCORD_INVITE_TEXT = "discord.gg/shinmod"
local TITLE_TEXT = "HDANH HUB"
local SUBTITLE_TEXT = "Join the Community"
local BODY_TEXT = "Connect with fellow gamers, get updates, and access exclusive tools."
local MEMBERS_COUNT = "500+"
local MEMBERS_LABEL = "Active Members"

local LOCK_KEY = "\0hdanh_discord_popup"
local SAVE_FILE = "HDANH Hub/DiscordPopup.json"

-- Modern Color Palette
local COLORS = {
	-- Primary Gradient
	Primary1 = Color3.fromRGB(139, 0, 255),     -- Vibrant Purple
	Primary2 = Color3.fromRGB(0, 191, 255),     -- Cyan Blue
	Primary3 = Color3.fromRGB(255, 0, 127),     -- Hot Pink
	
	-- Dark Mode
	BG_Dark = Color3.fromRGB(10, 10, 20),
	BG_DarkAlt = Color3.fromRGB(15, 15, 35),
	BG_Card = Color3.fromRGB(20, 20, 40),
	
	-- Text
	Text_Primary = Color3.fromRGB(255, 255, 255),
	Text_Secondary = Color3.fromRGB(180, 180, 200),
	
	-- Accents
	Accent_Glow = Color3.fromRGB(0, 255, 200),
	Accent_Success = Color3.fromRGB(0, 255, 100),
	
	-- Borders
	Border = Color3.fromRGB(60, 60, 100),
	Border_Light = Color3.fromRGB(80, 80, 120),
}

-- Check if already shown
local environment = (typeof(getgenv) == "function" and getgenv()) or _G
if environment[LOCK_KEY] ~= nil then
	return
end

local function alreadyShown()
	if typeof(isfile) ~= "function" or typeof(readfile) ~= "function" then
		return false
	end
	local okExists, exists = pcall(isfile, SAVE_FILE)
	if not okExists or not exists then
		return false
	end
	local okRead, content = pcall(readfile, SAVE_FILE)
	if not okRead then
		return false
	end
	return content == "true"
end

local function markAsShown()
	if typeof(writefile) == "function" then
		local okMakeDir = pcall(makefolder, "HDANH Hub")
		if okMakeDir or typeof(isfolder) == "function" and isfolder("HDANH Hub") then
			local ok = pcall(writefile, SAVE_FILE, "true")
			if ok then
				return true
			end
		end
	end
	return false
end

-- Skip if already shown (optional - comment out to show always)
-- if alreadyShown() then
-- 	return
-- end

-- ═══════════════════════════════════════════════════════════════
-- CREATE DISCORD POPUP
-- ═══════════════════════════════════════════════════════════════

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HDANHDiscordPopup"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = CoreGui

-- Blur background
local blurFrame = Instance.new("Frame")
blurFrame.Name = "BlurBackground"
blurFrame.BackgroundColor3 = Color3.new(0, 0, 0)
blurFrame.BackgroundTransparency = 0.3
blurFrame.BorderSizePixel = 0
blurFrame.Size = UDim2.new(1, 0, 1, 0)
blurFrame.Parent = screenGui

-- Main popup container
local popupContainer = Instance.new("Frame")
popupContainer.Name = "PopupContainer"
popupContainer.BackgroundColor3 = COLORS.BG_DarkAlt
popupContainer.BorderSizePixel = 0
popupContainer.Size = UDim2.new(0, 500, 0, 480)
popupContainer.Position = UDim2.new(0.5, -250, 0.5, -240)
popupContainer.Parent = screenGui

-- Popup corner radius
local popupCorner = Instance.new("UICornerRadius")
popupCorner.CornerRadius = UDim.new(0, 20)
popupCorner.Parent = popupContainer

-- Popup border/stroke
local popupStroke = Instance.new("UIStroke")
popupStroke.Color = COLORS.Border_Light
popupStroke.Thickness = 2
popupStroke.Parent = popupContainer

-- Gradient overlay at top
local gradientTop = Instance.new("Frame")
gradientTop.Name = "GradientTop"
gradientTop.BackgroundColor3 = COLORS.Primary1
gradientTop.BorderSizePixel = 0
gradientTop.Size = UDim2.new(1, 0, 0, 3)
gradientTop.Position = UDim2.new(0, 0, 0, 0)
gradientTop.Parent = popupContainer

local gradAccent = Instance.new("UIGradient")
gradAccent.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, COLORS.Primary1),
	ColorSequenceKeypoint.new(0.5, COLORS.Primary3),
	ColorSequenceKeypoint.new(1, COLORS.Primary2),
})
gradAccent.Parent = gradientTop

-- ═══════════════════════════════════════════════════════════════
-- HEADER WITH LOGO
-- ═══════════════════════════════════════════════════════════════

local headerBg = Instance.new("Frame")
headerBg.Name = "HeaderBg"
headerBg.BackgroundColor3 = COLORS.BG_Card
headerBg.BorderSizePixel = 0
headerBg.Size = UDim2.new(1, 0, 0, 80)
headerBg.Position = UDim2.new(0, 0, 0, 3)
headerBg.Parent = popupContainer

-- Logo circle
local logoBg = Instance.new("Frame")
logoBg.Name = "LogoBg"
logoBg.BackgroundColor3 = COLORS.Primary2
logoBg.BorderSizePixel = 0
logoBg.Size = UDim2.new(0, 60, 0, 60)
logoBg.Position = UDim2.new(0, 20, 0.5, -30)
logoBg.Parent = headerBg

local logoCorner = Instance.new("UICornerRadius")
logoCorner.CornerRadius = UDim.new(0, 15)
logoCorner.Parent = logoBg

local logoStroke = Instance.new("UIStroke")
logoStroke.Color = COLORS.Primary1
logoStroke.Thickness = 2
logoStroke.Parent = logoBg

local logoText = Instance.new("TextLabel")
logoText.Name = "LogoText"
logoText.Text = "H"
logoText.TextSize = 28
logoText.TextColor3 = COLORS.BG_Dark
logoText.BackgroundTransparency = 1
logoText.Font = Enum.Font.GothamBold
logoText.Size = UDim2.new(1, 0, 1, 0)
logoText.Parent = logoBg

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Text = TITLE_TEXT
titleLabel.TextSize = 22
titleLabel.TextColor3 = COLORS.Text_Primary
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Size = UDim2.new(0, 350, 0, 35)
titleLabel.Position = UDim2.new(0, 95, 0, 10)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = headerBg

-- Subtitle
local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Name = "Subtitle"
subtitleLabel.Text = SUBTITLE_TEXT
subtitleLabel.TextSize = 13
subtitleLabel.TextColor3 = COLORS.Text_Secondary
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.Size = UDim2.new(0, 350, 0, 25)
subtitleLabel.Position = UDim2.new(0, 95, 0, 45)
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subtitleLabel.Parent = headerBg

-- ═══════════════════════════════════════════════════════════════
-- CONTENT SECTION
-- ═══════════════════════════════════════════════════════════════

local contentBg = Instance.new("Frame")
contentBg.Name = "ContentBg"
contentBg.BackgroundTransparency = 1
contentBg.BorderSizePixel = 0
contentBg.Size = UDim2.new(1, 0, 0, 200)
contentBg.Position = UDim2.new(0, 0, 0, 90)
contentBg.Parent = popupContainer

-- Body text
local bodyText = Instance.new("TextLabel")
bodyText.Name = "BodyText"
bodyText.Text = BODY_TEXT
bodyText.TextSize = 13
bodyText.TextColor3 = COLORS.Text_Secondary
bodyText.BackgroundTransparency = 1
bodyText.Font = Enum.Font.Gotham
bodyText.TextWrapped = true
bodyText.Size = UDim2.new(1, -40, 0, 60)
bodyText.Position = UDim2.new(0, 20, 0, 20)
bodyText.TextXAlignment = Enum.TextXAlignment.Left
bodyText.TextYAlignment = Enum.TextYAlignment.Top
bodyText.Parent = contentBg

-- Members stats box
local statsBox = Instance.new("Frame")
statsBox.Name = "StatsBox"
statsBox.BackgroundColor3 = COLORS.BG_Card
statsBox.BorderSizePixel = 0
statsBox.Size = UDim2.new(1, -40, 0, 80)
statsBox.Position = UDim2.new(0, 20, 0, 90)
statsBox.Parent = contentBg

local statsCorner = Instance.new("UICornerRadius")
statsCorner.CornerRadius = UDim.new(0, 12)
statsCorner.Parent = statsBox

local statsStroke = Instance.new("UIStroke")
statsStroke.Color = COLORS.Border
statsStroke.Thickness = 1
statsStroke.Parent = statsBox

-- Stats gradient accent
local statsAccent = Instance.new("Frame")
statsAccent.Name = "Accent"
statsAccent.BackgroundColor3 = COLORS.Primary1
statsAccent.BorderSizePixel = 0
statsAccent.Size = UDim2.new(0, 4, 1, 0)
statsAccent.Position = UDim2.new(0, 0, 0, 0)
statsAccent.Parent = statsBox

local accentCorner = Instance.new("UICornerRadius")
accentCorner.CornerRadius = UDim.new(0, 12)
accentCorner.Parent = statsAccent

-- Members count
local membersCount = Instance.new("TextLabel")
membersCount.Name = "MembersCount"
membersCount.Text = MEMBERS_COUNT
membersCount.TextSize = 24
membersCount.TextColor3 = COLORS.Accent_Glow
membersCount.BackgroundTransparency = 1
membersCount.Font = Enum.Font.GothamBold
membersCount.Size = UDim2.new(0, 100, 0, 35)
membersCount.Position = UDim2.new(0, 20, 0, 15)
membersCount.TextXAlignment = Enum.TextXAlignment.Left
membersCount.Parent = statsBox

-- Members label
local membersLabel = Instance.new("TextLabel")
membersLabel.Name = "MembersLabel"
membersLabel.Text = MEMBERS_LABEL
membersLabel.TextSize = 11
membersLabel.TextColor3 = COLORS.Text_Secondary
membersLabel.BackgroundTransparency = 1
membersLabel.Font = Enum.Font.Gotham
membersLabel.Size = UDim2.new(0, 100, 0, 20)
membersLabel.Position = UDim2.new(0, 20, 0, 50)
membersLabel.TextXAlignment = Enum.TextXAlignment.Left
membersLabel.Parent = statsBox

-- Discord link
local discordLink = Instance.new("TextLabel")
discordLink.Name = "DiscordLink"
discordLink.Text = "💬 " .. DISCORD_INVITE_TEXT
discordLink.TextSize = 11
discordLink.TextColor3 = COLORS.Primary2
discordLink.BackgroundTransparency = 1
discordLink.Font = Enum.Font.GothamBold
discordLink.Size = UDim2.new(0, 200, 0, 20)
discordLink.Position = UDim2.new(1, -220, 0, 30)
discordLink.TextXAlignment = Enum.TextXAlignment.Right
discordLink.Parent = statsBox

-- ═══════════════════════════════════════════════════════════════
-- ACTION BUTTONS
-- ═══════════════════════════════════════════════════════════════

local buttonContainer = Instance.new("Frame")
buttonContainer.Name = "ButtonContainer"
buttonContainer.BackgroundTransparency = 1
buttonContainer.BorderSizePixel = 0
buttonContainer.Size = UDim2.new(1, 0, 0, 80)
buttonContainer.Position = UDim2.new(0, 0, 1, -80)
buttonContainer.Parent = popupContainer

-- Button corner
local function makeButton(name, text, color, pos)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Text = text
	btn.TextSize = 14
	btn.TextColor3 = COLORS.Text_Primary
	btn.BackgroundColor3 = color
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.GothamBold
	btn.Size = UDim2.new(0, 200, 0, 50)
	btn.Position = pos
	btn.Parent = buttonContainer
	
	local btnCorner = Instance.new("UICornerRadius")
	btnCorner.CornerRadius = UDim.new(0, 12)
	btnCorner.Parent = btn
	
	local btnStroke = Instance.new("UIStroke")
	btnStroke.Color = COLORS.Accent_Glow
	btnStroke.Thickness = 1
	btnStroke.Parent = btn
	
	-- Hover effect
	btn.MouseEnter:Connect(function()
		local tween = TweenService:Create(
			btn,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = color + Color3.new(0.1, 0.1, 0.1)}
		)
		tween:Play()
	end)
	
	btn.MouseLeave:Connect(function()
		local tween = TweenService:Create(
			btn,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = color}
		)
		tween:Play()
	end)
	
	return btn
end

-- Join button
local joinBtn = makeButton("JoinButton", "🔗 JOIN DISCORD", COLORS.Primary2, UDim2.new(0, 20, 0, 15))
local joinBtnOriginalColor = COLORS.Primary2
local joinBtnClicked = false

joinBtn.MouseButton1Click:Connect(function()
	if joinBtnClicked then return end
	joinBtnClicked = true
	
	setclipboard(DISCORD_INVITE)
	
	-- Change button text to show success
	joinBtn.Text = "✓ COPIED!"
	joinBtn.BackgroundColor3 = COLORS.Accent_Success
	
	-- Reset after 2 seconds
	task.wait(2)
	joinBtn.Text = "🔗 JOIN DISCORD"
	joinBtn.BackgroundColor3 = joinBtnOriginalColor
	joinBtnClicked = false
	
	markAsShown()
	print("✓ Discord link copied: " .. DISCORD_INVITE)
end)

-- Close button
local closeBtn = makeButton("CloseButton", "CLOSE", COLORS.BG_Card, UDim2.new(0, 280, 0, 15))
closeBtn.TextColor3 = COLORS.Text_Secondary

local closeStroke = closeBtn:FindFirstChild("UIStroke")
if closeStroke then
	closeStroke.Color = COLORS.Border
end

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- ═══════════════════════════════════════════════════════════════
-- ANIMATIONS
-- ═══════════════════════════════════════════════════════════════

-- Popup entrance animation
local popupTween = TweenService:Create(
	popupContainer,
	TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	{Position = UDim2.new(0.5, -250, 0.5, -240)}
)
popupContainer.Position = UDim2.new(0.5, -250, 0.5, -400)
popupTween:Play()

-- Rotating logo animation
local rotationAngle = 0
RunService.RenderStepped:Connect(function()
	rotationAngle = rotationAngle + 0.5
	-- Optional: Add subtle rotation or glow pulse here
end)

-- Glow pulse animation
task.spawn(function()
	while screenGui.Parent do
		local glowTween = TweenService:Create(
			logoBg,
			TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{BackgroundColor3 = COLORS.Primary3}
		)
		glowTween:Play()
		glowTween.Completed:Wait()
		
		local glowTween2 = TweenService:Create(
			logoBg,
			TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{BackgroundColor3 = COLORS.Primary2}
		)
		glowTween2:Play()
		glowTween2.Completed:Wait()
	end
end)

-- Set lock to prevent re-showing this session
environment[LOCK_KEY] = true

print("✓ HDANH Hub Discord Popup loaded | Join: " .. DISCORD_INVITE)
