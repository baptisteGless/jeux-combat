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
    -- punch
    self.punchFrames = {
        G = {
            love.graphics.newImage("images/perso_images/punch/punch1-G.png"),
            love.graphics.newImage("images/perso_images/punch/punch2-G.png"),
            love.graphics.newImage("images/perso_images/punch/punch3-G.png"),
            love.graphics.newImage("images/perso_images/punch/punch4-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/punch/punch1-D.png"),
            love.graphics.newImage("images/perso_images/punch/punch2-D.png"),
            love.graphics.newImage("images/perso_images/punch/punch3-D.png"),
            love.graphics.newImage("images/perso_images/punch/punch4-D.png"),
        }
    }

    -- low-slash
    self.lowSlashFrames = {
        G = {
            love.graphics.newImage("images/perso_images/low-slash/ls1-G.png"),
            love.graphics.newImage("images/perso_images/low-slash/ls2-G.png"),
            love.graphics.newImage("images/perso_images/low-slash/ls3-G.png"),
            love.graphics.newImage("images/perso_images/low-slash/ls4-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/low-slash/ls1-D.png"),
            love.graphics.newImage("images/perso_images/low-slash/ls2-D.png"),
            love.graphics.newImage("images/perso_images/low-slash/ls3-D.png"),
            love.graphics.newImage("images/perso_images/low-slash/ls4-D.png"),
        }
    }

    -- low-kick
    self.lowKickFrames = {
        G = {
            love.graphics.newImage("images/perso_images/low-kick/lk1-G.png"),
            love.graphics.newImage("images/perso_images/low-kick/lk2-G.png"),
            love.graphics.newImage("images/perso_images/low-kick/lk3-G.png"),
            love.graphics.newImage("images/perso_images/low-kick/lk4-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/low-kick/lk1-D.png"),
            love.graphics.newImage("images/perso_images/low-kick/lk2-D.png"),
            love.graphics.newImage("images/perso_images/low-kick/lk3-D.png"),
            love.graphics.newImage("images/perso_images/low-kick/lk4-D.png"),
        }
    }

    -- knee
    self.kneeFrames = {
        G = {
            love.graphics.newImage("images/perso_images/knee/knee1-G.png"),
            love.graphics.newImage("images/perso_images/knee/knee2-G.png"),
            love.graphics.newImage("images/perso_images/knee/knee3-G.png"),
            love.graphics.newImage("images/perso_images/knee/knee4-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/knee/knee1-D.png"),
            love.graphics.newImage("images/perso_images/knee/knee2-D.png"),
            love.graphics.newImage("images/perso_images/knee/knee3-D.png"),
            love.graphics.newImage("images/perso_images/knee/knee4-D.png"),
        }
    }

    -- kick
    self.kickFrames = {
        G = {
            love.graphics.newImage("images/perso_images/kick/kick1-G.png"),
            love.graphics.newImage("images/perso_images/kick/kick2-G.png"),
            love.graphics.newImage("images/perso_images/kick/kick3-G.png"),
            love.graphics.newImage("images/perso_images/kick/kick4-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/kick/kick1-D.png"),
            love.graphics.newImage("images/perso_images/kick/kick2-D.png"),
            love.graphics.newImage("images/perso_images/kick/kick3-D.png"),
            love.graphics.newImage("images/perso_images/kick/kick4-D.png"),
        }
    }

    -- hit1
    self.hit1Frames = {
        G = {
            love.graphics.newImage("images/perso_images/hit1/hit1-G.png"),
            love.graphics.newImage("images/perso_images/hit1/hit2-G.png"),
            love.graphics.newImage("images/perso_images/hit1/hit3-G.png"),
            love.graphics.newImage("images/perso_images/hit1/hit4-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/hit1/hit1-D.png"),
            love.graphics.newImage("images/perso_images/hit1/hit2-D.png"),
            love.graphics.newImage("images/perso_images/hit1/hit3-D.png"),
            love.graphics.newImage("images/perso_images/hit1/hit4-D.png"),
        }
    }
    
    -- heavy-slash
    self.heavySlashFrames = {
        G = {
            love.graphics.newImage("images/perso_images/heavy-slash/hs1-G.png"),
            love.graphics.newImage("images/perso_images/heavy-slash/hs2-G.png"),
            love.graphics.newImage("images/perso_images/heavy-slash/hs3-G.png"),
            love.graphics.newImage("images/perso_images/heavy-slash/hs4-G.png"),
            love.graphics.newImage("images/perso_images/heavy-slash/hs5-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/heavy-slash/hs1-D.png"),
            love.graphics.newImage("images/perso_images/heavy-slash/hs2-D.png"),
            love.graphics.newImage("images/perso_images/heavy-slash/hs3-D.png"),
            love.graphics.newImage("images/perso_images/heavy-slash/hs4-D.png"),
            love.graphics.newImage("images/perso_images/heavy-slash/hs5-D.png"),
        }
    }

    -- big-slash
    self.bigSlashFrames = {
        G = {
            love.graphics.newImage("images/perso_images/big-slash/bs1-G.png"),
            love.graphics.newImage("images/perso_images/big-slash/bs2-G.png"),
            love.graphics.newImage("images/perso_images/big-slash/bs3-G.png"),
            love.graphics.newImage("images/perso_images/big-slash/bs4-G.png"),
            love.graphics.newImage("images/perso_images/big-slash/bs5-G.png"),
            love.graphics.newImage("images/perso_images/big-slash/bs6-G.png"),
            love.graphics.newImage("images/perso_images/big-slash/bs7-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/big-slash/bs1-D.png"),
            love.graphics.newImage("images/perso_images/big-slash/bs2-D.png"),
            love.graphics.newImage("images/perso_images/big-slash/bs3-D.png"),
            love.graphics.newImage("images/perso_images/big-slash/bs4-D.png"),
            love.graphics.newImage("images/perso_images/big-slash/bs5-D.png"),
            love.graphics.newImage("images/perso_images/big-slash/bs6-D.png"),
            love.graphics.newImage("images/perso_images/big-slash/bs7-D.png"),
        }
    }

    return self
