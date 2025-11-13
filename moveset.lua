local Moveset = {}

-- Vérifie collision entre rectangles
function Moveset.checkCollision(a, b)
    return a.x < b.x + b.width and
           a.x + a.width > b.x and
           a.y < b.y + b.height and
           a.y + a.height > b.y
end

-- Déplacement gauche/droite
function Moveset.move(player, dt, other)
    if player.isCrouching then
        player.animation:stopWalk()
        return
    end

    local moveDir = 0
    if love.keyboard.isDown("left") then moveDir = -1
    elseif love.keyboard.isDown("right") then moveDir = 1 end

    -- Aucun déplacement → pose neutre
    if moveDir == 0 then
        player.animation:stopWalk()
        return
    end

    -- Mettre à jour orientation du personnage
    -- if moveDir == -1 then
    --     player.side = "G"
    -- elseif moveDir == 1 then
    --     player.side = "D"
    -- end

    -- Vérifie bord de fenêtre
    local atLeftEdge = (player.x <= 0)
    local atRightEdge = (player.x + player.width >= love.graphics.getWidth())
    if (moveDir == -1 and atLeftEdge) or (moveDir == 1 and atRightEdge) then
        player.animation:stopWalk()
        return
    end

    -- Vérifie collision frontale avec l'autre joueur
    local blockedByPlayer = false
    if other and Moveset.checkCollision(player, other) then
        if (moveDir == 1 and player.x < other.x) or (moveDir == -1 and player.x > other.x) then
            blockedByPlayer = true
        end
    end
    if blockedByPlayer then
        player.animation:stopWalk()
        return
    end

    -- Déplacement réel
    player.x = player.x + moveDir * player.speed * dt

    -- Animation marche
    if player.isOnGround then
        player.animation:startWalk(moveDir)
    end
end

-- Saut (appelé depuis player:keypressed)
function Moveset.jump(player)
    if player.isOnGround and not player.isRolling then
        player.yVelocity = -player.jumpStrength
        player.isOnGround = false
        player.animation:stopWalk() -- on arrête la marche en sautant
        player.animation:startJump()
    end
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
            -- Si on était en saut → lancer l’atterrissage
            if player.animation.isJumping then
                player.animation.jumpPhase = "land"
                player.animation.frameTimer = 0
                player.animation.currentFrame = 3 -- repart de saut3
            else
                -- déjà au sol = revenir pose
                player.animation:endJump()
            end
        end
    else
        -- en l'air → couper l'animation de marche
        if player.isWalking then
            player.animation:stopWalk()
        end
        player.isOnGround = false
    end
end

return Moveset
