-- enemy/sprites.lua
local Assets = require("assets")

local Sprites = {}
Sprites.__index = Sprites

function Sprites.new(enemy)
    local self = setmetatable({}, Sprites)
    self.enemy = enemy
    self.logoID = Assets.images.enemyLogoId
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
    self.bbhFrames = Assets.images.bbhFrames
    self.bhhFrames = Assets.images.bhhFrames
    self.fallLow = Assets.images.fallLow
    self.guv = Assets.images.guv
    self.shopReaction = Assets.images.shopReaction

    return self
end

function Sprites:getCurrentSprite()
    local e = self.enemy
    local sprite

    local function safeFrame(frames)
        if not frames or #frames == 0 then return nil end
        local idx = math.min(e.animation.currentFrame, #frames)
        return frames[idx]
    end

    -- Animation bas
    -- addDebugLog("e.state" .. tostring(e.state))
    -- addDebugLog("e.directionatk" .. tostring(e.directionatk))
    if e.isBlocking then
        if e.blockType == "bas" then
            sprite = (e.side=="G") and self.blockBasG or self.blockBasD
        else
            sprite = (e.side=="G") and self.blockHautG or self.blockHautD
        end
    elseif e.animation.isguving then
        sprite = safeFrame(self.guv[e.side])
    elseif e.thrown then
        sprite = safeFrame(self.fallLow[e.side])
    elseif e.animation.isBBHing then
        sprite = safeFrame(self.bbhFrames[e.side])
    elseif e.animation.isBHHing then
        sprite = safeFrame(self.bhhFrames[e.side])
    elseif e.animation.isRolling then
        sprite = safeFrame(self.rollFrames[e.side])
        if sprite and e.animation.rollBackward then
            local frames = self.rollFrames[e.side]
            sprite = frames[#frames - e.animation.currentFrame + 1]
        end
    elseif e.animation.isShopReactioning then
        sprite = safeFrame(self.shopReaction[e.side])
        local img = safeFrame(self.shopReaction[e.side])
        return {
            img = img,
            scaleX = e.scaleX or 1,
            scaleY = e.scaleY or 1
        }
    elseif e.animation.isJumping then
        sprite = safeFrame(e.jumpFrames and e.jumpFrames[e.side])
    elseif e.animation.isBasSlashing then
        sprite = safeFrame(self.basSlashFrames[e.side])
    elseif e.isCrouching then
        sprite = (e.side=="G") and self.poseBasG or self.poseBasD
    elseif e.animation.isBigSlashing then
        sprite = safeFrame(self.bigSlashFrames[e.side])
    elseif e.animation.isHeavySlashing then
        sprite = safeFrame(self.heavySlashFrames[e.side])
    elseif e.animation.ishit1ing then
        sprite = safeFrame(self.hit1Frames[e.side])
    elseif e.animation.iskicking then
        sprite = safeFrame(self.kickFrames[e.side])
    elseif e.animation.iskneeing then
        sprite = safeFrame(self.kneeFrames[e.side])
    elseif e.animation.isLowKicking then
        sprite = safeFrame(self.lowKickFrames[e.side])
    elseif e.animation.isLowSlashing then
        sprite = safeFrame(self.lowSlashFrames[e.side])
    elseif e.animation.isShoping then
        sprite = safeFrame(self.shopFrames[e.side])
    elseif e.animation.isPunching then
        sprite = safeFrame(self.punchFrames[e.side])
    elseif e.animation.isWalking then
        local frames = (e.animation.walkType=="forward") and e.walkForwardFrames[e.side] or e.walkBackwardFrames[e.side]
        sprite = safeFrame(frames)
    elseif e.gameOver then
        sprite = (e.side=="G") and self.KOG or self.KOD
    else
        sprite = (e.side=="G") and self.poseG or self.poseD
    end

    -- fallback
    if not sprite then
        if self.poseG then
            sprite = (e.side=="G") and self.poseG or self.poseD
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
Sprites.shopReactScaleMultipliers = { 
    0.12,  -- frame 1
    0.12,  -- frame 2
    0.12,  -- frame 3
    0.12,  -- frame 4
    0.12,  -- frame 5
    0.12,  -- frame 6
    0.12,  -- frame 7
    0.12,  -- frame 8
    0.12,  -- frame 9
    0.12,  -- frame 10
    0.12,  -- frame 11
    0.12,  -- frame 12
    0.12,  -- frame 13
    0.12   -- frame 14
}

function Sprites:draw()
    local e = self.enemy
    local sprite = self:getCurrentSprite()
    if not sprite then
        return -- on dessine rien cette frame
    end

    -- facteur de réduction quand accroupi
    local crouchScale = e.isCrouching and 0.7 or 1

    -- facteur spécial pour shop
    local shopScale = (sprite and e.animation.isShoping) and 1.1 or 1

    if type(sprite) == "table" then
        -- sprite = {img, scaleX, scaleY}
        local img = sprite.img
        local scaleX = sprite.scaleX
        local scaleY = sprite.scaleY
        if e.animation.isRolling then
            local frame = e.animation.currentFrame or 1
            local rollMultiplier = Sprites.rollScaleMultipliers[frame] or 1
            scaleX = scaleX * rollMultiplier
            scaleY = scaleY * rollMultiplier
        end
        if e.animation.isShopReactioning then
            local frame = e.animation.currentFrame or 1
            local shopMultiplier = Sprites.shopReactScaleMultipliers[frame] or 1
            scaleX = scaleX * shopMultiplier
            scaleY = scaleY * shopMultiplier
        end
        -- appliquer scale pour accroupissement
        scaleY = scaleY * crouchScale * shopScale
        local w, h = img:getWidth(), img:getHeight()
        local drawX = e.x + e.width / 2
        local drawY = e.y + e.height
        local originX = w / 2
        local originY = h * crouchScale * shopScale

        love.graphics.draw(img, drawX, drawY, 0, scaleX, scaleY, originX, originY)
        -- === LOGO AU-DESSUS DE L'ENEMY ===
        if self.logoID then
            local logo = self.logoID
            local lw, lh = logo:getWidth(), logo:getHeight()

            local logoScale = 0.4
            local offsetY = 20

            local logoX = e.x + e.width / 2
            local logoY = e.y - offsetY

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
        local scale = (e.height / h) * crouchScale * shopScale
        local drawX = e.x + e.width / 2
        local drawY = e.y + e.height
        local originX = w / 2
        local originY = h 

        love.graphics.draw(sprite, drawX, drawY, 0, scale, scale, originX, originY)
         -- === LOGO AU-DESSUS DE L'ENEMY ===
        if self.logoID then
            local logo = self.logoID
            local lw, lh = logo:getWidth(), logo:getHeight()

            local logoScale = 0.4
            local offsetY = 20

            local logoX = e.x + e.width / 2
            local logoY = e.y - offsetY

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