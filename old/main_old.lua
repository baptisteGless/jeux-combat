local Player = require("player")
local Enemy = require("enemy")

function love.load()
    -- Charger background
    background = love.graphics.newImage("images/background.png")
    love.window.setMode(0, 0, {fullscreen=true})
    screenWidth, screenHeight = love.graphics.getDimensions()

    -- Créer le joueur
    player = Player.new(200, screenHeight - 150)

    -- Créer l’ennemi
    enemy = Player.new(screenWidth - 400, screenHeight - 150)
end

function love.update(dt)
    player:update(dt)
    -- enemy:update(dt)

    -- Orientation
    player:updateOrientation(enemy)
    enemy:updateOrientation(player)

    -- Gérer collisions entre eux
    player:handleCollision(enemy, dt)
    enemy:handleCollision(player, dt)
end

function love.draw()
    -- Background redimensionné
    love.graphics.draw(background, 0, 0, 0,
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

    player:keypressed(key)
end