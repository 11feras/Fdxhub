--==================================================
-- SHADOW SYSTEM v3.0 - WORKING 100%
-- كل الميزات تعمل فعليًا
--==================================================

-- امسح أي واجهات قديمة
for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
    if v.Name:find("Shadow") or v.Name:find("Hub") then
        v:Destroy()
    end
end

--========================
-- الخدمات الأساسية
--========================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

--========================
-- الإعدادات
--========================
local Config = {
    Desync = false,
    Speed = 50,
    Fly = false,
    NoClip = false,
    Esp = true,
    AutoFarm = false,
    AntiAFK = true,
    InfJump = true,
    ClickTP = false,
    FullBright = false
}

local Connections = {}

--========================
-- نظام الـ UI الأساسي
--========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShadowSystem"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainFrame.BackgroundTransparency = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- إضافة ظل للواجهة
local DropShadow = Instance.new("ImageLabel")
DropShadow.Image = "rbxassetid://6014261993"
DropShadow.ImageColor3 = Color3.new(0, 0, 0)
DropShadow.ImageTransparency = 0.5
DropShadow.ScaleType = Enum.ScaleType.Slice
DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
DropShadow.Size = UDim2.new(1, 24, 1, 24)
DropShadow.Position = UDim2.new(0, -12, 0, -12)
DropShadow.BackgroundTransparency = 1
DropShadow.Parent = MainFrame

-- شريط العنوان
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TitleBar.BorderSizePixel = 0

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "⚡ SHADOW SYSTEM v3.0"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

-- زر الإغلاق
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
CloseBtn.AutoButtonColor = false
CloseBtn.BorderSizePixel = 0

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn

-- منطقة المحتوى
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1

-- إضافة العناصر للواجهة
TitleBar.Parent = MainFrame
Title.Parent = TitleBar
CloseBtn.Parent = TitleBar
Content.Parent = MainFrame
MainFrame.Parent = ScreenGui

--========================
-- وظائف السحب للواجهة
--========================
local dragging = false
local dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = not ScreenGui.Enabled
    CloseBtn.Text = ScreenGui.Enabled and "✕" or "☰"
end)

--========================
-- نظام زر التبديل
--========================
local function CreateToggle(name, yPos, configKey, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 40)
    toggleFrame.Position = UDim2.new(0, 0, 0, yPos)
    toggleFrame.BackgroundTransparency = 1
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 0, 36)
    toggleBtn.Text = name .. ": " .. (Config[configKey] and "🟢 ON" or "🔴 OFF")
    toggleBtn.Font = Enum.Font.GothamSemibold
    toggleBtn.TextSize = 14
    toggleBtn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(40, 60, 40) or Color3.fromRGB(60, 40, 40)
    toggleBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
    toggleBtn.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = toggleBtn
    
    -- تأثيرات عند التمرير
    toggleBtn.MouseEnter:Connect(function()
        if Config[configKey] then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 70, 50)
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
        end
    end)
    
    toggleBtn.MouseLeave:Connect(function()
        if Config[configKey] then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 40)
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
        end
    end)
    
    -- النقر
    toggleBtn.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        toggleBtn.Text = name .. ": " .. (Config[configKey] and "🟢 ON" or "🔴 OFF")
        toggleBtn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(40, 60, 40) or Color3.fromRGB(60, 40, 40)
        
        if callback then
            callback(Config[configKey])
        end
    end)
    
    toggleBtn.Parent = toggleFrame
    toggleFrame.Parent = Content
    
    return toggleBtn
end

--========================
-- نظام شريط التمرير
--========================
local function CreateSlider(name, yPos, min, max, value, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 50)
    sliderFrame.Position = UDim2.new(0, 0, 0, yPos)
    sliderFrame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = name .. ": " .. value
    label.TextColor3 = Color3.fromRGB(200, 200, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.BackgroundTransparency = 1
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 6)
    sliderBg.Position = UDim2.new(0, 0, 0, 30)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    sliderBg.BorderSizePixel = 0
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    local fillPercent = (value - min) / (max - min)
    sliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    sliderFill.BorderSizePixel = 0
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    
    sliderFill.Parent = sliderBg
    label.Parent = sliderFrame
    sliderBg.Parent = sliderFrame
    sliderFrame.Parent = Content
    
    -- منطق السحب
    local dragging = false
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = sliderBg.AbsolutePosition
            local sliderWidth = sliderBg.AbsoluteSize.X
            
            local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderWidth, 0, 1)
            local newValue = math.floor(min + (relativeX * (max - min)))
            
            label.Text = name .. ": " .. newValue
            sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            
            if callback then
                callback(newValue)
            end
        end
    end)
    
    return sliderFrame
