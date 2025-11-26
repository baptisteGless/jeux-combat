-- player/movement.lua
local Moveset = require("moveset")

local Movement = {}
Movement.__index = Movement

function Movement.new(player)
    local self = setmetatable({}, Movement)
    self.player = player
    return self
end

-- Exécute un move (doit être appelé uniquement quand le player n'est pas busy)
function Movement:executeMove(move)
    local p = self.player

    if move == "punch" then
        p.isPunching = true
        p.punchTimer = p.punchDuration
        p.animation:startPunch()
        p.lastAttack = move

    elseif move == "lowSlash" then
        p.isLowSlashing = true
        p.lowSlashTimer = p.lowSlashDuration
        p.animation:startLowSlash()
        p.lastAttack = move

    elseif move == "bigSlash" then
        p.isBigSlashing = true
        p.bigSlashTimer = p.bigSlashDuration
        p.animation:startBigSlash()
        p.lastAttack = move

    elseif move == "lowKick" then
        p.isLowKicking = true
        p.lowKickTimer = p.lowKickDuration
        p.animation:startLowKick()
        p.lastAttack = move

    elseif move == "knee" then
        p.iskneeing = true
        p.kneeTimer = p.kneeDuration
        p.animation:startknee()
        p.lastAttack = move

    elseif move == "heavySlash" then
        p.isHeavySlashing = true
        p.heavySlashTimer = p.heavySlashDuration
        p.animation:startHeavySlash()
        p.lastAttack = move

    elseif move == "hit1" then
        p.ishit1ing = true
        p.hit1Timer = p.hit1Duration
        p.animation:starthit1()
        p.lastAttack = move

    elseif move == "kick" then
        p.iskicking = true
        p.kickTimer = p.kickDuration
        p.animation:startkick()
        p.lastAttack = move

    else
        -- move inconnu
        return false
    end

    return true
end

-- Cherche dans comboDefinitions :
--  * un FULL match (taille séquence <= buffer et queue égale) -> renvoie combo
--  * sinon si buffer est un PREFIX de l'une des sequences -> indique qu'on doit attendre
local function findComboMatch(p)
    local buffer = p.inputBuffer
    local bLen = #buffer

    local possiblePrefix = false
    -- d'abord check full matches (priorité aux combos les plus longs)
    -- (itérer sur toutes les définitions ; si tu veux priorité différente, change l'ordre)
    for _, combo in ipairs(p.comboDefinitions) do
        local seq = combo.sequence
        local sLen = #seq
        if bLen >= sLen then
            -- comparer la queue du buffer avec seq
            local ok = true
            for i = 1, sLen do
                if buffer[bLen - sLen + i] ~= seq[i] then
                    ok = false; break
                end
            end
            if ok then
                return "full", combo
            end
        end
    end

    -- ensuite vérifier si buffer correspond au prefix de n'importe quel combo
    for _, combo in ipairs(p.comboDefinitions) do
        local seq = combo.sequence
        local sLen = #seq
        if bLen < sLen then
            local ok = true
            for i = 1, bLen do
                if buffer[i] ~= seq[i] then
                    ok = false; break
                end
            end
            if ok then
                possiblePrefix = true
                break
            end
        end
    end

    if possiblePrefix then
        return "prefix", nil
    end

    return "none", nil
end

function Movement:update(dt)
    local p = self.player

    -- timer entre moves de la queue
    p.moveQueueTimer = p.moveQueueTimer or 0
    p.moveQueueDelay = p.moveQueueDelay or 0.05  -- 50ms mini entre moves

    if p.moveQueueTimer > 0 then
        p.moveQueueTimer = p.moveQueueTimer - dt
    end

    -- 1) si on a des moves en queue et qu'on n'est pas occupé -> exécute le premier
    if p.moveQueue and #p.moveQueue > 0 and not p:isBusy() and p.moveQueueTimer <= 0 then
        local nextMove = table.remove(p.moveQueue, 1)
        self:executeMove(nextMove)
        p.moveQueueTimer = p.moveQueueDelay
        return
    end

    -- 2) mettre à jour timer du buffer d'input (expire le buffer)
    if p.inputBufferTimer and p.inputBufferTimer > 0 then
        p.inputBufferTimer = p.inputBufferTimer - dt
        if p.inputBufferTimer <= 0 then
            p.inputBuffer = {}
        end
    end

    if p.bufferedAttack and not p:isBusy() then
        local k = p.bufferedAttack
        p.bufferedAttack = nil

        if k == "g" then self:executeMove("punch")
        elseif k == "h" then self:executeMove("lowKick")
        elseif k == "y" then self:executeMove("kick")
        end

        -- ne pas continuer avant la fin de l'attaque
        return
    end


    -- Mettre à jour le timer du buffer de touches (inputBuffer)
    if p.inputBufferTimer and p.inputBufferTimer > 0 then
        p.inputBufferTimer = p.inputBufferTimer - dt
        if p.inputBufferTimer <= 0 then
            p.inputBuffer = {}
        end
    end

    -- Si on a un combo bufferisé (suite à une détection), et si on n'est pas occupé,
    -- on exécute l'étape suivante du combo (coup par coup).
    if p.bufferedCombo and not p:isBusy() then
        local move = p.bufferedCombo.moves[p.comboStep]
        if move then
            -- exécution sûre (on vérifie encore p:isBusy() dans executeMove)
            -- si le premier coup du combo est identique à l'attaque déjà faite,
            -- on saute cette étape
            if p.comboStep == 2 then
                if p.bufferedCombo.moves[1] == p.lastAttack then
                    p.comboStep = 3
                end
            end
            if self:executeMove(move) then
                p.comboStep = p.comboStep + 1
                -- si on a fini le bufferedCombo -> reset
                if p.comboStep > #p.bufferedCombo.moves then
                    p.bufferedCombo = nil
                    p.comboStep = 1
                end
            end
        else
            p.bufferedCombo = nil
            p.comboStep = 1
        end
    end

    -- === gestion des timers d'attaques (lock tant que l'attaque n'est pas terminée) ===
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

    -- Roulade (déplacement pendant roulade)
    if p.isRolling then
        local nextX = p.x + p.rollDirection * p.rollSpeed * dt
        if nextX < 0 then
            nextX = 0
        elseif nextX + p.width > love.graphics.getWidth() then
            nextX = love.graphics.getWidth() - p.width
        end
        p.x = nextX
        return
    end

    -- Si blocage -> pas de mouvement ni saut
    if p.isBlocking then return end

    -- Si accroupi -> pas de déplacement ni saut
    if p.isCrouching then return end

    -- Déplacements gauche/droite
    Moveset.move(p, dt)

    -- Gravité
    Moveset.applyGravity(p, dt)
