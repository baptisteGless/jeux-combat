-- enemy/movement.lua
local Moveset = require("moveset")

local Movement = {}
Movement.__index = Movement

function Movement.new(enemy,target)
    local self = setmetatable({}, Movement)
    self.enemy = enemy
    return self
end

function Movement:attackList(choice)
    local e = self.enemy

    if e:isBusy() then return end  

    e.moveQueue = e.moveQueue or {}
    if #e.moveQueue > 6 then
        e.moveQueue = {}
    end

    if choice == "1" then
        table.insert(e.moveQueue, "punch")

    elseif choice == "2" then
        table.insert(e.moveQueue, "punch")
        table.insert(e.moveQueue, "lowSlash")

    elseif choice == "3" then
        table.insert(e.moveQueue, "punch")
        table.insert(e.moveQueue, "lowSlash")
        table.insert(e.moveQueue, "punch")

    elseif choice == "4" then
        table.insert(e.moveQueue, "punch")
        table.insert(e.moveQueue, "lowSlash")
        table.insert(e.moveQueue, "punch")
        table.insert(e.moveQueue, "bigSlash")

    elseif choice == "5" then
        table.insert(e.moveQueue, "kick")

    elseif choice == "6" then
        table.insert(e.moveQueue, "lowKick")

    elseif choice == "7" then 
        table.insert(e.moveQueue, "lowKick")
        table.insert(e.moveQueue, "knee")

    elseif choice == "8" then 
        table.insert(e.moveQueue, "lowKick")
        table.insert(e.moveQueue, "knee")
        table.insert(e.moveQueue, "heavySlash")

    elseif choice == "9" then 
        table.insert(e.moveQueue, "punch")
        table.insert(e.moveQueue, "hit1")
    end
end

