-- player/init.lua
local Movement = require("player.movement")
local Animation = require("player.animation")
local Sprites = require("player.sprites")
local Collision = require("player.collision")

local Player = {}
Player.__index = Player

function Player.new(x, y)
    local self = setmetatable({}, Player)

    -- Récupérer dimensions actuelles de l’écran
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    -- Définir une résolution de référence (par ex. Full HD)
    local refWidth = 1920
    local refHeight = 1080

    -- Facteurs d’échelle
    local scaleX = screenWidth / refWidth
    local scaleY = screenHeight / refHeight
    local scale = math.min(scaleX, scaleY) -- garder proportions correctes

    -- Focus (touche F)
    self.isFocusing = false
    self.focusColor = {1, 0, 0} -- couleur actuelle (rouge par défaut)
    self.focusTransition = 0    -- timer violet → bleu
    self.focusTransitionDuration = 0.2

    -- Roulade
    self.isRolling = false
    self.rollDirection = 0
    self.rollTimer = 0
    self.rollDuration = 0.25       -- durée en secondes
    self.rollSpeed = 800 * scale   -- vitesse de roulade
    self.lastKeyPressed = { left = 0, right = 0 }
    self.doubleTapTime = 0.3       -- fenêtre max entre deux appuis rapides

    -- marche
    self.isWalking = false
    self.currentFrame = 1
    self.frameTimer = 0
    self.frameDuration = 0.08
    self.walkDirection = 1 -- -1 gauche, 1 droite

    -- Dimensions du joueur adaptées
    self.width = 100 * scale
    self.height = 200 * scale

    -- Stocker les dimensions normales pour crouch
    self.normalHeight = self.height
    self.normalWidth = self.width

    -- Dimensions accroupi
    self.crouchWidth = self.normalWidth
    self.crouchHeight = self.normalHeight / 2

    self.isCrouching = false

    -- Définir la position du sol (milieu vertical de la fenêtre)
    self.groundY = screenHeight / 2

    -- Position initiale
    self.x = x
    self.y = self.groundY - self.normalHeight  


    -- Vitesse adaptée
    self.speed = 400 * scale

    -- Saut adapté
    self.yVelocity = 0
    self.jumpStrength = 1000 * scale
    self.gravity = 2000 * scale

    self.isOnGround = true

    self.side = "G" -- orientation par défaut (G = gauche, D = droite)

    -- Sous-modules
    self.movement = Movement.new(self)
    self.animation = Animation.new(self)
    self.sprites = Sprites.new(self)
    self.collision = Collision.new(self)

    self:loadWalkSprites()
    self:loadJumpSprites() 

    return self
end

function Player:update(dt, other)
    self.movement:update(dt)
    self.animation:update(dt)
    self.collision:handle(other, dt)
    self.sprites.otherPlayer = other
end

function Player:draw()
    self.sprites:draw()
end

function Player:updateOrientation(other)
    if other.x < self.x then
        self.side = "G"
    else
        self.side = "D"
    end
end

function Player:keypressed(key)
    -- Ici tu délègues par ex. au mouvement ou à un moveset
    self.movement:keypressed(key)
end

-- Vérifie si le joueur touche le bord gauche de l'écran
function Player:isAtLeftEdge()
    return self.x <= 0
end

-- Vérifie si le joueur touche le bord droit de l'écran
function Player:isAtRightEdge()
    return self.x + self.width >= love.graphics.getWidth()
end

-- Remet le joueur debout s'il est accroupi
function Player:standUp()
    if self.isCrouching then
        self.isCrouching = false
        self.height = self.normalHeight or 200
        self.width = self.normalWidth or 100
        self.y = self.groundY - self.height
    end
end

function Player:loadWalkSprites()
    self.walkForwardFrames = { G = {}, D = {} }
    self.walkBackwardFrames = { G = {}, D = {} }

    local forwardOrder = {1,2,3,4,5,6,7,8,9,10,11,12,13}
    local backwardOrder = {5,4,3,2,1,12,13,11,10,9,8,7,6}

    for _, side in ipairs({"G","D"}) do
        for i, idx in ipairs(forwardOrder) do
            self.walkForwardFrames[side][i] = love.graphics.newImage("images/perso_images/pas/pas" .. idx .. "-" .. side .. ".png")
        end
        for i, idx in ipairs(backwardOrder) do
            self.walkBackwardFrames[side][i] = love.graphics.newImage("images/perso_images/pas/pas" .. idx .. "-" .. side .. ".png")
        end
    end
end

function Player:loadJumpSprites()
    self.jumpFrames = { G = {}, D = {} }

    for _, side in ipairs({"G", "D"}) do
        self.jumpFrames[side][1] = love.graphics.newImage("images/perso_images/saut/saut1-" .. side .. ".png")
        self.jumpFrames[side][2] = love.graphics.newImage("images/perso_images/saut/saut2-" .. side .. ".png")
        self.jumpFrames[side][3] = love.graphics.newImage("images/perso_images/saut/saut3-" .. side .. ".png")
    end
end

return Player
