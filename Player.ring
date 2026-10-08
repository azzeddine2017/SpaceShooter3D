#===================================================================#
# Space Shooter 3D - Player Ship Class (OOP)
# 360° All-Range 6DOF Flight, Tactical U-Turns, Acrobatics & Render
#===================================================================#

class PlayerShip
    # 3D Position & Attitude
    pos
    yaw
    pitch
    roll
    targetRoll

    # Velocities & Throttle
    forwardSpeed
    cruiseSpeed
    boostSpeed
    brakeSpeed
    targetSpeed
    throttleState # -1: Brake, 0: Cruise, 1: Boost

    # Special Combat Maneuvers
    uTurnTimer
    barrelRollTimer
    barrelRollDir

    # Agility Settings
    turnSpeed
    pitchSpeed

    # Telemetry & Camera
    distanceTraveled
    targetFOV
    camShake

    # Orthonormal 3D Basis Vectors
    fwdX  fwdY  fwdZ
    rX    rY    rZ
    upX   upY   upZ

    # Combat Stats & Powerups
    health
    maxHealth
    powerShotTimer
    powerShieldTimer

    # Selected Starfighter Identity & Profile
    shipId
    combatScale
    rotOffset
    fireCooldown
    shipColor

    func init
        shipId       = 1
        combatScale  = 0.015
        rotOffset    = 0.0
        fireCooldown = 0.17
        shipColor    = RAYLibColor(90, 150, 210, 255)
        reset()
        return self
    end

    func setShipProfile bData
        shipId       = bData[1]
        combatScale  = bData[15]
        maxHealth    = bData[16]
        health       = maxHealth
        cruiseSpeed  = bData[17]
        boostSpeed   = bData[18]
        turnSpeed    = bData[19]
        fireCooldown = bData[20]
        shipColor    = bData[10]
        rotOffset    = bData[13]
        forwardSpeed = cruiseSpeed
        targetSpeed  = cruiseSpeed
    end

    func reset
        pos              = Vector3(0.0, 0.0, 0.0)
        yaw              = 0.0
        pitch            = 0.0
        roll             = 0.0
        targetRoll       = 0.0

        cruiseSpeed      = 52.0
        boostSpeed       = 115.0
        brakeSpeed       = 16.0
        forwardSpeed     = cruiseSpeed
        targetSpeed      = cruiseSpeed
        throttleState    = 0

        uTurnTimer       = 0.0
        barrelRollTimer  = 0.0
        barrelRollDir    = 0

        turnSpeed        = 110.0
        pitchSpeed       = 90.0

        distanceTraveled = 0.0
        targetFOV        = 56.0
        camShake         = 0.0

        fwdX = 0.0  fwdY = 0.0  fwdZ = 1.0
        rX = -1.0   rY = 0.0    rZ = 0.0
        upX = 0.0   upY = 1.0   upZ = 0.0

        maxHealth        = 120
        health           = maxHealth
        powerShotTimer   = 0.0
        powerShieldTimer = 0.0
    end

    func update dt, particlesList, sndPowerup
        # 1. Update Powerup Timers
        if powerShotTimer > 0
            powerShotTimer -= dt
            if powerShotTimer < 0 powerShotTimer = 0 ok
        ok
        if powerShieldTimer > 0
            powerShieldTimer -= dt
            if powerShieldTimer < 0 powerShieldTimer = 0 ok
        ok

        # 2. Camera Shake Dampening
        if camShake > 0
            camShake -= dt * 2.0
            if camShake < 0 camShake = 0 ok
        ok

        targetRoll = 0.0

        # 3. 180° Tactical U-Turn (Key U, F, or R)
        if uTurnTimer > 0
            uTurnTimer -= dt
            yaw += (180.0 / 0.65) * dt
            progress = (0.65 - uTurnTimer) / 0.65
            pitch    = sin(progress * PI) * 28.0
            roll     = sin(progress * PI) * 180.0
        else
            if IsKeyPressed(KEY_U) or IsKeyPressed(KEY_F) or IsKeyPressed(KEY_R)
                uTurnTimer = 0.65
                PlaySound(sndPowerup)
            ok

            # Continuous 360° Horizontal Steering (Yaw + Banking Roll)
            if IsKeyDown(KEY_LEFT) or IsKeyDown(KEY_A)
                yaw -= turnSpeed * dt
                targetRoll = -35.0
            ok
            if IsKeyDown(KEY_RIGHT) or IsKeyDown(KEY_D)
                yaw += turnSpeed * dt
                targetRoll = 35.0
            ok

            # Vertical Pitch (Climb Up / Dive Down)
            if IsKeyDown(KEY_UP) or IsKeyDown(KEY_W)
                pitch += pitchSpeed * dt
                if pitch > 75.0 pitch = 75.0 ok
            ok
            if IsKeyDown(KEY_DOWN) or IsKeyDown(KEY_S)
                pitch -= pitchSpeed * dt
                if pitch < -75.0 pitch = -75.0 ok
            ok

            # Auto-leveling pitch when no vertical input
            if !IsKeyDown(KEY_UP) and !IsKeyDown(KEY_W) and !IsKeyDown(KEY_DOWN) and !IsKeyDown(KEY_S)
                pitch += (0.0 - pitch) * 2.5 * dt
            ok

            # Acrobatic 360° Barrel Roll (Q / Z: Left, X: Right)
            if barrelRollTimer > 0
                barrelRollTimer -= dt
                roll += barrelRollDir * 720.0 * dt
            else
                if IsKeyPressed(KEY_Q) or IsKeyPressed(KEY_Z)
                    barrelRollTimer = 0.50
                    barrelRollDir   = -1 # Roll Left
                    PlaySound(sndPowerup)
                ok
                if IsKeyPressed(KEY_X)
                    barrelRollTimer = 0.50
                    barrelRollDir   = 1  # Roll Right
                    PlaySound(sndPowerup)
                ok
                roll += (targetRoll - roll) * 10.0 * dt
            ok
        ok

        # 4. Angle Normalization
        while yaw >= 360.0 yaw -= 360.0 end
        while yaw < 0.0   yaw += 360.0 end
        while roll >= 360.0 roll -= 360.0 end
        while roll < -360.0 roll += 360.0 end

        # 5. Compute Orthonormal Basis
        yawRad   = yaw * DEG2RAD
        pitchRad = pitch * DEG2RAD
        rollRad  = roll * DEG2RAD

        cosP = cos(pitchRad)
        sinP = sin(pitchRad)
        cosY = cos(yawRad)
        sinY = sin(yawRad)
        cosR = cos(rollRad)
        sinR = sin(rollRad)

        # Forward Vector: Turning Right steers towards -X (Screen-Right), Left towards +X (Screen-Left)
        fwdX = -sinY * cosP
        fwdY = sinP
        fwdZ = cosY * cosP

        # Base Right Vector (Roll = 0)
        r0X = -cosY
        r0Y = 0.0
        r0Z = -sinY

        # Base Up Vector (Roll = 0)
        u0X = sinY * sinP
        u0Y = cosP
        u0Z = -cosY * sinP

        # Banked Right & Up Vectors
        rX = r0X * cosR - u0X * sinR
        rY = r0Y * cosR - u0Y * sinR
        rZ = r0Z * cosR - u0Z * sinR

        upX = r0X * sinR + u0X * cosR
        upY = r0Y * sinR + u0Y * cosR
        upZ = r0Z * sinR + u0Z * cosR

        # 6. Throttle Management
        throttleState = 0
        targetSpeed   = cruiseSpeed
        targetFOV     = 56.0

        if IsKeyDown(KEY_LEFT_SHIFT) or IsKeyDown(KEY_RIGHT_SHIFT) or IsKeyDown(KEY_E)
            targetSpeed   = boostSpeed
            throttleState = 1
            targetFOV     = 68.0
            camShake      = 0.35
        elseif IsKeyDown(KEY_LEFT_CONTROL) or IsKeyDown(KEY_RIGHT_CONTROL) or IsKeyDown(KEY_C)
            targetSpeed   = brakeSpeed
            throttleState = -1
            targetFOV     = 50.0
        ok

        forwardSpeed += (targetSpeed - forwardSpeed) * 5.5 * dt

        # 7. Translation along true 3D Heading
        pos.x += fwdX * forwardSpeed * dt
        pos.y += fwdY * forwardSpeed * dt
        pos.z += fwdZ * forwardSpeed * dt
        distanceTraveled += forwardSpeed * dt

        # Vast 3D Arena Altitude Boundaries
        if pos.y < -380.0 pos.y = -380.0 ok
        if pos.y >  380.0 pos.y =  380.0 ok

        # 8. Boost speed surge handled by throttleState in draw()
    end

    func draw curModel
        if shipId = 2 or shipId = 3
            # Models 2 (Fighter 38) and 3 (Fighter 232):
            # In Blender raw OBJ: Nose is along -X, Exhaust is along +X, Canopy along +Y, Right wing along +Z
            # To fly forward along player heading:
            # -X (Nose) -> +fwd   =>  col 0 (model X) = -fwd
            # +Y (Canopy) -> +up  =>  col 1 (model Y) = +up
            # +Z (Right) -> +r    =>  col 2 (model Z) = +r
            curModel.transform.m0  = -fwdX
            curModel.transform.m1  = -fwdY
            curModel.transform.m2  = -fwdZ
            curModel.transform.m3  = 0.0
            curModel.transform.m4  = upX
            curModel.transform.m5  = upY
            curModel.transform.m6  = upZ
            curModel.transform.m7  = 0.0
            curModel.transform.m8  = rX
            curModel.transform.m9  = rY
            curModel.transform.m10 = rZ
            curModel.transform.m11 = 0.0
            curModel.transform.m12 = 0.0
            curModel.transform.m13 = 0.0
            curModel.transform.m14 = 0.0
            curModel.transform.m15 = 1.0
            DrawModel(curModel, pos, combatScale, WHITE)

        elseif shipId = 5
            # Model 5 (Attack Fighter):
            # In Blender raw OBJ: Z forward, X right, Y offset upward by ~760 units.
            curModel.transform.m0  = rX
            curModel.transform.m1  = rY
            curModel.transform.m2  = rZ
            curModel.transform.m3  = 0.0
            curModel.transform.m4  = upX
            curModel.transform.m5  = upY
            curModel.transform.m6  = upZ
            curModel.transform.m7  = 0.0
            curModel.transform.m8  = fwdX
            curModel.transform.m9  = fwdY
            curModel.transform.m10 = fwdZ
            curModel.transform.m11 = 0.0
            curModel.transform.m12 = 0.0
            curModel.transform.m13 = 0.0
            curModel.transform.m14 = 0.0
            curModel.transform.m15 = 1.0
            # Shift position down along player's UP axis by 760 * combatScale to align with center of flight & guns
            shipDrawPos = Vector3(
                pos.x - upX * (760.0 * combatScale),
                pos.y - upY * (760.0 * combatScale),
                pos.z - upZ * (760.0 * combatScale)
            )
            DrawModel(curModel, shipDrawPos, combatScale, WHITE)

        else
            # Standard Starfighters (Ship 1 Coyote, Ship 4 Intergalactic, Ship 6 Boss):
            # Raw OBJ: Z forward, X right, Y up
            curModel.transform.m0  = rX
            curModel.transform.m1  = rY
            curModel.transform.m2  = rZ
            curModel.transform.m3  = 0.0
            curModel.transform.m4  = upX
            curModel.transform.m5  = upY
            curModel.transform.m6  = upZ
            curModel.transform.m7  = 0.0
            curModel.transform.m8  = fwdX
            curModel.transform.m9  = fwdY
            curModel.transform.m10 = fwdZ
            curModel.transform.m11 = 0.0
            curModel.transform.m12 = 0.0
            curModel.transform.m13 = 0.0
            curModel.transform.m14 = 0.0
            curModel.transform.m15 = 1.0
            DrawModel(curModel, pos, combatScale, WHITE)
        ok

        # Dynamic Engine Thruster Plumes Aligned Per Starfighter Architecture
        tDist = 3.4
        tSpan = 1.3
        if shipId = 2     tDist = 3.6 tSpan = 0.8
        elseif shipId = 3 tDist = 4.4 tSpan = 1.6
        elseif shipId = 4 tDist = 3.6 tSpan = 1.4
        elseif shipId = 5 tDist = 3.0 tSpan = 1.4
        elseif shipId = 6 tDist = 4.8 tSpan = 2.2
        ok
        leftEng  = Vector3(pos.x - fwdX * tDist - rX * tSpan - upX * 0.25, pos.y - fwdY * tDist - rY * tSpan - upY * 0.25, pos.z - fwdZ * tDist - rZ * tSpan - upZ * 0.25)
        rightEng = Vector3(pos.x - fwdX * tDist + rX * tSpan - upX * 0.25, pos.y - fwdY * tDist + rY * tSpan - upY * 0.25, pos.z - fwdZ * tDist + rZ * tSpan - upZ * 0.25)

        glowCol = shipColor
        if powerShotTimer > 0 glowCol = GREEN ok

        if throttleState = 1 # BOOST (Afterburner)
            DrawSphere(leftEng,  0.42, glowCol)
            DrawSphere(rightEng, 0.42, glowCol)
            DrawSphere(Vector3(leftEng.x - fwdX * 1.4, leftEng.y - fwdY * 1.4, leftEng.z - fwdZ * 1.4), 0.32, WHITE)
            DrawSphere(Vector3(rightEng.x - fwdX * 1.4, rightEng.y - fwdY * 1.4, rightEng.z - fwdZ * 1.4), 0.32, WHITE)
            DrawSphere(Vector3(leftEng.x - fwdX * 2.8, leftEng.y - fwdY * 2.8, leftEng.z - fwdZ * 2.8), 0.22, WHITE)
            DrawSphere(Vector3(rightEng.x - fwdX * 2.8, rightEng.y - fwdY * 2.8, rightEng.z - fwdZ * 2.8), 0.22, WHITE)
        elseif throttleState = -1 # BRAKE
            DrawSphere(leftEng,  0.22, MAROON)
            DrawSphere(rightEng, 0.22, MAROON)
        else # CRUISE
            DrawSphere(leftEng,  0.35, glowCol)
            DrawSphere(rightEng, 0.35, glowCol)
            DrawSphere(Vector3(leftEng.x - fwdX * 0.9, leftEng.y - fwdY * 0.9, leftEng.z - fwdZ * 0.9), 0.22, YELLOW)
            DrawSphere(Vector3(rightEng.x - fwdX * 0.9, rightEng.y - fwdY * 0.9, rightEng.z - fwdZ * 0.9), 0.22, YELLOW)
        ok
    end

    func takeDamage amount, particlesList, sndExplosion
        if barrelRollTimer > 0
            return False # Invulnerable during acrobatic dodge
        ok
        if powerShieldTimer > 0
            spawnImpactSparks(particlesList, pos, 6, SKYBLUE)
            return False
        ok
        health -= amount
        camShake = 0.65
        spawnImpactSparks(particlesList, pos, 6, RED)
        if health <= 0
            health = 0
            spawnExplosion(particlesList, pos, 50, ORANGE)
            PlaySound(sndExplosion)
            return True # Destroyed
        ok
        return False
    end

    func applySpeedSurge surgeAmount
        forwardSpeed += surgeAmount
        camShake = 0.6
    end

    func isAlive
        return health > 0
    end
end
