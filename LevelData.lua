--[[
    LevelData.lua
    Tabela de níveis → Alvo → Ilha → Missão do Blox Fruits
    Sea 1, Sea 2 e Sea 3
--]]

local LevelData = {
    -- ═══ SEA 1 ═══
    {MinLevel=1,    MaxLevel=9,    Enemy="Bandit",              Island="PirateStarter",  Quest="BanditQuest1"},
    {MinLevel=10,   MaxLevel=29,   Enemy="Monkey/Gorilla",      Island="Jungle",         Quest="JungleQuest"},
    {MinLevel=30,   MaxLevel=59,   Enemy="Pirate/Brute",        Island="PirateVillage",  Quest="BuggyQuest1"},
    {MinLevel=60,   MaxLevel=89,   Enemy="Desert Bandit/Desert Officer", Island="Desert", Quest="DesertQuest"},
    {MinLevel=90,   MaxLevel=119,  Enemy="Snow Bandit/Snowman", Island="FrozenVillage",  Quest="SnowQuest"},
    {MinLevel=120,  MaxLevel=149,  Enemy="Chief Petty Officer", Island="MarineFortress", Quest="MarineQuest2"},
    {MinLevel=150,  MaxLevel=189,  Enemy="Sky Bandit/Dark Master", Island="Skylands",    Quest="SkyQuest"},
    {MinLevel=190,  MaxLevel=249,  Enemy="Prisoner/Dangerous Prisoner", Island="Prison",  Quest="PrisonerQuest"},
    {MinLevel=250,  MaxLevel=299,  Enemy="Toga Warrior/Gladiator", Island="Colosseum",   Quest="ColosseumQuest"},
    {MinLevel=300,  MaxLevel=374,  Enemy="Military Soldier/Military Spy", Island="MagmaVillage", Quest="MagmaQuest"},
    {MinLevel=375,  MaxLevel=449,  Enemy="Fishman Warrior/Fishman Commando", Island="UnderwaterCity", Quest="FishmanQuest"},
    {MinLevel=450,  MaxLevel=524,  Enemy="God's Guard/Shanda",  Island="UpperSkylands",  Quest="SkyExp1Quest"},
    {MinLevel=525,  MaxLevel=624,  Enemy="Royal Squad/Royal Soldier", Island="UpperSkylands", Quest="SkyExp2Quest"},
    {MinLevel=625,  MaxLevel=700,  Enemy="Galley Pirate/Galley Captain", Island="FountainCity", Quest="FountainQuest"},

    -- ═══ SEA 2 ═══
    {MinLevel=700,  MaxLevel=774,  Enemy="Raider/Mercenary",    Island="KingdomOfRose",  Quest="Area1Quest"},
    {MinLevel=775,  MaxLevel=874,  Enemy="Swan Pirate/Factory Staff", Island="KingdomOfRose", Quest="Area2Quest"},
    {MinLevel=875,  MaxLevel=949,  Enemy="Marine Lieutenant/Marine Captain", Island="GreenZone", Quest="MarineQuest3"},
    {MinLevel=950,  MaxLevel=999,  Enemy="Zombie/Vampire",      Island="Graveyard",      Quest="ZombieQuest"},
    {MinLevel=1000, MaxLevel=1099, Enemy="Snow Trooper/Winter Warrior", Island="SnowMountain", Quest="SnowMountainQuest"},
    {MinLevel=1100, MaxLevel=1174, Enemy="Lab Subordinate/Horned Warrior", Island="HotAndCold", Quest="IceSideQuest"},
    {MinLevel=1175, MaxLevel=1249, Enemy="Magma Ninja/Lava Pirate", Island="HotAndCold", Quest="FireSideQuest"},
    {MinLevel=1250, MaxLevel=1299, Enemy="Ship Deckhand/Ship Engineer", Island="CursedShip", Quest="ShipQuest1"},
    {MinLevel=1300, MaxLevel=1349, Enemy="Ship Steward/Ship Officer", Island="CursedShip", Quest="ShipQuest2"},
    {MinLevel=1350, MaxLevel=1424, Enemy="Arctic Warrior/Snow Lurker", Island="IceCastle", Quest="FrostQuest"},
    {MinLevel=1425, MaxLevel=1500, Enemy="Sea Soldier/Water Fighter", Island="ForgottenIsland", Quest="ForgottenQuest"},

    -- ═══ SEA 3 ═══
    {MinLevel=1500, MaxLevel=1574, Enemy="Pirate Millionaire/Pistol Billionaire", Island="PortTown", Quest="PiratePortQuest"},
    {MinLevel=1575, MaxLevel=1624, Enemy="Dragon Crew Warrior/Dragon Crew Archer", Island="HydraIsland", Quest="AmazonQuest"},
    {MinLevel=1625, MaxLevel=1699, Enemy="Female Islander/Giant Islander", Island="HydraIsland", Quest="AmazonQuest2"},
    {MinLevel=1700, MaxLevel=1774, Enemy="Marine Commodore/Marine Rear Admiral", Island="GreatTree", Quest="MarineTreeIsland"},
    {MinLevel=1775, MaxLevel=1824, Enemy="Fishman Raider/Fishman Captain", Island="FloatingTurtle", Quest="DeepForestIsland3"},
    {MinLevel=1825, MaxLevel=1899, Enemy="Forest Pirate/Mythological Pirate", Island="FloatingTurtle", Quest="DeepForestIsland"},
    {MinLevel=1900, MaxLevel=1974, Enemy="Jungle Pirate/Musketeer Pirate", Island="FloatingTurtle", Quest="DeepForestIsland2"},
    {MinLevel=1975, MaxLevel=2024, Enemy="Reborn Skeleton/Living Zombie", Island="HauntedCastle", Quest="HauntedQuest1"},
    {MinLevel=2025, MaxLevel=2074, Enemy="Demonic Soul/Possessed Mummy", Island="HauntedCastle", Quest="HauntedQuest2"},
    {MinLevel=2075, MaxLevel=2124, Enemy="Peanut Scout/Peanut President", Island="SeaOfTreats", Quest="NutsIslandQuest"},
    {MinLevel=2125, MaxLevel=2199, Enemy="Ice Cream Chef/Ice Cream Commander", Island="SeaOfTreats", Quest="IceCreamIslandQuest"},
    {MinLevel=2200, MaxLevel=2249, Enemy="Cookie Crafter/Cake Guard", Island="SeaOfTreats", Quest="CakeQuest1"},
    {MinLevel=2250, MaxLevel=2299, Enemy="Baking Staff/Head Baker", Island="SeaOfTreats", Quest="CakeQuest2"},
    {MinLevel=2300, MaxLevel=2349, Enemy="Cocoa Warrior/Chocolate Bar Battler", Island="SeaOfTreats", Quest="ChocQuest1"},
    {MinLevel=2350, MaxLevel=2399, Enemy="Sweet Thief/Candy Rebel", Island="SeaOfTreats", Quest="ChocQuest2"},
    {MinLevel=2400, MaxLevel=2449, Enemy="Candy Pirate/Snow Demon", Island="SeaOfTreats", Quest="CandyQuest"},
    {MinLevel=2450, MaxLevel=2499, Enemy="Isle Outlaw/Island Boy", Island="TikiOutpost", Quest="TikiQuest1"},
    {MinLevel=2500, MaxLevel=2549, Enemy="Sun-kissed Warrior/Isle Champion", Island="TikiOutpost", Quest="TikiQuest2"},
    {MinLevel=2550, MaxLevel=2599, Enemy="Serpent Hunter/Skull Slayer", Island="TikiOutpost", Quest="TikiQuest3"},
    {MinLevel=2600, MaxLevel=2649, Enemy="Reef Bandit",         Island="SubmergedIsland", Quest="SubmergedQuest1"},
    {MinLevel=2650, MaxLevel=2699, Enemy="Coral Pirate",        Island="SubmergedIsland", Quest="SubmergedQuest1"},
    {MinLevel=2700, MaxLevel=2749, Enemy="Sea Chanter",         Island="SubmergedIsland", Quest="SubmergedQuest2"},
    {MinLevel=2750, MaxLevel=2800, Enemy="Ocean Prophet",       Island="SubmergedIsland", Quest="SubmergedQuest2"},
}

-- Retorna o registro completo do nível
function LevelData.GetFor(level)
    for _, entry in ipairs(LevelData) do
        if level >= entry.MinLevel and level <= entry.MaxLevel then
            return entry
        end
    end
    return nil
end

-- Retorna lista de inimigos da faixa
function LevelData.GetEnemyList(level)
    local entry = LevelData.GetFor(level)
    if not entry then return {} end
    local lista = {}
    for nome in entry.Enemy:gmatch("([^/]+)") do
        table.insert(lista, nome)
    end
    return lista
end

return LevelData
