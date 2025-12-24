-- enemy/ai.lua
local AI = {}
AI.__index = AI

function AI.new(enemy, target)
    local self = setmetatable({}, AI)
    self.enemy = enemy
    self.target = target

    self.pauseTimer = 0
    self.pauseChance = 0.05      -- 5% de chance de faire rien
    self.pauseMin = 0.05         -- mini 0.20s de pause
    self.pauseMax = 0.10         -- maxi 0.60s de pause

    self.thinkTimer = 0
    self.thinkDelay = 0.18

    -- COOL DOWN D'ATTAQUE
    self.attackCooldown = 0

    -- TABLE DES OPTIONS D'ATTAQUES IA
    self.attackOptions = {
        {
            id = "1",      -- punch rapide
            minRange = 30,
            maxRange = 120,
            chance = 0.60,
            priority = 5,
        },
        {
            id = "6",      -- lowKick court
            minRange = 0,
            maxRange = 80,
            chance = 0.45,
            priority = 10,
        },
        {
            id = "2",      -- haut → bas combo
            minRange = 40,
            maxRange = 110,
            chance = 0.30,
            priority = 4,
        },
        {
            id = "4",      -- combo strong
            minRange = 70,
            maxRange = 160,
            chance = 0.18,
            priority = 3,
        },
        {
            id = "9",      -- dash punch
            minRange = 100,
            maxRange = 200,
            chance = 0.15,
            priority = 2,
        }
    }

    return self
end

function AI:canPause(dist)
    -- trop loin -> jamais pause
    if dist > 200 then return false end

    -- trop proche -> éviter les pauses débiles
    if dist < 60 then return false end

    -- sinon OK
    return true
end

-- Distance horizontale
local function distance(a, b)
    return math.abs(a.x - b.x)
end

function AI:chooseAttack(dist)

    local candidates = {}

    for _,atk in ipairs(self.attackOptions) do
        if dist >= atk.minRange and dist <= atk.maxRange then
            table.insert(candidates, atk)
        end
    end

    if #candidates == 0 then return nil end

    -- tri par priorité décroissante
    table.sort(candidates, function(a,b)
        return a.priority > b.priority
    end)

    -- sélection par probabilité décroissante
    for _,atk in ipairs(candidates) do
        if math.random() < atk.chance then
            return atk.id
        end
    end

    -- fallback = meilleure attaque
    return candidates[1].id
end

