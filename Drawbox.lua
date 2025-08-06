-- Drawing Box Esp

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.ResetOnSpawn = false
ScreenGui.Name = "Nexus Esp"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 130, 0, 50)
Frame.Position = UDim2.new(0, 20, 0.5, -25)
Frame.BackgroundTransparency = 0.4
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local Toggle = Instance.new("TextButton", Frame)
Toggle.Size = UDim2.new(1, 0, 1, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Toggle.Text = "ESP: OFF"
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 14
Toggle.BorderSizePixel = 0

-- ESP System
local ESPEnabled = false
local ESPConnections = {}
local ESPDrawings = {}

function CreateESP(player)
	if not player.Character then return end
	if player == LocalPlayer then return end

	local nameBillboard = Instance.new("BillboardGui")
	nameBillboard.Size = UDim2.new(0, 100, 0, 20)
	nameBillboard.AlwaysOnTop = true
	nameBillboard.Name = "NexusNameESP"

	local nameLabel = Instance.new("TextLabel", nameBillboard)
	nameLabel.Size = UDim2.new(1, 0, 1, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Text = player.Name

	local box = Drawing.new("Square")
	box.Color = Color3.new(1, 1, 1)
	box.Thickness = 1.5
	box.Transparency = 1
	box.Filled = false
	box.Visible = false

	local function update()
		if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

		local hrp = player.Character.HumanoidRootPart
		nameBillboard.Adornee = hrp
		nameBillboard.Parent = hrp

		local head = player.Character:FindFirstChild("Head")
		if not head then return end

		local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
		if onScreen then
			local size = Vector3.new(2, 3, 1.5)
			local topLeft = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position + Vector3.new(-size.X, size.Y, 0))
			local bottomRight = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position + Vector3.new(size.X, -size.Y, 0))
			box.Size = Vector2.new(math.abs(topLeft.X - bottomRight.X), math.abs(topLeft.Y - bottomRight.Y))
			box.Position = Vector2.new(math.min(topLeft.X, bottomRight.X), math.min(topLeft.Y, bottomRight.Y))
			box.Visible = true
		else
			box.Visible = false
		end
	end

	local conn = RunService.RenderStepped:Connect(update)
	table.insert(ESPConnections, conn)
	table.insert(ESPDrawings, {billboard = nameBillboard, box = box})
end

function ClearESP()
	for _, conn in pairs(ESPConnections) do
		if conn then conn:Disconnect() end
	end
	for _, obj in pairs(ESPDrawings) do
		if obj.billboard then obj.billboard:Destroy() end
		if obj.box then obj.box:Remove() end
	end
	ESPConnections = {}
	ESPDrawings = {}
end

Toggle.MouseButton1Click:Connect(function()
	ESPEnabled = not ESPEnabled
	Toggle.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"

	if ESPEnabled then
		for _, player in pairs(Players:GetPlayers()) do
			CreateESP(player)
		end
	else
		ClearESP()
	end
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		if ESPEnabled then task.wait(1) CreateESP(player) end
	end)
end)

LocalPlayer.CharacterAdded:Connect(function()
	if ESPEnabled then
		task.wait(1)
		ClearESP()
		for _, player in pairs(Players:GetPlayers()) do
			CreateESP(player)
		end
	end
end)
