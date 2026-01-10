local Player = require("player")  -- ça charge player/init.lua automatiquement
local Enemy = require("enemy")    -- ça charge enemy/init.lua automatiquement
local HealthBar = require("healthbar") -- les bar de vie des 2 personnages

debugLog = ""
local MAX_DEBUG_LINES = 10

-- ===== SAND FX =====
local SandFX = require("sandFX")

local sandFrames = {
    G = {
        love.graphics.newImage("images/effet/sand/sand-spred-1-G.png"),
        love.graphics.newImage("images/effet/sand/sand-spred-2-G.png"),
        love.graphics.newImage("images/effet/sand/sand-spred-3-G.png"),
        love.graphics.newImage("images/effet/sand/sand-spred-4-G.png"),
        love.graphics.newImage("images/effet/sand/sand-spred-5-G.png"),
        love.graphics.newImage("images/effet/sand/sand-spred-6-G.png"),
    },
    D = {
        love.graphics.newImage("images/effet/sand/sand-spred-1-D.png"),
        love.graphics.newImage("images/effet/sand/sand-spred-2-D.png"),
        love.graphics.newImage("images/effet/sand/sand-spred-3-D.png"),
        love.graphics.newImage("images/effet/sand/sand-spred-4-D.png"),
        love.graphics.newImage("images/effet/sand/sand-spred-5-D.png"),
        love.graphics.newImage("images/effet/sand/sand-spred-6-D.png"),
    }
}

-- ===== HIT FX =====
local HitFX = require("hitFX")

local hitFrames = {
    G = {
        -- love.graphics.newImage("images/effet/blood-effect/blood-effect-1-G.png"),
        -- love.graphics.newImage("images/effet/blood-effect/blood-effect-2-G.png"),
        -- love.graphics.newImage("images/effet/blood-effect/blood-effect-3-G.png"),
        -- love.graphics.newImage("images/effet/blood-effect/blood-effect-4-G.png"),
        -- love.graphics.newImage("images/effet/blood-effect/blood-effect-5-G.png"),
        -- love.graphics.newImage("images/effet/blood-effect/blood-effect-6-G.png"),
        love.graphics.newImage("images/effet/blood-effect/blood-boom-1-G.png"),
        love.graphics.newImage("images/effet/blood-effect/blood-boom-2-G.png"),
        love.graphics.newImage("images/effet/blood-effect/blood-boom-3-G.png"),
        love.graphics.newImage("images/effet/blood-effect/blood-boom-4-G.png"),
    },
    D = {
        -- love.graphics.newImage("images/effet/blood-effect/blood-effect-1-D.png"),
        -- love.graphics.newImage("images/effet/blood-effect/blood-effect-2-D.png"),
        -- love.graphics.newImage("images/effet/blood-effect/blood-effect-3-D.png"),
        -- love.graphics.newImage("images/effet/blood-effect/blood-effect-4-D.png"),
        -- love.graphics.newImage("images/effet/blood-effect/blood-effect-5-D.png"),
        -- love.graphics.newImage("images/effet/blood-effect/blood-effect-6-D.png"),
        love.graphics.newImage("images/effet/blood-effect/blood-boom-1-D.png"),
        love.graphics.newImage("images/effet/blood-effect/blood-boom-2-D.png"),
        love.graphics.newImage("images/effet/blood-effect/blood-boom-3-D.png"),
        love.graphics.newImage("images/effet/blood-effect/blood-boom-4-D.png"),
    }
}

local hitFramesfall = {
    G = {
        love.graphics.newImage("images/effet/blood-effect/blood-effect-4-G.png"),
        love.graphics.newImage("images/effet/blood-effect/blood-effect-5-G.png"),
        love.graphics.newImage("images/effet/blood-effect/blood-effect-6-G.png"),
    },
    D = {
        love.graphics.newImage("images/effet/blood-effect/blood-effect-4-D.png"),
        love.graphics.newImage("images/effet/blood-effect/blood-effect-5-D.png"),
        love.graphics.newImage("images/effet/blood-effect/blood-effect-6-D.png"),
    }
}

