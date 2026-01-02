local SandFX = {}
SandFX.__index = SandFX

function SandFX:new(frames, x, y)
    return setmetatable({
        frames = frames,
        x = x,
        y = y,
        currentFrame = 1,
        timer = 0,
        frameDuration = 0.06,
        finished = false
    }, SandFX)
end

function SandFX:update(dt)
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

function SandFX:draw()
    if self.finished then return end

    local img = self.frames[self.currentFrame]
    local w, h = img:getWidth(), img:getHeight()
    local scale = 0.2

    love.graphics.draw(
        img,
        self.x,
        self.y,
        0,
        scale,
        scale,
        w / 2,
        h
    )
end

return SandFX
