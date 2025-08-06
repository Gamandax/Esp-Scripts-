-- HealthBar Esp

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

pcall(function() CoreGui:FindFirstChild("NexusESP"):Destroy() end)

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "NexusESP"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 180, 0, 100)
Frame.Position = UDim2.new(0, 20, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "Nexus ESP"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold

local HealthESP = Instance.new("TextButton", Frame)
HealthESP.Size = UDim2.new(1, -20, 0, 25)
HealthESP.Position = UDim2.new(0, 10, 0, 35)
HealthESP.Text = "🔋 Health Bar ESP [OFF]"
HealthESP.TextColor3 = Color3.fromRGB(255, 255, 255)
HealthESP.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
HealthESP.Font = Enum.Font.Gotham
HealthESP.TextSize = 14
HealthESP.AutoButtonColor = true

local HealthESPEnabled = false
local Bars = {}

local function CreateHealthBar(plr)
    if plr == LocalPlayer then return end
    local bar = Drawing.new("Line")
    bar.Thickness = 4
    bar.Transparency = 1
    bar.Visible = false
    Bars[plr] = bar
end

Players.PlayerRemoving:Connect(function(plr)
    if Bars[plr] then
        Bars[plr]:Remove()
        Bars[plr] = nil
    end
end)

HealthESP.MouseButton1Click:Connect(function()
    HealthESPEnabled = not HealthESPEnabled
    HealthESP.Text = HealthESPEnabled and "🔋 Health Bar ESP [ON]" or "🔋 Health Bar ESP [OFF]"
    if not HealthESPEnabled then
        for _,v in pairs(Bars) do v.Visible = false end
    end
end)

for _,plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        CreateHealthBar(plr)
    end
end

Players.PlayerAdded:Connect(function(plr)
    task.wait(1)
    CreateHealthBar(plr)
end)

RunService.RenderStepped:Connect(function()
    if not HealthESPEnabled then return end
    for plr, bar in pairs(Bars) do
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
            local hrp = char.HumanoidRootPart
            local hum = char:FindFirstChildOfClass("Humanoid")
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local healthRatio = hum.Health / hum.MaxHealth
                local barHeight = 50
                local topY = pos.Y - (barHeight / 2)
                local bottomY = topY + (barHeight * healthRatio)
                bar.Visible = true
                bar.From = Vector2.new(pos.X - 25, bottomY)
                bar.To = Vector2.new(pos.X - 25, topY)
                bar.Color = Color3.fromRGB(
                    255 - (healthRatio * 255),
                    (healthRatio * 255),
                    0
                )
            else
                bar.Visible = false
            end
        else
            bar.Visible = false
        end
    end
end)
