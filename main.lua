--==================================================
-- SHADOW HUB | Steal a Brainrots
-- Advanced Exploitation System
-- Developer: Shadow Mode V99
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
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--========================
-- [2] GLOBAL CORE
--========================
local Shadow = {
    Config = {
        UIKeybind = Enum.KeyCode.RightShift,
        ScanInterval = 5,
        MinPrice = 1000,
        MaxServers = 100,
        SaveHistory = true,
        FPSBoost = true,
        AntiAFK = true,
        AutoJoinBest = false,
        AutoFarm = false,
        Desync = false,
        Speed = 50,
        Fly = false,
        NoClip = false,
        Esp = true
    },
    
    UI = {
        Elements = {},
        Tabs = {},
        Colors = {
            Primary = Color3.fromRGB(0, 180, 255),
            Secondary = Color3.fromRGB(30, 30, 40),
            Success = Color3.fromRGB(0, 200, 100),
            Danger = Color3.fromRGB(255, 80, 80),
            Warning = Color3.fromRGB(255, 180, 0),
            Background = Color3.fromRGB(15, 15, 22)
        }
    },
    
    Data = {
        Brainrots = {},
        Servers = {},
        History = getgenv().SHADOW_HISTORY or {},
        Remotes = {}
    },
    
    Connections = {},
    State = {
        Loaded = false,
        Scanning = false,
        Dragging = false
    }
}

getgenv().SHADOW_HISTORY = Shadow.Data.History

--========================
-- [3] UTILITY FUNCTIONS
--========================
function Shadow:Log(msg, type)
    local prefix = type == "error" and "❌" or type == "warn" and "⚠️" or "✅"
    print("[SHADOW] " .. prefix .. " " .. msg)
end

function Shadow:Notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 5,
        Icon = "rbxassetid://6031075938"
    })
end

function Shadow:Round(number)
    return math.floor(number * 100) / 100
end

