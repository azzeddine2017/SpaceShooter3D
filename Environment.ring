#===================================================================#
# Space Shooter 3D - Environment Classes (OOP)
# Starfield, Textured Celestial Planets, Mineral Asteroids & Gates
#===================================================================#

MAX_STARS     = 300
MAX_ASTEROIDS = 20

# -------------------------------------------------------------------
# 3D Starfield & Textured Celestial Planets Class
# -------------------------------------------------------------------
class Starfield
    starsList
    maxStars

    # Textured 3D Planet Models & Textures
    modelAurelia
    texAurelia
    rotAurelia

    modelIgnis
    texIgnis
    rotIgnis

    modelVerdia
    texVerdia
    rotVerdia

    hasPlanetModels

    func init
        maxStars = MAX_STARS
        starsList = list(maxStars)

        for i = 1 to maxStars
            sPos = Vector3(GetRandomValue(-800, 800), GetRandomValue(-500, 500), GetRandomValue(-800, 800))
            # Stellar classification spectral types
            sCol = WHITE
            sSz  = 0.18
            rndType = GetRandomValue(1, 100)
            if rndType <= 24
                sCol = SKYBLUE                        # Class B: Blue Giant
                sSz  = 0.24
            elseif rndType <= 42
                sCol = GOLD                           # Class G: Solar Gold
                sSz  = 0.22
            elseif rndType <= 55
                sCol = RAYLibColor(255, 120, 100, 255) # Class M: Red Dwarf
                sSz  = 0.18
            ok
            starsList[i] = [sPos, sCol, sSz]
        next

        rotAurelia = 0.0
        rotIgnis   = 0.0
        rotVerdia  = 0.0
        hasPlanetModels = false

        initPlanetaryTextures()

        return self
    end

    func initPlanetaryTextures
        # 1. Planet Aurelia (Azure Gas Giant with Atmospheric Cloud Bands)
        imgAurelia = GenImagePerlinNoise(512, 256, 16, 64, 4.0)
        ImageColorTint(imgAurelia, RAYLibColor(70, 150, 255, 255))
        texAurelia = LoadTextureFromImage(imgAurelia)
        GenTextureMipmaps(texAurelia)
        UnloadImage(imgAurelia)

        meshAurelia  = GenMeshSphere(92.0, 32, 32)
        modelAurelia = LoadModelFromMesh(meshAurelia)
        modelAurelia.transform = MatrixIdentity()
        SetModelMaterialTexture(modelAurelia, 0, MATERIAL_MAP_DIFFUSE, texAurelia)

        # 2. Planet Ignis (Volcanic Magma World with Tectonic Fissures)
        imgIgnis = GenImageCellular(512, 256, 32)
        ImageColorTint(imgIgnis, RAYLibColor(255, 80, 25, 255))
        texIgnis = LoadTextureFromImage(imgIgnis)
        GenTextureMipmaps(texIgnis)
        UnloadImage(imgIgnis)

        meshIgnis  = GenMeshSphere(72.0, 32, 32)
        modelIgnis = LoadModelFromMesh(meshIgnis)
        modelIgnis.transform = MatrixIdentity()
        SetModelMaterialTexture(modelIgnis, 0, MATERIAL_MAP_DIFFUSE, texIgnis)

        # 3. Planet Verdia (Emerald & Jade Oceanic World)
        imgVerdia = GenImagePerlinNoise(512, 256, 24, 24, 3.2)
        ImageColorTint(imgVerdia, RAYLibColor(35, 205, 125, 255))
        texVerdia = LoadTextureFromImage(imgVerdia)
        GenTextureMipmaps(texVerdia)
        UnloadImage(imgVerdia)

        meshVerdia  = GenMeshSphere(64.0, 32, 32)
        modelVerdia = LoadModelFromMesh(meshVerdia)
        modelVerdia.transform = MatrixIdentity()
        SetModelMaterialTexture(modelVerdia, 0, MATERIAL_MAP_DIFFUSE, texVerdia)

        hasPlanetModels = true
    end

    func update dt, playerPos, fwdX, fwdY, fwdZ
        # Rotate planets slowly on their planetary axes
        rotAurelia += dt * 3.5
        rotIgnis   += dt * 2.2
        rotVerdia  += dt * 2.8

        for i = 1 to maxStars
            sPos = starsList[i][1]
            dx = sPos.x - playerPos.x
            dy = sPos.y - playerPos.y
            dz = sPos.z - playerPos.z
            distSq = dx*dx + dy*dy + dz*dz
            if distSq > (900.0 * 900.0)
                sPos.x = playerPos.x + fwdX * GetRandomValue(500, 850) + GetRandomValue(-400, 400)
                sPos.y = playerPos.y + fwdY * GetRandomValue(500, 850) + GetRandomValue(-300, 300)
                sPos.z = playerPos.z + fwdZ * GetRandomValue(500, 850) + GetRandomValue(-400, 400)
            ok
        next
    end

    func drawPlanets
        # -----------------------------------------------------------
        # 1. Planet Aurelia (Textured Azure Gas Giant with Tilted Rings)
        # -----------------------------------------------------------
        p1Pos = Vector3(-750.0, -220.0, 850.0)
        p1Rad = 92.0

        if hasPlanetModels
            DrawModelEx(modelAurelia, p1Pos, Vector3(0.38, 1.0, 0.15), rotAurelia, Vector3(1.0, 1.0, 1.0), WHITE)
        else
            DrawSphere(p1Pos, p1Rad, RAYLibColor(30, 95, 185, 255))
        ok

        # Tilted Planetary Ring System (Like Saturn) - Aligned with axial tilt (0.38, 1.0, 0.15)
        ringSegments = 40
        for r = 0 to 4
            rRad = 125.0 + r * 16.0
            lastPt = Vector3(0.0, 0.0, 0.0)
            firstPt = Vector3(0.0, 0.0, 0.0)
            rCol = GOLD
            if r = 1 or r = 3 rCol = SKYBLUE ok

            for seg = 1 to ringSegments
                ang = (seg * (360.0 / ringSegments)) * DEG2RAD
                rx = cos(ang) * rRad
                rz = sin(ang) * rRad
                ry = rx * 0.38 + rz * 0.15 # Matches 25° planetary axial tilt exactly
                pt = Vector3(p1Pos.x + rx, p1Pos.y + ry, p1Pos.z + rz)
                if seg = 1
                    firstPt = pt
                else
                    DrawLine3D(lastPt, pt, rCol)
                ok
                lastPt = pt
            next
            DrawLine3D(lastPt, firstPt, rCol)
        next

        # -----------------------------------------------------------
        # 2. Planet Ignis (Textured Volcanic Magma World)
        # -----------------------------------------------------------
        p2Pos = Vector3(780.0, 280.0, 880.0)
        p2Rad = 72.0

        if hasPlanetModels
            DrawModelEx(modelIgnis, p2Pos, Vector3(0.0, 1.0, 0.0), rotIgnis, Vector3(1.0, 1.0, 1.0), WHITE)
        else
            DrawSphere(p2Pos, p2Rad, RAYLibColor(170, 35, 20, 255))
        ok

        # -----------------------------------------------------------
        # 3. Planet Verdia (Textured Emerald & Jade Oceanic World)
        # -----------------------------------------------------------
        p3Pos = Vector3(520.0, -360.0, -850.0)
        p3Rad = 64.0

        if hasPlanetModels
            DrawModelEx(modelVerdia, p3Pos, Vector3(0.1, 1.0, 0.1), rotVerdia, Vector3(1.0, 1.0, 1.0), WHITE)
        else
            DrawSphere(p3Pos, p3Rad, RAYLibColor(18, 145, 95, 255))
        ok
    end

    func draw fwdX, fwdY, fwdZ, forwardSpeed
        # 1. Textured Celestial Planets in the Distant Sky
        drawPlanets()

        # 2. Multi-Spectral Starfield with Speed Warp Streaks
        starLen = 0.8 + (forwardSpeed / 10.0)
        for i = 1 to maxStars
            sPos = starsList[i][1]
            sCol = starsList[i][2]

            tail = Vector3(sPos.x - fwdX * starLen, sPos.y - fwdY * starLen, sPos.z - fwdZ * starLen)
            DrawLine3D(sPos, tail, sCol)
        next
    end

    func cleanup
        if hasPlanetModels
            UnloadTexture(texAurelia)
            UnloadModel(modelAurelia)

            UnloadTexture(texIgnis)
            UnloadModel(modelIgnis)

            UnloadTexture(texVerdia)
            UnloadModel(modelVerdia)

            hasPlanetModels = false
        ok
    end