function checkCollision(a, b)
    return a.x < b.x + b.width and
           a.x + a.width > b.x and
           a.y < b.y + b.height and
           a.y + a.height > b.y
end

function addDebugLog(line)
    -- Découpe en lignes
    local lines = {}
    for l in debugLog:gmatch("[^\n]+") do
        table.insert(lines, l)
    end

    -- Ajoute la nouvelle ligne
    table.insert(lines, line)

    -- Supprime les premières si on dépasse le max
    while #lines > MAX_DEBUG_LINES do
        table.remove(lines, 1)
    end

    -- Reconstruit le debugLog final
    debugLog = table.concat(lines, "\n")
end

function love.load()
    -- Charger background
    background = love.graphics.newImage("images/background.png")
    love.window.setMode(0, 0, {fullscreen = true})
    screenWidth, screenHeight = love.graphics.getDimensions()

    -- Créer le joueur
    player = Player.new(200, screenHeight - 150)

    -- Créer l’ennemi (autre Player pour l’instant)
    enemy = Enemy.new(screenWidth - 400, screenHeight - 150, player)
    player.target = enemy

    enemy.fx.hitFrames = hitFrames
    enemy.fx.hitFramesfall = hitFramesfall
    enemy.fx.HitFX = HitFX
    player.fx.hitFrames = hitFrames
    player.fx.hitFramesfall = hitFramesfall
    player.fx.HitFX = HitFX

    player.fx.sandFrames = sandFrames
    player.fx.SandFX = SandFX
    enemy.fx.sandFrames = sandFrames
    enemy.fx.SandFX = SandFX
    
    -- Chargement bar de vie
    local barWidth = 300
    local barHeight = 20
    local padding = 30
    local y = screenHeight - 50

    playerHealthBar = HealthBar:new(
        screenWidth / 2 - barWidth - padding,
        y,
        barWidth,
        barHeight,
        player
    )

    enemyHealthBar = HealthBar:new(
        screenWidth / 2 + padding,
        y,
        barWidth,
        barHeight,
        enemy
    )
end

function love.update(dt)
    -- Mise à jour du joueur et de l’ennemi
    player:update(dt, enemy)
    enemy:update(dt, player)

    -- Gestion orientation (tu peux l’intégrer dans update si tu veux)
    player:updateOrientation(enemy)
    enemy:updateOrientation(player)
    
    local atkennemy = enemy:getAttackHitbox()
    local atk = player:getAttackHitbox()
    if atkennemy and checkCollision(atkennemy, player) then
        player.directionatk = atkennemy.type
        player.state = atkennemy.strick 
        player.hitType = atkennemy.hitType
        player.hitTimer = 0
        player.fall = atkennemy.fall
    end
    if atk then
        enemy.hitType = atk.hitType
        enemy.directionatk = atk.type
    end
    if atk and checkCollision(atk, enemy) then
        enemy.state = atk.strick 
        enemy.hitTimer = 0
        enemy.fall = atk.fall
        enemy.hitJustReceived = true
    end
end

function love.draw()
    -- Dessiner le background redimensionné
    love.graphics.draw(
        background,
        0, 0, 0,
        screenWidth / background:getWidth(),
        screenHeight / background:getHeight()
    )

    -- Dessiner le joueur et l’ennemi
    player:draw()
    enemy:draw()
    -- HUD
    playerHealthBar:draw()
    enemyHealthBar:draw()

    love.graphics.setColor(1,1,1,1)
    love.graphics.print(debugLog, 10, 10)
end

function love.keypressed(key)
    if key == "q" then
        love.event.quit()
    end

    -- Passer l’événement au joueur
    player:keypressed(key)
    -- enemy:keypressed(key) -- si tu veux que l’ennemi réagisse aussi aux touches
end