-- player/init.lua
local Movement = require("player.movement")
local Animation = require("player.animation")
local Sprites = require("player.sprites")
local Collision = require("player.collision")

local Player = {}
Player.__index = Player

function Player.new(x, y,typeGame)
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

    self.side = "D" -- orientation par défaut (G = gauche, D = droite)

    -- Table de combos
    self.comboDefinitions = {
        {sequence = {"h","g","g","g","y"}, moves = {"lowKick","punch","lowSlash","punch","bigSlash"}},
        {sequence = {"h","g","g","g"}, moves = {"lowKick","punch","lowSlash","punch"}},
        {sequence = {"h","g","g"}, moves = {"lowKick","punch","lowSlash"}},
        {sequence = {"h","h","g","g","g","y"}, moves = {"lowKick","knee","punch","lowSlash","punch","bigSlash"}},
        {sequence = {"h","h","g","g","g"}, moves = {"lowKick","knee","punch","lowSlash","punch"}},
        {sequence = {"h","h","g","g"}, moves = {"lowKick","knee","punch","lowSlash"}},
        {sequence = {"g","h","h"}, moves = {"punch","lowKick","knee"}},
        {sequence = {"g","h","h","y"}, moves = {"punch","lowKick","knee","heavySlash"}},
        {sequence = {"g","g","h","h"}, moves = {"punch","lowSlash","lowKick","knee"}},
        {sequence = {"g","g","h","h","y"}, moves = {"punch","lowSlash","lowKick","knee","heavySlash"}},
        {sequence = {"g","g","g","h","h"}, moves = {"punch","lowSlash","punch","lowKick","knee"}},
        {sequence = {"g","g","g","h","h","y"}, moves = {"punch","lowSlash","punch","lowKick","knee","heavySlash"}},
        {sequence = {"g","g","g","y"}, moves = {"punch","lowSlash","punch","bigSlash"}},
        {sequence = {"g","g","g"}, moves = {"punch","lowSlash","punch"}},
        {sequence = {"g","g"}, moves = {"punch","lowSlash"}},
        {sequence = {"h","h","y"}, moves = {"lowKick","knee","heavySlash"}},
        {sequence = {"h","h"}, moves = {"lowKick","knee"}},
        {sequence = {"g","y"}, moves = {"punch","hit1"}},
        {sequence = {"y"}, moves = {"kick"}},
        {sequence = {"h"}, moves = {"lowKick"}},
        {sequence = {"g"}, moves = {"punch"}},
    }

    -- file d'exécution des moves (queued moves quand on est busy)
    self.moveQueue = {}

    self.moveQueueMax = 1  -- par exemple : max 3 moves en queue

    -- Input buffer pour les touches
    self.inputBuffer = {}         -- stocke les touches pressées
    self.inputBufferTimer = 0     -- timer pour effacer le buffer
    self.inputBufferMax = 1     -- max 0.4 secondes entre les touches
    self.bufferedCombo = nil      -- combo prêt à être lancé
    self.comboStep = 1            -- étape dans le combo en cours

    -- état du bas-slash
    self.isBasSlashing = false
    self.basSlashTimer = 0
    self.basSlashDuration = 0.35 -- durée totale du bas-slash (à ajuster)

    -- état du shop-success
    self.isShopSuccessing = false
    self.shopSuccessTimer = 0
    self.shopSuccessDuration = 1.2 -- durée totale du shop (à ajuster)

    -- état du shop-fail
    self.isShopFailing = false
    self.shopFailTimer = 0
    self.shopFailDuration = 0.2 -- durée totale du shop (à ajuster)

    -- état du shop
    self.shopWillSucceed = false
    self.isShoping = false
    self.shopTimer = 0
    self.shopDuration = 0.5 -- durée totale du shop (à ajuster)

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

    -- état de hit
    self.isBBHing = false
    self.isBHHing = false
    self.directionatk = "idle"
    self.state = false      -- peut être "idle", "hitBas"
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

    -- état de get-up-v
    self.isGettingUp = false
    self.guvTimer = 0
    self.guvDuration = 0.2 -- durée totale du big-slash (à ajuster)

    -- effet sable et effet hity
    self.hitImpactDone = false
    self.sandImpactDone = false
    self.fx = {
        sandList = {},
        hitList = {}
    }

    -- Sous-modules
    self.movement = Movement.new(self)
    self.animation = Animation.new(self)
    self.sprites = Sprites.new(self)
    self.collision = Collision.new(self)

    -- Parry
    self.parryWindow = 0
    self.parryDuration = 0.5

    -- camera
    self.camShake = false

    -- healthbar
    -- addDebugLog("typeGame=" .. tostring(typeGame))
    self.maxHp = 100
    if typeGame == "history" then
        self.maxHp = 100
    elseif typeGame == "survive" then
        self.maxHp = 150
    end
    self.hp = self.maxHp
    self.isKO = false
    self.gameOver = false

    self:loadWalkSprites()
    self:loadJumpSprites() 

    return self
