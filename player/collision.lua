-- player/collision.lua

local Collision = {}
Collision.__index = Collision

function Collision.new(player)
    local self = setmetatable({}, Collision)
    self.player = player
    return self
end

-- Vérifie si deux rectangles se touchent
function Collision.checkCollision(a, b)
    return a.x < b.x + b.width and
           a.x + a.width > b.x and
           a.y < b.y + b.height and
           a.y + a.height > b.y
end

function Collision:handle(other, dt ,typeGame)
    local p = self.player

    if p.isInShopSequence or other.isInShopSequence then
        return
    end
    
    if not Collision.checkCollision(p, other) then
        p.isBlocked = false
        return
    end

    -- Cas 1 : roulade
    if p.isRolling then
        if p.rollDirection > 0 then
            p.x = other.x + other.width
        else
            p.x = other.x - p.width
        end
        return
    end

    -- Cas 2 : saut → glisser
    if not p.isOnGround then
        local playerCenterX = p.x + p.width/2
        local otherCenterX = other.x + other.width/2
        local slideSpeed = 200 -- vitesse de glissement en px/s

        if other:isAtLeftEdge() then
            -- L'adversaire est collé à gauche → toujours glisser à droite
            p.x = math.max(p.x + slideSpeed * dt, other.x + other.width)
        elseif other:isAtRightEdge() then
            -- L'adversaire est collé à droite → toujours glisser à gauche
            p.x = math.min(p.x - slideSpeed * dt, other.x - p.width)
        else
            -- Sinon choisir gauche/droite en fonction de la position relative
            if playerCenterX < otherCenterX then
                -- Glisser vers la gauche
                p.x = math.min(p.x - slideSpeed * dt, other.x - p.width)
            else
                -- Glisser vers la droite
                p.x = math.max(p.x + slideSpeed * dt, other.x + other.width)
            end
        end
        return
    end

    -- Cas 3 : bloqué au sol
    if p.x < other.x then
        p.x = other.x - p.width
    else
        p.x = other.x + other.width
    end
    p.isBlocked = true
end

return Collision
