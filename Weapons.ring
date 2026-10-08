#===================================================================#
# Space Shooter 3D - Weapons & Ballistics Class (OOP)
# Plasma Cannons, Enemy Blasters & Combat Collision Physics
#===================================================================#

class WeaponSystem
    playerLasers
    enemyLasers
    fireTimer
    fireCooldown

    func init
        reset()
        return self
    end

    func reset
        playerLasers = []
        enemyLasers  = []
        fireTimer    = 0.0
        fireCooldown = 0.17
    end

    # ---------------------------------------------------------------
    # Player Dual Plasma Cannons
    # ---------------------------------------------------------------
    func handlePlayerFiring dt, player, sndPlayerLaser, sndLaserUpgraded
        fireTimer += dt
        currentCooldown = fireCooldown
        if player.powerShotTimer > 0 currentCooldown = 0.09 ok

        if (IsKeyDown(KEY_SPACE) or IsMouseButtonDown(MOUSE_LEFT_BUTTON)) and fireTimer >= currentCooldown
            fireTimer = 0.0

            isMega = (player.powerShotTimer > 0)
            if isMega
                PlaySound(sndLaserUpgraded)
            else
                PlaySound(sndPlayerLaser)
            ok

            dmg = 20
            if isMega dmg = 45 ok

            # Dual wing mounts aligned with full 3D orthonormal basis
            p1X = player.pos.x + player.fwdX * 2.2 - player.rX * 2.2 - player.upX * 0.2
            p1Y = player.pos.y + player.fwdY * 2.2 - player.rY * 2.2 - player.upY * 0.2
            p1Z = player.pos.z + player.fwdZ * 2.2 - player.rZ * 2.2 - player.upZ * 0.2

            p2X = player.pos.x + player.fwdX * 2.2 + player.rX * 2.2 - player.upX * 0.2
            p2Y = player.pos.y + player.fwdY * 2.2 + player.rY * 2.2 - player.upY * 0.2
            p2Z = player.pos.z + player.fwdZ * 2.2 + player.rZ * 2.2 - player.upZ * 0.2

            laserShotSpd = player.forwardSpeed + 250.0
            velX = player.fwdX * laserShotSpd
            velY = player.fwdY * laserShotSpd
            velZ = player.fwdZ * laserShotSpd

            # Flat structure for 60 FPS performance: [x, y, z, vx, vy, vz, dmg, isMega, lifetime]
            playerLasers + [p1X, p1Y, p1Z, velX, velY, velZ, dmg, isMega, 2.0]
            playerLasers + [p2X, p2Y, p2Z, velX, velY, velZ, dmg, isMega, 2.0]
        ok
    end

    # ---------------------------------------------------------------
    # Enemy Laser Spawning
    # ---------------------------------------------------------------
    func spawnEnemyLaser originPos, dirVec, spd, dmg, sndEnemyLaser
        PlaySound(sndEnemyLaser)
        enemyLasers + [
            Vector3(originPos.x, originPos.y, originPos.z),
            Vector3(dirVec.x, dirVec.y, dirVec.z),
            spd,
            dmg,
            2.2 # lifetime
        ]
    end

    # ---------------------------------------------------------------
    # Update Ballistics & Lifetimes
    # ---------------------------------------------------------------
    func update dt
        # 1. Update Player Lasers
        for i = len(playerLasers) to 1 step -1
            playerLasers[i][1] += playerLasers[i][4] * dt
            playerLasers[i][2] += playerLasers[i][5] * dt
            playerLasers[i][3] += playerLasers[i][6] * dt
            playerLasers[i][9] -= dt
            if playerLasers[i][9] <= 0
                del(playerLasers, i)
            ok
        next

        # 2. Update Enemy Lasers
        for i = len(enemyLasers) to 1 step -1
            el = ref(enemyLasers[i])
            el[1].x += el[2].x * el[3] * dt
            el[1].y += el[2].y * el[3] * dt
            el[1].z += el[2].z * el[3] * dt
            el[5]   -= dt
            if el[5] <= 0
                del(enemyLasers, i)
            ok
        next
    end

    # ---------------------------------------------------------------
    # Render Lasers
    # ---------------------------------------------------------------
    func draw
        # 1. Draw Player Lasers
        for i = 1 to len(playerLasers)
            lx = playerLasers[i][1]
            ly = playerLasers[i][2]
            lz = playerLasers[i][3]
            vx = playerLasers[i][4]
            vy = playerLasers[i][5]
            vz = playerLasers[i][6]

            lPos = Vector3(lx, ly, lz)
            tail = Vector3(lx - vx * 0.030, ly - vy * 0.030, lz - vz * 0.030)

            if playerLasers[i][8] # Mega-Shot (Green)
                DrawSphere(lPos, 0.40, LIME)
                DrawLine3D(lPos, tail, GREEN)
            else # Standard (Cyan)
                DrawSphere(lPos, 0.28, SKYBLUE)
                DrawLine3D(lPos, tail, BLUE)
            ok
        next

        # 2. Draw Enemy Lasers
        for i = 1 to len(enemyLasers)
            elPos = enemyLasers[i][1]
            DrawSphere(elPos, 0.32, RED)
            DrawSphereWires(elPos, 0.42, 6, 6, MAROON)
        next
    end

    # ---------------------------------------------------------------
    # Combat Collisions
    # ---------------------------------------------------------------
    func checkPlayerLasersVsFleet fleetObj, powerupsList, particlesList, sndExplosion
        bonusScore = 0
        for i = len(playerLasers) to 1 step -1
            lx  = playerLasers[i][1]
            ly  = playerLasers[i][2]
            lz  = playerLasers[i][3]
            dmg = playerLasers[i][7]
            hitEnemy = False

            for j = len(fleetObj.enemiesList) to 1 step -1
                enPos = fleetObj.enemiesList[j][1]
                ex = enPos.x
                ey = enPos.y
                ez = enPos.z
                dx = lx - ex
                dy = ly - ey
                dz = lz - ez
                dist = sqrt(dx*dx + dy*dy + dz*dz)

                eType = fleetObj.enemiesList[j][3]
                hitRadius = 5.2
                if eType = 4 hitRadius = 11.5 ok # Boss has larger hitbox

                if dist < hitRadius
                    fleetObj.enemiesList[j][4] -= dmg
                    hitEnemy = True
                    spawnImpactSparks(particlesList, Vector3(lx, ly, lz), 4, YELLOW)

                    if fleetObj.enemiesList[j][4] <= 0
                        bonusScore += fleetObj.enemiesList[j][6] * 15
                        spawnExplosion(particlesList, enPos, 22, ORANGE)
                        PlaySound(sndExplosion)

                        # 20% powerup drop
                        if GetRandomValue(1, 100) <= 20
                            spawnRandomPowerup(powerupsList, ex, ey, ez)
                        ok

                        del(fleetObj.enemiesList, j)
                    ok
                    exit
                ok
            next

            if hitEnemy
                del(playerLasers, i)
            ok
        next
        return bonusScore
    end

    func checkPlayerLasersVsEnemies enemiesParam, powerupsList, particlesList, sndExplosion
        if isObject(enemiesParam)
            return checkPlayerLasersVsFleet(enemiesParam, powerupsList, particlesList, sndExplosion)
        ok
        bonusScore = 0
        for i = len(playerLasers) to 1 step -1
            lx  = playerLasers[i][1]
            ly  = playerLasers[i][2]
            lz  = playerLasers[i][3]
            dmg = playerLasers[i][7]
            hitEnemy = False

            for j = len(enemiesParam) to 1 step -1
                enPos = enemiesParam[j][1]
                ex = enPos.x
                ey = enPos.y
                ez = enPos.z
                dx = lx - ex
                dy = ly - ey
                dz = lz - ez
                dist = sqrt(dx*dx + dy*dy + dz*dz)

                eType = enemiesParam[j][3]
                hitRadius = 5.2
                if eType = 4 hitRadius = 11.5 ok

                if dist < hitRadius
                    enemiesParam[j][4] -= dmg
                    hitEnemy = True
                    spawnImpactSparks(particlesList, Vector3(lx, ly, lz), 4, YELLOW)

                    if enemiesParam[j][4] <= 0
                        bonusScore += enemiesParam[j][6] * 15
                        spawnExplosion(particlesList, enPos, 22, ORANGE)
                        PlaySound(sndExplosion)

                        if GetRandomValue(1, 100) <= 20
                            spawnRandomPowerup(powerupsList, ex, ey, ez)
                        ok

                        del(enemiesParam, j)
                    ok
                    exit
                ok
            next

            if hitEnemy
                del(playerLasers, i)
            ok
        next
        return bonusScore
    end

    func checkPlayerLasersVsAsteroids asteroidsParam, playerPos, fwdX, fwdY, fwdZ, particlesList, sndExplosion
        bonusScore = 0
        for i = len(playerLasers) to 1 step -1
            lx = playerLasers[i][1]
            ly = playerLasers[i][2]
            lz = playerLasers[i][3]
            hitAst = False

            numAst = 0
            if isObject(asteroidsParam)
                numAst = len(asteroidsParam.asteroids)
            else
                numAst = len(asteroidsParam)
            ok

            for k = 1 to numAst
                if isObject(asteroidsParam)
                    ax = asteroidsParam.asteroids[k][1].x
                    ay = asteroidsParam.asteroids[k][1].y
                    az = asteroidsParam.asteroids[k][1].z
                    aRadius = asteroidsParam.asteroids[k][2]
                else
                    ax = asteroidsParam[k][1].x
                    ay = asteroidsParam[k][1].y
                    az = asteroidsParam[k][1].z
                    aRadius = asteroidsParam[k][2]
                ok

                dx = lx - ax
                dy = ly - ay
                dz = lz - az
                dist = sqrt(dx*dx + dy*dy + dz*dz)

                if dist < (aRadius + 1.2)
                    hitAst = True
                    spawnImpactSparks(particlesList, Vector3(lx, ly, lz), 4, ORANGE)

                    if isObject(asteroidsParam)
                        asteroidsParam.asteroids[k][5] -= 1
                        if asteroidsParam.asteroids[k][5] <= 0
                            bonusScore += 50
                            spawnExplosion(particlesList, asteroidsParam.asteroids[k][1], 20, ORANGE)
                            PlaySound(sndExplosion)
                            astDist = GetRandomValue(180, 280)
                            astSide = GetRandomValue(-150, 150)
                            astElev = GetRandomValue(-60, 60)
                            asteroidsParam.asteroids[k][1].x = playerPos.x + fwdX * astDist - fwdZ * astSide
                            asteroidsParam.asteroids[k][1].y = playerPos.y + fwdY * astDist + astElev
                            asteroidsParam.asteroids[k][1].z = playerPos.z + fwdZ * astDist + fwdX * astSide
                            asteroidsParam.asteroids[k][5]   = 3
                        ok
                    else
                        asteroidsParam[k][5] -= 1
                        if asteroidsParam[k][5] <= 0
                            bonusScore += 50
                            spawnExplosion(particlesList, asteroidsParam[k][1], 20, ORANGE)
                            PlaySound(sndExplosion)
                            astDist = GetRandomValue(180, 280)
                            astSide = GetRandomValue(-150, 150)
                            astElev = GetRandomValue(-60, 60)
                            asteroidsParam[k][1].x = playerPos.x + fwdX * astDist - fwdZ * astSide
                            asteroidsParam[k][1].y = playerPos.y + fwdY * astDist + astElev
                            asteroidsParam[k][1].z = playerPos.z + fwdZ * astDist + fwdX * astSide
                            asteroidsParam[k][5]   = 3
                        ok
                    ok
                    exit
                ok
            next

            if hitAst
                del(playerLasers, i)
            ok
        next
        return bonusScore
    end

    func checkEnemyLasersVsPlayer player, particlesList, sndExplosion
        for i = len(enemyLasers) to 1 step -1
            el = ref(enemyLasers[i])
            distP = getDistance3D(el[1], player.pos)
            if distP < 2.5
                player.takeDamage(el[4], particlesList, sndExplosion)
                del(enemyLasers, i)
            ok
        next
    end

    # Aliases for compatibility
    func checkEnemyLasersAgainstPlayer player, particlesList, sndExplosion
        checkEnemyLasersVsPlayer(player, particlesList, sndExplosion)
    end

    func checkPlayerLasersAgainstEnemies fleetObj, particlesList, sndExplosion, powerupsList
        if isObject(fleetObj)
            return checkPlayerLasersVsFleet(fleetObj, powerupsList, particlesList, sndExplosion)
        else
            return checkPlayerLasersVsEnemies(fleetObj, powerupsList, particlesList, sndExplosion)
        ok
    end
end
