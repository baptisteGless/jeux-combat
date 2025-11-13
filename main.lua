local Player = require("player")  -- ça charge player/init.lua automatiquement
local Enemy = require("enemy")    -- si tu veux garder une classe Enemy séparée

function love.load()
    -- Charger background
    background = love.graphics.newImage("images/background.png")
    love.window.setMode(0, 0, {fullscreen = true})
    screenWidth, screenHeight = love.graphics.getDimensions()

    -- Créer le joueur
    player = Player.new(200, screenHeight - 150)

    -- Créer l’ennemi (autre Player pour l’instant)
    enemy = Player.new(screenWidth - 400, screenHeight - 150)
end

function love.update(dt)
    -- Mise à jour du joueur et de l’ennemi
    player:update(dt, enemy)
    -- enemy:update(dt, player)

    -- Gestion orientation (tu peux l’intégrer dans update si tu veux)
    player:updateOrientation(enemy)
    enemy:updateOrientation(player)
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
end

function love.keypressed(key)
    if key == "q" then
        love.event.quit()
    end

    -- Passer l’événement au joueur
    player:keypressed(key)
    enemy:keypressed(key) -- si tu veux que l’ennemi réagisse aussi aux touches
end