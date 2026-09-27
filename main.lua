--[[
    redz Hub v2 — main.lua COM GUI
    Auto farm + interface visual
    Blox Fruits — Sea 1, 2, 3
--]]

--// Serviços
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

--// URL base
local BASE_URL = "https://raw.githubusercontent.com/isaquegoat/redz-hub/main/"

--// Carrega módulos
local LevelData = loadstring(game:HttpGet(BASE_URL .. "LevelData.lua"))()
local BossData  = loadstring(game:HttpGet(BASE_URL .. "BossData.lua"))()

--// ═══════════════════════════════════════════
--// CONFIGURAÇÕES
--// ═══════════════════════════════════════════
local Config = {
    FlightSpeed    = 180,
    FlightHeight   = 15,
    ClickDelay     = 0.1,
    HitboxSize     = 20,
    KillBossFirst  = true,
    RandomizeSpeed = true,
    RandomizeDelay = true,
    RandomizeHeight= true,
    PauseChance    = 0.01,
    PauseDuration  = 2,

    -- Tema
    Colors = {
        Background   = Color3.fromRGB(15, 15, 15),
        Sidebar      = Color3.fromRGB(20, 20, 20),
        Element      = Color3.fromRGB(32, 32, 32),
        ElementHover = Color3.fromRGB(44, 44, 44),
        Accent       = Color3.fromRGB(220, 30, 40),
        AccentDark   = Color3.fromRGB(160, 20, 30),
        Text         = Color3.fromRGB(240, 240, 240),
        TextDim      = Color3.fromRGB(150, 150, 150),
        Border       = Color3.fromRGB(45, 45, 45),
        ToggleOff    = Color3.fromRGB(48, 48, 48),
        ToggleOn     = Color3.fromRGB(220, 30, 40),
    },
    Font       = Enum.Font.Gotham,
    FontMedium = Enum.Font.GothamMedium,
    FontBold   = Enum.Font.GothamBold,
}

--// ═══════════════════════════════════════════
--// ESTADO
--// ═══════════════════════════════════════════
local State = {
    AutoFarmON  = false,
    KillBossON  = true,
    Running     = false,
    StopFlag    = false,
    CurrentTask = "Idle",
    KilledCount = 0,
    QuestDone   = 0,
    Level       = 1,
}

--// ═══════════════════════════════════════════
--// UTILITÁRIOS
--// ═══════════════════════════════════════════
local function getChar() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end
local function getHRP() local c = LocalPlayer.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function getHumanoid() local c = LocalPlayer.Character; return c and c:FindFirstChildOfClass("Humanoid") end

local function getLevel()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if not ls then return 1 end
    local lvl = ls:FindFirstChild("Level")
    return lvl and lvl.Value or 1
end

local function distance(a, b)
    if not a or not b then return math.huge end
    return (a.Position - b.Position).Magnitude
end

local function randomBetween(min, max)
    return min + math.random() * (max - min)
end

--// ═══════════════════════════════════════════
--// HITBOX
--// ═══════════════════════════════════════════
local function enableBigHitbox()
    local char = LocalPlayer.Character
    if not char then return end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            v.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
            v.Transparency = 1
            v.CanCollide = false
        end
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
        hrp.Transparency = 1
        hrp.CanCollide = false
    end
end

local function disableBigHitbox()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Size = Vector3.new(2, 2, 1)
        hrp.Transparency = 1
        hrp.CanCollide = true
    end
end

--// ═══════════════════════════════════════════
--// VOAR
--// ═══════════════════════════════════════════
local function flyTo(targetPart)
    if not targetPart then return false end
    local hrp = getHRP()
    if not hrp then return false end

    local height = Config.FlightHeight
    if Config.RandomizeHeight then height = randomBetween(12, 18) end

    local speed = Config.FlightSpeed
    if Config.RandomizeSpeed then speed = randomBetween(150, 180) end

    local destPos = targetPart.Position + Vector3.new(0, height, 0)
    local dist = (hrp.Position - destPos).Magnitude
    local duration = math.max(dist / speed, 0.1)

    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { CFrame = CFrame.new(destPos, targetPart.Position) }
    )
    tween:Play()

    local startTime = tick()
    while tween.PlaybackState == Enum.PlaybackState.Playing do
        if State.StopFlag then tween:Cancel(); return false end
        if tick() - startTime > duration + 2 then tween:Cancel(); break end
        task.wait(0.05)
    end
    return true
