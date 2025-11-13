-- player/sprites.lua
local Sprites = {}
Sprites.__index = Sprites

function Sprites.new(player)
    local self = setmetatable({}, Sprites)
    self.player = player
    self.poseG = love.graphics.newImage("images/perso_images/pose-G.png")
    self.poseD = love.graphics.newImage("images/perso_images/pose-D.png")
    self.poseBasG = love.graphics.newImage("images/perso_images/poseBAS-G.png")
    self.poseBasD = love.graphics.newImage("images/perso_images/poseBAS-D.png")

    self.blockHautG = love.graphics.newImage("images/perso_images/blockHAUT-G.png")
    self.blockHautD = love.graphics.newImage("images/perso_images/blockHAUT-D.png")
    self.blockBasG  = love.graphics.newImage("images/perso_images/blockBAS-G.png")
    self.blockBasD  = love.graphics.newImage("images/perso_images/blockBAS-D.png")

    -- roll
    self.rollFrames = {
        G = {
            love.graphics.newImage("images/perso_images/roll/roll1-G.png"),
            love.graphics.newImage("images/perso_images/roll/roll2-G.png"),
            love.graphics.newImage("images/perso_images/roll/roll3-G.png"),
            love.graphics.newImage("images/perso_images/roll/roll4-G.png"),
            love.graphics.newImage("images/perso_images/roll/roll5-G.png"),
            love.graphics.newImage("images/perso_images/roll/roll6-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/roll/roll1-D.png"),
            love.graphics.newImage("images/perso_images/roll/roll2-D.png"),
            love.graphics.newImage("images/perso_images/roll/roll3-D.png"),
            love.graphics.newImage("images/perso_images/roll/roll4-D.png"),
            love.graphics.newImage("images/perso_images/roll/roll5-D.png"),
            love.graphics.newImage("images/perso_images/roll/roll6-D.png"),
        }
    }

    return self
end

function Sprites:draw()
    local p = self.player
    local sprite

    if p.animation.isRolling then
        local frames = self.rollFrames[p.side]
        if p.animation.rollBackward then
            sprite = frames[#frames - p.animation.currentFrame + 1]
        else
            sprite = frames[p.animation.currentFrame]
        end
    elseif p.animation.isJumping then
        -- Animation de saut
        sprite = p.jumpFrames[p.side][p.animation.currentFrame]
    elseif p.isBlocking then
        -- Blocage haut ou bas
        if p.isCrouching then
            sprite = (p.side == "G") and self.blockBasG or self.blockBasD
        else
            sprite = (p.side == "G") and self.blockHautG or self.blockHautD
        end
    elseif p.isCrouching then
        sprite = (p.side == "G") and self.poseBasG or self.poseBasD
    elseif p.animation.isWalking then
        -- Animation de marche
        local frames = (p.animation.walkType == "forward")
            and p.walkForwardFrames[p.side]
            or p.walkBackwardFrames[p.side]
        sprite = frames[p.animation.currentFrame]
    else
        sprite = (p.side == "G") and self.poseG or self.poseD
    end

    if sprite then
        local w, h = sprite:getWidth(), sprite:getHeight()
        local scaleX = p.width / w
        local scaleY = p.height / h
        love.graphics.draw(sprite, p.x + p.width/2, p.y + p.height/2, 0, scaleX, scaleY, w/2, h/2)
    end
end

return Sprites
