local Moveset = {}

-- Vérifie si deux rectangles se touchent
function Moveset.checkCollision(a, b)
    return a.x < b.x + b.width and
           a.x + a.width > b.x and
           a.y < b.y + b.height and
           a.y + a.height > b.y
end

-- Déplacement gauche/droite
function Moveset.move(player, dt)
    if player.isCrouching then
        return -- pas de déplacement
    end

    -- gauche
    if love.keyboard.isDown("left") then
        if not player:isAtLeftEdge() then
            player.x = player.x - player.speed * dt
            if player.isOnGround then
                player:startWalk(-1)
            end
        else
            player:stopWalk()
        end

    -- droite
    elseif love.keyboard.isDown("right") then
        if not player:isAtRightEdge() then
            player.x = player.x + player.speed * dt
            if player.isOnGround then
                player:startWalk(1)
            end
        else
            player:stopWalk()
        end

    else
        player:stopWalk()
    end
end

-- Saut
function Moveset.jump(player, key)
end

-- Gravité et sol
function Moveset.applyGravity(player, dt)
    player.y = player.y + player.yVelocity * dt
    if not player.isOnGround then
        player.yVelocity = player.yVelocity + player.gravity * dt
    end

    local floorY = player.groundY - player.height
    if player.y >= floorY then
        -- atterrissage
        player.y = floorY
        player.yVelocity = 0
        if not player.isOnGround then
            player.isOnGround = true
        end
    else
        -- en l'air → couper l'animation de marche
        if player.isWalking then
            player:stopWalk()
        end
        player.isOnGround = false
    end
end

return Moveset