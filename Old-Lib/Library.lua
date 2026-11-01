

local unpack_ = unpack or table.unpack
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")
local Orion = {
	Elements = {},
	ThemeObjects = {},
	Connections = {},
	Flags = {},
	Themes = {
		Default = {
			Main = Color3.fromRGB(26, 16, 36),
			Second = Color3.fromRGB(38, 25, 54),
			Stroke = Color3.fromRGB(96, 62, 138),
			Divider = Color3.fromRGB(58, 40, 80),
			Text = Color3.fromRGB(255, 255, 255),
			TextDark = Color3.fromRGB(198, 188, 214)
		}
	},
	SelectedTheme = "Default",
	Folder = nil,
	SaveCfg = false
}
local icons = nil

local function LoadIconsFn()
	icons = HttpService:JSONDecode(game:HttpGetAsync("https://raw.githubusercontent.com/evoincorp/lucideblox/master/src/modules/util/icons.json")).icons
end

icons = {}

local IconLoadResult = { pcall(loadIconsFn) }
local IconLoadError = IconLoadResult[2]

if not IconLoadResult[1] then
	warn("\nOrion Library - Failed to load Feather Icons. Error code: " .. IconLoadError .. "\n")
end

local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = "Orion"

if syn then
	syn.protect_gui(ScreenGui)
	ScreenGui.Parent = game.CoreGui
else
	ScreenGui.Parent = gethui() or game.CoreGui
end

-- 窗口恢复按钮（隐藏后点击放大窗口）
local RestoreIcon = Instance.new("ImageButton")
RestoreIcon.Name = "RestoreIcon"
RestoreIcon.Size = UDim2.new(0, 46, 0, 46)
RestoreIcon.Position = UDim2.new(0, 12, 0, 12)
RestoreIcon.BackgroundColor3 = Orion.Themes[Orion.SelectedTheme].Second
RestoreIcon.Visible = false
RestoreIcon.ZIndex = 50
RestoreIcon.Parent = ScreenGui
local RestoreCorner = Instance.new("UICorner")
RestoreCorner.CornerRadius = UDim.new(1, 0)
RestoreCorner.Parent = RestoreIcon
local RestoreImage = Instance.new("ImageLabel")
RestoreImage.Image = "rbxassetid://8834748103"
RestoreImage.Size = UDim2.new(0, 26, 0, 26)
RestoreImage.Position = UDim2.new(0.5, -13, 0.5, -13)
RestoreImage.BackgroundTransparency = 1
RestoreImage.ZIndex = 51
RestoreImage.Parent = RestoreIcon
AddThemeObject(RestoreIcon, "Second")

if gethui then
	for _, child in ipairs(gethui():GetChildren()) do
		local isMatch = child.Name == ScreenGui.Name

		if isMatch then
			isMatch = child ~= ScreenGui
		end

		if isMatch then
			child:Destroy()
		end
	end
else
	for _, child in ipairs(game.CoreGui:GetChildren()) do
		local isMatch2 = child.Name == ScreenGui.Name

		if isMatch2 then
			isMatch2 = child ~= ScreenGui
		end

		if isMatch2 then
			child:Destroy()
		end
	end
end

function Orion.IsRunning(_)
	if gethui then
		return ScreenGui.Parent == gethui()
	else
		return ScreenGui.Parent == game:GetService("CoreGui")
	end
end

local function AddConnection(self, func)
	if Orion:IsRunning() then
		local connection = self:Connect(func)
		local Connections = Orion.Connections

		table.insert(Connections, connection)

		return connection
	end
end
local function SetProperties(connectionName, parent)
	table.foreach(parent, function(list, index)
		connectionName[list] = index
	end)

	return connectionName
end

task.spawn(function()
	while Orion:IsRunning() do
		wait()
	end

	local next_ = next
	local Connections = Orion.Connections
	local key = nil

	while true do
		local iterValue

		key, iterValue = next_(Connections, key)

		if not key then
			break
		end

		iterValue:Disconnect()
	end
end)

local function MakeDraggable(dragPoint, main)
	local valueA = nil
	local valueB = nil

	local function cleanupUI()
		local hideTween = false
		local waitTween = nil
		local Position = nil
		local Position2 = nil
		local InputBegan = valueB.InputBegan

		local function onInputBegan(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end

			hideTween = true
			Position = input.Position
			Position2 = valueA.Position
			input.Changed:Connect(function()
				if input.UserInputState ~= Enum.UserInputState.End then
					return
				end

				hideTween = false
			end)
		end

		if Orion:IsRunning() then
			local connection = InputBegan:Connect(onInputBegan)
			local Connections = Orion.Connections

			table.insert(Connections, connection)
		end

		local InputChanged = valueB.InputChanged

		local function onDragStart(input)
			if input.UserInputType ~= Enum.UserInputType.MouseMovement then
				return
			end

			waitTween = input
		end

		if Orion:IsRunning() then
			local connection = InputChanged:Connect(onDragStart)
			local Connections = Orion.Connections

			table.insert(Connections, connection)
		end

		local InputChanged2 = UserInputService.InputChanged

		local function onInputEnded(input)
			local shouldWait

			if input == waitTween then
				shouldWait = hideTween
			else
				shouldWait = false
			end

			if not shouldWait then
				return
			end

			local dragOffset = input.Position - Position

			valueA.Position = UDim2.new(Position2.X.Scale, Position2.X.Offset + dragOffset.X, Position2.Y.Scale, Position2.Y.Offset + dragOffset.Y)
		end

		if not Orion:IsRunning() then
			return
		end

		local connection = InputChanged2:Connect(onInputEnded)
		local Connections = Orion.Connections

		table.insert(Connections, connection)
	end

	valueB = dragPoint
	valueA = main
	pcall(cleanupUI)
end
local function CreateInstance(className, children, objects)
	local instance = Instance.new(className)
	local next_ = next
	local children = children or {}
	local key = nil

	while true do
		local propValue

		key, propValue = next_(children, key)

		if not key then
			break
		end

		instance[key] = propValue
	end

	local next_2 = next
	local objects = objects or {}
	local key2 = nil

	while true do
		local childValue

		key2, childValue = next_2(objects, key2)

		if not key2 then
			break
		end

		childValue.Parent = instance
	end

	return instance
end
local function NewElement(className, ...)
	return Orion.Elements[className](...)
end
local function RegisterElement(elementType, buildFunction)
	Orion.Elements[elementType] = function(...)
		return buildFunction(...)
	end
end
local function RoundToIncrement(value, increment)
	local roundedValue = math.floor(value / increment + math.sign(value) * 0.5) * increment

	if not (roundedValue < 0) then
		return roundedValue
	end

	roundedValue = roundedValue + increment

	return roundedValue
end
local function SetChildren(children, parent)
	table.foreach(parent, function(_, child)
		child.Parent = children
	end)

	return children
end

local GetColorProperty = nil

local function AddThemeObject(element, property)
	if Orion.ThemeObjects[property] then
		local themeObjects = Orion.ThemeObjects[property]
		table.insert(themeObjects, element)
		element[GetColorProperty(element)] = Orion.Themes[Orion.SelectedTheme][property]

		return element
	end

	Orion.ThemeObjects[property] = {}

	local objectsList = Orion.ThemeObjects[property]

	table.insert(objectsList, element)
	element[GetColorProperty(element)] = Orion.Themes[Orion.SelectedTheme][property]

	return element
end

GetColorProperty = function(property)
	if property:IsA("Frame") or property:IsA("TextButton") then
		return "BackgroundColor3"
	elseif property:IsA("ScrollingFrame") then
		return "ScrollBarImageColor3"
	elseif property:IsA("UIStroke") then
		return "Color"
	elseif property:IsA("TextLabel") or property:IsA("TextBox") then
		return "TextColor3"
	elseif property:IsA("ImageLabel") or property:IsA("ImageButton") then
		return "ImageColor3"
	else
		return
	end
end

local function SaveConfig(configName)
	local configToSave = {}

	for k, flagValue in pairs(Orion.Flags) do
		if flagValue.Save then
			if flagValue.Type == "Colorpicker" then
				local Value_ = flagValue.Value

				configToSave[k] = {
					R = Value_.R * 255,
					G = Value_.G * 255,
					B = Value_.B * 255
				}
			else
				configToSave[k] = flagValue.Value
			end
		end
	end

	local httpService = HttpService

	writefile(Orion.Folder .. "/" .. configName .. ".txt", (tostring(httpService:JSONEncode(configToSave))))
end

local DeserializeColor = nil

DeserializeColor = function(colorTable)
	return Color3.fromRGB(colorTable.R, colorTable.G, colorTable.B)
end

local MouseInputTypes = { Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3 }
local IgnoredKeys = {
	Enum.KeyCode.Unknown,
	Enum.KeyCode.W,
	Enum.KeyCode.A,
	Enum.KeyCode.S,
	Enum.KeyCode.D,
	Enum.KeyCode.Up,
	Enum.KeyCode.Left,
	Enum.KeyCode.Down,
	Enum.KeyCode.Right,
	Enum.KeyCode.Slash,
	Enum.KeyCode.Tab,
	Enum.KeyCode.Backspace,
	Enum.KeyCode.Escape
}

local function IsInList(list, item)
	local next_ = next
	local key = nil

	while true do
		local loopValue

		key, loopValue = next_(list, key)

		if not key then
			break
		end

		if loopValue == item then
			return true
		end
	end
end

RegisterElement("Corner", function(parent, cornerRadius)
	return CreateInstance("UICorner", {
		CornerRadius = UDim.new(parent or 0, cornerRadius or 10)
	})
end)
RegisterElement("Stroke", function(parent, thickness)
	return CreateInstance("UIStroke", {
		Color = parent or Color3.fromRGB(255, 255, 255),
		Thickness = thickness or 1
	})
end)
RegisterElement("List", function(parent, listPadding)
	return CreateInstance("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(parent or 0, listPadding or 0)
	})
end)
RegisterElement("Padding", function(parent, padTop, padBottom, padLeftRight)
	return CreateInstance("UIPadding", {
		PaddingBottom = UDim.new(0, parent or 4),
		PaddingLeft = UDim.new(0, padTop or 4),
		PaddingRight = UDim.new(0, padBottom or 4),
		PaddingTop = UDim.new(0, padLeftRight or 4)
	})
end)
RegisterElement("TFrame", function()
	return CreateInstance("Frame", {
		BackgroundTransparency = 1
	})
end)
RegisterElement("Frame", function(parent)
	return CreateInstance("Frame", {
		BackgroundColor3 = parent or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	})
end)
RegisterElement("RoundFrame", function(parent, cornerScale, cornerOffset)
	return CreateInstance("Frame", {
		BackgroundColor3 = parent or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	}, { CreateInstance("UICorner", {
			CornerRadius = UDim.new(cornerScale, cornerOffset)
		}) })
end)
RegisterElement("Button", function()
	return CreateInstance("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
end)
RegisterElement("ScrollFrame", function(parent, scrollingEnabled)
	return CreateInstance("ScrollingFrame", {
		BackgroundTransparency = 1,
		MidImage = "rbxassetid://7445543667",
		BottomImage = "rbxassetid://7445543667",
		TopImage = "rbxassetid://7445543667",
		ScrollBarImageColor3 = parent,
		BorderSizePixel = 0,
		ScrollBarThickness = scrollingEnabled,
		CanvasSize = UDim2.new(0, 0, 0, 0)
	})
end)
RegisterElement("Image", function(parent)
	local ImageLabel = CreateInstance("ImageLabel", {
		Image = parent,
		BackgroundTransparency = 1
	})
	local iconName

	if icons[parent] == nil then
		iconName = nil
	else
		iconName = icons[parent]
	end

	if iconName == nil then
		return ImageLabel
	end

	local iconId

	if icons[parent] == nil then
		iconId = nil
	else
		iconId = icons[parent]
	end

	ImageLabel.Image = iconId

	return ImageLabel
end)
RegisterElement("ImageButton", function(parent)
	return CreateInstance("ImageButton", {
		Image = parent,
		BackgroundTransparency = 1
	})
end)
RegisterElement("Label", function(parent, labelText, textSize)
	return CreateInstance("TextLabel", {
		Text = parent or "",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = textSize or 0,
		TextSize = labelText or 15,
		Font = Enum.Font.Gotham,
		RichText = true,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left
	})
end)

local NotificationHolder = SetProperties(SetChildren(NewElement("TFrame"), { SetProperties(NewElement("List"), {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 5)
	}) }), {
	Position = UDim2.new(1, -25, 1, -25),
	Size = UDim2.new(0, 300, 1, -25),
	AnchorPoint = Vector2.new(1, 1),
	Parent = ScreenGui
})

