

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
			Main = Color3.fromRGB(985, 25, 205),
			Second = Color3.fromRGB(362, 392, 3),
			Stroke = Color3.fromRGB(610, 6, 628),
			Divider = Color3.fromRGB(6, 680, 846),
			Text = Color3.fromRGB(290, 220, 280),
			TextDark = Color3.fromRGB(50, 150, 10)
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

local IconLoadResult = { pcall(v10) }
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

if gethui then
	for _, child in ipairs(gethui():GetChildren()) do
		local v16 = child.Name == ScreenGui.Name

		if v16 then
			v16 = child ~= ScreenGui
		end

		if v16 then
			child:Destroy()
		end
	end
else
	for _, child in ipairs(game.CoreGui:GetChildren()) do
		local v19 = child.Name == ScreenGui.Name

		if v19 then
			v19 = child ~= ScreenGui
		end

		if v19 then
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

local function AddConnection(p1, p2)
	if Orion:IsRunning() then
		local connection = p1:Connect(p2)
		local Connections = Orion.Connections

		table.insert(Connections, connection)

		return connection
	end
end
local function SetProperties(p3, p4)
	table.foreach(p4, function(p5, p6)
		p3[p5] = p6
	end)

	return p3
end

task.spawn(function()
	while Orion:IsRunning() do
		wait()
	end

	local next_ = next
	local Connections = Orion.Connections
	local key = nil

	while true do
		local v27

		key, v27 = next_(Connections, key)

		if not key then
			break
		end

		v27:Disconnect()
	end
end)

local function MakeDraggable(p7, p8)
	local v29 = nil
	local v30 = nil

	local function v31()
		local u32 = false
		local u33 = nil
		local Position = nil
		local Position2 = nil
		local InputBegan = v30.InputBegan

		local function v37(p9)
			if p9.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end

			u32 = true
			Position = p9.Position
			Position2 = v29.Position
			p9.Changed:Connect(function()
				if p9.UserInputState ~= Enum.UserInputState.End then
					return
				end

				u32 = false
			end)
		end

		if Orion:IsRunning() then
			local connection = InputBegan:Connect(v37)
			local Connections = Orion.Connections

			table.insert(Connections, connection)
		end

		local InputChanged = v30.InputChanged

		local function v41(p10)
			if p10.UserInputType ~= Enum.UserInputType.MouseMovement then
				return
			end

			u33 = p10
		end

		if Orion:IsRunning() then
			local connection = InputChanged:Connect(v41)
			local Connections = Orion.Connections

			table.insert(Connections, connection)
		end

		local InputChanged2 = UserInputService.InputChanged

		local function v45(p11)
			local v46

			if p11 == u33 then
				v46 = u32
			else
				v46 = false
			end

			if not v46 then
				return
			end

			local v47 = p11.Position - Position

			v29.Position = UDim2.new(Position2.X.Scale, Position2.X.Offset + v47.X, Position2.Y.Scale, Position2.Y.Offset + v47.Y)
		end

		if not Orion:IsRunning() then
			return
		end

		local connection = InputChanged2:Connect(v45)
		local Connections = Orion.Connections

		table.insert(Connections, connection)
	end

	v30 = p7
	v29 = p8
	pcall(v31)
end
local function CreateInstance(p12, p13, p14)
	local instance = Instance.new(p12)
	local next_ = next
	local v53 = p13 or {}
	local key = nil

	while true do
		local v55

		key, v55 = next_(v53, key)

		if not key then
			break
		end

		instance[key] = v55
	end

	local next_2 = next
	local v57 = p14 or {}
	local key2 = nil

	while true do
		local v59

		key2, v59 = next_2(v57, key2)

		if not key2 then
			break
		end

		v59.Parent = instance
	end

	return instance
end
local function NewElement(p15, ...)
	return Orion.Elements[p15](...)
end
local function RegisterElement(p16, p17)
	Orion.Elements[p16] = function(...)
		return p17(...)
	end
end
local function RoundToIncrement(p18, p19)
	local v63 = math.floor(p18 / p19 + math.sign(p18) * 0.5) * p19

	if not (v63 < 0) then
		return v63
	end

	v63 = v63 + p19

	return v63
end
local function SetChildren(p20, p21)
	table.foreach(p21, function(_, p22)
		p22.Parent = p20
	end)

	return p20
end

local GetColorProperty = nil

local function AddThemeObject(p23, p24)
	if Orion.ThemeObjects[p24] then
		local v88 = Orion.ThemeObjects[p24]
		table.insert(v88, p23)
		p23[GetColorProperty(p23)] = Orion.Themes[Orion.SelectedTheme][p24]

		return p23
	end

	Orion.ThemeObjects[p24] = {}

	local v67 = Orion.ThemeObjects[p24]

	table.insert(v67, p23)
	p23[GetColorProperty(p23)] = Orion.Themes[Orion.SelectedTheme][p24]

	return p23
end

GetColorProperty = function(p25)
	if p25:IsA("Frame") or p25:IsA("TextButton") then
		return "BackgroundColor3"
	elseif p25:IsA("ScrollingFrame") then
		return "ScrollBarImageColor3"
	elseif p25:IsA("UIStroke") then
		return "Color"
	elseif p25:IsA("TextLabel") or p25:IsA("TextBox") then
		return "TextColor3"
	elseif p25:IsA("ImageLabel") or p25:IsA("ImageButton") then
		return "ImageColor3"
	else
		return
	end
end

local function SaveConfig(p26)
	local t3 = {}

	for k, v71 in pairs(Orion.Flags) do
		if v71.Save then
			if v71.Type == "Colorpicker" then
				local Value_ = v71.Value

				t3[k] = {
					R = Value_.R * 255,
					G = Value_.G * 255,
					B = Value_.B * 255
				}
			else
				t3[k] = v71.Value
			end
		end
	end

	local v73 = HttpService

	writefile(Orion.Folder .. "/" .. p26 .. ".txt", (tostring(v73:JSONEncode(t3))))
end

local DeserializeColor = nil

DeserializeColor = function(p27)
	return Color3.fromRGB(p27.R, p27.G, p27.B)
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

local function IsInList(p28, p29)
	local next_ = next
	local key = nil

	while true do
		local v80

		key, v80 = next_(p28, key)

		if not key then
			break
		end

		if v80 == p29 then
			return true
		end
	end
end

RegisterElement("Corner", function(p30, p31)
	return CreateInstance("UICorner", {
		CornerRadius = UDim.new(p30 or 0, p31 or 10)
	})
end)
RegisterElement("Stroke", function(p32, p33)
	return CreateInstance("UIStroke", {
		Color = p32 or Color3.fromRGB(255, 255, 255),
		Thickness = p33 or 1
	})
end)
RegisterElement("List", function(p34, p35)
	return CreateInstance("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(p34 or 0, p35 or 0)
	})
