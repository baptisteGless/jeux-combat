local HealthBar = {}
HealthBar.__index = HealthBar

function HealthBar:new(x, y, w, h, owner)
    return setmetatable({
        x = x,
        y = y,
        width = w,
        height = h,
        owner = owner -- Player ou Enemy
    }, HealthBar)
end

function HealthBar:draw()
    local hpRatio = math.max(0, self.owner.hp / self.owner.maxHp)

    -- Fond
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", self.x - 2, self.y - 2, self.width + 4, self.height + 4)

    -- Barre vide
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Vie
    love.graphics.setColor(0.9, 0.1, 0.1)
    love.graphics.rectangle("fill", self.x, self.y, self.width * hpRatio, self.height)

    -- Reset
    love.graphics.setColor(1, 1, 1)
end

return HealthBar
