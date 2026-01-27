local Camera = {}
Camera.__index = Camera

function Camera:new()
    return setmetatable({
        shakeTime = 0,
        shakeDuration = 0,
        shakeIntensity = 0,
        offsetX = 0,
        offsetY = 0
    }, Camera)
end

function Camera:shake(duration, intensity)
    self.shakeDuration = duration
    self.shakeTime = duration
    self.shakeIntensity = intensity
end

function Camera:update(dt)
    if self.shakeTime > 0 then
        self.shakeTime = self.shakeTime - dt

        local strength = self.shakeIntensity * (self.shakeTime / self.shakeDuration)
        self.offsetX = love.math.random(-strength, strength)
        self.offsetY = love.math.random(-strength, strength)
    else
        self.offsetX = 0
        self.offsetY = 0
    end
end

function Camera:apply()
    love.graphics.push()
    love.graphics.translate(self.offsetX, self.offsetY)
end

function Camera:clear()
    love.graphics.pop()
end

return Camera