function AI:update(dt)
    local e = self.enemy
    local p = self.target

    if e.isStunned or e.animation.isBBHing or e.animation.isBHHing or e.thrown then
        return
    end

    if not p then return end

    self.thinkTimer = self.thinkTimer - dt
    if self.thinkTimer > 0 then return end
    self.thinkTimer = self.thinkDelay
    -- intention par défaut
    -- addDebugLog("e.wantMove" .. tostring(e.wantMove))
    e.wantMove = e.wantMove or 0

    if e.isStunned or e.animation.isBBHing or e.animation.isBHHing or e.thrown or e:isBusy() then
        return
    end

    self.attackCooldown = self.attackCooldown - dt

    -- Distance horizontale
    local dist = math.abs(e.x - p.x)
    local dirToPlayer = (p.x > e.x) and 1 or -1

    local screenWidth = love.graphics.getWidth()

    -- murs IA
    local eAtLeftWall  = (e.x <= 5)
    local eAtRightWall = (e.x + e.width >= screenWidth - 5)

    -- murs joueur
    local pAtLeftWall  = (p.x <= 5)
    local pAtRightWall = (p.x + p.width >= screenWidth - 5)

    -- addDebugLog("eAtLeftWall=" .. tostring(eAtLeftWall))
    -- addDebugLog("eAtRightWall=" .. tostring(eAtRightWall))
    -- addDebugLog("dist=" .. tostring(dist))
    -- si en pause, on décompte et on ne fait rien
    if self.pauseTimer > 0 then
        self.pauseTimer = self.pauseTimer - dt
        if e.isBlocking then
            e.isBlocking = false
            e.wantBlock = nil
        end
        e.wantMove = 0
        return
    end

    -- local dist = distance(e, p)
    -- local dirToPlayer = (p.x > e.x) and 1 or -1

    if e.directionatk == "hitHaut" and dist < 110 and math.random() < 0.30 and not e.isStunned and not e.state then
        -- addDebugLog("BLOCK HAUT")
        e.isCrouching = false
        e.wantBlock = "haut"
        if e.isBlocking then
            e.isBlocking = false
            e.wantBlock = nil
        end
        e.blockType = e.wantBlock
        return
    elseif e.directionatk == "hitBas" and dist < 110 and math.random() < 0.30 and not e.isStunned and not e.state then  --and math.random() < 0.95
        -- addDebugLog("BLOCK BAS")
        e.isCrouching = true
        e.wantBlock = "bas"
        if e.isBlocking then
            e.isBlocking = false
            e.wantBlock = nil
        end
        e.blockType = e.wantBlock
        return
    end

    -- si trop proche -> ROLL à 70% de chance 
    local proba = math.random()
    if e.hitJustReceived and dist < 110 and proba < 0.7 and not e.isStunned and not e.state then
        addDebugLog("e.directionatk =" .. tostring(e.directionatk ))
        if proba < 0.5 then 
            -- direction naturelle = s'éloigner du joueur
            local rollDir = -dirToPlayer

            -----------------------------------------------------------
            --  IA contre un mur → elle doit rouler en avant :
            -----------------------------------------------------------
            if rollDir == -1 and eAtLeftWall  then rollDir = 1  end
            if rollDir ==  1 and eAtRightWall then rollDir = -1 end

            -----------------------------------------------------------
            --  IA veut rouler vers le joueur →
            -- vérifier si un mur est derrière le joueur :
            -----------------------------------------------------------
            if rollDir == dirToPlayer then    
                if dirToPlayer == 1 and pAtRightWall then
                    rollDir = -1
                elseif dirToPlayer == -1 and pAtLeftWall then
                    rollDir = 1
                end
            end

            -----------------------------------------------------------
            -- Dans le cas extrême où les deux sens sont invalides
            -- rollDir peut se retrouver bloqué… Alors on roule dans
            -- le seul sens non-mur, même vers joueur.
            -----------------------------------------------------------
            if rollDir == -1 and eAtLeftWall then 
                rollDir = 1
            elseif rollDir == 1 and eAtRightWall then
                rollDir = -1
            end

            -----------------------------------------------------------
            -- Appliquer roulade finale
            -----------------------------------------------------------
            -- addDebugLog("---hit detecté---")
            e.isCrouching = false
            if e.isBlocking then
                e.isBlocking = false
                e.wantBlock = nil
            end
            e.rollRequested = true
            e.rollDirection = rollDir
            e.hitJustReceived = false
            return
        end

        ---------------------------------------
        -- RECULER (60% CHANCE)
        ---------------------------------------
        local backDir = -dirToPlayer

        -----------------------------------------------------------
        -- si mur derrière IA → ne pas reculer
        -----------------------------------------------------------

        if backDir == -1 and eAtLeftWall then
            backDir = 0
        elseif backDir == 1 and eAtRightWall then
            backDir = 0
        end

        e.isCrouching = false
        if e.isBlocking then
            e.isBlocking = false
            e.wantBlock = nil
        end
        e.wantMove = backDir
        return
    end 

    -- ===============================
    -- ATTAQUE SI À BONNE DISTANCE
    -- ===============================
    -- addDebugLog("self.attackCooldown=" .. tostring(self.attackCooldown))
    if dist < 100 and not e:isBusy() and self.attackCooldown <= 0 then
        e.isCrouching = false
        e.wantBlock = nil
        if e.isBlocking then
            e.isBlocking = false
            e.wantBlock = nil
        end
        local attackID = self:chooseAttack(dist)

        if attackID then
            e.movement:attackList(attackID)

            -- cooldown intelligent
            self.attackCooldown = 0.05 + math.random() * 0.00
            -- pause seulement APRES attaque
            -- if math.random() < self.pauseChance then
            --     self.pauseTimer = math.random(self.pauseMin, self.pauseMax)
            -- end
        end
        return
    end

    -- ===============================
    -- SE RAPPROCHER
    -- ===============================
    if dist < 67 then
        e.wantMove = 0
        return
    end

    if dist >= 70 and not e:isBusy() then
        e.wantMove = dirToPlayer
        return
    end

    if dist < 70 and math.random() < 0.15 and not e:isBusy() then
        -- CHANCE DE PAUSE
        -- if self:canPause(dist) and math.random() < self.pauseChance then
        --     self.pauseTimer = math.random(self.pauseMin, self.pauseMax)
        --     return
        -- end
        if not eAtRightWall or not eAtLeftWall then
            e.isCrouching = false
            if e.isBlocking then
                e.isBlocking = false
                e.wantBlock = nil
            end
            e.wantMove = -dirToPlayer
            return
        end
    end
end

return AI