end

--// ═══════════════════════════════════════════
--// BUSCAS
--// ═══════════════════════════════════════════
local function findNearestEnemy(enemyNames)
    local hrp = getHRP()
    if not hrp then return nil end
    local closest, closestDist = nil, math.huge
    local folder = workspace:FindFirstChild("Enemies") or workspace

    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("Model") then
            local h = obj:FindFirstChildOfClass("Humanoid")
            local objHrp = obj:FindFirstChild("HumanoidRootPart")
            if h and objHrp and h.Health > 0 then
                for _, name in ipairs(enemyNames) do
                    if obj.Name:lower():find(name:lower(), 1, true) then
                        local d = distance(hrp, objHrp)
                        if d < closestDist then closest, closestDist = objHrp, d end
                        break
                    end
                end
            end
        end
    end
    return closest
end

local function findBoss(bossName)
    local hrp = getHRP()
    if not hrp then return nil end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find(bossName:lower(), 1, true) then
            local h = obj:FindFirstChildOfClass("Humanoid")
            local objHrp = obj:FindFirstChild("HumanoidRootPart")
            if h and objHrp and h.Health > 0 then return objHrp end
        end
    end
    return nil
end

local function findQuestNPC(questName)
    local hrp = getHRP()
    if not hrp then return nil end
    local folder = workspace:FindFirstChild("QuestGivers") or workspace
    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find(questName:lower(), 1, true) then
            local objHrp = obj:FindFirstChild("HumanoidRootPart")
            if objHrp then return objHrp end
        end
    end
    return nil
end

--// ═══════════════════════════════════════════
--// ATAQUE
--// ═══════════════════════════════════════════
local function attackLoop(enemyHrp)
    if not enemyHrp then return end
    local char = LocalPlayer.Character
    if not char then return end

    local startTime = tick()
    while not State.StopFlag do
        local parent = enemyHrp.Parent
        if not parent then break end
        local h = parent:FindFirstChildOfClass("Humanoid")
        if not h or h.Health <= 0 then break end

        local tool = char:FindFirstChildOfClass("Tool")
        if tool then pcall(function() tool:Activate() end) end

        local delay = Config.ClickDelay
        if Config.RandomizeDelay then delay = randomBetween(0.08, 0.18) end
        task.wait(delay)

        if tick() - startTime > 10 then break end
    end
    State.KilledCount = State.KilledCount + 1
end

--// ═══════════════════════════════════════════
--// LOOP AUTO FARM
--// ═══════════════════════════════════════════
local function autoFarmLoop()
    if State.Running then return end
    State.Running = true
    State.StopFlag = false

    enableBigHitbox()

    while not State.StopFlag do
        if not State.AutoFarmON then break end
        if not LocalPlayer.Character then break end

        -- Atualiza nível
        State.Level = getLevel()

        if math.random() < Config.PauseChance then
            State.CurrentTask = "Pausa anti-detecção"
            task.wait(Config.PauseDuration)
        end

        local info = LevelData.GetFor(State.Level)
        if not info then
            State.CurrentTask = "Sem dados pro nível " .. State.Level
            task.wait(2)
            continue
        end

        -- Boss
        if State.KillBossON and Config.KillBossFirst then
            local bosses = BossData.GetFor(State.Level, info.Island)
            if #bosses > 0 then
                local boss = bosses[1]
                State.CurrentTask = "Procurando boss: " .. boss.Boss
                local bossPart = findBoss(boss.Boss)
                if bossPart then
                    State.CurrentTask = "Voando até " .. boss.Boss
                    flyTo(bossPart)
                    State.CurrentTask = "Matando " .. boss.Boss
                    attackLoop(bossPart)
                end
            end
        end

        -- Farm normal
        local enemyList = LevelData.GetEnemyList(State.Level)
        State.CurrentTask = "Procurando: " .. table.concat(enemyList, " ou ")
        local enemyPart = findNearestEnemy(enemyList)
        if enemyPart then
            State.CurrentTask = "Voando até inimigo"
            flyTo(enemyPart)
            State.CurrentTask = "Atacando"
            attackLoop(enemyPart)
        else
            State.CurrentTask = "Nenhum inimigo encontrado"
            task.wait(1)
        end
    end

    disableBigHitbox()
    State.Running = false
    State.CurrentTask = "Parado"
    State.StopFlag = false