function Orion.MakeNotification(_, NotificationConfig)
	local notification = nil

	local function removeNotification()
		notification.Name = notification.Name or "Notification"
		notification.Content = notification.Content or "Test"
		notification.Image = notification.Image or "rbxassetid://4384403532"
		notification.Time = notification.Time or 15

		local notifListFrame = SetProperties(NewElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = NotificationHolder
		})
		local notificationFrame = SetChildren(SetProperties(NewElement("RoundFrame", Color3.fromRGB(25, 25, 25), 0, 10), {
			Parent = notifListFrame,
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(1, -55, 0, 0),
			BackgroundTransparency = 0,
			AutomaticSize = Enum.AutomaticSize.Y
		}), {
			NewElement("Stroke", Color3.fromRGB(93, 93, 93), 1.2),
			NewElement("Padding", 12, 12, 12, 12),
			SetProperties(NewElement("Image", notification.Image), {
				Size = UDim2.new(0, 20, 0, 20),
				ImageColor3 = Color3.fromRGB(240, 240, 240),
				Name = "Icon"
			}),
			SetProperties(NewElement("Label", notification.Name, 15), {
				Size = UDim2.new(1, -30, 0, 20),
				Position = UDim2.new(0, 30, 0, 0),
				Font = Enum.Font.GothamBold,
				Name = "Title"
			}),
			SetProperties(NewElement("Label", notification.Content, 14), {
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 25),
				Font = Enum.Font.GothamSemibold,
				Name = "Content",
				AutomaticSize = Enum.AutomaticSize.Y,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextWrapped = true
			})
		})
		local tweenService = TweenService
		local tweenInfoNew = TweenInfo.new
		local Enum_ = Enum

		tweenService.Create(tweenService, notificationFrame, tweenInfoNew(0.5, Enum_.EasingStyle.Quint), {
			Position = UDim2.new(0, 0, 0, 0)
		}):Play()
		wait(notification.Time - 0.88)
		TweenService:Create(notificationFrame.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
			ImageTransparency = 1
		}):Play()
		TweenService:Create(notificationFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
			BackgroundTransparency = 0.6
		}):Play()
		wait(0.3)
		TweenService:Create(notificationFrame.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
			Transparency = 0.9
		}):Play()
		TweenService:Create(notificationFrame.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
			TextTransparency = 0.4
		}):Play()
		TweenService:Create(notificationFrame.Content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
			TextTransparency = 0.5
		}):Play()
		wait(0.05)
		notificationFrame:TweenPosition(UDim2.new(1, 20, 0, 0), "In", "Quint", 0.8, true)
		wait(1.35)
		notificationFrame:Destroy()
	end

	notification = NotificationConfig
	spawn(removeNotification)
end
function Orion.Init(_)
	if not Orion.SaveCfg then
		return
	end

	pcall(function()
		if not isfile(Orion.Folder .. "/" .. game.GameId .. ".txt") then
			return
		end

		local data = HttpService:JSONDecode((readfile(Orion.Folder .. "/" .. game.GameId .. ".txt")))

		table.foreach(data, function(key, value)
			if not Orion.Flags[key] then
				warn("Orion Library Config Loader - Could not find ", key, value)

				return
			end

			local function saveConfigOnExit()
				if Orion.Flags[key].Type == "Colorpicker" then
					Orion.Flags[key]:Set(unpack_({ DeserializeColor(value) }))
				else
					Orion.Flags[key]:Set(value)
				end
			end

			spawn(saveConfigOnExit)
		end)

		local orionRef = Orion
		local GameId = game.GameId

		orionRef.MakeNotification(orionRef, {
			Name = "配置",
			Content = "自动载入游戏配置" .. GameId .. ".",
			Time = 5
		})
	end)