end

# -------------------------------------------------------------------
# Wave-Scaled Asteroid Field Class - Vibrant Mineral Asteroids
# -------------------------------------------------------------------
class AsteroidField
    asteroids
    asteroidsList

    func init
        asteroids = []
        asteroidsList = asteroids
        reset(Vector3(0.0, 0.0, 0.0), 0.0, 0.0, 1.0)
        return self
    end

    func getTargetCount waveNum
        if waveNum < 1 waveNum = 1 ok
        count = 3 + (waveNum - 1) * 2
        if count > MAX_ASTEROIDS count = MAX_ASTEROIDS ok
        return count
    end

    func createSingleAsteroid pPos, fwdX, fwdY, fwdZ, minDist, maxDist
        fDist = GetRandomValue(minDist, maxDist)
        side  = GetRandomValue(-380, 380)
        elev  = GetRandomValue(-180, 180)

        rX = -fwdZ
        rZ = fwdX

        ax = pPos.x + fwdX * fDist + rX * side
        ay = pPos.y + fwdY * fDist + elev
        az = pPos.z + fwdZ * fDist + rZ * side

        aPos     = Vector3(ax, ay, az)
        aSize    = GetRandomValue(24, 60) / 10.0
        aRotSpd  = GetRandomValue(20, 80)
        aMinType = GetRandomValue(1, 4) # 1:Magma, 2:Ice, 3:Bronze/Gold, 4:Emerald
        return [aPos, aSize, aRotSpd, 0.0, 3, 3, aMinType]
    end

    func reset pPos, fwdX, fwdY, fwdZ
        while len(asteroids) > 0
            del(asteroids, 1)
        end
        initCount = getTargetCount(1)
        for i = 1 to initCount
            asteroids + createSingleAsteroid(pPos, fwdX, fwdY, fwdZ, 120 + (i * 45), 240 + (i * 65))
        next
        asteroidsList = asteroids
    end

    func syncToWave waveNum, pPos, fwdX, fwdY, fwdZ
        targetCount = getTargetCount(waveNum)
        while len(asteroids) < targetCount
            asteroids + createSingleAsteroid(pPos, fwdX, fwdY, fwdZ, 250, 680)
        end
        while len(asteroids) > targetCount
            del(asteroids, len(asteroids))
        end
        asteroidsList = asteroids
    end

    func update dt, playerPos, fwdX, fwdY, fwdZ
        rX = -fwdZ
        rZ = fwdX
        for i = 1 to len(asteroids)
            ast = ref(asteroids[i])
            ast[4] += ast[3] * dt # Rotation

            distP = getDistance3D(playerPos, ast[1])
            if distP > 720.0
                fDist = GetRandomValue(300, 680)
                side  = GetRandomValue(-380, 380)
                elev  = GetRandomValue(-180, 180)
                ast[1].x = playerPos.x + fwdX * fDist + rX * side
                ast[1].y = playerPos.y + fwdY * fDist + elev
                ast[1].z = playerPos.z + fwdZ * fDist + rZ * side
                ast[2]   = GetRandomValue(24, 60) / 10.0
                ast[5]   = 3
                ast[7]   = GetRandomValue(1, 4)
            ok
        next
    end

    func draw
        for i = 1 to len(asteroids)
            ast  = asteroids[i]
            aPos = ast[1]
            aSz  = ast[2]
            mType = 1
            if len(ast) >= 7 mType = ast[7] ok

            if mType = 1 # Volcanic Magma Asteroid (Glowing lava veins)
                DrawSphere(aPos, aSz, RAYLibColor(75, 25, 20, 255))
                DrawSphereWires(aPos, aSz + 0.05, 5, 6, ORANGE)
            elseif mType = 2 # Glacial Ice Asteroid (Crystalline cyan)
                DrawSphere(aPos, aSz, RAYLibColor(40, 95, 140, 255))
                DrawSphereWires(aPos, aSz + 0.06, 5, 6, SKYBLUE)
            elseif mType = 3 # Bronze & Gold Metallic Ore
                DrawSphere(aPos, aSz, RAYLibColor(120, 65, 35, 255))
                DrawSphereWires(aPos, aSz + 0.05, 5, 6, GOLD)
            else # Alien Kryptonite (Glowing green crystals)
                DrawSphere(aPos, aSz, RAYLibColor(30, 60, 35, 255))
                DrawSphereWires(aPos, aSz + 0.05, 5, 6, LIME)
            ok
        next
    end

    func checkPlayerCollisions player, particlesList, sndExplosion
        for i = 1 to len(asteroids)
            ast = ref(asteroids[i])
            distP = getDistance3D(player.pos, ast[1])
            if distP < (ast[2] + 1.8) and player.barrelRollTimer <= 0
                player.takeDamage(12, particlesList, sndExplosion)
                sparkCol = ORANGE
                if len(ast) >= 7
                    if ast[7] = 2 sparkCol = SKYBLUE ok
                    if ast[7] = 3 sparkCol = GOLD ok
                    if ast[7] = 4 sparkCol = LIME ok
                ok
                spawnExplosion(particlesList, ast[1], 25, sparkCol)
                PlaySound(sndExplosion)

                # Recycle asteroid safely ahead with broad spread
                astR_x  = -player.fwdZ
                astR_z  = player.fwdX
                astSide = GetRandomValue(-350, 350)
                astElev = GetRandomValue(-160, 160)
                astDist = GetRandomValue(300, 650)
                ast[1].x = player.pos.x + player.fwdX * astDist + astR_x * astSide
                ast[1].y = player.pos.y + player.fwdY * astDist + astElev
                ast[1].z = player.pos.z + player.fwdZ * astDist + astR_z * astSide
                ast[7]   = GetRandomValue(1, 4)
            ok
        next
    end
