local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("Main Loaded!")

local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local label = Instance.new("TextLabel", gui)

label.Size = UDim2.new(0,300,0,50)
label.Position = UDim2.new(0.5,-150,0.5,-25)
label.Text = "FDX HUB WORKING"
label.TextScaled = true
