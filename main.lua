--==================================================
-- FDX HUB | Steal a Brainrots
-- Professional All-in-One Main.lua
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
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

--========================
-- [2] GLOBAL CORE
--========================
local FDX = {
    Config = {},
    UI = {},
    Servers = {},
    Scanner = {},
    History = {},
    State = {
        Loaded = false
    }
}

--========================
-- [3] CONFIG
--========================
FDX.Config = {
    UIKeybind = Enum.KeyCode.RightShift,
    ScanInterval = 15,
    MinPrice = 100000,
    MaxServers = 50,
    SaveHistory = true,
    FPSBoost = true,
    AntiAFK = true
}

--========================
-- [4] UTILS
--========================
function FDX:Safe(fn)
    local ok, err = pcall(fn)
    if not ok then
        warn("[FDX ERROR]", err)
    end
end

function FDX:Log(msg)
    print("[FDX]", msg)
end

--========================
-- [5] HISTORY SYSTEM
--========================
getgenv().FDX_HISTORY = getgenv().FDX_HISTORY or {}
FDX.History.Data = getgenv().FDX_HISTORY

function FDX.History:Add(data)
    table.insert(self.Data, data)
end

-- Dummy data (عشان UI ما يكون فاضي)
if #FDX.History.Data == 0 then
    table.insert(FDX.History.Data, {
        JobId = game.JobId,
        Name = "Golden Brainrot",
        Price = 999999,
        Time = os.time()
    })
end

--========================
-- [6] SERVER SYSTEM
--========================
function FDX.Servers:GetPublic()
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

    for _, s in ipairs(data.data) do
        if s.id ~= game.JobId then
            table.insert(servers, {
                JobId = s.id,
                Players = s.playing or 0,
                MaxPlayers = s.maxPlayers or 0
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
function FDX.Scanner:ScanCurrent()
    local best = nil
    local container =
        workspace:FindFirstChild("Brainrots")
        or workspace:FindFirstChild("Items")
        or workspace

    for _, obj in ipairs(container:GetChildren()) do
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
    -- تنظيف قديم
    pcall(function()
        game:GetService("CoreGui"):FindFirstChild("FDXHubUI"):Destroy()
    end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "FDXHubUI"
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("CoreGui")

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 450, 0, 320)
    main.Position = UDim2.new(0.5, -225, 0.3, 0)
    main.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    main.BorderSizePixel = 0
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 42)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    title.Text = "FDX HUB | Steal a Brainrots"
    title.TextColor3 = Color3.fromRGB(0, 200, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

    local content = Instance.new("ScrollingFrame", main)
    content.Position = UDim2.new(0, 10, 0, 52)
    content.Size = UDim2.new(1, -20, 1, -62)
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.ScrollBarImageTransparency = 0.4
    content.BackgroundTransparency = 1

    -- Drag
    do
        local dragging, dragInput, dragStart, startPos
        title.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = main.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        title.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                main.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    FDX.UI.Gui = gui
    FDX.UI.Main = main
    FDX.UI.Content = content

    -- Toggle
    UserInputService.InputBegan:Connect(function(i, g)
        if g then return end
        if i.KeyCode == FDX.Config.UIKeybind then
            main.Visible = not main.Visible
        end
    end)
end

function FDX.UI:Refresh()
    local content = self.Content
    for _, c in ipairs(content:GetChildren()) do
        if c:IsA("Frame") then
            c:Destroy()
        end
    end

    local y = 0
    for _, entry in ipairs(FDX.History.Data) do
        local row = Instance.new("Frame", content)
        row.Size = UDim2.new(1, 0, 0, 38)
        row.Position = UDim2.new(0, 0, 0, y)
        row.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

        local txt = Instance.new("TextLabel", row)
        txt.Size = UDim2.new(0.7, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.Position = UDim2.new(0, 10, 0, 0)
        txt.Text = entry.Name .. " | $" .. entry.Price
        txt.TextColor3 = Color3.fromRGB(200, 255, 200)
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 13

        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(0.25, 0, 0.7, 0)
        btn.Position = UDim2.new(0.72, 0, 0.15, 0)
        btn.Text = "JOIN"
        btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        btn.MouseButton1Click:Connect(function()
            FDX.Servers:Join(entry.JobId)
        end)

        y += 44
    end

    content.CanvasSize = UDim2.new(0, 0, 0, y)
end

--========================
-- [9] QOL
--========================
if FDX.Config.AntiAFK then
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)
    end)
end

if FDX.Config.FPSBoost then
    Lighting.GlobalShadows = false
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") then
            v.Enabled = false
        end
    end
end

--========================
-- [10] LOOPS
--========================
task.spawn(function()
    while true do
        FDX:Safe(function()
            local best = FDX.Scanner:ScanCurrent()
            if best then
                FDX:Log("Found: " .. best.Name .. " $" .. best.Price)
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
FDX.UI:Refresh()
FDX.State.Loaded = true
FDX:Log("FDX HUB Loaded Successfully")
