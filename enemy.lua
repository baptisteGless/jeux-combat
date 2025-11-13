local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(x, y, target)
    local self = setmetatable({}, Enemy)
    self.x = x
    self.y = y
    self.width = 100
    self.height = 200
    self.speed = 150
    self.target = target -- référence vers le joueur
    self.sprite = love.graphics.newImage("images/perso_images/enemy.png")
    return self
end

function Enemy:update(dt)
    -- Simple IA : suivre le joueur en X
    if self.target.x < self.x then
        self.x = self.x - self.speed * dt
    elseif self.target.x > self.x then
        self.x = self.x + self.speed * dt
    end
end

function Enemy:draw()
    love.graphics.setColor(1, 1, 1)
    local spriteW = self.sprite:getWidth()
    local spriteH = self.sprite:getHeight()
    love.graphics.draw(
        self.sprite,
        self.x + self.width / 2,
        self.y + self.height / 2,
        0,
        self.width / spriteW,
        self.height / spriteH,
        spriteW / 2,
        spriteH / 2
    )
end

return Enemy