end
--// ═══════════════════════════════════════════
--// UI — Componentes
--// ═══════════════════════════════════════════

local function create(className, props)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function corner(parent, radius)
    return create("UICorner", { CornerRadius = UDim.new(0, radius or 6), Parent = parent })
end

local function stroke(parent, color, thickness, transparency)
    return create("UIStroke", {
        Color = color or Config.Colors.Border,
        Thickness = thickness or 1,
        Transparency = transparency or 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function tween(obj, time, props)
    local t = TweenService:Create(obj, TweenInfo.new(time or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

--// ═══════════════════════════════════════════
--// UI — Frame Principal
--// ═══════════════════════════════════════════

-- Detecta o parent (CoreGui ou PlayerGui)
local parentGui
pcall(function()
    if CoreGui:FindFirstChild("redzHubv2") then CoreGui.redzHubv2:Destroy() end
    local test = Instance.new("ScreenGui")
    test.Parent = CoreGui
    test:Destroy()
    parentGui = CoreGui
end)
if not parentGui then
    parentGui = LocalPlayer:WaitForChild("PlayerGui")
end

local ScreenGui = create("ScreenGui", {
    Name = "redzHubv2",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    Parent = parentGui,
})

local Main = create("Frame", {
    Name = "Main",
    Parent = ScreenGui,
    BackgroundColor3 = Config.Colors.Background,
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    Size = UDim2.new(0, 620, 0, 420),
    Position = UDim2.new(0.5, -310, 0.5, -210),
    Active = true,
    Draggable = true,
})
corner(Main, 10)
stroke(Main, Config.Colors.Border, 1, 0.3)

-- Topbar
local TopBar = create("Frame", {
    Name = "TopBar",
    Parent = Main,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 42),
})

create("TextLabel", {
    Parent = TopBar,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 16, 0, 6),
    Size = UDim2.new(0, 200, 0, 18),
    Font = Config.FontBold,
    Text = "redz Hub v2",
    TextColor3 = Config.Colors.Text,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
})

create("TextLabel", {
    Parent = TopBar,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 16, 0, 24),
    Size = UDim2.new(0, 200, 0, 12),
    Font = Config.Font,
    Text = "by tsread",
    TextColor3 = Config.Colors.TextDim,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
})

-- Botões min/fechar
local btnContainer = create("Frame", {
    Parent = TopBar,
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -76, 0, 10),
    Size = UDim2.new(0, 66, 0, 22),
})

local function makeWinBtn(text, xPos, hoverColor, callback)
    local btn = create("TextButton", {
        Parent = btnContainer,
        BackgroundColor3 = Config.Colors.Element,
        BorderSizePixel = 0,
        Position = UDim2.new(0, xPos, 0, 0),
        Size = UDim2.new(0, 20, 0, 20),
        Font = Config.FontBold,
        Text = text,
        TextColor3 = Config.Colors.Text,
        TextSize = 12,
        AutoButtonColor = false,
    })
    corner(btn, 5)
    btn.MouseEnter:Connect(function() tween(btn, 0.15, { BackgroundColor3 = hoverColor }) end)
    btn.MouseLeave:Connect(function() tween(btn, 0.15, { BackgroundColor3 = Config.Colors.Element }) end)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

makeWinBtn("–", 0, Config.Colors.ElementHover, function()
    Main.Visible = false
    local reopen = create("TextButton", {
        Parent = ScreenGui,
        BackgroundColor3 = Config.Colors.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 100, 0, 28),
        Position = UDim2.new(0, 20, 0, 60),
        Font = Config.FontBold,
        Text = "redz Hub v2",
        TextColor3 = Config.Colors.Text,
        TextSize = 11,
        AutoButtonColor = false,
        Name = "Reopen",
    })
    corner(reopen, 6)
    reopen.MouseButton1Click:Connect(function()
        Main.Visible = true
        reopen:Destroy()
    end)
