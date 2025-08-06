-- Distance Esp 

if game.CoreGui:FindFirstChild("NexusEspGui") then game.CoreGui.NexusEspGui:Destroy() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "NexusEspGui"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 140, 0, 160)
Frame.Position = UDim2.new(0, 10, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local UIListLayout = Instance.new("UIListLayout", Frame)
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", Frame)
title.Text = "Nexus ESP"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, 0, 0, 25)

local function createToggle(name, callback)
    local toggle = Instance.new("TextButton", Frame)
    toggle.Size = UDim2.new(1, -10, 0, 22)
    toggle.Position = UDim2.new(0, 5, 0, 0)
    toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    toggle.Text = name .. ": OFF"
    toggle.Font = Enum.Font.Gotham
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)

    local corner = Instance.new("UICorner", toggle)
    corner.CornerRadius = UDim.new(0, 6)

    local state = false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = name .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

local NameTags, Boxes, HealthBars, Distances = {}, {}, {}, {}

local function createBillboard(size, offset)
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, size.X, 0, size.Y)
    bb.AlwaysOnTop = true
    bb.StudsOffset = offset
    return bb
end

createToggle("NameTag ESP", function(state)
    for _, v in pairs(NameTags) do if v then v:Destroy() end end
    NameTags = {}
    if not state then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local tag = createBillboard(Vector2.new(100, 20), Vector3.new(0, 2.5, 0))
            tag.Name = "NameTag"
            tag.Parent = player.Character.Head

            local nameLabel = Instance.new("TextLabel", tag)
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.new(1, 1, 1)
            nameLabel.TextStrokeTransparency = 0
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 14
            nameLabel.Text = player.Name

            NameTags[player] = tag
        end
    end
end)

createToggle("Box ESP", function(state)
    for _, v in pairs(Boxes) do if v then v:Destroy() end end
    Boxes = {}
    if not state then return end

    RunService.RenderStepped:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp and not Boxes[player] then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Adornee = hrp
                    box.Size = Vector3.new(4, 6, 2)
                    box.Transparency = 0.5
                    box.Color3 = Color3.fromRGB(0, 170, 255)
                    box.AlwaysOnTop = true
                    box.ZIndex = 5
                    box.Parent = hrp
                    Boxes[player] = box
                end
            end
        end
    end)
end)

createToggle("HealthBar ESP", function(state)
    for _, v in pairs(HealthBars) do if v then v:Destroy() end end
    HealthBars = {}
    if not state then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") then
            local tag = createBillboard(Vector2.new(6, 50), Vector3.new(-3, 2, 0))
            tag.Name = "HealthBar"
            tag.Parent = player.Character.Head

            local bar = Instance.new("Frame", tag)
            bar.Size = UDim2.new(1, 0, 1, 0)
            bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)

            HealthBars[player] = { Gui = tag, Bar = bar, Humanoid = player.Character:FindFirstChild("Humanoid") }

            RunService.RenderStepped:Connect(function()
                if HealthBars[player] then
                    local h = HealthBars[player]
                    if h.Humanoid and h.Bar then
                        local hp = h.Humanoid.Health / h.Humanoid.MaxHealth
                        h.Bar.Size = UDim2.new(1, 0, hp, 0)
                        h.Bar.Position = UDim2.new(0, 0, 1 - hp, 0)
                        h.Bar.BackgroundColor3 = Color3.fromRGB(255 - (255 * hp), 255 * hp, 0)
                    end
                end
            end)
        end
    end
end)

createToggle("Distance ESP", function(state)
    for _, v in pairs(Distances) do if v then v:Destroy() end end
    Distances = {}
    if not state then return end

    RunService.RenderStepped:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                if not Distances[player] then
                    local tag = createBillboard(Vector2.new(80, 16), Vector3.new(0, 1.8, 0))
                    tag.Name = "Distance"
                    tag.Parent = player.Character.Head

                    local label = Instance.new("TextLabel", tag)
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Color3.fromRGB(255, 255, 0)
                    label.TextStrokeTransparency = 0
                    label.Font = Enum.Font.Gotham
                    label.TextSize = 12
                    label.Text = ""

                    Distances[player] = { Gui = tag, Label = label }
                end

                local dist = (player.Character.Head.Position - LocalPlayer.Character.Head.Position).Magnitude
                if Distances[player] then
                    Distances[player].Label.Text = string.format("%.0f studs", dist)
                end
            end
        end
    end)
end)
