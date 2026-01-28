local Assets = {
    images = {}
}

local assetsToLoad = {}

-- Préparer le tableau d'assets à charger
function Assets.prepareLoading()
    assetsToLoad = {}  -- reset

    table.insert(assetsToLoad, { path = "images/messages/go.png", assign = function(img) Assets.images.go = img end})
    table.insert(assetsToLoad, { path = "images/background.png", assign = function(img) Assets.images.background = img end })
    table.insert(assetsToLoad, { path = "images/logo_id/romain.png", assign = function(img) Assets.images.enemyLogoId = img end })
    table.insert(assetsToLoad, { path = "images/logo_id/bouclier.png", assign = function(img) Assets.images.playerLogoId = img end })
    table.insert(assetsToLoad, { path = "images/perso_images/pose-G.png", assign = function(img) Assets.images.poseG = img end })
    table.insert(assetsToLoad, { path = "images/perso_images/pose-D.png", assign = function(img) Assets.images.poseD = img end })
    table.insert(assetsToLoad, { path = "images/perso_images/poseBAS-G.png", assign = function(img) Assets.images.poseBasG = img end })
    table.insert(assetsToLoad, { path = "images/perso_images/poseBAS-D.png", assign = function(img) Assets.images.poseBasD = img end })
    table.insert(assetsToLoad, { path = "images/perso_images/KO/KO-G.png", assign = function(img) Assets.images.KOG = img end })
    table.insert(assetsToLoad, { path = "images/perso_images/KO/KO-D.png", assign = function(img) Assets.images.KOD = img end })
    table.insert(assetsToLoad, { path = "images/perso_images/blockHAUT-G.png", assign = function(img) Assets.images.blockHautG = img end })
    table.insert(assetsToLoad, { path = "images/perso_images/blockHAUT-D.png", assign = function(img) Assets.images.blockHautD = img end })
    table.insert(assetsToLoad, { path = "images/perso_images/blockBAS-G.png", assign = function(img) Assets.images.blockBasG = img end })
    table.insert(assetsToLoad, { path = "images/perso_images/blockBAS-D.png", assign = function(img) Assets.images.blockBasD = img end })

    Assets.images.roll = {G={}, D={}}
    for i = 1, 6 do
        table.insert(assetsToLoad, {
            path = "images/perso_images/roll/roll"..i.."-G.png",
            assign = function(img) Assets.images.roll.G[i] = img end
        })
        table.insert(assetsToLoad, {
            path = "images/perso_images/roll/roll"..i.."-D.png",
            assign = function(img) Assets.images.roll.D[i] = img end
        })
    end

    Assets.images.punchFrames = {G={}, D={}}
    for i = 1, 4 do
        table.insert(assetsToLoad, {
            path = "images/perso_images/punch/punch"..i.."-G.png",
            assign = function(img) Assets.images.punchFrames.G[i] = img end
        })
        table.insert(assetsToLoad, {
            path = "images/perso_images/punch/punch"..i.."-D.png",
            assign = function(img) Assets.images.punchFrames.D[i] = img end
        })
    end

    Assets.images.basSlashFrames = {G={}, D={}}
    for i = 1, 4 do
        table.insert(assetsToLoad, {
            path = "images/perso_images/bas-slash/basS"..i.."-G.png",
            assign = function(img) Assets.images.basSlashFrames.G[i] = img end
        })
        table.insert(assetsToLoad, {
            path = "images/perso_images/bas-slash/basS"..i.."-D.png",
            assign = function(img) Assets.images.basSlashFrames.D[i] = img end
        })
    end

    Assets.images.lowSlashFrames = {G={}, D={}}
    for i = 1, 4 do
        table.insert(assetsToLoad, {
            path = "images/perso_images/low-slash/ls"..i.."-G.png",
            assign = function(img) Assets.images.lowSlashFrames.G[i] = img end
        })
        table.insert(assetsToLoad, {
            path = "images/perso_images/low-slash/ls"..i.."-D.png",
            assign = function(img) Assets.images.lowSlashFrames.D[i] = img end
        })
    end

    Assets.images.lowKickFrames = {G={}, D={}}
    for i = 1, 4 do
        table.insert(assetsToLoad, {
            path = "images/perso_images/low-kick/lk"..i.."-G.png",
            assign = function(img) Assets.images.lowKickFrames.G[i] = img end
        })
        table.insert(assetsToLoad, {
            path = "images/perso_images/low-kick/lk"..i.."-D.png",
            assign = function(img) Assets.images.lowKickFrames.D[i] = img end
        })
    end

    Assets.images.kneeFrames = {G={}, D={}}
    for i = 1, 4 do
        table.insert(assetsToLoad, {
            path = "images/perso_images/knee/knee"..i.."-G.png",
            assign = function(img) Assets.images.kneeFrames.G[i] = img end
        })
        table.insert(assetsToLoad, {
            path = "images/perso_images/knee/knee"..i.."-D.png",
            assign = function(img) Assets.images.kneeFrames.D[i] = img end
        })
    end

    Assets.images.kickFrames = {G={}, D={}}
    for i = 1, 4 do
        table.insert(assetsToLoad, {
            path = "images/perso_images/kick/kick"..i.."-G.png",
            assign = function(img) Assets.images.kickFrames.G[i] = img end
        })
        table.insert(assetsToLoad, {
            path = "images/perso_images/kick/kick"..i.."-D.png",
            assign = function(img) Assets.images.kickFrames.D[i] = img end
        })
    end

    Assets.images.hit1Frames = {G={}, D={}}
    for i = 1, 4 do
        table.insert(assetsToLoad, {
            path = "images/perso_images/hit1/hit"..i.."-G.png",
            assign = function(img) Assets.images.hit1Frames.G[i] = img end
        })
        table.insert(assetsToLoad, {
            path = "images/perso_images/hit1/hit"..i.."-D.png",
            assign = function(img) Assets.images.hit1Frames.D[i] = img end
        })
    end

    Assets.images.heavySlashFrames = {G={}, D={}}
    for i = 1, 5 do
        table.insert(assetsToLoad, {
            path = "images/perso_images/heavy-slash/hs"..i.."-G.png",
            assign = function(img) Assets.images.heavySlashFrames.G[i] = img end
        })
        table.insert(assetsToLoad, {
            path = "images/perso_images/heavy-slash/hs"..i.."-D.png",
            assign = function(img) Assets.images.heavySlashFrames.D[i] = img end
        })
    end

    Assets.images.bigSlashFrames = {G={}, D={}}
    for i = 1, 7 do
        table.insert(assetsToLoad, {
            path = "images/perso_images/big-slash/bs"..i.."-G.png",
            assign = function(img) Assets.images.bigSlashFrames.G[i] = img end
        })
        table.insert(assetsToLoad, {
            path = "images/perso_images/big-slash/bs"..i.."-D.png",
            assign = function(img) Assets.images.bigSlashFrames.D[i] = img end
        })
    end

    Assets.images.shopFrames = {G={}, D={}}
    for i = 1, 4 do
        table.insert(assetsToLoad, {
            path = "images/perso_images/shop/shop"..i.."-G.png",
            assign = function(img) Assets.images.shopFrames.G[i] = img end
        })
        table.insert(assetsToLoad, {
            path = "images/perso_images/shop/shop"..i.."-D.png",
            assign = function(img) Assets.images.shopFrames.D[i] = img end
        })
    end

    Assets.images.shopSuccessFrames = {G={}, D={}}
    for i = 1, 16 do
        table.insert(assetsToLoad, {
            path = "images/perso_images/shop-success/shs"..i.."-G.png",
            assign = function(img) Assets.images.shopSuccessFrames.G[i] = img end
        })
        table.insert(assetsToLoad, {
            path = "images/perso_images/shop-success/shs"..i.."-D.png",
            assign = function(img) Assets.images.shopSuccessFrames.D[i] = img end
        })
    end

    Assets.images.shopFailFrames = {G={}, D={}}
    for i = 1, 3 do
        table.insert(assetsToLoad, {
            path = "images/perso_images/shop-fail/shop"..i.."-G.png",
            assign = function(img) Assets.images.shopFailFrames.G[i] = img end
        })
        table.insert(assetsToLoad, {
            path = "images/perso_images/shop-fail/shop"..i.."-D.png",
            assign = function(img) Assets.images.shopFailFrames.D[i] = img end
        })
    end

    Assets.images.bbhFrames = {G={}, D={}}
    for i = 1, 2 do
        table.insert(assetsToLoad, {
            path = "images/perso_images/bad-bas-hit/bbh"..i.."-G.png",
            assign = function(img) Assets.images.bbhFrames.G[i] = img end
        })
        table.insert(assetsToLoad, {
            path = "images/perso_images/bad-bas-hit/bbh"..i.."-D.png",
            assign = function(img) Assets.images.bbhFrames.D[i] = img end
        })
    end

    Assets.images.bhhFrames = {G={}, D={}}
    for i = 1, 2 do
        table.insert(assetsToLoad, {
            path = "images/perso_images/bad-haut-hit/bhh"..i.."-G.png",
            assign = function(img) Assets.images.bhhFrames.G[i] = img end
        })
        table.insert(assetsToLoad, {
            path = "images/perso_images/bad-haut-hit/bhh"..i.."-D.png",
            assign = function(img) Assets.images.bhhFrames.D[i] = img end
        })
    end

    Assets.images.fallLow = {G={}, D={}}
    for i = 1, 7 do
        table.insert(assetsToLoad, {
            path = "images/perso_images/fall-low/fl"..i.."-G.png",
            assign = function(img) Assets.images.fallLow.G[i] = img end
        })
        table.insert(assetsToLoad, {
            path = "images/perso_images/fall-low/fl"..i.."-D.png",
            assign = function(img) Assets.images.fallLow.D[i] = img end
        })
    end

    Assets.images.guv = {G={}, D={}}
    for i = 1, 4 do
        table.insert(assetsToLoad, {
            path = "images/perso_images/get-up-v/guv"..i.."-G.png",
            assign = function(img) Assets.images.guv.G[i] = img end
        })
        table.insert(assetsToLoad, {
            path = "images/perso_images/get-up-v/guv"..i.."-D.png",
            assign = function(img) Assets.images.guv.D[i] = img end
        })
    end

    Assets.images.shopReaction = {G={}, D={}}
    for i = 1, 14 do
        table.insert(assetsToLoad, {
            path = "images/perso_images/shop-reaction/sr"..i.."-G.png",
            assign = function(img) Assets.images.shopReaction.G[i] = img end
        })
        table.insert(assetsToLoad, {
            path = "images/perso_images/shop-reaction/sr"..i.."-D.png",
            assign = function(img) Assets.images.shopReaction.D[i] = img end
        })
    end

    Assets.images.sand = {G={}, D={}}
    for i = 1, 6 do
        table.insert(assetsToLoad, {
            path = "images/effet/sand/sand-spred-"..i.."-G.png",
            assign = function(img) Assets.images.sand.G[i] = img end
        })
        table.insert(assetsToLoad, {
            path = "images/effet/sand/sand-spred-"..i.."-D.png",
            assign = function(img) Assets.images.sand.D[i] = img end
        })
    end

    Assets.images.bloodBoom = {G={}, D={}}
    for i = 1, 4 do
        table.insert(assetsToLoad, {
            path = "images/effet/blood-effect/blood-boom-"..i.."-G.png",
            assign = function(img) Assets.images.bloodBoom.G[i] = img end
        })
        table.insert(assetsToLoad, {
            path = "images/effet/blood-effect/blood-boom-"..i.."-D.png",
            assign = function(img) Assets.images.bloodBoom.D[i] = img end
        })
    end

    Assets.images.bloodEffect = {G={}, D={}}
    table.insert(assetsToLoad, { path = "images/effet/blood-effect/blood-effect-4-G.png", assign = function(img) Assets.images.bloodEffect.G[1] = img end })
    table.insert(assetsToLoad, { path = "images/effet/blood-effect/blood-effect-5-G.png", assign = function(img) Assets.images.bloodEffect.G[2] = img end })
    table.insert(assetsToLoad, { path = "images/effet/blood-effect/blood-effect-6-G.png", assign = function(img) Assets.images.bloodEffect.G[3] = img end })
    table.insert(assetsToLoad, { path = "images/effet/blood-effect/blood-effect-4-D.png", assign = function(img) Assets.images.bloodEffect.D[1] = img end })
    table.insert(assetsToLoad, { path = "images/effet/blood-effect/blood-effect-5-D.png", assign = function(img) Assets.images.bloodEffect.D[2] = img end })
    table.insert(assetsToLoad, { path = "images/effet/blood-effect/blood-effect-6-D.png", assign = function(img) Assets.images.bloodEffect.D[3] = img end })

    Assets.images.sparkle = {G={}, D={}}
    for i = 1, 8 do
        table.insert(assetsToLoad, {
            path = "images/effet/sparkle-effect/sparkle-"..i.."-G.png",
            assign = function(img) Assets.images.sparkle.G[i] = img end
        })
        table.insert(assetsToLoad, {
            path = "images/effet/sparkle-effect/sparkle-"..i.."-D.png",
            assign = function(img) Assets.images.sparkle.D[i] = img end
        })
    end

end

function Assets.getAssetsToLoad()
    return assetsToLoad
end

return Assets