end

# -------------------------------------------------------------------
# Chrono-Gate Class (12-Segment Rotating Celestial Warp Rings)
# -------------------------------------------------------------------
class ChronoGate
    gates

    func init
        gates = []
        gates + [Vector3(0.0, 0.0, 300.0), 22.0, 0.0]
        gates + [Vector3(0.0, 0.0, 750.0), 22.0, 0.0]
        return self
    end

    func reset pPos, fwdX, fwdY, fwdZ
        gates[1][1] = Vector3(pPos.x + fwdX * 300.0, pPos.y + fwdY * 300.0, pPos.z + fwdZ * 300.0)
        gates[2][1] = Vector3(pPos.x + fwdX * 750.0, pPos.y + fwdY * 750.0, pPos.z + fwdZ * 750.0)
    end

    func update dt, player, particlesList, sndPowerup
        bonusScore = 0
        for i = 1 to len(gates)
            gate = gates[i]
            gate[3] += 45.0 * dt # Rotate clock dial
            distG = getDistance3D(player.pos, gate[1])

            # Player flew through the Chrono-Gate!
            if distG < gate[2]
                bonusScore += 250
                PlaySound(sndPowerup)
                player.applySpeedSurge(30.0)
                spawnExplosion(particlesList, gate[1], 40, SKYBLUE)

                # Reposition forward in the grand arena
                gate[1].x = player.pos.x + player.fwdX * GetRandomValue(600, 950) + GetRandomValue(-50, 50)
                gate[1].y = player.pos.y + player.fwdY * GetRandomValue(600, 950) + GetRandomValue(-30, 30)
                gate[1].z = player.pos.z + player.fwdZ * GetRandomValue(600, 950) + GetRandomValue(-50, 50)
            elseif distG > 850.0
                gate[1].x = player.pos.x + player.fwdX * GetRandomValue(600, 950) + GetRandomValue(-50, 50)
                gate[1].y = player.pos.y + player.fwdY * GetRandomValue(600, 950) + GetRandomValue(-30, 30)
                gate[1].z = player.pos.z + player.fwdZ * GetRandomValue(600, 950) + GetRandomValue(-50, 50)
            ok
        next
        return bonusScore
    end

    func draw
        SEGMENTS = 12 # 12 clock hour markers / energy conduits
        for i = 1 to len(gates)
            gate = gates[i]
            gPos = gate[1]
            gRad = gate[2]
            gRot = gate[3]

            lastSegPos = Vector3(0.0, 0.0, 0.0)
            firstSegPos = Vector3(0.0, 0.0, 0.0)

            for s = 1 to SEGMENTS
                ang = (s * (360.0 / SEGMENTS) + gRot) * DEG2RAD
                segPos = Vector3(gPos.x + cos(ang) * gRad, gPos.y + sin(ang) * gRad, gPos.z)
                DrawCube(segPos, 0.7, 0.7, 1.6, SKYBLUE)
                DrawCubeWires(segPos, 0.8, 0.8, 1.8, WHITE)

                # Radiant plasma beam connecting the 12 clock nodes
                if s = 1
                    firstSegPos = segPos
                else
                    DrawLine3D(lastSegPos, segPos, SKYBLUE)
                ok
                lastSegPos = segPos
            next
            # Close the ring
            DrawLine3D(lastSegPos, firstSegPos, SKYBLUE)

            # Central pulsating hyper-portal ring
            DrawSphereWires(gPos, 1.8, 8, 8, GOLD)
            DrawSphereWires(gPos, gRad * 0.45, 10, 10, SKYBLUE)
        next
    end
end
