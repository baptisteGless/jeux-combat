-- player/movement.lua
local Moveset = require("moveset")

local Movement = {}
Movement.__index = Movement

function Movement.new(player)
    local self = setmetatable({}, Movement)
    self.player = player
    return self
end

function Movement:update(dt)
    local p = self.player

    -- Gérer accroupissement
    if love.keyboard.isDown("down") and p.isOnGround and not p.isRolling then
        p.isCrouching = true
    else
        p.isCrouching = false
    end

    -- Gestion blocage (touche F)
    if love.keyboard.isDown("f") then
        if not p.animation.isJumping then
            p.isBlocking = true
        end
    else
        p.isBlocking = false
    end

    -- Roulade
    if p.isRolling then
        -- Calcul du futur déplacement
        local nextX = p.x + p.rollDirection * p.rollSpeed * dt

        -- Empêche le joueur de rouler hors de l’écran
        if nextX < 0 then
            nextX = 0
        elseif nextX + p.width > love.graphics.getWidth() then
            nextX = love.graphics.getWidth() - p.width
        end

        p.x = nextX

        -- Pendant la roulade, pas de mouvement normal ni saut
        return
    end

    -- Si blocage -> pas de mouvement ni saut
    if p.isBlocking then
        return
    end

    -- Si accroupi -> pas de déplacement ni saut
    if p.isCrouching then
        return
    end

    -- Déplacements gauche/droite
    Moveset.move(p, dt)

    -- Gravité
    Moveset.applyGravity(p, dt)
end

function Movement:keypressed(key)
    local p = self.player
    local t = love.timer.getTime()

    if key == "space" then
        -- Pas de saut pendant la roulade
        if not p.isRolling and not p.isCrouching and not p.isBlocking then
            Moveset.jump(p)
        end
    elseif key == "left" or key == "right" then
        -- Double-tap pour roulade uniquement si le joueur est au sol
        if p.isOnGround and not p.isRolling then
            -- Déterminer direction du roll selon touche
            local rollDir = (key == "left") and -1 or 1

            -- Empêche de rouler contre le mur
            if (rollDir == -1 and p:isAtLeftEdge()) or (rollDir == 1 and p:isAtRightEdge()) then
                return
            end

            if t - p.lastKeyPressed[key] < p.doubleTapTime then
                local rollDir = (key == "left") and -1 or 1
                p.isRolling = true
                p.rollDirection = rollDir  -- assigner la direction d'abord

                p.rollTimer = p.rollDuration

                -- déterminer si le roll est backward par rapport à l'adversaire
                -- par exemple "backward" si le joueur roule à contre-sens de son orientation
                local backward = false
                if rollDir == -1 and p.side == "D" then backward = true end
                if rollDir == 1  and p.side == "G" then backward = true end

                p.animation:startRoll(p.rollDuration, backward)
            end
            p.lastKeyPressed[key] = t
        end
    end
end

return Movement
