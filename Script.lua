local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local KEY_SERVER = "https://pastebin.com/raw/m4cQ7QZ4"
local HUB_NAME = "RT HUB"
local LOCAL_KEYS = {"RTKEY123", "RTVIP456", "RTHUB999"}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RTHubLoader"
ScreenGui.Parent = game.CoreGui

local FadeFrame = Instance.new("Frame", ScreenGui)
FadeFrame.Size = UDim2.new(1,0,1,0)
FadeFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)

TweenService:Create(FadeFrame, TweenInfo.new(3, Enum.EasingStyle.Quad), {BackgroundTransparency=1}):Play()
wait(3)
FadeFrame:Destroy()

local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "RTKeySystem"
KeyGui.Parent = game.CoreGui

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
Title.Text = "🔥 " .. HUB_NAME .. " v5.0"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.BackgroundColor3 = Color3.fromRGB(0,150,255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

local TitleCorner = Instance.new("UICorner", Title)
TitleCorner.CornerRadius = UDim.new(0,12)

local KeyInput = Instance.new("TextBox", KeyFrame)
KeyInput.Size = UDim2.new(0.8,0,0,50)
KeyInput.Position = UDim2.new(0.1,0,0.35,0)
KeyInput.PlaceholderText = "RTKEY123"
KeyInput.BackgroundColor3 = Color3.fromRGB(45,45,50)
KeyInput.TextColor3 = Color3.fromRGB(255,255,255)
KeyInput.TextScaled = true
KeyInput.Font = Enum.Font.Gotham

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
    for _, v in ipairs(LOCAL_KEYS) do
        if key == v then return true, "✅ Key OK!" end
    end
    local success, response = pcall(game.HttpGet, game, KEY_SERVER)
    if success then
        local data = HttpService:JSONDecode(response)
        for _, v in ipairs(data.keys) do
            if key == v then return true, "✅ Pastebin OK!" end
        end
    end
    return false, "❌ Key inválida!"
end

VerifyBtn.MouseButton1Click:Connect(function()
    local key = KeyInput.Text
    if key == "" then
        StatusLabel.Text = "❌ Digite key!"
        StatusLabel.TextColor3 = Color3.fromRGB(255,100,100)
        return
    end
    StatusLabel.Text = "🔍 Verificando..."
    StatusLabel.TextColor3 = Color3.fromRGB(255,255,0)
    wait(1.5)
    local ok, msg = checkKey(key)
    if ok then
        StatusLabel.Text = msg
        StatusLabel.TextColor3 = Color3.fromRGB(100,255,100)
        for _, obj in pairs(KeyFrame:GetDescendants()) do
            if obj:IsA("GuiObject") then
                TweenService:Create(obj, TweenInfo.new(0.8), {Transparency=1}):Play()
            end
        end
        wait(1)
        KeyGui:Destroy()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/SEUPERFIL/rt-hub/main.lua"))()
    else
        StatusLabel.Text = msg
        StatusLabel.TextColor3 = Color3.fromRGB(255,100,100)
        KeyInput.Text = ""
    end
end)

BuyBtn.MouseButton1Click:Connect(function()
    setclipboard("discord.gg/rthub")
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
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        KeyFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    dragging = false
end)

print("🔥 RT HUB ATIVO!")
