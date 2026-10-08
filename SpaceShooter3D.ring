#===================================================================#
# Space Shooter 3D (RayLib + Ring) - Master Game Orchestrator (OOP)
# Integrated Story Prologue -> 3D Starfleet Hangar Selection -> Combat
#===================================================================#

load "raylib.ring"
load "stdlibcore.ring"

# Load OOP Subsystems
load "Config.ring"
load "ShipRegistry.ring"
load "Environment.ring"
load "Player.ring"
load "Enemies.ring"
load "Weapons.ring"
load "HUD.ring"

# -------------------------------------------------------------------
# Application Entry Point
# -------------------------------------------------------------------
func main
    cleanObsoleteDataFiles()
    game = new SpaceShooterGame()
    game.run()

# -------------------------------------------------------------------
# Master Game Class
# -------------------------------------------------------------------
class SpaceShooterGame
    gameState
    score

    # 6 Unified Starfleet 3D Models & Hull Textures
    modelCoyote
    texCoyote
    modelFighter38
    texFighter38
    modelFighter232
    texFighter232
    modelIntergalactic
    texIntergalactic
    modelAttack
    texAttack
    modelBoss
    texBoss

    modelsList
    texturesList

    # Dynamically Assigned Combat Fleet Models
    activePlayerModel
    activeScoutModel
    activeFighterModel
    activeInterceptorModel
    activeBossModel

    # Audio Assets
    sndPlayerLaser
    sndPlayerLaserUpgraded
    sndEnemyLaser
    sndExplosion
    sndPowerup
    bgMusic

    # Shaders & Render Pipeline
    renderTarget
    bloomShader
    hasBloom
    spaceBgTexture

    # OOP Subsystems
    player
    weapons
    stars
    asteroids
    chronoGates
    fleet
    hud

    # FX Pools
    powerups
    particles

    # 3D Starfleet Hangar & Showroom State
    hangarBays
    selectedBay
    turntableSpin
    spinAngle
    hangarCam
    hangarCamTarget
    hangarDesiredTarget
    hangarDist
    hangarDesiredDist
    hangarPitch
    hangarDesiredPitch
    hangarYaw
    hangarDesiredYaw
    mousePrevX
    mousePrevY
    hangarStars
    prevSelectedBay
    showHangarHUD

    func init
        SetConfigFlags(FLAG_MSAA_4X_HINT)
        InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Space Shooter 3D - All-Range Starfighter Combat")
        SetTargetFPS(60)

        InitAudioDevice()
        sndPlayerLaser         = LoadSound("Assets/laser1.ogg")
        sndPlayerLaserUpgraded = LoadSound("Assets/raval.wav")
        sndEnemyLaser          = LoadSound("Assets/laser2.ogg")
        sndExplosion           = LoadSound("Assets/Explosion+3.wav")
        sndPowerup             = LoadSound("Assets/health.ogg")
        bgMusic                = LoadMusicStream("Assets/Dimensions.ogg")
        PlayMusicStream(bgMusic)
        SetMusicVolume(bgMusic, 0.7)

        # Space Background Nebula Texture
        spaceBgTexture = 0
        spaceBgPath    = "Assets/space_bg.png"
        if fexists(spaceBgPath)
            spaceBgTexture = LoadTexture(spaceBgPath)
        ok

        # ---------------------------------------------------------------
        # 1. Load All 6 Starfleet Models & High-Tech Hull Textures
        # ---------------------------------------------------------------

        # Vessel 1: Quarren Coyote Vanguard Starfighter
        coyotePath = "data/quarren_coyote_ship.obj"
        if not fexists(coyotePath) and fexists("data/Quarren Coyote Ship.obj")
            coyotePath = "data/Quarren Coyote Ship.obj"
        ok
        modelCoyote = LoadModel(coyotePath)
        modelCoyote.transform = MatrixIdentity()
        texCoyote   = LoadTexture("data/plane_diffuse.png")
        GenTextureMipmaps(texCoyote)
        SetModelMaterialTexture(modelCoyote, 0, MATERIAL_MAP_DIFFUSE, texCoyote)

        # Vessel 2: Fighter 38 Recon Scout Drone
        fighter38Path = "data/fighter_38/fighter_38.obj"
        if not fexists(fighter38Path) and fexists("data/Fighter+38_obj/Fighter 38.obj")
            fighter38Path = "data/Fighter+38_obj/Fighter 38.obj"
        ok
        modelFighter38 = LoadModel(fighter38Path)
        modelFighter38.transform = MatrixIdentity()
        imgFighter38   = GenImageCellular(512, 512, 16)
        ImageColorTint(imgFighter38, RAYLibColor(220, 50, 60, 255))
        texFighter38   = LoadTextureFromImage(imgFighter38)
        GenTextureMipmaps(texFighter38)
        UnloadImage(imgFighter38)
        SetModelMaterialTexture(modelFighter38, 0, MATERIAL_MAP_DIFFUSE, texFighter38)

        # Vessel 3: Fighter 232 Heavy Strike Raider
        fighter232Path = "data/fighter_232/fighter_232.obj"
        if not fexists(fighter232Path) and fexists("data/Fighter+232_obj/Fighter 232.obj")
            fighter232Path = "data/Fighter+232_obj/Fighter 232.obj"
        ok
        modelFighter232 = LoadModel(fighter232Path)
        modelFighter232.transform = MatrixIdentity()
        imgFighter232   = GenImageCellular(512, 512, 24)
        ImageColorTint(imgFighter232, RAYLibColor(45, 110, 210, 255))
        texFighter232   = LoadTextureFromImage(imgFighter232)
        GenTextureMipmaps(texFighter232)
        UnloadImage(imgFighter232)
        SetModelMaterialTexture(modelFighter232, 0, MATERIAL_MAP_DIFFUSE, texFighter232)

        # Vessel 4: Intergalactic Spaceship (Razor Stealth Interceptor)
        intergalacticPath = "data/enemy_fighter.obj"
        modelIntergalactic = LoadModel(intergalacticPath)
        modelIntergalactic.transform = MatrixIdentity()
        imgIntergalactic   = GenImagePerlinNoise(512, 512, 10, 10, 6.0)
        ImageColorTint(imgIntergalactic, RAYLibColor(70, 80, 105, 255))
        texIntergalactic   = LoadTextureFromImage(imgIntergalactic)
        GenTextureMipmaps(texIntergalactic)
        UnloadImage(imgIntergalactic)
        SetModelMaterialTexture(modelIntergalactic, 0, MATERIAL_MAP_DIFFUSE, texIntergalactic)

        # Vessel 5: Attack Fighter (Heavy Escort Cruiser)
        attackFighterPath = "data/enemy_scout.obj"
        modelAttack = LoadModel(attackFighterPath)
        modelAttack.transform = MatrixIdentity()
        imgAttack   = GenImageCellular(512, 512, 20)
        ImageColorTint(imgAttack, RAYLibColor(200, 100, 30, 255))
        texAttack   = LoadTextureFromImage(imgAttack)
        GenTextureMipmaps(texAttack)
        UnloadImage(imgAttack)
        SetModelMaterialTexture(modelAttack, 0, MATERIAL_MAP_DIFFUSE, texAttack)

        # Vessel 6: Titan Dreadnought Boss (Capital Flagship)
        bossPath = "data/enemy_fighter.obj"
        modelBoss = LoadModel(bossPath)
        modelBoss.transform = MatrixIdentity()
        imgBoss   = GenImageCellular(512, 512, 32)
        ImageColorTint(imgBoss, RAYLibColor(220, 160, 40, 255))
        texBoss   = LoadTextureFromImage(imgBoss)
        GenTextureMipmaps(texBoss)
        UnloadImage(imgBoss)
        SetModelMaterialTexture(modelBoss, 0, MATERIAL_MAP_DIFFUSE, texBoss)

        # Unified Ship Registries
        modelsList   = [modelCoyote, modelFighter38, modelFighter232, modelIntergalactic, modelAttack, modelBoss]
        texturesList = [texCoyote, texFighter38, texFighter232, texIntergalactic, texAttack, texBoss]

        # Active models assigned by default to Bay 1
        activePlayerModel      = modelCoyote
        activeScoutModel       = modelFighter38
        activeFighterModel     = modelFighter232
        activeInterceptorModel = modelIntergalactic
        activeBossModel        = modelBoss

        # ---------------------------------------------------------------
        # 2. Hangar Exhibition Configuration & Camera
        # ---------------------------------------------------------------
        hangarBays    = getStarfleetBays()
        selectedBay   = 1
        turntableSpin = true
        spinAngle     = 0.0

        hangarCam = Camera3D(
            -55.0, 16.0, 24.0,   # Position
            -55.0, 3.4,  6.0,    # Target
            0.0, 1.0, 0.0,       # Up
            48.0, CAMERA_PERSPECTIVE
        )

        hangarCamTarget     = Vector3(-55.0, 3.4, 6.0)
        hangarDesiredTarget = Vector3(-55.0, 3.4, 6.0)
        hangarDist          = 36.0
        hangarDesiredDist   = 36.0
        hangarPitch         = 18.0
        hangarDesiredPitch  = 18.0
        hangarYaw           = 0.0
        hangarDesiredYaw    = 0.0
        prevSelectedBay     = selectedBay
        showHangarHUD       = true

        mousePrevX = GetMouseX()
        mousePrevY = GetMouseY()

        # Ambient Stars for 3D Hangar
        hangarStarsCount = 220
        hangarStars = list(hangarStarsCount)
        for s = 1 to hangarStarsCount
            hangarStars[s] = [
                Vector3(GetRandomValue(-400, 400), GetRandomValue(30, 280), GetRandomValue(-400, 400)),
                GetRandomValue(1, 3)
            ]
        next

        # ---------------------------------------------------------------
        # 3. Post-Processing & Combat Subsystems
        # ---------------------------------------------------------------
        hasBloom     = false
        bloomShader  = 0
        renderTarget = LoadRenderTexture(SCREEN_WIDTH, SCREEN_HEIGHT)

        if fexists("Assets/bloom.fs")
            bloomShader = LoadShader("", "Assets/bloom.fs")
            hasBloom = false
        ok

        player      = new PlayerShip()
        weapons     = new WeaponSystem()
        stars       = new Starfield()
        asteroids   = new AsteroidField()
        chronoGates = new ChronoGate()
        fleet       = new EnemyFleet()
        hud         = new CockpitHUD()

        powerups    = []
        particles   = []
        score       = 0

        # Game launches into the Cinematic Story Prologue first!
        gameState   = STATE_STORY

        return self
    end

    # ---------------------------------------------------------------
    # Start Game with Player's Selected Ship from the Hangar
    # ---------------------------------------------------------------
    func startNewGameWithShip bayIdx
        score     = 0
        gameState = STATE_PLAYING
        powerups  = []
        particles = []

        player.reset()
        bData = hangarBays[bayIdx]
        player.setShipProfile(bData)

        weapons.reset()
        weapons.fireCooldown = player.fireCooldown
        hud.resetCamera()
        fleet.reset()

        # Dynamic model assignment: player gets chosen vessel
        activePlayerModel = modelsList[bayIdx]

        # Allocate unselected vessels to enemy armada waves
        enemyPool = []
        for k = 1 to len(hangarBays)
            if k != bayIdx
                enemyPool + k
            ok
        next

        scoutData       = hangarBays[enemyPool[1]]
        fighterData     = hangarBays[enemyPool[2]]
        interceptorData = hangarBays[enemyPool[3]]
        bossData        = hangarBays[6]
        if bayIdx = 6
            bossData = hangarBays[enemyPool[4]]
        ok

        activeScoutModel       = modelsList[scoutData[1]]
        activeFighterModel     = modelsList[fighterData[1]]
        activeInterceptorModel = modelsList[interceptorData[1]]
        activeBossModel        = modelsList[bossData[1]]

        fleet.setEnemyScales(
            scoutData[21], scoutData[13], scoutData[22],
            fighterData[21], fighterData[13], fighterData[22],
            interceptorData[21], interceptorData[13], interceptorData[22],
            bossData[21], bossData[13], bossData[22]
        )

        asteroids.reset(player.pos, player.fwdX, player.fwdY, player.fwdZ)
        chronoGates.reset(player.pos, player.fwdX, player.fwdY, player.fwdZ)
        fleet.spawnWave(1, player.pos, player.fwdX, player.fwdZ)

        PlaySound(sndPowerup)
    end

    func run
        while !WindowShouldClose()
            dt = GetFrameTime()
            if dt > 0.05 dt = 0.05 ok
            UpdateMusicStream(bgMusic)

            update(dt)
            render()
        end
        cleanup()
    end

    # ---------------------------------------------------------------
    # Update Subsystem State Machines
    # ---------------------------------------------------------------
    func update dt
        if IsKeyPressed(KEY_B) and bloomShader != 0
            hasBloom = !hasBloom
        ok

        # State 0: Cinematic Story Prologue Banner
        if gameState = STATE_STORY
            spinAngle += 22.0 * dt
            if spinAngle >= 360.0 spinAngle -= 360.0 ok
            updateHangarCamera(dt)

            if IsKeyPressed(KEY_SPACE) or IsKeyPressed(KEY_ENTER)
                gameState = STATE_HANGAR
                PlaySound(sndPowerup)
            ok

        # State 1: 3D Starfleet Hangar & Ship Selection Area
        elseif gameState = STATE_HANGAR
            if turntableSpin
                spinAngle += 45.0 * dt
                if spinAngle >= 360.0 spinAngle -= 360.0 ok
            ok

            # Cycle Starfighter Selection
            if IsKeyPressed(KEY_LEFT) or IsKeyPressed(KEY_A)
                selectedBay--
                if selectedBay < 1 selectedBay = len(hangarBays) ok
                PlaySound(sndPowerup)
            ok
            if IsKeyPressed(KEY_RIGHT) or IsKeyPressed(KEY_D)
                selectedBay++
                if selectedBay > len(hangarBays) selectedBay = 1 ok
                PlaySound(sndPowerup)
            ok

            # Direct Number Selection (Keys 1 - 6)
            if IsKeyPressed(KEY_ONE)   selectedBay = 1 PlaySound(sndPowerup) ok
            if IsKeyPressed(KEY_TWO)   selectedBay = 2 PlaySound(sndPowerup) ok
            if IsKeyPressed(KEY_THREE) selectedBay = 3 PlaySound(sndPowerup) ok
            if IsKeyPressed(KEY_FOUR)  selectedBay = 4 PlaySound(sndPowerup) ok
            if IsKeyPressed(KEY_FIVE)  selectedBay = 5 PlaySound(sndPowerup) ok
            if IsKeyPressed(KEY_SIX)   selectedBay = 6 PlaySound(sndPowerup) ok

            if IsKeyPressed(KEY_SPACE)
                turntableSpin = !turntableSpin
            ok

            # Toggle HUD Panels On / Off for Panoramic Inspection
            if IsKeyPressed(KEY_H)
                showHangarHUD = !showHangarHUD
            ok

            updateHangarCamera(dt)

            # [ENTER] Launches the Chosen Ship into Combat!
            if IsKeyPressed(KEY_ENTER)
                startNewGameWithShip(selectedBay)
            ok

        # State 2: Active 3D Combat Space Dogfight
        elseif gameState = STATE_PLAYING
            # 1. Update Player Flight Physics & Maneuvers
            player.update(dt, particles, sndPowerup)

            # 2. Update Chase Camera
            hud.updateCamera(dt, player)

            # 3. Handle Player Firing & Update Lasers
            weapons.handlePlayerFiring(dt, player, sndPlayerLaser, sndPlayerLaserUpgraded)
            weapons.update(dt)

            # 4. Update Environmental Systems
            stars.update(dt, player.pos, player.fwdX, player.fwdY, player.fwdZ)
            asteroids.update(dt, player.pos, player.fwdX, player.fwdY, player.fwdZ)
            asteroids.checkPlayerCollisions(player, particles, sndExplosion)

            # 5. Chrono-Gate Warp Rings
            gateBonus = chronoGates.update(dt, player, particles, sndPowerup)
            score += gateBonus

            # 6. Wave Progression & Enemy Fleet Spawning
            if not fleet.waveActive and fleet.count() = 0
                fleet.waveTimer += dt
                if fleet.waveTimer >= fleet.waveDelay
                    fleet.spawnWave(fleet.currentWave, player.pos, player.fwdX, player.fwdZ)
                ok
            ok

            if fleet.waveActive and fleet.count() = 0
                fleet.waveActive = False
                fleet.currentWave++
                score += 200
                spawnRandomPowerup(powerups, player.pos.x + player.fwdX * 45.0, player.pos.y + player.fwdY * 45.0, player.pos.z + player.fwdZ * 45.0)

                if fleet.currentWave > fleet.maxWaves
                    gameState = STATE_VICTORY
                else
                    asteroids.syncToWave(fleet.currentWave, player.pos, player.fwdX, player.fwdY, player.fwdZ)
                ok
            ok

            # 7. Update Enemy Fleet AI & Weapons
            fleet.update(dt, player, weapons, sndEnemyLaser)

            # 8. Enemy Lasers vs Player
            weapons.checkEnemyLasersVsPlayer(player, particles, sndExplosion)
            if !player.isAlive()
                gameState = STATE_GAMEOVER
            ok

            # 9. Player Lasers vs Enemy Fleet & Asteroids
            score += weapons.checkPlayerLasersVsFleet(fleet, powerups, particles, sndExplosion)
            score += weapons.checkPlayerLasersVsAsteroids(asteroids, player.pos, player.fwdX, player.fwdY, player.fwdZ, particles, sndExplosion)

            # 10. Update 3D Powerup Pickups & Magnetic Tractor Beam
            for i = len(powerups) to 1 step -1
                powerups[i][3] += dt * 3.5
                pwPos = powerups[i][1]
                pDist = getDistance3D(player.pos, pwPos)

                # Magnetic Tractor Beam (Pulls powerup smoothly towards player when within 60m)
                if pDist < 60.0 and pDist > 0.1
                    pullSpd = (50.0 + (60.0 - pDist) * 1.6) * dt
                    pwPos.x += (player.pos.x - pwPos.x) / pDist * pullSpd
                    pwPos.y += (player.pos.y - pwPos.y) / pDist * pullSpd
                    pwPos.z += (player.pos.z - pwPos.z) / pDist * pullSpd
                ok

                # Generous Easy Pickup Range (18.0 units radius)
                if pDist < 18.0
                    PlaySound(sndPowerup)
                    if powerups[i][2] = 1 # Health repair
                        player.health += 45
                        if player.health > player.maxHealth player.health = player.maxHealth ok
                    elseif powerups[i][2] = 2 # Supercharged Mega-Plasma
                        player.powerShotTimer = 12.0
                    elseif powerups[i][2] = 3 # Invulnerable Energy Shield Grid
                        player.powerShieldTimer = 12.0
                    ok
                    spawnImpactSparks(particles, pwPos, 8, GOLD)
                    del(powerups, i)
                elseif pDist > 550.0 or powerups[i][3] > 120.0
                    # Auto-despawn distant/expired powerups to prevent memory accumulation
                    del(powerups, i)
                ok
            next

            # 11. Update 3D Particle Lifetime & Movement (Direct modification, guaranteed expiration)
            for i = len(particles) to 1 step -1
                particles[i][1].x += particles[i][2].x * dt
                particles[i][1].y += particles[i][2].y * dt
                particles[i][1].z += particles[i][2].z * dt
                particles[i][5] -= dt
                if particles[i][5] <= 0
                    del(particles, i)
                ok
            next

            # Strict safety cap for persistent ultra-smooth 60 FPS
            while len(particles) > 60
                del(particles, 1)
            end

        # State 3 & 4: Mission Over / Victory
        elseif gameState = STATE_GAMEOVER or gameState = STATE_VICTORY
            if IsKeyPressed(KEY_ENTER) or IsKeyPressed(KEY_R)
                startNewGameWithShip(selectedBay)
            elseif IsKeyPressed(KEY_H)
                gameState = STATE_HANGAR
                PlaySound(sndPowerup)
            ok
        ok
    end

    # ---------------------------------------------------------------
    # Hangar Smooth Orbit Camera Controller
    # ---------------------------------------------------------------
    func updateHangarCamera dt
        if selectedBay != prevSelectedBay
            prevSelectedBay = selectedBay
            if selectedBay = 6
                hangarDesiredDist = 58.0
            else
                hangarDesiredDist = 36.0
            ok
        ok

        bayData = hangarBays[selectedBay]
        bPos    = bayData[8]
        hangarDesiredTarget = Vector3(bPos.x, bPos.y + 0.8, bPos.z)

        # Mouse Orbit Controls
        mouseCurX = GetMouseX()
        mouseCurY = GetMouseY()

        if IsMouseButtonDown(MOUSE_LEFT_BUTTON)
            deltaX = mouseCurX - mousePrevX
            deltaY = mouseCurY - mousePrevY
            hangarDesiredYaw   -= deltaX * 0.45
            hangarDesiredPitch += deltaY * 0.35
            if hangarDesiredPitch > 84.0  hangarDesiredPitch = 84.0 ok
            if hangarDesiredPitch < -15.0 hangarDesiredPitch = -15.0 ok
        ok

        wheel = GetMouseWheelMove()
        if wheel != 0
            hangarDesiredDist -= wheel * 3.5
            if hangarDesiredDist < 12.0  hangarDesiredDist = 12.0 ok
            if hangarDesiredDist > 140.0 hangarDesiredDist = 140.0 ok
        ok

        mousePrevX = mouseCurX
        mousePrevY = mouseCurY

        # Smooth Interpolation
        hangarCamTarget.x += (hangarDesiredTarget.x - hangarCamTarget.x) * 6.5 * dt
        hangarCamTarget.y += (hangarDesiredTarget.y - hangarCamTarget.y) * 6.5 * dt
        hangarCamTarget.z += (hangarDesiredTarget.z - hangarCamTarget.z) * 6.5 * dt

        hangarDist  += (hangarDesiredDist  - hangarDist)  * 7.0 * dt
        hangarPitch += (hangarDesiredPitch - hangarPitch) * 8.0 * dt
        hangarYaw   += (hangarDesiredYaw   - hangarYaw)   * 8.0 * dt

        pitchRad = hangarPitch * DEG2RAD
        yawRad   = hangarYaw   * DEG2RAD

        cEyeX = hangarCamTarget.x + hangarDist * cos(pitchRad) * sin(yawRad)
        cEyeY = hangarCamTarget.y + hangarDist * sin(pitchRad)
        cEyeZ = hangarCamTarget.z + hangarDist * cos(pitchRad) * cos(yawRad)

        hangarCam.position.x = cEyeX
        hangarCam.position.y = cEyeY
        hangarCam.position.z = cEyeZ
        hangarCam.target.x   = hangarCamTarget.x
        hangarCam.target.y   = hangarCamTarget.y
        hangarCam.target.z   = hangarCamTarget.z
    end

    # ---------------------------------------------------------------
    # Render 3D Starfleet Hangar Environment
    # ---------------------------------------------------------------
    func drawHangar3D
        BeginMode3D(hangarCam)

        # 1. Distant Space Ambience
        for s = 1 to len(hangarStars)
            sp = hangarStars[s][1]
            sz = hangarStars[s][2]
            DrawCube(sp, sz * 0.4, sz * 0.4, sz * 0.4, WHITE)
        next

        # 2. Cyber Hangar Floor Grid & Glowing Illumination Deck
        DrawGrid(50, 4.0)

        # 3. Main Runway Guidance Markings
        runwayLength = 220.0
        DrawLine3D(Vector3(-runwayLength / 2.0, 0.08, 0.0), Vector3(runwayLength / 2.0, 0.08, 0.0), RAYLibColor(0, 220, 255, 180))
        DrawLine3D(Vector3(-runwayLength / 2.0, 0.08, 9.0), Vector3(runwayLength / 2.0, 0.08, 9.0), RAYLibColor(0, 140, 240, 100))
        DrawLine3D(Vector3(-runwayLength / 2.0, 0.08, -9.0), Vector3(runwayLength / 2.0, 0.08, -9.0), RAYLibColor(0, 140, 240, 100))

        # 4. Render 6 Exhibition Bays
        curTime = GetTime()
        angRad  = spinAngle * DEG2RAD

        for b = 1 to len(hangarBays)
            bay = hangarBays[b]
            bIdx    = bay[1]
            bPadPos = bay[8]
            bScale  = bay[9]
            bColor  = bay[10]
            bYOff   = bay[11]
            bZOff   = bay[12]

            isFocused = (selectedBay = bIdx)

            # Anti-gravity hover bob
            bobY = sin(curTime * 2.2 + bIdx * 1.05) * 0.35
            shipPos = Vector3(bPadPos.x, bPadPos.y + bobY + bYOff, bPadPos.z + bZOff)

            # Pedestal Base Platform
            baseRadius = 6.8
            if bIdx = 6 baseRadius = 15.5 ok # Colossal Boss Pedestal

            DrawCylinder(Vector3(bPadPos.x, -0.5, bPadPos.z), baseRadius, baseRadius + 0.6, 1.0, 28, RAYLibColor(18, 24, 38, 255))
            DrawCylinderWires(Vector3(bPadPos.x, -0.5, bPadPos.z), baseRadius, baseRadius + 0.6, 1.0, 28, bColor)

            # Inner Glowing Emitter Disc
            discColor = Fade(bColor, 0.35)
            if isFocused discColor = bColor ok
            DrawCylinder(Vector3(bPadPos.x, 0.05, bPadPos.z), baseRadius * 0.85, baseRadius * 0.85, 0.08, 28, RAYLibColor(12, 18, 30, 255))
            DrawCylinderWires(Vector3(bPadPos.x, 0.05, bPadPos.z), baseRadius * 0.85, baseRadius * 0.85, 0.08, 28, discColor)

            # Holographic Vertical Containment Pillars (4 light beams)
            for k = 0 to 3
                ang = (k * 90.0 + curTime * 25.0) * DEG2RAD
                px = bPadPos.x + cos(ang) * (baseRadius * 0.95)
                pz = bPadPos.z + sin(ang) * (baseRadius * 0.95)
                beamCol = Fade(bColor, 0.45)
                if isFocused beamCol = bColor ok
                DrawLine3D(Vector3(px, 0.0, pz), Vector3(px, 7.0, pz), beamCol)
                DrawSphere(Vector3(px, 7.0, pz), 0.15, beamCol)
            next

            # Focused Highlight Spotlight Ring
            if isFocused
                DrawCylinderWires(Vector3(bPadPos.x, 0.12, bPadPos.z), baseRadius * 1.08, baseRadius * 1.08, 0.1, 32, GOLD)
                DrawCylinderWires(Vector3(bPadPos.x, 0.18, bPadPos.z), baseRadius * 1.15, baseRadius * 1.15, 0.1, 32, YELLOW)
            ok

            # Render 3D Ship Models & Animated Thrusters
            if bIdx = 1 # Quarren Coyote Interceptor (Precisely Centered on Pedestal)
                rotMat   = MatrixRotateXYZ(Vector3(0.0, angRad, 0.0))
                transMat = MatrixTranslate(0.0, 20.0, 122.5)
                modelCoyote.transform = MatrixMultiply(rotMat, transMat)
                DrawModel(modelCoyote, shipPos, bScale, WHITE)

                cosA = cos(angRad)
                sinA = sin(angRad)
                eCx = shipPos.x + (0.0 * cosA - (-3.8) * sinA)
                eCy = shipPos.y + 0.1
                eCz = shipPos.z + (0.0 * sinA + (-3.8) * cosA)
                DrawSphere(Vector3(eCx, eCy, eCz), 0.45, SKYBLUE)
                DrawSphere(Vector3(eCx, eCy, eCz), 0.22, WHITE)

            elseif bIdx = 2 # Fighter 38 Recon Scout
                modelFighter38.transform = MatrixRotateXYZ(Vector3(0.0, angRad + 90.0 * DEG2RAD, 0.0))
                DrawModel(modelFighter38, shipPos, bScale, WHITE)

                cosA = cos(angRad)
                sinA = sin(angRad)
                thX = shipPos.x + (0.0 * cosA - (-3.8) * sinA)
                thY = shipPos.y + 0.3
                thZ = shipPos.z + (0.0 * sinA + (-3.8) * cosA)
                DrawSphere(Vector3(thX, thY, thZ), 0.40, RED)

            elseif bIdx = 3 # Fighter 232 Heavy Raider
                modelFighter232.transform = MatrixRotateXYZ(Vector3(0.0, angRad, 0.0))
                DrawModel(modelFighter232, shipPos, bScale, WHITE)

                cosA = cos(angRad)
                sinA = sin(angRad)
                for side = -1 to 1 step 2
                    eX = shipPos.x + (side * 2.8 * cosA - (-3.6) * sinA)
                    eY = shipPos.y + 0.4
                    eZ = shipPos.z + (side * 2.8 * sinA + (-3.6) * cosA)
                    DrawSphere(Vector3(eX, eY, eZ), 0.38, SKYBLUE)
                    DrawSphere(Vector3(eX, eY, eZ), 0.20, WHITE)
                next

            elseif bIdx = 4 # Intergalactic Spaceship
                modelIntergalactic.transform = MatrixRotateXYZ(Vector3(0.0, angRad, 0.0))
                DrawModel(modelIntergalactic, shipPos, bScale, WHITE)

                cosA = cos(angRad)
                sinA = sin(angRad)
                eCx = shipPos.x + (0.0 * cosA - (-3.8) * sinA)
                eCy = shipPos.y + 0.5
                eCz = shipPos.z + (0.0 * sinA + (-3.8) * cosA)
                DrawSphere(Vector3(eCx, eCy, eCz), 0.45, PURPLE)

            elseif bIdx = 5 # Attack Fighter
                modelAttack.transform = MatrixRotateXYZ(Vector3(0.0, angRad, 0.0))
                DrawModel(modelAttack, shipPos, bScale, WHITE)

                cosA = cos(angRad)
                sinA = sin(angRad)
                eCx = shipPos.x + (0.0 * cosA - (-3.2) * sinA)
                eCy = shipPos.y + 0.3
                eCz = shipPos.z + (0.0 * sinA + (-3.2) * cosA)
                DrawSphere(Vector3(eCx, eCy, eCz), 0.40, ORANGE)

            elseif bIdx = 6 # Titan Dreadnought Flagship Boss
                modelBoss.transform = MatrixRotateXYZ(Vector3(0.0, angRad, 0.0))
                DrawModel(modelBoss, shipPos, bScale, WHITE)

                cosA = cos(angRad)
                sinA = sin(angRad)
                bossRatio = bScale / 2.4
                for eng = 1 to 4
                    engOff = (eng - 2.5) * 3.6 * bossRatio
                    backDist = -12.5 * bossRatio
                    eX = shipPos.x + (engOff * cosA - backDist * sinA)
                    eY = shipPos.y + 0.6 * bossRatio
                    eZ = shipPos.z + (engOff * sinA + backDist * cosA)
                    DrawSphere(Vector3(eX, eY, eZ), 1.2 * bossRatio, ORANGE)
                    DrawSphere(Vector3(eX, eY, eZ), 0.7 * bossRatio, GOLD)
                    DrawSphere(Vector3(eX, eY, eZ), 0.38 * bossRatio, WHITE)
                next
            ok

            # 3D Holo-Marker Above Ship
            holoY = shipPos.y + 7.5
            if bIdx = 6 holoY = shipPos.y + 16.0 ok
            DrawCubeWires(Vector3(shipPos.x, holoY, shipPos.z), 4.2, 0.4, 0.4, bColor)
            DrawSphere(Vector3(shipPos.x, holoY, shipPos.z), 0.22, bColor)
        next

        EndMode3D()
    end

    # ---------------------------------------------------------------
    # Render Master Pipeline
    # ---------------------------------------------------------------
    func render
        # Scene A: Cinematic Story Prologue Banner (No grid lines, pure cosmic space backdrop)
        if gameState = STATE_STORY
            BeginDrawing()
            ClearBackground(BLACK)
            hud.drawSpaceBackdrop(SCREEN_WIDTH, SCREEN_HEIGHT, spaceBgTexture)
            hud.drawStoryBanner(SCREEN_WIDTH, SCREEN_HEIGHT)
            EndDrawing()

        # Scene B: 3D Starfleet Hangar & Ship Selection (Bright, fully illuminated 3D hall)
        elseif gameState = STATE_HANGAR
            BeginDrawing()
            ClearBackground(RAYLibColor(10, 16, 28, 255))
            drawHangar3D()
            hud.drawHangarUI(SCREEN_WIDTH, SCREEN_HEIGHT, selectedBay, hangarBays, turntableSpin, showHangarHUD)
            EndDrawing()

        # Scene C: Active Dogfight Combat / Mission Over / Victory
        else
            if hasBloom
                BeginTextureMode(renderTarget)
                ClearBackground(BLACK)
                BeginMode3D(hud.camera)

                stars.draw(player.fwdX, player.fwdY, player.fwdZ, player.forwardSpeed)
                asteroids.draw()
                chronoGates.draw()
                fleet.draw(activeScoutModel, activeFighterModel, activeInterceptorModel, activeBossModel)
                player.draw(activePlayerModel)
                weapons.draw()

                # Large, Highly-Visible Glowing Energy Power Orbs
                for i = 1 to len(powerups)
                    pw = powerups[i]
                    pwCol = GREEN
                    if pw[2] = 2 pwCol = GOLD ok
                    if pw[2] = 3 pwCol = SKYBLUE ok
                    DrawSphereWires(pw[1], 3.2, 8, 8, pwCol)
                    DrawSphere(pw[1], 2.2, pwCol)
                    DrawSphere(pw[1], 1.1, WHITE)
                next

                # 3D Sparks & Fireballs (Smooth spherical glow, no lingering blocky cubes)
                for i = 1 to len(particles)
                    p = particles[i]
                    alphaRatio = p[5] / p[6]
                    if alphaRatio > 1.0 alphaRatio = 1.0 ok
                    if alphaRatio < 0.0 alphaRatio = 0.0 ok
                    pSz = p[4] * alphaRatio
                    DrawSphere(p[1], pSz * 0.45, p[3])
                next

                EndMode3D()
                EndTextureMode()

                BeginDrawing()
                ClearBackground(BLACK)
                BeginShaderMode(bloomShader)
                DrawTextureRec(renderTarget.texture, Rectangle(0, 0, renderTarget.texture.width, -renderTarget.texture.height), Vector2(0, 0), WHITE)
                EndShaderMode()

            else
                BeginDrawing()
                ClearBackground(BLACK)
                BeginMode3D(hud.camera)

                stars.draw(player.fwdX, player.fwdY, player.fwdZ, player.forwardSpeed)
                asteroids.draw()
                chronoGates.draw()
                fleet.draw(activeScoutModel, activeFighterModel, activeInterceptorModel, activeBossModel)
                player.draw(activePlayerModel)
                weapons.draw()

                # Large, Highly-Visible Glowing Energy Power Orbs
                for i = 1 to len(powerups)
                    pw = powerups[i]
                    pwCol = GREEN
                    if pw[2] = 2 pwCol = GOLD ok
                    if pw[2] = 3 pwCol = SKYBLUE ok
                    DrawSphereWires(pw[1], 3.2, 8, 8, pwCol)
                    DrawSphere(pw[1], 2.2, pwCol)
                    DrawSphere(pw[1], 1.1, WHITE)
                next

                # 3D Sparks & Fireballs (Smooth spherical glow, no lingering blocky cubes)
                for i = 1 to len(particles)
                    p = particles[i]
                    alphaRatio = p[5] / p[6]
                    if alphaRatio > 1.0 alphaRatio = 1.0 ok
                    if alphaRatio < 0.0 alphaRatio = 0.0 ok
                    pSz = p[4] * alphaRatio
                    DrawSphere(p[1], pSz * 0.45, p[3])
                next

                EndMode3D()
            ok

            # 2D HUD Overlays
            if gameState = STATE_PLAYING
                hud.drawCockpit(SCREEN_WIDTH, SCREEN_HEIGHT, score, player, fleet)
            elseif gameState = STATE_GAMEOVER
                hud.drawGameOver(SCREEN_WIDTH, SCREEN_HEIGHT, score, player.distanceTraveled)
            elseif gameState = STATE_VICTORY
                hud.drawVictory(SCREEN_WIDTH, SCREEN_HEIGHT, score, player.distanceTraveled, fleet.maxWaves)
            ok

            EndDrawing()
        ok
    end

    # ---------------------------------------------------------------
    # Resource Deallocation
    # ---------------------------------------------------------------
    func cleanup
        UnloadSound(sndPlayerLaser)
        UnloadSound(sndPlayerLaserUpgraded)
        UnloadSound(sndEnemyLaser)
        UnloadSound(sndExplosion)
        UnloadSound(sndPowerup)
        UnloadMusicStream(bgMusic)
        CloseAudioDevice()

        stars.cleanup()

        UnloadTexture(texCoyote)
        UnloadTexture(texFighter38)
        UnloadTexture(texFighter232)
        UnloadTexture(texIntergalactic)
        UnloadTexture(texAttack)
        UnloadTexture(texBoss)

        UnloadModel(modelCoyote)
        UnloadModel(modelFighter38)
        UnloadModel(modelFighter232)
        UnloadModel(modelIntergalactic)
        UnloadModel(modelAttack)
        UnloadModel(modelBoss)

        if hasBloom
            UnloadShader(bloomShader)
            UnloadRenderTexture(renderTarget)
        ok

        if spaceBgTexture != NULL and spaceBgTexture.id > 0
            UnloadTexture(spaceBgTexture)
        ok

        hud.cleanup()
        CloseWindow()
    end
end