end

function Player:takeDamage(amount, hitType)
    if self.hp <= 0 then return end

    self.hp = math.max(0, self.hp - amount)
    self.hitImpactDone = false
    self.lastHitType = hitType
    if self.hp == 0 and not self.isKO then
        self.isKO = true
        self.fall = true
        self.state = true
    end
end

function Player:spawnHitFX(type)
    local fx = self.fx
    if not fx or not fx.HitFX then return end

    local side = self.side or "G"

    local framesboom = fx.hitFrames[side]
    if not framesboom then return end

    local framesfall = fx.hitFramesfall[side]
    if not framesfall then return end

    local framessparkle = fx.sparkleFrames[side]
    if not framessparkle then return end

    local scale = 0.5

    -- position de base
    local baseX = self.x + self.width / 2
    local y = self.y

    if type == 1 then
        y  = self.y + self.height * 0.85
        if side == "G" then
            baseX = baseX + 10
        else
            baseX = baseX - 10
        end
        frames = framesboom
        scale = 0.5
        frameDuration = 0.05
    elseif type == 2 then
        y  = self.y + self.height * 0.85
        if side == "G" then
            baseX = baseX + 10
        else
            baseX = baseX - 10
        end
        frames = framesboom
        scale = 0.5
        frameDuration = 0.05
    elseif type == 3 then
        y  = self.y + self.height * 0.95
        frames = framesboom
        scale = 0.5
        frameDuration = 0.05
    elseif type == 4 then
        y  = self.y + self.height * 0.5
        if side == "G" then
            baseX = baseX + 10
        else
            baseX = baseX - 10
        end
        frames = framesboom
        scale = 0.5
        frameDuration = 0.05
    elseif type == 5 then
        y  = self.y + self.height * 0.95
        frames = framesboom
        scale = 0.5
        frameDuration = 0.05
    elseif type == 6 then
        y  = self.y + self.height * 0.3
        frames = framesfall
        if side == "G" then
            baseX = baseX + 30
        else
            baseX = baseX - 30
        end
        scale = 0.2
        frameDuration = 0.08
    elseif type == 7 then
        y  = self.y + self.height * 0.45
        if side == "G" then
            baseX = baseX + 10
        else
            baseX = baseX - 10
        end
        frames = framesboom
        scale = 0.5
        frameDuration = 0.05
    elseif type == 8 then
        y  = self.y + self.height * 0.3
        if side == "G" then
            baseX = baseX + 15
            framesfall = fx.hitFramesfall["D"]
        else
            baseX = baseX - 15
            framesfall = fx.hitFramesfall["G"]
        end
        frames = framesfall
        scale = 0.2
        frameDuration = 0.08
    elseif type == 9 then
        y  = self.y + self.height * 0.35
        if side == "G" then
            baseX = baseX + 10
        else
            baseX = baseX - 10
        end
        frames = framesboom
        scale = 0.5
        frameDuration = 0.05
    elseif type == 10 then
        y  = self.y + self.height * 0.35
        if side == "G" then
            baseX = baseX + 50
        else
            baseX = baseX - 50
        end
        frames = framesfall
        scale = 0.2
        frameDuration = 0.08
    elseif type == 11 then
        y  = self.y + self.height * 0.35
        if side == "G" then
            baseX = baseX - 20
        else
            baseX = baseX + 20
        end
        frames = framessparkle
        scale = 0.5
        frameDuration = 0.02
    elseif type == 12 then
        y  = self.y + self.height * 0.75
        if side == "G" then
            baseX = baseX - 20
        else
            baseX = baseX + 20
        end
        frames = framessparkle
        scale = 0.5
        frameDuration = 0.02
    end

    table.insert(
        fx.hitList,
        fx.HitFX:new(frames, baseX, y, scale, frameDuration)
    )
