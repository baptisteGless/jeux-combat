-- enemy/animation.lua
local Animation = {}
Animation.__index = Animation

function Animation.new(enemy)
    local self = setmetatable({}, Animation)
    self.enemy = enemy
    self.currentFrame = 1
    self.frameTimer = 0
    self.frameDuration = 0.08
    self.isWalking = false
    self.isJumping = false
    self.walkType = "forward" -- "forward" ou "backward"
    self.jumpPhase = "none"   -- "start", "air", "land"
    self.isPunching = false
    self.isLowSlashing = false
    self.isLowKicking = false
    self.iskneeing = false
    self.iskicking = false
    self.ishit1ing = false
    self.isHeavySlashing = false
    self.isBigSlashing = false
    self.isBasSlashing = false
    self.isShoping = false
    return self
end

function Animation:startBigSlash()
    self.isBigSlashing = true
    self.isHeavySlashing = false
    self.ishit1ing = false
    self.iskicking = false
    self.iskneeing = false
    self.isLowKicking = false
    self.isLowSlashing = false
    self.isPunching = false
    self.isWalking = false
    self.isJumping = false
    self.isRolling = false

    self.currentFrame = 1
    self.frameTimer = 0
end

function Animation:endBigSlash()
    self.isBigSlashing = false
    self.currentFrame = 1
end

function Animation:startHeavySlash()
    self.isBigSlashing = false
    self.isHeavySlashing = true
    self.ishit1ing = false
    self.iskicking = false
    self.iskneeing = false
    self.isLowKicking = false
    self.isLowSlashing = false
    self.isPunching = false
    self.isWalking = false
    self.isJumping = false
    self.isRolling = false

    self.currentFrame = 1
    self.frameTimer = 0
end

function Animation:endHeavySlash()
    self.isHeavySlashing = false
    self.currentFrame = 1
end

function Animation:starthit1()
    self.isBigSlashing = false
    self.isHeavySlashing = false
    self.ishit1ing = true
    self.iskicking = false
    self.iskneeing = false
    self.isLowKicking = false
    self.isLowSlashing = false
    self.isPunching = false
    self.isWalking = false
    self.isJumping = false
    self.isRolling = false

    self.currentFrame = 1
    self.frameTimer = 0
end

function Animation:endhit1()
    self.ishit1ing = false
    self.currentFrame = 1
end

function Animation:startkick()
    self.isBigSlashing = false
    self.isHeavySlashing = false
    self.ishit1ing = false
    self.iskicking = true
    self.iskneeing = false
    self.isLowKicking = false
    self.isLowSlashing = false
    self.isPunching = false
    self.isWalking = false
    self.isJumping = false
    self.isRolling = false

    self.currentFrame = 1
    self.frameTimer = 0
end

function Animation:endkick()
    self.iskicking = false
    self.currentFrame = 1
end

function Animation:startknee()
    self.isBigSlashing = false
    self.isHeavySlashing = false
    self.ishit1ing = false
    self.iskicking = false
    self.iskneeing = true
    self.isLowKicking = false
    self.isLowSlashing = false
    self.isPunching = false
    self.isWalking = false
    self.isJumping = false
    self.isRolling = false

    self.currentFrame = 1
    self.frameTimer = 0
end

function Animation:endknee()
    self.iskneeing = false
    self.currentFrame = 1
end

function Animation:startLowKick()
    self.isBigSlashing = false
    self.isHeavySlashing = false
    self.ishit1ing = false
    self.iskicking = false
    self.iskneeing = false
    self.isLowKicking = true
    self.isLowSlashing = false
    self.isPunching = false
    self.isWalking = false
    self.isJumping = false
    self.isRolling = false

    self.currentFrame = 1
    self.frameTimer = 0
end

function Animation:endLowKick()
    self.isLowKicking = false
    self.currentFrame = 1
end

function Animation:startLowSlash()
    self.isBigSlashing = false
    self.isHeavySlashing = false
    self.ishit1ing = false
    self.iskicking = false
    self.iskneeing = false
    self.isLowKicking = false
    self.isLowSlashing = true
    self.isPunching = false
    self.isWalking = false
    self.isJumping = false
    self.isRolling = false

    self.currentFrame = 1
    self.frameTimer = 0
end

function Animation:endLowSlash()
    self.isLowSlashing = false
    self.currentFrame = 1
end

function Animation:startBasSlash()
    self.isBasSlashing = true
    self.isBigSlashing = false
    self.isHeavySlashing = false
    self.ishit1ing = false
    self.iskicking = false
    self.iskneeing = false
    self.isLowKicking = false
    self.isLowSlashing = false
    self.isPunching = false
    self.isWalking = false
    self.isJumping = false
    self.isRolling = false

    self.currentFrame = 1
    self.frameTimer = 0