end
function Orion.MakeWindow(_, windowConfig)
	local WindowConfig = windowConfig or {}

	WindowConfig.Name = WindowConfig.Name or "Orion Library"
	WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
	WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
	WindowConfig.HidePremium = WindowConfig.HidePremium or false

	if WindowConfig.IntroEnabled == nil then
		WindowConfig.IntroEnabled = true
	end

	WindowConfig.IntroText = WindowConfig.IntroText or "Orion Library"
	WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
	WindowConfig.ShowIcon = WindowConfig.ShowIcon or false
	WindowConfig.Icon = WindowConfig.Icon or "rbxassetid://8834748103"
	WindowConfig.IntroIcon = WindowConfig.IntroIcon or "rbxassetid://8834748103"
	Orion.Folder = WindowConfig.ConfigFolder
	Orion.SaveCfg = WindowConfig.SaveConfig

	if WindowConfig.SaveConfig and not isfolder(WindowConfig.ConfigFolder) then
		makefolder(WindowConfig.ConfigFolder)
	end

	local divider = AddThemeObject(SetChildren(SetProperties(NewElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 4), {
		Size = UDim2.new(1, 0, 1, -50)
	}), { NewElement("List"), NewElement("Padding", 8, 0, 0, 8) }), "Divider")
	local signal = divider.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize")

	local function onWindowIconClick()
		divider.CanvasSize = UDim2.new(0, 0, 0, divider.UIListLayout.AbsoluteContentSize.Y + 16)
	end

	if Orion:IsRunning() then
		local connection = signal:Connect(onWindowIconClick)
		local Connections = Orion.Connections

		table.insert(Connections, connection)
	end

	local closeButton = SetChildren(SetProperties(NewElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1
	}), { AddThemeObject(SetProperties(NewElement("Image", "rbxassetid://7072725342"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18)
		}), "Text") })
	local menuButton = SetChildren(SetProperties(NewElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		BackgroundTransparency = 1
	}), { AddThemeObject(SetProperties(NewElement("Image", "rbxassetid://7072719338"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18),
			Name = "Ico"
		}), "Text") })
	local menuFrame = SetProperties(NewElement("TFrame"), {
		Size = UDim2.new(1, 0, 0, 50)
	})
	local addThemeFn = AddThemeObject
	local setChildrenFn2 = SetChildren
	local topBar = SetProperties(NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
		Size = UDim2.new(0, 150, 1, -50),
		Position = UDim2.new(0, 0, 0, 50)
	})
	local second = AddThemeObject(SetProperties(NewElement("Frame"), {
		Size = UDim2.new(1, 0, 0, 10),
		Position = UDim2.new(0, 0, 0, 0)
	}), "Second")
	local second2 = AddThemeObject(SetProperties(NewElement("Frame"), {
		Size = UDim2.new(0, 10, 1, 0),
		Position = UDim2.new(1, -10, 0, 0)
	}), "Second")
	local stroke = AddThemeObject(SetProperties(NewElement("Frame"), {
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, -1, 0, 0)
	}), "Stroke")
	local setChildrenFn3 = SetChildren
	local tabHolder = SetProperties(NewElement("TFrame"), {
		Size = UDim2.new(1, 0, 0, 50),
		Position = UDim2.new(0, 0, 1, -50)
	})
	local stroke2 = AddThemeObject(SetProperties(NewElement("Frame"), {
		Size = UDim2.new(1, 0, 0, 1)
	}), "Stroke")
	local divider2 = AddThemeObject(SetChildren(SetProperties(NewElement("Frame"), {
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.new(0, 32, 0, 32),
		Position = UDim2.new(0, 10, 0.5, 0)
	}), { SetProperties(NewElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"), {
			Size = UDim2.new(1, 0, 1, 0)
		}), AddThemeObject(SetProperties(NewElement("Image", "rbxassetid://4031889928"), {
			Size = UDim2.new(1, 0, 1, 0)
		}), "Second"), NewElement("Corner", 1) }), "Divider")
	local tabContainer = SetChildren(SetProperties(NewElement("TFrame"), {
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.new(0, 32, 0, 32),
		Position = UDim2.new(0, 10, 0.5, 0)
	}), { AddThemeObject(NewElement("Stroke"), "Stroke"), NewElement("Corner", 1) })
	local addThemeFn2 = AddThemeObject
	local setPropsFn = SetProperties
	local Label = NewElement("Label", LocalPlayer.DisplayName, WindowConfig.HidePremium and 14 or 13)
	local uDim2 = UDim2.new(1, -60, 0, 13)
	local HidePremium = WindowConfig.HidePremium

	if HidePremium then
		HidePremium = UDim2.new(0, 50, 0, 19)
	end

	local second3 = addThemeFn(setChildrenFn2(topBar, {
		second,
		second2,
		stroke,
		divider,
		setChildrenFn3(tabHolder, {
			stroke2,
			divider2,
			tabContainer,
			addThemeFn2(setPropsFn(Label, {
				Size = uDim2,
				Position = HidePremium or UDim2.new(0, 50, 0, 12),
				Font = Enum.Font.GothamBold,
				ClipsDescendants = true
			}), "Text"),
			AddThemeObject(SetProperties(NewElement("Label", "", 12), {
				Size = UDim2.new(1, -60, 0, 12),
				Position = UDim2.new(0, 50, 1, -25),
				Visible = not WindowConfig.HidePremium
			}), "TextDark")
		})
	}), "Second")
	local text = AddThemeObject(SetProperties(NewElement("Label", WindowConfig.Name, 14), {
		Size = UDim2.new(1, -30, 2, 0),
		Position = UDim2.new(0, 25, 0, -24),
		Font = Enum.Font.GothamBlack,
		TextSize = 20
	}), "Text")
	local stroke3 = AddThemeObject(SetProperties(NewElement("Frame"), {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1)
	}), "Stroke")
	local main = AddThemeObject(SetChildren(SetProperties(NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
		Parent = ScreenGui,
		Position = UDim2.new(0.5, -307, 0.5, -172),
		Size = UDim2.new(0, 615, 0, 344),
		ClipsDescendants = true,
		Active = true,
		Draggable = true
	}), { SetChildren(SetProperties(NewElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 50),
			Name = "TopBar"
		}), { text, stroke3, AddThemeObject(SetChildren(SetProperties(NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 7), {
				Size = UDim2.new(0, 70, 0, 30),
				Position = UDim2.new(1, -90, 0, 10)
			}), {
				AddThemeObject(NewElement("Stroke"), "Stroke"),
				AddThemeObject(SetProperties(NewElement("Frame"), {
					Size = UDim2.new(0, 1, 1, 0),
					Position = UDim2.new(0.5, 0, 0, 0)
				}), "Stroke"),
				closeButton,
				menuButton
			}), "Second") }), menuFrame, second3 }), "Main")

	if WindowConfig.ShowIcon then
		text.Position = UDim2.new(0, 50, 0, -24)
		SetProperties(NewElement("Image", WindowConfig.Icon), {
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(0, 25, 0, 15)
		}).Parent = main.TopBar
	end

	MakeDraggable(menuFrame, main)

	local MouseButton1Up = closeButton.MouseButton1Up

	local function closeWindow()
		main.Visible = false
		RestoreIcon.Visible = true
		Orion:MakeNotification({
			Name = "XK脚本中心",
			Content = "再见“朋友”有机会回来看啊",
			Time = 5
		})
		WindowConfig.CloseCallback()
	end

	if Orion:IsRunning() then
		local connection = MouseButton1Up:Connect(closeWindow)
		local Connections = Orion.Connections

		table.insert(Connections, connection)
	end

	local InputBegan = UserInputService.InputBegan

	local function toggleWindow(key, processed)
		if key.KeyCode == Enum.KeyCode.RightShift and not processed then
			if main.Visible then
				main.Visible = false
				RestoreIcon.Visible = true
			else
				main.Visible = true
				RestoreIcon.Visible = false
			end
		end
	end

	RestoreIcon.MouseButton1Click:Connect(function()
		main.Visible = true
		RestoreIcon.Visible = false
	end)

	if Orion:IsRunning() then
		local connection = InputBegan:Connect(toggleWindow)
		local Connections = Orion.Connections

		table.insert(Connections, connection)
	end

	local MouseButton1Up2 = menuButton.MouseButton1Up

	local function onRestoreClick()
		main.ClipsDescendants = true
		stroke3.Visible = false
		menuButton.Ico.Image = "rbxassetid://7072720870"

		local tweenService = TweenService
		local windowHolder = main
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		local uDim2New = UDim2.new
		local introTextWidth = text.TextBounds.X + 140

		tweenService.Create(tweenService, windowHolder, tweenInfo, {
			Size = uDim2New(0, introTextWidth, 0, 50)
		}):Play()
		wait(0.1)
		second3.Visible = false
	end

	if Orion:IsRunning() then
		local connection = MouseButton1Up2:Connect(onRestoreClick)
		local Connections = Orion.Connections

		table.insert(Connections, connection)
	end

	local function onMenuClick()
		main.Visible = false

		local introIcon = SetProperties(NewElement("Image", WindowConfig.IntroIcon), {
			Parent = ScreenGui,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.4, 0),
			Size = UDim2.new(0, 28, 0, 28),
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ImageTransparency = 1
		})
		local introTextLabel = SetProperties(NewElement("Label", WindowConfig.IntroText, 14), {
			Parent = ScreenGui,
			Size = UDim2.new(1, 0, 1, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 19, 0.5, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			Font = Enum.Font.GothamBold,
			TextTransparency = 1
		})
		local tweenService = TweenService
		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		tweenService.Create(tweenService, introIcon, tweenInfo, {
			ImageTransparency = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}):Play()
		wait(0.8)

		local tweenService = TweenService
		local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local uDim2New = UDim2.new
		local X = introTextLabel.TextBounds.X

		tweenService.Create(tweenService, introIcon, tweenInfo2, {
			Position = uDim2New(0.5, -(X / 2), 0.5, 0)
		}):Play()
		wait(0.3)
		TweenService:Create(introTextLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 0
		}):Play()
		wait(2)
		TweenService:Create(introTextLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 1
		}):Play()
		main.Visible = true
		introIcon:Destroy()
		introTextLabel:Destroy()
	end

	if WindowConfig.IntroEnabled then
		onMenuClick()
	end

	return {
		MakeTab = function(_, tabConfig)
			local TabConfig = tabConfig or {}

			TabConfig.Name = TabConfig.Name or "Tab"
			TabConfig.Icon = TabConfig.Icon or ""
			TabConfig.PremiumOnly = TabConfig.PremiumOnly or false

			local tabButton = SetProperties(NewElement("Button"), {
				Size = UDim2.new(1, 0, 0, 30),
				Parent = divider
			})
			local iconConfig = { AddThemeObject(SetProperties(NewElement("Image", TabConfig.Icon), {
					AnchorPoint = Vector2.new(0, 0.5),
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0, 10, 0.5, 0),
					ImageTransparency = 0.4,
					Name = "Ico"
				}), "Text"), AddThemeObject(SetProperties(NewElement("Label", TabConfig.Name, 14), {
					Size = UDim2.new(1, -35, 1, 0),
					Position = UDim2.new(0, 35, 0, 0),
					Font = Enum.Font.GothamSemibold,
					TextTransparency = 0.4,
					Name = "Title"
				}), "Text") }

			table.foreach(iconConfig, function(_, iconProp)
				iconProp.Parent = tabButton
			end)

			local Icon = TabConfig.Icon
			local notificationIcon

			if icons[Icon] == nil then
				notificationIcon = nil
			else
				notificationIcon = icons[Icon]
			end

			if notificationIcon ~= nil then
				local Ico = tabButton.Ico
				local Icon2 = TabConfig.Icon
				local notificationIcon2

				if icons[Icon2] == nil then
					notificationIcon2 = nil
				else
					notificationIcon2 = icons[Icon2]
				end

				Ico.Image = notificationIcon2
			end

			local divider3 = AddThemeObject(SetChildren(SetProperties(NewElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 5), {
				Size = UDim2.new(1, -150, 1, -50),
				Position = UDim2.new(0, 150, 0, 50),
				Parent = main,
				Visible = false,
				Name = "ItemContainer"
			}), { NewElement("List", 0, 6), NewElement("Padding", 15, 10, 10, 15) }), "Divider")
			local signal2 = divider3.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize")

			local function onTabSelected()
				divider3.CanvasSize = UDim2.new(0, 0, 0, divider3.UIListLayout.AbsoluteContentSize.Y + 30)
			end

			if Orion:IsRunning() then
				local connection = signal2:Connect(onTabSelected)
				local Connections = Orion.Connections

				table.insert(Connections, connection)
			end

			tabButton.Ico.ImageTransparency = 0
			tabButton.Title.TextTransparency = 0
			tabButton.Title.Font = Enum.Font.GothamBlack
			divider3.Visible = true

			local MouseButton1Click = tabButton.MouseButton1Click

			local function onTabHover()
				local next_ = next
				local children, key = divider:GetChildren()

				while true do
					local notifValue

					key, notifValue = next_(children, key)

					if not key then
						break
					end

					if notifValue:IsA("TextButton") then
						notifValue.Title.Font = Enum.Font.GothamSemibold
						TweenService:Create(notifValue.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							ImageTransparency = 0.4
						}):Play()
						TweenService:Create(notifValue.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							TextTransparency = 0.4
						}):Play()
					end
				end

				local next_2 = next
				local children2, key2 = main:GetChildren()

				while true do
					local closeConnValue

					key2, closeConnValue = next_2(children2, key2)

					if not key2 then
						break
					end

					if closeConnValue.Name == "ItemContainer" then
						closeConnValue.Visible = false
					end
				end

				TweenService:Create(tabButton.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					ImageTransparency = 0
				}):Play()
				TweenService:Create(tabButton.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					TextTransparency = 0
				}):Play()
				tabButton.Title.Font = Enum.Font.GothamBlack
				divider3.Visible = true
			end

			if Orion:IsRunning() then
				local connection = MouseButton1Click:Connect(onTabHover)
				local Connections = Orion.Connections

				table.insert(Connections, connection)
			end

			local function getChildren(childElement)
				return {
					AddLabel = function(_, text)
						local addThemeFn3 = AddThemeObject
						local RoundFrame = NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5)
						local tabChildrenList = {
							Size = UDim2.new(1, 0, 0, 30),
							BackgroundTransparency = 0.7,
							Parent = childElement
						}

						table.foreach(tabChildrenList, function(key, value)
							RoundFrame[key] = value
						end)

						local addThemeFn4 = AddThemeObject
						local Label2 = NewElement("Label", text, 15)
						local titleChildren = {
							Size = UDim2.new(1, -12, 1, 0),
							Position = UDim2.new(0, 12, 0, 0),
							Font = Enum.Font.GothamBold,
							Name = "Content"
						}

						table.foreach(titleChildren, function(key, value)
							Label2[key] = value
						end)

						local tabButtonProps = { addThemeFn4(Label2, "Text"), AddThemeObject(NewElement("Stroke"), "Stroke") }

						table.foreach(tabButtonProps, function(_, tabProp)
							tabProp.Parent = RoundFrame
						end)

						local second4 = addThemeFn3(RoundFrame, "Second")
						local labelContent = nil

						local function set(_, newText)
							labelContent.Content.Text = newText
						end

						labelContent = second4

						local labelProps = {
							Set = set
						}

						return labelProps
					end,
					AddParagraph = function(_, sectionTitle, sectionContent)
						local text2 = sectionContent or "Content"
						local addThemeFn5 = AddThemeObject
						local RoundFrame = NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5)
						local contentProps = {
							Size = UDim2.new(1, 0, 0, 30),
							BackgroundTransparency = 0.7,
							Parent = childElement
						}

						table.foreach(contentProps, function(key, value)
							RoundFrame[key] = value
						end)

						local text3 = AddThemeObject(SetProperties(NewElement("Label", sectionTitle or "Text", 15), {
							Size = UDim2.new(1, -12, 0, 14),
							Position = UDim2.new(0, 12, 0, 10),
							Font = Enum.Font.GothamBold,
							Name = "Title"
						}), "Text")
						local addThemeFn6 = AddThemeObject
						local Label2 = NewElement("Label", "", 13)
						local sectionProps = {
							Size = UDim2.new(1, -24, 0, 0),
							Position = UDim2.new(0, 12, 0, 26),
							Font = Enum.Font.GothamSemibold,
							Name = "Content",
							TextWrapped = true
						}

						table.foreach(sectionProps, function(key, value)
							Label2[key] = value
						end)

						local labelChildren = { text3, addThemeFn6(Label2, "TextDark"), AddThemeObject(NewElement("Stroke"), "Stroke") }

						table.foreach(labelChildren, function(_, labelChild)
							labelChild.Parent = RoundFrame
						end)

						local second4 = addThemeFn5(RoundFrame, "Second")
						local signal3 = second4.Content:GetPropertyChangedSignal("Text")

						local function onToggleRender()
							second4.Content.Size = UDim2.new(1, -24, 0, second4.Content.TextBounds.Y)
							second4.Size = UDim2.new(1, 0, 0, second4.Content.TextBounds.Y + 35)
						end

						if Orion:IsRunning() then
							local connection = signal3:Connect(onToggleRender)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						second4.Content.Text = text2

						return {
							Set = function(_, newText)
								second4.Content.Text = newText
							end
						}
					end,
					AddButton = function(_, toggleConfig)
						local ToggleConfig = toggleConfig or {}

						ToggleConfig.Name = ToggleConfig.Name or "Button"
						ToggleConfig.Callback = ToggleConfig.Callback or function() end
						ToggleConfig.Icon = ToggleConfig.Icon or "rbxassetid://3944703587"

						local toggleChildren = {}
						local toggleButton = SetProperties(NewElement("Button"), {
							Size = UDim2.new(1, 0, 1, 0)
						})
						local addThemeFn7 = AddThemeObject
						local setChildrenFn4 = SetChildren
						local RoundFrame = NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5)
						local toggleVisual = {
							Size = UDim2.new(1, 0, 0, 33),
							Parent = childElement
						}

						table.foreach(toggleVisual, function(key, value)
							RoundFrame[key] = value
						end)

						local second4 = addThemeFn7(setChildrenFn4(RoundFrame, {
							AddThemeObject(SetProperties(NewElement("Label", ToggleConfig.Name, 15), {
								Size = UDim2.new(1, -12, 1, 0),
								Position = UDim2.new(0, 12, 0, 0),
								Font = Enum.Font.GothamBold,
								Name = "Content"
							}), "Text"),
							AddThemeObject(SetProperties(NewElement("Image", ToggleConfig.Icon), {
								Size = UDim2.new(0, 20, 0, 20),
								Position = UDim2.new(1, -30, 0, 7)
							}), "TextDark"),
							AddThemeObject(NewElement("Stroke"), "Stroke"),
							toggleButton
						}), "Second")
						local MouseEnter = toggleButton.MouseEnter

						local function onToggleClick()
							local tweenService = TweenService
							local tweenService2 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local color3 = Color3.fromRGB
							local secondRed = Orion.Themes[Orion.SelectedTheme].Second.R * 255 + 3
							local currentTheme = Orion.Themes[Orion.SelectedTheme]

							tweenService.Create(tweenService, tweenService2, tweenInfo, {
								BackgroundColor3 = color3(secondRed, currentTheme.Second.G * 255 + 3, Orion.Themes[Orion.SelectedTheme].Second.B * 255 + 3)
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = MouseEnter:Connect(onToggleClick)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseLeave = toggleButton.MouseLeave

						local function onToggleChanged()
							local tweenService = TweenService
							local tweenService2 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local currentTheme = Orion.Themes[Orion.SelectedTheme]

							tweenService.Create(tweenService, tweenService2, tweenInfo, {
								BackgroundColor3 = currentTheme.Second
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = MouseLeave:Connect(onToggleChanged)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseButton1Up3 = toggleButton.MouseButton1Up

						local function onToggleHover()
							local tweenService = TweenService
							local tweenService2 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local color3 = Color3.fromRGB
							local secondRed = Orion.Themes[Orion.SelectedTheme].Second.R * 255 + 3
							local secondGreen = Orion.Themes[Orion.SelectedTheme].Second.G * 255 + 3
							local Themes = Orion.Themes
							local orionRef2 = Orion
							local openTween = tweenService.Create(tweenService, tweenService2, tweenInfo, {
								BackgroundColor3 = color3(secondRed, secondGreen, Themes[orionRef2.SelectedTheme].Second.B * 255 + 3)
							})

							local function onTogglePress()
								ToggleConfig.Callback()
							end

							openTween.Play(openTween)
							spawn(onTogglePress)
						end

						if Orion:IsRunning() then
							local connection = MouseButton1Up3:Connect(onToggleHover)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseButton1Down = toggleButton.MouseButton1Down

						local function onToggleRelease()
							TweenService:Create(second4, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
								BackgroundColor3 = Color3.fromRGB(Orion.Themes[Orion.SelectedTheme].Second.R * 255 + 6, Orion.Themes[Orion.SelectedTheme].Second.G * 255 + 6, Orion.Themes[Orion.SelectedTheme].Second.B * 255 + 6)
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = MouseButton1Down:Connect(onToggleRelease)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						function toggleChildren.Set(_, toggleValue)
							second4.Content.Text = toggleValue
						end

						return toggleChildren
					end,
					AddToggle = function(_, colorpickerConfig)
						local ColorpickerConfig = colorpickerConfig or {}

						ColorpickerConfig.Name = ColorpickerConfig.Name or "Toggle"
						ColorpickerConfig.Default = ColorpickerConfig.Default or false
						ColorpickerConfig.Callback = ColorpickerConfig.Callback or function() end
						ColorpickerConfig.Color = ColorpickerConfig.Color or Color3.fromRGB(9, 99, 195)
						ColorpickerConfig.Flag = ColorpickerConfig.Flag or nil
						ColorpickerConfig.Save = ColorpickerConfig.Save or false

						local colorpickerChildren = {
							Value = ColorpickerConfig.Default,
							Save = ColorpickerConfig.Save
						}
						local colorButton = SetProperties(NewElement("Button"), {
							Size = UDim2.new(1, 0, 1, 0)
						})
						local colorFrame = SetChildren(SetProperties(NewElement("RoundFrame", ColorpickerConfig.Color, 0, 4), {
							Size = UDim2.new(0, 24, 0, 24),
							Position = UDim2.new(1, -24, 0.5, 0),
							AnchorPoint = Vector2.new(0.5, 0.5)
						}), { SetProperties(NewElement("Stroke"), {
								Color = ColorpickerConfig.Color,
								Name = "Stroke",
								Transparency = 0.5
							}), SetProperties(NewElement("Image", "rbxassetid://3944680095"), {
								Size = UDim2.new(0, 20, 0, 20),
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.new(0.5, 0, 0.5, 0),
								ImageColor3 = Color3.fromRGB(255, 255, 255),
								Name = "Ico"
							}) })
						local second4 = AddThemeObject(SetChildren(SetProperties(NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
							Size = UDim2.new(1, 0, 0, 38),
							Parent = childElement
						}), {
							AddThemeObject(SetProperties(NewElement("Label", ColorpickerConfig.Name, 15), {
								Size = UDim2.new(1, -12, 1, 0),
								Position = UDim2.new(0, 12, 0, 0),
								Font = Enum.Font.GothamBold,
								Name = "Content"
							}), "Text"),
							AddThemeObject(NewElement("Stroke"), "Stroke"),
							colorFrame,
							colorButton
						}), "Second")

						function colorpickerChildren.Set(_, colorpickerValue)
							colorpickerChildren.Value = colorpickerValue

							local tweenService = TweenService
							local colorFrameRef = colorFrame
							local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local Value_ = colorpickerChildren.Value

							if Value_ then
								Value_ = ColorpickerConfig.Color
							end

							tweenService:Create(colorFrameRef, tweenInfo, {
								BackgroundColor3 = Value_ or Orion.Themes.Default.Divider
							}):Play()

							local tweenService = TweenService
							local Stroke = colorFrame.Stroke
							local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local Value_2 = colorpickerChildren.Value

							if Value_2 then
								Value_2 = ColorpickerConfig.Color
							end

							tweenService:Create(Stroke, tweenInfo2, {
								Color = Value_2 or Orion.Themes.Default.Stroke
							}):Play()

							local tweenService = TweenService
							local Ico = colorFrame.Ico
							local tweenInfo3 = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local strokeTrans = colorpickerChildren.Value and 0 or 1
							local Value_3 = colorpickerChildren.Value

							if not Value_3 then
								tweenService:Create(Ico, tweenInfo3, {
									ImageTransparency = strokeTrans,
									Size = Value_3 or UDim2.new(0, 8, 0, 8)
								}):Play()
								ColorpickerConfig.Callback(colorpickerChildren.Value)

								return
							end

							Value_3 = UDim2.new(0, 20, 0, 20)
							tweenService:Create(Ico, tweenInfo3, {
								ImageTransparency = strokeTrans,
								Size = Value_3 or UDim2.new(0, 8, 0, 8)
							}):Play()
							ColorpickerConfig.Callback(colorpickerChildren.Value)
						end

						colorpickerChildren:Set(colorpickerChildren.Value)

						local MouseEnter = colorButton.MouseEnter

						local function onColorRender()
							local tweenService = TweenService
							local tweenService2 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local color3 = Color3.fromRGB
							local secondRed = Orion.Themes[Orion.SelectedTheme].Second.R * 255 + 3

							tweenService.Create(tweenService, tweenService2, tweenInfo, {
								BackgroundColor3 = color3(secondRed, Orion.Themes[Orion.SelectedTheme].Second.G * 255 + 3, Orion.Themes[Orion.SelectedTheme].Second.B * 255 + 3)
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = MouseEnter:Connect(onColorRender)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseLeave = colorButton.MouseLeave

						local function onColorClick()
							TweenService:Create(second4, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
								BackgroundColor3 = Orion.Themes[Orion.SelectedTheme].Second
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = MouseLeave:Connect(onColorClick)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseButton1Up3 = colorButton.MouseButton1Up

						local function onColorHover()
							local tweenService = TweenService
							local tweenService2 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local color3 = Color3.fromRGB
							local secondRed = Orion.Themes[Orion.SelectedTheme].Second.R * 255 + 3
							local secondGreen = Orion.Themes[Orion.SelectedTheme].Second.G * 255 + 3
							local orionRef3 = Orion

							tweenService.Create(tweenService, tweenService2, tweenInfo, {
								BackgroundColor3 = color3(secondRed, secondGreen, orionRef3.Themes[Orion.SelectedTheme].Second.B * 255 + 3)
							}):Play()
							SaveConfig(game.GameId)
							colorpickerChildren:Set(not colorpickerChildren.Value)
						end

						if Orion:IsRunning() then
							local connection = MouseButton1Up3:Connect(onColorHover)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseButton1Down = colorButton.MouseButton1Down

						local function onColorChanged()
							local tweenService = TweenService
							local tweenService2 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local color3 = Color3.fromRGB
							local Second = Orion.Themes[Orion.SelectedTheme].Second

							tweenService.Create(tweenService, tweenService2, tweenInfo, {
								BackgroundColor3 = color3(Second.R * 255 + 6, Orion.Themes[Orion.SelectedTheme].Second.G * 255 + 6, Orion.Themes[Orion.SelectedTheme].Second.B * 255 + 6)
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = MouseButton1Down:Connect(onColorChanged)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						if not ColorpickerConfig.Flag then
							return colorpickerChildren
						end

						Orion.Flags[ColorpickerConfig.Flag] = colorpickerChildren

						return colorpickerChildren
					end,
					AddSlider = function(_, sliderConfig)
						local SliderConfig = sliderConfig or {}

						SliderConfig.Name = SliderConfig.Name or "Slider"
						SliderConfig.Min = SliderConfig.Min or 0
						SliderConfig.Max = SliderConfig.Max or 100
						SliderConfig.Increment = SliderConfig.Increment or 1
						SliderConfig.Default = SliderConfig.Default or 50
						SliderConfig.Callback = SliderConfig.Callback or function() end
						SliderConfig.ValueName = SliderConfig.ValueName or ""
						SliderConfig.Color = SliderConfig.Color or Color3.fromRGB(9, 149, 98)
						SliderConfig.Flag = SliderConfig.Flag or nil
						SliderConfig.Save = SliderConfig.Save or false

						local sliderChildren = {
							Value = SliderConfig.Default,
							Save = SliderConfig.Save
						}
						local isDragging = false
						local sliderBar = SetChildren(SetProperties(NewElement("RoundFrame", SliderConfig.Color, 0, 5), {
							Size = UDim2.new(0, 0, 1, 0),
							BackgroundTransparency = 0.3,
							ClipsDescendants = true
						}), { AddThemeObject(SetProperties(NewElement("Label", "value", 13), {
								Size = UDim2.new(1, -12, 0, 14),
								Position = UDim2.new(0, 12, 0, 6),
								Font = Enum.Font.GothamBold,
								Name = "Value",
								TextTransparency = 0
							}), "Text") })
						local sliderFill = SetChildren(SetProperties(NewElement("RoundFrame", SliderConfig.Color, 0, 5), {
							Size = UDim2.new(1, -24, 0, 26),
							Position = UDim2.new(0, 12, 0, 30),
							BackgroundTransparency = 0.9
						}), { SetProperties(NewElement("Stroke"), {
								Color = SliderConfig.Color
							}), AddThemeObject(SetProperties(NewElement("Label", "value", 13), {
								Size = UDim2.new(1, -12, 0, 14),
								Position = UDim2.new(0, 12, 0, 6),
								Font = Enum.Font.GothamBold,
								Name = "Value",
								TextTransparency = 0.8
							}), "Text"), sliderBar })

						AddThemeObject(SetChildren(SetProperties(NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
							Size = UDim2.new(1, 0, 0, 65),
							Parent = childElement
						}), { AddThemeObject(SetProperties(NewElement("Label", SliderConfig.Name, 15), {
								Size = UDim2.new(1, -12, 0, 14),
								Position = UDim2.new(0, 12, 0, 10),
								Font = Enum.Font.GothamBold,
								Name = "Content"
							}), "Text"), AddThemeObject(NewElement("Stroke"), "Stroke"), sliderFill }), "Second")
						sliderFill.InputBegan:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
								return
							end

							isDragging = true
						end)
						sliderFill.InputEnded:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
								return
							end

							isDragging = false
						end)
						UserInputService.InputChanged:Connect(function(input)
							local isDragging2 = isDragging

							if isDragging2 then
								isDragging2 = input.UserInputType == Enum.UserInputType.MouseMovement
							end

							if not isDragging2 then
								return
							end

							local rawValue = (input.Position.X - sliderFill.AbsolutePosition.X) / sliderFill.AbsoluteSize.X
							local clampedValue = math.clamp(rawValue, 0, 1)

							sliderChildren:Set(SliderConfig.Min + (SliderConfig.Max - SliderConfig.Min) * clampedValue)
							SaveConfig(game.GameId)
						end)

						function sliderChildren.Set(sliderSelf, sliderValue)
							sliderSelf.Value = math.clamp(RoundToIncrement(sliderValue, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)

							local tweenService = TweenService
							local sliderBarRef = sliderBar
							local tweenInfoNew = TweenInfo.new
							local Quad = Enum.EasingStyle.Quad
							local Enum_ = Enum

							tweenService.Create(tweenService, sliderBarRef, tweenInfoNew(0.15, Quad, Enum_.EasingDirection.Out), {
								Size = UDim2.fromScale((sliderSelf.Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 1)
							}):Play()

							local Value_ = sliderFill.Value
							local Value_2 = sliderSelf.Value

							Value_.Text = tostring(Value_2) .. " " .. SliderConfig.ValueName

							local Value_3 = sliderBar.Value
							local Value_4 = sliderSelf.Value

							Value_3.Text = tostring(Value_4) .. " " .. SliderConfig.ValueName
							SliderConfig.Callback(sliderSelf.Value)
						end

						sliderChildren:Set(sliderChildren.Value)

						if not SliderConfig.Flag then
							return sliderChildren
						end

						Orion.Flags[SliderConfig.Flag] = sliderChildren

						return sliderChildren
					end,
					AddDropdown = function(_, dropdownConfig)
						local DropdownConfig = dropdownConfig or {}

						DropdownConfig.Name = DropdownConfig.Name or "Dropdown"
						DropdownConfig.Options = DropdownConfig.Options or {}
						DropdownConfig.Default = DropdownConfig.Default or ""
						DropdownConfig.Callback = DropdownConfig.Callback or function() end
						DropdownConfig.Flag = DropdownConfig.Flag or nil
						DropdownConfig.Save = DropdownConfig.Save or false

						local dropdownChildren = {
							Value = DropdownConfig.Default,
							Options = DropdownConfig.Options,
							Buttons = {},
							Toggled = false,
							Type = "Dropdown",
							Save = DropdownConfig.Save
						}

						if not table.find(dropdownChildren.Options, dropdownChildren.Value) then
							dropdownChildren.Value = "..."
						end

						local List = NewElement("List")
						local addThemeFn8 = AddThemeObject
						local setPropsFn2 = SetProperties
						local ScrollFrame = NewElement("ScrollFrame", Color3.fromRGB(40, 40, 40), 4)

						table.foreach({ List }, function(_, listItem)
							listItem.Parent = ScrollFrame
						end)

						local divider4 = addThemeFn8(setPropsFn2(ScrollFrame, {
							Parent = childElement,
							Position = UDim2.new(0, 0, 0, 38),
							Size = UDim2.new(1, 0, 1, -38),
							ClipsDescendants = true
						}), "Divider")
						local dropdownButton = SetProperties(NewElement("Button"), {
							Size = UDim2.new(1, 0, 1, 0)
						})
						local second4 = AddThemeObject(SetChildren(SetProperties(NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
							Size = UDim2.new(1, 0, 0, 38),
							Parent = childElement,
							ClipsDescendants = true
						}), {
							divider4,
							SetProperties(SetChildren(NewElement("TFrame"), {
								AddThemeObject(SetProperties(NewElement("Label", DropdownConfig.Name, 15), {
									Size = UDim2.new(1, -12, 1, 0),
									Position = UDim2.new(0, 12, 0, 0),
									Font = Enum.Font.GothamBold,
									Name = "Content"
								}), "Text"),
								AddThemeObject(SetProperties(NewElement("Image", "rbxassetid://7072706796"), {
									Size = UDim2.new(0, 20, 0, 20),
									AnchorPoint = Vector2.new(0, 0.5),
									Position = UDim2.new(1, -30, 0.5, 0),
									ImageColor3 = Color3.fromRGB(240, 240, 240),
									Name = "Ico"
								}), "TextDark"),
								AddThemeObject(SetProperties(NewElement("Label", "Selected", 13), {
									Size = UDim2.new(1, -40, 1, 0),
									Font = Enum.Font.Gotham,
									Name = "Selected",
									TextXAlignment = Enum.TextXAlignment.Right
								}), "TextDark"),
								AddThemeObject(SetProperties(NewElement("Frame"), {
									Size = UDim2.new(1, 0, 0, 1),
									Position = UDim2.new(0, 0, 1, -1),
									Name = "Line",
									Visible = false
								}), "Stroke"),
								dropdownButton
							}), {
								Size = UDim2.new(1, 0, 0, 38),
								ClipsDescendants = true,
								Name = "F"
							}),
							AddThemeObject(NewElement("Stroke"), "Stroke"),
							NewElement("Corner")
						}), "Second")
						local signal3 = List:GetPropertyChangedSignal("AbsoluteContentSize")

						local function onDropdownRender()
							divider4.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y)
						end

						if Orion:IsRunning() then
							local connection = signal3:Connect(onDropdownRender)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local function onDropdownClick(dropdownInput)
							for _, v in pairs(dropdownInput) do
								local divider5 = AddThemeObject(SetProperties(SetChildren(NewElement("Button", Color3.fromRGB(40, 40, 40)), { NewElement("Corner", 0, 6), AddThemeObject(SetProperties(NewElement("Label", v, 13, 0.4), {
										Position = UDim2.new(0, 8, 0, 0),
										Size = UDim2.new(1, -8, 1, 0),
										Name = "Title"
									}), "Text") }), {
									Parent = divider4,
									Size = UDim2.new(1, 0, 0, 28),
									BackgroundTransparency = 1,
									ClipsDescendants = true
								}), "Divider")
								local MouseButton1Click2 = divider5.MouseButton1Click

								local function onDropdownChanged()
									dropdownChildren:Set(v)
									SaveConfig(game.GameId)
								end

								if Orion:IsRunning() then
									local connection = MouseButton1Click2:Connect(onDropdownChanged)
									local Connections = Orion.Connections

									table.insert(Connections, connection)
								end

								dropdownChildren.Buttons[v] = divider5
							end
						end

						function dropdownChildren.Refresh(_, newList, newDefault)
							if not newDefault then
								dropdownChildren.Options = newList
								onDropdownClick(dropdownChildren.Options)

								return
							end

							for _, button in pairs(dropdownChildren.Buttons) do
								button:Destroy()
							end

							table.clear(dropdownChildren.Options)
							table.clear(dropdownChildren.Buttons)
							dropdownChildren.Options = newList
							onDropdownClick(dropdownChildren.Options)
						end
						function dropdownChildren.Set(_, dropdownValue)
							if table.find(dropdownChildren.Options, dropdownValue) then
								dropdownChildren.Value = dropdownValue
								second4.F.Selected.Text = dropdownChildren.Value

								for _, button in pairs(dropdownChildren.Buttons) do
									local tweenService = TweenService
									local tweenInfoNew = TweenInfo.new
									local Quad = Enum.EasingStyle.Quad
									local EasingDirection = Enum.EasingDirection

									tweenService.Create(tweenService, button, tweenInfoNew(0.15, Quad, EasingDirection.Out), {
										BackgroundTransparency = 1
									}):Play()
									TweenService:Create(button.Title, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
										TextTransparency = 0.4
									}):Play()
								end

								TweenService:Create(dropdownChildren.Buttons[dropdownValue], TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
									BackgroundTransparency = 0
								}):Play()
								TweenService:Create(dropdownChildren.Buttons[dropdownValue].Title, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
									TextTransparency = 0
								}):Play()

								return DropdownConfig.Callback(dropdownChildren.Value)
							else
								dropdownChildren.Value = "..."
								second4.F.Selected.Text = dropdownChildren.Value

								for _, button in pairs(dropdownChildren.Buttons) do
									TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
										BackgroundTransparency = 1
									}):Play()
									TweenService:Create(button.Title, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
										TextTransparency = 0.4
									}):Play()
								end
							end
						end

						AddConnection(dropdownButton.MouseButton1Click, function()
							dropdownChildren.Toggled = not dropdownChildren.Toggled
							second4.F.Line.Visible = dropdownChildren.Toggled

							local tweenService = TweenService
							local Ico = second4.F.Ico
							local tweenInfoNew = TweenInfo.new
							local Enum_ = Enum

							tweenService.Create(tweenService, Ico, tweenInfoNew(0.15, Enum_.EasingStyle.Quad, Enum.EasingDirection.Out), {
								Rotation = dropdownChildren.Toggled and 180 or 0
							}):Play()

							if #dropdownChildren.Options > 5 then
								local tweenService = TweenService
								local tweenService2 = second4
								local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
								local s1 = "Size"
								local Toggled = dropdownChildren.Toggled

								if not Toggled then
									tweenService:Create(tweenService2, tweenInfo, {
										[s1] = Toggled or UDim2.new(1, 0, 0, 38)
									}):Play()

									return
								end

								Toggled = UDim2.new(1, 0, 0, 178)
								tweenService:Create(tweenService2, tweenInfo, {
									[s1] = Toggled or UDim2.new(1, 0, 0, 38)
								}):Play()
							else
								local tweenService = TweenService
								local tweenService2 = second4
								local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
								local s2 = "Size"
								local Toggled = dropdownChildren.Toggled

								if not Toggled then
									tweenService:Create(tweenService2, tweenInfo, {
										[s2] = Toggled or UDim2.new(1, 0, 0, 38)
									}):Play()

									return
								end

								Toggled = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y + 38)
								tweenService:Create(tweenService2, tweenInfo, {
									[s2] = Toggled or UDim2.new(1, 0, 0, 38)
								}):Play()
							end
						end)
						dropdownChildren:Refresh(dropdownChildren.Options, false)
						dropdownChildren:Set(dropdownChildren.Value)

						if not DropdownConfig.Flag then
							return dropdownChildren
						end

						Orion.Flags[DropdownConfig.Flag] = dropdownChildren

						return dropdownChildren
					end,
					AddBind = function(_, bindConfig)
						bindConfig.Name = bindConfig.Name or "Bind"
						bindConfig.Default = bindConfig.Default or Enum.KeyCode.Unknown
						bindConfig.Hold = bindConfig.Hold or false
						bindConfig.Callback = bindConfig.Callback or function() end
						bindConfig.Flag = bindConfig.Flag or nil
						bindConfig.Save = bindConfig.Save or false

						local bindChildren = {
							Value = nil,
							Binding = false,
							Type = "Bind",
							Save = bindConfig.Save
						}
						local isHolding = false
						local bindButton = SetProperties(NewElement("Button"), {
							Size = UDim2.new(1, 0, 1, 0)
						})
						local main2 = AddThemeObject(SetChildren(SetProperties(NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
							Size = UDim2.new(0, 24, 0, 24),
							Position = UDim2.new(1, -12, 0.5, 0),
							AnchorPoint = Vector2.new(1, 0.5)
						}), { AddThemeObject(NewElement("Stroke"), "Stroke"), AddThemeObject(SetProperties(NewElement("Label", bindConfig.Name, 14), {
								Size = UDim2.new(1, 0, 1, 0),
								Font = Enum.Font.GothamBold,
								TextXAlignment = Enum.TextXAlignment.Center,
								Name = "Value"
							}), "Text") }), "Main")
						local addThemeFn9 = AddThemeObject
						local bindFrame = SetProperties(NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
							Size = UDim2.new(1, 0, 0, 38),
							Parent = childElement
						})
						local bindVisual = {
							AddThemeObject(SetProperties(NewElement("Label", bindConfig.Name, 15), {
								Size = UDim2.new(1, -12, 1, 0),
								Position = UDim2.new(0, 12, 0, 0),
								Font = Enum.Font.GothamBold,
								Name = "Content"
							}), "Text"),
							AddThemeObject(NewElement("Stroke"), "Stroke"),
							main2,
							bindButton
						}

						table.foreach(bindVisual, function(_, bindChild)
							bindChild.Parent = bindFrame
						end)

						local second4 = addThemeFn9(bindFrame, "Second")
						local signal3 = main2.Value:GetPropertyChangedSignal("Text")

						local function onBindRender()
							local tweenService = TweenService
							local parentElement = main2
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

							tweenService.Create(tweenService, parentElement, tweenInfo, {
								Size = UDim2.new(0, main2.Value.TextBounds.X + 16, 0, 24)
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = signal3:Connect(onBindRender)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local InputEnded = bindButton.InputEnded

						local function onBindClick(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
								return
							end

							if bindChildren.Binding then
								return
							end

							bindChildren.Binding = true
							main2.Value.Text = ""
						end

						if Orion:IsRunning() then
							local connection = InputEnded:Connect(onBindClick)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local InputBegan2 = UserInputService.InputBegan

						local function onKeyPressed(input)
							if UserInputService:GetFocusedTextBox() then
								return
							end

							local isKeyMatch = input.KeyCode.Name == bindChildren.Value or input.UserInputType.Name == bindChildren.Value

							if isKeyMatch then
								isKeyMatch = not bindChildren.Binding
							end

							if isKeyMatch then
								if bindConfig.Hold then
									isHolding = true
									bindConfig.Callback(isHolding)

									return
								else
									bindConfig.Callback()

									return
								end
							end

							if not bindChildren.Binding then
								return
							end

							local KeyCode = nil

							local function onKeyHeld()
								if IsInList(IgnoredKeys, input.KeyCode) then
									return
								end

								KeyCode = input.KeyCode
							end

							KeyCode = nil
							pcall(onKeyHeld)

							local function onKeyReleased()
								local isMouseInput = IsInList(MouseInputTypes, input.UserInputType)

								if isMouseInput then
									isMouseInput = not KeyCode
								end

								if not isMouseInput then
									return
								end

								KeyCode = input.UserInputType
							end

							pcall(onKeyReleased)
							KeyCode = KeyCode or bindChildren.Value
							bindChildren:Set(KeyCode)
							SaveConfig(game.GameId)
						end

						if Orion:IsRunning() then
							local connection = InputBegan2:Connect(onKeyPressed)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local InputEnded2 = UserInputService.InputEnded

						local function onBindChanged(newBindValue)
							if not (newBindValue.KeyCode.Name == bindChildren.Value or newBindValue.UserInputType.Name == bindChildren.Value) then
								return
							end

							local Hold = bindConfig.Hold

							if Hold then
								Hold = isHolding
							end

							if not Hold then
								return
							end

							isHolding = false
							bindConfig.Callback(isHolding)
						end

						if Orion:IsRunning() then
							local connection = InputEnded2:Connect(onBindChanged)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseEnter = bindButton.MouseEnter

						local function onBindHover()
							local tweenService = TweenService
							local tweenService2 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local color3 = Color3.fromRGB
							local secondRed = Orion.Themes[Orion.SelectedTheme].Second.R * 255 + 3
							local secondGreen = Orion.Themes[Orion.SelectedTheme].Second.G * 255 + 3
							local secondBlue = Orion.Themes[Orion.SelectedTheme].Second.B * 255

							tweenService.Create(tweenService, tweenService2, tweenInfo, {
								BackgroundColor3 = color3(secondRed, secondGreen, secondBlue + 3)
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = MouseEnter:Connect(onBindHover)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseLeave = bindButton.MouseLeave

						local function onBindPress()
							local tweenService = TweenService
							local tweenService2 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local Themes = Orion.Themes
							local orionRef4 = Orion

							tweenService.Create(tweenService, tweenService2, tweenInfo, {
								BackgroundColor3 = Themes[orionRef4.SelectedTheme].Second
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = MouseLeave:Connect(onBindPress)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseButton1Up3 = bindButton.MouseButton1Up

						local function onBindRelease()
							local tweenService = TweenService
							local tweenService2 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local color3 = Color3.fromRGB
							local secondRed = Orion.Themes[Orion.SelectedTheme].Second.R * 255 + 3
							local Themes = Orion.Themes
							local orionRef5 = Orion

							tweenService.Create(tweenService, tweenService2, tweenInfo, {
								BackgroundColor3 = color3(secondRed, Themes[orionRef5.SelectedTheme].Second.G * 255 + 3, Orion.Themes[Orion.SelectedTheme].Second.B * 255 + 3)
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = MouseButton1Up3:Connect(onBindRelease)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseButton1Down = bindButton.MouseButton1Down

						local function onBindFocusLost()
							local tweenService = TweenService
							local tweenService2 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local Color3_ = Color3

							tweenService.Create(tweenService, tweenService2, tweenInfo, {
								BackgroundColor3 = Color3_.fromRGB(Orion.Themes[Orion.SelectedTheme].Second.R * 255 + 6, Orion.Themes[Orion.SelectedTheme].Second.G * 255 + 6, Orion.Themes[Orion.SelectedTheme].Second.B * 255 + 6)
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = MouseButton1Down:Connect(onBindFocusLost)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						function bindChildren.Set(_, bindValue)
							bindChildren.Binding = false
							bindChildren.Value = bindValue or bindChildren.Value
							bindChildren.Value = bindChildren.Value.Name or bindChildren.Value
							main2.Value.Text = bindChildren.Value
						end

						bindChildren:Set(bindConfig.Default)

						if not bindConfig.Flag then
							return bindChildren
						end

						Orion.Flags[bindConfig.Flag] = bindChildren

						return bindChildren
					end,
					AddTextbox = function(_, textboxConfig)
						local TextboxConfig = textboxConfig or {}

						TextboxConfig.Name = TextboxConfig.Name or "Textbox"
						TextboxConfig.Default = TextboxConfig.Default or ""
						TextboxConfig.TextDisappear = TextboxConfig.TextDisappear or false
						TextboxConfig.Callback = TextboxConfig.Callback or function() end

						local textboxButton = SetProperties(NewElement("Button"), {
							Size = UDim2.new(1, 0, 1, 0)
						})
						local text2 = AddThemeObject(CreateInstance("TextBox", {
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							TextColor3 = Color3.fromRGB(255, 255, 255),
							PlaceholderColor3 = Color3.fromRGB(210, 210, 210),
							PlaceholderText = "数字",
							Font = Enum.Font.GothamSemibold,
							TextXAlignment = Enum.TextXAlignment.Center,
							TextSize = 14,
							ClearTextOnFocus = false
						}), "Text")
						local main2 = AddThemeObject(SetChildren(SetProperties(NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
							Size = UDim2.new(0, 24, 0, 24),
							Position = UDim2.new(1, -12, 0.5, 0),
							AnchorPoint = Vector2.new(1, 0.5)
						}), { AddThemeObject(NewElement("Stroke"), "Stroke"), text2 }), "Main")
						local addThemeFn10 = AddThemeObject
						local textboxFrame = SetProperties(NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
							Size = UDim2.new(1, 0, 0, 38),
							Parent = childElement
						})
						local textboxVisual = {
							AddThemeObject(SetProperties(NewElement("Label", TextboxConfig.Name, 15), {
								Size = UDim2.new(1, -12, 1, 0),
								Position = UDim2.new(0, 12, 0, 0),
								Font = Enum.Font.GothamBold,
								Name = "Content"
							}), "Text"),
							AddThemeObject(NewElement("Stroke"), "Stroke"),
							main2,
							textboxButton
						}

						table.foreach(textboxVisual, function(_, textboxChild)
							textboxChild.Parent = textboxFrame
						end)

						local second4 = addThemeFn10(textboxFrame, "Second")
						local signal3 = text2:GetPropertyChangedSignal("Text")

						local function onTextboxRender()
							local tweenService = TweenService
							local parentElement = main2
							local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local uDim2New = UDim2.new
							local TextBounds = text2.TextBounds

							tweenService.Create(tweenService, parentElement, tweenInfo, {
								Size = uDim2New(0, TextBounds.X + 16, 0, 24)
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = signal3:Connect(onTextboxRender)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local FocusLost = text2.FocusLost

						local function onTextboxChanged()
							TextboxConfig.Callback(text2.Text)

							if not TextboxConfig.TextDisappear then
								return
							end

							text2.Text = ""
						end

						if Orion:IsRunning() then
							local connection = FocusLost:Connect(onTextboxChanged)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						text2.Text = TextboxConfig.Default

						local MouseEnter = textboxButton.MouseEnter

						local function onTextboxFocus()
							local tweenService = TweenService
							local tweenService2 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local color3 = Color3.fromRGB
							local secondRed = Orion.Themes[Orion.SelectedTheme].Second.R * 255 + 3
							local secondGreen = Orion.Themes[Orion.SelectedTheme].Second.G * 255 + 3
							local currentTheme = Orion.Themes[Orion.SelectedTheme]

							tweenService.Create(tweenService, tweenService2, tweenInfo, {
								BackgroundColor3 = color3(secondRed, secondGreen, currentTheme.Second.B * 255 + 3)
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = MouseEnter:Connect(onTextboxFocus)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseLeave = textboxButton.MouseLeave

						local function onTextboxFocusLost()
							local tweenService = TweenService
							local tweenService2 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local currentTheme = Orion.Themes[Orion.SelectedTheme]

							tweenService.Create(tweenService, tweenService2, tweenInfo, {
								BackgroundColor3 = currentTheme.Second
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = MouseLeave:Connect(onTextboxFocusLost)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseButton1Up3 = textboxButton.MouseButton1Up

						local function onTextboxSubmit()
							local tweenService = TweenService
							local tweenService2 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local color3 = Color3.fromRGB
							local secondRed = Orion.Themes[Orion.SelectedTheme].Second.R * 255 + 3
							local secondGreen = Orion.Themes[Orion.SelectedTheme].Second.G * 255 + 3
							local Themes = Orion.Themes

							tweenService.Create(tweenService, tweenService2, tweenInfo, {
								BackgroundColor3 = color3(secondRed, secondGreen, Themes[Orion.SelectedTheme].Second.B * 255 + 3)
							}):Play()
							text2:CaptureFocus()
						end

						if Orion:IsRunning() then
							local connection = MouseButton1Up3:Connect(onTextboxSubmit)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseButton1Down = textboxButton.MouseButton1Down

						local function onTextboxClear()
							local tweenService = TweenService
							local tweenService2 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local color3 = Color3.fromRGB
							local secondRed = Orion.Themes[Orion.SelectedTheme].Second.R * 255 + 6
							local secondGreen = Orion.Themes[Orion.SelectedTheme].Second.G * 255 + 6
							local orionRef6 = Orion

							tweenService.Create(tweenService, tweenService2, tweenInfo, {
								BackgroundColor3 = color3(secondRed, secondGreen, orionRef6.Themes[Orion.SelectedTheme].Second.B * 255 + 6)
							}):Play()
						end

						if not Orion:IsRunning() then
							return
						end

						local connection = MouseButton1Down:Connect(onTextboxClear)
						local Connections = Orion.Connections

						table.insert(Connections, connection)
					end,
					AddColorpicker = function(_, paragraphConfig)
						local ParagraphConfig = paragraphConfig or {}

						ParagraphConfig.Name = ParagraphConfig.Name or "Colorpicker"
						ParagraphConfig.Default = ParagraphConfig.Default or Color3.fromRGB(255, 255, 255)
						ParagraphConfig.Callback = ParagraphConfig.Callback or function() end
						ParagraphConfig.Flag = ParagraphConfig.Flag or nil
						ParagraphConfig.Save = ParagraphConfig.Save or false

						local hue = 1
						local saturation = 1
						local brightness = 1
						local ColorInput, HueInput = nil, nil
						local colorpickerElements = {
							Value = ParagraphConfig.Default,
							Toggled = false,
							Type = "Colorpicker",
							Save = ParagraphConfig.Save
						}
						local ImageLabel = CreateInstance("ImageLabel", {
							Size = UDim2.new(0, 18, 0, 18),
							Position = UDim2.new(select(3, Color3.toHSV(colorpickerElements.Value))),
							ScaleType = Enum.ScaleType.Fit,
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							Image = "http://www.roblox.com/asset/?id=4805639000"
						})
						local ImageLabel2 = CreateInstance("ImageLabel", {
							Size = UDim2.new(0, 18, 0, 18),
							Position = UDim2.new(0.5, 0, 1 - select(1, Color3.toHSV(colorpickerElements.Value))),
							ScaleType = Enum.ScaleType.Fit,
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							Image = "http://www.roblox.com/asset/?id=4805639000"
						})
						local ImageLabel3 = CreateInstance("ImageLabel", {
							Size = UDim2.new(1, -25, 1, 0),
							Visible = false,
							Image = "rbxassetid://4155801252"
						}, { CreateInstance("UICorner", {
								CornerRadius = UDim.new(0, 5)
							}), ImageLabel })
						local Frame = CreateInstance("Frame", {
							Size = UDim2.new(0, 20, 1, 0),
							Position = UDim2.new(1, -20, 0, 0),
							Visible = false
						}, { CreateInstance("UIGradient", {
								Rotation = 270,
								Color = ColorSequence.new({
									ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 4)),
									ColorSequenceKeypoint.new(0.2, Color3.fromRGB(234, 255, 0)),
									ColorSequenceKeypoint.new(0.4, Color3.fromRGB(21, 255, 0)),
									ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
									ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 17, 255)),
									ColorSequenceKeypoint.new(0.9, Color3.fromRGB(255, 0, 251)),
									ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 4))
								})
							}), CreateInstance("UICorner", {
								CornerRadius = UDim.new(0, 5)
							}), ImageLabel2 })
						local Frame2 = CreateInstance("Frame", {
							Position = UDim2.new(0, 0, 0, 32),
							Size = UDim2.new(1, 0, 1, -32),
							BackgroundTransparency = 1,
							ClipsDescendants = true
						}, { Frame, ImageLabel3, CreateInstance("UIPadding", {
								PaddingLeft = UDim.new(0, 35),
								PaddingRight = UDim.new(0, 35),
								PaddingBottom = UDim.new(0, 10),
								PaddingTop = UDim.new(0, 17)
							}) })
						local colorButton2 = SetProperties(NewElement("Button"), {
							Size = UDim2.new(1, 0, 1, 0)
						})
						local main2 = AddThemeObject(SetChildren(SetProperties(NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
							Size = UDim2.new(0, 24, 0, 24),
							Position = UDim2.new(1, -12, 0.5, 0),
							AnchorPoint = Vector2.new(1, 0.5)
						}), { AddThemeObject(NewElement("Stroke"), "Stroke") }), "Main")
						local second4 = AddThemeObject(SetChildren(SetProperties(NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
							Size = UDim2.new(1, 0, 0, 38),
							Parent = childElement
						}), { SetProperties(SetChildren(NewElement("TFrame"), {
								AddThemeObject(SetProperties(NewElement("Label", ParagraphConfig.Name, 15), {
									Size = UDim2.new(1, -12, 1, 0),
									Position = UDim2.new(0, 12, 0, 0),
									Font = Enum.Font.GothamBold,
									Name = "Content"
								}), "Text"),
								main2,
								colorButton2,
								AddThemeObject(SetProperties(NewElement("Frame"), {
									Size = UDim2.new(1, 0, 0, 1),
									Position = UDim2.new(0, 0, 1, -1),
									Name = "Line",
									Visible = false
								}), "Stroke")
							}), {
								Size = UDim2.new(1, 0, 0, 38),
								ClipsDescendants = true,
								Name = "F"
							}), Frame2, AddThemeObject(NewElement("Stroke"), "Stroke") }), "Second")
						local MouseButton1Click2 = colorButton2.MouseButton1Click

						local function toggleToggled()
							colorpickerElements.Toggled = not colorpickerElements.Toggled

							local tweenService = TweenService
							local tweenService2 = second4
							local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
							local Toggled = colorpickerElements.Toggled

							if not Toggled then
								tweenService:Create(tweenService2, tweenInfo, {
									Size = Toggled or UDim2.new(1, 0, 0, 38)
								}):Play()
								ImageLabel3.Visible = colorpickerElements.Toggled
								Frame.Visible = colorpickerElements.Toggled
								second4.F.Line.Visible = colorpickerElements.Toggled

								return
							end

							Toggled = UDim2.new(1, 0, 0, 148)
							tweenService:Create(tweenService2, tweenInfo, {
								Size = Toggled or UDim2.new(1, 0, 0, 38)
							}):Play()
							ImageLabel3.Visible = colorpickerElements.Toggled
							Frame.Visible = colorpickerElements.Toggled
							second4.F.Line.Visible = colorpickerElements.Toggled
						end

						if Orion:IsRunning() then
							local connection = MouseButton1Click2:Connect(toggleToggled)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local function onSliderRender()
							main2.BackgroundColor3 = Color3.fromHSV(hue, saturation, brightness)
							ImageLabel3.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
							colorpickerElements:Set(main2.BackgroundColor3)
							ParagraphConfig.Callback(main2.BackgroundColor3)
							SaveConfig(game.GameId)
						end

						local mouseOffsetY = ImageLabel2.AbsolutePosition.Y - Frame.AbsolutePosition.Y
						local Y = Frame.AbsoluteSize.Y
						local _ = 1 - math.clamp(mouseOffsetY, 0, Y) / Frame.AbsoluteSize.Y
						local offsetX = ImageLabel.AbsolutePosition.X - ImageLabel3.AbsolutePosition.X
						local X = ImageLabel3.AbsoluteSize.X
						local _ = math.clamp(offsetX, 0, X) / ImageLabel3.AbsoluteSize.X
						local offsetY = ImageLabel.AbsolutePosition.Y - ImageLabel3.AbsolutePosition.Y
						local Y2 = ImageLabel3.AbsoluteSize.Y
						local _ = 1 - math.clamp(offsetY, 0, Y2) / ImageLabel3.AbsoluteSize.Y
						local InputBegan2 = ImageLabel3.InputBegan

						local function onSliderClick(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
								return
							end

							if ColorInput then
								ColorInput:Disconnect()
							end

							local RenderStepped = RunService.RenderStepped

							local function onSliderHover()
								local mouseX = mouse.X - ImageLabel3.AbsolutePosition.X
								local X2 = ImageLabel3.AbsoluteSize.X
								local huePosition = math.clamp(mouseX, 0, X2) / ImageLabel3.AbsoluteSize.X
								local mouseY = mouse.Y - ImageLabel3.AbsolutePosition.Y
								local Y3 = ImageLabel3.AbsoluteSize.Y
								local satPosition = math.clamp(mouseY, 0, Y3) / ImageLabel3.AbsoluteSize.Y

								ImageLabel.Position = UDim2.new(huePosition, 0, satPosition, 0)

								local _ = 1 - satPosition

								onSliderRender()
							end

							local connection

							if Orion:IsRunning() then
								connection = RenderStepped:Connect(onSliderHover)

								local Connections = Orion.Connections

								table.insert(Connections, connection)
							else
								connection = nil
							end

							ColorInput = connection
						end

						if Orion:IsRunning() then
							local connection = InputBegan2:Connect(onSliderClick)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local InputEnded = ImageLabel3.InputEnded

						local function onSliderInputBegan(input)
							if not (input.UserInputType == Enum.UserInputType.MouseButton1 and ColorInput) then
								return
							end

							ColorInput:Disconnect()
						end

						if Orion:IsRunning() then
							local connection = InputEnded:Connect(onSliderInputBegan)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local InputBegan3 = Frame.InputBegan

						local function onSliderInputChanged(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
								return
							end

							if HueInput then
								HueInput:Disconnect()
							end

							local RenderStepped = RunService.RenderStepped

							local function onSliderInputEnded()
								local mouseY2 = mouse.Y - Frame.AbsolutePosition.Y
								local Y3 = Frame.AbsoluteSize.Y
								local valPosition = math.clamp(mouseY2, 0, Y3) / Frame.AbsoluteSize.Y

								ImageLabel2.Position = UDim2.new(0.5, 0, valPosition, 0)

								local _ = 1 - valPosition

								onSliderRender()
							end

							local connection

							if Orion:IsRunning() then
								connection = RenderStepped:Connect(onSliderInputEnded)

								local Connections = Orion.Connections

								table.insert(Connections, connection)
							else
								connection = nil
							end

							HueInput = connection
						end

						if Orion:IsRunning() then
							local connection = InputBegan3:Connect(onSliderInputChanged)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local InputEnded2 = Frame.InputEnded

						local function onSliderRelease(input)
							if not (input.UserInputType == Enum.UserInputType.MouseButton1 and HueInput) then
								return
							end

							HueInput:Disconnect()
						end

						if Orion:IsRunning() then
							local connection = InputEnded2:Connect(onSliderRelease)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						function colorpickerElements.Set(_, colorValue)
							colorpickerElements.Value = colorValue
							main2.BackgroundColor3 = colorpickerElements.Value
							ParagraphConfig.Callback(colorpickerElements.Value)
						end

						colorpickerElements:Set(colorpickerElements.Value)

						if not ParagraphConfig.Flag then
							return colorpickerElements
						end

						Orion.Flags[ParagraphConfig.Flag] = colorpickerElements

						return colorpickerElements
					end
				}
			end

			local sectionListProps = {
				AddSection = function(_, sectionConfig)
					sectionConfig.Name = sectionConfig.Name or "Section"

					local setChildrenFn5 = SetChildren
					local TFrame = NewElement("TFrame")
					local notificationChildren = {
						Size = UDim2.new(1, 0, 0, 26),
						Parent = divider3
					}

					table.foreach(notificationChildren, function(key, value)
						TFrame[key] = value
					end)

					local section = setChildrenFn5(TFrame, { AddThemeObject(SetProperties(NewElement("Label", sectionConfig.Name, 14), {
							Size = UDim2.new(1, -12, 0, 16),
							Position = UDim2.new(0, 0, 0, 3),
							Font = Enum.Font.GothamSemibold
						}), "TextDark"), SetChildren(SetProperties(NewElement("TFrame"), {
							AnchorPoint = Vector2.new(0, 0),
							Size = UDim2.new(1, 0, 1, -24),
							Position = UDim2.new(0, 0, 0, 23),
							Name = "Holder"
						}), { NewElement("List", 0, 6) }) })
					local signal3 = section.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize")

					local function onSectionRender()
						section.Size = UDim2.new(1, 0, 0, section.Holder.UIListLayout.AbsoluteContentSize.Y + 31)
						section.Holder.Size = UDim2.new(1, 0, 0, section.Holder.UIListLayout.AbsoluteContentSize.Y)
					end

					local sectionValue

					if not Orion:IsRunning() then
						local nextFn = next
						local childrenList, loopState = getChildren(section.Holder)
						local childrenTbl = {}

						while true do
							loopState, sectionValue = nextFn(childrenList, loopState)

							if not loopState then
								break
							end

							childrenTbl[loopState] = sectionValue
						end

						return childrenTbl
					end

					local connection = signal3:Connect(onSectionRender)
					local Connections = Orion.Connections

					table.insert(Connections, connection)

					local next_ = next
					local getSectionChildren, key = getChildren(section.Holder)
					local newConfigData = {}

					while true do
						key, sectionValue = next_(getSectionChildren, key)

						if not key then
							break
						end

						newConfigData[key] = sectionValue
					end

					return newConfigData
				end
			}
			local next_ = next
			local serializeConfig, key = getChildren(divider3)

			while true do
				local tabValue

				key, tabValue = next_(serializeConfig, key)

				if not key then
					break
				end

				sectionListProps[key] = tabValue
			end

			local setConfigValue

			if TabConfig.PremiumOnly then
				local next_2 = next

				setConfigValue = sectionListProps

				local key2 = nil

				while true do
					local notifItemValue

					key2, notifItemValue = next_2(sectionListProps, key2)

					if not key2 then
						break
					end

					setConfigValue[key2] = function() end
				end

				divider3:FindFirstChild("UIListLayout"):Destroy()
				divider3:FindFirstChild("UIPadding"):Destroy()
				SetChildren(SetProperties(NewElement("TFrame"), {
					Size = UDim2.new(1, 0, 1, 0),
					Parent = divider3
				}), {
					AddThemeObject(SetProperties(NewElement("Image", "rbxassetid://3610239960"), {
						Size = UDim2.new(0, 18, 0, 18),
						Position = UDim2.new(0, 15, 0, 15),
						ImageTransparency = 0.4
					}), "Text"),
					AddThemeObject(SetProperties(NewElement("Label", "Unauthorised Access", 14), {
						Size = UDim2.new(1, -38, 0, 14),
						Position = UDim2.new(0, 38, 0, 18),
						TextTransparency = 0.4
					}), "Text"),
					AddThemeObject(SetProperties(NewElement("Image", "rbxassetid://4483345875"), {
						Size = UDim2.new(0, 56, 0, 56),
						Position = UDim2.new(0, 84, 0, 110)
					}), "Text"),
					AddThemeObject(SetProperties(NewElement("Label", "Premium Features", 14), {
						Size = UDim2.new(1, -150, 0, 14),
						Position = UDim2.new(0, 150, 0, 112),
						Font = Enum.Font.GothamBold
					}), "Text"),
					AddThemeObject(SetProperties(NewElement("Label", "This part of the script is locked to Sirius Premium users. Purchase Premium in the Discord server (discord.gg/sirius)", 12), {
						Size = UDim2.new(1, -200, 0, 14),
						Position = UDim2.new(0, 150, 0, 138),
						TextWrapped = true,
						TextTransparency = 0.4
					}), "Text")
				})
			else
				setConfigValue = sectionListProps
			end

			return setConfigValue
		end
	}
end
function Orion.Destroy(_)
	ScreenGui:Destroy()
end

return Orion
