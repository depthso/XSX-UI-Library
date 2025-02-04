--[[
  Forked UI from bungie#0001
  Edited by Depso

  I edited this a while ago, the code may not meet my standards xD

  This is also no longer speific to Synapse-X
]]

local CloneRef = cloneref or function(a)return a end

--// Service handlers
local Services = setmetatable({}, {
	__index = function(self, Name: string)
		local Service = game:GetService(Name)
		return CloneRef(Service)
	end,
})

-- / Locals
local Player = Services.Players.LocalPlayer
local Mouse = CloneRef(Player:GetMouse())

-- / Services
local UserInputService = Services.UserInputService
local TextService = Services.TextService
local TweenService =Services.TweenService
local RunService = Services.RunService
local CoreGui = RunService:IsStudio() and CloneRef(Player:WaitForChild("PlayerGui")) or Services.CoreGui
local TeleportService = Services.TeleportService
local Workspace = Services.Workspace
local CurrentCam = Workspace.CurrentCamera

local hiddenUI = get_hidden_gui or gethui or function(a)return CoreGui end

-- / Defaults 
local OptionStates = {} -- Used for panic
local library = {
	title = "Bozo depso",
	company = "Company",
	
	RainbowEnabled = true,
	BlurEffect = true,
	BlurSize = 24,
	FieldOfView = CurrentCam.FieldOfView,

	Key = UserInputService.TouchEnabled and Enum.KeyCode.P or Enum.KeyCode.RightShift,
	fps = 0,
	Debug = true,

	-- / Elements Config
	transparency = 0,
	backgroundColor = Color3.fromRGB(31, 31, 31),
	headerColor = Color3.fromRGB(255, 255, 255),
	companyColor = Color3.fromRGB(163, 151, 255),
	acientColor = Color3.fromRGB(167, 154, 121),
	darkGray = Color3.fromRGB(27, 27, 27),
	lightGray = Color3.fromRGB(48, 48, 48),

	Font = Enum.Font.Code,

	rainbowColors = ColorSequence.new{
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(241, 137, 53)), 
		ColorSequenceKeypoint.new(0.33, Color3.fromRGB(241, 53, 106)), 
		ColorSequenceKeypoint.new(0.66, Color3.fromRGB(133, 53, 241)), 
		ColorSequenceKeypoint.new(1, Color3.fromRGB(53, 186, 241))
	}
}

local function Warn(...)
	if not library.Debug then return end
	warn("Depso:", ...)
end

-- / Remove the previous interface
if _G.DepsoGUI then
	pcall(function()
		_G.DepsoGUI:Remove()
	end)
end
_G.DepsoGUI = library

-- / Blur effect
local Blur = Instance.new("BlurEffect", CurrentCam)
Blur.Enabled = true
Blur.Size = 0

-- / Tween table & function
local TweenWrapper = {}

function TweenWrapper:Init()
	self.RealStyles = {
		Default = {
			TweenInfo.new(0.17, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0)
		}
	}
	self.Styles = setmetatable({}, {
		__index = function(_, Key)
			local Value = self.RealStyles[Key]
			if not Value then
				Warn(`No Tween style for {Key}, returning default`)
				return self.RealStyles.Default
			end
			return Value
		end,
	})
end

function TweenWrapper:CreateStyle(name, speed, ...)
	if not name then 
		return TweenInfo.new(0) 
	end

	local Tweeninfo = TweenInfo.new(
		speed or 0.17, 
		...
	)

	self.RealStyles[name] = Tweeninfo
	return Tweeninfo
end

TweenWrapper:Init()


-- / Dragging
local function EnableDrag(obj, latency)
	if not obj then
		return
	end
	latency = latency or 0.06

	local toggled = nil
	local input = nil
	local start = nil
	local startPos = obj.Position
	
	local function InputIsAccepted(Input)
		local UserInputType = Input.UserInputType
		
		if UserInputType == Enum.UserInputType.Touch then return true end
		if UserInputType == Enum.UserInputType.MouseButton1 then return true end
		
		return false
	end

	obj.InputBegan:Connect(function(Input)
		if not InputIsAccepted(Input) then return end
		
		toggled = true
		start = Input.Position
		startPos = obj.Position
		
		Input.Changed:Connect(function()
			if Input.UserInputState == Enum.UserInputState.End then
				toggled = false
			end
		end)
	end)

	obj.InputChanged:Connect(function(Input)
		local MouseMovement = Input.UserInputType == Enum.UserInputType.MouseMovement
		if not MouseMovement and not InputIsAccepted(Input) then return end 
		
		input = Input
	end)

	UserInputService.InputChanged:Connect(function(Input)
		if Input == input and toggled then
			local Delta = input.Position - start
			local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + Delta.X, startPos.Y.Scale, startPos.Y.Offset + Delta.Y)
			TweenService:Create(obj, TweenInfo.new(latency), {Position = Position}):Play()
		end
	end)
end

RunService.RenderStepped:Connect(function(v)
	library.fps =  math.round(1/v)
end)

function library:RoundNumber(int, float)
	return tonumber(string.format("%." .. (int or 0) .. "f", float))
end

function library:GetUsername()
	return Player.Name
end

function library:Panic()
	for Frame, Data in next, OptionStates do
		local Functions = Data[2]
		local State = Data[1]

		Functions:Set(State)
	end
	return self
end

function library:SetKeybind(new)
	library.Key = new
	return self
end

function library:IsGameLoaded()
	return game:IsLoaded()
end

function library:GetUserId()
	return Player.UserId
end

function library:GetPlaceId()
	return game.PlaceId
end

function library:GetJobId()
	return game.JobId
end

function library:Rejoin()
	TeleportService:TeleportToPlaceInstance(
		library:GetPlaceId(), 
		library:GetJobId(), 
		library:GetUserId()
	)
end

function library:Copy(input) 
	local clipBoard = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
	if clipBoard then
		clipBoard(input)
	end
end

function library:GetDay(type)
	if type == "word" then -- day in a full word
		return os.date("%A")
	elseif type == "short" then -- day in a shortened word
		return os.date("%a")
	elseif type == "month" then -- day of the month in digits
		return os.date("%d")
	elseif type == "year" then -- day of the year in digits
		return os.date("%j")
	end
end

function library:GetTime(type)
	if type == "24h" then -- time using a 24 hour clock
		return os.date("%H")
	elseif type == "12h" then -- time using a 12 hour clock
		return os.date("%I")
	elseif type == "minute" then -- time in minutes
		return os.date("%M")
	elseif type == "half" then -- what part of the day it is (AM or PM)
		return os.date("%p")
	elseif type == "second" then -- time in seconds
		return os.date("%S")
	elseif type == "full" then -- full time
		return os.date("%X")
	elseif type == "ISO" then -- ISO / UTC ( 1min = 1, 1hour = 100)
		return os.date("%z")
	elseif type == "zone" then -- time zone
		return os.date("%Z") 
	end
end

function library:GetMonth(type)
	if type == "word" then -- full month name
		return os.date("%B")
	elseif type == "short" then -- month in shortened word
		return os.date("%b")
	elseif type == "digit" then -- the months digit
		return os.date("%m")
	end
end

function library:GetWeek(type)
	if type == "year_S" then -- the number of the week in the current year (sunday first day)
		return os.date("%U")
	elseif type == "day" then -- the week day
		return os.date("%w")
	elseif type == "year_M" then -- the number of the week in the current year (monday first day)
		return os.date("%W")
	end
end

function library:GetYear(type)
	if type == "digits" then -- the second 2 digits of the year
		return os.date("%y")
	elseif type == "full" then -- the full year
		return os.date("%Y")
	end
end

function library:UnlockFps(new) 
	if setfpscap then
		setfpscap(new)
	end
end

