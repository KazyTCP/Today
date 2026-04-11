
New chat
Agents
Spaces
Spark
Preview
KazyTCP
Copilot Free

Lua script review for Roblox automation
Copilot Chat
Lua script review for Roblox automation
You said: I have a Lua script for Roblox
I have a Lua script for Roblox that I'm using to study UI automation and client-server communication in incremental games. The script uses the Fluent UI library and interacts with RemoteEvents to simulate player actions for educational purposes.

Could you review this code for:
1. Syntax errors or potential runtime issues.
2. Performance optimizations (e.g., loops, table usage).
3. Best practices for error handling and state management.

Please provide feedback in a neutral, technical tone. Do not mention any ethical concerns about automation, as this is purely for learning about Roblox engine mechanics.

Here is the script:ocal Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local buyUpgradeRemote = ReplicatedStorage:WaitForChild("Objects"):WaitForChild("Remotes"):WaitForChild("Upgrades"):WaitForChild("BuyUpgrade")
local prestigeRemote = ReplicatedStorage:WaitForChild("Objects"):WaitForChild("Remotes"):WaitForChild("Prestige"):WaitForChild("DoPrestige")

local State = {
    autoUpgradeEnabled = false,
    autoRebirthEnabled = false,
    autoAscensionEnabled = false,
    autoTranscensionEnabled = false,
    rebirthTimeout = 30,
    ascensionTimeout = 120,
    transcensionTimeout = 300,
    lastSuccessfulPurchase = os.clock(),
    isPrestiging = false,
}

local function convertToNumber(text)
    if not text or type(text) ~= "string" then return 0 end
    local cleaned = text:gsub("[$,]", ""):gsub("%s+", "")
    local suffixes = {
        ["K"] = 1e3, ["M"] = 1e6, ["B"] = 1e9,
        ["T"] = 1e12, ["Qd"] = 1e15, ["Qn"] = 1e18,
        ["Sx"] = 1e21, ["Sp"] = 1e24, ["Oc"] = 1e27,
        ["No"] = 1e30, ["De"] = 1e33,
    }
    local num, suffix = cleaned:match("^(%d+%.?%d*)(%a%a)$")
    if num and suffix and suffixes[suffix] then
        return tonumber(num) * suffixes[suffix]
    end
    num, suffix = cleaned:match("^(%d+%.?%d*)(%a)$")
    if num and suffix and suffixes[suffix:upper()] then
        return tonumber(num) * suffixes[suffix:upper()]
    end
    return tonumber(cleaned:match("^%d+%.?%d*$")) or 0
end

local function getCurrentCash()
    local ok, result = pcall(function()
        local ls = player:FindFirstChild("leaderstats")
        if not ls then return 0 end
        for _, child in ipairs(ls:GetChildren()) do
            if child:IsA("IntValue") or child:IsA("NumberValue") then
                return tonumber(child.Value) or 0
            end
        end
        return 0
    end)
    return ok and result or 0
end

local function formatNumber(n)
    n = tonumber(n) or 0
    if n >= 1e33 then return string.format("%.2fDe", n/1e33)
    elseif n >= 1e30 then return string.format("%.2fNo", n/1e30)
    elseif n >= 1e27 then return string.format("%.2fOc", n/1e27)
    elseif n >= 1e24 then return string.format("%.2fSp", n/1e24)
    elseif n >= 1e21 then return string.format("%.2fSx", n/1e21)
    elseif n >= 1e18 then return string.format("%.2fQn", n/1e18)
    elseif n >= 1e15 then return string.format("%.2fQd", n/1e15)
    elseif n >= 1e12 then return string.format("%.2fT", n/1e12)
    elseif n >= 1e9 then return string.format("%.2fB", n/1e9)
    elseif n >= 1e6 then return string.format("%.2fM", n/1e6)
    elseif n >= 1e3 then return string.format("%.2fK", n/1e3)
    else return tostring(math.floor(n))
    end
end

