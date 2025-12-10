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

    local isForward = ((e.side == "D" and moveDir == 1) or
                       (e.side == "G" and moveDir == -1))

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
    self.enemy.isRolling = false
    self.enemy.rollDirection = 0
end

function Animation:update(dt)
    local e = self.enemy

    -- === Gestion big-slash ===
    
end

return Animation
