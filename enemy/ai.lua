-- enemy/ai.lua
local AI = {}
AI.__index = AI

function AI.new(enemy, target)
    local self = setmetatable({}, AI)
    self.enemy = enemy
    self.target = target

    self.thinkTimer = 0
    self.thinkDelay = 0.15 -- temps entre décisions (important)

    return self
end

-- Distance horizontale
local function distance(a, b)
    return math.abs(a.x - b.x)
end

function AI:update(dt)
    local e = self.enemy
    local p = self.target

    if not p then return end

    self.thinkTimer = self.thinkTimer - dt
    if self.thinkTimer > 0 then return end
    self.thinkTimer = self.thinkDelay

    -- Si l'ennemi est touché, il ne décide rien
    if e.state ~= "idle" or e:isBusy() then
        return
    end

    local dist = distance(e, p)
    local dirToPlayer = (p.x > e.x) and 1 or -1

    -- ===============================
    -- ESQUIVE SI LE JOUEUR ATTAQUE
    -- ===============================
    if p:isBusy() then
        -- si trop proche -> ROLL OBLIGATOIRE
        if dist < 160 then
            e.rollRequested = true

            -- 70% de chance de reculer
            e.rollDirection = (math.random() < 0.7) and -dirToPlayer or dirToPlayer
            return
        end

        -- sinon reculer franchement
        e.wantMove = -dirToPlayer
        return
    end


    -- ===============================
    -- ATTAQUE SI À BONNE DISTANCE
    -- ===============================
    -- if dist < 120 then
    --     -- if not e:isBusy() then
    --     e.movement:executeMove("punch")
    --     -- end
    --     return
    -- end

    -- ===============================
    -- SE RAPPROCHER
    -- ===============================
    if dist > 160 then
        e.wantMove = dirToPlayer
        return
    end
    if dist < 90 then
        e.wantMove = -dirToPlayer
        return
    end
    -- ===============================
    -- MICRO-AJUSTEMENT / FEINTE
    -- ===============================
    if math.random() < 0.3 then
        e.wantMove = -dirToPlayer
    end
end

return AI