end)
RegisterElement("Padding", function(p36, p37, p38, p39)
	return CreateInstance("UIPadding", {
		PaddingBottom = UDim.new(0, p36 or 4),
		PaddingLeft = UDim.new(0, p37 or 4),
		PaddingRight = UDim.new(0, p38 or 4),
		PaddingTop = UDim.new(0, p39 or 4)
	})
end)
RegisterElement("TFrame", function()
	return CreateInstance("Frame", {
		BackgroundTransparency = 1
	})
end)
RegisterElement("Frame", function(p40)
	return CreateInstance("Frame", {
		BackgroundColor3 = p40 or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	})
end)
RegisterElement("RoundFrame", function(p41, p42, p43)
	return CreateInstance("Frame", {
		BackgroundColor3 = p41 or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	}, { CreateInstance("UICorner", {
			CornerRadius = UDim.new(p42, p43)
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
RegisterElement("ScrollFrame", function(p44, p45)
	return CreateInstance("ScrollingFrame", {
		BackgroundTransparency = 1,
		MidImage = "rbxassetid://7445543667",
		BottomImage = "rbxassetid://7445543667",
		TopImage = "rbxassetid://7445543667",
		ScrollBarImageColor3 = p44,
		BorderSizePixel = 0,
		ScrollBarThickness = p45,
		CanvasSize = UDim2.new(0, 0, 0, 0)
	})
end)
RegisterElement("Image", function(p46)
	local ImageLabel = CreateInstance("ImageLabel", {
		Image = p46,
		BackgroundTransparency = 1
	})
	local v82

	if icons[p46] == nil then
		v82 = nil
	else
		v82 = icons[p46]
	end

	if v82 == nil then
		return ImageLabel
	end

	local v83

	if icons[p46] == nil then
		v83 = nil
	else
		v83 = icons[p46]
	end

	ImageLabel.Image = v83

	return ImageLabel
end)
RegisterElement("ImageButton", function(p47)
	return CreateInstance("ImageButton", {
		Image = p47,
		BackgroundTransparency = 1
	})
end)
RegisterElement("Label", function(p48, p49, p50)
	return CreateInstance("TextLabel", {
		Text = p48 or "",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = p50 or 0,
		TextSize = p49 or 15,
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

function Orion.MakeNotification(_, p51)
	local v85 = nil

	local function v86()
		v85.Name = v85.Name or "Notification"
		v85.Content = v85.Content or "Test"
		v85.Image = v85.Image or "rbxassetid://4384403532"
		v85.Time = v85.Time or 15

		local v87 = SetProperties(NewElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = NotificationHolder
		})
		local v89 = SetChildren(SetProperties(NewElement("RoundFrame", Color3.fromRGB(25, 25, 25), 0, 10), {
			Parent = v87,
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(1, -55, 0, 0),
			BackgroundTransparency = 0,
			AutomaticSize = Enum.AutomaticSize.Y
		}), {
			NewElement("Stroke", Color3.fromRGB(93, 93, 93), 1.2),
			NewElement("Padding", 12, 12, 12, 12),
			SetProperties(NewElement("Image", v85.Image), {
				Size = UDim2.new(0, 20, 0, 20),
				ImageColor3 = Color3.fromRGB(240, 240, 240),
				Name = "Icon"
			}),
			SetProperties(NewElement("Label", v85.Name, 15), {
				Size = UDim2.new(1, -30, 0, 20),
				Position = UDim2.new(0, 30, 0, 0),
				Font = Enum.Font.GothamBold,
				Name = "Title"
			}),
			SetProperties(NewElement("Label", v85.Content, 14), {
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 25),
				Font = Enum.Font.GothamSemibold,
				Name = "Content",
				AutomaticSize = Enum.AutomaticSize.Y,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextWrapped = true
			})
		})
		local v90 = TweenService
		local tweenInfoNew = TweenInfo.new
		local Enum_ = Enum

		v90.Create(v90, v89, tweenInfoNew(0.5, Enum_.EasingStyle.Quint), {
			Position = UDim2.new(0, 0, 0, 0)
		}):Play()
		wait(v85.Time - 0.88)
		TweenService:Create(v89.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
			ImageTransparency = 1
		}):Play()
		TweenService:Create(v89, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
			BackgroundTransparency = 0.6
		}):Play()
		wait(0.3)
		TweenService:Create(v89.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
			Transparency = 0.9
		}):Play()
		TweenService:Create(v89.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
			TextTransparency = 0.4
		}):Play()
		TweenService:Create(v89.Content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
			TextTransparency = 0.5
		}):Play()
		wait(0.05)
		v89:TweenPosition(UDim2.new(1, 20, 0, 0), "In", "Quint", 0.8, true)
		wait(1.35)
		v89:Destroy()
	end

	v85 = p51
	spawn(v86)
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

		table.foreach(data, function(p52, p53)
			if not Orion.Flags[p52] then
				warn("Orion Library Config Loader - Could not find ", p52, p53)

				return
			end

			local function v93()
				if Orion.Flags[p52].Type == "Colorpicker" then
					Orion.Flags[p52]:Set(unpack_({ DeserializeColor(p53) }))
				else
					Orion.Flags[p52]:Set(p53)
				end
			end

			spawn(v93)
		end)

		local v94 = Orion
		local GameId = game.GameId

		v94.MakeNotification(v94, {
			Name = "配置",
			Content = "自动载入游戏配置" .. GameId .. ".",
			Time = 5
		})
	end)