end)

makeWinBtn("✕", 24, Color3.fromRGB(180, 30, 40), function()
    ScreenGui:Destroy()
    State.StopFlag = true
end)

create("Frame", {
    Parent = TopBar,
    BackgroundColor3 = Config.Colors.Border,
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 1, -1),
    Size = UDim2.new(1, 0, 0, 1),
})

-- Sidebar
local Sidebar = create("Frame", {
    Parent = Main,
    BackgroundColor3 = Config.Colors.Sidebar,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, 42),
    Size = UDim2.new(0, 140, 1, -42),
})

local SideScroll = create("ScrollingFrame", {
    Parent = Sidebar,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 6, 0, 8),
    Size = UDim2.new(1, -12, 1, -16),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Config.Colors.Accent,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
})
create("UIListLayout", { Parent = SideScroll, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder })

-- Content
local Content = create("Frame", {
    Parent = Main,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 140, 0, 42),
    Size = UDim2.new(1, -140, 1, -42),
})

-- Categorias
local CATEGORIES = {
    "Info & Server", "Tab Farming", "Stack Farm", "Farm Mastery",
    "Sea Event", "Upgrade V4", "Dojo & Drago Race", "Get Item & Upgrade",
    "Raid & Fruit", "Local Player", "Local Shop", "Stats & ESP",
    "Tab Teleport", "Setting & UI",
}

local Pages = {}
local CurrentPage = nil

local function switchPage(name)
    for pageName, page in pairs(Pages) do
        page.Visible = (pageName == name)
    end
    CurrentPage = name
end

local buttons = {}
local selected = nil

