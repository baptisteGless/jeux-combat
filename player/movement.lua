-- player/movement.lua
local Moveset = require("moveset")

local Movement = {}
Movement.__index = Movement

function Movement.new(player)
    local self = setmetatable({}, Movement)
    self.player = player
    return self
end

function Movement:cancelShop()
    local p = self.player
    local e = p.target

    -- Si pas en shop → rien à faire
    if not (p.isShoping or p.isShopSuccessing) then
        return
    end

    -- STOP timers & états
    p.isShoping = false
    p.isShopSuccessing = false
    p.isShopFailing = false
    p.isInShopSequence = false

    -- STOP animations
    p.animation:endShop()
    p.animation:endShopSuccess()
    p.animation:endShopFail()

    -- RESTAURER POSITIONS
    if p._shopPrevX then
        p.x = p._shopPrevX
        p._shopPrevX = nil
    end

    if e and e._shopPrevX then
        e.x = e._shopPrevX
        e._shopPrevX = nil
    end

    -- RESET ENEMY
    if e then
        e.isShopReactioning = false
        e.isInShopSequence = false
        e.animation:endSR()
    end
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

    elseif move == "basSlash" then
        p.isBasSlashing = true
        p.basSlashTimer = p.basSlashDuration
        p.animation:startBasSlash()
        p.lastAttack = move

    elseif move == "shop" then
        p.isShoping = true
        p.isInShopSequence = true
        p.shopTimer = p.shopDuration
        p.animation:startShop()
        p.lastAttack = move

        -- IMPORTANT : vérifier la distance ici
        local e = p.target
        local dist = math.abs((p.x + p.width/2) - (e.x + e.width/2))

        if dist < 140 and not e.isInShopSequence and not e.thrown then
            -- SHOP RÉUSSIE
            p.shopWillSucceed = true
        else
            -- addDebugLog(" SHOP RATÉE ")
            -- SHOP RATÉE
            p.shopWillSucceed = false
        end

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

    if p.animation.isBBHing then
        -- addDebugLog("p.bbhTimer=" .. tostring(p.bbhTimer))
        p.bbhTimer = p.bbhTimer - dt
        if p.bbhTimer <= 0 then
            p.animation:endBBH()
        end
        return
    end

    if p.animation.isBHHing then
        -- addDebugLog("p.bhhTimer=" .. tostring(p.bhhTimer))
        p.bhhTimer = p.bhhTimer - dt
        if p.bhhTimer <= 0 then
            p.animation:endBHH()
        end
        return
    end

    -- addDebugLog("(p.isCrouching and p.isBlocking)=" .. tostring((p.isCrouching and p.isBlocking)))
    if p.state and not p.isRolling and not p.animation.isBBHingand and not p.animation.isBHHing then
        -- COUP BAS
        if p.directionatk == "hitBas" then
            -- bloqué SEULEMENT si accroupi + block
            if not (p.isCrouching and p.isBlocking) then
                self:cancelShop()
                p.bbhTimer = p.bbhDuration
                p.isBlocking = false
                p.isCrouching = false
                p.state = false  
                p.animation:startBBH()
            end
            return
        end

        -- COUP HAUT
        if p.directionatk == "hitHaut" then
            -- bloqué SEULEMENT si block debout
            if not (p.isBlocking and not p.isCrouching) then
                self:cancelShop()
                p.bhhTimer = p.bhhDuration
                p.state = false  
                p.animation:startBHH()
            end
            return
        end
    end

    if p.isShoping then
        p.shopTimer = p.shopTimer - dt
        if p.shopTimer <= 0 then
            p.isShoping = false
            p.animation:endShop()
            if p.shopWillSucceed then
                local e = p.target
                local overlap = 40 -- PLUS PETIT = PLUS COLLÉS
                -- Sauvegarde positions AVANT shop
                p._shopPrevX = p.x
                e._shopPrevX = e.x

                -- Coller enemy au player
                if p.side == "D" then
                    e.x = p.x + p.width - overlap
                    -- e.x = p.x
                    e.side = "G"
                else
                    e.x = p.x - e.width + overlap
                    -- e.x = p.x
                    e.side = "D"
                end
                -- DÉMARRER SHOP SUCCESS
                p.isShopSuccessing = true
                p.shopSuccessTimer = p.shopSuccessDuration
                p.animation:startShopSuccess()

                -- ENEMY ENTRE EN SHOP REACTION
                e.isInShopSequence = true
                e.isShopReactioning = true
                e.shopReactionTimer = e.shopReactionDuration
                e.animation:startSR()
            else
                -- SHOP FAIL
                p.isShopFailing = true
                p.shopFailTimer = p.shopFailDuration
                p.animation:startShopFail()
            end
        end

        return
    end

    if p.isShopSuccessing then
        p.shopSuccessTimer = p.shopSuccessTimer - dt

        if p.shopSuccessTimer <= 0 then
            p.isShopSuccessing = false
            p.animation:endShopSuccess()
            p.isInShopSequence = false
            -- RESTAURATION PLAYER
            if p._shopPrevX then
                p.x = p._shopPrevX
                p._shopPrevX = nil
            end
        end

        return
    end

    if p.isShopFailing then
        p.shopFailTimer = p.shopFailTimer - dt

        if p.shopFailTimer <= 0 then
            p.isShopFailing = false
            p.animation:endShopFail()
            p.isInShopSequence = false
        end

        return
    end

    -- -------------------------------
    -- Si un roll est demandé et que le player est libre
    -- -------------------------------
    if p.rollRequested and not p:isBusy() and not p.isRolling and not self.state then
        p.isRolling = true
        p.rollRequested = false
        p.rollTimer = p.rollDuration
        local backward = (p.rollDirection == -1 and p.side == "D") or (p.rollDirection == 1 and p.side == "G")
        p.animation:startRoll(p.rollDuration, backward)
        return
    end

    -- Roulade (déplacement pendant roulade)
    if p.isRolling then
        local nextX = p.x + p.rollDirection * p.rollSpeed * dt
        if nextX < 0 then nextX = 0 end
        if nextX + p.width > love.graphics.getWidth() then
            nextX = love.graphics.getWidth() - p.width
        end
        p.x = nextX
        -- appliquer gravité (IMPORTANT)
        Moveset.applyGravity(p, dt)
        -- mettre à jour le timer
        p.rollTimer = p.rollTimer - dt
        if p.rollTimer <= 0 then
            p.isRolling = false
        end
        return
    end

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

    if p.bufferedAttack and not p:isBusy() and not p.state then
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
        local ratio = p.hit1Timer / p.hit1Duration  -- entre 1 et 0
        local advanceSpeed = 250 * ratio           -- finit en douceur (250 = à ajuster)

        local dir = (p.side == "D") and 1 or -1
        local nextX = p.x + dir * advanceSpeed * dt

        if nextX < 0 then nextX = 0 end
        if nextX + p.width > love.graphics.getWidth() then
            nextX = love.graphics.getWidth() - p.width
        end
        p.x = nextX

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
        local ratio = p.bigSlashTimer / p.bigSlashDuration
        local advanceSpeed = 250 * ratio   -- tu peux augmenter ici !

        local dir = (p.side == "D") and 1 or -1
        local nextX = p.x + dir * advanceSpeed * dt

        if nextX < 0 then nextX = 0 end
        if nextX + p.width > love.graphics.getWidth() then
            nextX = love.graphics.getWidth() - p.width
        end
        p.x = nextX

        if p.bigSlashTimer <= 0 then
            p.isBigSlashing = false
            p.animation:endBigSlash()
        end
        return
    end

    if p.isBasSlashing then
        p.basSlashTimer = p.basSlashTimer - dt
        if p.basSlashTimer <= 0 then
            p.isBasSlashing = false
            p.animation:endBasSlash()
        end
        return
    end

    -- Gérer accroupissement
    -- addDebugLog("p.directionatk == hitBas=" .. tostring(p.directionatk == "hitBas"))
    -- addDebugLog("p.isCrouching=" .. tostring(p.isCrouching))
    if love.keyboard.isDown("down") and p.isOnGround and not p.isRolling and not p.isShopSuccessing and not p.isShopFailing then
        p.isCrouching = true
    else
        p.isCrouching = false
    end

    -- Gestion blocage (touche F)
    if love.keyboard.isDown("f") and not p.isShopSuccessing and not p.isShopFailing then
        if not p.animation.isJumping then
            p.isBlocking = true
        end
    else
        p.isBlocking = false
    end

    -- Si blocage -> pas de mouvement ni saut
    if p.isBlocking then return end

    -- Si accroupi -> bloquer seulement le déplacement et le saut
    local canMove = not p.isCrouching
    if canMove then
        Moveset.move(p, dt)
        Moveset.applyGravity(p, dt)
    else
        -- applique quand même la gravité
        Moveset.applyGravity(p, dt)
    end