end
function Orion.MakeWindow(_, p54)
	local u96 = false
	local v97 = p54 or {}

	v97.Name = v97.Name or "Orion Library"
	v97.ConfigFolder = v97.ConfigFolder or v97.Name
	v97.SaveConfig = v97.SaveConfig or false
	v97.HidePremium = v97.HidePremium or false

	if v97.IntroEnabled == nil then
		v97.IntroEnabled = true
	end

	v97.IntroText = v97.IntroText or "Orion Library"
	v97.CloseCallback = v97.CloseCallback or function() end
	v97.ShowIcon = v97.ShowIcon or false
	v97.Icon = v97.Icon or "rbxassetid://8834748103"
	v97.IntroIcon = v97.IntroIcon or "rbxassetid://8834748103"
	Orion.Folder = v97.ConfigFolder
	Orion.SaveCfg = v97.SaveConfig

	if v97.SaveConfig and not isfolder(v97.ConfigFolder) then
		makefolder(v97.ConfigFolder)
	end

	local divider = AddThemeObject(SetChildren(SetProperties(NewElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 4), {
		Size = UDim2.new(1, 0, 1, -50)
	}), { NewElement("List"), NewElement("Padding", 8, 0, 0, 8) }), "Divider")
	local signal = divider.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize")

	local function v100()
		divider.CanvasSize = UDim2.new(0, 0, 0, divider.UIListLayout.AbsoluteContentSize.Y + 16)
	end

	if Orion:IsRunning() then
		local connection = signal:Connect(v100)
		local Connections = Orion.Connections

		table.insert(Connections, connection)
	end

	local v103 = SetChildren(SetProperties(NewElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1
	}), { AddThemeObject(SetProperties(NewElement("Image", "rbxassetid://7072725342"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18)
		}), "Text") })
	local v104 = SetChildren(SetProperties(NewElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		BackgroundTransparency = 1
	}), { AddThemeObject(SetProperties(NewElement("Image", "rbxassetid://7072719338"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18),
			Name = "Ico"
		}), "Text") })
	local v105 = SetProperties(NewElement("TFrame"), {
		Size = UDim2.new(1, 0, 0, 50)
	})
	local v106 = AddThemeObject
	local v107 = SetChildren
	local v108 = SetProperties(NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
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
	local v112 = SetChildren
	local v113 = SetProperties(NewElement("TFrame"), {
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
	local v116 = SetChildren(SetProperties(NewElement("TFrame"), {
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.new(0, 32, 0, 32),
		Position = UDim2.new(0, 10, 0.5, 0)
	}), { AddThemeObject(NewElement("Stroke"), "Stroke"), NewElement("Corner", 1) })
	local v117 = AddThemeObject
	local v118 = SetProperties
	local Label = NewElement("Label", LocalPlayer.DisplayName, v97.HidePremium and 14 or 13)
	local uDim2 = UDim2.new(1, -60, 0, 13)
	local HidePremium = v97.HidePremium

	if HidePremium then
		HidePremium = UDim2.new(0, 50, 0, 19)
	end

	local second3 = v106(v107(v108, {
		second,
		second2,
		stroke,
		divider,
		v112(v113, {
			stroke2,
			divider2,
			v116,
			v117(v118(Label, {
				Size = uDim2,
				Position = HidePremium or UDim2.new(0, 50, 0, 12),
				Font = Enum.Font.GothamBold,
				ClipsDescendants = true
			}), "Text"),
			AddThemeObject(SetProperties(NewElement("Label", "", 12), {
				Size = UDim2.new(1, -60, 0, 12),
				Position = UDim2.new(0, 50, 1, -25),
				Visible = not v97.HidePremium
			}), "TextDark")
		})
	}), "Second")
	local text = AddThemeObject(SetProperties(NewElement("Label", v97.Name, 14), {
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
				v103,
				v104
			}), "Second") }), v105, second3 }), "Main")

	if v97.ShowIcon then
		text.Position = UDim2.new(0, 50, 0, -24)
		SetProperties(NewElement("Image", v97.Icon), {
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(0, 25, 0, 15)
		}).Parent = main.TopBar
	end

	MakeDraggable(v105, main)

	local MouseButton1Up = v103.MouseButton1Up

	local function v127()
		main.Visible = false
		u96 = true
		Orion:MakeNotification({
			Name = "XK脚本中心",
			Content = "再见“朋友”有机会回来看啊",
			Time = 5
		})
		v97.CloseCallback()
	end

	if Orion:IsRunning() then
		local connection = MouseButton1Up:Connect(v127)
		local Connections = Orion.Connections

		table.insert(Connections, connection)
	end

	local InputBegan = UserInputService.InputBegan

	local function v131(p55)
		local v132

		if p55.KeyCode == Enum.KeyCode.RightShift then
			v132 = u96
		else
			v132 = false
		end

		if not v132 then
			return
		end

		main.Visible = true
	end

	if Orion:IsRunning() then
		local connection = InputBegan:Connect(v131)
		local Connections = Orion.Connections

		table.insert(Connections, connection)
	end

	local MouseButton1Up2 = v104.MouseButton1Up

	local function v136()
		main.ClipsDescendants = true
		stroke3.Visible = false
		v104.Ico.Image = "rbxassetid://7072720870"

		local v137 = TweenService
		local v138 = main
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		local uDim2New = UDim2.new
		local v141 = text.TextBounds.X + 140

		v137.Create(v137, v138, tweenInfo, {
			Size = uDim2New(0, v141, 0, 50)
		}):Play()
		wait(0.1)
		second3.Visible = false
	end

	if Orion:IsRunning() then
		local connection = MouseButton1Up2:Connect(v136)
		local Connections = Orion.Connections

		table.insert(Connections, connection)
	end

	local function v144()
		main.Visible = false

		local v145 = SetProperties(NewElement("Image", v97.IntroIcon), {
			Parent = ScreenGui,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.4, 0),
			Size = UDim2.new(0, 28, 0, 28),
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ImageTransparency = 1
		})
		local v146 = SetProperties(NewElement("Label", v97.IntroText, 14), {
			Parent = ScreenGui,
			Size = UDim2.new(1, 0, 1, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 19, 0.5, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			Font = Enum.Font.GothamBold,
			TextTransparency = 1
		})
		local v147 = TweenService
		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		v147.Create(v147, v145, tweenInfo, {
			ImageTransparency = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}):Play()
		wait(0.8)

		local v149 = TweenService
		local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local uDim2New = UDim2.new
		local X = v146.TextBounds.X

		v149.Create(v149, v145, tweenInfo2, {
			Position = uDim2New(0.5, -(X / 2), 0.5, 0)
		}):Play()
		wait(0.3)
		TweenService:Create(v146, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 0
		}):Play()
		wait(2)
		TweenService:Create(v146, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 1
		}):Play()
		main.Visible = true
		v145:Destroy()
		v146:Destroy()
	end

	if v97.IntroEnabled then
		v144()
	end

	return {
		MakeTab = function(_, p56)
			local v153 = p56 or {}

			v153.Name = v153.Name or "Tab"
			v153.Icon = v153.Icon or ""
			v153.PremiumOnly = v153.PremiumOnly or false

			local v154 = SetProperties(NewElement("Button"), {
				Size = UDim2.new(1, 0, 0, 30),
				Parent = divider
			})
			local t6 = { AddThemeObject(SetProperties(NewElement("Image", v153.Icon), {
					AnchorPoint = Vector2.new(0, 0.5),
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0, 10, 0.5, 0),
					ImageTransparency = 0.4,
					Name = "Ico"
				}), "Text"), AddThemeObject(SetProperties(NewElement("Label", v153.Name, 14), {
					Size = UDim2.new(1, -35, 1, 0),
					Position = UDim2.new(0, 35, 0, 0),
					Font = Enum.Font.GothamSemibold,
					TextTransparency = 0.4,
					Name = "Title"
				}), "Text") }

			table.foreach(t6, function(_, p57)
				p57.Parent = v154
			end)

			local Icon = v153.Icon
			local v157

			if icons[Icon] == nil then
				v157 = nil
			else
				v157 = icons[Icon]
			end

			if v157 ~= nil then
				local Ico = v154.Ico
				local Icon2 = v153.Icon
				local v160

				if icons[Icon2] == nil then
					v160 = nil
				else
					v160 = icons[Icon2]
				end

				Ico.Image = v160
			end

			local divider3 = AddThemeObject(SetChildren(SetProperties(NewElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 5), {
				Size = UDim2.new(1, -150, 1, -50),
				Position = UDim2.new(0, 150, 0, 50),
				Parent = main,
				Visible = false,
				Name = "ItemContainer"
			}), { NewElement("List", 0, 6), NewElement("Padding", 15, 10, 10, 15) }), "Divider")
			local signal2 = divider3.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize")

			local function v163()
				divider3.CanvasSize = UDim2.new(0, 0, 0, divider3.UIListLayout.AbsoluteContentSize.Y + 30)
			end

			if Orion:IsRunning() then
				local connection = signal2:Connect(v163)
				local Connections = Orion.Connections

				table.insert(Connections, connection)
			end

			v154.Ico.ImageTransparency = 0
			v154.Title.TextTransparency = 0
			v154.Title.Font = Enum.Font.GothamBlack
			divider3.Visible = true

			local MouseButton1Click = v154.MouseButton1Click

			local function v167()
				local next_ = next
				local children, key = divider:GetChildren()

				while true do
					local v171

					key, v171 = next_(children, key)

					if not key then
						break
					end

					if v171:IsA("TextButton") then
						v171.Title.Font = Enum.Font.GothamSemibold
						TweenService:Create(v171.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							ImageTransparency = 0.4
						}):Play()
						TweenService:Create(v171.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							TextTransparency = 0.4
						}):Play()
					end
				end

				local next_2 = next
				local children2, key2 = main:GetChildren()

				while true do
					local v175

					key2, v175 = next_2(children2, key2)

					if not key2 then
						break
					end

					if v175.Name == "ItemContainer" then
						v175.Visible = false
					end
				end

				TweenService:Create(v154.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					ImageTransparency = 0
				}):Play()
				TweenService:Create(v154.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					TextTransparency = 0
				}):Play()
				v154.Title.Font = Enum.Font.GothamBlack
				divider3.Visible = true
			end

			if Orion:IsRunning() then
				local connection = MouseButton1Click:Connect(v167)
				local Connections = Orion.Connections

				table.insert(Connections, connection)
			end

			local function v178(p58)
				return {
					AddLabel = function(_, p59)
						local v179 = AddThemeObject
						local RoundFrame = NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5)
						local t7 = {
							Size = UDim2.new(1, 0, 0, 30),
							BackgroundTransparency = 0.7,
							Parent = p58
						}

						table.foreach(t7, function(p60, p61)
							RoundFrame[p60] = p61
						end)

						local v182 = AddThemeObject
						local Label2 = NewElement("Label", p59, 15)
						local t8 = {
							Size = UDim2.new(1, -12, 1, 0),
							Position = UDim2.new(0, 12, 0, 0),
							Font = Enum.Font.GothamBold,
							Name = "Content"
						}

						table.foreach(t8, function(p62, p63)
							Label2[p62] = p63
						end)

						local t9 = { v182(Label2, "Text"), AddThemeObject(NewElement("Stroke"), "Stroke") }

						table.foreach(t9, function(_, p64)
							p64.Parent = RoundFrame
						end)

						local second4 = v179(RoundFrame, "Second")
						local v187 = nil

						local function set(_, p65)
							v187.Content.Text = p65
						end

						v187 = second4

						local t10 = {
							Set = set
						}

						return t10
					end,
					AddParagraph = function(_, p66, p67)
						local text2 = p67 or "Content"
						local v191 = AddThemeObject
						local RoundFrame = NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5)
						local t11 = {
							Size = UDim2.new(1, 0, 0, 30),
							BackgroundTransparency = 0.7,
							Parent = p58
						}

						table.foreach(t11, function(p68, p69)
							RoundFrame[p68] = p69
						end)

						local text3 = AddThemeObject(SetProperties(NewElement("Label", p66 or "Text", 15), {
							Size = UDim2.new(1, -12, 0, 14),
							Position = UDim2.new(0, 12, 0, 10),
							Font = Enum.Font.GothamBold,
							Name = "Title"
						}), "Text")
						local v195 = AddThemeObject
						local Label2 = NewElement("Label", "", 13)
						local t12 = {
							Size = UDim2.new(1, -24, 0, 0),
							Position = UDim2.new(0, 12, 0, 26),
							Font = Enum.Font.GothamSemibold,
							Name = "Content",
							TextWrapped = true
						}

						table.foreach(t12, function(p70, p71)
							Label2[p70] = p71
						end)

						local t13 = { text3, v195(Label2, "TextDark"), AddThemeObject(NewElement("Stroke"), "Stroke") }

						table.foreach(t13, function(_, p72)
							p72.Parent = RoundFrame
						end)

						local second4 = v191(RoundFrame, "Second")
						local signal3 = second4.Content:GetPropertyChangedSignal("Text")

						local function v201()
							second4.Content.Size = UDim2.new(1, -24, 0, second4.Content.TextBounds.Y)
							second4.Size = UDim2.new(1, 0, 0, second4.Content.TextBounds.Y + 35)
						end

						if Orion:IsRunning() then
							local connection = signal3:Connect(v201)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						second4.Content.Text = text2

						return {
							Set = function(_, p73)
								second4.Content.Text = p73
							end
						}
					end,
					AddButton = function(_, p74)
						local v204 = p74 or {}

						v204.Name = v204.Name or "Button"
						v204.Callback = v204.Callback or function() end
						v204.Icon = v204.Icon or "rbxassetid://3944703587"

						local t14 = {}
						local v206 = SetProperties(NewElement("Button"), {
							Size = UDim2.new(1, 0, 1, 0)
						})
						local v207 = AddThemeObject
						local v208 = SetChildren
						local RoundFrame = NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5)
						local t15 = {
							Size = UDim2.new(1, 0, 0, 33),
							Parent = p58
						}

						table.foreach(t15, function(p75, p76)
							RoundFrame[p75] = p76
						end)

						local second4 = v207(v208(RoundFrame, {
							AddThemeObject(SetProperties(NewElement("Label", v204.Name, 15), {
								Size = UDim2.new(1, -12, 1, 0),
								Position = UDim2.new(0, 12, 0, 0),
								Font = Enum.Font.GothamBold,
								Name = "Content"
							}), "Text"),
							AddThemeObject(SetProperties(NewElement("Image", v204.Icon), {
								Size = UDim2.new(0, 20, 0, 20),
								Position = UDim2.new(1, -30, 0, 7)
							}), "TextDark"),
							AddThemeObject(NewElement("Stroke"), "Stroke"),
							v206
						}), "Second")
						local MouseEnter = v206.MouseEnter

						local function v213()
							local v214 = TweenService
							local v215 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local color3 = Color3.fromRGB
							local v218 = Orion.Themes[Orion.SelectedTheme].Second.R * 255 + 3
							local v219 = Orion.Themes[Orion.SelectedTheme]

							v214.Create(v214, v215, tweenInfo, {
								BackgroundColor3 = color3(v218, v219.Second.G * 255 + 3, Orion.Themes[Orion.SelectedTheme].Second.B * 255 + 3)
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = MouseEnter:Connect(v213)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseLeave = v206.MouseLeave

						local function v223()
							local v224 = TweenService
							local v225 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local v227 = Orion.Themes[Orion.SelectedTheme]

							v224.Create(v224, v225, tweenInfo, {
								BackgroundColor3 = v227.Second
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = MouseLeave:Connect(v223)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseButton1Up3 = v206.MouseButton1Up

						local function v231()
							local v232 = TweenService
							local v233 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local color3 = Color3.fromRGB
							local v236 = Orion.Themes[Orion.SelectedTheme].Second.R * 255 + 3
							local v237 = Orion.Themes[Orion.SelectedTheme].Second.G * 255 + 3
							local Themes = Orion.Themes
							local v239 = Orion
							local v240 = v232.Create(v232, v233, tweenInfo, {
								BackgroundColor3 = color3(v236, v237, Themes[v239.SelectedTheme].Second.B * 255 + 3)
							})

							local function v241()
								v204.Callback()
							end

							v240.Play(v240)
							spawn(v241)
						end

						if Orion:IsRunning() then
							local connection = MouseButton1Up3:Connect(v231)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseButton1Down = v206.MouseButton1Down

						local function v245()
							TweenService:Create(second4, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
								BackgroundColor3 = Color3.fromRGB(Orion.Themes[Orion.SelectedTheme].Second.R * 255 + 6, Orion.Themes[Orion.SelectedTheme].Second.G * 255 + 6, Orion.Themes[Orion.SelectedTheme].Second.B * 255 + 6)
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = MouseButton1Down:Connect(v245)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						function t14.Set(_, p77)
							second4.Content.Text = p77
						end

						return t14
					end,
					AddToggle = function(_, p78)
						local v248 = p78 or {}

						v248.Name = v248.Name or "Toggle"
						v248.Default = v248.Default or false
						v248.Callback = v248.Callback or function() end
						v248.Color = v248.Color or Color3.fromRGB(9, 99, 195)
						v248.Flag = v248.Flag or nil
						v248.Save = v248.Save or false

						local t16 = {
							Value = v248.Default,
							Save = v248.Save
						}
						local v250 = SetProperties(NewElement("Button"), {
							Size = UDim2.new(1, 0, 1, 0)
						})
						local v251 = SetChildren(SetProperties(NewElement("RoundFrame", v248.Color, 0, 4), {
							Size = UDim2.new(0, 24, 0, 24),
							Position = UDim2.new(1, -24, 0.5, 0),
							AnchorPoint = Vector2.new(0.5, 0.5)
						}), { SetProperties(NewElement("Stroke"), {
								Color = v248.Color,
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
							Parent = p58
						}), {
							AddThemeObject(SetProperties(NewElement("Label", v248.Name, 15), {
								Size = UDim2.new(1, -12, 1, 0),
								Position = UDim2.new(0, 12, 0, 0),
								Font = Enum.Font.GothamBold,
								Name = "Content"
							}), "Text"),
							AddThemeObject(NewElement("Stroke"), "Stroke"),
							v251,
							v250
						}), "Second")

						function t16.Set(_, p79)
							t16.Value = p79

							local v253 = TweenService
							local v254 = v251
							local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local Value_ = t16.Value

							if Value_ then
								Value_ = v248.Color
							end

							v253:Create(v254, tweenInfo, {
								BackgroundColor3 = Value_ or Orion.Themes.Default.Divider
							}):Play()

							local v257 = TweenService
							local Stroke = v251.Stroke
							local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local Value_2 = t16.Value

							if Value_2 then
								Value_2 = v248.Color
							end

							v257:Create(Stroke, tweenInfo2, {
								Color = Value_2 or Orion.Themes.Default.Stroke
							}):Play()

							local v261 = TweenService
							local Ico = v251.Ico
							local tweenInfo3 = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local v264 = t16.Value and 0 or 1
							local Value_3 = t16.Value

							if not Value_3 then
								v261:Create(Ico, tweenInfo3, {
									ImageTransparency = v264,
									Size = Value_3 or UDim2.new(0, 8, 0, 8)
								}):Play()
								v248.Callback(t16.Value)

								return
							end

							Value_3 = UDim2.new(0, 20, 0, 20)
							v261:Create(Ico, tweenInfo3, {
								ImageTransparency = v264,
								Size = Value_3 or UDim2.new(0, 8, 0, 8)
							}):Play()
							v248.Callback(t16.Value)
						end

						t16:Set(t16.Value)

						local MouseEnter = v250.MouseEnter

						local function v267()
							local v268 = TweenService
							local v269 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local color3 = Color3.fromRGB
							local v272 = Orion.Themes[Orion.SelectedTheme].Second.R * 255 + 3

							v268.Create(v268, v269, tweenInfo, {
								BackgroundColor3 = color3(v272, Orion.Themes[Orion.SelectedTheme].Second.G * 255 + 3, Orion.Themes[Orion.SelectedTheme].Second.B * 255 + 3)
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = MouseEnter:Connect(v267)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseLeave = v250.MouseLeave

						local function v276()
							TweenService:Create(second4, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
								BackgroundColor3 = Orion.Themes[Orion.SelectedTheme].Second
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = MouseLeave:Connect(v276)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseButton1Up3 = v250.MouseButton1Up

						local function v280()
							local v281 = TweenService
							local v282 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local color3 = Color3.fromRGB
							local v285 = Orion.Themes[Orion.SelectedTheme].Second.R * 255 + 3
							local v286 = Orion.Themes[Orion.SelectedTheme].Second.G * 255 + 3
							local v287 = Orion

							v281.Create(v281, v282, tweenInfo, {
								BackgroundColor3 = color3(v285, v286, v287.Themes[Orion.SelectedTheme].Second.B * 255 + 3)
							}):Play()
							SaveConfig(game.GameId)
							t16:Set(not t16.Value)
						end

						if Orion:IsRunning() then
							local connection = MouseButton1Up3:Connect(v280)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseButton1Down = v250.MouseButton1Down

						local function v291()
							local v292 = TweenService
							local v293 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local color3 = Color3.fromRGB
							local Second = Orion.Themes[Orion.SelectedTheme].Second

							v292.Create(v292, v293, tweenInfo, {
								BackgroundColor3 = color3(Second.R * 255 + 6, Orion.Themes[Orion.SelectedTheme].Second.G * 255 + 6, Orion.Themes[Orion.SelectedTheme].Second.B * 255 + 6)
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = MouseButton1Down:Connect(v291)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						if not v248.Flag then
							return t16
						end

						Orion.Flags[v248.Flag] = t16

						return t16
					end,
					AddSlider = function(_, p80)
						local v299 = p80 or {}

						v299.Name = v299.Name or "Slider"
						v299.Min = v299.Min or 0
						v299.Max = v299.Max or 100
						v299.Increment = v299.Increment or 1
						v299.Default = v299.Default or 50
						v299.Callback = v299.Callback or function() end
						v299.ValueName = v299.ValueName or ""
						v299.Color = v299.Color or Color3.fromRGB(9, 149, 98)
						v299.Flag = v299.Flag or nil
						v299.Save = v299.Save or false

						local t17 = {
							Value = v299.Default,
							Save = v299.Save
						}
						local u301 = false
						local v302 = SetChildren(SetProperties(NewElement("RoundFrame", v299.Color, 0, 5), {
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
						local v303 = SetChildren(SetProperties(NewElement("RoundFrame", v299.Color, 0, 5), {
							Size = UDim2.new(1, -24, 0, 26),
							Position = UDim2.new(0, 12, 0, 30),
							BackgroundTransparency = 0.9
						}), { SetProperties(NewElement("Stroke"), {
								Color = v299.Color
							}), AddThemeObject(SetProperties(NewElement("Label", "value", 13), {
								Size = UDim2.new(1, -12, 0, 14),
								Position = UDim2.new(0, 12, 0, 6),
								Font = Enum.Font.GothamBold,
								Name = "Value",
								TextTransparency = 0.8
							}), "Text"), v302 })

						AddThemeObject(SetChildren(SetProperties(NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
							Size = UDim2.new(1, 0, 0, 65),
							Parent = p58
						}), { AddThemeObject(SetProperties(NewElement("Label", v299.Name, 15), {
								Size = UDim2.new(1, -12, 0, 14),
								Position = UDim2.new(0, 12, 0, 10),
								Font = Enum.Font.GothamBold,
								Name = "Content"
							}), "Text"), AddThemeObject(NewElement("Stroke"), "Stroke"), v303 }), "Second")
						v303.InputBegan:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
								return
							end

							u301 = true
						end)
						v303.InputEnded:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
								return
							end

							u301 = false
						end)
						UserInputService.InputChanged:Connect(function(input)
							local v304 = u301

							if v304 then
								v304 = input.UserInputType == Enum.UserInputType.MouseMovement
							end

							if not v304 then
								return
							end

							local v305 = (input.Position.X - v303.AbsolutePosition.X) / v303.AbsoluteSize.X
							local v306 = math.clamp(v305, 0, 1)

							t17:Set(v299.Min + (v299.Max - v299.Min) * v306)
							SaveConfig(game.GameId)
						end)

						function t17.Set(p81, p82)
							p81.Value = math.clamp(RoundToIncrement(p82, v299.Increment), v299.Min, v299.Max)

							local v307 = TweenService
							local v308 = v302
							local tweenInfoNew = TweenInfo.new
							local Quad = Enum.EasingStyle.Quad
							local Enum_ = Enum

							v307.Create(v307, v308, tweenInfoNew(0.15, Quad, Enum_.EasingDirection.Out), {
								Size = UDim2.fromScale((p81.Value - v299.Min) / (v299.Max - v299.Min), 1)
							}):Play()

							local Value_ = v303.Value
							local Value_2 = p81.Value

							Value_.Text = tostring(Value_2) .. " " .. v299.ValueName

							local Value_3 = v302.Value
							local Value_4 = p81.Value

							Value_3.Text = tostring(Value_4) .. " " .. v299.ValueName
							v299.Callback(p81.Value)
						end

						t17:Set(t17.Value)

						if not v299.Flag then
							return t17
						end

						Orion.Flags[v299.Flag] = t17

						return t17
					end,
					AddDropdown = function(_, p83)
						local v316 = p83 or {}

						v316.Name = v316.Name or "Dropdown"
						v316.Options = v316.Options or {}
						v316.Default = v316.Default or ""
						v316.Callback = v316.Callback or function() end
						v316.Flag = v316.Flag or nil
						v316.Save = v316.Save or false

						local t18 = {
							Value = v316.Default,
							Options = v316.Options,
							Buttons = {},
							Toggled = false,
							Type = "Dropdown",
							Save = v316.Save
						}

						if not table.find(t18.Options, t18.Value) then
							t18.Value = "..."
						end

						local List = NewElement("List")
						local v319 = AddThemeObject
						local v320 = SetProperties
						local ScrollFrame = NewElement("ScrollFrame", Color3.fromRGB(40, 40, 40), 4)

						table.foreach({ List }, function(_, p84)
							p84.Parent = ScrollFrame
						end)

						local divider4 = v319(v320(ScrollFrame, {
							Parent = p58,
							Position = UDim2.new(0, 0, 0, 38),
							Size = UDim2.new(1, 0, 1, -38),
							ClipsDescendants = true
						}), "Divider")
						local v323 = SetProperties(NewElement("Button"), {
							Size = UDim2.new(1, 0, 1, 0)
						})
						local second4 = AddThemeObject(SetChildren(SetProperties(NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
							Size = UDim2.new(1, 0, 0, 38),
							Parent = p58,
							ClipsDescendants = true
						}), {
							divider4,
							SetProperties(SetChildren(NewElement("TFrame"), {
								AddThemeObject(SetProperties(NewElement("Label", v316.Name, 15), {
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
								v323
							}), {
								Size = UDim2.new(1, 0, 0, 38),
								ClipsDescendants = true,
								Name = "F"
							}),
							AddThemeObject(NewElement("Stroke"), "Stroke"),
							NewElement("Corner")
						}), "Second")
						local signal3 = List:GetPropertyChangedSignal("AbsoluteContentSize")

						local function v326()
							divider4.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y)
						end

						if Orion:IsRunning() then
							local connection = signal3:Connect(v326)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local function v329(p85)
							for _, v in pairs(p85) do
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

								local function v334()
									t18:Set(v)
									SaveConfig(game.GameId)
								end

								if Orion:IsRunning() then
									local connection = MouseButton1Click2:Connect(v334)
									local Connections = Orion.Connections

									table.insert(Connections, connection)
								end

								t18.Buttons[v] = divider5
							end
						end

						function t18.Refresh(_, p86, p87)
							if not p87 then
								t18.Options = p86
								v329(t18.Options)

								return
							end

							for _, button in pairs(t18.Buttons) do
								button:Destroy()
							end

							table.clear(t18.Options)
							table.clear(t18.Buttons)
							t18.Options = p86
							v329(t18.Options)
						end
						function t18.Set(_, p88)
							if table.find(t18.Options, p88) then
								t18.Value = p88
								second4.F.Selected.Text = t18.Value

								for _, button in pairs(t18.Buttons) do
									local v341 = TweenService
									local tweenInfoNew = TweenInfo.new
									local Quad = Enum.EasingStyle.Quad
									local EasingDirection = Enum.EasingDirection

									v341.Create(v341, button, tweenInfoNew(0.15, Quad, EasingDirection.Out), {
										BackgroundTransparency = 1
									}):Play()
									TweenService:Create(button.Title, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
										TextTransparency = 0.4
									}):Play()
								end

								TweenService:Create(t18.Buttons[p88], TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
									BackgroundTransparency = 0
								}):Play()
								TweenService:Create(t18.Buttons[p88].Title, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
									TextTransparency = 0
								}):Play()

								return v316.Callback(t18.Value)
							else
								t18.Value = "..."
								second4.F.Selected.Text = t18.Value

								for _, button in pairs(t18.Buttons) do
									TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
										BackgroundTransparency = 1
									}):Play()
									TweenService:Create(button.Title, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
										TextTransparency = 0.4
									}):Play()
								end
							end
						end

						AddConnection(v323.MouseButton1Click, function()
							t18.Toggled = not t18.Toggled
							second4.F.Line.Visible = t18.Toggled

							local v347 = TweenService
							local Ico = second4.F.Ico
							local tweenInfoNew = TweenInfo.new
							local Enum_ = Enum

							v347.Create(v347, Ico, tweenInfoNew(0.15, Enum_.EasingStyle.Quad, Enum.EasingDirection.Out), {
								Rotation = t18.Toggled and 180 or 0
							}):Play()

							if #t18.Options > 5 then
								local v351 = TweenService
								local v352 = second4
								local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
								local s1 = "Size"
								local Toggled = t18.Toggled

								if not Toggled then
									v351:Create(v352, tweenInfo, {
										[s1] = Toggled or UDim2.new(1, 0, 0, 38)
									}):Play()

									return
								end

								Toggled = UDim2.new(1, 0, 0, 178)
								v351:Create(v352, tweenInfo, {
									[s1] = Toggled or UDim2.new(1, 0, 0, 38)
								}):Play()
							else
								local v356 = TweenService
								local v357 = second4
								local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
								local s2 = "Size"
								local Toggled = t18.Toggled

								if not Toggled then
									v356:Create(v357, tweenInfo, {
										[s2] = Toggled or UDim2.new(1, 0, 0, 38)
									}):Play()

									return
								end

								Toggled = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y + 38)
								v356:Create(v357, tweenInfo, {
									[s2] = Toggled or UDim2.new(1, 0, 0, 38)
								}):Play()
							end
						end)
						t18:Refresh(t18.Options, false)
						t18:Set(t18.Value)

						if not v316.Flag then
							return t18
						end

						Orion.Flags[v316.Flag] = t18

						return t18
					end,
					AddBind = function(_, p89)
						p89.Name = p89.Name or "Bind"
						p89.Default = p89.Default or Enum.KeyCode.Unknown
						p89.Hold = p89.Hold or false
						p89.Callback = p89.Callback or function() end
						p89.Flag = p89.Flag or nil
						p89.Save = p89.Save or false

						local t19 = {
							Value = nil,
							Binding = false,
							Type = "Bind",
							Save = p89.Save
						}
						local u362 = false
						local v363 = SetProperties(NewElement("Button"), {
							Size = UDim2.new(1, 0, 1, 0)
						})
						local main2 = AddThemeObject(SetChildren(SetProperties(NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
							Size = UDim2.new(0, 24, 0, 24),
							Position = UDim2.new(1, -12, 0.5, 0),
							AnchorPoint = Vector2.new(1, 0.5)
						}), { AddThemeObject(NewElement("Stroke"), "Stroke"), AddThemeObject(SetProperties(NewElement("Label", p89.Name, 14), {
								Size = UDim2.new(1, 0, 1, 0),
								Font = Enum.Font.GothamBold,
								TextXAlignment = Enum.TextXAlignment.Center,
								Name = "Value"
							}), "Text") }), "Main")
						local v365 = AddThemeObject
						local v366 = SetProperties(NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
							Size = UDim2.new(1, 0, 0, 38),
							Parent = p58
						})
						local t20 = {
							AddThemeObject(SetProperties(NewElement("Label", p89.Name, 15), {
								Size = UDim2.new(1, -12, 1, 0),
								Position = UDim2.new(0, 12, 0, 0),
								Font = Enum.Font.GothamBold,
								Name = "Content"
							}), "Text"),
							AddThemeObject(NewElement("Stroke"), "Stroke"),
							main2,
							v363
						}

						table.foreach(t20, function(_, p90)
							p90.Parent = v366
						end)

						local second4 = v365(v366, "Second")
						local signal3 = main2.Value:GetPropertyChangedSignal("Text")

						local function v370()
							local v371 = TweenService
							local v372 = main2
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

							v371.Create(v371, v372, tweenInfo, {
								Size = UDim2.new(0, main2.Value.TextBounds.X + 16, 0, 24)
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = signal3:Connect(v370)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local InputEnded = v363.InputEnded

						local function v377(p91)
							if p91.UserInputType ~= Enum.UserInputType.MouseButton1 then
								return
							end

							if t19.Binding then
								return
							end

							t19.Binding = true
							main2.Value.Text = ""
						end

						if Orion:IsRunning() then
							local connection = InputEnded:Connect(v377)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local InputBegan2 = UserInputService.InputBegan

						local function v381(p92)
							if UserInputService:GetFocusedTextBox() then
								return
							end

							local v382 = p92.KeyCode.Name == t19.Value or p92.UserInputType.Name == t19.Value

							if v382 then
								v382 = not t19.Binding
							end

							if v382 then
								if p89.Hold then
									u362 = true
									p89.Callback(u362)

									return
								else
									p89.Callback()

									return
								end
							end

							if not t19.Binding then
								return
							end

							local KeyCode = nil

							local function v384()
								if IsInList(IgnoredKeys, p92.KeyCode) then
									return
								end

								KeyCode = p92.KeyCode
							end

							KeyCode = nil
							pcall(v384)

							local function v385()
								local v386 = IsInList(MouseInputTypes, p92.UserInputType)

								if v386 then
									v386 = not KeyCode
								end

								if not v386 then
									return
								end

								KeyCode = p92.UserInputType
							end

							pcall(v385)
							KeyCode = KeyCode or t19.Value
							t19:Set(KeyCode)
							SaveConfig(game.GameId)
						end

						if Orion:IsRunning() then
							local connection = InputBegan2:Connect(v381)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local InputEnded2 = UserInputService.InputEnded

						local function v390(p93)
							if not (p93.KeyCode.Name == t19.Value or p93.UserInputType.Name == t19.Value) then
								return
							end

							local Hold = p89.Hold

							if Hold then
								Hold = u362
							end

							if not Hold then
								return
							end

							u362 = false
							p89.Callback(u362)
						end

						if Orion:IsRunning() then
							local connection = InputEnded2:Connect(v390)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseEnter = v363.MouseEnter

						local function v395()
							local v396 = TweenService
							local v397 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local color3 = Color3.fromRGB
							local v400 = Orion.Themes[Orion.SelectedTheme].Second.R * 255 + 3
							local v401 = Orion.Themes[Orion.SelectedTheme].Second.G * 255 + 3
							local v402 = Orion.Themes[Orion.SelectedTheme].Second.B * 255

							v396.Create(v396, v397, tweenInfo, {
								BackgroundColor3 = color3(v400, v401, v402 + 3)
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = MouseEnter:Connect(v395)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseLeave = v363.MouseLeave

						local function v406()
							local v407 = TweenService
							local v408 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local Themes = Orion.Themes
							local v411 = Orion

							v407.Create(v407, v408, tweenInfo, {
								BackgroundColor3 = Themes[v411.SelectedTheme].Second
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = MouseLeave:Connect(v406)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseButton1Up3 = v363.MouseButton1Up

						local function v415()
							local v416 = TweenService
							local v417 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local color3 = Color3.fromRGB
							local v420 = Orion.Themes[Orion.SelectedTheme].Second.R * 255 + 3
							local Themes = Orion.Themes
							local v422 = Orion

							v416.Create(v416, v417, tweenInfo, {
								BackgroundColor3 = color3(v420, Themes[v422.SelectedTheme].Second.G * 255 + 3, Orion.Themes[Orion.SelectedTheme].Second.B * 255 + 3)
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = MouseButton1Up3:Connect(v415)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseButton1Down = v363.MouseButton1Down

						local function v426()
							local v427 = TweenService
							local v428 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local Color3_ = Color3

							v427.Create(v427, v428, tweenInfo, {
								BackgroundColor3 = Color3_.fromRGB(Orion.Themes[Orion.SelectedTheme].Second.R * 255 + 6, Orion.Themes[Orion.SelectedTheme].Second.G * 255 + 6, Orion.Themes[Orion.SelectedTheme].Second.B * 255 + 6)
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = MouseButton1Down:Connect(v426)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						function t19.Set(_, p94)
							t19.Binding = false
							t19.Value = p94 or t19.Value
							t19.Value = t19.Value.Name or t19.Value
							main2.Value.Text = t19.Value
						end

						t19:Set(p89.Default)

						if not p89.Flag then
							return t19
						end

						Orion.Flags[p89.Flag] = t19

						return t19
					end,
					AddTextbox = function(_, p95)
						local v433 = p95 or {}

						v433.Name = v433.Name or "Textbox"
						v433.Default = v433.Default or ""
						v433.TextDisappear = v433.TextDisappear or false
						v433.Callback = v433.Callback or function() end

						local v434 = SetProperties(NewElement("Button"), {
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
						local v437 = AddThemeObject
						local v438 = SetProperties(NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
							Size = UDim2.new(1, 0, 0, 38),
							Parent = p58
						})
						local t21 = {
							AddThemeObject(SetProperties(NewElement("Label", v433.Name, 15), {
								Size = UDim2.new(1, -12, 1, 0),
								Position = UDim2.new(0, 12, 0, 0),
								Font = Enum.Font.GothamBold,
								Name = "Content"
							}), "Text"),
							AddThemeObject(NewElement("Stroke"), "Stroke"),
							main2,
							v434
						}

						table.foreach(t21, function(_, p96)
							p96.Parent = v438
						end)

						local second4 = v437(v438, "Second")
						local signal3 = text2:GetPropertyChangedSignal("Text")

						local function v442()
							local v443 = TweenService
							local v444 = main2
							local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local uDim2New = UDim2.new
							local TextBounds = text2.TextBounds

							v443.Create(v443, v444, tweenInfo, {
								Size = uDim2New(0, TextBounds.X + 16, 0, 24)
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = signal3:Connect(v442)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local FocusLost = text2.FocusLost

						local function v451()
							v433.Callback(text2.Text)

							if not v433.TextDisappear then
								return
							end

							text2.Text = ""
						end

						if Orion:IsRunning() then
							local connection = FocusLost:Connect(v451)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						text2.Text = v433.Default

						local MouseEnter = v434.MouseEnter

						local function v455()
							local v456 = TweenService
							local v457 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local color3 = Color3.fromRGB
							local v460 = Orion.Themes[Orion.SelectedTheme].Second.R * 255 + 3
							local v461 = Orion.Themes[Orion.SelectedTheme].Second.G * 255 + 3
							local v462 = Orion.Themes[Orion.SelectedTheme]

							v456.Create(v456, v457, tweenInfo, {
								BackgroundColor3 = color3(v460, v461, v462.Second.B * 255 + 3)
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = MouseEnter:Connect(v455)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseLeave = v434.MouseLeave

						local function v466()
							local v467 = TweenService
							local v468 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local v470 = Orion.Themes[Orion.SelectedTheme]

							v467.Create(v467, v468, tweenInfo, {
								BackgroundColor3 = v470.Second
							}):Play()
						end

						if Orion:IsRunning() then
							local connection = MouseLeave:Connect(v466)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseButton1Up3 = v434.MouseButton1Up

						local function v474()
							local v475 = TweenService
							local v476 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local color3 = Color3.fromRGB
							local v479 = Orion.Themes[Orion.SelectedTheme].Second.R * 255 + 3
							local v480 = Orion.Themes[Orion.SelectedTheme].Second.G * 255 + 3
							local Themes = Orion.Themes

							v475.Create(v475, v476, tweenInfo, {
								BackgroundColor3 = color3(v479, v480, Themes[Orion.SelectedTheme].Second.B * 255 + 3)
							}):Play()
							text2:CaptureFocus()
						end

						if Orion:IsRunning() then
							local connection = MouseButton1Up3:Connect(v474)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local MouseButton1Down = v434.MouseButton1Down

						local function v485()
							local v486 = TweenService
							local v487 = second4
							local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							local color3 = Color3.fromRGB
							local v490 = Orion.Themes[Orion.SelectedTheme].Second.R * 255 + 6
							local v491 = Orion.Themes[Orion.SelectedTheme].Second.G * 255 + 6
							local v492 = Orion

							v486.Create(v486, v487, tweenInfo, {
								BackgroundColor3 = color3(v490, v491, v492.Themes[Orion.SelectedTheme].Second.B * 255 + 6)
							}):Play()
						end

						if not Orion:IsRunning() then
							return
						end

						local connection = MouseButton1Down:Connect(v485)
						local Connections = Orion.Connections

						table.insert(Connections, connection)
					end,
					AddColorpicker = function(_, p97)
						local v495 = p97 or {}

						v495.Name = v495.Name or "Colorpicker"
						v495.Default = v495.Default or Color3.fromRGB(255, 255, 255)
						v495.Callback = v495.Callback or function() end
						v495.Flag = v495.Flag or nil
						v495.Save = v495.Save or false

						local n1 = 1
						local n2 = 1
						local n3 = 1
						local ColorInput, HueInput = nil, nil
						local t22 = {
							Value = v495.Default,
							Toggled = false,
							Type = "Colorpicker",
							Save = v495.Save
						}
						local ImageLabel = CreateInstance("ImageLabel", {
							Size = UDim2.new(0, 18, 0, 18),
							Position = UDim2.new(select(3, Color3.toHSV(t22.Value))),
							ScaleType = Enum.ScaleType.Fit,
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							Image = "http://www.roblox.com/asset/?id=4805639000"
						})
						local ImageLabel2 = CreateInstance("ImageLabel", {
							Size = UDim2.new(0, 18, 0, 18),
							Position = UDim2.new(0.5, 0, 1 - select(1, Color3.toHSV(t22.Value))),
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
						local v505 = SetProperties(NewElement("Button"), {
							Size = UDim2.new(1, 0, 1, 0)
						})
						local main2 = AddThemeObject(SetChildren(SetProperties(NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
							Size = UDim2.new(0, 24, 0, 24),
							Position = UDim2.new(1, -12, 0.5, 0),
							AnchorPoint = Vector2.new(1, 0.5)
						}), { AddThemeObject(NewElement("Stroke"), "Stroke") }), "Main")
						local second4 = AddThemeObject(SetChildren(SetProperties(NewElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
							Size = UDim2.new(1, 0, 0, 38),
							Parent = p58
						}), { SetProperties(SetChildren(NewElement("TFrame"), {
								AddThemeObject(SetProperties(NewElement("Label", v495.Name, 15), {
									Size = UDim2.new(1, -12, 1, 0),
									Position = UDim2.new(0, 12, 0, 0),
									Font = Enum.Font.GothamBold,
									Name = "Content"
								}), "Text"),
								main2,
								v505,
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
						local MouseButton1Click2 = v505.MouseButton1Click

						local function toggleToggled()
							t22.Toggled = not t22.Toggled

							local v510 = TweenService
							local v511 = second4
							local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
							local Toggled = t22.Toggled

							if not Toggled then
								v510:Create(v511, tweenInfo, {
									Size = Toggled or UDim2.new(1, 0, 0, 38)
								}):Play()
								ImageLabel3.Visible = t22.Toggled
								Frame.Visible = t22.Toggled
								second4.F.Line.Visible = t22.Toggled

								return
							end

							Toggled = UDim2.new(1, 0, 0, 148)
							v510:Create(v511, tweenInfo, {
								Size = Toggled or UDim2.new(1, 0, 0, 38)
							}):Play()
							ImageLabel3.Visible = t22.Toggled
							Frame.Visible = t22.Toggled
							second4.F.Line.Visible = t22.Toggled
						end

						if Orion:IsRunning() then
							local connection = MouseButton1Click2:Connect(toggleToggled)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local function v516()
							main2.BackgroundColor3 = Color3.fromHSV(n1, n2, n3)
							ImageLabel3.BackgroundColor3 = Color3.fromHSV(n1, 1, 1)
							t22:Set(main2.BackgroundColor3)
							v495.Callback(main2.BackgroundColor3)
							SaveConfig(game.GameId)
						end

						local v517 = ImageLabel2.AbsolutePosition.Y - Frame.AbsolutePosition.Y
						local Y = Frame.AbsoluteSize.Y
						local _ = 1 - math.clamp(v517, 0, Y) / Frame.AbsoluteSize.Y
						local v520 = ImageLabel.AbsolutePosition.X - ImageLabel3.AbsolutePosition.X
						local X = ImageLabel3.AbsoluteSize.X
						local _ = math.clamp(v520, 0, X) / ImageLabel3.AbsoluteSize.X
						local v523 = ImageLabel.AbsolutePosition.Y - ImageLabel3.AbsolutePosition.Y
						local Y2 = ImageLabel3.AbsoluteSize.Y
						local _ = 1 - math.clamp(v523, 0, Y2) / ImageLabel3.AbsoluteSize.Y
						local InputBegan2 = ImageLabel3.InputBegan

						local function v527(p98)
							if p98.UserInputType ~= Enum.UserInputType.MouseButton1 then
								return
							end

							if ColorInput then
								ColorInput:Disconnect()
							end

							local RenderStepped = RunService.RenderStepped

							local function v529()
								local v530 = mouse.X - ImageLabel3.AbsolutePosition.X
								local X2 = ImageLabel3.AbsoluteSize.X
								local v532 = math.clamp(v530, 0, X2) / ImageLabel3.AbsoluteSize.X
								local v533 = mouse.Y - ImageLabel3.AbsolutePosition.Y
								local Y3 = ImageLabel3.AbsoluteSize.Y
								local v535 = math.clamp(v533, 0, Y3) / ImageLabel3.AbsoluteSize.Y

								ImageLabel.Position = UDim2.new(v532, 0, v535, 0)

								local _ = 1 - v535

								v516()
							end

							local connection

							if Orion:IsRunning() then
								connection = RenderStepped:Connect(v529)

								local Connections = Orion.Connections

								table.insert(Connections, connection)
							else
								connection = nil
							end

							ColorInput = connection
						end

						if Orion:IsRunning() then
							local connection = InputBegan2:Connect(v527)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local InputEnded = ImageLabel3.InputEnded

						local function v542(p99)
							if not (p99.UserInputType == Enum.UserInputType.MouseButton1 and ColorInput) then
								return
							end

							ColorInput:Disconnect()
						end

						if Orion:IsRunning() then
							local connection = InputEnded:Connect(v542)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local InputBegan3 = Frame.InputBegan

						local function v546(p100)
							if p100.UserInputType ~= Enum.UserInputType.MouseButton1 then
								return
							end

							if HueInput then
								HueInput:Disconnect()
							end

							local RenderStepped = RunService.RenderStepped

							local function v548()
								local v549 = mouse.Y - Frame.AbsolutePosition.Y
								local Y3 = Frame.AbsoluteSize.Y
								local v551 = math.clamp(v549, 0, Y3) / Frame.AbsoluteSize.Y

								ImageLabel2.Position = UDim2.new(0.5, 0, v551, 0)

								local _ = 1 - v551

								v516()
							end

							local connection

							if Orion:IsRunning() then
								connection = RenderStepped:Connect(v548)

								local Connections = Orion.Connections

								table.insert(Connections, connection)
							else
								connection = nil
							end

							HueInput = connection
						end

						if Orion:IsRunning() then
							local connection = InputBegan3:Connect(v546)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						local InputEnded2 = Frame.InputEnded

						local function v558(p101)
							if not (p101.UserInputType == Enum.UserInputType.MouseButton1 and HueInput) then
								return
							end

							HueInput:Disconnect()
						end

						if Orion:IsRunning() then
							local connection = InputEnded2:Connect(v558)
							local Connections = Orion.Connections

							table.insert(Connections, connection)
						end

						function t22.Set(_, p102)
							t22.Value = p102
							main2.BackgroundColor3 = t22.Value
							v495.Callback(t22.Value)
						end

						t22:Set(t22.Value)

						if not v495.Flag then
							return t22
						end

						Orion.Flags[v495.Flag] = t22

						return t22
					end
				}
			end

			local t23 = {
				AddSection = function(_, p103)
					p103.Name = p103.Name or "Section"

					local v562 = SetChildren
					local TFrame = NewElement("TFrame")
					local t24 = {
						Size = UDim2.new(1, 0, 0, 26),
						Parent = divider3
					}

					table.foreach(t24, function(p104, p105)
						TFrame[p104] = p105
					end)

					local v565 = v562(TFrame, { AddThemeObject(SetProperties(NewElement("Label", p103.Name, 14), {
							Size = UDim2.new(1, -12, 0, 16),
							Position = UDim2.new(0, 0, 0, 3),
							Font = Enum.Font.GothamSemibold
						}), "TextDark"), SetChildren(SetProperties(NewElement("TFrame"), {
							AnchorPoint = Vector2.new(0, 0),
							Size = UDim2.new(1, 0, 1, -24),
							Position = UDim2.new(0, 0, 0, 23),
							Name = "Holder"
						}), { NewElement("List", 0, 6) }) })
					local signal3 = v565.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize")

					local function v567()
						v565.Size = UDim2.new(1, 0, 0, v565.Holder.UIListLayout.AbsoluteContentSize.Y + 31)
						v565.Holder.Size = UDim2.new(1, 0, 0, v565.Holder.UIListLayout.AbsoluteContentSize.Y)
					end

					local v568

					if not Orion:IsRunning() then
						local v667 = next
						local v668, v669 = v178(v565.Holder)
						local v670 = {}

						while true do
							v669, v568 = v667(v668, v669)

							if not v669 then
								break
							end

							v670[v669] = v568
						end

						return v670
					end

					local connection = signal3:Connect(v567)
					local Connections = Orion.Connections

					table.insert(Connections, connection)

					local next_ = next
					local v572, key = v178(v565.Holder)
					local t25 = {}

					while true do
						key, v568 = next_(v572, key)

						if not key then
							break
						end

						t25[key] = v568
					end

					return t25
				end
			}
			local next_ = next
			local v576, key = v178(divider3)

			while true do
				local v578

				key, v578 = next_(v576, key)

				if not key then
					break
				end

				t23[key] = v578
			end

			local v579

			if v153.PremiumOnly then
				local next_2 = next

				v579 = t23

				local key2 = nil

				while true do
					local v582

					key2, v582 = next_2(t23, key2)

					if not key2 then
						break
					end

					v579[key2] = function() end
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
				v579 = t23
			end

			return v579
		end
	}
end
function Orion.Destroy(_)
	ScreenGui:Destroy()
end

return Orion
