local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

local function getCharacter()
    return Player.Character
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChild("Humanoid")
end

local function getRoot()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local KEY_SERVER = "https://pastebin.com/raw/m4cQ7QZ4"
local HUB_NAME = "RT HUB"
local LOCAL_KEYS = {"RTKEY123", "RTVIP456", "RTHUB999"}

local Toggles = {
    AutoFarm = false, AutoBoss = false, AutoStars = false, RandomFarm = false,
    AutoDungeon = false, AutoRaid = false, KillAura = false, InstantKill = false,
    AutoEquip = false, AutoM1 = false, AutoQuest = false, AutoClaim = false,
    AutoDaily = false, AutoReroll = false, AutoSpin = false, AutoUpgrade = false,
    FlyEnabled = false, NoClip = false, ESP = false, AntiAFK = false
}

local Settings = {
    KillAuraRange = 50, WalkSpeed = 16, JumpPower = 50, FPSBoost = false
}

local Connections = {}

local function newGui(name, parent)
    local gui = Instance.new("ScreenGui")
    gui.Name = name
    gui.Parent = parent or game:GetService("CoreGui")
    return gui
end

local function notify(title, text, duration)
    local Notification = Instance.new("ScreenGui")
    Notification.Name = "Notification"
    Notification.Parent = game:GetService("CoreGui")
    Notification.ResetOnSpawn = false
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 300, 0, 80)
    Frame.Position = UDim2.new(1, -320, 0, 20)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Frame.BorderSizePixel = 0
    Frame.Parent = Notification
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = Frame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 25)
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.Text = title
    Title.TextColor3 = Color3.fromRGB(0, 150, 255)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.BackgroundTransparency = 1
    Title.Parent = Frame
    
    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1, -20, 0, 40)
    Text.Position = UDim2.new(0, 10, 0, 30)
    Text.Text = text
    Text.TextColor3 = Color3.fromRGB(200, 200, 200)
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.Font = Enum.Font.Gotham
    Text.TextSize = 14
    Text.BackgroundTransparency = 1
    Text.Parent = Frame
    
    task.delay(duration or 3, function()
        Notification:Destroy()
    end)
end

local KeyGui = newGui("RTKeySystem")
local KeyFrame = Instance.new("Frame", KeyGui)
KeyFrame.Size = UDim2.new(0,450,0,300)
KeyFrame.Position = UDim2.new(0.5,-225,0.5,-150)
KeyFrame.BackgroundColor3 = Color3.fromRGB(25,25,30)
KeyFrame.Active = true
KeyFrame.Draggable = true