end

function Sprites:getCurrentSprite()
    local p = self.player
    local sprite

    local function safeFrame(frames)
        if not frames or #frames == 0 then return nil end
        local idx = math.min(p.animation.currentFrame, #frames)
        return frames[idx]
    end

    if p.animation.isRolling then
        sprite = safeFrame(self.rollFrames[p.side])
        if sprite and p.animation.rollBackward then
            local frames = self.rollFrames[p.side]
            sprite = frames[#frames - p.animation.currentFrame + 1]
        end
    elseif p.animation.isJumping then
        sprite = safeFrame(p.jumpFrames and p.jumpFrames[p.side])
    elseif p.isBlocking then
        sprite = p.isCrouching and ((p.side=="G") and self.blockBasG or self.blockBasD)
                                  or ((p.side=="G") and self.blockHautG or self.blockHautD)
    elseif p.isCrouching then
        sprite = (p.side=="G") and self.poseBasG or self.poseBasD
    elseif p.animation.isBigSlashing then
        sprite = safeFrame(self.bigSlashFrames[p.side])
    elseif p.animation.isHeavySlashing then
        sprite = safeFrame(self.heavySlashFrames[p.side])
    elseif p.animation.ishit1ing then
        sprite = safeFrame(self.hit1Frames[p.side])
    elseif p.animation.iskicking then
        sprite = safeFrame(self.kickFrames[p.side])
    elseif p.animation.iskneeing then
        sprite = safeFrame(self.kneeFrames[p.side])
    elseif p.animation.isLowKicking then
        sprite = safeFrame(self.lowKickFrames[p.side])
    elseif p.animation.isLowSlashing then
        sprite = safeFrame(self.lowSlashFrames[p.side])
    elseif p.animation.isPunching then
        sprite = safeFrame(self.punchFrames[p.side])
    elseif p.animation.isWalking then
        local frames = (p.animation.walkType=="forward") and p.walkForwardFrames[p.side] or p.walkBackwardFrames[p.side]
        sprite = safeFrame(frames)
    else
        sprite = (p.side=="G") and self.poseG or self.poseD
    end

    -- fallback
    if not sprite then
        sprite = (p.side=="G") and self.poseG or self.poseD
    end

    return sprite
end

-- multipliers pour les frames du roll
Sprites.rollScaleMultipliers = { 
    0.7,  -- frame 1
    0.6,  -- frame 2
    0.6,  -- frame 3
    0.6,  -- frame 4
    0.6,  -- frame 5
    0.8   -- frame 6
}

function Sprites:draw()
    local p = self.player
    local sprite = self:getCurrentSprite()
    
    -- facteur de réduction quand accroupi
    local crouchScale = p.isCrouching and 0.7 or 1

    if type(sprite) == "table" then
        -- sprite = {img, scaleX, scaleY}
        local img = sprite.img
        local scaleX = sprite.scaleX
        local scaleY = sprite.scaleY
        if p.animation.isRolling then
            local frame = p.animation.currentFrame or 1
            local rollMultiplier = Sprites.rollScaleMultipliers[frame] or 1
            scaleX = scaleX * rollMultiplier
            scaleY = scaleY * rollMultiplier
        end
        -- appliquer scale pour accroupissement
        scaleY = scaleY * crouchScale 
        local w, h = img:getWidth(), img:getHeight()
        local drawX = p.x + p.width / 2
        local drawY = p.y + p.height
        local originX = w / 2
        local originY = h * crouchScale  

        love.graphics.draw(img, drawX, drawY, 0, scaleX, scaleY, originX, originY)
    else
        -- ancien comportement (pour les poses fixes qui sont juste des images)
        local w, h = sprite:getWidth(), sprite:getHeight()
        local scale = (p.height / h) * crouchScale
        local drawX = p.x + p.width / 2
        local drawY = p.y + p.height
        local originX = w / 2
        local originY = h 

        love.graphics.draw(sprite, drawX, drawY, 0, scale, scale, originX, originY)
    end
end



return Sprites
