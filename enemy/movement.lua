-- enemy/movement.lua
local Moveset = require("moveset")

local Movement = {}
Movement.__index = Movement

function Movement.new(enemy)
    local self = setmetatable({}, Movement)
    self.enemy = enemy
    return self
end

-- Exécute un move (doit être appelé uniquement quand le enemy n'est pas busy)
function Movement:executeMove(move)
    local e = self.enemy

    return true
end

-- Cherche dans comboDefinitions :
--  * un FULL match (taille séquence <= buffer et queue égale) -> renvoie combo
--  * sinon si buffer est un PREFIX de l'une des sequences -> indique qu'on doit attendre
local function findComboMatch(e)
    local buffer = e.inputBuffer
    local bLen = #buffer

    local possiblePrefix = false
    -- d'abord check full matches (priorité aux combos les plus longs)
    -- (itérer sur toutes les définitions ; si tu veux priorité différente, change l'ordre)
    for _, combo in ipairs(e.comboDefinitions) do
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
    for _, combo in ipairs(e.comboDefinitions) do
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
    local e = self.enemy

    local canMove = not e.isCrouching

     -- Gestion de l’animation du hit bas
    if e.state == "hitBas" then
        e.hitTimer = e.hitTimer + dt
        if e.hitTimer >= e.hitDuration then
            e.state = "idle"
        end
    end

    if canMove then
        Moveset.move(e, dt)
        Moveset.applyGravity(e, dt)
    else
        -- applique quand même la gravité
        Moveset.applyGravity(e, dt)
    end
end

-- keypressed : g/h/y mapped to moves; on appui on ajoute dans le buffer et on tente une détection
function Movement:keypressed(key)
    local e = self.enemy
    local t = love.timer.getTime()
    addDebugLog("key=" .. tostring(key))

    if key == "up" then
        if e.isOnGround and not e.isRolling and not e.isCrouching and not e.isBlocking then
            Moveset.jump(e)
        end
        return
    end

    if key == "left" or key == "right" then
        if e.isOnGround and not e.isRolling then
            local rollDir = (key == "left") and -1 or 1
            if (rollDir == -1 and e:isAtLeftEdge()) or (rollDir == 1 and e:isAtRightEdge()) then
                return
            end
            if t - e.lastKeyPressed[key] < e.doubleTapTime then
                -- demander un roll pour après le coup en cours
                e.rollRequested = true
                e.rollDirection = rollDir     -- DIRECTION BONNE AU DOUBLE TAP
                -- annuler combos existants
                e.bufferedCombo = nil
                e.comboStep = 1
                e.moveQueue = {}
            end
            e.lastKeyPressed[key] = t
        end
        return
    end

    -- Interdire les attaques en l'air
    if not e.isOnGround or e.isRolling or e.isBlocking then
        return
    end

    ---------- LOGIQUE DYNAMIQUE DES COMBOS (moveQueue) ----------
    -- Si on est accroupi, attaques spéciales accroupies
    if e.isCrouching then
        if key == "y" then
            -- attaque bas-slash
            if not e:isBusy() then
                self:executeMove("basSlash")
            else
                -- le buffer marche toujours si combat en cours
                if #e.moveQueue < e.moveQueueMax then
                    table.insert(e.moveQueue, "basSlash")
                else
                    e.moveQueue[#e.moveQueue] = "basSlash"
                end
            end
            return -- très important : ne pas passer dans la logique combo
        end

        -- Si accroupi mais autre touche, on NE fait pas d’attaque
        return
    end

    if key == "j" then
        if e.isOnGround and not e.isRolling and not e.isCrouching and not e.isBlocking and not e:isBusy()then
            self:executeMove("shop")
        end
        return
    end

    -- reset buffer si timer expiré (déjà géré dans update, mais on double-check ici)
    if not e.inputBufferTimer or e.inputBufferTimer <= 0 then
        e.inputBuffer = {}
    end

    -- préparer le buffer temporaire (ce que serait le buffer après ce press)
    local tmpBuffer = {}
    for i=1,#e.inputBuffer do tmpBuffer[i] = e.inputBuffer[i] end
    table.insert(tmpBuffer, key)

    -- chercher le meilleur combo dont le prefix correspond à tmpBuffer
    local bestCombo = nil
    table.sort(e.comboDefinitions, function(a,b) return #a.sequence > #b.sequence end)
    for _, combo in ipairs(e.comboDefinitions) do
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
            e.inputBuffer = {}
            e.inputBufferTimer = 0
        else
            -- sinon on met à jour le buffer réel (on conserve tmpBuffer)
            e.inputBuffer = tmpBuffer
            e.inputBufferTimer = e.inputBufferMax
        end
    else
        -- aucun combo ne commence par ce prefix -> fallback : move simple par touche
        if key == "g" then intendedMove = "punch"
        elseif key == "h" then intendedMove = "lowKick"
        elseif key == "y" then intendedMove = "kick"
        else
            -- touches non mappées : on les ajoute au buffer quand même
            e.inputBuffer = tmpBuffer
            e.inputBufferTimer = e.inputBufferMax
        end
    end

    -- si on a déterminé un move à faire maintenant ou en queue
    if intendedMove then
        if not e:isBusy() then
            -- exécute maintenant
            self:executeMove(intendedMove)
        else
             -- met en queue pour exécution après la fin d'attaque
            if #e.moveQueue < e.moveQueueMax then
                table.insert(e.moveQueue, intendedMove)
            else
                -- si la queue est pleine, on écrase le dernier move
                e.moveQueue[#e.moveQueue] = intendedMove
            end
        end
    end
end

return Movement