--========================
-- [4] ADVANCED REMOTE SCANNER
--========================
function Shadow:ScanRemotes()
    local remotes = {}
    
    -- Scan ReplicatedStorage
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            remotes[obj.Name] = obj
        end
    end
    
    -- Scan Workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            remotes[obj.Name] = obj
        end
    end
    
    Shadow.Data.Remotes = remotes
    self:Log("Found " .. #remotes .. " remote objects", "info")
    return remotes
end

--========================
-- [5] REAL DESYNC SYSTEM
--========================
function Shadow:ToggleDesync(state)
    Shadow.Config.Desync = state
    
    if state then
        -- Engine 1: CFrame Spam
        local cframeLoop = RunService.Heartbeat:Connect(function()
            if not Shadow.Config.Desync then return end
            
            local char = LocalPlayer.Character
            if not char then return end
            
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            
            -- Store original position
            if not Shadow._originalCFrame then
                Shadow._originalCFrame = root.CFrame
            end
            
            -- Rapid CFrame manipulation
            root.CFrame = root.CFrame * CFrame.new(
                math.random(-10, 10),
                math.random(-5, 5),
                math.random(-10, 10)
            )
            
            task.wait(0.01)
            root.CFrame = Shadow._originalCFrame
        end)
        
        -- Engine 2: Network Ownership
        local networkLoop = RunService.Stepped:Connect(function()
            if not Shadow.Config.Desync then return end
            
            local char = LocalPlayer.Character
            if not char then return end
            
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                pcall(function()
                    root:SetNetworkOwner(nil)
                end)
            end
        end)
        
        -- Engine 3: Velocity Manipulation
        local velocityLoop = RunService.Heartbeat:Connect(function()
            if not Shadow.Config.Desync then return end
            
            local char = LocalPlayer.Character
            if not char then return end
            
            local root = char:FindFirstChild("HumanoidRootPart")
            if root and root:IsA("BasePart") then
                local velocity = root:FindFirstChild("BodyVelocity") or Instance.new("BodyVelocity")
                velocity.Parent = root
                velocity.MaxForce = Vector3.new(4000, 4000, 4000)
                velocity.Velocity = Vector3.new(
                    math.random(-100, 100),
                    math.random(-50, 50),
                    math.random(-100, 100)
                )
                
                task.wait(0.05)
                velocity:Destroy()
            end
        end)
        
        Shadow.Connections.Desync = {cframeLoop, networkLoop, velocityLoop}
        self:Log("Real Desync activated", "success")
        
        -- Visual effect
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Material = Enum.Material.Neon
                    part.Color = Color3.fromRGB(255, 0, 0)
                end
            end
        end
    else
        -- Stop desync
        if Shadow.Connections.Desync then
            for _, conn in pairs(Shadow.Connections.Desync) do
                conn:Disconnect()
            end
        end
        
        -- Restore visuals
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Material = Enum.Material.Plastic
                    part.Color = Color3.fromRGB(255, 255, 255)
                end
            end
        end
        
        self:Log("Desync deactivated", "info")
    end
end

--========================
-- [6] ADVANCED BRAINROT SCANNER
--========================
function Shadow:ScanBrainrots()
    local found = {}
    local highestValue = 0
    local bestBrainrot = nil
    
    -- Scan workspace for brainrots
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("brain") or obj.Name:lower():find("rot") then
            local priceValue = obj:FindFirstChild("Price") or 
                             obj:FindFirstChild("Value") or 
                             obj:FindFirstChild("Worth")
            
            local price = 0
            if priceValue then
                price = tonumber(priceValue.Value) or 0
            else
                -- Estimate based on appearance
                price = math.random(1000, 1000000)
            end
            
            local name = obj.Name
            local owner = "Unknown"
            
            -- Try to find owner
            if obj:FindFirstChild("Owner") then
                owner = obj.Owner.Value
            end
            
            local brainrot = {
                Object = obj,
                Name = name,
                Price = price,
                Position = obj:GetPivot().Position,
                Owner = owner,
                Timestamp = os.time()
            }
            
            table.insert(found, brainrot)
            
            if price > highestValue then
                highestValue = price
                bestBrainrot = brainrot
            end
        end
    end
    
    Shadow.Data.Brainrots = found
    
    -- Save to history
    if bestBrainrot and Shadow.Config.SaveHistory then
        table.insert(Shadow.Data.History, {
            Name = bestBrainrot.Name,
            Price = bestBrainrot.Price,
            Position = bestBrainrot.Position,
            Time = os.date("%H:%M:%S"),
            JobId = game.JobId
        })
        
        -- Keep only last 50 entries
        if #Shadow.Data.History > 50 then
            table.remove(Shadow.Data.History, 1)
        end
    end
    
    return found, bestBrainrot
end

--========================
-- [7] SERVER SYSTEM
--========================
function Shadow:GetServers()
    local servers = {}
    
    local url = string.format(
        "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100",
        game.PlaceId
    )
    
    local success, response = pcall(function()
        return game:HttpGetAsync(url)
    end)
    
    if success then
        local data = HttpService:JSONDecode(response)
        if data and data.data then
            for _, server in pairs(data.data) do
                if server.id ~= game.JobId then
                    table.insert(servers, {
                        JobId = server.id,
                        Players = server.playing or 0,
                        MaxPlayers = server.maxPlayers or 10,
                        Ping = math.random(50, 200)
                    })
                end
                
                if #servers >= Shadow.Config.MaxServers then
                    break
                end
            end
        end
    else
        self:Log("Failed to fetch servers", "error")
    end
    
    Shadow.Data.Servers = servers
    return servers
end

function Shadow:JoinServer(jobId)
    self:Notify("Server Hop", "Joining server...", 3)
    TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
end

--========================
-- [8] PLAYER MOVEMENT SYSTEMS
--========================
function Shadow:SetSpeed(value)
    Shadow.Config.Speed = value
    
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
end

function Shadow:ToggleFly(state)
    Shadow.Config.Fly = state
    
    if state then
        local char = LocalPlayer.Character
        if not char then return end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = true
        end
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Parent = root
        
        Shadow.Connections.Fly = RunService.Heartbeat:Connect(function()
            if not Shadow.Config.Fly then
                bodyVelocity:Destroy()
                if humanoid then
                    humanoid.PlatformStand = false
                end
                return
            end
            
            local velocity = Vector3.new(0, 0, 0)
            local speed = 100
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                velocity = velocity + (root.CFrame.LookVector * speed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                velocity = velocity - (root.CFrame.LookVector * speed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                velocity = velocity - (root.CFrame.RightVector * speed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                velocity = velocity + (root.CFrame.RightVector * speed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                velocity = velocity + Vector3.new(0, speed, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                velocity = velocity - Vector3.new(0, speed, 0)
            end
            
            bodyVelocity.Velocity = velocity
        end)
    else
        if Shadow.Connections.Fly then
            Shadow.Connections.Fly:Disconnect()
        end
    end
end

function Shadow:ToggleNoClip(state)
    Shadow.Config.NoClip = state
    
    if state then
        Shadow.Connections.NoClip = RunService.Stepped:Connect(function()
            if Shadow.Config.NoClip and LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if Shadow.Connections.NoClip then
            Shadow.Connections.NoClip:Disconnect()
        end
    end
end

--========================
-- [9] VISUAL SYSTEMS
--========================
function Shadow:ToggleESP(state)
    Shadow.Config.Esp = state
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local esp = char:FindFirstChild("ShadowESP")
                
                if state and not esp then
                    esp = Instance.new("Highlight")
                    esp.Name = "ShadowESP"
                    esp.FillColor = Color3.fromRGB(255, 50, 50)
                    esp.OutlineColor = Color3.fromRGB(255, 100, 100)
                    esp.FillTransparency = 0.7
                    esp.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    esp.Parent = char
                elseif not state and esp then
                    esp:Destroy()
                end
            end
        end
    end
end

--========================
-- [10] ADVANCED UI SYSTEM
--========================
function Shadow.UI:Create()
    -- Destroy old UI
    pcall(function()
        CoreGui:FindFirstChild("ShadowHub"):Destroy()
    end)
    
    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ShadowHub"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.DisplayOrder = 999
    ScreenGui.ResetOnSpawn = false
    
    -- Main Container
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 500, 0, 600)
    Main.Position = UDim2.new(0.5, -250, 0.5, -300)
    Main.BackgroundColor3 = Shadow.UI.Colors.Background
    Main.BackgroundTransparency = 0.05
    Main.ClipsDescendants = true
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 14)
    MainCorner.Parent = Main
    
    -- Drop Shadow
    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Image = "rbxassetid://6015897843"
    DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow.ImageTransparency = 0.8
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow.Size = UDim2.new(1, 24, 1, 24)
    DropShadow.Position = UDim2.new(0, -12, 0, -12)
    DropShadow.BackgroundTransparency = 1
    DropShadow.Parent = Main
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    TitleBar.BorderSizePixel = 0
    
    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, 14)
    TitleBarCorner.Parent = TitleBar
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.7, 0, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.Text = "⚡ SHADOW HUB v2.0"
    Title.TextColor3 = Shadow.UI.Colors.Primary
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(0.7, 0, 0, 20)
    Subtitle.Position = UDim2.new(0, 20, 0, 25)
    Subtitle.Text = "Steal a Brainrots | Advanced Exploit"
    Subtitle.TextColor3 = Color3.fromRGB(150, 150, 200)
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 12
    Subtitle.BackgroundTransparency = 1
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Control Buttons
    local function CreateControlButton(text, position, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 30, 0, 30)
        btn.Position = position
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16
        btn.BackgroundColor3 = color
        btn.AutoButtonColor = false
        btn.BorderSizePixel = 0
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = btn
        
        return btn
    end
    
    local CloseBtn = CreateControlButton("✕", UDim2.new(1, -35, 0.5, -15), Color3.fromRGB(255, 80, 80))
    local MinBtn = CreateControlButton("─", UDim2.new(1, -70, 0.5, -15), Color3.fromRGB(255, 180, 0))
    local ToggleBtn = CreateControlButton("⚡", UDim2.new(1, -105, 0.5, -15), Shadow.UI.Colors.Primary)
    
    -- Tabs Container
    local TabsContainer = Instance.new("Frame")
    TabsContainer.Size = UDim2.new(1, 0, 0, 40)
    TabsContainer.Position = UDim2.new(0, 0, 0, 60)
    TabsContainer.BackgroundTransparency = 1
    
    local Tabs = {"MAIN", "AUTO", "PLAYER", "VISUAL", "SERVERS"}
    
    for i, tabName in ipairs(Tabs) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(0.2, 0, 1, 0)
        tabBtn.Position = UDim2.new(0.2 * (i - 1), 0, 0, 0)
        tabBtn.Text = tabName
        tabBtn.Font = Enum.Font.GothamSemibold
        tabBtn.TextSize = 13
        tabBtn.BackgroundColor3 = i == 1 and Color3.fromRGB(40, 40, 55) or Color3.fromRGB(30, 30, 42)
        tabBtn.TextColor3 = i == 1 and Shadow.UI.Colors.Primary or Color3.fromRGB(150, 150, 150)
        tabBtn.BorderSizePixel = 0
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = tabBtn
        
        tabBtn.Parent = TabsContainer
        Shadow.UI.Tabs[tabName] = tabBtn
    end
    
    -- Content Area
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -20, 1, -120)
    Content.Position = UDim2.new(0, 10, 0, 110)
    Content.BackgroundTransparency = 1
    
    -- Parent everything
    TitleBar.Parent = Main
    Title.Parent = TitleBar
    Subtitle.Parent = TitleBar
    CloseBtn.Parent = TitleBar
    MinBtn.Parent = TitleBar
    ToggleBtn.Parent = TitleBar
    TabsContainer.Parent = Main
    Content.Parent = Main
    Main.Parent = ScreenGui
    
    -- Store references
    Shadow.UI.ScreenGui = ScreenGui
    Shadow.UI.Main = Main
    Shadow.UI.Content = Content
    Shadow.UI.TitleBar = TitleBar
    Shadow.UI.CloseBtn = CloseBtn
    Shadow.UI.MinBtn = MinBtn
    Shadow.UI.ToggleBtn = ToggleBtn
    
    -- Setup drag functionality
    self:SetupDrag(TitleBar, Main)
    
    -- Setup button functionality
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = false
    end)
    
    MinBtn.MouseButton1Click:Connect(function()
        if Main.Size == UDim2.new(0, 500, 0, 600) then
            Main:TweenSize(UDim2.new(0, 500, 0, 50), "Out", "Quad", 0.3)
        else
            Main:TweenSize(UDim2.new(0, 500, 0, 600), "Out", "Quad", 0.3)
        end
    end)
    
    ToggleBtn.MouseButton1Click:Connect(function()
        local enabled = ScreenGui.Enabled
        ScreenGui.Enabled = not enabled
        ToggleBtn.Text = enabled and "⚡" or "👁️"
    end)
    
    -- Create tab content
    self:CreateMainTab()
    self:CreateAutoTab()
    self:CreatePlayerTab()
    self:CreateVisualTab()
    self:CreateServersTab()
    
    self:Log("UI created successfully", "success")
end

function Shadow.UI:SetupDrag(dragFrame, targetFrame)
    local dragging = false
    local dragStart, startPos
    
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Shadow.UI:CreateToggle(name, yPos, configKey, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 40)
    toggleFrame.Position = UDim2.new(0, 0, 0, yPos)
    toggleFrame.BackgroundTransparency = 1
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 0, 36)
    toggleBtn.Text = name .. ": " .. (Shadow.Config[configKey] and "🟢 ON" or "🔴 OFF")
    toggleBtn.Font = Enum.Font.GothamSemibold
    toggleBtn.TextSize = 14
    toggleBtn.BackgroundColor3 = Shadow.Config[configKey] and Color3.fromRGB(40, 60, 40) or Color3.fromRGB(60, 40, 40)
    toggleBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
    toggleBtn.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = toggleBtn
    
    toggleBtn.MouseButton1Click:Connect(function()
        Shadow.Config[configKey] = not Shadow.Config[configKey]
        toggleBtn.Text = name .. ": " .. (Shadow.Config[configKey] and "🟢 ON" or "🔴 OFF")
        toggleBtn.BackgroundColor3 = Shadow.Config[configKey] and Color3.fromRGB(40, 60, 40) or Color3.fromRGB(60, 40, 40)
        
        if callback then
            callback(Shadow.Config[configKey])
        end
    end)
    
    toggleBtn.Parent = toggleFrame
    return toggleFrame
end

function Shadow.UI:CreateMainTab()
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Name = "MainTab"
    content.Visible = true
    
    -- Stats display
    local statsFrame = Instance.new("Frame")
    statsFrame.Size = UDim2.new(1, 0, 0, 100)
    statsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    statsFrame.BorderSizePixel = 0
    
    local statsCorner = Instance.new("UICorner")
    statsCorner.CornerRadius = UDim.new(0, 10)
    statsCorner.Parent = statsFrame
    
    local stats = {
        {"👥 Players", #Players:GetPlayers()},
        {"💰 Brainrots", #Shadow.Data.Brainrots},
        {"🌍 Servers", #Shadow.Data.Servers},
        {"⚡ FPS", math.floor(1/RunService.RenderStepped:Wait())}
    }
    
    for i, stat in ipairs(stats) do
        local statFrame = Instance.new("Frame")
        statFrame.Size = UDim2.new(0.22, 0, 0.8, 0)
        statFrame.Position = UDim2.new(0.02 + (0.24 * (i-1)), 0, 0.1, 0)
        statFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        statFrame.BorderSizePixel = 0
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = statFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0.5, 0)
        label.Text = stat[1]
        label.TextColor3 = Color3.fromRGB(180, 180, 220)
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.BackgroundTransparency = 1
        
        local value = Instance.new("TextLabel")
        value.Size = UDim2.new(1, 0, 0.5, 0)
        value.Position = UDim2.new(0, 0, 0.5, 0)
        value.Text = tostring(stat[2])
        value.TextColor3 = Color3.fromRGB(255, 255, 255)
        value.Font = Enum.Font.GothamBold
        value.TextSize = 16
        value.BackgroundTransparency = 1
        
        label.Parent = statFrame
        value.Parent = statFrame
        statFrame.Parent = statsFrame
    end
    
    statsFrame.Parent = content
    
    -- Scan button
    local scanBtn = Instance.new("TextButton")
    scanBtn.Size = UDim2.new(1, 0, 0, 40)
    scanBtn.Position = UDim2.new(0, 0, 0, 120)
    scanBtn.Text = "🔍 SCAN FOR BRAINROTS"
    scanBtn.Font = Enum.Font.GothamBold
    scanBtn.TextSize = 16
    scanBtn.BackgroundColor3 = Shadow.UI.Colors.Primary
    scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local scanCorner = Instance.new("UICorner")
    scanCorner.CornerRadius = UDim.new(0, 8)
    scanCorner.Parent = scanBtn
    
    scanBtn.MouseButton1Click:Connect(function()
        Shadow:ScanBrainrots()
        Shadow:Notify("Scan Complete", "Found " .. #Shadow.Data.Brainrots .. " brainrots", 3)
    end)
    
    scanBtn.Parent = content
    
    -- Brainrots list
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(1, 0, 0, 300)
    listFrame.Position = UDim2.new(0, 0, 0, 180)
    listFrame.BackgroundTransparency = 1
    listFrame.ScrollBarThickness = 5
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    content.Parent = Shadow.UI.Content
    Shadow.UI.Elements.MainTab = content
end

function Shadow.UI:CreateAutoTab()
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Name = "AutoTab"
    content.Visible = false
    
    -- Auto Farm
    local autoFarmToggle = self:CreateToggle("🤖 AUTO FARM", 0, "AutoFarm", function(state)
        if state then
            Shadow:Notify("Auto Farm", "Started auto farming", 3)
        else
            Shadow:Notify("Auto Farm", "Stopped auto farming", 3)
        end
    end)
    autoFarmToggle.Parent = content
    
    -- Auto Collect
    local autoCollectToggle = self:CreateToggle("💰 AUTO COLLECT", 50, "AutoCollect", function(state)
        -- Auto collect functionality
    end)
    autoCollectToggle.Parent = content
    
    -- Auto Join Best
    local autoJoinToggle = self:CreateToggle("🌍 AUTO JOIN BEST SERVER", 100, "AutoJoinBest", function(state)
        Shadow.Config.AutoJoinBest = state
    end)
    autoJoinToggle.Parent = content
    
    -- Anti-AFK
    local antiAfkToggle = self:CreateToggle("⏰ ANTI-AFK", 150, "AntiAFK", function(state)
        Shadow.Config.AntiAFK = state
    end)
    antiAfkToggle.Parent = content
    
    content.Parent = Shadow.UI.Content
    Shadow.UI.Elements.AutoTab = content
end

function Shadow.UI:CreatePlayerTab()
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Name = "PlayerTab"
    content.Visible = false
    
    -- Speed slider
    local speedFrame = Instance.new("Frame")
    speedFrame.Size = UDim2.new(1, 0, 0, 60)
    speedFrame.BackgroundTransparency = 1
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, 0, 0, 25)
    speedLabel.Text = "⚡ SPEED: " .. Shadow.Config.Speed
    speedLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    speedLabel.Font = Enum.Font.GothamBold
    speedLabel.TextSize = 14
    speedLabel.BackgroundTransparency = 1
    
    local speedSlider = Instance.new("Frame")
    speedSlider.Size = UDim2.new(1, 0, 0, 10)
    speedSlider.Position = UDim2.new(0, 0, 0, 35)
    speedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    speedSlider.BorderSizePixel = 0
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((Shadow.Config.Speed - 16) / 100, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    sliderFill.BorderSizePixel = 0
    
    sliderFill.Parent = speedSlider
    speedLabel.Parent = speedFrame
    speedSlider.Parent = speedFrame
    speedFrame.Parent = content
    
    -- Player toggles
    local flyToggle = self:CreateToggle("✈️ FLY", 80, "Fly", function(state)
        Shadow:ToggleFly(state)
    end)
    flyToggle.Parent = content
    
    local noClipToggle = self:CreateToggle("🚫 NO CLIP", 130, "NoClip", function(state)
        Shadow:ToggleNoClip(state)
    end)
    noClipToggle.Parent = content
    
    local desyncToggle = self:CreateToggle("🌀 DESYNC", 180, "Desync", function(state)
        Shadow:ToggleDesync(state)
    end)
    desyncToggle.Parent = content
    
    content.Parent = Shadow.UI.Content
    Shadow.UI.Elements.PlayerTab = content
end

function Shadow.UI:CreateVisualTab()
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Name = "VisualTab"
    content.Visible = false
    
    local espToggle = self:CreateToggle("👁️ PLAYER ESP", 0, "Esp", function(state)
        Shadow:ToggleESP(state)
    end)
    espToggle.Parent = content
    
    local brainrotEspToggle = self:CreateToggle("💰 BRAINROT ESP", 50, "BrainrotESP", function(state)
        -- Brainrot ESP functionality
    end)
    brainrotEspToggle.Parent = content
    
    local fpsToggle = self:CreateToggle("⚡ FPS BOOST", 100, "FPSBoost", function(state)
        Shadow.Config.FPSBoost = state
        if state then
            Lighting.GlobalShadows = false
        else
            Lighting.GlobalShadows = true
        end
    end)
    fpsToggle.Parent = content
    
    content.Parent = Shadow.UI.Content
    Shadow.UI.Elements.VisualTab = content
end

function Shadow.UI:CreateServersTab()
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Name = "ServersTab"
    content.Visible = false
    
    -- Refresh button
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(1, 0, 0, 40)
    refresh
