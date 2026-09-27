--[[
    BossData.lua
    Tabela de bosses do Blox Fruits (Sea 1, 2, 3)

    Campos:
        Sea        = 1, 2 ou 3
        Island     = nome da ilha
        Boss       = nome exato do boss no workspace
        MinLevel   = nível mínimo pra matar
        Quest      = quest associada (nil se não tem)
        QuestGiver = NPC que dá a quest (nil se não tem)
        HasQuest   = true/false (se o boss dá progresso de quest)
--]]

local BossData = {
    -- ═══ SEA 1 ═══
    {Sea=1, Island="Jungle",          Boss="The Gorilla King", MinLevel=20,  Quest="JungleQuest",   QuestGiver="Adventurer",           HasQuest=true},
    {Sea=1, Island="PirateVillage",   Boss="Chef",             MinLevel=55,  Quest="BuggyQuest1",   QuestGiver="Pirate Adventurer",    HasQuest=true},
    {Sea=1, Island="MarineFortress",  Boss="Vice Admiral",     MinLevel=130, Quest="MarineQuest2",  QuestGiver="Marine",               HasQuest=true},
    {Sea=1, Island="Jungle",          Boss="The Saw",          MinLevel=100, Quest=nil,             QuestGiver=nil,                    HasQuest=false},
    {Sea=1, Island="FrozenVillage",   Boss="Yeti",             MinLevel=105, Quest="SnowQuest",     QuestGiver="Villager",             HasQuest=true},
    {Sea=1, Island="MiddleTown",      Boss="Mob Leader",       MinLevel=120, Quest=nil,             QuestGiver=nil,                    HasQuest=false},
    {Sea=1, Island="Desert",          Boss="Saber Expert",     MinLevel=200, Quest=nil,             QuestGiver=nil,                    HasQuest=false},
    {Sea=1, Island="Prison",          Boss="Warden",           MinLevel=220, Quest="PrisonerQuest", QuestGiver="Prisoner Quest Giver", HasQuest=true},
    {Sea=1, Island="Prison",          Boss="Chief Warden",     MinLevel=230, Quest="PrisonerQuest", QuestGiver="Prisoner Quest Giver", HasQuest=true},
    {Sea=1, Island="Prison",          Boss="Swan",             MinLevel=240, Quest="PrisonerQuest", QuestGiver="Prisoner Quest Giver", HasQuest=true},
    {Sea=1, Island="MagmaVillage",    Boss="Magma Admiral",    MinLevel=350, Quest="MagmaQuest",    QuestGiver="The Mayor",            HasQuest=true},
    {Sea=1, Island="UnderwaterCity",  Boss="Fishman Lord",     MinLevel=425, Quest="FishmanQuest",  QuestGiver="King Neptune",         HasQuest=true},
    {Sea=1, Island="UpperSkylands",   Boss="Wysper",           MinLevel=500, Quest="SkyExp1Quest",  QuestGiver="Sky Quest Giver",      HasQuest=true},
    {Sea=1, Island="UpperSkylands",   Boss="Thunder God",      MinLevel=575, Quest="SkyExp2Quest",  QuestGiver="Sky Quest Giver",      HasQuest=true},
    {Sea=1, Island="FountainCity",    Boss="Cyborg",           MinLevel=675, Quest="FountainQuest", QuestGiver="Citizen",              HasQuest=true},
    {Sea=1, Island="FrozenVillage",   Boss="Ice Admiral",      MinLevel=700, Quest=nil,             QuestGiver=nil,                    HasQuest=false},

    -- ═══ SEA 2 ═══
    {Sea=2, Island="KingdomOfRose",   Boss="Diamond",                MinLevel=750,  Quest="Area1Quest",       QuestGiver="Area 1 Quest Giver",       HasQuest=true},
    {Sea=2, Island="KingdomOfRose",   Boss="Jeremy",                 MinLevel=850,  Quest="Area2Quest",       QuestGiver="Area 2 Quest Giver",       HasQuest=true},
    {Sea=2, Island="GreenZone",       Boss="Orbitus",                MinLevel=925,  Quest="MarineQuest3",     QuestGiver="Marine Quest Giver",       HasQuest=true},
    {Sea=2, Island="KingdomOfRose",   Boss="Don Swan",               MinLevel=1000, Quest=nil,                QuestGiver=nil,                        HasQuest=false},
    {Sea=2, Island="HotAndCold",      Boss="Smoke Admiral",          MinLevel=1150, Quest="FireSideQuest",    QuestGiver="Hot and Cold Quest Giver", HasQuest=true},
    {Sea=2, Island="IceCastle",       Boss="Awakened Ice Admiral",   MinLevel=1400, Quest=nil,                QuestGiver=nil,                        HasQuest=false},
    {Sea=2, Island="ForgottenIsland", Boss="Tide Keeper",            MinLevel=1475, Quest="ForgottenQuest",   QuestGiver="Forgotten Quest Giver",    HasQuest=true},
    {Sea=2, Island="IndraIsland",     Boss="rip_indra",              MinLevel=1500, Quest=nil,                QuestGiver=nil,                        HasQuest=false},

    -- ═══ SEA 3 ═══
    {Sea=3, Island="PortTown",        Boss="Stone",                MinLevel=1550, Quest="PiratePortQuest",   QuestGiver="Pirate Port Quest Giver", HasQuest=true},
    {Sea=3, Island="HydraIsland",     Boss="Hydra Leader",         MinLevel=1600, Quest=nil,                 QuestGiver=nil,                       HasQuest=false},
    {Sea=3, Island="GreatTree",       Boss="Kilo Admiral",         MinLevel=1750, Quest="MarineTreeIsland",  QuestGiver="Marine Tree Quest Giver", HasQuest=true},
    {Sea=3, Island="FloatingTurtle",  Boss="Captain Elephant",     MinLevel=1875, Quest="DeepForestIsland3", QuestGiver="Deep Forest Quest Giver", HasQuest=true},
    {Sea=3, Island="FloatingTurtle",  Boss="Beautiful Pirate",     MinLevel=1950, Quest="DeepForestIsland2", QuestGiver="Deep Forest Quest Giver", HasQuest=true},
    {Sea=3, Island="FloatingTurtle",  Boss="Longma",               MinLevel=2000, Quest=nil,                 QuestGiver=nil,                       HasQuest=false},
    {Sea=3, Island="HauntedCastle",   Boss="Cursed Skeleton Boss", MinLevel=2025, Quest=nil,                 QuestGiver=nil,                       HasQuest=false},
    {Sea=3, Island="SeaOfTreats",     Boss="Cake Queen",           MinLevel=2175, Quest="IceCreamIslandQuest", QuestGiver="Ice Cream Quest Giver", HasQuest=true},
    {Sea=3, Island="HydraIsland",     Boss="Heaven's Guardian",    MinLevel=1500, Quest=nil,                 QuestGiver=nil,                       HasQuest=false},
    {Sea=3, Island="HydraIsland",     Boss="Hell's Messenger",     MinLevel=1500, Quest=nil,                 QuestGiver=nil,                       HasQuest=false},
}

-- Retorna bosses disponíveis no nível + ilha
function BossData.GetFor(level, island)
    local resultado = {}
    for _, boss in ipairs(BossData) do
        local nivelOK = level >= boss.MinLevel
        local ilhaOK  = (island == nil) or (boss.Island == island)
        if nivelOK and ilhaOK then
            table.insert(resultado, boss)
        end
    end
    return resultado
end

-- Retorna registro pelo nome
function BossData.GetByName(nomeBoss)
    for _, boss in ipairs(BossData) do
        if boss.Boss == nomeBoss then return boss end
    end
    return nil
end

-- Retorna só os bosses com quest
function BossData.GetAllWithQuest()
    local resultado = {}
    for _, boss in ipairs(BossData) do
        if boss.HasQuest then table.insert(resultado, boss) end
    end
    return resultado
end

-- Verifica se pode matar
function BossData.CanKill(level, nomeBoss)
    local boss = BossData.GetByName(nomeBoss)
    if not boss then return false end
    return level >= boss.MinLevel
end

return BossData
