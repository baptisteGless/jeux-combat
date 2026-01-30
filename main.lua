local Player = require("player")  -- ça charge player/init.lua automatiquement
local Enemy = require("enemy")    -- ça charge enemy/init.lua automatiquement
local HealthBar = require("healthbar") -- les bar de vie des 2 personnages
local Camera = require("camera")  -- le systeme de camera shaking
local Assets = require("assets")

local gameState = "menu" -- "menu" | "game"
local typeGame = "history"

local initStep = 0
local initDone = false

local buttonScale = 0.5       -- réduit la taille des boutons à 50%
local buttonSpacing = 40      -- espace vertical entre les boutons

local menuButtons = {}
local selectedButton = 1
local buttonSpacing = 80 -- espace vertical entre les boutons
screenWidth, screenHeight = love.graphics.getDimensions()
local menuStartY = (screenHeight - (#menuButtons * buttonSpacing)) / 2

local loadingAngle = 0
local LOADING_ROTATION_SPEED = math.pi

local readyTimer = 0
local READY_DURATION = 2.5 -- secondes
local assetsToLoad = {}
local assetsLoaded = 0
local totalAssets = 0
local loadingDone = false

local goAlpha = 1         -- alpha actuel (1 = opaque, 0 = invisible)
local goTimer = 0         -- timer pour l'affichage
local GO_DURATION = 2     -- secondes pendant lesquelles "GO" est visible avant de disparaître
local GO_FADE_DURATION = 0.5 -- durée de la disparition en secondes

debugLog = ""
local MAX_DEBUG_LINES = 10

local SandFX = require("sandFX")
local HitFX = require("hitFX")

local sandFrames = { G = {}, D = {} }
local hitFrames = { G = {}, D = {} }
local hitFramesfall = { G = {}, D = {} }
local sparkleFrames = { G = {}, D = {} }

function checkCollision(a, b)
    return a.x < b.x + b.width and
           a.x + a.width > b.x and
           a.y < b.y + b.height and
           a.y + a.height > b.y
end

function addDebugLog(line)
    -- Découpe en lignes
    local lines = {}
    for l in debugLog:gmatch("[^\n]+") do
        table.insert(lines, l)
    end

    -- Ajoute la nouvelle ligne
    table.insert(lines, line)

    -- Supprime les premières si on dépasse le max
    while #lines > MAX_DEBUG_LINES do
        table.remove(lines, 1)
    end

    -- Reconstruit le debugLog final
    debugLog = table.concat(lines, "\n")
end

function prepareLoading()
    Assets.prepareLoading()
    assetsToLoad = Assets.getAssetsToLoad()
    assetsLoaded = 0
    totalAssets = #assetsToLoad
    loadingDone = false
end

function loadNextAsset()
    local asset = assetsToLoad[assetsLoaded + 1]
    if not asset then
        loadingDone = true
        return
    end

    -- local key, path = asset[1], asset[2]
    -- _G[key] = love.graphics.newImage(path)
    local img = love.graphics.newImage(asset.path)
    asset.assign(img)

    assetsLoaded = assetsLoaded + 1
end

function drawLoadingScreen()
    love.graphics.draw(
        loadingBackground,
        0, 0, 0,
        screenWidth / loadingBackground:getWidth(),
        screenHeight / loadingBackground:getHeight()
    )
    local scale = 0.1 -- ajuste la taille
    local w, h = logoloading:getWidth(), logoloading:getHeight()
    local x = screenWidth - (w * scale) - 20 -- 20 pixels du bord droit
    local y = screenHeight - (h * scale) - 20 -- 20 pixels du bas
    love.graphics.draw(logoloading, x + (w*scale)/2, y + (h*scale)/2, loadingAngle, scale, scale, w/2, h/2)
end

function initGameStep()
    if initStep == 1 then
        screenWidth, screenHeight = love.graphics.getDimensions()

    elseif initStep == 2 then
        -- Créer le joueur
        if typeGame == "history" then
            player = Player.new(200, screenHeight - 150)
        elseif typeGame == "survive" then
            player = Player.new(screenWidth/2, screenHeight - 150)
        end

    elseif initStep == 3 then
        -- Créer l’ennemi
        if typeGame == "history" then
            enemy = Enemy.new(screenWidth - 400, screenHeight - 150, player)
            player.target = enemy
        elseif typeGame == "survive" then
            enemies = {}
            
            local enemyCount = 3
            local spacing = 180
            local offscreenMargin = 200

            for i = 1, enemyCount do
                local y = screenHeight - 150
                local x

                if i % 2 == 0 then
                    -- ennemi à droite
                    x = screenWidth + offscreenMargin + (i * 40)
                else
                    -- ennemi à gauche
                    x = -offscreenMargin - (i * 40)
                end

                local e = Enemy.new(x, y, player)
                table.insert(enemies, e)
            end
            player.target = getClosestEnemy(player, enemies)
        end

    elseif initStep == 4 then
        -- FX sang / étincelles
        if typeGame == "history" then
            enemy.fx.hitFrames = Assets.images.bloodBoom
            enemy.fx.hitFramesfall = Assets.images.bloodEffect
            enemy.fx.sparkleFrames = Assets.images.sparkle
            enemy.fx.HitFX = HitFX
        elseif typeGame == "survive" then
            for _, e in ipairs(enemies) do
                e.fx.hitFrames = Assets.images.bloodBoom
                e.fx.hitFramesfall = Assets.images.bloodEffect
                e.fx.sparkleFrames = Assets.images.sparkle
                e.fx.HitFX = HitFX
            end
        end

        player.fx.hitFrames = Assets.images.bloodBoom
        player.fx.hitFramesfall = Assets.images.bloodEffect
        player.fx.sparkleFrames = Assets.images.sparkle
        player.fx.HitFX = HitFX

    elseif initStep == 5 then
        -- FX sable
        player.fx.sandFrames = Assets.images.sand
        player.fx.SandFX = SandFX
        if typeGame == "history" then
            enemy.fx.sandFrames = Assets.images.sand
            enemy.fx.SandFX = SandFX
        elseif typeGame == "survive" then
            for _, e in ipairs(enemies) do
                e.fx.sandFrames = Assets.images.sand
                e.fx.SandFX = SandFX
            end
        end

    elseif initStep == 6 then
        -- Barres de vie
        local barWidth = 300
        local barHeight = 20
        local padding = 30
        local y = screenHeight - 50

        playerHealthBar = HealthBar:new(
            screenWidth / 2 - barWidth - padding,
            y,
            barWidth,
            barHeight,
            player
        )

        if typeGame == "history" then
            enemyHealthBar = HealthBar:new(
                screenWidth / 2 + padding,
                y,
                barWidth,
                barHeight,
                enemy
            )

        elseif typeGame == "survive" then
            enemyHealthBars = {}

            for i, e in ipairs(enemies) do
                local x = padding + (i - 1) * (barWidth / 2 + 10)
                local bar = HealthBar:new(x, 20, barWidth / 2, barHeight, e)
                table.insert(enemyHealthBars, bar)
            end
        end

    elseif initStep == 7 then
        -- Caméra
        camera = Camera:new()

    elseif initStep == 8 then
        -- FIN
        initDone = true
    end

    initStep = initStep + 1
end

function getClosestEnemy(player, enemies)
    local closest = nil
    local minDist = math.huge

    for _, e in ipairs(enemies) do
        if e.alive ~= false then
            local dx = e.x - player.x
            local dy = e.y - player.y
            local dist = dx*dx + dy*dy

            if dist < minDist then
                minDist = dist
                closest = e
            end
        end
    end

    return closest
end

function startTransition(direction)
    if direction == "down" then
        transitionState = "down"    -- descend pour cacher
    elseif direction == "up" then
        transitionState = "up"      -- remonte pour montrer
    elseif direction == "stay" then
        transitionState = "stay"
    end
end


function love.load()
    love.window.setMode(0, 0, { fullscreen = true })
    screenWidth, screenHeight = love.graphics.getDimensions()
    menuBackground = love.graphics.newImage("images/menu.png")
    loadingBackground = love.graphics.newImage("images/load-fon.png")
    logoloading = love.graphics.newImage("images/loading.png")
    transition = love.graphics.newImage("images/porte-2.png")
    transitionY = -screenHeight  -- commence au dessus de l'écran
    transitionSpeed = 1000        -- pixels par seconde
    transitionState = "hidden"   -- "hidden" | "down" | "up" | "stay"
    local buttonNames = {
        "combats-legendaires",
        "jouer-la-legende",
        "mode-survie",
        "options",
        "quitter"
    }
    menuButtons = {}
    for i, name in ipairs(buttonNames) do
        local img = love.graphics.newImage("images/button/" .. name .. ".png")
        table.insert(menuButtons, {name = name, img = img})
    end
    menuFont = love.graphics.newFont(48)
    loadingFont = love.graphics.newFont(48)
    smallFont = love.graphics.newFont(20)
end

function love.update(dt)
    if transitionState == "down" then
        transitionY = math.min(0, transitionY + transitionSpeed * dt)
    elseif transitionState == "up" then
        transitionY = math.max(-screenHeight, transitionY - transitionSpeed * dt)
    elseif transitionState == "stay" then
        transitionY = 0
    end
    if gameState == "loading" then
        -- charge 1 ou 2 images par frame
        loadNextAsset()
        local progress = assetsLoaded / totalAssets
        -- déclencher la herse quand on atteint 70%
        if progress >= 0.7 and transitionState ~= "down" then
            startTransition("down")  -- herse commence à descendre
        end
        if loadingDone then
            initStep = 1
            initDone = false
            gameState = "postload"
        end
        loadingAngle = loadingAngle + LOADING_ROTATION_SPEED * dt
        return
    end

    if gameState == "postload" then
        initGameStep()
        if initDone then
            startTransition("up")
            readyTimer = 0
            gameState = "ready"
        end
        return
    end

    if gameState == "ready" then
        goTimer = goTimer + dt
        readyTimer = readyTimer + dt
        if goTimer > GO_DURATION then
            local t = goTimer - GO_DURATION
            goAlpha = math.max(0, 1 - t / GO_FADE_DURATION) -- alpha décroît jusqu'à 0
        end
        if readyTimer >= READY_DURATION then
            gameState = "game"
        end
        return
    end
    if gameState == "game" and typeGame == "history" then
        -- Mise à jour du joueur et de l’ennemi
        player:update(dt, enemy)
        enemy:update(dt, player, typeGame, nil)

        -- Mise à jour de la camera
        camera:update(dt)

        -- Gestion orientation (tu peux l’intégrer dans update si tu veux)
        player:updateOrientation(enemy,dt,typeGame)
        enemy:updateOrientation(player)
        
        local atkennemy = enemy:getAttackHitbox()
        local atk = player:getAttackHitbox()
        if atkennemy and checkCollision(atkennemy, player) then
            player.directionatk = atkennemy.type
            player.state = atkennemy.strick 
            player.hitType = atkennemy.hitType
            player.hitTimer = 0
            player.fall = atkennemy.fall
        end
        if player.camShake then
            camera:shake(0.25, 5)
        end
        if atk then
            enemy.hitType = atk.hitType
            enemy.directionatk = atk.type
        end
        if atk and checkCollision(atk, enemy) then
            enemy.state = atk.strick 
            enemy.hitTimer = 0
            enemy.fall = atk.fall
            enemy.hitJustReceived = true
        end
        if enemy.camShake then
            camera:shake(0.25, 5)
        end
    end
    if gameState == "game" and typeGame == "survive" then
        local closestEnemy = getClosestEnemy(player, enemies)

        if closestEnemy then
            player:update(dt, closestEnemy)
        else
            player:update(dt, nil)
        end
        camera:update(dt)
        player:updateOrientation(enemy,dt,typeGame)
        for _, e in ipairs(enemies) do
            e:update(dt, player, typeGame,enemies)
            e:updateOrientation(player)
        end

        local atk = player:getAttackHitbox()
        for _, e in ipairs(enemies) do
            local atke = e:getAttackHitbox()

            if atke and checkCollision(atke, player) then
                player.directionatk = atke.type
                player.state = atke.strick 
                player.hitType = atke.hitType
                player.hitTimer = 0
                player.fall = atke.fall
            end
            if player.camShake then
                camera:shake(0.25, 5)
            end
            if atk then
                e.hitType = atk.hitType
                e.directionatk = atk.type
            end
            if atk and checkCollision(atk, e) then
                e.state = atk.strick
                e.hitTimer = 0
                e.fall = atk.fall
                e.hitJustReceived = true
            end
            if e.camShake then
                camera:shake(0.25, 5)
            end
        end
    end
end

function love.draw()
    if gameState == "menu" then
        love.graphics.setFont(menuFont)
        love.graphics.draw(
            menuBackground,
            0, 0, 0,
            screenWidth / menuBackground:getWidth(),
            screenHeight / menuBackground:getHeight()
        )

        local totalHeight = (#menuButtons - 1) * buttonSpacing
        local startY = (screenHeight - totalHeight) / 2

        for i, btn in ipairs(menuButtons) do
            local scaledWidth = btn.img:getWidth() * buttonScale
            local scaledHeight = btn.img:getHeight() * buttonScale
            local x = (screenWidth - scaledWidth) / 2
            local y = startY + (i - 1) * buttonSpacing

            if i == selectedButton then
                love.graphics.setColor(1,1,0,1) -- surbrillance jaune
            else
                love.graphics.setColor(1,1,1,1)
            end

            love.graphics.draw(btn.img, x, y, 0, buttonScale, buttonScale)
            love.graphics.setColor(1, 1, 1, 1)
        end
    elseif gameState == "loading" then
        drawLoadingScreen()
    elseif gameState == "ready" and typeGame == "survive" then
        camera:apply()
        local bg = Assets.images.background
        love.graphics.draw(
            bg,
            0, 0, 0,
            screenWidth / bg:getWidth(),
            screenHeight / bg:getHeight()
        )
        player:draw()
        for _, e in ipairs(enemies) do
            e:draw()
        end
        camera:clear()
        playerHealthBar:draw()

        -- TEXTE CENTRAL
        local go = Assets.images.go
        local scale = 0.2
        local x = (screenWidth - go:getWidth() * scale) / 2
        local y = (screenHeight - go:getHeight() * scale) / 2
        love.graphics.setColor(1, 1, 1, goAlpha) 
        love.graphics.draw(go, x, y, 0, scale, scale)
        love.graphics.setColor(1, 1, 1, 1)
    elseif gameState == "ready" and typeGame == "history" then
        camera:apply()
        local bg = Assets.images.background
        love.graphics.draw(
            bg,
            0, 0, 0,
            screenWidth / bg:getWidth(),
            screenHeight / bg:getHeight()
        )
        player:draw()
        enemy:draw()
        camera:clear()
        playerHealthBar:draw()
        enemyHealthBar:draw()

        -- TEXTE CENTRAL
        local go = Assets.images.go
        local scale = 0.2
        local x = (screenWidth - go:getWidth() * scale) / 2
        local y = (screenHeight - go:getHeight() * scale) / 2
        love.graphics.setColor(1, 1, 1, goAlpha) 
        love.graphics.draw(go, x, y, 0, scale, scale)
        love.graphics.setColor(1, 1, 1, 1)
    elseif gameState == "game" and typeGame == "history" then
        camera:apply()
        local bg = Assets.images.background
        -- Dessiner le background redimensionné
        love.graphics.draw(
            bg,
            0, 0, 0,
            screenWidth / bg:getWidth(),
            screenHeight / bg:getHeight()
        )
        -- Dessiner le joueur et l’ennemi
        player:draw()
        enemy:draw()
        camera:clear()
        -- HUD
        playerHealthBar:draw()
        enemyHealthBar:draw()
        love.graphics.setColor(1,1,1,1)
        love.graphics.print(debugLog, 10, 10)
    elseif gameState == "game" and typeGame == "survive" then
        camera:apply()
        local bg = Assets.images.background
        -- Dessiner le background redimensionné
        love.graphics.draw(
            bg,
            0, 0, 0,
            screenWidth / bg:getWidth(),
            screenHeight / bg:getHeight()
        )
        -- Dessiner le joueur et l’ennemi
        player:draw()
        for _, e in ipairs(enemies) do
            e:draw()
        end
        camera:clear()
        -- HUD
        playerHealthBar:draw()
        -- for _, bar in ipairs(enemyHealthBars) do
        --     bar:draw()
        -- end
        love.graphics.setColor(1,1,1,1)
        love.graphics.print(debugLog, 10, 10)
    end
    if transitionY > -screenHeight then
        love.graphics.draw(
            transition,
            0,
            transitionY,
            0,
            screenWidth / transition:getWidth(),
            screenHeight / transition:getHeight()
        )
    end
end

function love.keypressed(key)
    if gameState == "menu" then
         if key == "up" then
            selectedButton = selectedButton - 1
            if selectedButton < 1 then selectedButton = #menuButtons end
        elseif key == "down" then
            selectedButton = selectedButton + 1
            if selectedButton > #menuButtons then selectedButton = 1 end
        elseif key == "return" then
            local sel = menuButtons[selectedButton].name
            if sel == "quitter" then
                love.event.quit()
            elseif sel == "mode-survie" then
                prepareLoading()
                gameState = "loading"
                typeGame = "survive"
            elseif sel == "jouer-la-legende" then
                prepareLoading()
                gameState = "loading"
                typeGame = "history"
            end
        end

    elseif gameState == "game" then
        if key == "q" then
            love.event.quit()
        end

        player:keypressed(key)
    end
end