end

-- keypressed : g/h/y mapped to moves; on appui on ajoute dans le buffer et on tente une détection
function Movement:keypressed(key)
    local p = self.player
    local t = love.timer.getTime()
    -- addDebugLog("key=" .. tostring(key))

    if p.isShopSuccessing or p.isShopFailing then
        return
    end

    if key == "up" then
        if p.isOnGround and not p.isRolling and not p.isCrouching and not p.isBlocking and not p.state and not p.isShopSuccessing and not p.isShopFailing and not p:isBusy() then
            Moveset.jump(p)
        end
        return
    end

    if key == "left" or key == "right" then
        if p.isOnGround and not p.isRolling and not p.state and not p.isShopSuccessing and not p.isShopFailing then
            local rollDir = (key == "left") and -1 or 1
            if (rollDir == -1 and p:isAtLeftEdge()) or (rollDir == 1 and p:isAtRightEdge()) then
                return
            end
            if t - p.lastKeyPressed[key] < p.doubleTapTime then
                -- demander un roll pour après le coup en cours
                p.rollRequested = true
                p.rollDirection = rollDir     -- DIRECTION BONNE AU DOUBLE TAP
                -- annuler combos existants
                p.bufferedCombo = nil
                p.comboStep = 1
                p.moveQueue = {}
            end
            p.lastKeyPressed[key] = t
        end
        return
    end

    -- Interdire les attaques en l'air
    if not p.isOnGround or p.isRolling or p.isBlocking or p.state then
        return
    end

    ---------- LOGIQUE DYNAMIQUE DES COMBOS (moveQueue) ----------
    -- Si on est accroupi, attaques spéciales accroupies
    if p.isCrouching then
        if key == "y" then
            -- attaque bas-slash
            if not p:isBusy() and not p.state then
                self:executeMove("basSlash")
            else
                -- le buffer marche toujours si combat en cours
                if #p.moveQueue < p.moveQueueMax then
                    table.insert(p.moveQueue, "basSlash")
                else
                    p.moveQueue[#p.moveQueue] = "basSlash"
                end
            end
            return -- très important : ne pas passer dans la logique combo
        end

        -- Si accroupi mais autre touche, on NE fait pas d’attaque
        return
    end

    if key == "j" then
        if p.isOnGround and not p.isRolling and not p.isCrouching and not p.isBlocking and not p:isBusy()then
            self:executeMove("shop")
        end
        return
    end

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

    -- addDebugLog("bestCombo=" .. tostring(bestCombo))

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