end

function Player:getAttackHitbox()
     -- On vérifie que l'animation est en bas slash ET sur la frame souhaitée
    local anim = self.animation

    if self.isBasSlashing then
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

        return { x = x, y = y, width = w, height = h, type = "hitBas", strick = strick, fall = false, hitType = 1 }
    elseif self.isLowSlashing then
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

        return { x = x, y = y, width = w, height = h, type = "hitBas", strick = strick, fall = false, hitType = 2 }
    elseif self.isLowKicking then
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

        return { x = x, y = y, width = w, height = h, type = "hitBas", strick = strick, fall = false, hitType = 3 }
    elseif self.ishit1ing then
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

        return { x = x, y = y, width = w, height = h, type = "hitHaut", strick = strick, fall = false, hitType = 4 }
    elseif self.iskicking then
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

        return { x = x, y = y, width = w, height = h, type = "hitHaut", strick = strick, fall = false, hitType = 5 }
    elseif self.isHeavySlashing then
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

        return { x = x, y = y, width = w, height = h, type = "hitHaut", strick = strick, fall = true, hitType = 6 }
    elseif self.iskneeing then
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

        return { x = x, y = y, width = w, height = h, type = "hitHaut", strick = strick, fall = false, hitType = 7 }
    elseif self.isBigSlashing then
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

        return { x = x, y = y, width = w, height = h, type = "hitHaut", strick = strick, fall = true, hitType = 8 }
    elseif self.isPunching then
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

        return { x = x, y = y, width = w, height = h, type = "hitHaut", strick = strick, fall = false, hitType = 9 }   
    end

    return nil
end

function Player:isBusy()
    return self.isPunching or self.isLowSlashing or self.isLowKicking or
           self.iskneeing or self.iskicking or self.ishit1ing or
           self.isHeavySlashing or self.isBigSlashing or
           self.isBasSlashing or self.isShoping or self.isShopSuccessing or self.isShopFailing
end

function Player:update(dt, other)
    self.movement:update(dt)
    self.animation:update(dt)
    self.collision:handle(other, dt)
    self.sprites.otherPlayer = other

    local attackActive = self:isBusy()
    for i = #self.fx.sandList, 1, -1 do
        local fx = self.fx.sandList[i]
        fx:update(dt)
        if fx.finished then
            table.remove(self.fx.sandList, i)
        end
    end
    for i = #self.fx.hitList, 1, -1 do
        local fx = self.fx.hitList[i]
        fx:update(dt)
        if fx.finished then
            table.remove(self.fx.hitList, i)
        end
    end
end

function Player:draw()
    self.sprites:draw()
    for _, fx in ipairs(self.fx.sandList) do
        fx:draw()
    end
    for _, fx in ipairs(self.fx.hitList) do
        fx:draw()
    end
end

function Player:updateOrientation(other, dt, mode)
    local aimX
    if mode == "survive" then
        if love.keyboard.isDown("left") then
            self.side = "G"
        elseif love.keyboard.isDown("right") then 
            self.side = "D"
        end
    elseif mode == "history" then
        if other.x < self.x then
            self.side = "G"
        else
            self.side = "D"
        end
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

-- Retourne scaleX et scaleY pour que l'image ait la hauteur 'targetHeight'
local function getImageScaleForHeight(image, targetHeight)
    local imgWidth = image:getWidth()
    local imgHeight = image:getHeight()
    local scaleY = targetHeight / imgHeight
    local scaleX = scaleY -- garde les proportions
    return scaleX, scaleY
end

function Player:loadWalkSprites()
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


function Player:loadJumpSprites()
    self.jumpFrames = { G = {}, D = {} }

    for _, side in ipairs({"G", "D"}) do
        self.jumpFrames[side][1] = love.graphics.newImage("images/perso_images/saut/saut1-" .. side .. ".png")
        self.jumpFrames[side][2] = love.graphics.newImage("images/perso_images/saut/saut2-" .. side .. ".png")
        self.jumpFrames[side][3] = love.graphics.newImage("images/perso_images/saut/saut3-" .. side .. ".png")
    end
end

return Player
