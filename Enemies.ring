#===================================================================#
# Space Shooter 3D - Enemy Fleet Class (OOP)
# Dogfight AI State Machine, Wave Spawner & 3D Fleet Rendering
#===================================================================#

class EnemyFleet
    enemiesList
    currentWave
    maxWaves
    waveTimer
    waveActive
    waveDelay
    targetLockIdx
    minTargetDist
    behindCount
    closestBehindDist
    # Dynamic Fleet Scales & Orientations
    scoutScale
    scoutRotOff
    scoutYOff
    fighterScale
    fighterRotOff
    fighterYOff
    interceptorScale
    interceptorRotOff
    interceptorYOff
    bossScale
    bossRotOff
    bossYOff

    func init
        maxWaves  = 10
        waveDelay = 2.5
        scoutScale        = 2.60
        scoutRotOff       = 90.0
        scoutYOff         = 0.0
        fighterScale      = 0.26
        fighterRotOff     = 90.0
        fighterYOff       = 0.0
        interceptorScale  = 1.15
        interceptorRotOff = 0.0
        interceptorYOff   = 0.0
        bossScale         = 2.90
        bossRotOff        = 0.0
        bossYOff          = 0.0
        reset()
        return self
    end

    func setEnemyScales sScout, rScout, yScout, sFighter, rFighter, yFighter, sInter, rInter, yInter, sBoss, rBoss, yBoss
        scoutScale        = sScout
        scoutRotOff       = rScout
        scoutYOff         = yScout
        fighterScale      = sFighter
        fighterRotOff     = rFighter
        fighterYOff       = yFighter
        interceptorScale  = sInter
        interceptorRotOff = rInter
        interceptorYOff   = yInter
        bossScale         = sBoss
        bossRotOff        = rBoss
        bossYOff          = yBoss
    end

    func reset
        enemiesList       = []
        currentWave       = 1
        waveTimer         = 0.0
        waveActive        = False
        targetLockIdx     = 0
        minTargetDist     = 9999.0
        behindCount       = 0
        closestBehindDist = 9999.0
    end

    func createEnemy x, y, z, eType, hp, spd, ox, oy
        pos = Vector3(x, y, z)
        vel = Vector3(0.0, 0.0, -spd)
        offset = Vector3(ox, oy, 0.0)
        return [
            pos,
            vel,
            eType,
            hp,
            hp,
            spd,
            GetRandomValue(4, 12) / 10.0, # shootTimer
            0.0,                          # timeAlive
            0,                            # aiState (0: Approach)
            0.0,                          # stateTimer
            0.0, 180.0, 0.0,              # rotPitch, rotYaw, rotRoll
            offset                        # formation scatter offset
        ]
    end

    func spawnWave waveNum, pPos, fx, fz
        currentWave = waveNum
        waveActive  = True
        waveTimer   = 0.0
        enemiesList = []

        spawnDist = 340.0
        baseX = pPos.x + fx * spawnDist
        baseY = pPos.y + 4.0
        baseZ = pPos.z + fz * spawnDist

        rX = -fz
        rZ = fx

        if waveNum = 1 # Wave 1: 2 Scouts in dogfight formation (spacious opening)
            for i = 1 to 2
                ox = (i - 1.5) * 24.0
                enemiesList + createEnemy(baseX + rX * ox, baseY + 2.0, baseZ + rZ * ox + fz * (i * 12.0), 1, 28, 20.0, ox, 1.5)
            next
        elseif waveNum = 2 # Wave 2: 3 Fighters in V-formation
            for i = 1 to 3
                ox = (i - 2) * 16.0
                distFwd = fabs(i - 2) * 14.0
                enemiesList + createEnemy(baseX + rX * ox + fx * distFwd, baseY + fabs(i - 2) * 2.0, baseZ + rZ * ox + fz * distFwd, 2, 40, 22.0, ox, 2.0)
            next
        elseif waveNum = 3 # Wave 3: 4 Interceptors
            for i = 1 to 4
                ox = (i - 2.5) * 18.0
                enemiesList + createEnemy(baseX + rX * ox, baseY + GetRandomValue(-4, 12), baseZ + rZ * ox + fz * (i * 10.0), 3, 55, 25.0, ox, 0.0)
            next
        elseif waveNum = 4 # Wave 4: Scouts + Fighters
            for i = 1 to 4
                ox = (i - 2.5) * 14.0
                enemiesList + createEnemy(baseX + rX * ox, baseY + 4.0, baseZ + rZ * ox + fz * (i * 8.0), 1, 35, 20.0, ox, 2.0)
                enemiesList + createEnemy(baseX + rX * ox + fx * 25.0, baseY - 3.0, baseZ + rZ * ox + fz * (25.0 + i * 8.0), 2, 50, 22.0, ox, -2.0)
            next
        elseif waveNum = 5 # Wave 5: Mini Boss Cruiser + Escorts
            enemiesList + createEnemy(baseX, baseY + 6.0, baseZ + fz * 20.0, 4, 320, 16.0, 0.0, 3.0)
            enemiesList + createEnemy(baseX - rX * 18.0, baseY + 3.0, baseZ - rZ * 18.0 + fz * 6.0, 2, 50, 22.0, -10.0, 1.0)
            enemiesList + createEnemy(baseX + rX * 18.0, baseY + 3.0, baseZ + rZ * 18.0 + fz * 6.0, 2, 50, 22.0, 10.0, 1.0)
        elseif waveNum = 6 # Wave 6: Fast Interceptor Swarm
            for i = 1 to 8
                ox = GetRandomValue(-35, 35)
                oy = GetRandomValue(-8, 16)
                enemiesList + createEnemy(baseX + rX * ox, baseY + oy, baseZ + rZ * ox + fz * (i * 10.0), 3, 65, 26.0, ox, oy)
            next
        elseif waveNum = 7 # Wave 7: Heavy Pincer Assault
            for i = 1 to 4
                enemiesList + createEnemy(baseX - rX * 26.0, baseY + 4.0, baseZ - rZ * 26.0 + fz * (i * 14.0), 3, 75, 24.0, -16.0, 2.0)
                enemiesList + createEnemy(baseX + rX * 26.0, baseY + 4.0, baseZ + rZ * 26.0 + fz * (i * 14.0), 3, 75, 24.0, 16.0, 2.0)
            next
        elseif waveNum = 8 # Wave 8: Double Cruisers
            enemiesList + createEnemy(baseX - rX * 16.0, baseY + 6.0, baseZ - rZ * 16.0 + fz * 22.0, 4, 250, 17.0, -10.0, 3.0)
            enemiesList + createEnemy(baseX + rX * 16.0, baseY + 6.0, baseZ + rZ * 16.0 + fz * 22.0, 4, 250, 17.0, 10.0, 3.0)
            enemiesList + createEnemy(baseX, baseY, baseZ + fz * 6.0, 2, 60, 22.0, 0.0, 0.0)
        elseif waveNum = 9 # Wave 9: All-Out Armada
            for i = 1 to 5
                ox = (i - 3) * 14.0
                enemiesList + createEnemy(baseX + rX * ox, baseY + 6.0, baseZ + rZ * ox + fz * (i * 10.0), 1, 40, 22.0, ox, 2.0)
                enemiesList + createEnemy(baseX + rX * ox + fx * 28.0, baseY - 3.0, baseZ + rZ * ox + fz * (28.0 + i * 10.0), 3, 80, 26.0, ox, -2.0)
            next
        elseif waveNum >= 10 # Final Wave: Supreme MotherShip Boss + Elite Interceptors
            enemiesList + createEnemy(baseX, baseY + 8.0, baseZ + fz * 35.0, 4, 700, 15.0, 0.0, 4.0)
            for i = 1 to 4
                ox = (i - 2.5) * 18.0
                enemiesList + createEnemy(baseX + rX * ox, baseY + 3.0, baseZ + rZ * ox + fz * 10.0, 3, 85, 26.0, ox, 1.0)
            next
        ok
    end

    func update dt, player, weaponSystem, sndEnemyLaser
        playerPos    = player.pos
        fwdX         = player.fwdX
        fwdY         = player.fwdY
        fwdZ         = player.fwdZ
        forwardSpeed = player.forwardSpeed

        targetLockIdx     = 0
        minTargetDist     = 9999.0
        behindCount       = 0
        closestBehindDist = 9999.0

        for i = len(enemiesList) to 1 step -1
            e = ref(enemiesList[i])
            e[8] += dt      # timeAlive
            e[10] -= dt     # stateTimer
            aiState = e[9]
            eType   = e[3]
            spd     = e[6]
            turnAgility = 4.2
            if eType = 3 turnAgility = 5.5 ok
            if eType = 4 turnAgility = 2.5 ok

            distToP = getDistance3D(e[1], playerPos)

            # Target Lock Tracking
            if distToP < minTargetDist
                minTargetDist = distToP
                targetLockIdx = i
            ok

            # Rear Radar Threat Detection
            toEnemy = Vector3(e[1].x - playerPos.x, e[1].y - playerPos.y, e[1].z - playerPos.z)
            dotFwd  = toEnemy.x * fwdX + toEnemy.y * fwdY + toEnemy.z * fwdZ
            if dotFwd < 0 and distToP < 175.0
                behindCount++
                if distToP < closestBehindDist
                    closestBehindDist = distToP
                ok
            ok

            # Distance tether: return to combat arena if too far (>580m)
            if distToP > 580.0
                toP = normalizeVector3(Vector3(playerPos.x - e[1].x, playerPos.y - e[1].y, playerPos.z - e[1].z))
                e[2].x = toP.x * (spd + 18.0)
                e[2].y = toP.y * (spd + 18.0)
                e[2].z = toP.z * (spd + 18.0)
                e[9] = 0 # Return to Approach
            else
                # State 0: APPROACH (Head-on attack)
                if aiState = 0
                    targetPos = Vector3(playerPos.x + e[14].x, playerPos.y + e[14].y, playerPos.z + e[14].z)
                    toTarget = normalizeVector3(Vector3(targetPos.x - e[1].x, targetPos.y - e[1].y, targetPos.z - e[1].z))
                    e[2].x += (toTarget.x * spd - e[2].x) * turnAgility * dt
                    e[2].y += (toTarget.y * spd - e[2].y) * turnAgility * dt
                    e[2].z += (toTarget.z * spd - e[2].z) * turnAgility * dt

                    if distToP < 24.0
                        e[9] = 1 # FLYBY
                        e[10] = GetRandomValue(14, 22) / 10.0
                    ok

                # State 1: FLYBY (Zoom past cockpit across wide arena)
                elseif aiState = 1
                    if e[10] <= 0 or distToP > 130.0
                        e[9] = 2 # LOOP_TURN
                        e[10] = GetRandomValue(16, 26) / 10.0
                    ok

                # State 2: LOOP_TURN (180 wide tactical turn)
                elseif aiState = 2
                    toPlayer = normalizeVector3(Vector3(playerPos.x - e[1].x, playerPos.y - e[1].y, playerPos.z - e[1].z))
                    hardTurn = turnAgility * 2.2
                    e[2].x += (toPlayer.x * spd - e[2].x) * hardTurn * dt
                    e[2].y += (toPlayer.y * spd - e[2].y) * hardTurn * dt
                    e[2].z += (toPlayer.z * spd - e[2].z) * hardTurn * dt

                    hDir = normalizeVector3(e[2])
                    dotHead = hDir.x * toPlayer.x + hDir.y * toPlayer.y + hDir.z * toPlayer.z
                    if dotHead > 0.60 or e[10] <= 0
                        e[9] = 3 # CHASE
                        e[10] = GetRandomValue(35, 55) / 10.0
                    ok

                # State 3: CHASE (Pursue player rear with comfortable spacing)
                elseif aiState = 3
                    targetPos = Vector3(playerPos.x - fwdX * 65.0 + e[14].x, playerPos.y - fwdY * 65.0 + e[14].y, playerPos.z - fwdZ * 65.0 + e[14].z)
                    toTarget = normalizeVector3(Vector3(targetPos.x - e[1].x, targetPos.y - e[1].y, targetPos.z - e[1].z))
                    chaseSpd = forwardSpeed + spd * 0.30
                    e[2].x += (toTarget.x * chaseSpd - e[2].x) * turnAgility * dt
                    e[2].y += (toTarget.y * chaseSpd - e[2].y) * turnAgility * dt
                    e[2].z += (toTarget.z * chaseSpd - e[2].z) * turnAgility * dt

                    if e[10] <= 0 or distToP < 16.0
                        e[9] = 0 # Return to Approach
                    ok
                ok
            ok

            # Update 3D position
            e[1].x += e[2].x * dt
            e[1].y += e[2].y * dt
            e[1].z += e[2].z * dt

            # Vast Altitude bounds
            if e[1].y < -160.0 e[2].y = fabs(e[2].y) ok
            if e[1].y >  160.0 e[2].y = -fabs(e[2].y) ok

            # Enemy Shooting
            e[7] += dt
            shootInterval = 1.4
            if eType = 4 shootInterval = 0.85 ok
            if eType = 3 shootInterval = 1.15 ok
            if eType = 1 shootInterval = 1.60 ok

            if e[7] >= shootInterval and distToP < 95.0
                toPDir = normalizeVector3(Vector3(playerPos.x - e[1].x, playerPos.y - e[1].y, playerPos.z - e[1].z))
                hDir   = normalizeVector3(e[2])
                dotVal = hDir.x * toPDir.x + hDir.y * toPDir.y + hDir.z * toPDir.z

                if dotVal > 0.35
                    e[7] = 0.0
                    laserSpd = 50.0
                    spawnPos = Vector3(e[1].x + hDir.x * 2.0, e[1].y + hDir.y * 2.0, e[1].z + hDir.z * 2.0)
                    weaponSystem.spawnEnemyLaser(spawnPos, toPDir, laserSpd, 9, sndEnemyLaser)
                ok
            ok
        next
    end

    func draw modelScout, modelFighter, modelInterceptor, modelBoss
        strobeOn = (sin(GetTime() * 9.0) > 0.2)

        for i = 1 to len(enemiesList)
            en = enemiesList[i]
            ePos  = en[1]
            eVel  = en[2]
            eType = en[3]

            curModel  = modelFighter
            eColor    = WHITE
            eScale    = 0.95
            curRotOff = 0.0
            curYOff   = 0.0

            if eType = 1 # Scout Drone
                curModel  = modelScout
                eColor    = WHITE
                eScale    = scoutScale
                curRotOff = scoutRotOff
                curYOff   = scoutYOff
            elseif eType = 2 # Strike Fighter
                curModel  = modelFighter
                eColor    = WHITE
                eScale    = fighterScale
                curRotOff = fighterRotOff
                curYOff   = fighterYOff
            elseif eType = 3 # Stealth Interceptor
                curModel  = modelInterceptor
                eColor    = WHITE
                eScale    = interceptorScale
                curRotOff = interceptorRotOff
                curYOff   = interceptorYOff
            elseif eType = 4 # Dreadnought Flagship Boss
                curModel  = modelBoss
                eColor    = WHITE
                eScale    = bossScale
                curRotOff = bossRotOff
                curYOff   = bossYOff
            ok

            # 3D Orientation from velocity
            currVelSpd = sqrt(eVel.x*eVel.x + eVel.y*eVel.y + eVel.z*eVel.z)
            if currVelSpd > 0.1
                eFx = eVel.x / currVelSpd
                eFy = eVel.y / currVelSpd
                eFz = eVel.z / currVelSpd
            else
                eFx = 0.0
                eFy = 0.0
                eFz = -1.0
            ok

            hLen = sqrt(eFx*eFx + eFz*eFz)
            if hLen > 0.001
                eR0x = eFz / hLen
                eR0y = 0.0
                eR0z = -eFx / hLen
            else
                eR0x = 1.0
                eR0y = 0.0
                eR0z = 0.0
            ok

            eU0x = eFy * eR0z
            eU0y = hLen
            eU0z = -eFy * eR0x

            if curRotOff = 90.0 # Mesh has its nose along -X (Fighter 38 / Fighter 232)
                curModel.transform.m0  = -eFx
                curModel.transform.m1  = -eFy
                curModel.transform.m2  = -eFz
                curModel.transform.m3  = 0.0
                curModel.transform.m4  = eU0x
                curModel.transform.m5  = eU0y
                curModel.transform.m6  = eU0z
                curModel.transform.m7  = 0.0
                curModel.transform.m8  = eR0x
                curModel.transform.m9  = eR0y
                curModel.transform.m10 = eR0z
                curModel.transform.m11 = 0.0
                curModel.transform.m12 = 0.0
                curModel.transform.m13 = 0.0
                curModel.transform.m14 = 0.0
                curModel.transform.m15 = 1.0
            else # Standard starfighter models: Z is forward, X is right, Y is up
                curModel.transform.m0  = eR0x
                curModel.transform.m1  = eR0y
                curModel.transform.m2  = eR0z
                curModel.transform.m3  = 0.0
                curModel.transform.m4  = eU0x
                curModel.transform.m5  = eU0y
                curModel.transform.m6  = eU0z
                curModel.transform.m7  = 0.0
                curModel.transform.m8  = eFx
                curModel.transform.m9  = eFy
                curModel.transform.m10 = eFz
                curModel.transform.m11 = 0.0
                curModel.transform.m12 = 0.0
                curModel.transform.m13 = 0.0
                curModel.transform.m14 = 0.0
                curModel.transform.m15 = 1.0
            ok

            if curYOff != 0.0
                eDrawPos = Vector3(
                    ePos.x - eU0x * (curYOff * eScale),
                    ePos.y - eU0y * (curYOff * eScale),
                    ePos.z - eU0z * (curYOff * eScale)
                )
                DrawModel(curModel, eDrawPos, eScale, eColor)
            else
                DrawModel(curModel, ePos, eScale, eColor)
            ok

            # High-Detail Composite Ship Details per Type
            if eType = 1 # Scout (Viper Dart)
                # Glowing Glass Cockpit Canopy Visor
                canopyPos = Vector3(ePos.x + eFx * 1.4 + eU0x * 0.7, ePos.y + eFy * 1.4 + eU0y * 0.7, ePos.z + eFz * 1.4 + eU0z * 0.7)
                DrawSphere(canopyPos, 0.40, SKYBLUE)
                DrawSphere(canopyPos, 0.22, WHITE)

                # Navigation Strobe Beacons on Delta Wingtips
                if strobeOn
                    leftStrobe  = Vector3(ePos.x - eFx * 2.2 - eR0x * 3.8, ePos.y - eFy * 2.2 - eR0y * 3.8, ePos.z - eFz * 2.2 - eR0z * 3.8)
                    rightStrobe = Vector3(ePos.x - eFx * 2.2 + eR0x * 3.8, ePos.y - eFy * 2.2 + eR0y * 3.8, ePos.z - eFz * 2.2 + eR0z * 3.8)
                    DrawSphere(leftStrobe, 0.25, RED)
                    DrawSphere(rightStrobe, 0.25, GREEN)
                ok

                # Multi-stage Thruster Plume
                rPos = Vector3(ePos.x - eFx * 3.8, ePos.y - eFy * 3.8, ePos.z - eFz * 3.8)
                DrawSphere(rPos, 0.38, LIME)
                DrawSphere(Vector3(rPos.x - eFx * 0.9, rPos.y - eFy * 0.9, rPos.z - eFz * 0.9), 0.24, YELLOW)
                DrawSphere(Vector3(rPos.x - eFx * 1.6, rPos.y - eFy * 1.6, rPos.z - eFz * 1.6), 0.15, WHITE)

            elseif eType = 2 # Fighter (Strike Raider)
                # Cockpit Glass Visor
                canopyPos = Vector3(ePos.x + eFx * 1.2 + eU0x * 0.8, ePos.y + eFy * 1.2 + eU0y * 0.8, ePos.z + eFz * 1.2 + eU0z * 0.8)
                DrawSphere(canopyPos, 0.45, GOLD)
                DrawSphere(canopyPos, 0.22, WHITE)

                # Wingtip Navigation Beacons
                if strobeOn
                    leftStrobe  = Vector3(ePos.x - eR0x * 4.2, ePos.y - eR0y * 4.2, ePos.z - eR0z * 4.2)
                    rightStrobe = Vector3(ePos.x + eR0x * 4.2, ePos.y + eR0y * 4.2, ePos.z + eR0z * 4.2)
                    DrawSphere(leftStrobe, 0.26, RED)
                    DrawSphere(rightStrobe, 0.26, GREEN)
                ok

                # Twin Nacelle Exhaust Plumes
                pL = Vector3(ePos.x - eFx * 3.6 - eR0x * 2.0, ePos.y - eFy * 3.6 - eR0y * 2.0, ePos.z - eFz * 3.6 - eR0z * 2.0)
                pR = Vector3(ePos.x - eFx * 3.6 + eR0x * 2.0, ePos.y - eFy * 3.6 + eR0y * 2.0, ePos.z - eFz * 3.6 + eR0z * 2.0)
                DrawSphere(pL, 0.38, ORANGE)
                DrawSphere(pR, 0.38, ORANGE)
                DrawSphere(Vector3(pL.x - eFx * 0.8, pL.y - eFy * 0.8, pL.z - eFz * 0.8), 0.24, GOLD)
                DrawSphere(Vector3(pR.x - eFx * 0.8, pR.y - eFy * 0.8, pR.z - eFz * 0.8), 0.24, GOLD)

            elseif eType = 3 # Interceptor (Razor Wing)
                # Predatory Red Cockpit Dome
                canopyPos = Vector3(ePos.x + eFx * 1.8 + eU0x * 0.8, ePos.y + eFy * 1.8 + eU0y * 0.8, ePos.z + eFz * 1.8 + eU0z * 0.8)
                DrawSphere(canopyPos, 0.42, RED)
                DrawSphere(canopyPos, 0.20, YELLOW)

                # Forward-Swept Wingtip Cannons
                tipL = Vector3(ePos.x + eFx * 2.4 - eR0x * 5.2, ePos.y + eFy * 2.4 - eR0y * 5.2, ePos.z + eFz * 2.4 - eR0z * 5.2)
                tipR = Vector3(ePos.x + eFx * 2.4 + eR0x * 5.2, ePos.y + eFy * 2.4 + eR0y * 5.2, ePos.z + eFz * 2.4 + eR0z * 5.2)
                DrawSphere(tipL, 0.30, RED)
                DrawSphere(tipR, 0.30, RED)

                if strobeOn
                    DrawSphere(tipL, 0.40, MAROON)
                    DrawSphere(tipR, 0.40, MAROON)
                ok

                # Triple Razor Thrusters
                pC = Vector3(ePos.x - eFx * 4.0, ePos.y - eFy * 4.0, ePos.z - eFz * 4.0)
                pL = Vector3(ePos.x - eFx * 3.7 - eR0x * 1.3, ePos.y - eFy * 3.7 - eR0y * 1.3, ePos.z - eFz * 3.7 - eR0z * 1.3)
                pR = Vector3(ePos.x - eFx * 3.7 + eR0x * 1.3, ePos.y - eFy * 3.7 + eR0y * 1.3, ePos.z - eFz * 3.7 + eR0z * 1.3)
                DrawSphere(pC, 0.42, RED)
                DrawSphere(pL, 0.32, ORANGE)
                DrawSphere(pR, 0.32, ORANGE)
                DrawSphere(Vector3(pC.x - eFx * 0.9, pC.y - eFy * 0.9, pC.z - eFz * 0.9), 0.22, YELLOW)

            elseif eType = 4 # Boss (Titan Dreadnought)
                # Command Citadel Bridge Windows (Glowing Amber / Gold)
                bridgePos = Vector3(ePos.x - eFx * 3.8 + eU0x * 5.2, ePos.y - eFy * 3.8 + eU0y * 5.2, ePos.z - eFz * 3.8 + eU0z * 5.2)
                DrawCube(bridgePos, 3.4, 1.2, 2.2, GOLD)
                DrawCubeWires(bridgePos, 3.6, 1.4, 2.4, YELLOW)

                # Active Titan Energy Shield Grid
                DrawSphereWires(ePos, 14.5, 8, 8, RAYLibColor(255, 170, 0, 60))

                # Quad Massive Engine Blocks
                for b = 1 to 4
                    bOffset = (b - 2.5) * 2.8
                    bPos = Vector3(ePos.x - eFx * 12.0 + eR0x * bOffset, ePos.y - eFy * 12.0 + eR0y * bOffset, ePos.z - eFz * 12.0 + eR0z * bOffset)
                    DrawSphere(bPos, 0.90, ORANGE)
                    DrawSphere(Vector3(bPos.x - eFx * 1.6, bPos.y - eFy * 1.6, bPos.z - eFz * 1.6), 0.60, GOLD)
                    DrawSphere(Vector3(bPos.x - eFx * 3.0, bPos.y - eFy * 3.0, bPos.z - eFz * 3.0), 0.35, WHITE)
                next
            ok

            # Floating 3D Health Bar
            barW = 3.2
            barElev = 2.5
            if eType = 4
                barW = 12.0
                barElev = 6.2
            ok
            healthPct = en[4] / en[5]
            if healthPct < 0 healthPct = 0 ok
            barPos = Vector3(ePos.x, ePos.y + barElev, ePos.z)
            DrawCube(barPos, barW, 0.20, 0.20, DARKGRAY)
            DrawCube(Vector3(barPos.x - (barW * (1.0 - healthPct))/2.0, barPos.y, barPos.z), barW * healthPct, 0.24, 0.24, GREEN)

            # Target Lock Bracket on Closest Enemy
            if i = targetLockIdx
                lockRadius = 3.8
                if eType = 4 lockRadius = 9.5 ok
                DrawSphereWires(ePos, lockRadius, 6, 6, RED)
                DrawCubeWires(ePos, lockRadius * 1.2, lockRadius * 1.2, lockRadius * 1.2, GOLD)
            ok
        next
    end

    func count
        return len(enemiesList)
    end
end