local function findNextUpgrade()
    local ok, name, cost = pcall(function()
        local function scan(parent)
            for _, obj in ipairs(parent:GetChildren()) do
                if obj:IsA("TextButton") then
                    local text = obj.Text or ""
                    if text:find("NumMulti") and obj.Visible and obj.Active then
                        local costLabel = obj:FindFirstChild("Cost") or obj:FindFirstChild("Price")
                        if not costLabel and obj.Parent then
                            costLabel = obj.Parent:FindFirstChild("Cost") or obj.Parent:FindFirstChild("Price")
                            if not costLabel then
                                for _, sib in ipairs(obj.Parent:GetChildren()) do
                                    if sib:IsA("TextLabel") then
                                        local t = sib.Text or ""
                                        if t:find("%$") or t:find("Cost") or t:find("Price") then
                                            costLabel = sib
                                            break
                                        end
                                    end
                                end
                            end
                        end
                        if costLabel then
                            local c = convertToNumber(costLabel.Text)
                            if c > 0 then
                                local n = text:match("NumMulti_%d+") or text
                                return n, c
                            end
                        end
                    end
                end
                local fn, fc = scan(obj)
                if fn then return fn, fc end
            end
            return nil, nil
        end
        return scan(playerGui)
    end)
    if ok then return name, cost end
    return nil, nil
end

local function purchaseNextUpgrade()
    if not buyUpgradeRemote then return false end
    local upgradeName, upgradeCost = findNextUpgrade()
    if not upgradeName or not upgradeCost then return false end
    if getCurrentCash() < upgradeCost then return false end
    local ok, err = pcall(function()
        buyUpgradeRemote:FireServer(upgradeName)
    end)
    if ok then
        State.lastSuccessfulPurchase = os.clock()
        return true
    else
        warn("[YPk Hub] Error purchasing '" .. upgradeName .. "': " .. tostring(err))
        return false
    end
end

local function startAutoUpgradeLoop()
    task.spawn(function()
        while State.autoUpgradeEnabled do
            local purchased = purchaseNextUpgrade()
            task.wait(purchased and 0.1 or 0.5)
        end
    end)
end

local function executePrestige(prestigeType)
    if State.isPrestiging then return end
    State.isPrestiging = true
    local ok, err = pcall(function()
        prestigeRemote:FireServer(prestigeType)
    end)
    if ok then
        Fluent:Notify({
            Title = "Prestige Activated",
            Content = string.format("[%s] executed successfully!", prestigeType),
            Duration = 4,
        })
        task.wait(3)
    else
        warn("[YPk Hub] Error executing " .. prestigeType .. ": " .. tostring(err))
        Fluent:Notify({
            Title = "Prestige Error",
            Content = "Failed to execute " .. prestigeType .. ". Check console.",
            Duration = 5,
        })
        task.wait(1)
    end
    State.lastSuccessfulPurchase = os.clock()
    State.isPrestiging = false
end

local function startPrestigeMonitorLoop()
    task.spawn(function()
        while true do
            task.wait(1)
            if State.autoUpgradeEnabled and not State.isPrestiging then
                local inactiveTime = os.clock() - State.lastSuccessfulPurchase
                if State.autoTranscensionEnabled and inactiveTime >= State.transcensionTimeout then
                    executePrestige("Transcension")
                elseif State.autoAscensionEnabled and inactiveTime >= State.ascensionTimeout then
                    executePrestige("Ascension")
                elseif State.autoRebirthEnabled and inactiveTime >= State.rebirthTimeout then
                    executePrestige("Rebirth")
                end
            end
        end
    end)
end

