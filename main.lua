local Player = require("player")  -- ça charge player/init.lua automatiquement
local Enemy = require("enemy")    -- ça charge enemy/init.lua automatiquement

debugLog = ""
local MAX_DEBUG_LINES = 10

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
end

function love.update(dt)
    -- Mise à jour du joueur et de l’ennemi
    player:update(dt, enemy)
    enemy:update(dt, player)

    -- Gestion orientation (tu peux l’intégrer dans update si tu veux)
    player:updateOrientation(enemy)
    enemy:updateOrientation(player)
    
    local atk = player:getAttackHitbox()
    if atk then
        enemy.directionatk = atk.type
    end
    if atk and checkCollision(atk, enemy) then
        enemy.state = atk.strick 
        enemy.hitTimer = 0
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