TweenWrapper:CreateStyle("Rainbow", 5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
function library:ApplyRainbow(instance, Wave)
	local Colors = library.rainbowColors
	local RainbowEnabled = library.RainbowEnabled
	
	if not RainbowEnabled then return end

	if not Wave then
		instance.BackgroundColor3 = Colors.Keypoints[1].Value
		TweenService:Create(instance, TweenWrapper.Styles["Rainbow"], {
			BackgroundColor3 =  Colors.Keypoints[#Colors.Keypoints].Value
		}):Play()

		return
	end

	local gradient = Instance.new("UIGradient", instance)
	gradient.Offset = Vector2.new(-0.8, 0)
	gradient.Color = Colors

	TweenService:Create(gradient, TweenWrapper.Styles["Rainbow"], {
		Offset = Vector2.new(0.8, 0)
	}):Play()
end

--/ Watermark library
TweenWrapper:CreateStyle("wm", 0.24)
TweenWrapper:CreateStyle("wm_2", 0.04)

function library:Init(Config)
	--/ Apply new config
	for Key, Value in next, Config do
		library[Key] = Value
	end

	local watermark = Instance.new("ScreenGui", CoreGui)
	watermark.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local watermarkPadding = Instance.new("UIPadding")
	watermarkPadding.Parent = watermark
	watermarkPadding.PaddingBottom = UDim.new(0, 6)
	watermarkPadding.PaddingLeft = UDim.new(0, 6)

	local watermarkLayout = Instance.new("UIListLayout")
	watermarkLayout.Parent = watermark
	watermarkLayout.FillDirection = Enum.FillDirection.Horizontal
	watermarkLayout.SortOrder = Enum.SortOrder.LayoutOrder
	watermarkLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	watermarkLayout.Padding = UDim.new(0, 4)

	function library:Watermark(text)
		local edge = Instance.new("Frame")
		local edgeCorner = Instance.new("UICorner")
		local background = Instance.new("Frame")
		local barFolder = Instance.new("Folder")
		local bar = Instance.new("Frame")
		local barCorner = Instance.new("UICorner")
		local barLayout = Instance.new("UIListLayout")
		local backgroundGradient = Instance.new("UIGradient")
		local backgroundCorner = Instance.new("UICorner")
		local waterText = Instance.new("TextLabel")
		local waterPadding = Instance.new("UIPadding")
		local backgroundLayout = Instance.new("UIListLayout")

		edge.Parent = watermark
		edge.AnchorPoint = Vector2.new(0.5, 0.5)
		edge.BackgroundColor3 = library.backgroundColor
		edge.Position = UDim2.new(0.5, 0, -0.03, 0)
		edge.Size = UDim2.new(0, 0, 0, 26)
		edge.BackgroundTransparency = 1

		edgeCorner.CornerRadius = UDim.new(0, 2)
		edgeCorner.Parent = edge

		background.Parent = edge
		background.AnchorPoint = Vector2.new(0.5, 0.5)
		background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		background.BackgroundTransparency = 1
		background.ClipsDescendants = true
		background.Position = UDim2.new(0.5, 0, 0.5, 0)
		background.Size = UDim2.new(0, 0, 0, 24)

		barFolder.Parent = background

		bar.Parent = barFolder
		bar.BackgroundColor3 = library.acientColor
		bar.BackgroundTransparency = 0
		bar.Size = UDim2.new(0, 0, 0, 2)

		self:ApplyRainbow(bar, false)

		barCorner.CornerRadius = UDim.new(0, 2)
		barCorner.Parent = bar

		barLayout.Parent = barFolder
		barLayout.SortOrder = Enum.SortOrder.LayoutOrder

		backgroundGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(34, 34, 34)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(28, 28, 28))}
		backgroundGradient.Rotation = 90
		backgroundGradient.Parent = background

		backgroundCorner.CornerRadius = UDim.new(0, 2)
		backgroundCorner.Parent = background

		waterText.Parent = background
		waterText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		waterText.BackgroundTransparency = 1.000
		waterText.Position = UDim2.new(0, 0, -0.0416666679, 0)
		waterText.Size = UDim2.new(0, 0, 0, 24)
		waterText.Font = library.Font
		waterText.Text = text
		waterText.TextColor3 = Color3.fromRGB(198, 198, 198)
		waterText.TextTransparency = 1
		waterText.TextSize = 14.000
		waterText.RichText = true

		local NewSize = TextService:GetTextSize(waterText.Text, waterText.TextSize, waterText.Font, Vector2.new(math.huge, math.huge))
		waterText.Size = UDim2.new(0, NewSize.X + 8, 0, 24)

		waterPadding.Parent = waterText
		waterPadding.PaddingBottom = UDim.new(0, 4)
		waterPadding.PaddingLeft = UDim.new(0, 4)
		waterPadding.PaddingRight = UDim.new(0, 4)
		waterPadding.PaddingTop = UDim.new(0, 4)

		backgroundLayout.Parent = background
		backgroundLayout.SortOrder = Enum.SortOrder.LayoutOrder
		backgroundLayout.VerticalAlignment = Enum.VerticalAlignment.Center

		coroutine.wrap(function()
			TweenService:Create(edge, TweenWrapper.Styles["wm"], {BackgroundTransparency = 0}):Play()
			TweenService:Create(edge, TweenWrapper.Styles["wm"], {Size = UDim2.new(0, NewSize.x + 10, 0, 26)}):Play()
			TweenService:Create(background, TweenWrapper.Styles["wm"], {BackgroundTransparency = 0}):Play()
			TweenService:Create(background, TweenWrapper.Styles["wm"], {Size = UDim2.new(0, NewSize.x + 8, 0, 24)}):Play()
			wait(.2)
			TweenService:Create(bar, TweenWrapper.Styles["wm"], {Size = UDim2.new(0, NewSize.x + 8, 0, 1)}):Play()
			wait(.1)
			TweenService:Create(waterText, TweenWrapper.Styles["wm"], {TextTransparency = 0}):Play()
		end)()

		local WatermarkFunctions = {}

		function WatermarkFunctions:Hide()
			edge.Visible = false
			return self
		end

		function WatermarkFunctions:Show()
			edge.Visible = true
			return self
		end

		function WatermarkFunctions:SetText(new)
			new = new or text
			waterText.Text = new

			local NewSize = TextService:GetTextSize(waterText.Text, waterText.TextSize, waterText.Font, Vector2.new(math.huge, math.huge))
			coroutine.wrap(function()
				TweenService:Create(edge, TweenWrapper.Styles["wm_2"], {Size = UDim2.new(0, NewSize.x + 10, 0, 26)}):Play()
				TweenService:Create(background, TweenWrapper.Styles["wm_2"], {Size = UDim2.new(0, NewSize.x + 8, 0, 24)}):Play()
				TweenService:Create(bar, TweenWrapper.Styles["wm_2"], {Size = UDim2.new(0, NewSize.x + 8, 0, 1)}):Play()
				TweenService:Create(waterText, TweenWrapper.Styles["wm_2"], {Size = UDim2.new(0, NewSize.x + 8, 0, 1)}):Play()
			end)()

			return self
		end

		function WatermarkFunctions:Remove()
			watermark:Destroy()
			return self
		end
		return WatermarkFunctions
	end


	-- InitNotifications

	local Notification = {}
	local Notifications = Instance.new("ScreenGui", hiddenUI())
	local notificationsLayout = Instance.new("UIListLayout", Notifications)
	local notificationsPadding = Instance.new("UIPadding", Notifications)

	Notifications.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	notificationsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	notificationsLayout.Padding = UDim.new(0, 4)

	notificationsPadding.PaddingLeft = UDim.new(0, 6)
	notificationsPadding.PaddingTop = UDim.new(0, 18)

	function library:Notify(text, duration, type, callback)
		TweenWrapper:CreateStyle("notification_load", 0.2)

		text = tostring(text)
		duration = duration or 5
		type = type or "notification"
		callback = callback or function() end

		local edge = Instance.new("Frame", Notifications)
		local edgeCorner = Instance.new("UICorner")
		local background = Instance.new("Frame")
		local barFolder = Instance.new("Folder")
		local bar = Instance.new("Frame")
		local barCorner = Instance.new("UICorner")
		local barLayout = Instance.new("UIListLayout")
		local backgroundGradient = Instance.new("UIGradient")
		local backgroundCorner = Instance.new("UICorner")
		local notifText = Instance.new("TextLabel")
		local notifPadding = Instance.new("UIPadding")
		local backgroundLayout = Instance.new("UIListLayout")

		edge.BackgroundColor3 = library.backgroundColor
		edge.BackgroundTransparency = 1.000
		edge.Size = UDim2.new(0, 0, 0, 26)

		edgeCorner.CornerRadius = UDim.new(0, 2)
		edgeCorner.Parent = edge

		background.Parent = edge
		background.AnchorPoint = Vector2.new(0.5, 0.5)
		background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		background.BackgroundTransparency = 1.000
		background.ClipsDescendants = true
		background.Position = UDim2.new(0.5, 0, 0.5, 0)
		background.Size = UDim2.new(0, 0, 0, 24)

		barFolder.Parent = background

		bar.Parent = barFolder
		bar.BackgroundColor3 = library.acientColor
		bar.BackgroundTransparency = 0.200
		bar.Size = UDim2.new(0, 0, 0, 1)

		if type == "alert" then
			bar.BackgroundColor3 = Color3.fromRGB(255, 246, 112)
		elseif type == "error" then
			bar.BackgroundColor3 = Color3.fromRGB(255, 74, 77)
		elseif type == "success" then
			bar.BackgroundColor3 = Color3.fromRGB(131, 255, 103)
		else
			library:ApplyRainbow(bar, false)
		end

		barCorner.CornerRadius = UDim.new(0, 2)
		barCorner.Parent = bar

		barLayout.Parent = barFolder
		barLayout.SortOrder = Enum.SortOrder.LayoutOrder

		backgroundGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(34, 34, 34)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(28, 28, 28))}
		backgroundGradient.Rotation = 90
		backgroundGradient.Parent = background

		backgroundCorner.CornerRadius = UDim.new(0, 2)
		backgroundCorner.Parent = background

		notifText.Parent = background
		notifText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		notifText.BackgroundTransparency = 1.000
		notifText.Size = UDim2.new(0, 230, 0, 26)
		notifText.Font = library.Font
		notifText.Text = text
		notifText.TextColor3 = Color3.fromRGB(198, 198, 198)
		notifText.TextSize = 14.000
		notifText.TextTransparency = 1.000
		notifText.TextXAlignment = Enum.TextXAlignment.Left
		notifText.RichText = true

		notifPadding.Parent = notifText
		notifPadding.PaddingBottom = UDim.new(0, 4)
		notifPadding.PaddingLeft = UDim.new(0, 4)
		notifPadding.PaddingRight = UDim.new(0, 4)
		notifPadding.PaddingTop = UDim.new(0, 4)

		backgroundLayout.Parent = background
		backgroundLayout.SortOrder = Enum.SortOrder.LayoutOrder
		backgroundLayout.VerticalAlignment = Enum.VerticalAlignment.Center

		local NewSize = TextService:GetTextSize(notifText.Text, notifText.TextSize, notifText.Font, Vector2.new(math.huge, math.huge))
		TweenWrapper:CreateStyle("notification_wait", duration, Enum.EasingStyle.Quad)
		local IsRunning = false
		coroutine.wrap(function()
			IsRunning = true
			TweenService:Create(edge, TweenWrapper.Styles["notification_load"], {BackgroundTransparency = 0}):Play()
			TweenService:Create(background, TweenWrapper.Styles["notification_load"], {BackgroundTransparency = 0}):Play()
			TweenService:Create(notifText, TweenWrapper.Styles["notification_load"], {TextTransparency = 0}):Play()
			TweenService:Create(edge, TweenWrapper.Styles["notification_load"], {Size = UDim2.new(0, NewSize.X + 10, 0, 26)}):Play()
			TweenService:Create(background, TweenWrapper.Styles["notification_load"], {Size = UDim2.new(0, NewSize.X + 8, 0, 24)}):Play()
			TweenService:Create(notifText, TweenWrapper.Styles["notification_load"], {Size = UDim2.new(0, NewSize.X + 8, 0, 24)}):Play()
			wait()
			local Tween = TweenService:Create(bar, TweenWrapper.Styles["notification_wait"], {Size = UDim2.new(0, NewSize.X + 8, 0, 1)})
			Tween:Play()
			Tween.Completed:Wait()
			IsRunning = false
			TweenService:Create(edge, TweenWrapper.Styles["notification_load"], {BackgroundTransparency = 1}):Play()
			TweenService:Create(background, TweenWrapper.Styles["notification_load"], {BackgroundTransparency = 1}):Play()
			TweenService:Create(notifText, TweenWrapper.Styles["notification_load"], {TextTransparency = 1}):Play()
			TweenService:Create(bar, TweenWrapper.Styles["notification_load"], {BackgroundTransparency = 1}):Play()
			TweenService:Create(edge, TweenWrapper.Styles["notification_load"], {Size = UDim2.new(0, 0, 0, 26)}):Play()
			TweenService:Create(background, TweenWrapper.Styles["notification_load"], {Size = UDim2.new(0, 0, 0, 24)}):Play()
			TweenService:Create(notifText, TweenWrapper.Styles["notification_load"], {Size = UDim2.new(0, 0, 0, 24)}):Play()
			TweenService:Create(bar, TweenWrapper.Styles["notification_load"], {Size = UDim2.new(0, 0, 0, 1)}):Play()
			wait(.2)
			edge:Destroy()
		end)()

		TweenWrapper:CreateStyle("notification_reset", 0.4)
		local NotificationFunctions = {}
		function NotificationFunctions:SetText(new)
			new = new or text
			notifText.Text = new

			NewSize = TextService:GetTextSize(notifText.Text, notifText.TextSize, notifText.Font, Vector2.new(math.huge, math.huge))
			local NewSize_2 = NewSize
			if IsRunning then
				TweenService:Create(edge, TweenWrapper.Styles["notification_load"], {Size = UDim2.new(0, NewSize.X + 10, 0, 26)}):Play()
				TweenService:Create(background, TweenWrapper.Styles["notification_load"], {Size = UDim2.new(0, NewSize.X + 8, 0, 24)}):Play()
				TweenService:Create(notifText, TweenWrapper.Styles["notification_load"], {Size = UDim2.new(0, NewSize.X + 8, 0, 24)}):Play()
				wait()
				TweenService:Create(bar, TweenWrapper.Styles["notification_reset"], {Size = UDim2.new(0, 0, 0, 1)}):Play()
				wait(.4)
				TweenService:Create(bar, TweenWrapper.Styles["notification_wait"], {Size = UDim2.new(0, NewSize.X + 8, 0, 1)}):Play()
			end

			return self
		end
		return NotificationFunctions
	end

	-- Introduction

	local introduction = Instance.new("ScreenGui", CoreGui)
	local background = Instance.new("Frame")
	local Logo = Instance.new("TextLabel")
	local backgroundGradient_2 = Instance.new("UIGradient")
	local bar = Instance.new("Frame")
	local barCorner = Instance.new("UICorner")
	local messages = Instance.new("Frame")
	local LogExample = Instance.new("TextLabel")
	local backgroundGradient_3 = Instance.new("UIGradient")
	local pageLayout = Instance.new("UIListLayout")

	introduction.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	background.Parent = introduction
	background.BackgroundTransparency = 1
	background.AnchorPoint = Vector2.new(0.5, 0.5)
	background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	background.ClipsDescendants = true
	background.Position = UDim2.new(0.511773348, 0, 0.5, 0)
	background.Size = UDim2.new(0, 300, 0, 308)

	--/ Style
	local IntroStroke = Instance.new("UIStroke", background)
	IntroStroke.Color = Color3.fromRGB(26, 26, 26)
	IntroStroke.Thickness = 2
	IntroStroke.Transparency = 1

	local backgroundGradient = Instance.new("UIGradient", background)
	backgroundGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(34, 34, 34)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(28, 28, 28))}
	backgroundGradient.Rotation = 90

	local backgroundCorner = Instance.new("UICorner", background)
	backgroundCorner.CornerRadius = UDim.new(0, 3)

	Logo.Parent = background
	Logo.AnchorPoint = Vector2.new(0.5, 0.5)
	Logo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Logo.BackgroundTransparency = 1.000
	Logo.TextTransparency = 1
	Logo.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Logo.BorderSizePixel = 0
	Logo.Position = UDim2.new(0.5, 0, 0.5, 0)
	Logo.Size = UDim2.new(0, 448, 0, 150)
	Logo.Font = Enum.Font.Unknown
	Logo.FontFace.Weight = Enum.FontWeight.Bold
	Logo.Font = Enum.Font.FredokaOne
	Logo.TextColor3 = library.acientColor
	Logo.TextSize = 100.000

	backgroundGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(171, 171, 171))}
	backgroundGradient_2.Rotation = 90
	backgroundGradient_2.Parent = Logo

	bar.Parent = background
	bar.BackgroundColor3 = library.acientColor
	bar.BackgroundTransparency = 1
	bar.Size = UDim2.new(1, 0, 0, 2)
	library:ApplyRainbow(bar, true)

	barCorner.CornerRadius = UDim.new(0, 2)
	barCorner.Parent = bar

	messages.Parent = background
	messages.AnchorPoint = Vector2.new(0.5, 0.5)
	messages.BackgroundColor3 = Color3.fromRGB(9, 9, 9)
	messages.BackgroundTransparency = 1
	messages.BorderColor3 = Color3.fromRGB(0, 0, 0)
	messages.BorderSizePixel = 1
	messages.Position = UDim2.new(0.5, 0, 0.5, 0)
	messages.Size = UDim2.new(1, -30, 1, -30)

	local messagesUIPadding = Instance.new("UIPadding", messages)
	messagesUIPadding.PaddingLeft = UDim.new(0, 6)
	messagesUIPadding.PaddingTop = UDim.new(0, 3)

	local messagesUIListLayout = Instance.new("UIListLayout", messages)
	messagesUIListLayout.Parent = messages
	messagesUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	messagesUIListLayout.FillDirection = Enum.FillDirection.Vertical
	messagesUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	messagesUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

	LogExample.Parent = messages
	LogExample.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	LogExample.BackgroundTransparency = 1.000
	LogExample.BorderColor3 = Color3.fromRGB(0, 0, 0)
	LogExample.BorderSizePixel = 0
	LogExample.Size = UDim2.new(1, 0, 0, 18)
	LogExample.Visible = false
	LogExample.Font = library.Font
	LogExample.TextColor3 = Color3.fromRGB(255, 255, 255)
	LogExample.TextSize = 18.000
	LogExample.TextTransparency = 1
	LogExample.TextWrapped = true
	LogExample.TextXAlignment = Enum.TextXAlignment.Left
	LogExample.TextYAlignment = Enum.TextYAlignment.Top

	backgroundGradient_3.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(171, 171, 171))}
	backgroundGradient_3.Rotation = 90
	backgroundGradient_3.Parent = LogExample

	pageLayout.Parent = introduction
	pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	TweenWrapper:CreateStyle("introduction",0.175)
	TweenWrapper:CreateStyle("introduction end",0.5)

	function library:BeginIntroduction()
		Logo.Text = library.company:sub(1, 1):upper()

		--TweenService:Create(edge, TweenWrapper.Styles["introduction"], {BackgroundTransparency = 0}):Play()
		TweenService:Create(background, TweenWrapper.Styles["introduction"], {BackgroundTransparency = 0}):Play()
		wait(.2)
		TweenService:Create(IntroStroke, TweenWrapper.Styles["introduction end"], {Transparency = 0.55}):Play()
		TweenService:Create(bar, TweenWrapper.Styles["introduction"], {BackgroundTransparency = 0.2}):Play()
		wait(.3)
		TweenService:Create(Logo, TweenWrapper.Styles["introduction"], {TextTransparency = 0}):Play()

		wait(2)

		local LogoTween = TweenService:Create(Logo, TweenWrapper.Styles["introduction"], {TextTransparency = 1})
		TweenService:Create(Logo, TweenInfo.new(1), {TextSize = 0}):Play()
		LogoTween:Play()
		LogoTween.Completed:Wait()
	end

	function library:AddIntroductionMessage(Message)
		if messages.BackgroundTransparency >= 1 then
			TweenService:Create(messages, TweenInfo.new(.2), {BackgroundTransparency = 0.55}):Play()
		end

		local Log = LogExample:Clone()
		local OrginalSize = Log.TextSize
		Log.Parent = messages
		Log.Text = Message
		Log.TextTransparency = 1
		Log.TextSize = OrginalSize*0.9
		Log.Visible = true
		TweenService:Create(Log, TweenInfo.new(1), {TextTransparency = 0}):Play()
		TweenService:Create(Log, TweenInfo.new(.7), {TextSize = OrginalSize}):Play()
		wait(.1)
		return Log
	end

	function library:EndIntroduction(Message)
		for _, Message in next, messages:GetChildren() do
			pcall(function()
				TweenService:Create(Message, TweenWrapper.Styles["introduction end"], {TextTransparency = 1}):Play()
			end)
		end
		wait(0.2)

		TweenService:Create(messages, TweenWrapper.Styles["introduction end"], {BackgroundTransparency = 1}):Play()
		--TweenService:Create(edge, TweenWrapper.Styles["introduction end"], {BackgroundTransparency = 1}):Play()
		TweenService:Create(background, TweenWrapper.Styles["introduction end"], {BackgroundTransparency = 1}):Play()
		TweenService:Create(bar, TweenWrapper.Styles["introduction end"], {BackgroundTransparency = 1}):Play()
		TweenService:Create(Logo, TweenWrapper.Styles["introduction end"], {TextTransparency = 1}):Play()
		TweenService:Create(IntroStroke, TweenWrapper.Styles["introduction end"], {Transparency = 1}):Play()
	end

	----/// UI INIT
	local screen = Instance.new("ScreenGui", hiddenUI())
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local background = Instance.new("Frame", screen)
	background.Visible = false
	background.BorderSizePixel = 0
	background.AnchorPoint = Vector2.new(0.5, 0.5)
	background.BackgroundTransparency = library.transparency
	background.BackgroundColor3 = library.backgroundColor
	background.Position = UDim2.new(0.5, 0, 0.5, 0)
	--background.Size = UDim2.fromScale(0.5, 0.5)
	background.Size = UDim2.fromOffset(594, 406)
	background.ClipsDescendants = true
	EnableDrag(background, 0.1)
	
	local SizeConstraint = Instance.new("UISizeConstraint")
	SizeConstraint.Parent = background
	SizeConstraint.MaxSize = Vector2.new(594, 406)
	SizeConstraint.MinSize = Vector2.new(450, 300)

	--/ Style
	local BGStroke = Instance.new("UIStroke", background)
	BGStroke.Color = Color3.fromRGB(26, 26, 26)
	BGStroke.Thickness = 2
	BGStroke.Transparency = 0.55

	local BGGradient = Instance.new("UIGradient", background)
	BGGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(230, 230, 230))}
	BGGradient.Rotation = 90

	--/ Tabs
	local tabButtons = Instance.new("Frame", background)
	tabButtons.BackgroundTransparency = 1
	tabButtons.ClipsDescendants = true
	tabButtons.Position = UDim2.new(0, 10, 0, 35)
	tabButtons.Size = UDim2.new(0, 152, 0, 330)

	local tabButtonLayout = Instance.new("UIListLayout", tabButtons)
	tabButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local tabButtonPadding = Instance.new("UIPadding", tabButtons)
	tabButtonPadding.PaddingBottom = UDim.new(0, 4)
	tabButtonPadding.PaddingLeft = UDim.new(0, 4)
	tabButtonPadding.PaddingRight = UDim.new(0, 4)
	tabButtonPadding.PaddingTop = UDim.new(0, 4)

	local tabButtonCorner_2 = Instance.new("UICorner", tabButtons)
	tabButtonCorner_2.CornerRadius = UDim.new(0, 2)

	--/ Header
	local container = Instance.new("Frame", background)
	container.AnchorPoint = Vector2.new(1, 0)
	container.BackgroundTransparency = 1
	container.Position = UDim2.new(1, -10, 0, 35)
	container.Size = UDim2.new(0, 414, 0, 360)

	local header = Instance.new("Frame", background)
	header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	header.BackgroundTransparency = 1.000
	header.BorderColor3 = Color3.fromRGB(0, 0, 0)
	header.BorderSizePixel = 0
	header.Size = UDim2.new(1, 0, 0, 32)

	local company = Instance.new("TextLabel", header)
	company.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	company.BackgroundTransparency = 1.000
	company.LayoutOrder = 1
	company.AutomaticSize = Enum.AutomaticSize.X
	company.Size = UDim2.new(0, 0, 1, 0)
	company.Font = library.Font
	company.TextColor3 = library.companyColor
	company.TextSize = 16.000
	company.TextTransparency = 0.300
 company.RichText = true
	company.TextXAlignment = Enum.TextXAlignment.Left

	function library:SetCompany(text)
		library.company = text
		company.Text = ("%s: "):format(text) or ""
		return self
	end
	library:SetCompany(library.company)

	local headerLabel = Instance.new("TextLabel", header)
	headerLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	headerLabel.BackgroundTransparency = 1.000
	headerLabel.LayoutOrder = 2
	headerLabel.Size = UDim2.new(1, 0, 1, 0)
	headerLabel.Font = library.Font
	headerLabel.Text = library.title
 headerLabel.RichText = true
	headerLabel.TextColor3 = Color3.fromRGB(198, 198, 198)
	headerLabel.TextSize = 16.000
	headerLabel.TextXAlignment = Enum.TextXAlignment.Left

	function library:SetTitle(text)
		headerLabel.Text = text or ""
		return self
	end

	local UIListLayout = Instance.new("UIListLayout", header)
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 5)

	local UIPadding = Instance.new("UIPadding", header)
	UIPadding.PaddingLeft = UDim.new(0, 10)

	--/ Bars
	local barFolder = Instance.new("Folder", background)

	local bar = Instance.new("Frame", barFolder)
	bar.BackgroundColor3 = library.acientColor
	bar.BackgroundTransparency = 0.200
	bar.Size = UDim2.new(1, 0, 0, 2)
	bar.BorderSizePixel = 0
	library:ApplyRainbow(bar, true)

	local barCorner = Instance.new("UICorner", bar)
	barCorner.CornerRadius = UDim.new(0, 2)

	local barLayout = Instance.new("UIListLayout", barFolder)
	barLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	barLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local tabButtonsOutline = Instance.new("UIStroke", tabButtons)
	tabButtonsOutline.Thickness = 1
	tabButtonsOutline.Color = library.lightGray

	local tabButtonsGradient = Instance.new("UIGradient", tabButtons)
	tabButtonsGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(34, 34, 34)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(28, 28, 28))}
	tabButtonsGradient.Rotation = 90

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 2)
	containerCorner.Parent = container

	local tabButtonsOutline = Instance.new("UIStroke", container)
	tabButtonsOutline.Thickness = 1
	tabButtonsOutline.Color = library.lightGray

	local panic = Instance.new("TextButton", background)
	panic.Text = "Panic"
	panic.AnchorPoint = Vector2.new(0, 1)
	panic.BackgroundTransparency = library.transparency
	panic.BackgroundColor3 = library.darkGray
	panic.Position = UDim2.new(0, 10, 1, -10)
	panic.Size = UDim2.new(0, 152, 0, 24)
	panic.Font = library.Font
	panic.TextColor3 = Color3.fromRGB(190, 190, 190)
	panic.TextSize = 14.000
	panic.Activated:Connect(function()
		library:Panic()
	end)

	local buttonCorner = Instance.new("UICorner", panic)
	buttonCorner.CornerRadius = UDim.new(0, 2)

	local panicOutline = Instance.new("UIStroke", panic)
	panicOutline.Thickness = 1
	panicOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	panicOutline.Color = library.lightGray

	--delay(1, function()
	--	library:Notify("Keybind set to ".. library.Key.Name, 20, "success")
	--end)

	UserInputService.InputBegan:Connect(function(input) -- Toggle UI
		if input.KeyCode ~= library.Key then return end

		local Visible = not background.Visible
		library:ShowUI(Visible)
	end)

	function library:ShowUI(Visible: boolean)
		local FieldOfView = library.FieldOfView
		local BlurSize = library.BlurSize
		local BlurEffect = library.BlurEffect

		local Tweeninfo = TweenInfo.new(Visible and 0.5 or 0.3)

		background.Visible = Visible
		
		if BlurEffect then
			TweenService:Create(Blur, Tweeninfo, {
				Size = Visible and BlurSize or 0
			}):Play()
			TweenService:Create(CurrentCam, Tweeninfo, {
				FieldOfView = Visible and FieldOfView-12 or FieldOfView
			}):Play()
		end

		return self
	end

	local TabLibrary = {
		IsFirst = true,
		CurrentTab = ""
	}
	TweenWrapper:CreateStyle("tab_text_colour", 0.16)
	function library:NewTab(title)
		title = title or "tab"

		local tabButton = Instance.new("TextButton")
		local page = Instance.new("ScrollingFrame")
		local pageLayout = Instance.new("UIListLayout")
		local pagePadding = Instance.new("UIPadding")

		tabButton.Parent = tabButtons
		tabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		tabButton.BackgroundTransparency = 1.000
		tabButton.ClipsDescendants = true
		tabButton.Position = UDim2.new(-0.0281690136, 0, 0, 0)
		tabButton.Size = UDim2.new(0, 150, 0, 22)
		tabButton.AutoButtonColor = false
		tabButton.Font = library.Font
		tabButton.Text = title
		tabButton.TextColor3 = Color3.fromRGB(170, 170, 170)
		tabButton.TextSize = 15.000
		tabButton.RichText = true

		page.Parent = container
		page.Active = true
		page.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		page.BackgroundTransparency = 1.000
		page.BorderSizePixel = 0
		page.Size = UDim2.new(0, 412, 0, 358)
		page.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
		page.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
		page.ScrollBarThickness = 1
		page.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
		page.ScrollBarImageColor3 = library.acientColor
		page.Visible = false
		page.CanvasSize = UDim2.new(0,0,0,0)
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y

		pageLayout.Parent = page
		pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		pageLayout.Padding = UDim.new(0, 4)

		pagePadding.Parent = page
		pagePadding.PaddingBottom = UDim.new(0, 6)
		pagePadding.PaddingLeft = UDim.new(0, 6)
		pagePadding.PaddingRight = UDim.new(0, 6)
		pagePadding.PaddingTop = UDim.new(0, 6)

		if self.IsFirst then
			page.Visible = true
			tabButton.TextColor3 = library.acientColor
			self.CurrentTab = title
		end

		tabButton.MouseButton1Click:Connect(function()
			self.CurrentTab = title
			for i,v in pairs(container:GetChildren()) do 
				if v:IsA("ScrollingFrame") then
					v.Visible = false
				end
			end
			page.Visible = true

			for i,v in pairs(tabButtons:GetChildren()) do
				if v:IsA("TextButton") then
					TweenService:Create(v, TweenWrapper.Styles["tab_text_colour"], {TextColor3 = Color3.fromRGB(170, 170, 170)}):Play()
				end
			end
			TweenService:Create(tabButton, TweenWrapper.Styles["tab_text_colour"], {TextColor3 = library.acientColor}):Play()
		end)

		self.IsFirst = false

		TweenWrapper:CreateStyle("hover", 0.16)
		local Components = {}
		function Components:NewLabel(text, alignment)
			text = text or "label"
			alignment = alignment or "left"

			local label = Instance.new("TextLabel")
			local labelPadding = Instance.new("UIPadding")

			label.Parent = page
			label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			label.BackgroundTransparency = 1.000
			label.Position = UDim2.new(0.00499999989, 0, 0, 0)
			label.Size = UDim2.new(0, 396, 0, 24)
			label.Font = library.Font
			label.Text = text
			label.TextColor3 = Color3.fromRGB(190, 190, 190)
			label.TextSize = 14.000
			label.TextWrapped = true
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.RichText = true

			labelPadding.Parent = page
			labelPadding.PaddingBottom = UDim.new(0, 6)
			labelPadding.PaddingLeft = UDim.new(0, 12)
			labelPadding.PaddingRight = UDim.new(0, 6)
			labelPadding.PaddingTop = UDim.new(0, 6)

			if alignment:lower():find("le") then
				label.TextXAlignment = Enum.TextXAlignment.Left
			elseif alignment:lower():find("cent") then
				label.TextXAlignment = Enum.TextXAlignment.Center
			elseif alignment:lower():find("ri") then
				label.TextXAlignment = Enum.TextXAlignment.Right
			end



			local LabelFunctions = {}
			function LabelFunctions:SetText(text)
				text = text or "new label text"
				label.Text = text
				return self
			end

			function LabelFunctions:Remove()
				label:Destroy()
				return self
			end

			function LabelFunctions:Hide()
				label.Visible = false

				return self
			end

			function LabelFunctions:Show()
				label.Visible = true

				return self
			end

			function LabelFunctions:Align(new)
				new = new or "le"
				if new:lower():find("le") then
					label.TextXAlignment = Enum.TextXAlignment.Left
				elseif new:lower():find("cent") then
					label.TextXAlignment = Enum.TextXAlignment.Center
				elseif new:lower():find("ri") then
					label.TextXAlignment = Enum.TextXAlignment.Right
				end
			end
			return LabelFunctions
		end

		function Components:NewButton(text, callback)
			text = text or "Button"
			callback = callback or function() end

			local ButtonFunctions = {}
			local button = Instance.new("TextButton")
			local buttonCorner = Instance.new("UICorner", button)
			local buttonStroke = Instance.new("UIStroke", button)

			local Color = library.darkGray
			local Hover = Color3.fromRGB(40, 40, 40)

			button.Text = text
			button.Parent = page
			button.BackgroundColor3 = Color
			button.BackgroundTransparency = library.transparency
			button.Size = UDim2.new(0, 396, 0, 24)
			button.AutoButtonColor = false
			button.Font = library.Font
			button.TextColor3 = Color3.fromRGB(190, 190, 190)
			button.TextSize = 14

			buttonStroke.Thickness = 1
			buttonStroke.Color = library.lightGray
			buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			buttonCorner.CornerRadius = UDim.new(0, 2)

			button.MouseEnter:Connect(function()
				TweenService:Create(button, TweenWrapper.Styles["hover"], {BackgroundColor3 = Hover}):Play()
			end)
			button.MouseLeave:Connect(function()
				TweenService:Create(button, TweenWrapper.Styles["hover"], {BackgroundColor3 = Color}):Play()
			end)

			button.MouseButton1Down:Connect(function()
				TweenService:Create(button, TweenWrapper.Styles["hover"], {TextColor3 = Color3.fromRGB(169, 107, 255)}):Play()
			end)
			button.MouseButton1Up:Connect(function()
				TweenService:Create(button, TweenWrapper.Styles["hover"], {TextColor3 = Color3.fromRGB(125, 125, 125)}):Play()
			end)

			button.MouseButton1Click:Connect(function()
				callback()
			end)

			function ButtonFunctions:Fire()
				callback()
			end

			function ButtonFunctions:Hide()
				button.Visible = false
				return self
			end

			function ButtonFunctions:Show()
				button.Visible = true
				return self
			end

			function ButtonFunctions:SetText(text)
				text = text or ""
				button.Text = text

				return self
			end

			function ButtonFunctions:Remove()
				button:Destroy()
				return self
			end

			function ButtonFunctions:SetFunction(new)
				new = new or function() end
				callback = new
				return self
			end
			return ButtonFunctions
		end

		function Components:NewSection(text)
			text = text or "section"

			local sectionFrame = Instance.new("Frame", page)
			local sectionLayout = Instance.new("UIListLayout")
			local sectionLabel = Instance.new("TextLabel")
			local sectionPadding = Instance.new("UIPadding", sectionFrame)

			local UICorner = Instance.new("UICorner", sectionFrame)
			UICorner.CornerRadius = UDim.new(0, 3)

			sectionFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
			sectionFrame.BackgroundTransparency = 0.500
			sectionFrame.BorderSizePixel = 0
			sectionFrame.ClipsDescendants = true
			sectionFrame.Size = UDim2.new(0, 396, 0, 19)

			sectionPadding.PaddingBottom = UDim.new(0, 6)
			sectionPadding.PaddingLeft = UDim.new(0, 3)
			sectionPadding.PaddingRight = UDim.new(0, 3)
			sectionPadding.PaddingTop = UDim.new(0, 6)

			sectionLayout.Parent = sectionFrame
			sectionLayout.FillDirection = Enum.FillDirection.Horizontal
			sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
			sectionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			sectionLayout.Padding = UDim.new(0, 4)

			sectionLabel.Parent = sectionFrame
			sectionLabel.BackgroundColor3 = library.headerColor 
			sectionLabel.BackgroundTransparency = 1.000
			sectionLabel.ClipsDescendants = true
			sectionLabel.Position = UDim2.new(0.0252525248, 0, 0.020833334, 0)
			sectionLabel.Size = UDim2.new(1, 0, 1, 0)
			sectionLabel.Font = library.Font
			sectionLabel.LineHeight = 1
			sectionLabel.Text = text
			sectionLabel.TextColor3 = Color3.fromRGB(190, 190, 190)
			sectionLabel.TextSize = 14.000
			sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
			sectionLabel.RichText = true


			local NewSectionSize = TextService:GetTextSize(sectionLabel.Text, sectionLabel.TextSize, sectionLabel.Font, Vector2.new(math.huge,math.huge))
			sectionLabel.Size = UDim2.new(0, NewSectionSize.X, 0, 18)

			local SectionFunctions = {}
			function SectionFunctions:SetText(new)
				new = new or text
				sectionLabel.Text = new

				local NewSectionSize = TextService:GetTextSize(sectionLabel.Text, sectionLabel.TextSize, sectionLabel.Font, Vector2.new(math.huge,math.huge))
				sectionLabel.Size = UDim2.new(0, NewSectionSize.X, 0, 18)

				return self
			end
			function SectionFunctions:Hide()
				sectionFrame.Visible = false
				return self
			end
			function SectionFunctions:Show()
				sectionFrame.Visible = true
				return self
			end
			function SectionFunctions:Remove()
				sectionFrame:Destroy()
				return self
			end
			--
			return SectionFunctions
		end

		function Components:NewToggle(text, default, callback, loop, ignorepanic)
			text = text or "toggle"
			default = default or false
			callback = callback or function() end

			local toggleButton = Instance.new("TextButton", page)
			local toggleLayout = Instance.new("UIListLayout")

			local toggle = Instance.new("Frame")
			local toggleCorner = Instance.new("UICorner")
			local toggleDesign = Instance.new("Frame")
			local toggleDesignCorner = Instance.new("UICorner")
			local toggleStroke = Instance.new("UIStroke", toggle)
			local toggleLabel = Instance.new("TextLabel")
			local toggleLabelPadding = Instance.new("UIPadding")
			local Extras = Instance.new("Folder")
			local ExtrasLayout = Instance.new("UIListLayout")

			toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			toggleButton.BackgroundTransparency = 1.000
			toggleButton.ClipsDescendants = false
			toggleButton.Size = UDim2.new(0, 396, 0, 22)
			toggleButton.Font = library.Font
			toggleButton.Text = ""
			toggleButton.TextColor3 = Color3.fromRGB(190, 190, 190)
			toggleButton.TextSize = 14.000
			toggleButton.TextXAlignment = Enum.TextXAlignment.Left

			toggleLayout.Parent = toggleButton
			toggleLayout.FillDirection = Enum.FillDirection.Horizontal
			toggleLayout.SortOrder = Enum.SortOrder.LayoutOrder
			toggleLayout.VerticalAlignment = Enum.VerticalAlignment.Center

			toggle.Parent = toggleButton
			toggle.BackgroundColor3 = library.darkGray
			toggle.BackgroundTransparency = library.transparency
			toggle.Size = UDim2.new(0, 18, 0, 18)

			toggleStroke.Thickness = 1
			toggleStroke.Color = library.lightGray

			toggleCorner.CornerRadius = UDim.new(0, 2)
			toggleCorner.Parent = toggle

			toggleDesign.Parent = toggle
			toggleDesign.AnchorPoint = Vector2.new(0.5, 0.5)
			toggleDesign.BackgroundColor3 = library.acientColor
			toggleDesign.BackgroundTransparency = 1.000
			toggleDesign.Position = UDim2.new(0.5, 0, 0.5, 0)

			toggleDesignCorner.CornerRadius = UDim.new(0, 2)
			toggleDesignCorner.Parent = toggleDesign

			toggleLabel.Parent = toggleButton
			toggleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			toggleLabel.BackgroundTransparency = 1.000
			toggleLabel.Position = UDim2.new(0.0454545468, 0, 0, 0)
			toggleLabel.Size = UDim2.new(0, 377, 0, 22)
			toggleLabel.Font = library.Font
			toggleLabel.LineHeight = 1.150
			toggleLabel.Text = text
			toggleLabel.TextColor3 = Color3.fromRGB(190, 190, 190)
			toggleLabel.TextSize = 14.000
			toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
			toggleLabel.RichText = true

			toggleLabelPadding.Parent = toggleLabel
			toggleLabelPadding.PaddingLeft = UDim.new(0, 6)

			Extras.Parent = toggleButton

			ExtrasLayout.Parent = Extras
			ExtrasLayout.FillDirection = Enum.FillDirection.Horizontal
			ExtrasLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
			ExtrasLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ExtrasLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			ExtrasLayout.Padding = UDim.new(0, 2)

			local NewToggleLabelSize = TextService:GetTextSize(toggleLabel.Text, toggleLabel.TextSize, toggleLabel.Font, Vector2.new(math.huge,math.huge))
			toggleLabel.Size = UDim2.new(0, NewToggleLabelSize.X + 6, 0, 22)

			toggleButton.MouseEnter:Connect(function()
				TweenService:Create(toggleLabel, TweenWrapper.Styles["hover"], {TextColor3 = Color3.fromRGB(210, 210, 210)}):Play()
			end)
			toggleButton.MouseLeave:Connect(function()
				TweenService:Create(toggleLabel, TweenWrapper.Styles["hover"], {TextColor3 = Color3.fromRGB(190, 190, 190)}):Play()
			end)

			TweenWrapper:CreateStyle("toggle_form", 0.13)
			local On = default
			if default then
				On = true
			else
				On = false
			end

			if loop ~= nil then
				RunService.RenderStepped:Connect(function()
					if On == true then
						callback(On)
					end
				end)
			end

			toggleButton.MouseButton1Click:Connect(function()
				On = not On
				local SizeOn = On and UDim2.new(0, 12, 0, 12) or UDim2.new(0, 0, 0, 0)
				local Transparency = On and 0 or 1
				TweenService:Create(toggleDesign, TweenWrapper.Styles["toggle_form"], {Size = SizeOn}):Play()
				TweenService:Create(toggleDesign, TweenWrapper.Styles["toggle_form"], {BackgroundTransparency = Transparency}):Play()
				callback(On)
			end)

			local ToggleFunctions = {}

			if not ignorepanic then
				OptionStates[toggleButton] = {false, ToggleFunctions}
			end

			function ToggleFunctions:SetText(new)
				new = new or text
				toggleLabel.Text = new
				return self
			end

			function ToggleFunctions:Hide()
				toggleButton.Visible = false
				return self
			end

			function ToggleFunctions:Show()
				toggleButton.Visible = true
				return self
			end   

			function ToggleFunctions:Change()
				On = not On
				local SizeOn = On and UDim2.new(0, 12, 0, 12) or UDim2.new(0, 0, 0, 0)
				local Transparency = On and 0 or 1
				TweenService:Create(toggleDesign, TweenWrapper.Styles["toggle_form"], {Size = SizeOn}):Play()
				TweenService:Create(toggleDesign, TweenWrapper.Styles["toggle_form"], {BackgroundTransparency = Transparency}):Play()
				callback(On)
				return self
			end

			function ToggleFunctions:Remove()
				toggleButton:Destroy()
				return self
			end

			function ToggleFunctions:Set(state)
				On = state
				local SizeOn = On and UDim2.new(0, 12, 0, 12) or UDim2.new(0, 0, 0, 0)
				local Transparency = On and 0 or 1
				TweenService:Create(toggleDesign, TweenWrapper.Styles["toggle_form"], {Size = SizeOn}):Play()
				TweenService:Create(toggleDesign, TweenWrapper.Styles["toggle_form"], {BackgroundTransparency = Transparency}):Play()
				callback(On)
				return ToggleFunctions
			end

			function ToggleFunctions:GetValue()
				return On
			end

			local callback_t
			function ToggleFunctions:SetFunction(new)
				new = new or function() end
				callback = new
				callback_t = new
				return ToggleFunctions
			end


			function ToggleFunctions:AddKeybind(default_t)
				callback_t = callback
				if default_t == Enum.KeyCode.Backspace then
					default_t = nil
				end

				local keybind = Instance.new("TextButton")
				local keybindOutline = Instance.new("UIStroke")
				local keybindCorner = Instance.new("UICorner")
				local keybindBackground = Instance.new("Frame")
				local keybindBackCorner = Instance.new("UICorner")
				local keybindButtonLabel = Instance.new("TextLabel")
				local keybindLabelStraint = Instance.new("UISizeConstraint")
				local keybindBackgroundStraint = Instance.new("UISizeConstraint")
				local keybindStraint = Instance.new("UISizeConstraint")
				
				keybindOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				keybindOutline.Thickness = 1
				keybindOutline.Parent = keybind
				keybindOutline.Color = library.lightGray
				
				keybindCorner.CornerRadius = UDim.new(0, 2)
				keybindCorner.Parent = keybind

				keybind.Parent = Extras
				keybind.BackgroundTransparency = library.transparency
				keybind.BackgroundColor3 = library.darkGray
				keybind.Position = UDim2.new(0.780303001, 0, 0, 0)
				keybind.Size = UDim2.new(0, 87, 0, 22)
				keybind.AutoButtonColor = false
				keybind.Font = library.Font
				keybind.Text = ""
				keybind.TextColor3 = Color3.fromRGB(0, 0, 0)
				keybind.TextSize = 14.000
				keybind.Active = false

				keybindBackground.Parent = keybind
				keybindBackground.AnchorPoint = Vector2.new(0.5, 0.5)
				keybindBackground.BackgroundTransparency = 1 --library.transparency
				keybindBackground.BackgroundColor3 = library.darkGray
				keybindBackground.Position = UDim2.new(0.5, 0, 0.5, 0)
				keybindBackground.Size = UDim2.new(0, 85, 0, 20)

				keybindBackCorner.CornerRadius = UDim.new(0, 2)
				keybindBackCorner.Parent = keybindBackground

				keybindButtonLabel.Parent = keybindBackground
				keybindButtonLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				keybindButtonLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				keybindButtonLabel.BackgroundTransparency = 1.000
				keybindButtonLabel.ClipsDescendants = true
				keybindButtonLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
				keybindButtonLabel.Size = UDim2.new(0, 85, 0, 20)
				keybindButtonLabel.Font = library.Font
				keybindButtonLabel.Text = ". . ."
				keybindButtonLabel.TextColor3 = Color3.fromRGB(190, 190, 190)
				keybindButtonLabel.TextSize = 14.000
				keybindButtonLabel.RichText = true

				keybindLabelStraint.Parent = keybindButtonLabel
				keybindLabelStraint.MinSize = Vector2.new(28, 20)

				keybindBackgroundStraint.Parent = keybindBackground
				keybindBackgroundStraint.MinSize = Vector2.new(28, 20)

				keybindStraint.Parent = keybind
				keybindStraint.MinSize = Vector2.new(30, 22)

				local Shortcuts = {
					Return = "enter"
				}

				keybindButtonLabel.Text = default_t and (Shortcuts[default_t.Name] or default_t.Name) or "None"
				TweenWrapper:CreateStyle("keybind", 0.08)

				local NewKeybindSize = TextService:GetTextSize(keybindButtonLabel.Text, keybindButtonLabel.TextSize, keybindButtonLabel.Font, Vector2.new(math.huge,math.huge))
				keybindButtonLabel.Size = UDim2.new(0, NewKeybindSize.X + 6, 0, 20)
				keybindBackground.Size = UDim2.new(0, NewKeybindSize.X + 6, 0, 20)
				keybind.Size = UDim2.new(0, NewKeybindSize.X + 8, 0, 22)

				local function ResizeKeybind()
					NewKeybindSize = TextService:GetTextSize(keybindButtonLabel.Text, keybindButtonLabel.TextSize, keybindButtonLabel.Font, Vector2.new(math.huge,math.huge))
					TweenService:Create(keybindButtonLabel, TweenWrapper.Styles["keybind"], {Size = UDim2.new(0, NewKeybindSize.X + 6, 0, 20)}):Play()
					TweenService:Create(keybindBackground, TweenWrapper.Styles["keybind"], {Size = UDim2.new(0, NewKeybindSize.X + 6, 0, 20)}):Play()
					TweenService:Create(keybind, TweenWrapper.Styles["keybind"], {Size = UDim2.new(0, NewKeybindSize.X + 8, 0, 22)}):Play()
				end
				keybindButtonLabel:GetPropertyChangedSignal("Text"):Connect(ResizeKeybind)
				ResizeKeybind()


				local ChosenKey = default_t and default_t.Name

				keybind.MouseButton1Click:Connect(function()
					keybindButtonLabel.Text = ". . ."
					local InputWait = UserInputService.InputBegan:wait()
					if not UserInputService.WindowFocused then return end 

					if InputWait == Enum.KeyCode.Backspace then
						default_t = nil
						ChosenKey = nil
						keybindButtonLabel.Text = "None"
						return
					end

					if InputWait.KeyCode.Name ~= "Unknown" then
						local Result = Shortcuts[InputWait.KeyCode.Name] or InputWait.KeyCode.Name
						keybindButtonLabel.Text = Result
						ChosenKey = InputWait.KeyCode.Name
					end
				end)

				--local ChatTextBox = Player.PlayerGui.Chat.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar
				if UserInputService.WindowFocused then
					UserInputService.InputBegan:Connect(function(c, p)
						if not p and default_t and ChosenKey then
							if c.KeyCode.Name == ChosenKey then --  and not ChatTextBox:IsFocused()
								On = not On
								local SizeOn = On and UDim2.new(0, 12, 0, 12) or UDim2.new(0, 0, 0, 0)
								local Transparency = On and 0 or 1
								TweenService:Create(toggleDesign, TweenWrapper.Styles["toggle_form"], {Size = SizeOn}):Play()
								TweenService:Create(toggleDesign, TweenWrapper.Styles["toggle_form"], {BackgroundTransparency = Transparency}):Play()
								callback_t(On)
								return
							end
						end
					end)
				end

				local ExtraKeybindFunctions = {}
				function ExtraKeybindFunctions:SetKey(new)
					new = new or ChosenKey.Name
					ChosenKey = new.Name
					keybindButtonLabel.Text = new.Name
					return self
				end

				function ExtraKeybindFunctions:Fire()
					callback_t(ChosenKey)
					return self
				end

				function ExtraKeybindFunctions:SetFunction(new)
					new = new or function() end
					callback_t = new
					return self 
				end

				function ExtraKeybindFunctions:Hide()
					keybind.Visible = false
					return self
				end

				function ExtraKeybindFunctions:Show()
					keybind.Visible = true
					return self
				end
				return ExtraKeybindFunctions and ToggleFunctions
			end

			if default then
				toggleDesign.Size = UDim2.new(0, 12, 0, 12)
				toggleDesign.BackgroundTransparency = 0
				callback(true)
			end
			return ToggleFunctions
		end

		function Components:NewKeybind(text, default, callback)
			text = text or "keybind"
			default = default or Enum.KeyCode.P
			callback = callback or function() end

			local keybindFrame = Instance.new("Frame")
			local keybindButton = Instance.new("TextButton")
			local keybindLayout = Instance.new("UIListLayout")
			local keybindLabel = Instance.new("TextLabel")
			local keybindPadding = Instance.new("UIPadding")
			local keybindFolder = Instance.new("Folder")
			local keybindFolderLayout = Instance.new("UIListLayout")
			local keybind = Instance.new("TextButton")
			local keybindCorner = Instance.new("UICorner")
			local keybindBackground = Instance.new("Frame")
			local keybindGradient = Instance.new("UIGradient")
			local keybindBackCorner = Instance.new("UICorner")
			local keybindButtonLabel = Instance.new("TextLabel")
			local keybindLabelStraint = Instance.new("UISizeConstraint")
			local keybindBackgroundStraint = Instance.new("UISizeConstraint")
			local keybindStraint = Instance.new("UISizeConstraint")

			keybindFrame.Parent = page
			keybindFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			keybindFrame.BackgroundTransparency = 1.000
			keybindFrame.ClipsDescendants = true
			keybindFrame.Size = UDim2.new(0, 396, 0, 24)

			keybindButton.Parent = keybindFrame
			keybindButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			keybindButton.BackgroundTransparency = 1.000
			keybindButton.Size = UDim2.new(0, 396, 0, 24)
			keybindButton.AutoButtonColor = false
			keybindButton.Font = library.Font
			keybindButton.Text = ""
			keybindButton.TextColor3 = Color3.fromRGB(0, 0, 0)
			keybindButton.TextSize = 14.000

			keybindLayout.Parent = keybindButton
			keybindLayout.FillDirection = Enum.FillDirection.Horizontal
			keybindLayout.SortOrder = Enum.SortOrder.LayoutOrder
			keybindLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			keybindLayout.Padding = UDim.new(0, 4)

			keybindLabel.Parent = keybindButton
			keybindLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			keybindLabel.BackgroundTransparency = 1.000
			keybindLabel.Size = UDim2.new(0, 396, 0, 24)
			keybindLabel.Font = library.Font
			keybindLabel.Text = text
			keybindLabel.TextColor3 = Color3.fromRGB(190, 190, 190)
			keybindLabel.TextSize = 14.000
			keybindLabel.TextWrapped = true
			keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
			keybindLabel.RichText = true

			keybindPadding.Parent = keybindLabel
			keybindPadding.PaddingBottom = UDim.new(0, 6)
			keybindPadding.PaddingLeft = UDim.new(0, 2)
			keybindPadding.PaddingRight = UDim.new(0, 6)
			keybindPadding.PaddingTop = UDim.new(0, 6)

			keybindFolder.Parent = keybindFrame

			keybindFolderLayout.Parent = keybindFolder
			keybindFolderLayout.FillDirection = Enum.FillDirection.Horizontal
			keybindFolderLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
			keybindFolderLayout.SortOrder = Enum.SortOrder.LayoutOrder
			keybindFolderLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			keybindFolderLayout.Padding = UDim.new(0, 4)

			keybind.Parent = keybindFolder
			keybind.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			keybind.Position = UDim2.new(0.780303001, 0, 0, 0)
			keybind.Size = UDim2.new(0, 87, 0, 22)
			keybind.AutoButtonColor = false
			keybind.Font = library.Font
			keybind.Text = ""
			keybind.TextColor3 = Color3.fromRGB(0, 0, 0)
			keybind.TextSize = 14.000
			keybind.Active = false

			keybindCorner.CornerRadius = UDim.new(0, 2)
			keybindCorner.Parent = keybind

			keybindBackground.Parent = keybind
			keybindBackground.AnchorPoint = Vector2.new(0.5, 0.5)
			keybindBackground.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			keybindBackground.Position = UDim2.new(0.5, 0, 0.5, 0)
			keybindBackground.Size = UDim2.new(0, 85, 0, 20)

			keybindGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(34, 34, 34)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(28, 28, 28))}
			keybindGradient.Rotation = 90
			keybindGradient.Parent = keybindBackground

			keybindBackCorner.CornerRadius = UDim.new(0, 2)
			keybindBackCorner.Parent = keybindBackground

			keybindButtonLabel.Parent = keybindBackground
			keybindButtonLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			keybindButtonLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			keybindButtonLabel.BackgroundTransparency = 1.000
			keybindButtonLabel.ClipsDescendants = true
			keybindButtonLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
			keybindButtonLabel.Size = UDim2.new(0, 85, 0, 20)
			keybindButtonLabel.Font = library.Font
			keybindButtonLabel.Text = ". . ."
			keybindButtonLabel.TextColor3 = Color3.fromRGB(190, 190, 190)
			keybindButtonLabel.TextSize = 14.000
			keybindButtonLabel.RichText = true

			keybindLabelStraint.Parent = keybindButtonLabel
			keybindLabelStraint.MinSize = Vector2.new(28, 20)

			keybindBackgroundStraint.Parent = keybindBackground
			keybindBackgroundStraint.MinSize = Vector2.new(28, 20)

			keybindStraint.Parent = keybind
			keybindStraint.MinSize = Vector2.new(30, 22)

			local Shortcuts = {
				Return = "enter"
			}

			keybindButtonLabel.Text = Shortcuts[default.Name] or default.Name
			TweenWrapper:CreateStyle("keybind", 0.08)

			local NewKeybindSize = TextService:GetTextSize(keybindButtonLabel.Text, keybindButtonLabel.TextSize, keybindButtonLabel.Font, Vector2.new(math.huge,math.huge))
			keybindButtonLabel.Size = UDim2.new(0, NewKeybindSize.X + 6, 0, 20)
			keybindBackground.Size = UDim2.new(0, NewKeybindSize.X + 6, 0, 20)
			keybind.Size = UDim2.new(0, NewKeybindSize.X + 8, 0, 22)

			local function ResizeKeybind()
				NewKeybindSize = TextService:GetTextSize(keybindButtonLabel.Text, keybindButtonLabel.TextSize, keybindButtonLabel.Font, Vector2.new(math.huge,math.huge))
				TweenService:Create(keybindButtonLabel, TweenWrapper.Styles["keybind"], {Size = UDim2.new(0, NewKeybindSize.X + 6, 0, 20)}):Play()
				TweenService:Create(keybindBackground, TweenWrapper.Styles["keybind"], {Size = UDim2.new(0, NewKeybindSize.X + 6, 0, 20)}):Play()
				TweenService:Create(keybind, TweenWrapper.Styles["keybind"], {Size = UDim2.new(0, NewKeybindSize.X + 8, 0, 22)}):Play()
			end
			keybindButtonLabel:GetPropertyChangedSignal("Text"):Connect(ResizeKeybind)
			ResizeKeybind()

			local ChosenKey = default
			keybindButton.MouseButton1Click:Connect(function()
				keybindButtonLabel.Text = "..."
				local InputWait = UserInputService.InputBegan:wait()
				if UserInputService.WindowFocused and InputWait.KeyCode.Name ~= "Unknown" then
					local Result = Shortcuts[InputWait.KeyCode.Name] or InputWait.KeyCode.Name
					keybindButtonLabel.Text = Result
					ChosenKey = InputWait.KeyCode.Name
				end
			end)

			keybind.MouseButton1Click:Connect(function()
				keybindButtonLabel.Text = ". . ."
				local InputWait = UserInputService.InputBegan:wait()
				if UserInputService.WindowFocused and InputWait.KeyCode.Name ~= "Unknown" then
					local Result = Shortcuts[InputWait.KeyCode.Name] or InputWait.KeyCode.Name
					keybindButtonLabel.Text = Result
					ChosenKey = InputWait.KeyCode.Name
				end
			end)

			--local ChatTextBox = Player.PlayerGui.Chat.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar
			if UserInputService.WindowFocused then
				UserInputService.InputBegan:Connect(function(c, GameProcessed)
					if GameProcessed then
						return
					end
					if c.KeyCode.Name == ChosenKey then -- and not ChatTextBox:IsFocused()
						callback(ChosenKey)
						return
					end
				end)
			end



			local KeybindFunctions = {}
			function KeybindFunctions:Fire()
				callback(ChosenKey)
				return KeybindFunctions
			end

			function KeybindFunctions:SetFunction(new)
				new = new or function() end
				callback = new
				return self 
			end

			function KeybindFunctions:SetKey(new)
				new = new or ChosenKey.Name
				ChosenKey = new.Name
				keybindButtonLabel.Text = new.Name
				return self
			end

			function KeybindFunctions:SetText(new)
				new = new or keybindLabel.Text
				keybindLabel.Text = new
				return self
			end

			function KeybindFunctions:Hide()
				keybindFrame.Visible = false
				return self
			end

			function KeybindFunctions:Show()
				keybindFrame.Visible = true
				return self
			end
			return KeybindFunctions
		end

		function Components:NewTextbox(text, default, placeHolder, type, autoexec, autoclear, callback)
			text = text or "text box"
			default = default or ""
			placeHolder = placeHolder or ""
			type = type or "small" -- small, medium, large
			autoexec = autoexec or true
			autoclear = autoclear or false
			callback = callback or function() end

			local textboxFrame = Instance.new("Frame")
			local textboxLabel = Instance.new("TextLabel")
			local textboxPadding = Instance.new("UIPadding")
			local textbox = Instance.new("Frame")
			local textBoxValues = Instance.new("TextBox")
			local textBoxValuesPadding = Instance.new("UIPadding")

			textboxFrame.Parent = page
			textboxFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			textboxFrame.BackgroundTransparency = 1.000
			textboxFrame.BorderSizePixel = 0
			textboxFrame.Position = UDim2.new(0.00499999989, 0, 0.268786132, 0)

			textBoxValues.MultiLine = true
			if type == "small" then
				textBoxValues.MultiLine = false
				textboxFrame.Size = UDim2.new(0, 393, 0, 46)
			elseif type == "medium" then
				textboxFrame.Size = UDim2.new(0, 393, 0, 60)
			elseif type == "large" then
				textboxFrame.Size = UDim2.new(0, 393, 0, 118)
			end

			textboxLabel.Parent = textboxFrame
			textboxLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			textboxLabel.BackgroundTransparency = 1.000
			textboxLabel.Size = UDim2.new(1, 0, 0, 24)
			textboxLabel.Font = library.Font
			textboxLabel.Text = text
			textboxLabel.TextColor3 = Color3.fromRGB(190, 190, 190)
			textboxLabel.TextSize = 14.000
			textboxLabel.TextWrapped = true
			textboxLabel.TextXAlignment = Enum.TextXAlignment.Left

			textboxPadding.Parent = textboxLabel
			textboxPadding.PaddingBottom = UDim.new(0, 6)
			textboxPadding.PaddingRight = UDim.new(0, 6)
			textboxPadding.PaddingTop = UDim.new(0, 6)

			textbox.Parent = textboxFrame
			textbox.BackgroundColor3 = library.darkGray
			textbox.BackgroundTransparency = library.transparency
			textbox.BorderSizePixel = 0
			textbox.Position = UDim2.new(0, 0, 0, 24)
			textbox.Size = UDim2.new(1, 0, 1, -24)

			local textboxOutline = Instance.new("UIStroke", textbox)
			textboxOutline.Thickness = 1
			textboxOutline.Color = library.lightGray

			local UICorner = Instance.new("UICorner", textbox)
			UICorner.CornerRadius = UDim.new(0, 2)

			textBoxValues.Parent = textbox
			textBoxValues.BackgroundTransparency = 1
			textBoxValues.BorderSizePixel = 0
			textBoxValues.ClipsDescendants = true
			textBoxValues.Size = UDim2.new(1, 0, 1, 0)
			textBoxValues.Font = library.Font
			textBoxValues.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
			textBoxValues.PlaceholderText = placeHolder
			textBoxValues.Text = default
			textBoxValues.TextColor3 = Color3.fromRGB(190, 190, 190)
			textBoxValues.TextSize = 14.000
			textBoxValues.TextWrapped = true
			textBoxValues.TextXAlignment = Enum.TextXAlignment.Left
			textBoxValues.TextYAlignment = Enum.TextYAlignment.Top

			textBoxValuesPadding.Parent = textBoxValues
			textBoxValuesPadding.PaddingBottom = UDim.new(0, 4)
			textBoxValuesPadding.PaddingLeft = UDim.new(0, 4)
			textBoxValuesPadding.PaddingRight = UDim.new(0, 4)
			textBoxValuesPadding.PaddingTop = UDim.new(0, 4)

			TweenWrapper:CreateStyle("TextBox", 0.07)


			textBoxValues.FocusLost:Connect(function(enterPressed)
				if autoexec or enterPressed then
					callback(textBoxValues.Text)
				end
			end)

			local TextboxFunctions = {}
			function TextboxFunctions:Input(new)
				new = new or textBoxValues.Text
				textBoxValues = new
				return self
			end

			function TextboxFunctions:Fire()
				callback(textBoxValues.Text)
				return self
			end

			function TextboxFunctions:SetFunction(new)
				new = new or callback
				callback = new
				return self
			end

			function TextboxFunctions:SetText(new)
				new = new or textboxLabel.Text
				textboxLabel.Text = new
				return self
			end

			function TextboxFunctions:Hide()
				textboxFrame.Visible = false
				return self
			end

			function TextboxFunctions:Show()
				textboxFrame.Visible = true
				return self
			end

			function TextboxFunctions:Remove()
				textboxFrame:Destroy()
				return self
			end

			function TextboxFunctions:SetPlaceHolder(new)
				new = new or textBoxValues.PlaceholderText
				textBoxValues.PlaceholderText = new
				return self
			end
			return TextboxFunctions
		end
		--
		function Components:NewSelector(text, default, list, callback)
			text = text or "selector"
			default = default or ". . ."
			list = list or {}
			callback = callback or function() end

			local selectorFrame = Instance.new("Frame")
			local selectorLabel = Instance.new("TextLabel")
			local selectorLabelPadding = Instance.new("UIPadding")
			local selectorFrameLayout = Instance.new("UIListLayout")
			local selector = Instance.new("TextButton")
			local selectorCorner = Instance.new("UICorner")
			local selectorLayout = Instance.new("UIListLayout")
			local selectorPadding = Instance.new("UIPadding")
			local selectorTwo = Instance.new("Frame")
			local selectorText = Instance.new("TextLabel")
			local textBoxValuesPadding = Instance.new("UIPadding")
			local Frame = Instance.new("Frame")
			local selectorTwoLayout = Instance.new("UIListLayout")
			local selectorTwoCorner = Instance.new("UICorner")
			local selectorPadding_2 = Instance.new("UIPadding")
			local selectorContainer = Instance.new("Frame")
			local selectorTwoLayout_2 = Instance.new("UIListLayout")

			selectorFrame.Parent = page
			selectorFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			selectorFrame.BackgroundTransparency = 1.000
			selectorFrame.ClipsDescendants = true
			selectorFrame.Position = UDim2.new(0.00499999989, 0, 0.0895953774, 0)
			selectorFrame.Size = UDim2.new(0, 394, 0, 48)

			selectorLabel.Parent = selectorFrame
			selectorLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			selectorLabel.BackgroundTransparency = 1.000
			selectorLabel.Size = UDim2.new(0, 396, 0, 24)
			selectorLabel.Font = library.Font
			selectorLabel.Text = text
			selectorLabel.TextColor3 = Color3.fromRGB(190, 190, 190)
			selectorLabel.TextSize = 14.000
			selectorLabel.TextWrapped = true
			selectorLabel.TextXAlignment = Enum.TextXAlignment.Left
			selectorLabel.RichText = true

			selectorLabelPadding.Parent = selectorLabel
			selectorLabelPadding.PaddingBottom = UDim.new(0, 6)
			selectorLabelPadding.PaddingLeft = UDim.new(0, 2)
			selectorLabelPadding.PaddingRight = UDim.new(0, 6)
			selectorLabelPadding.PaddingTop = UDim.new(0, 6)

			selectorFrameLayout.Parent = selectorFrame
			selectorFrameLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			selectorFrameLayout.SortOrder = Enum.SortOrder.LayoutOrder

			selector.Parent = selectorFrame
			selector.BackgroundColor3 = library.darkGray
			selector.BackgroundTransparency = library.transparency
			selector.ClipsDescendants = true
			selector.Position = UDim2.new(0, 0, 0.0926640928, 0)
			selector.Size = UDim2.new(1, 0, 0, 23)
			selector.AutoButtonColor = false
			selector.Font = library.Font
			selector.Text = ""
			selector.TextColor3 = Color3.fromRGB(0, 0, 0)
			selector.TextSize = 14.000

			selectorCorner.CornerRadius = UDim.new(0, 2)
			selectorCorner.Parent = selector

			selectorLayout.Parent = selector
			selectorLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			selectorLayout.SortOrder = Enum.SortOrder.LayoutOrder

			selectorPadding.Parent = selector
			selectorPadding.PaddingTop = UDim.new(0, 1)

			selectorTwo.Parent = selector
			selectorTwo.BackgroundColor3 = library.darkGray
			selectorTwo.BackgroundTransparency = library.transparency
			selectorTwo.ClipsDescendants = true
			selectorTwo.Position = UDim2.new(0.00252525252, 0, 0, 0)
			selectorTwo.Size = UDim2.new(1, -2, 1, -1)

			selectorText.Parent = selectorTwo
			selectorText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			selectorText.BackgroundTransparency = 1.000
			selectorText.Size = UDim2.new(0, 394, 0, 20)
			selectorText.Font = library.Font
			selectorText.LineHeight = 1.150
			selectorText.TextColor3 = Color3.fromRGB(160, 160, 160)
			selectorText.TextSize = 14.000
			selectorText.TextXAlignment = Enum.TextXAlignment.Left
			selectorText.Text = default

			local Toggle = Instance.new("TextButton", selectorText)
			Toggle.AnchorPoint = Vector2.new(1, 0.5)
			Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Toggle.BackgroundTransparency = 1.000
			Toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Toggle.BorderSizePixel = 0
			Toggle.Position = UDim2.new(1, 0, 0.5, 0)
			Toggle.Rotation = 90
			Toggle.Size = UDim2.new(0, 20, 1, 5)
			Toggle.Font = library.Font
			Toggle.Text = ">"
			Toggle.TextColor3 = Color3.fromRGB(160, 160, 160)
			Toggle.TextSize = 14.000

			textBoxValuesPadding.Parent = selectorText
			textBoxValuesPadding.PaddingBottom = UDim.new(0, 6)
			textBoxValuesPadding.PaddingLeft = UDim.new(0, 6)
			textBoxValuesPadding.PaddingRight = UDim.new(0, 6)
			textBoxValuesPadding.PaddingTop = UDim.new(0, 6)

			Frame.Parent = selectorText
			Frame.AnchorPoint = Vector2.new(0.5, 1)
			Frame.BackgroundColor3 = Color3.fromRGB(39, 39, 39)
			Frame.BorderSizePixel = 0
			Frame.Position = UDim2.new(0.5, 0, 1, 7)
			Frame.Size = UDim2.new(1, -6, 0, 1)

			selectorTwoLayout.Parent = selectorTwo
			selectorTwoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			selectorTwoLayout.SortOrder = Enum.SortOrder.LayoutOrder

			selectorTwoCorner.CornerRadius = UDim.new(0, 2)
			selectorTwoCorner.Parent = selectorTwo

			selectorPadding_2.Parent = selectorTwo
			selectorPadding_2.PaddingTop = UDim.new(0, 1)

			selectorContainer.Parent = selectorTwo
			selectorContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			selectorContainer.BackgroundTransparency = 1.000
			selectorContainer.Size = UDim2.new(1, 0, 0, 20)

			selectorTwoLayout_2.Parent = selectorContainer
			selectorTwoLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
			selectorTwoLayout_2.SortOrder = Enum.SortOrder.LayoutOrder

			TweenWrapper:CreateStyle("selector", 0.08)


			local Amount = #list
			local Val = (Amount * 20)
			local Size= 0

			local function checkSizes()
				Amount = #list
				Val = (Amount * 20) + 20
			end

			for i,v in next, list do
				local optionButton = Instance.new("TextButton")

				optionButton.Name = "optionButton"
				optionButton.Parent = selectorContainer
				optionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				optionButton.BackgroundTransparency = 1.000
				optionButton.Size = UDim2.new(0, 394, 0, 20)
				optionButton.AutoButtonColor = false
				optionButton.Font = library.Font
				optionButton.Text = v
				optionButton.TextColor3 = Color3.fromRGB(160, 160, 160)
				optionButton.TextSize = 14.000
				if optionButton.Text == default then
					optionButton.TextColor3 = library.acientColor
					callback(selectorText.Text)
				end

				optionButton.MouseButton1Click:Connect(function()
					for z,x in next, selectorContainer:GetChildren() do
						if x:IsA("TextButton") then
							TweenService:Create(x, TweenWrapper.Styles["selector"], {TextColor3 = Color3.fromRGB(160, 160, 160)}):Play()
						end
					end
					TweenService:Create(optionButton, TweenWrapper.Styles["selector"], {TextColor3 = library.acientColor}):Play()
					selectorText.Text = optionButton.Text
					callback(optionButton.Text)
				end)

				Size = Val + 2


				checkSizes()
			end


			local SelectorFunctions = {}
			local AddAmount = 0

			local IsOpen = false
			local function HandleToggle()
				local Speed = 0.2
				IsOpen = not IsOpen

				TweenService:Create(selector, TweenInfo.new(Speed), {
					Size = UDim2.new(1, 0, 0, IsOpen and Size or 23)
				}):Play()
				TweenService:Create(selectorFrame, TweenInfo.new(Speed), {
					Size = UDim2.new(0, 394, 0, IsOpen and Size+24 or 48)
				}):Play()
				TweenService:Create(Toggle, TweenInfo.new(Speed), {
					Rotation = IsOpen and -90 or 90
				}):Play()
			end

			selector.Activated:Connect(HandleToggle)
			Toggle.Activated:Connect(HandleToggle)

			function SelectorFunctions:AddOption(new, callback_f)
				new = new or "option"
				list[new] = new

				local optionButton = Instance.new("TextButton")

				AddAmount = AddAmount + 20

				optionButton.Name = "optionButton"
				optionButton.Parent = selectorContainer
				optionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				optionButton.BackgroundTransparency = 1.000
				optionButton.Size = UDim2.new(0, 394, 0, 20)
				optionButton.AutoButtonColor = false
				optionButton.Font = library.Font
				optionButton.Text = new
				optionButton.TextColor3 = Color3.fromRGB(140, 140, 140)
				optionButton.TextSize = 14.000
				if optionButton.Text == default then
					optionButton.TextColor3 = library.acientColor
					callback(selectorText.Text)
				end

				optionButton.MouseButton1Click:Connect(function()
					for z,x in next, selectorContainer:GetChildren() do
						if x:IsA("TextButton") then
							TweenService:Create(x, TweenWrapper.Styles["selector"], {TextColor3 = Color3.fromRGB(140, 140, 140)}):Play()
						end
					end
					TweenService:Create(optionButton, TweenWrapper.Styles["selector"], {TextColor3 = library.acientColor}):Play()
					selectorText.Text = optionButton.Text
					callback(optionButton.Text)
				end)

				checkSizes()
				Size = (Val + AddAmount) + 2


				checkSizes()
				return self
			end

			local RemoveAmount = 0
			function SelectorFunctions:RemoveOption(option)
				list[option] = nil

				RemoveAmount = RemoveAmount + 20
				AddAmount = AddAmount - 20

				for i,v in next, selectorContainer:GetDescendants() do
					if v:IsA("TextButton") then
						if v.Text == option then
							v:Destroy()
							Size = (Val - RemoveAmount) + 2
						end
					end
				end

				if selectorText.Text == option then
					selectorText.Text = ". . ."
				end


				checkSizes()
				return self
			end

			function SelectorFunctions:SetFunction(new)
				new = new or callback
				callback = new
				return self
			end

			function SelectorFunctions:Text(new)
				new = new or selectorLabel.Text
				selectorLabel.Text = new
				return self
			end

			function SelectorFunctions:Hide()
				selectorFrame.Visible = false
				return self
			end

			function SelectorFunctions:Show()
				selectorFrame.Visible = true
				return self
			end

			function SelectorFunctions:Remove()
				selectorFrame:Destroy()
				return self
			end
			return SelectorFunctions
		end

		function Components:NewSlider(text, suffix, compare, compareSign, values, callback)
			text = text or "slider"
			suffix = suffix or ""
			compare = compare or false
			compareSign = compareSign or "/"
			values = values or {
				min = values.min or 0,
				max = values.max or 100,
				default = values.default or 0
			}
			callback = callback or function() end

			values.max = values.max + 1

			local sliderFrame = Instance.new("Frame")
			local sliderFolder = Instance.new("Folder")
			local textboxFolderLayout = Instance.new("UIListLayout")
			local sliderButton = Instance.new("TextButton")
			local sliderButtonCorner = Instance.new("UICorner")
			local sliderBackground = Instance.new("Frame")
			local sliderButtonCorner_2 = Instance.new("UICorner")
			local sliderBackgroundLayout = Instance.new("UIListLayout")
			local sliderIndicator = Instance.new("Frame")
			local sliderIndicatorStraint = Instance.new("UISizeConstraint")
			local sliderIndicatorGradient = Instance.new("UIGradient")
			local sliderIndicatorCorner = Instance.new("UICorner")
			local sliderBackgroundPadding = Instance.new("UIPadding")
			local sliderButtonLayout = Instance.new("UIListLayout")
			local sliderLabel = Instance.new("TextLabel")
			local sliderPadding = Instance.new("UIPadding")
			local sliderValue = Instance.new("TextLabel")

			sliderFrame.Parent = page
			sliderFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
			sliderFrame.BackgroundTransparency = 1.000
			sliderFrame.ClipsDescendants = true
			sliderFrame.Position = UDim2.new(0.00499999989, 0, 0.667630076, 0)
			sliderFrame.Size = UDim2.new(0, 394, 0, 40)

			sliderFolder.Parent = sliderFrame

			textboxFolderLayout.Parent = sliderFolder
			textboxFolderLayout.FillDirection = Enum.FillDirection.Horizontal
			textboxFolderLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			textboxFolderLayout.SortOrder = Enum.SortOrder.LayoutOrder
			textboxFolderLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
			textboxFolderLayout.Padding = UDim.new(0, 4)

			sliderButton.Parent = sliderFolder
			sliderButton.BackgroundColor3 = library.darkGray
			sliderButton.BackgroundTransparency = library.transparency
			sliderButton.Position = UDim2.new(0.348484844, 0, 0.600000024, 0)
			sliderButton.Size = UDim2.new(0, 394, 0, 16)
			sliderButton.AutoButtonColor = false
			sliderButton.Font = library.Font
			sliderButton.Text = ""
			sliderButton.TextColor3 = Color3.fromRGB(0, 0, 0)
			sliderButton.TextSize = 14.000

			sliderButtonCorner.CornerRadius = UDim.new(0, 2)
			sliderButtonCorner.Parent = sliderButton

			sliderBackground.Parent = sliderButton
			sliderBackground.BackgroundColor3 = library.darkGray
			sliderBackground.BackgroundTransparency = library.transparency
			sliderBackground.Size = UDim2.new(0, 392, 0, 14)
			sliderBackground.Position = UDim2.new(0, 2, 0, 0)
			sliderBackground.ClipsDescendants = true

			sliderButtonCorner_2.CornerRadius = UDim.new(0, 2)
			sliderButtonCorner_2.Parent = sliderBackground

			sliderBackgroundLayout.Parent = sliderBackground
			sliderBackgroundLayout.SortOrder = Enum.SortOrder.LayoutOrder
			sliderBackgroundLayout.VerticalAlignment = Enum.VerticalAlignment.Center

			sliderIndicator.Parent = sliderBackground
			sliderIndicator.BorderSizePixel = 0
			sliderIndicator.Position = UDim2.new(0, 0, -0.1, 0)
			sliderIndicator.Size = UDim2.new(0, 0, 0, 12)
			sliderIndicator.BackgroundColor3 = library.acientColor

			sliderIndicatorStraint.Parent = sliderIndicator
			sliderIndicatorStraint.MaxSize = Vector2.new(392, 12)

			sliderIndicatorGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,255,255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(181, 181, 181))}
			sliderIndicatorGradient.Rotation = 90
			sliderIndicatorGradient.Parent = sliderIndicator

			sliderIndicatorCorner.CornerRadius = UDim.new(0, 2)
			sliderIndicatorCorner.Parent = sliderIndicator

			sliderBackgroundPadding.Parent = sliderBackground
			sliderBackgroundPadding.PaddingBottom = UDim.new(0, 2)
			sliderBackgroundPadding.PaddingLeft = UDim.new(0, 1)
			sliderBackgroundPadding.PaddingRight = UDim.new(0, 1)
			sliderBackgroundPadding.PaddingTop = UDim.new(0, 2)

			sliderButtonLayout.Parent = sliderButton
			sliderButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			sliderButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
			sliderButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Center

			sliderLabel.Parent = sliderFrame
			sliderLabel.BackgroundTransparency = 1.000
			sliderLabel.Size = UDim2.new(0, 396, 0, 24)
			sliderLabel.Font = library.Font
			sliderLabel.Text = text
			sliderLabel.TextColor3 = Color3.fromRGB(190, 190, 190)
			sliderLabel.TextSize = 14.000
			sliderLabel.TextWrapped = true
			sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
			sliderLabel.RichText = true

			sliderPadding.Parent = sliderLabel
			sliderPadding.PaddingBottom = UDim.new(0, 6)
			sliderPadding.PaddingLeft = UDim.new(0, 2)
			sliderPadding.PaddingRight = UDim.new(0, 6)
			sliderPadding.PaddingTop = UDim.new(0, 6)

			sliderValue.Parent = sliderLabel
			sliderValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			sliderValue.BackgroundTransparency = 1.000
			sliderValue.Position = UDim2.new(0.577319562, 0, 0, 0)
			sliderValue.Size = UDim2.new(0, 169, 0, 15)
			sliderValue.Font = library.Font
			sliderValue.Text = values.default or ""
			sliderValue.TextColor3 = Color3.fromRGB(140, 140, 140)
			sliderValue.TextSize = 14.000
			sliderValue.TextXAlignment = Enum.TextXAlignment.Right


			local calc1 = values.max - values.min
			local calc2 = values.default - values.min
			local calc3 = calc2 / calc1
			local calc4 = calc3 * sliderBackground.AbsoluteSize.X
			sliderIndicator.Size = UDim2.new(0, calc4, 0, 12)
			sliderValue.Text = values.default

			TweenWrapper:CreateStyle("slider_drag", 0.05, Enum.EasingStyle.Linear)

			local ValueNum = values.default
			local slideText = compare and ValueNum .. compareSign .. tostring(values.max - 1) .. suffix or ValueNum .. suffix
			sliderValue.Text = slideText
			local function UpdateSlider()
				TweenService:Create(sliderIndicator, TweenWrapper.Styles["slider_drag"], {Size = UDim2.new(0, math.clamp(Mouse.X - sliderIndicator.AbsolutePosition.X, 0, sliderBackground.AbsoluteSize.X), 0, 12)}):Play()

				ValueNum = math.floor((((tonumber(values.max) - tonumber(values.min)) / sliderBackground.AbsoluteSize.X) * sliderIndicator.AbsoluteSize.X) + tonumber(values.min)) or 0.00

				local slideText = compare and ValueNum .. compareSign .. tostring(values.max - 1) .. suffix or ValueNum .. suffix

				sliderValue.Text = slideText

				pcall(function()
					callback(ValueNum)
				end)

				sliderValue.Text = slideText

				moveconnection = Mouse.Move:Connect(function()
					ValueNum = math.floor((((tonumber(values.max) - tonumber(values.min)) / sliderBackground.AbsoluteSize.X) * sliderIndicator.AbsoluteSize.X) + tonumber(values.min))

					slideText = compare and ValueNum .. compareSign .. tostring(values.max - 1) .. suffix or ValueNum .. suffix
					sliderValue.Text = slideText

					pcall(function()
						callback(ValueNum)
					end)

					TweenService:Create(sliderIndicator, TweenWrapper.Styles["slider_drag"], {Size = UDim2.new(0, math.clamp(Mouse.X - sliderIndicator.AbsolutePosition.X, 0, sliderBackground.AbsoluteSize.X), 0, 12)}):Play()
					if not UserInputService.WindowFocused then
						moveconnection:Disconnect()
					end
				end)

				releaseconnection = UserInputService.InputEnded:Connect(function(Mouse_2)
					if Mouse_2.UserInputType == Enum.UserInputType.MouseButton1 then
						ValueNum = math.floor((((tonumber(values.max) - tonumber(values.min)) / sliderBackground.AbsoluteSize.X) * sliderIndicator.AbsoluteSize.X) + tonumber(values.min))

						slideText = compare and ValueNum .. compareSign .. tostring(values.max - 1) .. suffix or ValueNum .. suffix
						sliderValue.Text = slideText

						pcall(function()
							callback(ValueNum)
						end)

						TweenService:Create(sliderIndicator, TweenWrapper.Styles["slider_drag"], {Size = UDim2.new(0, math.clamp(Mouse.X - sliderIndicator.AbsolutePosition.X, 0, sliderBackground.AbsoluteSize.X), 0, 12)}):Play()
						moveconnection:Disconnect()
						releaseconnection:Disconnect()
					end
				end)
			end

			sliderButton.MouseButton1Down:Connect(function()
				UpdateSlider()
			end)



			local SliderFunctions = {}
			OptionStates[sliderButton] = {values.default, SliderFunctions}

			function SliderFunctions:Set(new, NoCallBack)
				local ncalc1 = new - values.min
				local ncalc2 = ncalc1 / calc1
				local ncalc3 = ncalc2 * sliderBackground.AbsoluteSize.X
				local nCalculation = ncalc3
				sliderIndicator.Size = UDim2.new(0, nCalculation, 0, 12)
				slideText = compare and new .. compareSign .. tostring(values.max - 1) .. suffix or new .. suffix
				sliderValue.Text = slideText
				if not NoCallBack then
					callback(new)
				end
				return self
			end
			SliderFunctions:Set(values.default, true)

			function SliderFunctions:Max(new)
				new = new or values.max
				values.max = new + 1
				slideText = compare and ValueNum .. compareSign .. tostring(values.max - 1) .. suffix or ValueNum .. suffix
				return self
			end

			function SliderFunctions:Min(new)
				new = new or values.min
				values.min = new
				slideText = compare and new .. compareSign .. tostring(values.max - 1) .. suffix or ValueNum .. suffix
				TweenService:Create(sliderIndicator, TweenWrapper.Styles["slider_drag"], {Size = UDim2.new(0, math.clamp(Mouse.X - sliderIndicator.AbsolutePosition.X, 0, sliderBackground.AbsoluteSize.X), 0, 12)}):Play()
				return self
			end

			function SliderFunctions:SetFunction(new)
				new = new or callback
				callback = new
				return self
			end

			function SliderFunctions:GetValue()
				return ValueNum
			end

			function SliderFunctions:SetText(new)
				new = new or sliderLabel.Text
				sliderLabel.Text = new
				return self
			end

			function SliderFunctions:Hide()
				sliderFrame.Visible = false
				return self
			end

			function SliderFunctions:Show()
				sliderFrame.Visible = true
				return self
			end

			function SliderFunctions:Remove()
				sliderFrame:Destroy()
				return self
			end
			return SliderFunctions
		end

		function Components:NewSeperator()
			local sectionFrame = Instance.new("Frame")
			local sectionLayout = Instance.new("UIListLayout")
			local rightBar = Instance.new("Frame")

			sectionFrame.Name = "sectionFrame"
			sectionFrame.Parent = page
			sectionFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			sectionFrame.BackgroundTransparency = 1.000
			sectionFrame.ClipsDescendants = true
			sectionFrame.Position = UDim2.new(0.00499999989, 0, 0.361271679, 0)
			sectionFrame.Size = UDim2.new(0, 396, 0, 12)

			sectionLayout.Name = "sectionLayout"
			sectionLayout.Parent = sectionFrame
			sectionLayout.FillDirection = Enum.FillDirection.Horizontal
			sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
			sectionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			sectionLayout.Padding = UDim.new(0, 4)

			rightBar.Name = "rightBar"
			rightBar.Parent = sectionFrame
			rightBar.BackgroundColor3 = library.darkGray
			rightBar.BackgroundTransparency = library.transparency
			rightBar.BorderSizePixel = 0
			rightBar.Position = UDim2.new(0.308080822, 0, 0.479166657, 0)
			rightBar.Size = UDim2.new(0, 403, 0, 1)



			local SeperatorFunctions = {}
			function SeperatorFunctions:Hide()
				sectionFrame.Visible = false
				return SeperatorFunctions
			end

			function SeperatorFunctions:Show()
				sectionFrame.Visible = true
				return SeperatorFunctions
			end

			function SeperatorFunctions:Remove()
				sectionFrame:Destroy()
				return SeperatorFunctions
			end
			return SeperatorFunctions
		end

		function Components:Open()
			TabLibrary.CurrentTab = title
			for i,v in next, container:GetChildren() do 
				if v:IsA("ScrollingFrame") then
					v.Visible = false
				end
			end
			page.Visible = true

			for i,v in next, tabButtons:GetChildren() do
				if v:IsA("TextButton") then
					TweenService:Create(v, TweenWrapper.Styles["tab_text_colour"], {TextColor3 = Color3.fromRGB(170, 170, 170)}):Play()
				end
			end
			TweenService:Create(tabButton, TweenWrapper.Styles["tab_text_colour"], {TextColor3 = library.acientColor}):Play()

			return Components
		end

		function Components:Remove()
			tabButton:Destroy()
			page:Destroy()

			return Components
		end

		function Components:Hide()
			tabButton.Visible = false
			page.Visible = false

			return Components
		end

		function Components:Show()
			tabButton.Visible = true

			return Components
		end

		function Components:Text(text)
			text = text or "new text"
			tabButton.Text = text

			return Components
		end
		return Components
	end

	function library:Remove()
		screen:Destroy()
		library:Panic()

		return self
	end


	return library
end

return library