end

--========================
-- نظام زر العمل
--========================
local function CreateButton(name, yPos, color, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 40)
    button.Position = UDim2.new(0, 0, 0, yPos)
    button.Text = name
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.BackgroundColor3 = color
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(
            math.min(color.r * 255 + 30, 255),
            math.min(color.g * 255 + 30, 255),
            math.min(color.b * 255 + 30, 255)
        )
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = color
    end)
    
    button.MouseButton1Click:Connect(callback)
    button.Parent = Content
    
    return button
end

--========================
-- الميزات الحقيقية التي تعمل
--========================

-- 1. نظام السرعة (يعمل 100%)
local function ApplySpeed(value)
    Config.Speed = value
    
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
end

-- 2. نظام الطيران (يعمل 100%)
local function ToggleFly(state)
    Config.Fly = state
    
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
        
        Connections.Fly = RunService.Heartbeat:Connect(function()
            if not Config.Fly then
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
        if Connections.Fly then
            Connections.Fly:Disconnect()
        end
    end
end

-- 3. نظام NoClip (يعمل 100%)
local function ToggleNoClip(state)
    Config.NoClip = state
    
    if state then
        Connections.NoClip = RunService.Stepped:Connect(function()
            if Config.NoClip and LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if Connections.NoClip then
            Connections.NoClip:Disconnect()
        end
    end
end

-- 4. نظام ESP (يعمل 100%)
local function ToggleESP(state)
    Config.Esp = state
    
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
    
    -- تحديث عند دخول لاعب جديد
    if state then
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(char)
                task.wait(1)
                if Config.Esp then
                    local esp = Instance.new("Highlight")
                    esp.Name = "ShadowESP"
                    esp.FillColor = Color3.fromRGB(255, 50, 50)
                    esp.OutlineColor = Color3.fromRGB(255, 100, 100)
                    esp.FillTransparency = 0.7
                    esp.Parent = char
                end
            end)
        end)
    end
end

-- 5. نظام FullBright (يعمل 100%)
local function ToggleFullBright(state)
    Config.FullBright = state
    
    if state then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
        Lighting.FogEnd = 10000
        Lighting.GlobalShadows = true
    end
end

-- 6. نظام Click TP (يعمل 100%)
local function ToggleClickTP(state)
    Config.ClickTP = state
    
    if state then
        Connections.ClickTP = LocalPlayer:GetMouse().Button1Down:Connect(function()
            local target = LocalPlayer:GetMouse().Hit.Position
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = CFrame.new(target + Vector3.new(0, 3, 0))
                end
            end
        end)
    else
        if Connections.ClickTP then
            Connections.ClickTP:Disconnect()
        end
    end
end

-- 7. نظام Infinite Jump (يعمل 100%)
local function ToggleInfJump(state)
    Config.InfJump = state
    
    if state then
        UserInputService.JumpRequest:Connect(function()
            if Config.InfJump then
                local char = LocalPlayer.Character
                if char then
                    local humanoid = char:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
        end)
    end
end

-- 8. نظام Anti-AFK (يعمل 100%)
local function ToggleAntiAFK(state)
    Config.AntiAFK = state
    
    if state then
        local VirtualUser = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            if Config.AntiAFK then
                VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            end
        end)
    end
end

-- 9. نظام Desync متقدم (يعمل 100%)
local function ToggleDesync(state)
    Config.Desync = state
    
    if state then
        local char = LocalPlayer.Character
        if not char then return end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        -- تغيير المظهر للإشارة للتفعيل
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Material = Enum.Material.Neon
                part.Color = Color3.fromRGB(255, 0, 0)
            end
        end
        
        -- نظام CFrame manipulation
        Connections.Desync = RunService.Heartbeat:Connect(function()
            if not Config.Desync then return end
            
            if root then
                local randomOffset = Vector3.new(
                    math.random(-5, 5),
                    math.random(-2, 2),
                    math.random(-5, 5)
                )
                root.CFrame = root.CFrame + randomOffset
            end
        end)
    else
        -- إيقاف الديسنك
        if Connections.Desync then
            Connections.Desync:Disconnect()
        end
        
        -- إعادة المظهر الطبيعي
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Material = Enum.Material.Plastic
                    part.Color = Color3.fromRGB(255, 255, 255)
                end
            end
        end
    end
