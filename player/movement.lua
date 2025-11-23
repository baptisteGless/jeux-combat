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

    if p.isPunching then
        p.punchTimer = p.punchTimer - dt
        if p.punchTimer <= 0 then
            p.isPunching = false
            p.animation:endPunch()
        end
        return
    end

    if p.isLowSlashing then
        p.lowSlashTimer = p.lowSlashTimer - dt
        if p.lowSlashTimer <= 0 then
            p.isLowSlashing = false
            p.animation:endLowSlash()
        end
        return
    end

    if p.isLowSlashing then
        p.lowSlashTimer = p.lowSlashTimer - dt
        if p.lowSlashTimer <= 0 then
            p.isLowSlashing = false
            p.animation:endLowSlash()
        end
        return
    end

    if p.isLowKicking then
        p.lowKickTimer = p.lowKickTimer - dt
        if p.lowKickTimer <= 0 then
            p.isLowKicking = false
            p.animation:endLowKick()
        end
        return
    end

    if p.iskneeing then
        p.kneeTimer = p.kneeTimer - dt
        if p.kneeTimer <= 0 then
            p.iskneeing = false
            p.animation:endknee()
        end
        return
    end

    if p.iskicking then
        p.kickTimer = p.kickTimer - dt
        if p.kickTimer <= 0 then
            p.iskicking = false
            p.animation:endkick()
        end
        return
    end

    if p.ishit1ing then
        p.hit1Timer = p.hit1Timer - dt
        if p.hit1Timer <= 0 then
            p.ishit1ing = false
            p.animation:endhit1()
        end
        return
    end

    if p.isHeavySlashing then
        p.heavySlashTimer = p.heavySlashTimer - dt
        if p.heavySlashTimer <= 0 then
            p.isHeavySlashing = false
            p.animation:endHeavySlash()
        end
        return
    end

    if p.isBigSlashing then
        p.bigSlashTimer = p.bigSlashTimer - dt
        if p.bigSlashTimer <= 0 then
            p.isBigSlashing = false
            p.animation:endBigSlash()
        end
        return
    end

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
        -- Saut uniquement si au sol et pas en roulade, pas accroupi, pas en blocage
        if p.isOnGround and not p.isRolling and not p.isCrouching and not p.isBlocking then
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
    elseif key == "y" then
        local p = self.player

        -- Conditions où le punch est interdit
        if p.isBigSlashing then return end
        if p.isHeavySlashing then return end
        if p.ishit1ing then return end
        if p.iskicking then return end
        if p.iskneeing then return end
        if p.isLowKicking then return end
        if p.isLowSlashing then return end
        if p.isPunching then return end
        if p.isRolling then return end
        if not p.isOnGround then return end
        if p.isCrouching then return end

        -- Lancer punch
        p.isPunching = true
        p.punchTimer = p.punchDuration
        p.animation:startPunch()
    elseif key == "g" then
        local p = self.player

        -- Conditions où le low-slash est interdit
        if p.isBigSlashing then return end
        if p.isHeavySlashing then return end
        if p.ishit1ing then return end
        if p.iskicking then return end
        if p.iskneeing then return end
        if p.isLowKicking then return end
        if p.isLowSlashing then return end
        if p.isPunching then return end
        if p.isRolling then return end
        if not p.isOnGround then return end
        if p.isCrouching then return end

        -- Lancer low-slash
        p.isLowSlashing = true
        p.lowSlashTimer = p.lowSlashDuration
        p.animation:startLowSlash()
    elseif key == "h" then
        local p = self.player

        -- Conditions où le low-kick est interdit
        if p.isBigSlashing then return end
        if p.isHeavySlashing then return end
        if p.ishit1ing then return end
        if p.iskicking then return end
        if p.iskneeing then return end
        if p.isLowKicking then return end
        if p.isLowSlashing then return end
        if p.isPunching then return end
        if p.isRolling then return end
        if not p.isOnGround then return end
        if p.isCrouching then return end

        -- Lancer low-kick
        p.isLowKicking = true
        p.lowKickTimer = p.lowKickDuration
        p.animation:startLowKick()
    elseif key == "j" then
        local p = self.player

        -- Conditions où le knee est interdit
        if p.isBigSlashing then return end
        if p.isHeavySlashing then return end
        if p.ishit1ing then return end
        if p.iskicking then return end
        if p.iskneeing then return end
        if p.isLowKicking then return end
        if p.isLowSlashing then return end
        if p.isPunching then return end
        if p.isRolling then return end
        if not p.isOnGround then return end
        if p.isCrouching then return end

        -- Lancer knee
        p.iskneeing = true
        p.kneeTimer = p.kneeDuration
        p.animation:startknee()
    elseif key == "k" then
        local p = self.player

        -- Conditions où le kick est interdit
        if p.isBigSlashing then return end
        if p.isHeavySlashing then return end
        if p.ishit1ing then return end
        if p.iskicking then return end
        if p.iskneeing then return end
        if p.isLowKicking then return end
        if p.isLowSlashing then return end
        if p.isPunching then return end
        if p.isRolling then return end
        if not p.isOnGround then return end
        if p.isCrouching then return end

        -- Lancer kick
        p.iskicking = true
        p.kickTimer = p.kickDuration
        p.animation:startkick()
    elseif key == "l" then
        local p = self.player

        -- Conditions où le hit1 est interdit
        if p.isBigSlashing then return end
        if p.isHeavySlashing then return end
        if p.ishit1ing then return end
        if p.iskicking then return end
        if p.iskneeing then return end
        if p.isLowKicking then return end
        if p.isLowSlashing then return end
        if p.isPunching then return end
        if p.isRolling then return end
        if not p.isOnGround then return end
        if p.isCrouching then return end

        -- Lancer hit1
        p.ishit1ing = true
        p.hit1Timer = p.hit1Duration
        p.animation:starthit1()
    elseif key == "m" then
        local p = self.player

        -- Conditions où le heavy-slash est interdit
        if p.isBigSlashing then return end
        if p.isHeavySlashing then return end
        if p.ishit1ing then return end
        if p.iskicking then return end
        if p.iskneeing then return end
        if p.isLowKicking then return end
        if p.isLowSlashing then return end
        if p.isPunching then return end
        if p.isRolling then return end
        if not p.isOnGround then return end
        if p.isCrouching then return end

        -- Lancer heavy-slash
        p.isHeavySlashing = true
        p.heavySlashTimer = p.heavySlashDuration
        p.animation:startHeavySlash()
    elseif key == "u" then
        local p = self.player

        -- Conditions où le big-slash est interdit
        if p.isBigSlashing then return end
        if p.isHeavySlashing then return end
        if p.ishit1ing then return end
        if p.iskicking then return end
        if p.iskneeing then return end
        if p.isLowKicking then return end
        if p.isLowSlashing then return end
        if p.isPunching then return end
        if p.isRolling then return end
        if not p.isOnGround then return end
        if p.isCrouching then return end

        -- Lancer big-slash
        p.isBigSlashing = true
        p.bigSlashTimer = p.bigSlashDuration
        p.animation:startBigSlash()
    end
end

return Movement