local Corner = Instance.new("UICorner", KeyFrame)
Corner.CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel", KeyFrame)
Title.Size = UDim2.new(1,0,0,80)
Title.Position = UDim2.new(0,0,0,0)
Title.Text = "🔥 " .. HUB_NAME .. " v5.0"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.BackgroundColor3 = Color3.fromRGB(0,150,255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.BorderSizePixel = 0

local TitleCorner = Instance.new("UICorner", Title)
TitleCorner.CornerRadius = UDim.new(0,12)

local KeyInput = Instance.new("TextBox", KeyFrame)
KeyInput.Size = UDim2.new(0.8,0,0,50)
KeyInput.Position = UDim2.new(0.1,0,0.35,0)
KeyInput.PlaceholderText = "Digite sua key..."
KeyInput.BackgroundColor3 = Color3.fromRGB(45,45,50)
KeyInput.TextColor3 = Color3.fromRGB(255,255,255)
KeyInput.TextScaled = true
KeyInput.Font = Enum.Font.Gotham
KeyInput.ClearTextOnFocus = false

local InputCorner = Instance.new("UICorner", KeyInput)
InputCorner.CornerRadius = UDim.new(0,8)

local VerifyBtn = Instance.new("TextButton", KeyFrame)
VerifyBtn.Size = UDim2.new(0.38,0,0,50)
VerifyBtn.Position = UDim2.new(0.1,0,0.55,0)
VerifyBtn.Text = "✅ VERIFICAR"
VerifyBtn.BackgroundColor3 = Color3.fromRGB(40,200,40)
VerifyBtn.TextColor3 = Color3.fromRGB(255,255,255)
VerifyBtn.TextScaled = true
VerifyBtn.Font = Enum.Font.GothamBold

local BtnCorner1 = Instance.new("UICorner", VerifyBtn)
BtnCorner1.CornerRadius = UDim.new(0,8)

local BuyBtn = Instance.new("TextButton", KeyFrame)
BuyBtn.Size = UDim2.new(0.38,0,0,50)
BuyBtn.Position = UDim2.new(0.52,0,0.55,0)
BuyBtn.Text = "🛒 DISCORD"
BuyBtn.BackgroundColor3 = Color3.fromRGB(255,170,0)
BuyBtn.TextColor3 = Color3.fromRGB(255,255,255)
BuyBtn.TextScaled = true
BuyBtn.Font = Enum.Font.GothamBold

local BtnCorner2 = Instance.new("UICorner", BuyBtn)
BtnCorner2.CornerRadius = UDim.new(0,8)

local StatusLabel = Instance.new("TextLabel", KeyFrame)
StatusLabel.Size = UDim2.new(1,-20,0,40)
StatusLabel.Position = UDim2.new(0,10,0.75,0)
StatusLabel.Text = "Aguardando key..."
StatusLabel.TextColor3 = Color3.fromRGB(200,200,200)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.Gotham

local function checkKey(key)
    key = string.gsub(key or "", "%s", "")
    if key == "" then return false, "❌ Digite uma key válida!" end
    for _, v in ipairs(LOCAL_KEYS) do
        if key == v then return true, "✅ Key OK! (local)" end
    end
    local success, raw = pcall(function() return game:HttpGet(KEY_SERVER) end)
    if not success then return false, "⚠ Falha de conexão ao servidor" end
    local success, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if not success or not data or type(data.keys) ~= "table" then return false, "⚠ Dados de chave quebrados" end
    for _, v in ipairs(data.keys) do
        if key == v then return true, "✅ Pastebin OK! (remota)" end
    end
    return false, "❌ Key inválida!"
end

VerifyBtn.MouseButton1Click:Connect(function()
    local key = KeyInput.Text
    StatusLabel.Text = "🔍 Verificando..."
    StatusLabel.TextColor3 = Color3.fromRGB(255,255,0)
    task.wait(1.5)
    local ok, msg = checkKey(key)
    if ok then
        StatusLabel.Text = msg
        StatusLabel.TextColor3 = Color3.fromRGB(100,255,100)
        notify("✅ Acesso Liberado", "Bem-vindo ao " .. HUB_NAME .. "!", 3)
        for _, obj in pairs(KeyFrame:GetDescendants()) do
            if obj:IsA("GuiObject") then
                TweenService:Create(obj, TweenInfo.new(0.8), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            end
        end
        task.wait(1)
        KeyGui:Destroy()
        loadMainHub()
    else
        StatusLabel.Text = msg
        StatusLabel.TextColor3 = Color3.fromRGB(255,100,100)
        KeyInput.Text = ""
    end
end)

BuyBtn.MouseButton1Click:Connect(function()
    local DISCORD_LINK = "discord.gg/rthub"
    pcall(setclipboard, DISCORD_LINK)
    StatusLabel.Text = "🛒 Discord copiado!"
    StatusLabel.TextColor3 = Color3.fromRGB(255,170,0)
end)

local dragging, dragStart, startPos
KeyFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = KeyFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        KeyFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

function loadMainHub()
    local HubGui = newGui("RTHub_Main")
    
    local Main = Instance.new("Frame", HubGui)
    Main.Size = UDim2.new(0, 600, 0, 420)
    Main.Position = UDim2.new(0.5, -300, 0.5, -210)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Main.Active = true
    Main.Draggable = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    
    local Top = Instance.new("Frame", Main)
    Top.Size = UDim2.new(1, 0, 0, 45)
    Top.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 12)
    
    local TitleLabel = Instance.new("TextLabel", Top)
    TitleLabel.Size = UDim2.new(1, 0, 1, 0)
    TitleLabel.Text = "🔥 " .. HUB_NAME .. " PREMIUM v5.0"
    TitleLabel.TextScaled = true
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    
    local CloseBtn = Instance.new("TextButton", Top)
    CloseBtn.Size = UDim2.new(0, 40, 0, 40)
    CloseBtn.Position = UDim2.new(1, -45, 0, 2)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 20
    CloseBtn.MouseButton1Click:Connect(function() HubGui:Destroy() end)
    
    local Tabs = Instance.new("Frame", Main)
    Tabs.Position = UDim2.new(0, 0, 0, 45)
    Tabs.Size = UDim2.new(0, 130, 1, -45)
    Tabs.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    
    local Content = Instance.new("Frame", Main)
    Content.Position = UDim2.new(0, 130, 0, 45)
    Content.Size = UDim2.new(1, -130, 1, -45)
    Content.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    
    local function createScrollingFrame(parent)
        local sf = Instance.new("ScrollingFrame", parent)
        sf.Size = UDim2.new(1, 0, 1, 0)
        sf.CanvasSize = UDim2.new(0, 0, 0, 0)
        sf.ScrollBarThickness = 6
        sf.BackgroundTransparency = 1
        sf.BorderSizePixel = 0
        sf.ScrollingDirection = Enum.ScrollingDirection.Y
        sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
        local UIListLayout = Instance.new("UIListLayout", sf)
        UIListLayout.Padding = UDim.new(0, 5)
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        local Padding = Instance.new("UIPadding", sf)
        Padding.PaddingTop = UDim.new(0, 10)
        Padding.PaddingLeft = UDim.new(0, 10)
        Padding.PaddingRight = UDim.new(0, 10)
        return sf
    end
    
    local function createTab(name)
        local btn = Instance.new("TextButton", Tabs)
        btn.Size = UDim2.new(1, 0, 0, 45)
        btn.Text = name
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        local page = Instance.new("Frame", Content)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.Visible = false
        page.BackgroundTransparency = 1
        local sf = createScrollingFrame(page)
        btn.MouseButton1Click:Connect(function()
            for _, v in pairs(Content:GetChildren()) do if v:IsA("Frame") then v.Visible = false end end
            for _, b in pairs(Tabs:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(35, 35, 40) end end
            btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            page.Visible = true
        end)
        return sf
    end
    
    local function createToggle(parent, text, default, callback)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, -10, 0, 45)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        frame.BorderSizePixel = 0
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.Text = text
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.BackgroundTransparency = 1
        local state = default or false
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0, 60, 0, 25)
        btn.Position = UDim2.new(1, -70, 0.5, -12)
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.Text = state and "ON" or "OFF"
            btn.BackgroundColor3 = state and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
            callback(state)
        end)
        return frame
    end
    
    local function createSlider(parent, text, min, max, default, callback)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, -10, 0, 70)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        frame.BorderSizePixel = 0
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, -20, 0, 25)
        label.Position = UDim2.new(0, 10, 0, 5)
        label.Text = text .. ": " .. default
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.BackgroundTransparency = 1
        local bar = Instance.new("Frame", frame)
        bar.Position = UDim2.new(0, 10, 0, 35)
        bar.Size = UDim2.new(1, -20, 0, 12)
        bar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        bar.BorderSizePixel = 0
        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        fill.BorderSizePixel = 0
        local draggingSlider = false
        local function updateSlider(input)
            local percent = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            local value = math.floor(min + (max - min) * percent)
            label.Text = text .. ": " .. value
            callback(value)
        end
        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = true
                updateSlider(input)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = false
            end
        end)
        callback(default)
        return frame
    end
    
    local function createButton(parent, text, callback)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1, -10, 0, 40)
        btn.Text = text
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.BorderSizePixel = 0
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    local FarmTab = createTab("🏠 Farm")
    local CombatTab = createTab("⚔️ Combat")
    local QuestTab = createTab("📜 Quests")
    local UpgradeTab = createTab("✨ Upgrades")
    local HacksTab = createTab("🚀 Hacks")
    local MiscTab = createTab("🎮 Misc")
    
    FarmTab.Parent.Visible = true
    Tabs:FindFirstChildWhichIsA("TextButton").BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    
    local function getEnemies(range)
        local enemies = {}
        local char = getCharacter()
        local root = getRoot()
        if not char or not root then return enemies end
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= char then
                local hum = obj:FindFirstChild("Humanoid")
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 then
                    local dist = (hrp.Position - root.Position).Magnitude
                    if dist <= (range or 50) then
                        table.insert(enemies, obj)
                    end
                end
            end
        end
        return enemies
    end
    
    local function attackEnemy(enemy)
        local char = getCharacter()
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            task.wait(0.1)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end)
    end
    
    local function autoFarmLoop()
        while Toggles.AutoFarm do
            local enemies = getEnemies(100)
            for _, enemy in ipairs(enemies) do
                if not Toggles.AutoFarm then break end
                if enemy and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                    local hrp = enemy:FindFirstChild("HumanoidRootPart")
                    local char = getCharacter()
                    local hum = getHumanoid()
                    if hrp and char and hum then
                        hum:MoveTo(hrp.Position)
                        repeat
                            attackEnemy(enemy)
                            task.wait(0.2)
                        until not enemy.Parent or enemy.Humanoid.Health <= 0 or not Toggles.AutoFarm
                    end
                end
            end
            task.wait(0.5)
        end
    end
    
    local function killAuraLoop()
        while Toggles.KillAura do
            local enemies = getEnemies(Settings.KillAuraRange)
            for _, enemy in ipairs(enemies) do
                if Toggles.InstantKill and enemy:FindFirstChild("Humanoid") then
                    enemy.Humanoid.Health = 0
                else
                    attackEnemy(enemy)
                end
            end
            task.wait(0.1)
        end
    end
    
    local function antiAFKLoop()
        while Toggles.AntiAFK do
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
            end)
            task.wait(60)
        end
    end
    
    local function espLoop()
        while Toggles.ESP do
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                    if not obj:FindFirstChild("ESP_Highlight") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "ESP_Highlight"
                        highlight.FillTransparency = 0.5
                        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                        highlight.Parent = obj
                    end
                end
            end
            task.wait(1)
        end
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name == "ESP_Highlight" then obj:Destroy() end
        end
    end
    
    local function flyLoop()
        local char = getCharacter()
        local h    end)
