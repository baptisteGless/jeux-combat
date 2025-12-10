local Movement = require("enemy.movement")
local Animation = require("enemy.animation")
local Sprites = require("enemy.sprites")
local Collision = require("enemy.collision")

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

    self.isEnemy = true -- pour différencier les mouvement du joueur et de l'énemie

    -- Sous-modules
    self.movement = Movement.new(self)
    self.animation = Animation.new(self)
    self.sprites = Sprites.new(self)
    self.collision = Collision.new(self)

    return self
end

function Enemy:update(dt,other)
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

return Enemy
