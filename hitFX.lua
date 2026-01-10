local HitFX = {}
HitFX.__index = HitFX

function HitFX:new(frames, x, y, scale, frameDuration)
    return setmetatable({
        frames = frames,
        x = x,
        y = y,
        currentFrame = 1,
        timer = 0,
        frameDuration = frameDuration,
        finished = false,
        scale = scale
    }, HitFX)
end

function HitFX:update(dt)
    if self.finished then return end

    self.timer = self.timer + dt
    if self.timer >= self.frameDuration then
        self.timer = self.timer - self.frameDuration
        self.currentFrame = self.currentFrame + 1

        if self.currentFrame > #self.frames then
            self.finished = true
        end
    end
end

function HitFX:draw()
    if self.finished then return end

    local img = self.frames[self.currentFrame]
    local w, h = img:getWidth(), img:getHeight()
    -- local scale = 0.5

    love.graphics.draw(
        img,
        self.x,
        self.y,
        0,
        self.scale,
        self.scale,
        w / 2,
        h
    )
end

return HitFX