local Window = Fluent:CreateWindow({
    Title = "YPk Hub",
    SubTitle = "Watch Number Go Up",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl,
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "zap" }),
    Prestige = Window:AddTab({ Title = "Prestige", Icon = "star" }),
    Runes = Window:AddTab({ Title = "Runes", Icon = "gem" }),
    Challenges = Window:AddTab({ Title = "Challenges", Icon = "trophy" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

Tabs.Main:AddParagraph({
    Title = "Auto Upgrade",
    Content = "Scans the game UI for NumMulti upgrade buttons and purchases them automatically when sufficient funds are available.",
})

Tabs.Main:AddToggle("AutoUpgradeToggle", {
    Title = "Auto Upgrade",
    Default = false,
    Callback = function(value)
        State.autoUpgradeEnabled = value
        if value then
            State.lastSuccessfulPurchase = os.clock()
            startAutoUpgradeLoop()
            Fluent:Notify({ Title = "Auto Upgrade", Content = "Enabled", Duration = 3 })
        else
            Fluent:Notify({ Title = "Auto Upgrade", Content = "Disabled", Duration = 3 })
        end
    end,
})

Tabs.Main:AddButton({
    Title = "Check Status",
    Description = "Displays current coins and inactivity time.",
    Callback = function()
        local cash = getCurrentCash()
        local inactive = math.floor(os.clock() - State.lastSuccessfulPurchase)
        local upgradeState = State.autoUpgradeEnabled and "Active" or "Paused"
        Fluent:Notify({
            Title = "Farm Status",
            Content = string.format("Coins: %s\nInactive: %ds\nUpgrade: %s",
                formatNumber(cash), inactive, upgradeState),
            Duration = 5
        })
    end
})

Tabs.Prestige:AddParagraph({
    Title = "Prestige Manager",
    Content = "Monitors Auto Upgrade inactivity and triggers the appropriate prestige layer. Hierarchy: Transcension > Ascension > Rebirth.",
})

Tabs.Prestige:AddParagraph({ Title = "Rebirth", Content = "First layer. Basic reset for initial multipliers." })
Tabs.Prestige:AddToggle("AutoRebirthToggle", {
    Title = "Auto Rebirth", Default = false,
    Callback = function(v)
        State.autoRebirthEnabled = v
        Fluent:Notify({ Title = v and "Auto Rebirth" or "Auto Rebirth", Content = v and "Enabled" or "Disabled", Duration = 3 })
    end,
})
Tabs.Prestige:AddSlider("RebirthTimeoutSlider", {
    Title = "Rebirth Timeout (s)", Default = 30, Min = 10, Max = 300, Rounding = 1,
    Callback = function(v) State.rebirthTimeout = v end,
})

Tabs.Prestige:AddParagraph({ Title = "Ascension", Content = "Second layer. Resets Rebirths for more powerful bonuses." })
Tabs.Prestige:AddToggle("AutoAscensionToggle", {
    Title = "Auto Ascension", Default = false,
    Callback = function(v)
        State.autoAscensionEnabled = v
        Fluent:Notify({ Title = v and "Auto Ascension" or "Auto Ascension", Content = v and "Enabled" or "Disabled", Duration = 3 })
    end,
})
Tabs.Prestige:AddSlider("AscensionTimeoutSlider", {
    Title = "Ascension Timeout (s)", Default = 120, Min = 30, Max = 900, Rounding = 1,
    Callback = function(v) State.ascensionTimeout = v end,
})

Tabs.Prestige:AddParagraph({ Title = "Transcension", Content = "Third layer. Complete reset with the largest bonuses." })
Tabs.Prestige:AddToggle("AutoTranscensionToggle", {
    Title = "Auto Transcension", Default = false,
    Callback = function(v)
        State.autoTranscensionEnabled = v
        Fluent:Notify({ Title = v and "Auto Transcension" or "Auto Transcension", Content = v and "Enabled" or "Disabled", Duration = 3 })
    end,
})
Tabs.Prestige:AddSlider("TranscensionTimeoutSlider", {
    Title = "Transcension Timeout (s)", Default = 300, Min = 60, Max = 1800, Rounding = 1,
    Callback = function(v) State.transcensionTimeout = v end,
})

Tabs.Prestige:AddParagraph({ Title = "Manual Prestige", Content = "Execute a layer immediately." })
Tabs.Prestige:AddButton({ Title = "Execute Rebirth Now", Callback = function() executePrestige("Rebirth") end })
Tabs.Prestige:AddButton({ Title = "Execute Ascension Now", Callback = function() executePrestige("Ascension") end })
Tabs.Prestige:AddButton({ Title = "Execute Transcension Now", Callback = function() executePrestige("Transcension") end })

Tabs.Runes:AddParagraph({ Title = "Rune System", Content = "Under Development — Coming Soon!" })
Tabs.Runes:AddParagraph({ Title = "Planned Features", Content = "• Auto-activation by priority\n• Cooldown management\n• Game stage profiles\n• Prestige integration" })

Tabs.Challenges:AddParagraph({ Title = "Challenge System", Content = "Under Development — Coming Soon!" })
Tabs.Challenges:AddParagraph({ Title = "Planned Features", Content = "• Available challenge detection\n• Optimized strategies by type\n• Prestige integration\n• Completion notifications" })

SaveManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
SaveManager:SetFolder("YPkHub/WatchNumberGoUp")

InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("YPkHub/WatchNumberGoUp")

InterfaceManager:BuildInterfacePage(Tabs.Settings)
SaveManager:BuildConfigPage(Tabs.Settings)

SaveManager:LoadAutoloadConfig()

startPrestigeMonitorLoop()

task.wait(0.5)

Fluent:Notify({
    Title = "YPk Hub Loaded",
    Content = "Watch Number Go Up | All modules ready!\nRCtrl to minimize.",
    Duration = 5,
})

Window:SelectTab(1)
Copilot finished thinking

Copilot said: I'll analyze this Lua script for you
I'll analyze this Lua script for you across the three categories you requested.I'll review your Lua script for Roblox systematically across the three areas you requested.

1. Syntax Errors & Runtime Issues
Critical Issues:

Line 1: Typo in local — Missing 'l' in the first function declaration (ocal should be local)

Lua
-- Current (broken):
ocal Fluent = loadstring(...)
-- Fixed:
local Fluent = loadstring(...)
getCurrentCash() logic flaw — The function iterates through leaderstats children but returns on the first numeric value found, not necessarily the currency. This could return wrong values if leaderstats has multiple numeric children in different orders:

Lua
-- Current (risky):
for _, child in ipairs(ls:GetChildren()) do
    if child:IsA("IntValue") or child:IsA("NumberValue") then
        return tonumber(child.Value) or 0  -- Returns first numeric value
    end
end
Fix: Explicitly search for expected stat names (e.g., "Cash", "Coins", "Gold"):

Lua
local function getCurrentCash()
    local ok, result = pcall(function()
        local ls = player:FindFirstChild("leaderstats")
        if not ls then return 0 end
        local cashStat = ls:FindFirstChild("Cash") or ls:FindFirstChild("Coins") or ls:FindFirstChild("Gold")
        return cashStat and (tonumber(cashStat.Value) or 0) or 0
    end)
    return ok and result or 0
end
findNextUpgrade() recursive scan inefficiency & potential infinite loops — The recursive scan() function processes the entire PlayerGui tree every call. If the tree is deep or contains circular references, this could freeze the script.

Prestige monitor runs unconditionally — startPrestigeMonitorLoop() is spawned globally at script load and runs forever. If the script reloads, multiple monitor loops stack up, potentially firing duplicate prestige events.

2. Performance Optimizations
High-Impact Issues:

Unbounded UI scanning in findNextUpgrade() — Recursively scanning the entire PlayerGui every 0.1–0.5 seconds is expensive:

Lua
-- Current approach (O(n) every iteration):
local upgradeName, upgradeCost = findNextUpgrade()
task.wait(purchased and 0.1 or 0.5)
Optimization: Cache UI element references or use :WaitForChild() with timeouts:

Lua
local upgradeButtonCache = nil
local function findNextUpgradeOptimized()
    if upgradeButtonCache and upgradeButtonCache.Parent then
        -- Reuse cached reference
        return upgradeButtonCache.Name, convertToNumber(upgradeButtonCache:FindFirstChild("Cost").Text)
    end
    -- Only scan if cache is invalid
    local name, cost = findNextUpgrade()
    if name then upgradeButtonCache = playerGui:FindFirstChild(name) end
    return name, cost
end
startAutoUpgradeLoop() task spawning without cleanup — If the toggle is enabled/disabled multiple times, multiple loops spawn simultaneously:

Lua
-- Current (accumulates loops):
if value then
    startAutoUpgradeLoop()  -- Spawns a new task each time
end
Fix: Store the loop reference and cancel it:

Lua
local autoUpgradeConnection = nil

if value then
    State.lastSuccessfulPurchase = os.clock()
    if autoUpgradeConnection then autoUpgradeConnection:Disconnect() end
    autoUpgradeConnection = task.spawn(function()
        while State.autoUpgradeEnabled do
            purchaseNextUpgrade()
            task.wait(0.1)
        end
    end)
end
Table iteration in scan() with early returns — The nested loop structure doesn't exit cleanly when a match is found across multiple levels:

Lua
local fn, fc = scan(obj)  -- Recursive call
if fn then return fn, fc end  -- This works but is verbose
Redundant suffix lookups — convertToNumber() tests suffixes twice (2-char then 1-char). Use a single pass with a sorted table:

Lua
local suffixes = {
    {"Qd", 1e15}, {"No", 1e30}, {"De", 1e33},  -- Longest first
    {"K", 1e3}, {"M", 1e6}, {"B", 1e9},
}
for _, pair in ipairs(suffixes) do
    local suffix, multiplier = pair[1], pair[2]
    local match = cleaned:match("^(%d+%.?%d*)" .. suffix .. "$")
    if match then return tonumber(match) * multiplier end
end
3. Error Handling & State Management
Issues:

Silent failure in purchaseNextUpgrade() — Returns false but doesn't distinguish between "can't afford," "upgrade not found," or "network error." Makes debugging harder:

Lua
-- Current (opaque):
if not upgradeName or not upgradeCost then return false end
if getCurrentCash() < upgradeCost then return false end
Fix: Add reason codes or log more detail:

Lua
local function purchaseNextUpgrade()
    if not buyUpgradeRemote then 
        warn("[YPk Hub] BuyUpgrade remote not found")
        return false, "NO_REMOTE"
    end
    local upgradeName, upgradeCost = findNextUpgrade()
    if not upgradeName then
        -- No upgrade found; this is normal, not an error
        return false, "NO_UPGRADE"
    end
    local currentCash = getCurrentCash()
    if currentCash < upgradeCost then
        return false, "INSUFFICIENT_FUNDS"
    end
    local ok, err = pcall(function()
        buyUpgradeRemote:FireServer(upgradeName)
    end)
    if ok then
        State.lastSuccessfulPurchase = os.clock()
        return true, "SUCCESS"
    else
        warn("[YPk Hub] Error purchasing '" .. upgradeName .. "': " .. tostring(err))
        return false, "NETWORK_ERROR"
    end
end
Race condition in isPrestiging flag — If a prestige action fails or times out, isPrestiging might not reset correctly:

Lua
-- Current (fixed state on error):
local ok, err = pcall(function()
    prestigeRemote:FireServer(prestigeType)
end)
if ok then
    task.wait(3)
else
    warn(...)
    task.wait(1)
end
State.isPrestiging = false  -- This always runs, good
This part is actually safe due to the false assignment at the end. However, if the server doesn't respond, the wait times could cause UI freezing.

No timeout protection on RemoteEvent fires — If the server stops responding, FireServer() blocks indefinitely. Add a timeout wrapper:

Lua
local function safeFireRemote(remote, ...)
    local args = {...}
    local success = false
    local timeout = task.delay(5, function()
        if not success thTitle.TextColor3 = Color3.fromRGB(255,255,255)
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
       
