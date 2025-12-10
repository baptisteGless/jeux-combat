-- enemy/sprites.lua
local Sprites = {}
Sprites.__index = Sprites

function Sprites.new(enemy)
    local self = setmetatable({}, Sprites)
    self.enemy = enemy
    self.poseG = love.graphics.newImage("images/perso_images/pose-G.png")
    self.poseD = love.graphics.newImage("images/perso_images/pose-D.png")
    return self
end

function Sprites:getCurrentSprite()
    local e = self.enemy
    -- Pour l’instant, l’ennemi n’a pas d’animations :
    return (e.side == "G") and self.poseG or self.poseD
end

function Sprites:draw()
   local e = self.enemy
    local sprite = self:getCurrentSprite()

    local w, h = sprite:getWidth(), sprite:getHeight()
    local scale = e.height / h

    local drawX = e.x + e.width / 2
    local drawY = e.y + e.height
    local originX = w / 2
    local originY = h

    love.graphics.draw(sprite, drawX, drawY, 0, scale, scale, originX, originY)
end

return Sprites