end

-- keypressed : g/h/y mapped to moves; on appui on ajoute dans le buffer et on tente une détection
function Movement:keypressed(key)
    local p = self.player
    local t = love.timer.getTime()
    addDebugLog("key=" .. tostring(key))

    if key == "space" then
        if p.isOnGround and not p.isRolling and not p.isCrouching and not p.isBlocking then
            Moveset.jump(p)
        end
        return
    end

    if key == "left" or key == "right" then
        if p.isOnGround and not p.isRolling then
            local rollDir = (key == "left") and -1 or 1
            if (rollDir == -1 and p:isAtLeftEdge()) or (rollDir == 1 and p:isAtRightEdge()) then
                return
            end
            if t - p.lastKeyPressed[key] < p.doubleTapTime then
                p.isRolling = true
                p.rollDirection = rollDir
                p.rollTimer = p.rollDuration
                local backward = (rollDir == -1 and p.side == "D") or (rollDir == 1 and p.side == "G")
                p.animation:startRoll(p.rollDuration, backward)
            end
            p.lastKeyPressed[key] = t
        end
        return
    end

     -- ---------- LOGIQUE DYNAMIQUE DES COMBOS (moveQueue) ----------
    -- reset buffer si timer expiré (déjà géré dans update, mais on double-check ici)
    if not p.inputBufferTimer or p.inputBufferTimer <= 0 then
        p.inputBuffer = {}
    end

    -- préparer le buffer temporaire (ce que serait le buffer après ce press)
    local tmpBuffer = {}
    for i=1,#p.inputBuffer do tmpBuffer[i] = p.inputBuffer[i] end
    table.insert(tmpBuffer, key)

    -- chercher le meilleur combo dont le prefix correspond à tmpBuffer
    local bestCombo = nil
    table.sort(p.comboDefinitions, function(a,b) return #a.sequence > #b.sequence end)
    for _, combo in ipairs(p.comboDefinitions) do
        local seq = combo.sequence
        if #tmpBuffer <= #seq then
            local ok = true
            for i = 1, #tmpBuffer do
                if tmpBuffer[i] ~= seq[i] then ok = false; break end
            end
            if ok then
                -- priorité : le combo qui contient ce prefix (pas besoin de choisir par longueur ici)
                bestCombo = combo
                break
            end
        end
    end

    local intendedMove = nil

    if bestCombo then
        -- la touche correspond à l'étape ##tmpBuffer dans bestCombo
        intendedMove = bestCombo.moves[#tmpBuffer]
        -- si on a complété la séquence complètement, on efface le buffer (evite re-détection)
        if #tmpBuffer == #bestCombo.sequence then
            p.inputBuffer = {}
            p.inputBufferTimer = 0
        else
            -- sinon on met à jour le buffer réel (on conserve tmpBuffer)
            p.inputBuffer = tmpBuffer
            p.inputBufferTimer = p.inputBufferMax
        end
    else
        -- aucun combo ne commence par ce prefix -> fallback : move simple par touche
        if key == "g" then intendedMove = "punch"
        elseif key == "h" then intendedMove = "lowKick"
        elseif key == "y" then intendedMove = "kick"
        else
            -- touches non mappées : on les ajoute au buffer quand même
            p.inputBuffer = tmpBuffer
            p.inputBufferTimer = p.inputBufferMax
        end
    end

    -- si on a déterminé un move à faire maintenant ou en queue
    if intendedMove then
        if not p:isBusy() then
            -- exécute maintenant
            self:executeMove(intendedMove)
        else
             -- met en queue pour exécution après la fin d'attaque
            if #p.moveQueue < p.moveQueueMax then
                table.insert(p.moveQueue, intendedMove)
            else
                -- si la queue est pleine, on écrase le dernier move
                p.moveQueue[#p.moveQueue] = intendedMove
            end
        end
    end
end

return Movement