for _, catName in ipairs(CATEGORIES) do
    local btn = create("TextButton", {
        Parent = SideScroll,
        BackgroundColor3 = Config.Colors.Element,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 26),
        Font = Config.FontMedium,
        Text = "  " .. catName,
        TextColor3 = Config.Colors.TextDim,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        Name = catName,
    })
    corner(btn, 5)

    local indicator = create("Frame", {
        Parent = btn,
        BackgroundColor3 = Config.Colors.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 2, 0.6, 0),
        Position = UDim2.new(0, 0, 0.2, 0),
        Visible = false,
        Name = "Indicator",
    })
    corner(indicator, 2)

    btn.MouseEnter:Connect(function()
        if selected ~= catName then
            tween(btn, 0.12, { BackgroundTransparency = 0.6, TextColor3 = Config.Colors.Text })
        end
    end)
    btn.MouseLeave:Connect(function()
        if selected ~= catName then
            tween(btn, 0.12, { BackgroundTransparency = 1, TextColor3 = Config.Colors.TextDim })
        end
    end)
    btn.MouseButton1Click:Connect(function()
        if selected == catName then return end
        selected = catName
        for _, other in ipairs(buttons) do
            other.BackgroundTransparency = 1
            other.TextColor3 = Config.Colors.TextDim
            other.Indicator.Visible = false
        end
        btn.BackgroundTransparency = 0.4
        btn.TextColor3 = Config.Colors.Text
        indicator.Visible = true
        switchPage(catName)
    end)

    buttons[#buttons + 1] = btn

    -- Cria página
    local page = create("ScrollingFrame", {
        Parent = Content,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Config.Colors.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Name = catName,
    })
    create("UIPadding", {
        Parent = page,
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
    })
    create("UIListLayout", { Parent = page, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })
    Pages[catName] = page
end

--// ═══════════════════════════════════════════
--// Componentes
--// ═══════════════════════════════════════════

local function addSection(page, text)
    return create("TextLabel", {
        Parent = page,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        Font = Config.FontBold,
        Text = text,
        TextColor3 = Config.Colors.Accent,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
end

local function addToggle(page, name, default, callback)
    local state = default or false

    local btn = create("TextButton", {
        Parent = page,
        BackgroundColor3 = Config.Colors.Element,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 28),
        Text = "",
        AutoButtonColor = false,
        Name = name,
    })
    corner(btn, 6)
    stroke(btn, Config.Colors.Border, 1, 0.6)

    create("TextLabel", {
        Parent = btn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        Font = Config.FontMedium,
        Text = name,
        TextColor3 = Config.Colors.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local sw = create("Frame", {
        Parent = btn,
        BackgroundColor3 = state and Config.Colors.ToggleOn or Config.Colors.ToggleOff,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -42, 0.5, -8),
        Size = UDim2.new(0, 34, 0, 16),
    })
    corner(sw, 8)

    local knob = create("Frame", {
        Parent = sw,
        BackgroundColor3 = Color3.fromRGB(240, 240, 240),
        BorderSizePixel = 0,
        Position = state and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2),
        Size = UDim2.new(0, 12, 0, 12),
    })
    corner(knob, 6)

    local function update()
        tween(sw, 0.15, { BackgroundColor3 = state and Config.Colors.ToggleOn or Config.Colors.ToggleOff })
        tween(knob, 0.15, { Position = state and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2) })
    end

    btn.MouseButton1Click:Connect(function()
        state = not state
        update()
        if callback then task.spawn(callback, state) end
    end)
    btn.MouseEnter:Connect(function() tween(btn, 0.12, { BackgroundColor3 = Config.Colors.ElementHover }) end)
    btn.MouseLeave:Connect(function() tween(btn, 0.12, { BackgroundColor3 = Config.Colors.Element }) end)

    return { Set = function(v) state = v; update(); if callback then callback(v) end end }
end

local function addSlider(page, name, minV, maxV, default, callback)
    local value = default or minV

    local container = create("Frame", {
        Parent = page,
        BackgroundColor3 = Config.Colors.Element,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 32),
        Name = name,
    })
    corner(container, 6)
    stroke(container, Config.Colors.Border, 1, 0.6)

    create("TextLabel", {
        Parent = container, BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 2), Size = UDim2.new(0.7, 0, 0, 14),
        Font = Config.FontMedium, Text = name,
        TextColor3 = Config.Colors.Text, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local valLbl = create("TextLabel", {
        Parent = container, BackgroundTransparency = 1,
        Position = UDim2.new(0.7, 0, 0, 2), Size = UDim2.new(0.3, -10, 0, 14),
        Font = Config.FontBold, Text = tostring(value),
        TextColor3 = Config.Colors.Accent, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right,
    })

    local track = create("Frame", {
        Parent = container,
        BackgroundColor3 = Config.Colors.ToggleOff,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 1, -12),
        Size = UDim2.new(1, -20, 0, 4),
    })
    corner(track, 2)

    local fill = create("Frame", {
        Parent = track,
        BackgroundColor3 = Config.Colors.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new((value - minV) / (maxV - minV), 0, 1, 0),
    })
    corner(fill, 2)

    local dragging = false
    local function updateFromX(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local v = math.floor(minV + (maxV - minV) * rel + 0.5)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        valLbl.Text = tostring(v)
        if callback then callback(v) end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromX(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function addButton(page, name, callback)
    local btn = create("TextButton", {
        Parent = page,
        BackgroundColor3 = Config.Colors.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 28),
        Font = Config.FontBold,
        Text = name,
        TextColor3 = Config.Colors.Text,
        TextSize = 11,
        AutoButtonColor = false,
    })
    corner(btn, 6)
    btn.MouseEnter:Connect(function() tween(btn, 0.12, { BackgroundColor3 = Config.Colors.AccentDark }) end)
    btn.MouseLeave:Connect(function() tween(btn, 0.12, { BackgroundColor3 = Config.Colors.Accent }) end)
    btn.MouseButton1Click:Connect(function()
        if callback then task.spawn(callback) end
    end)
    return btn
end

local function addInfo(page, name)
    local lbl = create("TextLabel", {
        Parent = page,
        BackgroundColor3 = Config.Colors.Element,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 24),
        Font = Config.Font,
        Text = "  " .. name,
        TextColor3 = Config.Colors.TextDim,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Name = name,
    })
    corner(lbl, 6)
    stroke(lbl, Config.Colors.Border, 1, 0.6)
    return lbl
end

