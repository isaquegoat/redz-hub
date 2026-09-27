--[[
    redz Hub v2 — loader.lua
    Cole ESTE arquivo no executor.
    Ele baixa e executa o main.lua do GitHub.

    Uso:
        loadstring(game:HttpGet("https://raw.githubusercontent.com/isaquegoat/redz-hub/main/loader.lua"))()
--]]

local BASE_URL = "https://raw.githubusercontent.com/isaquegoat/redz-hub/main/"

-- Baixa e executa o main.lua
local ok, main = pcall(function()
    local src = game:HttpGet(BASE_URL .. "main.lua")
    local func = loadstring(src)
    return func()
end)

if not ok then
    warn("[redz Hub v2] Erro ao carregar: " .. tostring(main))
else
    print("[redz Hub v2] Carregado com sucesso!")
end
