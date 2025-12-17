local Movement = require("enemy.movement")
local Animation = require("enemy.animation")
local Sprites = require("enemy.sprites")
local Collision = require("enemy.collision")
local AI = require("enemy.ai")

local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(x, y, target)
    local self = setmetatable({}, Enemy)

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

     -- Roulade
    self.rollRequested = false
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

    self.ai = AI.new(self, target)

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
    self.speed = 300 * scale

    -- Saut adapté
    self.yVelocity = 0
    self.jumpStrength = 1000 * scale
    self.gravity = 2000 * scale

    self.isOnGround = true

    self.side = "G" -- orientation par défaut (G = gauche, D = droite)

    self.isEnemy = true -- pour différencier les mouvement du joueur et de l'énemie

    
    self.state = "idle"      -- peut être "idle", "hitBas"
    self.hitTimer = 0
    self.hitDuration = 0.25  -- durée de l’animation du coup reçu

    -- Sous-modules
    self.movement = Movement.new(self)
    self.animation = Animation.new(self)
    self.sprites = Sprites.new(self)
    self.collision = Collision.new(self)

    self:loadWalkSprites()
    -- self:loadJumpSprites() 

    return self
end

function Enemy:isBusy()
    return self.state ~= "idle"
end

function Enemy:update(dt,other)
    self.ai:update(dt)
    self.movement:update(dt)
    self.animation:update(dt)
    self.collision:handle(other, dt)
end

function Enemy:draw()
    self.sprites:draw()
end

function Enemy:updateOrientation(other)
    if other.x < self.x then
        self.side = "G"
    else
        self.side = "D"
    end
end

-- Vérifie si le joueur touche le bord gauche de l'écran
function Enemy:isAtLeftEdge()
    return self.x <= 0
end

-- Vérifie si le joueur touche le bord droit de l'écran
function Enemy:isAtRightEdge()
    return self.x + self.width >= love.graphics.getWidth()
end

-- Retourne scaleX et scaleY pour que l'image ait la hauteur 'targetHeight'
local function getImageScaleForHeight(image, targetHeight)
    local imgWidth = image:getWidth()
    local imgHeight = image:getHeight()
    local scaleY = targetHeight / imgHeight
    local scaleX = scaleY -- garde les proportions
    return scaleX, scaleY
end

function Enemy:loadWalkSprites()
    self.walkForwardFrames = { G = {}, D = {} }
    self.walkBackwardFrames = { G = {}, D = {} }

    local forwardOrder = {1,2,3,4,5,6,7,8,9,10,11,12,13}
    local backwardOrder = {5,4,3,2,1,12,13,11,10,9,8,7,6}

    local targetHeight = self.height -- hauteur à respecter pour toutes les images

    for _, side in ipairs({"G","D"}) do
        for i, idx in ipairs(forwardOrder) do
            local img = love.graphics.newImage("images/perso_images/pas/pas" .. idx .. "-" .. side .. ".png")
            local scaleX, scaleY = getImageScaleForHeight(img, targetHeight)
            self.walkForwardFrames[side][i] = {img = img, scaleX = scaleX, scaleY = scaleY}
        end
        for i, idx in ipairs(backwardOrder) do
            local img = love.graphics.newImage("images/perso_images/pas/pas" .. idx .. "-" .. side .. ".png")
            local scaleX, scaleY = getImageScaleForHeight(img, targetHeight)
            self.walkBackwardFrames[side][i] = {img = img, scaleX = scaleX, scaleY = scaleY}
        end
    end
end

return Enemy