end

function Animation:endBasSlash()
    self.isBasSlashing = false
    self.currentFrame = 1
end

function Animation:startPunch()
    self.isBigSlashing = false
    self.isHeavySlashing = false
    self.ishit1ing = false
    self.iskicking = false
    self.iskneeing = false
    self.isLowKicking = false
    self.isLowSlashing = false
    self.isPunching = true
    self.isWalking = false
    self.isJumping = false
    self.isRolling = false

    self.currentFrame = 1
    self.frameTimer = 0
end

function Animation:endPunch()
    self.isPunching = false
    self.currentFrame = 1
end

function Animation:startShop()
    self.isBigSlashing = false
    self.isHeavySlashing = false
    self.ishit1ing = false
    self.iskicking = false
    self.iskneeing = false
    self.isLowKicking = false
    self.isLowSlashing = false
    self.isPunching = false
    self.isWalking = false
    self.isJumping = false
    self.isRolling = false
    self.isShoping = true


    self.currentFrame = 1
    self.frameTimer = 0
end

function Animation:endShop()
    self.isShoping = false
    self.currentFrame = 1
end

function Animation:startWalk(moveDir)
    local e = self.enemy
    if self.isJumping then return end -- pas d’anim de marche en l’air
    local isForward = ((e.side == "G" and moveDir == -1) or
                       (e.side == "D" and moveDir == 1))
    self.walkType = isForward and "forward" or "backward"

    if not self.isWalking then
        self.isWalking = true
        self.currentFrame = 1
        self.frameTimer = 0
    end
end

function Animation:stopWalk()
    self.isWalking = false
    if not self.isJumping then
        self.currentFrame = 1 -- revient sur pose
    end
end

function Animation:startJump()
    self.isWalking = false
    self.isJumping = true
    self.jumpPhase = "start"   -- start → air → land
    self.currentFrame = 1
    self.frameTimer = 0
end

function Animation:endJump()
    self.isJumping = false
    self.jumpPhase = "none"
    self.currentFrame = 1
end

function Animation:startbbh()
    self.isBBHing = true
    self.isBigSlashing = false
    self.isHeavySlashing = false
    self.ishit1ing = false
    self.iskicking = false
    self.iskneeing = false
    self.isLowKicking = false
    self.isLowSlashing = false
    self.isPunching = false
    self.isWalking = false
    self.isJumping = false
    self.isRolling = false
    self.isShoping = false


    self.currentFrame = 1
    self.frameTimer = 0
end

function Animation:endbbh()
    self.isBBHing = false
    self.state = false 
    self.currentFrame = 1
end

function Animation:startguv()
    self.isguving = true
    self.isBHHing = false
    self.isBigSlashing = false
    self.isHeavySlashing = false
    self.ishit1ing = false
    self.iskicking = false
    self.iskneeing = false
    self.isLowKicking = false
    self.isLowSlashing = false
    self.isPunching = false
    self.isWalking = false
    self.isJumping = false
    self.isRolling = false
    self.isShoping = false


    self.currentFrame = 1
    self.frameTimer = 0
end

function Animation:endguv()
    self.isguving = false
    self.currentFrame = 1
end

function Animation:startSR()
    self.isShopReactioning = true
    self.isguving = false
    self.isBHHing = false
    self.isBigSlashing = false
    self.isHeavySlashing = false
    self.ishit1ing = false
    self.iskicking = false
    self.iskneeing = false
    self.isLowKicking = false
    self.isLowSlashing = false
    self.isPunching = false
    self.isWalking = false
    self.isJumping = false
    self.isRolling = false
    self.isShoping = false


    self.currentFrame = 1
    self.frameTimer = 0
end

function Animation:endSR()
    self.isShopReactioning = false
    self.currentFrame = 1
end

function Animation:startbhh()
    self.isBHHing = true
    self.isBigSlashing = false
    self.isHeavySlashing = false
    self.ishit1ing = false
    self.iskicking = false
    self.iskneeing = false
    self.isLowKicking = false
    self.isLowSlashing = false
    self.isPunching = false
    self.isWalking = false
    self.isJumping = false
    self.isRolling = false
    self.isShoping = false


    self.currentFrame = 1
    self.frameTimer = 0
end

function Animation:endbhh()
    self.isBHHing = false
    self.state = false 
    self.currentFrame = 1
end

function Animation:startRoll(duration,backward)
    self.isRolling = true
    self.isWalking = false
    self.isJumping = false

    self.rollDuration = duration or 0.6  -- durée totale du roll
    self.frameTimer = 0
    self.currentFrame = 1
    self.rollFrameCount = 6
    self.rollBackward = backward or false 
end

