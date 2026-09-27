--[[
    redz Hub v2 — main.lua
    Script principal do auto farm
    Blox Fruits — Sea 1, 2, 3

    ⚠️  AVISO: Este script é detectável. Use por sua conta e risco.
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

--// URL base (muda se você mudar o repo)
local BASE_URL = "https://raw.githubusercontent.com/isaquegoat/redz-hub/main/"

--// Carrega módulos do GitHub
local LevelData = loadstring(game:HttpGet(BASE_URL .. "LevelData.lua"))()
local BossData  = loadstring(game:HttpGet(BASE_URL .. "BossData.lua"))()

--// ═══════════════════════════════════════════
--// CONFIGURAÇÕES
--// ═══════════════════════════════════════════
local Config = {
    -- Movimento
    FlightSpeed    = 180,   -- studs por segundo
    FlightHeight   = 15,    -- studs acima do alvo
    TweenDuration  = 0.5,   -- duração do tween

    -- Ataque
    ClickDelay     = 0.1,   -- delay entre cliques
    AttackRange    = 20,    -- alcance do M1 (studs)
    HitboxSize     = 20,    -- tamanho da hitbox grande

    -- Boss
    KillBossFirst  = true,  -- matar boss antes de farmar

    -- Anti-detecção
    RandomizeSpeed = true,  -- velocidade aleatória (150-180)
    RandomizeDelay = true,  -- delay aleatório (0.08-0.18)
    RandomizeHeight= true,  -- altura aleatória (12-18)
    PauseChance    = 0.01,  -- 1% de chance de pausar por frame
    PauseDuration  = 2,     -- duração da pausa (segundos)
}

--// ═══════════════════════════════════════════
--// ESTADO GLOBAL
--// ═══════════════════════════════════════════
local State = {
    AutoFarmON  = false,
    KillBossON  = true,
    Running     = false,
    StopFlag    = false,
    CurrentTask = "Idle",
    KilledCount = 0,
    QuestDone   = 0,
}

--// ═══════════════════════════════════════════
--// UTILITÁRIOS
--// ═══════════════════════════════════════════

local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local c = LocalPlayer.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

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
--// HITBOX GRANDE
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
--// VOAR (TweenService)
--// ═══════════════════════════════════════════
local function flyTo(targetPart)
    if not targetPart then return false end
    local hrp = getHRP()
    if not hrp then return false end

    -- Altura aleatória (anti-detecção)
    local height = Config.FlightHeight
    if Config.RandomizeHeight then
        height = randomBetween(12, 18)
    end

    -- Velocidade aleatória (anti-detecção)
    local speed = Config.FlightSpeed
    if Config.RandomizeSpeed then
        speed = randomBetween(150, 180)
    end

    -- Calcula destino (X studs acima do alvo)
    local destPos = targetPart.Position + Vector3.new(0, height, 0)

    -- Distância atual
    local dist = (hrp.Position - destPos).Magnitude
    local duration = dist / speed

    -- Cria o tween
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(hrp, tweenInfo, {
        CFrame = CFrame.new(destPos, targetPart.Position)
    })
    tween:Play()

    -- Espera terminar (com timeout de segurança)
    local startTime = tick()
    while tween.PlaybackState == Enum.PlaybackState.Playing do
        if State.StopFlag then tween:Cancel(); return false end
        if tick() - startTime > duration + 2 then tween:Cancel(); break end
        task.wait(0.05)
    end
    return true
end

--// ═══════════════════════════════════════════
--// ACHAR INIMIGO MAIS PRÓXIMO
--// ═══════════════════════════════════════════
local function findNearestEnemy(enemyNames)
    local hrp = getHRP()
    if not hrp then return nil end

    local closest = nil
    local closestDist = math.huge

    -- Procura em workspace.Enemies
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if not enemiesFolder then
        -- Fallback: procura em workspace todo
        enemiesFolder = workspace
    end

    for _, obj in ipairs(enemiesFolder:GetDescendants()) do
        -- Só models com Humanoid
        if obj:IsA("Model") then
            local h = obj:FindFirstChildOfClass("Humanoid")
            local objHrp = obj:FindFirstChild("HumanoidRootPart")
            if h and objHrp and h.Health > 0 then
                -- Verifica se o nome bate com a lista
                for _, enemyName in ipairs(enemyNames) do
                    if obj.Name:lower():find(enemyName:lower(), 1, true) then
                        local d = distance(hrp, objHrp)
                        if d < closestDist then
                            closest = objHrp
                            closestDist = d
                        end
                        break
                    end
                end
            end
        end
    end

    return closest
end

--// ═══════════════════════════════════════════
--// ACHAR BOSS
--// ═══════════════════════════════════════════
local function findBoss(bossName)
    local hrp = getHRP()
    if not hrp then return nil end

    local bosses = BossData.GetFor(getLevel())
    for _, boss in ipairs(bosses) do
        if boss.Boss == bossName then
            -- Procura no workspace
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name:lower():find(bossName:lower(), 1, true) then
                    local h = obj:FindFirstChildOfClass("Humanoid")
                    local objHrp = obj:FindFirstChild("HumanoidRootPart")
                    if h and objHrp and h.Health > 0 then
                        return objHrp
                    end
                end
            end
        end
    end
    return nil
end

--// ═══════════════════════════════════════════
--// ACHAR NPC DE QUEST
--// ═══════════════════════════════════════════
local function findQuestNPC(questName)
    local hrp = getHRP()
    if not hrp then return nil end

    local qgFolder = workspace:FindFirstChild("QuestGivers")
    if not qgFolder then qgFolder = workspace end

    for _, obj in ipairs(qgFolder:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find(questName:lower(), 1, true) then
            local objHrp = obj:FindFirstChild("HumanoidRootPart")
            if objHrp then return objHrp end
        end
    end
    return nil
end

--// ═══════════════════════════════════════════
--// ATIVAR PROXIMITY PROMPT
--// ═══════════════════════════════════════════
local function fireProximityPrompt(targetPart)
    if not targetPart then return false end
    local parent = targetPart.Parent
    if not parent then return false end

    for _, obj in ipairs(parent:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            pcall(function()
                fireproximityprompt(obj)
            end)
            return true
        end
    end
    return false
end

--// ═══════════════════════════════════════════
--// ATACAR
--// ═══════════════════════════════════════════
local function attackLoop(enemyHrp)
    if not enemyHrp then return end
    local char = LocalPlayer.Character
    if not char then return end

    local startTime = tick()
    while not State.StopFlag do
        -- Se inimigo sumiu/morreu, sai
        local parent = enemyHrp.Parent
        if not parent then break end
        local h = parent:FindFirstChildOfClass("Humanoid")
        if not h or h.Health <= 0 then break end

        -- Pega a ferramenta equipada
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function() tool:Activate() end)
        end

        -- Dispara skill (se tiver)
        pcall(function()
            -- Tenta disparar evento de skill
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if remotes then
                local combat = remotes:FindFirstChild("Combat")
                if combat then
                    local attack = combat:FindFirstChild("Attack")
                    if attack then
                        attack:FireServer()
                    end
                end
            end
        end)

        -- Delay aleatório (anti-detecção)
        local delay = Config.ClickDelay
        if Config.RandomizeDelay then
            delay = randomBetween(0.08, 0.18)
        end
        task.wait(delay)

        -- Timeout de segurança (10s por inimigo)
        if tick() - startTime > 10 then break end
    end

    State.KilledCount = State.KilledCount + 1
end

--// ═══════════════════════════════════════════
--// LOOP PRINCIPAL DO AUTO FARM
--// ═══════════════════════════════════════════
local function autoFarmLoop()
    if State.Running then return end
    State.Running = true
    State.StopFlag = false

    -- Ativa hitbox grande
    enableBigHitbox()

    while not State.StopFlag do
        if not State.AutoFarmON then break end
        if not LocalPlayer.Character then break end

        -- Pausa aleatória (anti-detecção)
        if math.random() < Config.PauseChance then
            State.CurrentTask = "Pausa anti-detecção"
            task.wait(Config.PauseDuration)
        end

        -- 1. Lê o nível
        local level = getLevel()
        State.CurrentTask = "Lv. " .. level .. " — consultando LevelData"

        -- 2. Consulta LevelData
        local info = LevelData.GetFor(level)
        if not info then
            State.CurrentTask = "Sem dados para este nível"
            task.wait(2)
            continue
        end

        -- 3. Tenta matar boss primeiro
        if State.KillBossON and Config.KillBossFirst then
            local bosses = BossData.GetFor(level, info.Island)
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

        -- 4. Farm normal
        local enemyList = LevelData.GetEnemyList(level)
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

        -- 5. Verifica se quest completa
        State.CurrentTask = "Verificando quest"
        task.wait(0.2)
    end

    -- Desativa hitbox ao parar
    disableBigHitbox()
    State.Running = false
    State.CurrentTask = "Parado"
    State.StopFlag = false
end

--// ═══════════════════════════════════════════
--// API PÚBLICA (chamada pela GUI)
--// ═══════════════════════════════════════════
local API = {}

function API.Start()
    if State.Running then return end
    State.AutoFarmON = true
    task.spawn(autoFarmLoop)
end

function API.Stop()
    State.AutoFarmON = false
    State.StopFlag = true
end

function API.SetKillBoss(v)
    State.KillBossON = v
end

function API.SetSpeed(v)
    Config.FlightSpeed = v
end

function API.SetHeight(v)
    Config.FlightHeight = v
end

function API.SetDelay(v)
    Config.ClickDelay = v
end

function API.GetState()
    return State
end

function API.GetLevel()
    return getLevel()
end

--// ═══════════════════════════════════════════
--// EXEMPLO: Iniciar automaticamente (opcional)
--// ═══════════════════════════════════════════
-- Descomenta se quiser que o farm comece sozinho:
-- API.Start()

-- Notificação
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "redz Hub v2",
        Text = "main.lua carregado! (auto farm pronto)",
        Duration = 4,
    })
end)

-- Retorna API para quem carregar
return API
