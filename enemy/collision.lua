-- enemy/collision.lua

local Collision = {}
Collision.__index = Collision

function Collision.new(enemy)
    local self = setmetatable({}, Collision)
    self.enemy = enemy
    return self
end

-- Vérifie si deux rectangles se touchent
function Collision.checkCollision(a, b)
    return a.x < b.x + b.width and
           a.x + a.width > b.x and
           a.y < b.y + b.height and
           a.y + a.height > b.y
end

function Collision:handle(other, dt)
    local e = self.enemy
    
    if e.thrown or e.isGettingUp then
        return
    end

    if not Collision.checkCollision(e, other) then
        e.isBlocked = false
        return
    end

    -- Cas 1 : roulade
    if e.isRolling then
        if e.rollDirection > 0 then
            e.x = other.x + other.width
        else
            e.x = other.x - e.width
        end
        return
    end

    -- Cas 2 : saut → glisser
    if not e.isOnGround then
        local enemyCenterX = e.x + e.width/2
        local otherCenterX = other.x + other.width/2
        local slideSpeed = 200 -- vitesse de glissement en px/s

        if other:isAtLeftEdge() then
            -- L'adversaire est collé à gauche → toujours glisser à droite
            e.x = math.max(e.x + slideSpeed * dt, other.x + other.width)
        elseif other:isAtRightEdge() then
            -- L'adversaire est collé à droite → toujours glisser à gauche
            e.x = math.min(e.x - slideSpeed * dt, other.x - e.width)
        else
            -- Sinon choisir gauche/droite en fonction de la position relative
            if enemyCenterX < otherCenterX then
                -- Glisser vers la gauche
                e.x = math.min(e.x - slideSpeed * dt, other.x - e.width)
            else
                -- Glisser vers la droite
                e.x = math.max(e.x + slideSpeed * dt, other.x + other.width)
            end
        end
        return
    end

    -- Cas 3 : bloqué au sol
    if e.x < other.x then
        e.x = other.x - e.width
    else
        e.x = other.x + other.width
    end
    e.isBlocked = true
end

return Collision