-- enemy/ai.lua
local AI = {}
AI.__index = AI

function AI.new(enemy, target)
    local self = setmetatable({}, AI)
    self.enemy = enemy
    self.target = target

    self.pauseTimer = 0
    self.pauseChance = 0.10      -- 40% de chance de faire rien
    self.pauseMin = 0.5         -- mini 0.20s de pause
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

    if not p then return end

    self.thinkTimer = self.thinkTimer - dt
    if self.thinkTimer > 0 then return end
    self.thinkTimer = self.thinkDelay

    self.attackCooldown = self.attackCooldown - dt

    -- Si l'ennemi est touché, il ne décide rien
    if e.state ~= "idle" or e:isBusy() then
        return
    end

    -- si en pause, on décompte et on ne fait rien
    if self.pauseTimer > 0 then
        self.pauseTimer = self.pauseTimer - dt
        e.wantMove = 0
        return
    end

    local dist = distance(e, p)
    local dirToPlayer = (p.x > e.x) and 1 or -1

    -- ===============================
    -- ESQUIVE SI LE JOUEUR ATTAQUE
    -- ===============================
    if p:isBusy() then
        -- si trop proche -> ROLL OBLIGATOIRE
        if dist < 140 then
            -- CHANCE DE PAUSE
            if self:canPause(dist) and math.random() < self.pauseChance then
                self.pauseTimer = math.random(self.pauseMin, self.pauseMax)
                e.wantMove = 0
                return
            end

            e.rollRequested = true
            -- 70% de chance de reculer
            e.rollDirection = (math.random() < 0.7) and -dirToPlayer or dirToPlayer
            return
        end
        -- CHANCE DE PAUSE
        if self:canPause(dist) and math.random() < self.pauseChance then
            self.pauseTimer = math.random(self.pauseMin, self.pauseMax)
            e.wantMove = 0
            return
        end
        -- sinon reculer franchement
        e.wantMove = -dirToPlayer
        return
    end


    -- ===============================
    -- ATTAQUE SI À BONNE DISTANCE
    -- ===============================
    if dist < 140 and not e:isBusy() and self.attackCooldown <= 0 then

        local attackID = self:chooseAttack(dist)

        if attackID then
            e.movement:attackList(attackID)

            -- cooldown intelligent
            self.attackCooldown = 0.45 + math.random() * 0.25
            -- pause seulement APRES attaque
            if math.random() < 0.45 then
                self.pauseTimer = math.random(0.15, 0.45)
            end
        end
        return
    end

    -- ===============================
    -- SE RAPPROCHER
    -- ===============================
    if dist > 200 then
        e.wantMove = dirToPlayer
        return
    end

    if dist > 160 then
        -- CHANCE DE PAUSE
        if self:canPause(dist) and math.random() < self.pauseChance then
            self.pauseTimer = math.random(self.pauseMin, self.pauseMax)
            e.wantMove = 0
            return
        end
        e.wantMove = dirToPlayer
        return
    end
    if dist < 75 then
        -- CHANCE DE PAUSE
        if self:canPause(dist) and math.random() < self.pauseChance then
            self.pauseTimer = math.random(self.pauseMin, self.pauseMax)
            e.wantMove = 0
            return
        end
        e.wantMove = -dirToPlayer
        return
    end
    -- ===============================
    -- MICRO-AJUSTEMENT / FEINTE
    -- ===============================
    if math.random() < 0.25 then
        e.wantMove = -dirToPlayer
    end
end

return AI
