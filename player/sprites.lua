-- player/sprites.lua
local Assets = require("assets")

local Sprites = {}
Sprites.__index = Sprites

function Sprites.new(player)
    local self = setmetatable({}, Sprites)
    self.player = player
    self.logoID = Assets.images.playerLogoId
    self.poseG = Assets.images.poseG
    self.poseD = Assets.images.poseD
    self.poseBasG = Assets.images.poseBasG
    self.poseBasD = Assets.images.poseBasD
    self.KOG = Assets.images.KOG
    self.KOD = Assets.images.KOD
    self.blockHautG = Assets.images.blockHautG
    self.blockHautD = Assets.images.blockHautD
    self.blockBasG = Assets.images.blockBasG
    self.blockBasD = Assets.images.blockBasD
    self.rollFrames = Assets.images.roll
    self.punchFrames = Assets.images.punchFrames
    self.basSlashFrames = Assets.images.basSlashFrames
    self.lowSlashFrames = Assets.images.lowSlashFrames
    self.lowKickFrames = Assets.images.lowKickFrames
    self.kneeFrames = Assets.images.kneeFrames
    self.kickFrames = Assets.images.kickFrames
    self.hit1Frames = Assets.images.hit1Frames
    self.heavySlashFrames = Assets.images.heavySlashFrames
    self.bigSlashFrames = Assets.images.bigSlashFrames
    self.shopFrames = Assets.images.shopFrames
    self.shopSuccessFrames = Assets.images.shopSuccessFrames
    self.shopFailFrames = Assets.images.shopFailFrames
    self.bbhFrames = Assets.images.bbhFrames
    self.bhhFrames = Assets.images.bhhFrames
    self.fallLow = Assets.images.fallLow
    self.guv = Assets.images.guv

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
    -- addDebugLog("p.animation.isBHHing=" .. tostring(p.animation.isBHHing))
    -- addDebugLog("p.animation.isBBHing=" .. tostring(p.animation.isBBHing))

    if p.animation.isRolling then
        sprite = safeFrame(self.rollFrames[p.side])
        if sprite and p.animation.rollBackward then
            local frames = self.rollFrames[p.side]
            sprite = frames[#frames - p.animation.currentFrame + 1]
        end
    elseif p.animation.isguving then
        sprite = safeFrame(self.guv[p.side])
    elseif p.thrown then
        sprite = safeFrame(self.fallLow[p.side])
    elseif p.animation.isJumping then
        sprite = safeFrame(p.jumpFrames and p.jumpFrames[p.side])
    elseif p.isBlocking then
        sprite = p.isCrouching and ((p.side=="G") and self.blockBasG or self.blockBasD)
                                  or ((p.side=="G") and self.blockHautG or self.blockHautD)
    elseif p.animation.isBBHing then
        p.isCrouching = false
        sprite = safeFrame(self.bbhFrames[p.side])
    elseif p.animation.isBHHing then
        p.isCrouching = false
        sprite = safeFrame(self.bhhFrames[p.side])
    elseif p.animation.isBasSlashing then
        sprite = safeFrame(self.basSlashFrames[p.side])
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
    elseif p.animation.isShopFailing then
        sprite = safeFrame(self.shopFailFrames[p.side])
    elseif p.animation.isShopSuccessing then
        sprite = safeFrame(self.shopSuccessFrames[p.side])
        local img = safeFrame(self.shopSuccessFrames[p.side])
        return {
            img = img,
            scaleX = p.scaleX or 1,
            scaleY = p.scaleY or 1
        }
    elseif p.animation.isShoping then
        sprite = safeFrame(self.shopFrames[p.side])
    elseif p.animation.isPunching then
        sprite = safeFrame(self.punchFrames[p.side])
    elseif p.animation.isWalking then
        local frames = (p.animation.walkType=="forward") and p.walkForwardFrames[p.side] or p.walkBackwardFrames[p.side]
        sprite = safeFrame(frames)
    elseif p.gameOver then
        sprite = (p.side=="G") and self.KOG or self.KOD
    else
        sprite = (p.side=="G") and self.poseG or self.poseD
    end

    -- fallback
    if not sprite then
        if self.poseG then
            sprite = (p.side == "G") and self.poseG or self.poseD
        else
            return nil
        end
    end

    return sprite
end

-- multipliers pour les frames du roll
Sprites.rollScaleMultipliers = { 
    0.5,  -- frame 1
    0.4,  -- frame 2
    0.4,  -- frame 3
    0.4,  -- frame 4
    0.3,  -- frame 5
    0.6   -- frame 6
}

-- multipliers pour les frames du roll
Sprites.shopScaleMultipliers = { 
    0.12,  -- frame 1
    0.12,  -- frame 2
    0.12,  -- frame 3
    0.12,  -- frame 4
    0.12,  -- frame 5
    0.12,   -- frame 6
    0.12,  -- frame 7
    0.12,  -- frame 8
    0.12,  -- frame 9
    0.12,  -- frame 10
    0.12,  -- frame 11
    0.12,   -- frame 12
    0.12,  -- frame 13
    0.12,  -- frame 14
    0.12,  -- frame 15
    0.12   -- frame 16
}

function Sprites:draw()
    local p = self.player
    local sprite = self:getCurrentSprite()
    if not sprite then
        return -- on dessine rien cette frame
    end
    
    -- facteur de réduction quand accroupi
    local crouchScale = p.isCrouching and 0.7 or 1

    -- facteur spécial pour shop
    local shopScale = (sprite and p.animation.isShoping) and 1.1 or 1
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
        if p.animation.isShopSuccessing then
            local frame = p.animation.currentFrame or 1
            local shopMultiplier = Sprites.shopScaleMultipliers[frame] or 1
            scaleX = scaleX * shopMultiplier
            scaleY = scaleY * shopMultiplier
        end
        -- appliquer scale pour accroupissement
        scaleY = scaleY * crouchScale * shopScale
        local w, h = img:getWidth(), img:getHeight()
        local drawX = p.x + p.width / 2
        local drawY = p.y + p.height
        local originX = w / 2
        local originY = h * crouchScale * shopScale

        love.graphics.draw(img, drawX, drawY, 0, scaleX, scaleY, originX, originY)
        -- === LOGO AU-DESSUS DU PLAYER ===
        if self.logoID then
            local logo = self.logoID
            local lw, lh = logo:getWidth(), logo:getHeight()

            local logoScale = 0.4 -- ajuste si besoin
            local offsetY = 20    -- distance au-dessus de la tête

            local logoX = p.x + p.width / 2
            local logoY = p.y - offsetY

            love.graphics.draw(
                logo,
                logoX,
                logoY,
                0,
                logoScale,
                logoScale,
                lw / 2,
                lh
            )
        end
    else
        if not sprite or not sprite.getWidth then
            return
        end
        -- ancien comportement (pour les poses fixes qui sont juste des images)
        local w, h = sprite:getWidth(), sprite:getHeight()
        local scale = (p.height / h) * crouchScale * shopScale
        local drawX = p.x + p.width / 2
        local drawY = p.y + p.height
        local originX = w / 2
        local originY = h 

        love.graphics.draw(sprite, drawX, drawY, 0, scale, scale, originX, originY)
        -- === LOGO AU-DESSUS DU PLAYER ===
        if self.logoID then
            local logo = self.logoID
            local lw, lh = logo:getWidth(), logo:getHeight()

            local logoScale = 0.4 -- ajuste si besoin
            local offsetY = 20    -- distance au-dessus de la tête

            local logoX = p.x + p.width / 2
            local logoY = p.y - offsetY

            love.graphics.draw(
                logo,
                logoX,
                logoY,
                0,
                logoScale,
                logoScale,
                lw / 2,
                lh
            )
        end
    end
end



return Sprites
