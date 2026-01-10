-- enemy/sprites.lua
local Sprites = {}
Sprites.__index = Sprites

function Sprites.new(enemy)
    local self = setmetatable({}, Sprites)
    self.enemy = enemy
    self.logoID = love.graphics.newImage("images/logo_id/romain.png")
    self.poseG = love.graphics.newImage("images/perso_images/pose-G.png")
    self.poseD = love.graphics.newImage("images/perso_images/pose-D.png")
    self.poseBasG = love.graphics.newImage("images/perso_images/poseBAS-G.png")
    self.poseBasD = love.graphics.newImage("images/perso_images/poseBAS-D.png")

    self.KOG = love.graphics.newImage("images/perso_images/KO/KO-G.png")
    self.KOD = love.graphics.newImage("images/perso_images/KO/KO-D.png")

    self.blockHautG = love.graphics.newImage("images/perso_images/blockHAUT-G.png")
    self.blockHautD = love.graphics.newImage("images/perso_images/blockHAUT-D.png")
    self.blockBasG  = love.graphics.newImage("images/perso_images/blockBAS-G.png")
    self.blockBasD  = love.graphics.newImage("images/perso_images/blockBAS-D.png")

    -- roll
    self.rollFrames = {
        G = {
            love.graphics.newImage("images/perso_images/roll/roll1-G.png"),
            love.graphics.newImage("images/perso_images/roll/roll2-G.png"),
            love.graphics.newImage("images/perso_images/roll/roll3-G.png"),
            love.graphics.newImage("images/perso_images/roll/roll4-G.png"),
            love.graphics.newImage("images/perso_images/roll/roll5-G.png"),
            love.graphics.newImage("images/perso_images/roll/roll6-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/roll/roll1-D.png"),
            love.graphics.newImage("images/perso_images/roll/roll2-D.png"),
            love.graphics.newImage("images/perso_images/roll/roll3-D.png"),
            love.graphics.newImage("images/perso_images/roll/roll4-D.png"),
            love.graphics.newImage("images/perso_images/roll/roll5-D.png"),
            love.graphics.newImage("images/perso_images/roll/roll6-D.png"),
        }
    }
    -- punch
    self.punchFrames = {
        G = {
            love.graphics.newImage("images/perso_images/punch/punch1-G.png"),
            love.graphics.newImage("images/perso_images/punch/punch2-G.png"),
            love.graphics.newImage("images/perso_images/punch/punch3-G.png"),
            love.graphics.newImage("images/perso_images/punch/punch4-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/punch/punch1-D.png"),
            love.graphics.newImage("images/perso_images/punch/punch2-D.png"),
            love.graphics.newImage("images/perso_images/punch/punch3-D.png"),
            love.graphics.newImage("images/perso_images/punch/punch4-D.png"),
        }
    }
    -- bas-slash
    self.basSlashFrames = {
        G = {
            love.graphics.newImage("images/perso_images/bas-slash/basS1-G.png"),
            love.graphics.newImage("images/perso_images/bas-slash/basS2-G.png"),
            love.graphics.newImage("images/perso_images/bas-slash/basS3-G.png"),
            love.graphics.newImage("images/perso_images/bas-slash/basS4-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/bas-slash/basS1-D.png"),
            love.graphics.newImage("images/perso_images/bas-slash/basS2-D.png"),
            love.graphics.newImage("images/perso_images/bas-slash/basS3-D.png"),
            love.graphics.newImage("images/perso_images/bas-slash/basS4-D.png"),
        }
    }
    -- low-slash
    self.lowSlashFrames = {
        G = {
            love.graphics.newImage("images/perso_images/low-slash/ls1-G.png"),
            love.graphics.newImage("images/perso_images/low-slash/ls2-G.png"),
            love.graphics.newImage("images/perso_images/low-slash/ls3-G.png"),
            love.graphics.newImage("images/perso_images/low-slash/ls4-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/low-slash/ls1-D.png"),
            love.graphics.newImage("images/perso_images/low-slash/ls2-D.png"),
            love.graphics.newImage("images/perso_images/low-slash/ls3-D.png"),
            love.graphics.newImage("images/perso_images/low-slash/ls4-D.png"),
        }
    }

    -- low-kick
    self.lowKickFrames = {
        G = {
            love.graphics.newImage("images/perso_images/low-kick/lk1-G.png"),
            love.graphics.newImage("images/perso_images/low-kick/lk2-G.png"),
            love.graphics.newImage("images/perso_images/low-kick/lk3-G.png"),
            love.graphics.newImage("images/perso_images/low-kick/lk4-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/low-kick/lk1-D.png"),
            love.graphics.newImage("images/perso_images/low-kick/lk2-D.png"),
            love.graphics.newImage("images/perso_images/low-kick/lk3-D.png"),
            love.graphics.newImage("images/perso_images/low-kick/lk4-D.png"),
        }
    }

    -- knee
    self.kneeFrames = {
        G = {
            love.graphics.newImage("images/perso_images/knee/knee1-G.png"),
            love.graphics.newImage("images/perso_images/knee/knee2-G.png"),
            love.graphics.newImage("images/perso_images/knee/knee3-G.png"),
            love.graphics.newImage("images/perso_images/knee/knee4-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/knee/knee1-D.png"),
            love.graphics.newImage("images/perso_images/knee/knee2-D.png"),
            love.graphics.newImage("images/perso_images/knee/knee3-D.png"),
            love.graphics.newImage("images/perso_images/knee/knee4-D.png"),
        }
    }

    -- kick
    self.kickFrames = {
        G = {
            love.graphics.newImage("images/perso_images/kick/kick1-G.png"),
            love.graphics.newImage("images/perso_images/kick/kick2-G.png"),
            love.graphics.newImage("images/perso_images/kick/kick3-G.png"),
            love.graphics.newImage("images/perso_images/kick/kick4-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/kick/kick1-D.png"),
            love.graphics.newImage("images/perso_images/kick/kick2-D.png"),
            love.graphics.newImage("images/perso_images/kick/kick3-D.png"),
            love.graphics.newImage("images/perso_images/kick/kick4-D.png"),
        }
    }

    -- hit1
    self.hit1Frames = {
        G = {
            love.graphics.newImage("images/perso_images/hit1/hit1-G.png"),
            love.graphics.newImage("images/perso_images/hit1/hit2-G.png"),
            love.graphics.newImage("images/perso_images/hit1/hit3-G.png"),
            love.graphics.newImage("images/perso_images/hit1/hit4-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/hit1/hit1-D.png"),
            love.graphics.newImage("images/perso_images/hit1/hit2-D.png"),
            love.graphics.newImage("images/perso_images/hit1/hit3-D.png"),
            love.graphics.newImage("images/perso_images/hit1/hit4-D.png"),
        }
    }
    
    -- heavy-slash
    self.heavySlashFrames = {
        G = {
            love.graphics.newImage("images/perso_images/heavy-slash/hs1-G.png"),
            love.graphics.newImage("images/perso_images/heavy-slash/hs2-G.png"),
            love.graphics.newImage("images/perso_images/heavy-slash/hs3-G.png"),
            love.graphics.newImage("images/perso_images/heavy-slash/hs4-G.png"),
            love.graphics.newImage("images/perso_images/heavy-slash/hs5-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/heavy-slash/hs1-D.png"),
            love.graphics.newImage("images/perso_images/heavy-slash/hs2-D.png"),
            love.graphics.newImage("images/perso_images/heavy-slash/hs3-D.png"),
            love.graphics.newImage("images/perso_images/heavy-slash/hs4-D.png"),
            love.graphics.newImage("images/perso_images/heavy-slash/hs5-D.png"),
        }
    }

    -- big-slash
    self.bigSlashFrames = {
        G = {
            love.graphics.newImage("images/perso_images/big-slash/bs1-G.png"),
            love.graphics.newImage("images/perso_images/big-slash/bs2-G.png"),
            love.graphics.newImage("images/perso_images/big-slash/bs3-G.png"),
            love.graphics.newImage("images/perso_images/big-slash/bs4-G.png"),
            love.graphics.newImage("images/perso_images/big-slash/bs5-G.png"),
            love.graphics.newImage("images/perso_images/big-slash/bs6-G.png"),
            love.graphics.newImage("images/perso_images/big-slash/bs7-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/big-slash/bs1-D.png"),
            love.graphics.newImage("images/perso_images/big-slash/bs2-D.png"),
            love.graphics.newImage("images/perso_images/big-slash/bs3-D.png"),
            love.graphics.newImage("images/perso_images/big-slash/bs4-D.png"),
            love.graphics.newImage("images/perso_images/big-slash/bs5-D.png"),
            love.graphics.newImage("images/perso_images/big-slash/bs6-D.png"),
            love.graphics.newImage("images/perso_images/big-slash/bs7-D.png"),
        }
    }

    -- shop
    self.shopFrames = {
        G = {
            love.graphics.newImage("images/perso_images/shop/shop1-G.png"),
            love.graphics.newImage("images/perso_images/shop/shop2-G.png"),
            love.graphics.newImage("images/perso_images/shop/shop3-G.png"),
            love.graphics.newImage("images/perso_images/shop/shop4-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/shop/shop1-D.png"),
            love.graphics.newImage("images/perso_images/shop/shop2-D.png"),
            love.graphics.newImage("images/perso_images/shop/shop3-D.png"),
            love.graphics.newImage("images/perso_images/shop/shop4-D.png"),
        }
    }

    -- bad-bas-hit
    self.bbhFrames = {
        G = {
            love.graphics.newImage("images/perso_images/bad-bas-hit/bbh1-G.png"),
            love.graphics.newImage("images/perso_images/bad-bas-hit/bbh2-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/bad-bas-hit/bbh1-D.png"),
            love.graphics.newImage("images/perso_images/bad-bas-hit/bbh2-D.png"),
        }
    }

    -- bad-haut-hit
    self.bhhFrames = {
        G = {
            love.graphics.newImage("images/perso_images/bad-haut-hit/bhh1-G.png"),
            love.graphics.newImage("images/perso_images/bad-haut-hit/bhh2-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/bad-haut-hit/bhh1-D.png"),
            love.graphics.newImage("images/perso_images/bad-haut-hit/bhh2-D.png"),
        }
    }

    -- fall-low
    self.fallLow = {
        G = {
            love.graphics.newImage("images/perso_images/fall-low/fl1-G.png"),
            love.graphics.newImage("images/perso_images/fall-low/fl2-G.png"),
            love.graphics.newImage("images/perso_images/fall-low/fl3-G.png"),
            love.graphics.newImage("images/perso_images/fall-low/fl4-G.png"),
            love.graphics.newImage("images/perso_images/fall-low/fl5-G.png"),
            love.graphics.newImage("images/perso_images/fall-low/fl6-G.png"),
            love.graphics.newImage("images/perso_images/fall-low/fl7-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/fall-low/fl1-D.png"),
            love.graphics.newImage("images/perso_images/fall-low/fl2-D.png"),
            love.graphics.newImage("images/perso_images/fall-low/fl3-D.png"),
            love.graphics.newImage("images/perso_images/fall-low/fl4-D.png"),
            love.graphics.newImage("images/perso_images/fall-low/fl5-D.png"),
            love.graphics.newImage("images/perso_images/fall-low/fl6-D.png"),
            love.graphics.newImage("images/perso_images/fall-low/fl7-D.png"),
        }
    }

    -- get-up-v
    self.guv = {
        G = {
            love.graphics.newImage("images/perso_images/get-up-v/guv1-G.png"),
            love.graphics.newImage("images/perso_images/get-up-v/guv2-G.png"),
            love.graphics.newImage("images/perso_images/get-up-v/guv3-G.png"),
            love.graphics.newImage("images/perso_images/get-up-v/guv4-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/get-up-v/guv1-D.png"),
            love.graphics.newImage("images/perso_images/get-up-v/guv2-D.png"),
            love.graphics.newImage("images/perso_images/get-up-v/guv3-D.png"),
            love.graphics.newImage("images/perso_images/get-up-v/guv4-D.png"),
        }
    }

    -- shop-reaction
    self.shopReaction = {
        G = {
            love.graphics.newImage("images/perso_images/shop-reaction/sr1-G.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr2-G.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr3-G.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr4-G.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr5-G.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr6-G.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr7-G.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr8-G.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr9-G.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr10-G.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr11-G.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr12-G.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr13-G.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr14-G.png"),
        },
        D = {
            love.graphics.newImage("images/perso_images/shop-reaction/sr1-D.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr2-D.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr3-D.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr4-D.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr5-D.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr6-D.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr7-D.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr8-D.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr9-D.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr10-D.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr11-D.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr12-D.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr13-D.png"),
            love.graphics.newImage("images/perso_images/shop-reaction/sr14-D.png"),
        }
    }

    return self