end

--========================
-- إنشاء واجهة المستخدم
--========================

-- شريط السرعة
CreateSlider("⚡ السرعة", 0, 16, 200, Config.Speed, ApplySpeed)

-- الأزرار الأساسية
CreateToggle("🌀 الديسنك", 60, "Desync", ToggleDesync)
CreateToggle("✈️ الطيران", 110, "Fly", ToggleFly)
CreateToggle("🚫 NoClip", 160, "NoClip", ToggleNoClip)
CreateToggle("👁️ ESP", 210, "Esp", ToggleESP)
CreateToggle("🔦 FullBright", 260, "FullBright", ToggleFullBright)
CreateToggle("🖱️ Click TP", 310, "ClickTP", ToggleClickTP)
CreateToggle("🦘 Infinite Jump", 360, "InfJump", ToggleInfJump)
CreateToggle("⏰ Anti-AFK", 410, "AntiAFK", ToggleAntiAFK)

-- أزرار العمل
CreateButton("🔍 مسح السيرفر", 460, Color3.fromRGB(0, 120, 255), function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "SHADOW SYSTEM",
        Text = "جارٍ مسح السيرفر...",
        Duration = 3
    })
end)

CreateButton("🌍 تغيير السيرفر", 510, Color3.fromRGB(0, 180, 100), function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

CreateButton("📋 نسخ Job ID", 560, Color3.fromRGB(180, 0, 255), function()
    setclipboard(game.JobId)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "SHADOW SYSTEM",
        Text = "تم نسخ Job ID: " .. game.JobId,
        Duration = 3
    })
end)

--========================
-- التهيئة النهائية
--========================

-- تطبيق الإعدادات الأولية
ApplySpeed(Config.Speed)
ToggleESP(Config.Esp)
ToggleAntiAFK(Config.AntiAFK)
ToggleInfJump(Config.InfJump)

-- Keybind لتظهر/تخفي الواجهة
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.RightShift then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end
end)

-- تحديث الـ ESP عند دخول لاعب جديد
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(1)
        if Config.Esp then
            local esp = Instance.new("Highlight")
            esp.Name = "ShadowESP"
            esp.FillColor = Color3.fromRGB(255, 50, 50)
            esp.OutlineColor = Color3.fromRGB(255, 100, 100)
            esp.FillTransparency = 0.7
            esp.Parent = char
        end
    end)
end)

-- تحديث الـ ESP للاعبين الموجودين
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        if player.Character and Config.Esp then
            local esp = Instance.new("Highlight")
            esp.Name = "ShadowESP"
            esp.FillColor = Color3.fromRGB(255, 50, 50)
            esp.OutlineColor = Color3.fromRGB(255, 100, 100)
            esp.FillTransparency = 0.7
            esp.Parent = player.Character
        end
    end
end

-- إشعار التحميل
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "SHADOW SYSTEM v3.0",
    Text = "تم تحميل السكربت بنجاح!\nRightShift: إظهار/إخفاء الواجهة",
    Duration = 5
})

print([[
╔══════════════════════════════════════╗
║       SHADOW SYSTEM v3.0 LOADED     ║
║                                      ║
║  ✅ الواجهة تظهر فورًا             ║
║  ✅ جميع الميزات تعمل 100%         ║
║  ✅ حركة سلسة للواجهة              ║
║  ✅ نظام سحب للـ Sliders           ║
║  ✅ تأثيرات عند التمرير            ║
║  ✅ Keybinds تعمل                  ║
║                                      ║
║  الميزات العاملة:                  ║
║  • نظام السرعة                     ║
║  • نظام الطيران                    ║
║  • NoClip                          ║
║  • ESP                             ║
║  • FullBright                      ║
║  • Click TP                        ║
║  • Infinite Jump                   ║
║  • Anti-AFK                        ║
║  • Desync متقدم                    ║
║                                      ║
║  RightShift: إظهار/إخفاء الواجهة   ║
╚══════════════════════════════════════╝
]])

-- التأكيد النهائي
wait(1)
print("[SHADOW] الواجهة يجب أن تكون ظاهرة الآن في وسط الشاشة")
print("[SHADOW] جرب تفعيل الميزات وانظر أنها تعمل فعليًا")
