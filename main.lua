--==================================================
-- FDX HUB | Steal a Brainrots
-- Main Script (All-in-One)
--==================================================

--========================
-- [1] SERVICES
--========================
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

--========================
-- [2] CORE TABLE
--========================
local FDX = {
    Config = {},
    UI = {},
    Servers = {},
    Scanner = {},
    History = {},
    State = {}
}

--========================
-- [3] CONFIG
--========================
FDX.Config = {
    UIKeybind = Enum.KeyCode.RightShift,
    AutoScan = true,
    ScanInterval = 15,
    MinPrice = 100000,
    MaxServers = 50,
    SaveHistory = true,
    AutoRejoin = true,
    AntiAFK = true,
    FPSBoost = true
}

--========================
-- [4] UTILS
--========================
function FDX:SafeCall(fn)
    local ok, err = pcall(fn)
    if not ok then
        warn("[FDX ERROR]", err)
    end
end

function FDX:Notify(txt)
    print("[FDX]", txt)
end

--========================
-- [5] HISTORY SYSTEM
--========================
FDX.History.Data = getgenv().FDX_HISTORY or {}
getgenv().FDX_HISTORY = FDX.History.Data

function FDX.History:Add(entry)
    table.insert(self.Data, entry)
end

--========================
-- [6] SERVER SYSTEM
--========================
function FDX.Servers:GetPublicServers()
    local servers = {}
    local url =
        "https://games.roblox.com/v1/games/"
        .. game.PlaceId
        .. "/servers/Public?limit=100"

    local ok, res = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok then return servers end

    local data = HttpService:JSONDecode(res)
    if not data or not data.data then return servers end

    for _, s in pairs(data.data) do
        if s.id ~= game.JobId then
            table.insert(servers, {
                JobId = s.id,
                Players = s.playing or 0,
                Max = s.maxPlayers or 0
            })
        end
        if #servers >= FDX.Config.MaxServers then
            break
        end
    end

    return servers
end

function FDX.Servers:Join(jobId)
    TeleportService:TeleportToPlaceInstance(
        game.PlaceId,
        jobId,
        LocalPlayer
    )
end

--========================
-- [7] BRAINROT SCANNER
--========================
function FDX.Scanner:ScanCurrentServer()
    local best = nil
    local container =
        workspace:FindFirstChild("Brainrots")
        or workspace:FindFirstChild("Items")
        or workspace

    for _, obj in pairs(container:GetChildren()) do
        if obj:FindFirstChild("Price") and obj:FindFirstChild("Name") then
            local price = obj.Price.Value
            if price >= FDX.Config.MinPrice then
                if not best or price > best.Price then
                    best = {
                        Name = obj.Name.Value,
                        Price = price
                    }
                end
            end
        end
    end

    if best and FDX.Config.SaveHistory then
        FDX.History:Add({
            JobId = game.JobId,
            Name = best.Name,
            Price = best.Price,
            Time = os.time()
        })
    end

    return best
end

--========================
-- [8] UI SYSTEM
--========================
function FDX.UI:Init()
    local gui = Instance.new("ScreenGui")
    gui.Name = "FDXHubUI"
    gui.ResetOnSpawn = false

    pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)
    if not gui.Parent then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 420, 0, 300)
    main.Position = UDim2.new(0.5, -210, 0.3, 0)
    main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    main.BorderSizePixel = 0

    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    title.Text = "FDX HUB | Steal a Brainrots"
    title.TextColor3 = Color3.fromRGB(0, 200, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16

    local content = Instance.new("ScrollingFrame", main)
    content.Position = UDim2.new(0, 10, 0, 50)
    content.Size = UDim2.new(1, -20, 1, -60)
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.BackgroundTransparency = 1

    FDX.UI.Gui = gui
    FDX.UI.Content = content
    FDX.UI.Main = main

    -- Toggle UI
    UserInputService.InputBegan:Connect(function(i, g)
        if g then return end
        if i.KeyCode == FDX.Config.UIKeybind then
            main.Visible = not main.Visible
        end
    end)
end

function FDX.UI:Refresh()
    local content = self.Content
    for _, c in pairs(content:GetChildren()) do
        if c:IsA("Frame") then
            c:Destroy()
        end
    end

    local y = 0

    for _, entry in pairs(FDX.History.Data) do
        local row = Instance.new("Frame", content)
        row.Size = UDim2.new(1, 0, 0, 36)
        row.Position = UDim2.new(0, 0, 0, y)
        row.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

        local txt = Instance.new("TextLabel", row)
        txt.Size = UDim2.new(0.7, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.TextXAlignment = Left
        txt.Text =
            entry.Name
            .. " | $"
            .. entry.Price
        txt.TextColor3 = Color3.fromRGB(200, 255, 200)
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 13

        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(0.25, 0, 0.7, 0)
        btn.Position = UDim2.new(0.73, 0, 0.15, 0)
        btn.Text = "JOIN"
        btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        btn.TextColor3 = Color3.new(1, 1, 1)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            FDX.Servers:Join(entry.JobId)
        end)

        y = y + 42
    end

    content.CanvasSize = UDim2.new(0, 0, 0, y)
end

--========================
-- [9] QOL
--========================
if FDX.Config.AntiAFK then
    pcall(function()
        LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)
        end)
    end)
end

if FDX.Config.FPSBoost then
    pcall(function()
        Lighting.GlobalShadows = false
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") then
                v.Enabled = false
            end
        end
    end)
end

--========================
-- [10] LOOPS
--========================
task.spawn(function()
    while true do
        FDX:SafeCall(function()
            local best = FDX.Scanner:ScanCurrentServer()
            if best then
                FDX:Notify("Best Found: " .. best.Name .. " $" .. best.Price)
                FDX.UI:Refresh()
            end
        end)
        task.wait(FDX.Config.ScanInterval)
    end
end)

--========================
-- [11] INIT
--========================
FDX.UI:Init()
FDX:Notify("FDX HUB Loaded Successfully")