-- Exécute un move (doit être appelé uniquement quand le enemy n'est pas busy)
function Movement:executeMove(move)

    local e = self.enemy

    if e.isStunned then return false end

    if move == "punch" then
        -- e.isPunching = true
        e.punchTimer = e.punchDuration
        e.animation:startPunch()
        e.lastAttack = move

    elseif move == "lowSlash" then
        -- e.isLowSlashing = true
        e.lowSlashTimer = e.lowSlashDuration
        e.animation:startLowSlash()
        e.lastAttack = move

    elseif move == "bigSlash" then
        -- e.isBigSlashing = true
        e.bigSlashTimer = e.bigSlashDuration
        e.animation:startBigSlash()
        e.lastAttack = move

    elseif move == "lowKick" then
        -- e.isLowKicking = true
        e.lowKickTimer = e.lowKickDuration
        e.animation:startLowKick()
        e.lastAttack = move

    elseif move == "knee" then
        -- e.iskneeing = true
        e.kneeTimer = e.kneeDuration
        e.animation:startknee()
        e.lastAttack = move

    elseif move == "heavySlash" then
        -- e.isHeavySlashing = true
        e.heavySlashTimer = e.heavySlashDuration
        e.animation:startHeavySlash()
        e.lastAttack = move

    elseif move == "hit1" then
        -- e.ishit1ing = true
        e.hit1Timer = e.hit1Duration
        e.animation:starthit1()
        e.lastAttack = move

    elseif move == "kick" then
        -- e.iskicking = true
        e.kickTimer = e.kickDuration
        e.animation:startkick()
        e.lastAttack = move

    elseif move == "basSlash" then
        -- e.isBasSlashing = true
        e.basSlashTimer = e.basSlashDuration
        e.animation:startBasSlash()
        e.lastAttack = move

    elseif move == "shop" then
        -- e.isShoping = true
        e.shopTimer = e.shopDuration
        e.animation:startShop()
        e.lastAttack = move

    else
        -- move inconnu
        return false
    end

    return true
end

function Movement:update(dt)
    local e = self.enemy
    e.camShake = false
    -- addDebugLog("e.compteHit" .. tostring(e.compteHit))

    -- if e.isInShopSequence then
    --     return
    -- end
    if e.gameOver then
        return
    end
    if e.isKO then
        -- laisser tomber / glisser
        e.fall = true
        e.state = true
    end
    -- addDebugLog("e.isShopReactioning=" .. tostring(e.isShopReactioning))
    if e.isShopReactioning then
        e.isCrouching = false
        e.shopReactionTimer = e.shopReactionTimer - dt
        if e.shopReactionTimer <= 0 then
            e.animation:endSR()
            e.isShopReactioning = false
            e.isInShopSequence = false

            -- RESTAURATION POSITION
            if e._shopPrevX then
                e.x = e._shopPrevX
                e._shopPrevX = nil
            end

            -- ENCHAÎNER AVEC FALL
            e.fall = true
            e.state = true
            e.compteHit = e.limiteHit
        end

        return
    end

    if e.isGettingUp then
        e.guvTimer = e.guvTimer - dt

        if e.guvTimer <= 0 then
            e.isGettingUp = false
            e.animation:endguv()

            e.state = false
            e.directionatk = "idle"
            e.isStunned = false
            e.wantMove = 0
            e.rollRequested = false
        end

        return
    end

    if e.thrown then
        -- e.camShake = false
        e.thrownTimer = e.thrownTimer - dt

        -- déplacement
        local dx = e.throwDirection * e.throwVelocity * dt
        e.throwVelocity = e.throwVelocity * 0.92  -- friction sol

        local nextX = e.x + dx

        if nextX < 0 then
            nextX = 0
            e.throwVelocity = 0
        elseif nextX + e.width > love.graphics.getWidth() then
            nextX = love.graphics.getWidth() - e.width
            e.throwVelocity = 0
        end

        e.x = nextX

        -- === IMPACT SOL AU MILIEU DE LA CHUTE ===
        if not e.sandImpactDone and e.thrownTimer <= (e.thrownDuration / 2) + 0.2 then
            local baseX = e.x + e.width / 2
            local offsetX = (e.throwDirection == -1) and -40 or 40
            local x = baseX + offsetX
            local y = e.y + e.height
            local fx = e.fx

            -- Choix des frames selon la direction
            local frames
            if e.throwDirection == -1 then
                frames = fx.sandFrames.D   -- projection vers la gauche
            else
                frames = fx.sandFrames.G   -- projection vers la droite
            end

            table.insert(fx.sandList, fx.SandFX:new(frames, x, y))
            e.sandImpactDone = true
        end

        -- AUCUNE AUTRE ACTION
        if e.thrownTimer <= 0 then
            e.thrown = false
            -- e.isStunned = false
            e.throwVelocity = 0
            if e.isKO then
                e.gameOver = true
                return
            end
            e.isGettingUp = true
            e.guvTimer = e.guvDuration
            e.animation:startguv()
        end

        return
    end

    if e.thrown or e.isGettingUp then
        return
    end

    -- Si blocage -> pas de mouvement ni saut
    if e.isBlocking then
        e.compteHit = 0
        e.blockTimer = e.blockTimer + dt
        if e.blockTimer >= e.blockDuration then
            e.isCrouching = false
            e.isBlocking = false
            e.directionatk = "idle"
            e.blockTimer = 0
        end

        return -- tant qu'on bloque on ne bouge pas
    end

    if e.animation.isBBHing then
        e.bbhTimer = e.bbhTimer - dt
        if e.bbhTimer <= 0 then
            -- addDebugLog("------")
            e.isStunned = false
            e.directionatk = "idle"
            e.hitTimer = 0
            e.state = false
            e.animation:endbbh()
            -- if e.isKO then
            --     addDebugLog("isKO bas")
            --     e.fall = true
            --     e.state = true
            --     return
            -- end
        end
        return
    end

    if e.animation.isBHHing then
        e.bhhTimer = e.bhhTimer - dt
        if e.bhhTimer <= 0 then
            -- addDebugLog("++++++")
            e.isDeflect = false
            e.isStunned = false
            e.directionatk = "idle"
            e.hitTimer = 0
            e.state = false
            e.animation:endbhh()
            -- if e.isKO then
            --     addDebugLog("isKO haut")
            --     e.fall = true
            --     e.state = true
            --     return
            -- end
        end
        return
    end
    -- addDebugLog("e.state=" .. tostring(e.state))
    -- addDebugLog("e.isRolling=" .. tostring(e.isRolling))
    -- addDebugLog("e.animation.isBBHing=" .. tostring(e.animation.isBBHing))
    -- addDebugLog("e.animation.isBHHing=" .. tostring(e.animation.isBHHing))

    if e.isDeflect == true then
        e.isStunned = true
        e.moveQueue = {}
        e.bhhTimer = e.deflectDuration
        e.state = false  
        e.animation:startbhh()
    end

    if e.state and not e.isRolling and not e.animation.isBBHing and not e.animation.isBHHing then
        -- addDebugLog("e.fall =" .. tostring(e.fall))
        -- addDebugLog("e.thrown =" .. tostring(e.thrown))
        -- if e.compteHit >= e.limiteHit and not e.thrown then
        if e.fall and not e.thrown then
            if (e.hitType == 6 or e.hitType == 8) and not e.isCrouching and not e.isBlocking then
                e:spawnHitFX(e.hitType) 
                e.camShake = true
                -- e.camShake = true
                e.sandImpactDone = false
                e.fall = false
                e.thrown = true
                e.thrownTimer = e.thrownDuration

                -- direction opposée au joueur
                local p = e.target
                e.throwDirection = (e.x < p.x) and -1 or 1

                -- distance variable selon position écran
                local screenW = love.graphics.getWidth()
                local distToEdge

                if e.throwDirection == -1 then
                    distToEdge = e.x
                else
                    distToEdge = screenW - (e.x + e.width)
                end

                -- puissance proportionnelle à l’espace dispo
                local maxThrow = 620
                local minThrow = 220
                local factor = math.min(distToEdge / 200, 1)

                e.throwVelocity = minThrow + (maxThrow - minThrow) * factor

                -- hard lock
                e.isStunned = true
                e.state = false
                e.directionatk = "idle"
                e.moveQueue = {}
                e.rollRequested = false
                e.wantMove = 0

                return
            elseif e.hitType == "12" then
                -- e:spawnHitFX(8) 
                -- e.camShake = true
                e.sandImpactDone = false
                e.fall = false
                e.thrown = true
                e.thrownTimer = e.thrownDuration

                -- direction opposée au joueur
                local p = e.target
                e.throwDirection = (e.x < p.x) and -1 or 1

                -- distance variable selon position écran
                local screenW = love.graphics.getWidth()
                local distToEdge

                if e.throwDirection == -1 then
                    distToEdge = e.x
                else
                    distToEdge = screenW - (e.x + e.width)
                end

                -- puissance proportionnelle à l’espace dispo
                local maxThrow = 620
                local minThrow = 220
                local factor = math.min(distToEdge / 200, 1)

                e.throwVelocity = minThrow + (maxThrow - minThrow) * factor

                -- hard lock
                e.isStunned = true
                e.state = false
                e.directionatk = "idle"
                e.moveQueue = {}
                e.rollRequested = false
                e.wantMove = 0

                return
            elseif e.isKO then
                -- e:spawnHitFX(8) 
                -- e.camShake = true
                e.sandImpactDone = false
                e.fall = false
                e.thrown = true
                e.thrownTimer = e.thrownDuration

                -- direction opposée au joueur
                local p = e.target
                e.throwDirection = (e.x < p.x) and -1 or 1

                -- distance variable selon position écran
                local screenW = love.graphics.getWidth()
                local distToEdge

                if e.throwDirection == -1 then
                    distToEdge = e.x
                else
                    distToEdge = screenW - (e.x + e.width)
                end

                -- puissance proportionnelle à l’espace dispo
                local maxThrow = 620
                local minThrow = 220
                local factor = math.min(distToEdge / 200, 1)

                e.throwVelocity = minThrow + (maxThrow - minThrow) * factor

                -- hard lock
                e.isStunned = true
                e.state = false
                e.directionatk = "idle"
                e.moveQueue = {}
                e.rollRequested = false
                e.wantMove = 0

                return
            end
        end

        -- COUP BAS
        if e.directionatk == "hitBas" then
            -- bloqué SEULEMENT si accroupi + block
            if not (e.isCrouching and e.isBlocking) then
                -- addDebugLog("+++hitBas+++")
                e.isStunned = true
                e.moveQueue = {}
                -- e.compteHit = e.compteHit + 1
                e.bbhTimer = e.bbhDuration
                e.isBlocking = false
                e.isCrouching = false
                e.state = false  
                e:takeDamage(10, "bas")
                e.animation:startbbh()
                if e.hitType == 1 or e.hitType == 2 or e.hitType == 4 or e.hitType == 6 or e.hitType == 8 then
                    e:spawnHitFX(e.hitType) 
                end
            end
            return
        end

        -- COUP HAUT
        if e.directionatk == "hitHaut" then
            -- bloqué SEULEMENT si block debout
            if not e.isBlocking and not e.isCrouching then
                e.isStunned = true
                e.moveQueue = {}
                -- e.compteHit = e.compteHit + 1
                e.bhhTimer = e.bhhDuration
                e.state = false  
                e:takeDamage(15, "haut")
                e.animation:startbhh()
                if e.hitType == 1 or e.hitType == 2 or e.hitType == 4 or e.hitType == 6 or e.hitType == 8 then
                    e:spawnHitFX(e.hitType) 
                end
            end
            return
        end
    end

    -- si on est stun -> mise à jour timer stun
    -- if e.isStunned then
    --     -- e.hitTimer = e.hitTimer + dt
    --     e.moveQueue = {}
    --     e.rollRequested = false
    --     e.animation.isRolling = false
    --     e.isBlocking = false
    --     e.isWalking = false
    --     e.animation.isBasSlashing = false
    --     e.animation.isShoping = false
    --     e.animation.isPunching = false
    --     e.animation.isLowSlashing = false
    --     e.animation.isLowKicking = false
    --     e.animation.iskneeing = false
    --     e.animation.iskicking = false
    --     e.animation.ishit1ing = false
    --     e.animation.isHeavySlashing = false
    --     e.animation.isBigSlashing = false
    --     e.isCrouching = false

    --     -- if e.hitTimer >= e.hitDuration then
    --     --     -- fin du stun
    --     --     e.isStunned = false
    --     --     e.directionatk = nil
    --     --     e.hitTimer = 0
    --     --     e.state = false
    --     -- end

    --     -- empêche tout le reste du code
    --     return
    -- end

    -- Si accroupi -> bloquer seulement le déplacement et le saut
    local canMove = not e.isCrouching and not e.isRolling and not e.animation.isPunching 
        and not e.animation.isLowSlashing and not e.animation.isLowKicking and not e.animation.iskneeing and not e.animation.iskicking
        and not e.animation.ishit1ing and not e.animation.isHeavySlashing and not e.animation.isBigSlashing 
        and not e.animation.isBasSlashing and not e.animation.isShoping
    -- addDebugLog("canMove=" .. tostring(canMove))
    if canMove then
        -- déplacement AI si demandé
        if e.wantMove and e.wantMove ~= 0 then
            -- addDebugLog("============")
            -- if e.compteHit > 0 then
            --     addDebugLog("+++++++++")
            -- end
            local speed = e.speed
            local nextX = e.x + (e.wantMove * speed * dt)

            -- collisions bord écran
            if nextX < 0 then nextX = 0
            elseif nextX + e.width > love.graphics.getWidth() then
                nextX = love.graphics.getWidth() - e.width
            end

            e.x = nextX
            -- addDebugLog("e:isBusy()=" .. tostring(e:isBusy()))
            if not e:isBusy() and not e.isRolling then
                e.animation:startWalk(e.wantMove)
            end

        else
            e.animation:stopWalk()
        end

        -- appliquer gravité
        Moveset.applyGravity(e, dt)
    else
        -- applique quand même la gravité
        Moveset.applyGravity(e, dt)
    end

    -- -------------------------------
    -- Si un roll est demandé et que l'enemy est libre
    -- -------------------------------
    -- addDebugLog("e.rollTimer=" .. tostring(e.rollTimer))
    if e.rollRequested and not e:isBusy() and not e.isRolling then
        -- addDebugLog("0000000000000")
        e.isRolling = true
        e.rollRequested = false
        e.wantMove = 0
        e.rollTimer = e.rollDuration
        local backward = (e.rollDirection == -1 and e.side == "D") or (e.rollDirection == 1 and e.side == "G")
        e.animation:startRoll(e.rollDuration, backward)
        return
    end

    -- Roulade (déplacement pendant roulade)
    if e.isRolling then
        -- addDebugLog("1111111111111")
        local nextX = e.x + e.rollDirection * e.rollSpeed * dt
        if nextX < 0 then nextX = 0 end
        if nextX + e.width > love.graphics.getWidth() then
            nextX = love.graphics.getWidth() - e.width
        end
        e.x = nextX
        -- mettre à jour le timer
        e.rollTimer = e.rollTimer - dt
        if e.rollTimer <= 0 then
            -- addDebugLog("++++++ e.rollTimer=" .. tostring(e.rollTimer))
            e.isRolling = false
        end
        return
    end

    -- timer entre moves de la queue
    e.moveQueueTimer = e.moveQueueTimer or 0
    e.moveQueueDelay = e.moveQueueDelay or 0.05  -- 50ms mini entre moves

    if e.moveQueueTimer > 0 then
        e.moveQueueTimer = e.moveQueueTimer - dt
    end

    -- 1) si on a des moves en queue et qu'on n'est pas occupé -> exécute le premier
    if e.moveQueue and #e.moveQueue > 0 and not e:isBusy() and e.moveQueueTimer <= 0 then
        local nextMove = table.remove(e.moveQueue, 1)
        self:executeMove(nextMove)
        e.moveQueueTimer = e.moveQueueDelay
        return
    end

    -- 2) mettre à jour timer du buffer d'input (expire le buffer)
    if e.inputBufferTimer and e.inputBufferTimer > 0 then
        e.inputBufferTimer = e.inputBufferTimer - dt
        if e.inputBufferTimer <= 0 then
            e.inputBuffer = {}
        end
    end

    if e.bufferedAttack and not e:isBusy() then
        local k = e.bufferedAttack
        e.bufferedAttack = nil

        -- ne pas continuer avant la fin de l'attaque
        return
    end


    -- Mettre à jour le timer du buffer de touches (inputBuffer)
    if e.inputBufferTimer and e.inputBufferTimer > 0 then
        e.inputBufferTimer = e.inputBufferTimer - dt
        if e.inputBufferTimer <= 0 then
            e.inputBuffer = {}
        end
    end

    -- Si on a un combo bufferisé (suite à une détection), et si on n'est pas occupé,
    -- on exécute l'étape suivante du combo (coup par coup).
    if e.bufferedCombo and not e:isBusy() then
        local move = e.bufferedCombo.moves[e.comboStep]
        if move then
            -- exécution sûre (on vérifie encore e:isBusy() dans executeMove)
            -- si le premier coup du combo est identique à l'attaque déjà faite,
            -- on saute cette étape
            if e.comboStep == 2 then
                if e.bufferedCombo.moves[1] == e.lastAttack then
                    e.comboStep = 3
                end
            end
            if self:executeMove(move) then
                e.comboStep = e.comboStep + 1
                -- si on a fini le bufferedCombo -> reset
                if e.comboStep > #e.bufferedCombo.moves then
                    e.bufferedCombo = nil
                    e.comboStep = 1
                end
            end
        else
            e.bufferedCombo = nil
            e.comboStep = 1
        end
    end

    -- === gestion des timers d'attaques (lock tant que l'attaque n'est pas terminée) ===
    if e.animation.isPunching then
        e.punchTimer = e.punchTimer - dt
        if e.punchTimer <= 0 then
            e.animation:endPunch()
        end
        return
    end

    if e.animation.isLowSlashing then
        e.lowSlashTimer = e.lowSlashTimer - dt
        if e.lowSlashTimer <= 0 then
            e.animation:endLowSlash()
        end
        return
    end

    if e.animation.isLowKicking then
        e.lowKickTimer = e.lowKickTimer - dt
        if e.lowKickTimer <= 0 then
            e.animation:endLowKick()
        end
        return
    end

    if e.animation.iskneeing then
        e.kneeTimer = e.kneeTimer - dt
        if e.kneeTimer <= 0 then
            e.animation:endknee()
        end
        return
    end

    if e.animation.iskicking then
        e.kickTimer = e.kickTimer - dt
        if e.kickTimer <= 0 then
            e.animation:endkick()
        end
        return
    end

    if e.animation.ishit1ing then
        e.hit1Timer = e.hit1Timer - dt
        local ratio = e.hit1Timer / e.hit1Duration  -- entre 1 et 0
        local advanceSpeed = 250 * ratio           -- finit en douceur (250 = à ajuster)

        local dir = (e.side == "D") and 1 or -1
        local nextX = e.x + dir * advanceSpeed * dt

        if nextX < 0 then nextX = 0 end
        if nextX + e.width > love.graphics.getWidth() then
            nextX = love.graphics.getWidth() - e.width
        end
        e.x = nextX

        if e.hit1Timer <= 0 then
            e.animation:endhit1()
        end
        return
    end

    if e.animation.isHeavySlashing then
        e.heavySlashTimer = e.heavySlashTimer - dt
        if e.heavySlashTimer <= 0 then
            e.animation:endHeavySlash()
        end
        return
    end

    if e.animation.isBigSlashing then
        e.bigSlashTimer = e.bigSlashTimer - dt
        local ratio = e.bigSlashTimer / e.bigSlashDuration
        local advanceSpeed = 250 * ratio   -- tu peux augmenter ici !

        local dir = (e.side == "D") and 1 or -1
        local nextX = e.x + dir * advanceSpeed * dt

        if nextX < 0 then nextX = 0 end
        if nextX + e.width > love.graphics.getWidth() then
            nextX = love.graphics.getWidth() - e.width
        end
        e.x = nextX

        if e.bigSlashTimer <= 0 then
            e.animation:endBigSlash()
        end
        return
    end

    if e.animation.isBasSlashing then
        e.basSlashTimer = e.basSlashTimer - dt
        if e.basSlashTimer <= 0 then
            e.animation:endBasSlash()
        end
        return
    end

    if e.animation.isShoping then
        e.shopTimer = e.shopTimer - dt
        if e.shopTimer <= 0 then
            e.animation:endShop()
        end
        return
    end

end

return Movement