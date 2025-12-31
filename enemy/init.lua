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

    self.isCrouching = false

    -- état du shop-reaction
    self.isShopReactioning = false
    self.shopReactionTimer = 0
    self.shopReactionDuration = 1.2 -- durée totale du shop (à ajuster)

    -- blockage
    self.isBlocking = false
    self.blockTimer = 0
    self.blockDuration = 0.35
    self.wantBlock = nil
    self.blockType = nil

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

    -- état du bas-slash
    self.isBasSlashing = false
    self.basSlashTimer = 0
    self.basSlashDuration = 0.35 -- durée totale du bas-slash (à ajuster)

    -- état du shop
    self.isShoping = false
    self.shopTimer = 0
    self.shopDuration = 0.7 -- durée totale du punch (à ajuster)

    -- état du punch
    self.isPunching = false
    self.punchTimer = 0
    self.punchDuration = 0.35 -- durée totale du punch (à ajuster)

    -- état de low-slash
    self.isLowSlashing = false
    self.lowSlashTimer = 0
    self.lowSlashDuration = 0.35 -- durée totale du low-slash (à ajuster)

    -- état de low-kick
    self.isLowKicking = false
    self.lowKickTimer = 0
    self.lowKickDuration = 0.35 -- durée totale du low-kick (à ajuster)

    -- état de knee
    self.iskneeing = false
    self.kneeTimer = 0
    self.kneeDuration = 0.35 -- durée totale du knee (à ajuster)

    -- état de kick
    self.iskicking = false
    self.kickTimer = 0
    self.kickDuration = 0.5 -- durée totale du kick (à ajuster)

    -- état de hit1
    self.ishit1ing = false
    self.hit1Timer = 0
    self.hit1Duration = 0.35 -- durée totale du hit1 (à ajuster)

    -- état de heavy-slash
    self.isHeavySlashing = false
    self.heavySlashTimer = 0
    self.heavySlashDuration = 0.4 -- durée totale du heavy-slash (à ajuster)

    -- état de big-slash
    self.isBigSlashing = false
    self.bigSlashTimer = 0
    self.bigSlashDuration = 0.7 -- durée totale du big-slash (à ajuster)

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
    self.hitJustReceived = false

    self.isStunned = false
    self.directionatk = "idle"
    self.state = false
    self.isBBHing = false
    self.isBHHing = false
    -- self.hitTimer = 0
    -- self.hitDuration = 0.2  -- durée de l’animation du coup reçu
    self.bbhTimer = 0
    self.bbhDuration = 0.2  -- durée de l’animation du coup reçu
    self.bhhTimer = 0
    self.bhhDuration = 0.2  -- durée de l’animation du coup reçu

    -- Envoyer dans le decore
    self.fall = false
    self.thrown = false
    self.thrownTimer = 0
    self.thrownDuration = 0.8
    self.compteHit = 0
    self.limiteHit = 4
    self.hitLock = false  

    self.throwVelocity = 0
    self.throwDirection = 0

    self.target = target 

    -- état de get-up-v
    self.isGettingUp = false
    self.guvTimer = 0
    self.guvDuration = 0.2 -- durée totale du big-slash (à ajuster)

    -- Sous-modules
    self.movement = Movement.new(self,target)
    self.animation = Animation.new(self)
    self.sprites = Sprites.new(self)
    self.collision = Collision.new(self)

    self:loadWalkSprites()
    -- self:loadJumpSprites() 

    return self
end

function Enemy:getAttackHitbox()
     -- On vérifie que l'animation est en bas slash ET sur la frame souhaitée
    local anim = self.animation

    if anim.isBasSlashing then
        strick = false
        if anim.currentFrame == 3 then
            strick = true
        end
        local w = 60   -- largeur du coup
        local h = 30   -- hauteur du coup
        local x, y = self.x, self.y + self.height - h

        if self.side == "D" then
            x = x + self.width
        else
            x = x - w
        end

        return { x = x, y = y, width = w, height = h, type = "hitBas", strick = strick }
    elseif anim.isLowSlashing then
        strick = false
        if anim.currentFrame == 2 then
            strick = true
        end
        local w = 25   -- largeur du coup
        local h = 30   -- hauteur du coup
        local x, y = self.x, self.y + self.height - h

        if self.side == "D" then
            x = x + self.width
        else
            x = x - w
        end

        return { x = x, y = y, width = w, height = h, type = "hitBas", strick = strick }
    elseif anim.isLowKicking then
        strick = false
        if anim.currentFrame == 2 then
            strick = true
        end
        local w = 30   -- largeur du coup
        local h = 30   -- hauteur du coup
        local x, y = self.x, self.y + self.height - h

        if self.side == "D" then
            x = x + self.width
        else
            x = x - w
        end

        return { x = x, y = y, width = w, height = h, type = "hitBas", strick = strick }
    elseif anim.ishit1ing then
        strick = false
        if anim.currentFrame == 2 then
            strick = true
        end
        local w = 20   -- largeur du coup
        local h = 30   -- hauteur du coup
        local x, y = self.x, self.y + self.height - h

        if self.side == "D" then
            x = x + self.width
        else
            x = x - w
        end

        return { x = x, y = y, width = w, height = h, type = "hitHaut", strick = strick }
    elseif anim.iskicking then
        strick = false
        if anim.currentFrame == 2 then
            strick = true
        end
        local w = 60   -- largeur du coup
        local h = 30   -- hauteur du coup
        local x, y = self.x, self.y + self.height - h

        if self.side == "D" then
            x = x + self.width
        else
            x = x - w
        end

        return { x = x, y = y, width = w, height = h, type = "hitHaut", strick = strick }
    elseif anim.isHeavySlashing then
        strick = false
        if anim.currentFrame == 3 then
            strick = true
        end
        local w = 60   -- largeur du coup
        local h = 30   -- hauteur du coup
        local x, y = self.x, self.y + self.height - h

        if self.side == "D" then
            x = x + self.width
        else
            x = x - w
        end

        return { x = x, y = y, width = w, height = h, type = "hitHaut", strick = strick }
    elseif anim.iskneeing then
        strick = false
        if anim.currentFrame == 2 then
            strick = true
        end
        local w = 20   -- largeur du coup
        local h = 30   -- hauteur du coup
        local x, y = self.x, self.y + self.height - h

        if self.side == "D" then
            x = x + self.width
        else
            x = x - w
        end

        return { x = x, y = y, width = w, height = h, type = "hitHaut", strick = strick }
    elseif anim.isBigSlashing then
        strick = false
        if anim.currentFrame == 4 or anim.currentFrame == 5 then
            strick = true
        end
        local w = 60   -- largeur du coup
        local h = 30   -- hauteur du coup
        local x, y = self.x, self.y + self.height - h

        if self.side == "D" then
            x = x + self.width
        else
            x = x - w
        end

        return { x = x, y = y, width = w, height = h, type = "hitHaut", strick = strick }
    elseif anim.isPunching then
        strick = false
        if anim.currentFrame == 2 then
            strick = true
        end
        local w = 20   -- largeur du coup
        local h = 30   -- hauteur du coup
        local x, y = self.x, self.y + self.height - h

        if self.side == "D" then
            x = x + self.width
        else
            x = x - w
        end

        return { x = x, y = y, width = w, height = h, type = "hitHaut", strick = strick }
    end

    return nil
end

function Enemy:isBusy()
    return self.isPunching or self.isLowSlashing or self.isLowKicking or
           self.iskneeing or self.iskicking or self.ishit1ing or
           self.isHeavySlashing or self.isBigSlashing or
           self.isBasSlashing or self.isShoping or self.state or self.isStunned
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
