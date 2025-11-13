local Moveset = require("moveset")

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
    self.jumpStrength = -1000 * scale
    self.gravity = 2000 * scale

    self.isOnGround = true

    self.side = "G" -- orientation par défaut (G = gauche, D = droite)

    -- Charger l'image du personnage
    self.spriteG = love.graphics.newImage("images/perso_images/pose-G.png")
    self.spriteD = love.graphics.newImage("images/perso_images/pose-D.png")
    self.sprite = self.spriteG 

    self:loadWalkSprites()

    return self
end

function Player:handleCollision(other, dt)
    if not Moveset.checkCollision(self, other) then
        self.isBlocked = false -- pas de contact → pas bloqué
        return
    end

    -- Cas 1 : roulade → passer derrière
    if self.isRolling then
        if self.rollDirection > 0 then
            self.x = other.x + other.width
        else
            self.x = other.x - self.width
        end
        return
    end

    -- Cas 2 : saut → glisser sur le côté pendant la descente
    if not self.isOnGround then
        local playerCenterX = self.x + self.width/2
        local otherCenterX = other.x + other.width/2
        local slideSpeed = 200 -- vitesse de glissement en px/s

        if other:isAtLeftEdge() then
            -- L'adversaire est collé à gauche → toujours glisser à droite
            self.x = math.max(self.x + slideSpeed * dt, other.x + other.width)
        elseif other:isAtRightEdge() then
            -- L'adversaire est collé à droite → toujours glisser à gauche
            self.x = math.min(self.x - slideSpeed * dt, other.x - self.width)
        else
            -- Sinon choisir gauche/droite en fonction de la position relative
            if playerCenterX < otherCenterX then
                -- Glisser vers la gauche
                self.x = math.min(self.x - slideSpeed * dt, other.x - self.width)
            else
                -- Glisser vers la droite
                self.x = math.max(self.x + slideSpeed * dt, other.x + other.width)
            end
        end
        return
    end

    -- Cas 3 : au sol → blocage classique
    if self.x < other.x then
        self.x = other.x - self.width
    else
        self.x = other.x + other.width
    end

    -- On marque le perso comme bloqué
    self.isBlocked = true
end

function Player:update(dt)
    -- Si roulade : priorité absolue
    if self.isRolling then
        -- Mouvement automatique
        self.x = self.x + self.rollDirection * self.rollSpeed * dt
        self.rollTimer = self.rollTimer - dt
        if self.rollTimer <= 0 then
            -- Fin de la roulade
            self.isRolling = false
            self.height = self.normalHeight
            self.width = self.normalWidth
            self.y = self.groundY - self.height
        end
        return -- on ignore tout le reste pendant la roulade
    end

    -- Gestion du focus (touche F maintenue)
    if love.keyboard.isDown("f") then
        if not self.isFocusing then
            self.isFocusing = true
            self.focusTransition = self.focusTransitionDuration
        end
    else
        self.isFocusing = false
    end

    -- Transition violet → bleu
    if self.isFocusing and self.focusTransition > 0 then
        self.focusTransition = self.focusTransition - dt
        self.focusColor = {1, 0, 1} -- violet
    elseif self.isFocusing then
        self.focusColor = {0, 0, 1} -- bleu
    else
        self.focusColor = {1, 0, 0} -- rouge normal
    end

    -- Si focus : pas de déplacement ni de saut
    if self.isFocusing then
        if love.keyboard.isDown("down") and self.isOnGround then
            self:crouch()
        else
            self:standUp()
        end
        Moveset.applyGravity(self, dt)
        return
    end

    -- Gestion du crouch : maintenir ↓
    if love.keyboard.isDown("down") and self.isOnGround then
        self:crouch()
    else
        self:standUp()
    end

    Moveset.move(self, dt)
    Moveset.applyGravity(self, dt)

    -- Empêcher de sortir de l’écran
    self:clampToScreen()

    -- animation marche
    if self.isWalking and not self.isBlocked and self.isOnGround then
        self.frameTimer = self.frameTimer + dt
        if self.frameTimer >= self.frameDuration then
            self.frameTimer = 0

            local frames = (self.walkType == "forward")
                and self.walkForwardFrames[self.side]
                or self.walkBackwardFrames[self.side]

            self.currentFrame = self.currentFrame + 1
            if self.currentFrame > #frames then
                self.currentFrame = 1
            end
        end
    end
end

function Player:updateOrientation(other)
    if self.x + self.width/2 < other.x + other.width/2 then
        self.side = "D" -- si on est à gauche → on regarde à droite
        self.sprite = self.spriteD
    else
        self.side = "G" -- si on est à droite → on regarde à gauche
        self.sprite = self.spriteG
    end
end