end

-- Sistema de Key
local KeyGui = newGui("RTKeySystem")
local KeyFrame = Instance.new("Frame", KeyGui)
KeyFrame.Size = UDim2.new(0,450,0,300)
KeyFrame.Position = UDim2.new(0.5,-225,0.5,-150)
KeyFrame.BackgroundColor3 = Color3.fromRGB(25,25,30)
KeyFrame.Active = true
KeyFrame.Draggable = true

local Corner = Instance.new("UICorner", KeyFrame)
Corner.CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel", KeyFrame)
Title.Size = UDim2.new(1,0,0,80)
Title.Position = UDim2.new(0,0,0,0)
Title.Text = "🔥 " .. HUB_NAME .. " v5.0"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.BackgroundColor3 = Color3.fromRGB(0,150,255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.BorderSizePixel = 0

local TitleCorner = Instance.new("UICorner", Title)
TitleCorner.CornerRadius = UDim.new(0,12)

local KeyInput = Instance.new("TextBox", KeyFrame)
KeyInput.Size = UDim2.new(0.8,0,0,50)
KeyInput.Position = UDim2.new(0.1,0,0.35,0)
KeyInput.PlaceholderText = "Digite sua key..."
KeyInput.BackgroundColor3 = Color3.fromRGB(45,45,50)
KeyInput.TextColor3 = Color3.fromRGB(255,255,255)
KeyInput.TextScaled = true
KeyInput.Font = Enum.Font.Gotham
KeyInput.ClearTextOnFocus = false

local InputCorner = Instance.new("UICorner", KeyInput)
InputCorner.CornerRadius = UDim.new(0,8)

local VerifyBtn = Instance.new("TextButton", KeyFrame)
VerifyBtn.Size = UDim2.new(0.38,0,0,50)
VerifyBtn.Position = UDim2.new(0.1,0,0.55,0)
VerifyBtn.Text = "✅ VERIFICAR"
VerifyBtn.BackgroundColor3 = Color3.fromRGB(40,200,40)
VerifyBtn.TextColor3 = Color3.fromRGB(255,255,255)
VerifyBtn.TextScaled = true
VerifyBtn.Font = Enum.Font.GothamBold

local BtnCorner1 = Instance.new("UICorner", VerifyBtn)
BtnCorner1.CornerRadius = UDim.new(0,8)

local BuyBtn = Instance.new("TextButton", KeyFrame)
BuyBtn.Size = UDim2.new(0.38,0,0,50)
BuyBtn.Position = UDim2.new(0.52,0,0.55,0)
BuyBtn.Text = "🛒 DISCORD"
BuyBtn.BackgroundColor3 = Color3.fromRGB(255,170,0)
BuyBtn.TextColor3 = Color3.fromRGB(255,255,255)
BuyBtn.TextScaled = true
BuyBtn.Font = Enum.Font.GothamBold

local BtnCorner2 = Instance.new("UICorner", BuyBtn)
BtnCorner2.CornerRadius = UDim.new(0,8)

local StatusLabel = Instance.new("TextLabel", KeyFrame)
StatusLabel.Size = UDim2.new(1,-20,0,40)
StatusLabel.Position = UDim2.new(0,10,0.75,0)
StatusLabel.Text = "Aguardando key..."
StatusLabel.TextColor3 = Color3.fromRGB(200,200,200)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.Gotham

local function checkKey(key)
    key = string.gsub(key or "", "%s", "")
    
    if key == "" then
        return false, "❌ Digite uma key válida!"
    end
    
    for _, v in ipairs(LOCAL_KEYS) do
        if key == v then
            return true, "✅ Key OK! (local)"
        end
    end
    
    local success, raw = pcall(function()
        return game:HttpGet(KEY_SERVER)
    end)
    
    if not success then
        return false, "⚠ Falha de conexão ao servidor"
    end
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(raw)
    end)
    
    if not success or not data or type(data.keys) ~= "table" then
        return false, "⚠ Dados de chave quebrados"
    end
    
    for _, v in ipairs(data.keys) do
        if key == v then
            return true, "✅ Pastebin OK! (remota)"
        end
    end
    
    return false, "❌ Key inválida!"
