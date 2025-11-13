-- player/animation.lua
local Animation = {}
Animation.__index = Animation

function Animation.new(player)
    local self = setmetatable({}, Animation)
    self.player = player
    self.currentFrame = 1
    self.frameTimer = 0
    self.frameDuration = 0.08
    self.isWalking = false
    self.isJumping = false
    self.walkType = "forward" -- "forward" ou "backward"
    self.jumpPhase = "none"   -- "start", "air", "land"
    return self
end

function Animation:startWalk(moveDir)
    local p = self.player
    if self.isJumping then return end -- pas d’anim de marche en l’air

    local isForward = ((p.side == "D" and moveDir == 1) or
                       (p.side == "G" and moveDir == -1))

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
    self.player.isRolling = false
    self.player.rollDirection = 0
end

function Animation:update(dt)
    local p = self.player

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
            if p.yVelocity > 0 then -- commence à descendre
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
    if not self.isWalking or p.isBlocked or not p.isOnGround or p.isRolling then
        return
    end

    self.frameTimer = self.frameTimer + dt
    if self.frameTimer >= self.frameDuration then
        self.frameTimer = self.frameTimer - self.frameDuration

        -- Sélectionne le set de frames correct
        local frames = (self.walkType == "forward")
            and p.walkForwardFrames[p.side]
            or p.walkBackwardFrames[p.side]

        self.currentFrame = self.currentFrame + 1
        if self.currentFrame > #frames then
            self.currentFrame = 1
        end
    end
end

return Animation