function Animation:endRoll()
    self.isRolling = false
    self.currentFrame = 1
    self.rollTimer = 0
    self.rollDuration = 0
    self.currentFrame = 1
    self.enemy.isRolling = false
    self.enemy.rollDirection = 0
end

function Animation:update(dt)
    local e = self.enemy

    -- == Gestion shopReaction ==
    if self.isShopReactioning then
        self.frameTimer = self.frameTimer + dt

        local shopReaction = self.enemy.sprites.shopReaction[self.enemy.side]
        local frameTime = (self.enemy.shopReactionDuration / #shopReaction)

        local newFrame = math.floor(self.frameTimer / frameTime) + 1
        if newFrame ~= self.currentFrame and newFrame <= #shopReaction then
            self.currentFrame = newFrame
        end

        return
    end

    -- == Gestion guv ==
    if self.isguving then
        self.frameTimer = self.frameTimer + dt

        local guvFrames = self.enemy.sprites.guv[self.enemy.side]
        local frameTime = (self.enemy.guvDuration / #guvFrames)

        local newFrame = math.floor(self.frameTimer / frameTime) + 1
        if newFrame ~= self.currentFrame and newFrame <= #guvFrames then
            self.currentFrame = newFrame
        end

        return
    end

    -- == Gestion chute ==
    if e.thrown then
        self.frameTimer = self.frameTimer + dt

        local frames = e.sprites.fallLow[e.side]
        local frameTime = e.thrownDuration / #frames

        self.currentFrame = math.min(
            math.floor(self.frameTimer / frameTime) + 1,
            #frames
        )
        return
    end

    -- == Gestion bbh ==
    if self.isBBHing then
        self.frameTimer = self.frameTimer + dt

        local bbhFrames = self.enemy.sprites.bbhFrames[self.enemy.side]
        local frameTime = (self.enemy.bbhDuration / #bbhFrames)

        local newFrame = math.floor(self.frameTimer / frameTime) + 1
        if newFrame ~= self.currentFrame and newFrame <= #bbhFrames then
            self.currentFrame = newFrame
        end

        return
    end

    -- == Gestion bhh ==
    if self.isBHHing then
        self.frameTimer = self.frameTimer + dt

        local bhhFrames = self.enemy.sprites.bhhFrames[self.enemy.side]
        local frameTime = (self.enemy.bhhDuration / #bhhFrames)

        local newFrame = math.floor(self.frameTimer / frameTime) + 1
        if newFrame ~= self.currentFrame and newFrame <= #bhhFrames then
            self.currentFrame = newFrame
        end

        return
    end

    -- === Gestion big-slash ===
    if self.isBigSlashing then
        self.frameTimer = self.frameTimer + dt

        local bigSlashFrames = self.enemy.sprites.bigSlashFrames[self.enemy.side]
        local frameTime = (self.enemy.bigSlashDuration / #bigSlashFrames)

        local newFrame = math.floor(self.frameTimer / frameTime) + 1
        if newFrame ~= self.currentFrame and newFrame <= #bigSlashFrames then
            self.currentFrame = newFrame
        end

        return
    end

    -- === Gestion heavy-slash ===
    if self.isHeavySlashing then
        self.frameTimer = self.frameTimer + dt

        local heavySlashFrames = self.enemy.sprites.heavySlashFrames[self.enemy.side]
        local frameTime = (self.enemy.heavySlashDuration / #heavySlashFrames)

        local newFrame = math.floor(self.frameTimer / frameTime) + 1
        if newFrame ~= self.currentFrame and newFrame <= #heavySlashFrames then
            self.currentFrame = newFrame
        end

        return
    end

    -- === Gestion hit1 ===
    if self.ishit1ing then
        self.frameTimer = self.frameTimer + dt

        local hit1Frames = self.enemy.sprites.hit1Frames[self.enemy.side]
        local frameTime = (self.enemy.hit1Duration / #hit1Frames)

        local newFrame = math.floor(self.frameTimer / frameTime) + 1
        if newFrame ~= self.currentFrame and newFrame <= #hit1Frames then
            self.currentFrame = newFrame
        end

        return
    end

    -- === Gestion kick ===
    if self.iskicking then
        self.frameTimer = self.frameTimer + dt

        local kickFrames = self.enemy.sprites.kickFrames[self.enemy.side]
        local frameTime = (self.enemy.kickDuration / #kickFrames)

        local newFrame = math.floor(self.frameTimer / frameTime) + 1
        if newFrame ~= self.currentFrame and newFrame <= #kickFrames then
            self.currentFrame = newFrame
        end

        return
    end

    -- === Gestion knee ===
    if self.iskneeing then
        self.frameTimer = self.frameTimer + dt

        local kneeFrames = self.enemy.sprites.kneeFrames[self.enemy.side]
        local frameTime = (self.enemy.kneeDuration / #kneeFrames)

        local newFrame = math.floor(self.frameTimer / frameTime) + 1
        if newFrame ~= self.currentFrame and newFrame <= #kneeFrames then
            self.currentFrame = newFrame
        end

        return
    end

    -- === Gestion low-kick ===
    if self.isLowKicking then
        self.frameTimer = self.frameTimer + dt

        local lowKickFrames = self.enemy.sprites.lowKickFrames[self.enemy.side]
        local frameTime = (self.enemy.lowKickDuration / #lowKickFrames)

        local newFrame = math.floor(self.frameTimer / frameTime) + 1
        if newFrame ~= self.currentFrame and newFrame <= #lowKickFrames then
            self.currentFrame = newFrame
        end

        return
    end

    -- === Gestion low-slash ===
    if self.isLowSlashing then
        self.frameTimer = self.frameTimer + dt

        local lowSlashFrames = self.enemy.sprites.lowSlashFrames[self.enemy.side]
        local frameTime = (self.enemy.lowSlashDuration / #lowSlashFrames)

        local newFrame = math.floor(self.frameTimer / frameTime) + 1
        if newFrame ~= self.currentFrame and newFrame <= #lowSlashFrames then
            self.currentFrame = newFrame
        end

        return
    end

    -- === Gestion bas-slash ===
    if self.isBasSlashing then
        self.frameTimer = self.frameTimer + dt

        local basSlashFrames = self.enemy.sprites.basSlashFrames[self.enemy.side]
        local frameTime = (self.enemy.basSlashDuration / #basSlashFrames)

        local newFrame = math.floor(self.frameTimer / frameTime) + 1
        if newFrame ~= self.currentFrame and newFrame <= #basSlashFrames then
            self.currentFrame = newFrame
        end

        return
    end

    -- === Gestion punch ===
    if self.isPunching then
        self.frameTimer = self.frameTimer + dt

        local punchFrames = self.enemy.sprites.punchFrames[self.enemy.side]
        local frameTime = (self.enemy.punchDuration / #punchFrames)

        local newFrame = math.floor(self.frameTimer / frameTime) + 1
        if newFrame ~= self.currentFrame and newFrame <= #punchFrames then
            self.currentFrame = newFrame
        end

        return
    end

    -- === Gestion shop ===
    if self.isShoping then
        self.frameTimer = self.frameTimer + dt

        local shopFrames = self.enemy.sprites.shopFrames[self.enemy.side]
        local frameTime = (self.enemy.shopDuration / #shopFrames)

        local newFrame = math.floor(self.frameTimer / frameTime) + 1
        if newFrame ~= self.currentFrame and newFrame <= #shopFrames then
            self.currentFrame = newFrame
        end

        return
    end

    -- === Gestion saut ===
    if self.isJumping then
        if self.jumpPhase == "start" then
            -- saute 1 -> saute 2 rapidement
            self.frameTimer = self.frameTimer + dt
            if self.frameTimer > 0.1 then
                self.currentFrame = 2
                self.jumpPhase = "air"
            end

        elseif self.jumpPhase == "air" then
            -- reste en saut3 tant qu’en l’air
            if e.yVelocity > 0 then -- commence à descendre
                self.currentFrame = 3
            else
                self.currentFrame = 2
            end

        elseif self.jumpPhase == "land" then
            -- descente : saut2 puis saut1
            self.currentFrame = self.currentFrame - 1
            if self.currentFrame <= 1 then
                self:endJump()
            end
        end
        return
    end

    if self.isRolling then
        self.frameTimer = self.frameTimer + dt

        -- temps par frame = durée totale / nb de frames
        local frameTime = self.rollDuration / self.rollFrameCount

        -- calculer frame courante
        local newFrame = math.floor(self.frameTimer / frameTime) + 1
        if newFrame ~= self.currentFrame and newFrame <= self.rollFrameCount then
            self.currentFrame = newFrame
        end

        -- roll terminé ?
        if self.frameTimer >= self.rollDuration then
            self:endRoll()
        end

        return
    end

    -- Conditions pour avancer les frames
    if not self.isWalking or e.isBlocked or not e.isOnGround or e.isRolling then
        return
    end

    self.frameTimer = self.frameTimer + dt
    if self.frameTimer >= self.frameDuration then
        self.frameTimer = self.frameTimer - self.frameDuration

        -- Sélectionne le set de frames correct
        local frames = (self.walkType == "forward")
            and e.walkForwardFrames[e.side]
            or e.walkBackwardFrames[e.side]

        self.currentFrame = self.currentFrame + 1
        if self.currentFrame > #frames then
            self.currentFrame = 1
        end
    end
end

return Animation