--// ═══════════════════════════════════════════
--// Preenche as abas
--// ═══════════════════════════════════════════

-- Info & Server
do
    local page = Pages["Info & Server"]
    addSection(page, "INFO")
    addInfo(page, "Player: " .. LocalPlayer.Name)
    local lvlInfo = addInfo(page, "Level: --")
    addInfo(page, "Server: " .. game.JobId:sub(1, 8))

    -- Atualiza level na tela
    task.spawn(function()
        while ScreenGui.Parent do
            lvlInfo.Text = "  Level: " .. getLevel()
            task.wait(1)
        end
    end)

    addButton(page, "Copy Job ID", function()
        if setclipboard then setclipboard(game.JobId) end
    end)
end

-- Tab Farming
do
    local page = Pages["Tab Farming"]
    addSection(page, "AUTO FARM")
    addToggle(page, "Auto Farm Level", false, function(v)
        if v then
            State.AutoFarmON = true
            task.spawn(autoFarmLoop)
        else
            State.AutoFarmON = false
            State.StopFlag = true
        end
    end)
    addToggle(page, "Kill Boss First", true, function(v)
        State.KillBossON = v
    end)

    addSection(page, "STATUS")
    local statusLbl = addInfo(page, "Status: Idle")
    local killedLbl = addInfo(page, "Killed: 0")

    task.spawn(function()
        while ScreenGui.Parent do
            statusLbl.Text = "  Status: " .. State.CurrentTask
            killedLbl.Text = "  Killed: " .. State.KilledCount
            task.wait(0.5)
        end
    end)

    addSection(page, "CONFIG")
    addSlider(page, "Flight Speed", 50, 300, 180, function(v) Config.FlightSpeed = v end)
    addSlider(page, "Flight Height", 5, 30, 15, function(v) Config.FlightHeight = v end)
    addSlider(page, "Click Delay", 5, 30, 10, function(v) Config.ClickDelay = v / 100 end)
    addSlider(page, "Hitbox Size", 5, 50, 20, function(v) Config.HitboxSize = v end)
end

-- Local Player
do
    local page = Pages["Local Player"]
    addSection(page, "CHARACTER")
    addSlider(page, "WalkSpeed", 16, 300, 16, function(v)
        local h = getHumanoid()
        if h then h.WalkSpeed = v end
    end)
    addSlider(page, "JumpPower", 50, 500, 50, function(v)
        local h = getHumanoid()
        if h then h.JumpPower = v end
    end)
    addToggle(page, "Infinite Jump", false, function(v)
        if v then
            task.spawn(function()
                while State.AutoFarmON or ScreenGui.Parent do
                    if not ScreenGui.Parent then break end
                    task.wait(0.2)
                end
            end)
        end
    end)
    addToggle(page, "NoClip", false, function(v)
        if v then
            task.spawn(function()
                while ScreenGui.Parent do
                    local char = LocalPlayer.Character
                    if char then
                        for _, p in ipairs(char:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end
                    task.wait(0.2)
                end
            end)
        end
    end)
end

-- Tab Teleport
do
    local page = Pages["Tab Teleport"]
    addSection(page, "TELEPORT")
    addButton(page, "Teleport to Spawn", function()
        local hrp = getHRP()
        if hrp then hrp.CFrame = CFrame.new(0, 10, 0) end
    end)
    addButton(page, "Stop Farm", function()
        State.StopFlag = true
        State.AutoFarmON = false
    end)
end

-- Setting & UI
do
    local page = Pages["Setting & UI"]
    addSection(page, "UI")
    addToggle(page, "UI Visible", true, function(v)
        Main.Visible = v
    end)

    addSection(page, "SERVER")
    addButton(page, "Rejoin", function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)
end

-- Abre a primeira aba
if buttons[2] then
    buttons[2].BackgroundTransparency = 0.4
    buttons[2].TextColor3 = Config.Colors.Text
    buttons[2].Indicator.Visible = true
    selected = "Tab Farming"
    switchPage("Tab Farming")
end

--// Notificação
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "redz Hub v2",
        Text = "GUI carregada!",
        Duration = 4,
    })
end)

print("[redz Hub v2] GUI carregada com sucesso!")