end

VerifyBtn.MouseButton1Click:Connect(function()
    local key = KeyInput.Text
    StatusLabel.Text = "🔍 Verificando..."
    StatusLabel.TextColor3 = Color3.fromRGB(255,255,0)
    
    task.wait(1.5)
    local ok, msg = checkKey(key)
    
    if ok then
        StatusLabel.Text = msg
        StatusLabel.TextColor3 = Color3.fromRGB(100,255,100)
        notify("✅ Acesso Liberado", "Bem-vindo ao " .. HUB_NAME .. "!", 3)
        
        for _, obj in pairs(KeyFrame:GetDescendants()) do
            if obj:IsA("GuiObject") then
                TweenService:Create(obj, TweenInfo.new(0.8), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            end
        end
        
        task.wait(1)
        KeyGui:Destroy()
        loadMainHub()
    else
        StatusLabel.Text = msg
        StatusLabel.TextColor3 = Color3.fromRGB(255,100,100)
        KeyInput.Text = ""
    end
end)

BuyBtn.MouseButton1Click:Connect(function()
    local DISCORD_LINK = "discord.gg/rthub"
    pcall(setclipboard, DISCORD_LINK)
    StatusLabel.Text = "🛒 Discord copiado!"
    StatusLabel.TextColor3 = Color3.fromRGB(255,170,0)
end)

-- Dragging do KeyFrame
local dragging, dragStart, startPos
KeyFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = KeyFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        KeyFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- =============================================
-- FUNÇÕES DO HUB PRINCIPAL
-- =============================================
function loadMainHub()
    local HubGui = newGui("RTHub_Main")
    
    -- UI Base
    local Main = Instance.new("Frame", HubGui)
    Main.Size = UDim2.new(0, 600, 0, 420)
    Main.Position = UDim2.new(0.5, -300, 0.5, -210)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Main.Active = true
    Main.Draggable = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    
    -- Top Bar
    local Top = Instance.new("Frame", Main)
    Top.Size = UDim2.new(1, 0, 0, 45)
    Top.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 12)
    
    local TitleLabel = Instance.new("TextLabel", Top)
    TitleLabel.Size = UDim2.new(1, 0, 1, 0)
    TitleLabel.Text = "🔥 " .. HUB_NAME .. " PREMIUM v5.0"
    TitleLabel.TextScaled = true
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton", Top)
    CloseBtn.Size = UDim2.new(0, 40, 0, 40)
    CloseBtn.Position = UDim2.new(1, -45, 0, 2)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 20
    CloseBtn.MouseButton1Click:Connect(function()
        HubGui:Destroy()
    end)
    
    -- Tabs Container
    local Tabs = Instance.new("Frame", Main)
    Tabs.Position = UDim2.new(0, 0, 0, 45)
    Tabs.Size = UDim2.new(0, 130, 1, -45)
    Tabs.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    
    local Content = Instance.new("Frame", Main)
    Content.Position = UDim2.new(0, 130, 0, 45)
    Content.Size = UDim2.new(1, -130, 1, -45)
    Content.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    
    -- ScrollingFrame para conteúdo
    local function createScrollingFrame(parent)
        local sf = Instance.new("ScrollingFrame", parent)
        sf.Size = UDim2.new(1, 0, 1, 0)
        sf.CanvasSize = UDim2.new(0, 0, 0, 0)
        sf.ScrollBarThickness = 6
        sf.BackgroundTransparency = 1
        sf.BorderSizePixel = 0
        sf.ScrollingDirection = Enum.ScrollingDirection.Y
        sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
        
        local UIListLayout = Instance.new("UIListLayout", sf)
        UIListLayout.Padding = UDim.new(0, 5)
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        local Padding = Instance.new("UIPadding", sf)
        Padding.PaddingTop = UDim.new(0, 10)
        Padding.PaddingLeft = UDim.new(0, 10)
        Padding.PaddingRight = UDim.new(0, 10)
        
        return sf
    end
    
    -- Função criar Tab
    local function createTab(name)
        local btn = Instance.new("TextButton", Tabs)
        btn.Size = UDim2.new(1, 0, 0, 45)
        btn.Text = name
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        
        local page = Instance.new("Frame", Content)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.Visible = false
        page.BackgroundTransparency = 1
        
        local sf = createScrollingFrame(page)
        
        btn.MouseButton1Click:Connect(function()
            for _, v in pairs(Content:GetChildren()) do
                if v:IsA("Frame") then v.Visible = false end
            end
            for _, b in pairs(Tabs:GetChildren()) do
                if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(35, 35, 40) end
            end
            btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            page.Visible = true
        end)
        
        return sf
    end
    
    -- Função criar Toggle
    local function createToggle(parent, text, default, callback)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, -10, 0, 45)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        frame.BorderSizePixel = 0
        
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.Text = text
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.BackgroundTransparency = 1
        
        local state = default or false
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0, 60, 0, 25)
        btn.Position = UDim2.new(1, -70, 0.5, -12)
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.Text = state and "ON" or "OFF"
            btn.BackgroundColor3 = state and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
            callback(state)
        end)
        
        return frame
    end
    
    -- Função criar Slider
    local function createSlider(parent, text, min, max, default, callback)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, -10, 0, 70)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        frame.BorderSizePixel = 0
        
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, -20, 0, 25)
        label.Position = UDim2.new(0, 10, 0, 5)
        label.Text = text .. ": " .. default
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.BackgroundTransparency = 1
        
        local bar = Instance.new("Frame", frame)
        bar.Position = UDim2.new(0, 10, 0, 35)
        bar.Size = UDim2.new(1, -20, 0, 12)
        bar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        bar.BorderSizePixel = 0
        
        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        fill.BorderSizePixel = 0
        
        local draggingSlider = false
        
        local function updateSlider(input)
            local percent = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            local value = math.floor(min + (max - min) * percent)
            label.Text = text .. ": " .. value
            callback(value)
        end
        
        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = true
                updateSlider(input)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = false
            end
        end)
        
        callback(default)
        return frame
    end
    
    -- Função criar Botão
    local function createButton(parent, text, callback)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1, -10, 0, 40)
        btn.Text = text
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.BorderSizePixel = 0
        
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    -- Criar Tabs
    local FarmTab = createTab("🏠 Farm")
    local CombatTab = createTab("⚔️ Combat")
    local QuestTab = createTab("📜 Quests")
    local UpgradeTab = createTab("✨ Upgrades")
    local HacksTab = createTab("🚀 Hacks")
    local MiscTab = createTab("🎮 Misc")
    
    FarmTab.Parent.Visible = true
    Tabs:FindFirstChildWhichIsA("TextButton").BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    
    -- =============================================
    -- LÓGICA DAS FUNÇÕES (ANIME ETERNAL)
    -- =============================================
    
    -- Função para encontrar inimigos
    local function getEnemies(range)
        local enemies = {}
        local char = Player.Character
        if not char then return enemies end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return enemies end
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= char then
                local hum = obj:FindFirstChild("Humanoid")
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 then
                    local dist = (hrp.Position - root.Position).Magnitude
                    if dist <= (range or 50) then
                        table.insert(enemies, obj)
                    end
                end
            end
        end
        return enemies
    end
    
    -- Função para atacar
    local function attackEnemy(enemy)
        local char = Player.Character
        if not char then return end
        
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
        
        -- Simula clique M1
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end
    
    -- Auto Farm Loop
    local function autoFarmLoop()
        while Toggles.AutoFarm do
            local enemies = getEnemies(100)
            for _, enemy in ipairs(enemies) do
                if not Toggles.AutoFarm then break end
                if enemy and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                    local hrp = enemy:FindFirstChild("HumanoidRootPart")
                    local char = Player.Character
                    if hrp and char then
                        char.Humanoid:MoveTo(hrp.Position)
                        repeat
                            attackEnemy(enemy)
                            task.wait(0.2)
                        until not enemy.Parent or enemy.Humanoid.Health <= 0 or not Toggles.AutoFarm
                    end
                end
            end
            task.wait(0.5)
        end
    end
    
    -- Kill Aura Loop
    local function killAuraLoop()
        while Toggles.KillAura do
            local enemies = getEnemies(Settings.KillAuraRange)
            for _, enemy in ipairs(enemies) do
                if Toggles.InstantKill and enemy:FindFirstChild("Humanoid") then
                    enemy.Humanoid.Health = 0
                else
                    attackEnemy(enemy)
       