end

function Sprites:getCurrentSprite()
    local e = self.enemy
    local sprite

    local function safeFrame(frames)
        if not frames or #frames == 0 then return nil end
        local idx = math.min(e.animation.currentFrame, #frames)
        return frames[idx]
    end

    -- Animation bas
    -- addDebugLog("e.state" .. tostring(e.state))
    -- addDebugLog("e.directionatk" .. tostring(e.directionatk))
    if e.isBlocking then
        if e.blockType == "bas" then
            sprite = (e.side=="G") and self.blockBasG or self.blockBasD
        else
            sprite = (e.side=="G") and self.blockHautG or self.blockHautD
        end
    elseif e.animation.isguving then
        sprite = safeFrame(self.guv[e.side])
    elseif e.thrown then
        sprite = safeFrame(self.fallLow[e.side])
    elseif e.animation.isBBHing then
        sprite = safeFrame(self.bbhFrames[e.side])
    elseif e.animation.isBHHing then
        sprite = safeFrame(self.bhhFrames[e.side])
    elseif e.animation.isRolling then
        sprite = safeFrame(self.rollFrames[e.side])
        if sprite and e.animation.rollBackward then
            local frames = self.rollFrames[e.side]
            sprite = frames[#frames - e.animation.currentFrame + 1]
        end
    elseif e.animation.isShopReactioning then
        sprite = safeFrame(self.shopReaction[e.side])
        local img = safeFrame(self.shopReaction[e.side])
        return {
            img = img,
            scaleX = e.scaleX or 1,
            scaleY = e.scaleY or 1
        }
    elseif e.animation.isJumping then
        sprite = safeFrame(e.jumpFrames and e.jumpFrames[e.side])
    elseif e.animation.isBasSlashing then
        sprite = safeFrame(self.basSlashFrames[e.side])
    elseif e.isCrouching then
        sprite = (e.side=="G") and self.poseBasG or self.poseBasD
    elseif e.animation.isBigSlashing then
        sprite = safeFrame(self.bigSlashFrames[e.side])
    elseif e.animation.isHeavySlashing then
        sprite = safeFrame(self.heavySlashFrames[e.side])
    elseif e.animation.ishit1ing then
        sprite = safeFrame(self.hit1Frames[e.side])
    elseif e.animation.iskicking then
        sprite = safeFrame(self.kickFrames[e.side])
    elseif e.animation.iskneeing then
        sprite = safeFrame(self.kneeFrames[e.side])
    elseif e.animation.isLowKicking then
        sprite = safeFrame(self.lowKickFrames[e.side])
    elseif e.animation.isLowSlashing then
        sprite = safeFrame(self.lowSlashFrames[e.side])
    elseif e.animation.isShoping then
        sprite = safeFrame(self.shopFrames[e.side])
    elseif e.animation.isPunching then
        sprite = safeFrame(self.punchFrames[e.side])
    elseif e.animation.isWalking then
        local frames = (e.animation.walkType=="forward") and e.walkForwardFrames[e.side] or e.walkBackwardFrames[e.side]
        sprite = safeFrame(frames)
    elseif e.gameOver then
        sprite = (e.side=="G") and self.KOG or self.KOD
    else
        sprite = (e.side=="G") and self.poseG or self.poseD
    end

    -- fallback
    if not sprite then
        sprite = (e.side=="G") and self.poseG or self.poseD
    end

    return sprite
end

-- multipliers pour les frames du roll
Sprites.rollScaleMultipliers = { 
    0.5,  -- frame 1
    0.4,  -- frame 2
    0.4,  -- frame 3
    0.4,  -- frame 4
    0.3,  -- frame 5
    0.6   -- frame 6
}

-- multipliers pour les frames du roll
Sprites.shopReactScaleMultipliers = { 
    0.12,  -- frame 1
    0.12,  -- frame 2
    0.12,  -- frame 3
    0.12,  -- frame 4
    0.12,  -- frame 5
    0.12,  -- frame 6
    0.12,  -- frame 7
    0.12,  -- frame 8
    0.12,  -- frame 9
    0.12,  -- frame 10
    0.12,  -- frame 11
    0.12,  -- frame 12
    0.12,  -- frame 13
    0.12   -- frame 14
}

function Sprites:draw()
    local e = self.enemy
    local sprite = self:getCurrentSprite()

    -- facteur de réduction quand accroupi
    local crouchScale = e.isCrouching and 0.7 or 1

    -- facteur spécial pour shop
    local shopScale = (sprite and e.animation.isShoping) and 1.1 or 1

    if type(sprite) == "table" then
        -- sprite = {img, scaleX, scaleY}
        local img = sprite.img
        local scaleX = sprite.scaleX
        local scaleY = sprite.scaleY
        if e.animation.isRolling then
            local frame = e.animation.currentFrame or 1
            local rollMultiplier = Sprites.rollScaleMultipliers[frame] or 1
            scaleX = scaleX * rollMultiplier
            scaleY = scaleY * rollMultiplier
        end
        if e.animation.isShopReactioning then
            local frame = e.animation.currentFrame or 1
            local shopMultiplier = Sprites.shopReactScaleMultipliers[frame] or 1
            scaleX = scaleX * shopMultiplier
            scaleY = scaleY * shopMultiplier
        end
        -- appliquer scale pour accroupissement
        scaleY = scaleY * crouchScale * shopScale
        local w, h = img:getWidth(), img:getHeight()
        local drawX = e.x + e.width / 2
        local drawY = e.y + e.height
        local originX = w / 2
        local originY = h * crouchScale * shopScale

        love.graphics.draw(img, drawX, drawY, 0, scaleX, scaleY, originX, originY)
        -- === LOGO AU-DESSUS DE L'ENEMY ===
        if self.logoID then
            local logo = self.logoID
            local lw, lh = logo:getWidth(), logo:getHeight()

            local logoScale = 0.4
            local offsetY = 20

            local logoX = e.x + e.width / 2
            local logoY = e.y - offsetY

            love.graphics.draw(
                logo,
                logoX,
                logoY,
                0,
                logoScale,
                logoScale,
                lw / 2,
                lh
            )
        end
    else
        -- ancien comportement (pour les poses fixes qui sont juste des images)
        local w, h = sprite:getWidth(), sprite:getHeight()
        local scale = (e.height / h) * crouchScale * shopScale
        local drawX = e.x + e.width / 2
        local drawY = e.y + e.height
        local originX = w / 2
        local originY = h 

        love.graphics.draw(sprite, drawX, drawY, 0, scale, scale, originX, originY)
         -- === LOGO AU-DESSUS DE L'ENEMY ===
        if self.logoID then
            local logo = self.logoID
            local lw, lh = logo:getWidth(), logo:getHeight()

            local logoScale = 0.4
            local offsetY = 20

            local logoX = e.x + e.width / 2
            local logoY = e.y - offsetY

            love.graphics.draw(
                logo,
                logoX,
                logoY,
                0,
                logoScale,
                logoScale,
                lw / 2,
                lh
            )
        end
    end
end

return Sprites