function Player:draw()
    local halfHeight = self.height / 2

    if not self.isOnGround then
        -- En l’air : tout rouge
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    elseif self.isCrouching then
        -- Accroupi : tout focusColor
        love.graphics.setColor(self.focusColor)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    else
        -- Debout : bas rouge, haut focusColor
        -- Partie basse
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", self.x, self.y + halfHeight, self.width, halfHeight)

        -- Partie haute
        love.graphics.setColor(self.focusColor)
        love.graphics.rectangle("fill", self.x, self.y, self.width, halfHeight)
    end

    -- reset couleur
    love.graphics.setColor(1, 1, 1)

    -- Choisir quel sprite afficher
    local spriteToDraw

    if self.isWalking then
        -- affiche bien les frames de la bonne orientation
        local frames = (self.walkType == "forward") and self.walkForwardFrames[self.side] or self.walkBackwardFrames[self.side]

        local frame = frames[self.currentFrame]
        spriteToDraw = frame
    else
        -- affiche la pose
        spriteToDraw = (self.side == "G") and self.spriteG or self.spriteD
    end

    if spriteToDraw then
        local spriteW = spriteToDraw:getWidth()
        local spriteH = spriteToDraw:getHeight()
        local scaleX = self.width / spriteW
        local scaleY = self.height / spriteH

        love.graphics.draw(
            spriteToDraw,
            self.x + self.width / 2,
            self.y + self.height / 2,
            0,
            scaleX, scaleY,
            spriteW / 2, spriteH / 2
        )
    end

end

function Player:keypressed(key)
    local now = love.timer.getTime()

    -- Empêcher saut/roulade pendant un saut déjà en cours
    if key == "space" and self.isOnGround and not self.isRolling then
        self.yVelocity = self.jumpStrength
        self.isOnGround = false
        self:standUp()  -- annuler le crouch en saut
    end

    -- Double appui droite
    if key == "right" and self.isOnGround and not self.isRolling then
        if now - self.lastKeyPressed.right <= self.doubleTapTime then
            self:startRoll(1)
        end
        self.lastKeyPressed.right = now
    end

    -- Double appui gauche
    if key == "left" and self.isOnGround and not self.isRolling then
        if now - self.lastKeyPressed.left <= self.doubleTapTime then
            self:startRoll(-1)
        end
        self.lastKeyPressed.left = now
    end
end

function Player:startWalk(dir)
    -- Déterminer si on avance ou recule selon le côté
    local isForward = (dir == 1 and self.side == "D") or (dir == -1 and self.side == "G")

    self.walkType = isForward and "forward" or "backward"

    if not self.isWalking then
        self.isWalking = true
        self.currentFrame = 1
        self.frameTimer = 0
    end
end

function Player:stopWalk()
    self.isWalking = false
    self.currentFrame = 1 -- ou frame neutre si tu veux
end

function Player:startRoll(direction)
     -- Vérifier si on est au bord et qu’on veut rouler vers l’extérieur
    if direction < 0 and self:isAtLeftEdge() then
        return -- annuler la roulade gauche si collé à gauche
    elseif direction > 0 and self:isAtRightEdge() then
        return -- annuler la roulade droite si collé à droite
    end

    self.isRolling = true
    self.rollDirection = direction
    self.rollTimer = self.rollDuration

    -- Réduction du joueur (comme crouch)
    self.width = self.normalWidth
    self.height = self.normalHeight / 2
    self.y = self.groundY - self.height

    -- Pendant la roulade : couleur normale
    self.focusColor = {1, 0, 0}
end

function Player:crouch()
    if not self.isCrouching then
        self.isCrouching = true
        self.width = self.crouchWidth
        self.height = self.crouchHeight
        -- Ajuster la position pour que le bas reste collé au sol
        self.y = self.groundY - self.height
    end
end

function Player:clampToScreen()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    -- Bloquer en X
    if self.x < 0 then
        self.x = 0
    elseif self.x + self.width > screenWidth then
        self.x = screenWidth - self.width
    end

    -- Bloquer en Y (au cas où tu modifies le sol plus tard)
    if self.y < 0 then
        self.y = 0
    elseif self.y + self.height > screenHeight then
        self.y = screenHeight - self.height
    end
end

function Player:isAtLeftEdge()
    return self.x <= 0
end

function Player:isAtRightEdge()
    return self.x + self.width >= love.graphics.getWidth()
end

function Player:standUp()
    if self.isCrouching then
        self.isCrouching = false
        self.height = self.normalHeight
        self.width = self.normalWidth
        self.y = self.groundY - self.height
    end
end

function Player:loadWalkSprites()
    self.walkForwardFrames = { G = {}, D = {} }
    self.walkBackwardFrames = { G = {}, D = {} }

    -- Ordre des frames marche avant
    local forwardOrder = {1,2,3,4,5,6,7,8,9,10,11,12,13}
    -- Ordre des frames marche arrière
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

return Player