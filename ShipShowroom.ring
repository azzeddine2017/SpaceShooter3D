#===================================================================#
# Space Shooter 3D - Interactive Starfleet Showroom & Hangar Arena
# Exhibition deck displaying all player and newly downloaded enemy vessels
#===================================================================#

load "raylib.ring"
load "ShipRegistry.ring"

# Configuration & Constants
SCREEN_WIDTH  = 1280
SCREEN_HEIGHT = 720
PI            = 3.141592653589793
DEG2RAD       = PI / 180.0
RAD2DEG       = 180.0 / PI

MATERIAL_MAP_DIFFUSE = 0
MAP_DIFFUSE          = 0

func main
    cleanObsoleteDataFiles()

    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Space Shooter 3D - Starfleet Hangar Showroom")
    SetTargetFPS(60)

    # ---------------------------------------------------------------
    # 1. Typography Setup
    # ---------------------------------------------------------------
    fontLoaded = false
    fontSciFi  = 0
    fontPath = "Assets/pirulen.ttf"
    if not fexists(fontPath) and fexists("C:/ring/samples/UsingRayLib/more/resources/pirulen.ttf")
        fontData = read("C:/ring/samples/UsingRayLib/more/resources/pirulen.ttf")
        write("Assets/pirulen.ttf", fontData)
    ok
    if fexists(fontPath)
        fontSciFi  = LoadFont(fontPath)
        fontLoaded = true
    ok

    # ---------------------------------------------------------------
    # 2. Load 3D Models & Materials (6 Pure Sci-Fi Starfleet Ships)
    # ---------------------------------------------------------------

    # Vessel 1: Quarren Coyote Interceptor (Vanguard Starfighter)
    coyotePath = "data/quarren_coyote_ship.obj"
    if not fexists(coyotePath) and fexists("data/Quarren Coyote Ship.obj")
        coyotePath = "data/Quarren Coyote Ship.obj"
    ok
    modelCoyote = LoadModel(coyotePath)
    modelCoyote.transform = MatrixIdentity()
    texCoyote   = LoadTexture("data/plane_diffuse.png")
    GenTextureMipmaps(texCoyote)
    SetModelMaterialTexture(modelCoyote, 0, MATERIAL_MAP_DIFFUSE, texCoyote)

    # Vessel 2: Fighter 38 (New Recon Scout Drone)
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

    # Vessel 3: Fighter 232 (New Strike Raider Heavy Fighter)
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

    # Vessel 4: Intergalactic Spaceship (New Razor Stealth Interceptor)
    intergalacticPath = "data/enemy_fighter.obj"
    modelIntergalactic = LoadModel(intergalacticPath)
    modelIntergalactic.transform = MatrixIdentity()
    imgIntergalactic   = GenImagePerlinNoise(512, 512, 10, 10, 6.0)
    ImageColorTint(imgIntergalactic, RAYLibColor(70, 80, 105, 255))
    texIntergalactic   = LoadTextureFromImage(imgIntergalactic)
    GenTextureMipmaps(texIntergalactic)
    UnloadImage(imgIntergalactic)
    SetModelMaterialTexture(modelIntergalactic, 0, MATERIAL_MAP_DIFFUSE, texIntergalactic)

    # Vessel 5: Attack Fighter (Alternative Recon Drone)
    attackFighterPath = "data/enemy_scout.obj"
    modelAttack = LoadModel(attackFighterPath)
    modelAttack.transform = MatrixIdentity()
    imgAttack   = GenImageCellular(512, 512, 20)
    ImageColorTint(imgAttack, RAYLibColor(200, 100, 30, 255))
    texAttack   = LoadTextureFromImage(imgAttack)
    GenTextureMipmaps(texAttack)
    UnloadImage(imgAttack)
    SetModelMaterialTexture(modelAttack, 0, MATERIAL_MAP_DIFFUSE, texAttack)

    # Vessel 6: Titan Dreadnought Boss (Enlarged Intergalactic Flagship)
    bossPath = "data/enemy_fighter.obj"
    modelBoss = LoadModel(bossPath)
    modelBoss.transform = MatrixIdentity()
    imgBoss   = GenImageCellular(512, 512, 32)
    ImageColorTint(imgBoss, RAYLibColor(220, 160, 40, 255))
    texBoss   = LoadTextureFromImage(imgBoss)
    GenTextureMipmaps(texBoss)
    UnloadImage(imgBoss)
    SetModelMaterialTexture(modelBoss, 0, MATERIAL_MAP_DIFFUSE, texBoss)

    # ---------------------------------------------------------------
    # 3. Exhibition Bay Configurations (Pads & Coordinates from Registry)
    # ---------------------------------------------------------------
    bays = getStarfleetBays()

    totalBays = len(bays)

    # ---------------------------------------------------------------
    # 4. Camera & Interaction State
    # ---------------------------------------------------------------
    camera = Camera3D(
        0.0, 22.0, 80.0,     # Position
        0.0, 3.5, 0.0,       # Target
        0.0, 1.0, 0.0,       # Up
        48.0, CAMERA_PERSPECTIVE
    )

    selectedBay   = 0     # 0: Full Arena Overview, 1-7: Focus on Bay
    turntableSpin = true  # Auto-rotate vessels on pedestals
    spinAngle     = 0.0
    showHUD       = true

    # Camera Orbit Parameters
    camTarget     = Vector3(0.0, 3.5, 0.0)
    desiredTarget = Vector3(0.0, 3.5, 0.0)
    camDist       = 96.0
    desiredDist   = 96.0
    camPitch      = 22.0
    desiredPitch  = 22.0
    camYaw        = 0.0
    desiredYaw    = 0.0

    mousePrevX = GetMouseX()
    mousePrevY = GetMouseY()

    # Pre-generate ambient background stars
    starsCount = 220
    ambientStars = list(starsCount)
    for s = 1 to starsCount
        ambientStars[s] = [
            Vector3(GetRandomValue(-400, 400), GetRandomValue(30, 280), GetRandomValue(-400, 400)),
            GetRandomValue(1, 3)
        ]
    next

    # ---------------------------------------------------------------
    # 5. Main Showroom Loop
    # ---------------------------------------------------------------
    while !WindowShouldClose()
        dt = GetFrameTime()
        if dt > 0.05 dt = 0.05 ok
        curTime = GetTime()

        # Update Turntable Spin
        if turntableSpin
            spinAngle += 36.0 * dt
            if spinAngle >= 360.0 spinAngle -= 360.0 ok
        ok

        # Input & Bay Selection
        if IsKeyPressed(KEY_ZERO) or IsKeyPressed(KEY_TAB)
            selectedBay = 0 # Overview Mode
        ok
        if IsKeyPressed(KEY_ONE)   selectedBay = 1 ok
        if IsKeyPressed(KEY_TWO)   selectedBay = 2 ok
        if IsKeyPressed(KEY_THREE) selectedBay = 3 ok
        if IsKeyPressed(KEY_FOUR)  selectedBay = 4 ok
        if IsKeyPressed(KEY_FIVE)  selectedBay = 5 ok
        if IsKeyPressed(KEY_SIX)   selectedBay = 6 ok

        if IsKeyPressed(KEY_LEFT) or IsKeyPressed(KEY_A)
            selectedBay--
            if selectedBay < 0 selectedBay = totalBays ok
        ok
        if IsKeyPressed(KEY_RIGHT) or IsKeyPressed(KEY_D)
            selectedBay++
            if selectedBay > totalBays selectedBay = 0 ok
        ok

        if IsKeyPressed(KEY_SPACE)
            turntableSpin = !turntableSpin
        ok
        if IsKeyPressed(KEY_H)
            showHUD = !showHUD
        ok
        if IsKeyPressed(KEY_R)
            desiredPitch = 22.0
            desiredYaw   = 0.0
            if selectedBay = 0
                desiredDist = 96.0
            else
                desiredDist = 18.0
                if selectedBay = 6 desiredDist = 42.0 ok # Boss view distance
            ok
        ok

        # Real-time scale fine-tuning keys for the focused vessel
        if selectedBay > 0
            scaleStep = 0.005
            if selectedBay = 2 scaleStep = 0.05 ok   # Fighter 38
            if selectedBay = 3 scaleStep = 0.01 ok   # Fighter 232
            if selectedBay = 4 scaleStep = 0.05 ok   # Intergalactic
            if selectedBay = 5 scaleStep = 0.0005 ok # Attack Fighter
            if selectedBay = 6 scaleStep = 0.08 ok   # Boss

            if IsKeyDown(KEY_UP) or IsKeyDown(KEY_EQUAL) or IsKeyDown(KEY_KP_ADD)
                bays[selectedBay][9] += scaleStep
            elseif IsKeyDown(KEY_DOWN) or IsKeyDown(KEY_MINUS) or IsKeyDown(KEY_KP_SUBTRACT)
                bays[selectedBay][9] -= scaleStep
                if bays[selectedBay][9] < 0.001 bays[selectedBay][9] = 0.001 ok
            ok
        ok

        # Camera Focus Target Resolution
        if selectedBay = 0
            desiredTarget = Vector3(0.0, 3.5, 0.0)
            if desiredDist < 45.0 desiredDist = 96.0 ok
        else
            bayData = bays[selectedBay]
            bPos    = bayData[8]
            desiredTarget = Vector3(bPos.x, bPos.y, bPos.z)
            if desiredDist > 55.0
                desiredDist = 18.0
                if selectedBay = 6 desiredDist = 42.0 ok
            ok
        ok

        # Mouse Orbit Controls
        mouseCurX = GetMouseX()
        mouseCurY = GetMouseY()

        if IsMouseButtonDown(MOUSE_LEFT_BUTTON)
            deltaX = mouseCurX - mousePrevX
            deltaY = mouseCurY - mousePrevY
            desiredYaw   -= deltaX * 0.45
            desiredPitch += deltaY * 0.35
            if desiredPitch > 84.0  desiredPitch = 84.0 ok
            if desiredPitch < -15.0 desiredPitch = -15.0 ok
        ok

        # Mouse Wheel Zoom
        wheel = GetMouseWheelMove()
        if wheel != 0
            desiredDist -= wheel * 3.5
            if desiredDist < 6.0   desiredDist = 6.0 ok
            if desiredDist > 160.0 desiredDist = 160.0 ok
        ok

        mousePrevX = mouseCurX
        mousePrevY = mouseCurY

        # Smooth Camera Interpolation
        camTarget.x  += (desiredTarget.x - camTarget.x) * 6.5 * dt
        camTarget.y  += (desiredTarget.y - camTarget.y) * 6.5 * dt
        camTarget.z  += (desiredTarget.z - camTarget.z) * 6.5 * dt
        camDist      += (desiredDist - camDist) * 7.0 * dt
        camPitch     += (desiredPitch - camPitch) * 8.0 * dt
        camYaw       += (desiredYaw - camYaw) * 8.0 * dt

        pitchRad = camPitch * DEG2RAD
        yawRad   = camYaw * DEG2RAD

        cEyeX = camTarget.x + camDist * cos(pitchRad) * sin(yawRad)
        cEyeY = camTarget.y + camDist * sin(pitchRad)
        cEyeZ = camTarget.z + camDist * cos(pitchRad) * cos(yawRad)

        camera.position.x = cEyeX
        camera.position.y = cEyeY
        camera.position.z = cEyeZ
        camera.target.x   = camTarget.x
        camera.target.y   = camTarget.y
        camera.target.z   = camTarget.z

        # -----------------------------------------------------------
        # Render 3D Scene
        # -----------------------------------------------------------
        BeginDrawing()
        ClearBackground(RAYLibColor(8, 12, 22, 255))

        BeginMode3D(camera)

        # 1. Distant Space Ambience
        for s = 1 to starsCount
            sp = ambientStars[s][1]
            sz = ambientStars[s][2]
            DrawCube(sp, sz * 0.4, sz * 0.4, sz * 0.4, WHITE)
        next

        # 2. Cyber Hangar Floor Grid & Glowing Illumination Deck
        DrawGrid(50, 4.0)

        # 3. Main Exhibition Runway Markings
        runwayLength = 220.0
        DrawLine3D(Vector3(-runwayLength / 2.0, 0.08, 0.0), Vector3(runwayLength / 2.0, 0.08, 0.0), RAYLibColor(0, 220, 255, 180))
        DrawLine3D(Vector3(-runwayLength / 2.0, 0.08, 9.0), Vector3(runwayLength / 2.0, 0.08, 9.0), RAYLibColor(0, 140, 240, 100))
        DrawLine3D(Vector3(-runwayLength / 2.0, 0.08, -9.0), Vector3(runwayLength / 2.0, 0.08, -9.0), RAYLibColor(0, 140, 240, 100))

        # 4. Render All Exhibition Bays
        for b = 1 to totalBays
            bay = bays[b]
            bIdx    = bay[1]
            bPadPos = bay[8]
            bScale  = bay[9]
            bColor  = bay[10]
            bYOff   = bay[11]
            bZOff   = bay[12]

            isFocused = (selectedBay = bIdx)

            # Floating Anti-Gravity Repulsor Animation
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

            # Turntable Rotation Angle for Ship
            vesselRot = spinAngle
            angRad = vesselRot * DEG2RAD

            # Draw Individual 3D Ship Models & Animated Systems
            if bIdx = 1 # Quarren Coyote Interceptor (Vanguard Starfighter)
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

            elseif bIdx = 2 # Fighter 38 (New Recon Scout)
                modelFighter38.transform = MatrixRotateXYZ(Vector3(0.0, angRad + 90.0 * DEG2RAD, 0.0))
                DrawModel(modelFighter38, shipPos, bScale, WHITE)

                cosA = cos(angRad)
                sinA = sin(angRad)
                thX = shipPos.x + (0.0 * cosA - (-3.8) * sinA)
                thY = shipPos.y + 0.3
                thZ = shipPos.z + (0.0 * sinA + (-3.8) * cosA)
                DrawSphere(Vector3(thX, thY, thZ), 0.40, RED)
                DrawSphere(Vector3(thX, thY, thZ), 0.22, YELLOW)

            elseif bIdx = 3 # Fighter 232 (New Strike Raider Heavy Fighter)
                modelFighter232.transform = MatrixRotateXYZ(Vector3(0.0, angRad, 0.0))
                DrawModel(modelFighter232, shipPos, bScale, WHITE)

                cosA = cos(angRad)
                sinA = sin(angRad)
                pLx = shipPos.x + (-2.2 * cosA - (-3.4) * sinA)
                pLy = shipPos.y + 0.4
                pLz = shipPos.z + (-2.2 * sinA + (-3.4) * cosA)
                pRx = shipPos.x + (2.2 * cosA - (-3.4) * sinA)
                pRy = shipPos.y + 0.4
                pRz = shipPos.z + (2.2 * sinA + (-3.4) * cosA)
                DrawSphere(Vector3(pLx, pLy, pLz), 0.38, SKYBLUE)
                DrawSphere(Vector3(pRx, pRy, pRz), 0.38, SKYBLUE)
                DrawSphere(Vector3(pLx, pLy, pLz), 0.20, WHITE)
                DrawSphere(Vector3(pRx, pRy, pRz), 0.20, WHITE)

            elseif bIdx = 4 # Intergalactic Cruiser (New Razor Stealth Interceptor)
                modelIntergalactic.transform = MatrixRotateXYZ(Vector3(0.0, angRad, 0.0))
                DrawModel(modelIntergalactic, shipPos, bScale, WHITE)

                cosA = cos(angRad)
                sinA = sin(angRad)
                thX = shipPos.x + (0.0 * cosA - (-4.2) * sinA)
                thY = shipPos.y + 0.2
                thZ = shipPos.z + (0.0 * sinA + (-4.2) * cosA)
                DrawSphere(Vector3(thX, thY, thZ), 0.45, PURPLE)
                DrawSphere(Vector3(thX, thY, thZ), 0.25, SKYBLUE)

            elseif bIdx = 5 # Attack Fighter (Alternative Heavy Raider)
                modelAttack.transform = MatrixRotateXYZ(Vector3(0.0, angRad, 0.0))
                DrawModel(modelAttack, shipPos, bScale, WHITE)

            elseif bIdx = 6 # Titan Dreadnought Boss (ENLARGED Intergalactic Flagship)
                modelBoss.transform = MatrixRotateXYZ(Vector3(0.0, angRad, 0.0))
                DrawModel(modelBoss, shipPos, bScale, WHITE)

                # Colossal Energy Shield Grid
                DrawSphereWires(shipPos, bScale * 5.5, 8, 8, RAYLibColor(255, 180, 0, 50))

                # Massive Quad Engine Thrusters
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
            

            # Floating 3D Holo-Label Above Ship
            holoY = shipPos.y + 7.5
            if bIdx = 6 holoY = shipPos.y + 16.0 ok
            DrawCubeWires(Vector3(shipPos.x, holoY, shipPos.z), 4.2, 0.4, 0.4, bColor)
            DrawSphere(Vector3(shipPos.x, holoY, shipPos.z), 0.22, bColor)
        next

        EndMode3D()

        # -----------------------------------------------------------
        # 2D Cyberpunk HUD & Technical Specification Overlays
        # -----------------------------------------------------------
        if showHUD
            # 1. Top Header Glass Bar
            recHeader = Rectangle(0, 0, SCREEN_WIDTH, 56)
            DrawRectangleRounded(recHeader, 0.0, 0, RAYLibColor(10, 16, 28, 230))
            DrawRectangleLines(0, 0, SCREEN_WIDTH, 56, DARKBLUE)

            if fontLoaded
                DrawTextEx(fontSciFi, "STARFLEET 3D SHOWROOM // NEW FLEET MODELS & BOSS ENLARGEMENT", Vector2(30, 16), 18, 1.0, GOLD)
            else
                DrawText("STARFLEET 3D SHOWROOM // NEW FLEET MODELS & BOSS ENLARGEMENT", 30, 18, 18, GOLD)
            ok

            statusTxt = "TURNTABLE: ACTIVE (ROTATING 360°)"
            if not turntableSpin statusTxt = "TURNTABLE: PAUSED (STATIONARY)" ok
            DrawText(statusTxt, SCREEN_WIDTH - 380, 20, 14, SKYBLUE)

            # 2. Bottom Left Technical Specification Card
            cardW = 550
            cardH = 210
            cardX = 30
            cardY = SCREEN_HEIGHT - cardH - 30

            recCard = Rectangle(cardX, cardY, cardW, cardH)
            DrawRectangleRounded(recCard, 0.12, 6, RAYLibColor(12, 18, 32, 235))
            DrawRectangleRoundedLines(recCard, 0.12, 6, 2.0, SKYBLUE)

            if selectedBay = 0 # Overview Card
                DrawText("EXHIBITION MODE: FULL ARENA OVERVIEW", cardX + 24, cardY + 20, 18, GOLD)
                DrawText("Active Fleet: 7 Combat Spacecraft (Including New Downloaded Models)", cardX + 24, cardY + 54, 15, RAYWHITE)
                DrawText("- Hero P-51 Falcon Starfighter (Full Diffuse Skin Applied)", cardX + 24, cardY + 80, 14, SKYBLUE)
                DrawText("- New Fighter 38 (Scout Drone) & Fighter 232 (Strike Raider)", cardX + 24, cardY + 104, 14, RAYLibColor(50, 150, 255, 255))
                DrawText("- Colossal Titan Dreadnought Flagship (Wave 10 Boss - Enlarged)", cardX + 24, cardY + 128, 14, GOLD)
                DrawText("Controls: Press keys [1] to [7] to zoom into any ship for inspection", cardX + 24, cardY + 162, 14, GREEN)
            else
                curBayData = bays[selectedBay]
                shipTitle  = curBayData[2]
                shipSub    = curBayData[3]
                shipAffil  = curBayData[4]
                shipHull   = curBayData[5]
                shipWeap   = curBayData[6]
                shipSpd    = curBayData[7]
                shipCol    = curBayData[10]

                DrawText(shipTitle, cardX + 24, cardY + 18, 18, shipCol)
                DrawText(shipSub, cardX + 24, cardY + 44, 14, RAYWHITE)

                DrawText("AFFILIATION: " + shipAffil, cardX + 24, cardY + 76, 13, SKYBLUE)
                DrawText("HULL ARMOR : " + shipHull, cardX + 24, cardY + 100, 13, LIGHTGRAY)
                DrawText("PROPULSION : " + shipSpd, cardX + 24, cardY + 124, 13, GOLD)
                DrawText("ARMAMENT   : " + shipWeap, cardX + 24, cardY + 148, 13, GREEN)

                DrawText("PAD: 0" + selectedBay + " // SCALE: " + curBayData[9], cardX + 24, cardY + 176, 12, DARKGRAY)
            ok

            # 3. Bottom Quick-Select Pad Selector Bar
            selBarX = cardX + cardW + 20
            selBarY = SCREEN_HEIGHT - 65
            selBarW = SCREEN_WIDTH - selBarX - 30

            recSelBar = Rectangle(selBarX, selBarY, selBarW, 40)
            DrawRectangleRounded(recSelBar, 0.25, 4, RAYLibColor(14, 20, 35, 230))
            DrawRectangleRoundedLines(recSelBar, 0.25, 4, 1.5, DARKBLUE)

            btnLabels = ["[0] ALL", "[1] HERO", "[2] F-38", "[3] F-232", "[4] RAZOR", "[5] ATTACK", "[6] TITAN", "[7] COYOTE"]
            btnSpacing = selBarW / 8.0

            for btn = 0 to 7
                bx = selBarX + btn * btnSpacing
                bCol = LIGHTGRAY
                if selectedBay = btn
                    bCol = GOLD
                    DrawRectangleRounded(Rectangle(bx + 2, selBarY + 4, btnSpacing - 4, 32), 0.2, 4, RAYLibColor(40, 60, 95, 200))
                    DrawRectangleRoundedLines(Rectangle(bx + 2, selBarY + 4, btnSpacing - 4, 32), 0.2, 4, 1.5, GOLD)
                ok
                DrawText(btnLabels[btn + 1], bx + 6, selBarY + 12, 11, bCol)
            next

            # 4. Top Right Interactive Controls Panel
            ctrlW = 340
            ctrlH = 175
            ctrlX = SCREEN_WIDTH - ctrlW - 30
            ctrlY = 75

            recCtrl = Rectangle(ctrlX, ctrlY, ctrlW, ctrlH)
            DrawRectangleRounded(recCtrl, 0.12, 4, RAYLibColor(12, 18, 30, 220))
            DrawRectangleRoundedLines(recCtrl, 0.12, 4, 1.5, DARKBLUE)

            DrawText("INTERACTION CONTROLS:", ctrlX + 18, ctrlY + 14, 14, GOLD)
            DrawText("- Left Mouse Drag  : 360° Free Orbit Camera", ctrlX + 18, ctrlY + 38, 13, RAYWHITE)
            DrawText("- Mouse Scroll     : Smooth Zoom In / Out", ctrlX + 18, ctrlY + 60, 13, RAYWHITE)
            DrawText("- [1] to [6] / [0] : Focus Vessel / Overview", ctrlX + 18, ctrlY + 82, 13, SKYBLUE)
            DrawText("- Left / Right     : Cycle Previous / Next", ctrlX + 18, ctrlY + 104, 13, LIGHTGRAY)
            DrawText("- [SPACE]          : Toggle Turntable Spin", ctrlX + 18, ctrlY + 126, 13, GREEN)
            DrawText("- [R] Reset View   : [H] Hide HUD Overlay", ctrlX + 18, ctrlY + 148, 13, GOLD)
        ok

        EndDrawing()
    end

    # ---------------------------------------------------------------
    # 6. Clean Resource Deallocation
    # ---------------------------------------------------------------
    UnloadModel(modelCoyote)
    UnloadTexture(texCoyote)

    UnloadModel(modelFighter38)
    UnloadTexture(texFighter38)

    UnloadModel(modelFighter232)
    UnloadTexture(texFighter232)

    UnloadModel(modelIntergalactic)
    UnloadTexture(texIntergalactic)

    UnloadModel(modelAttack)
    UnloadTexture(texAttack)

    UnloadModel(modelBoss)
    UnloadTexture(texBoss)

    if fontLoaded
        UnloadFont(fontSciFi)
    ok

    CloseWindow()
end
