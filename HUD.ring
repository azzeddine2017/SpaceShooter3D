#===================================================================#
# Space Shooter 3D - Cockpit HUD & Camera Class (OOP)
# Dynamic Chase Camera, Dashboard Instruments, Radar & UI Screens
#===================================================================#

class CockpitHUD
    camera
    fontSciFi
    fontLoaded

    func init
        camera = Camera3D(
            0.0, 8.5, -25.0,   # Position
            0.0, 1.8,  35.0,   # Target
            0.0, 1.0,   0.0,   # Up
            56.0, CAMERA_PERSPECTIVE
        )

        fontLoaded = false
        fontSciFi  = 0
        fontPath = "C:/ring/samples/UsingRayLib/more/resources/pirulen.ttf"
        if fexists("Assets/pirulen.ttf")
            fontPath = "Assets/pirulen.ttf"
        ok
        if fexists(fontPath)
            fontSciFi  = LoadFont(fontPath)
            fontLoaded = true
        ok

        return self
    end

    func drawTextStyled txt, x, y, sz, col
        if fontLoaded
            DrawTextEx(fontSciFi, txt, Vector2(x, y), sz, 1.0, col)
        else
            DrawText(txt, x, y, sz, col)
        ok
    end

    func drawSpaceBackdrop screenWidth, screenHeight, bgTex
        if isObject(bgTex)
            if bgTex.id > 0
                srcRec  = Rectangle(0.0, 0.0, bgTex.width, bgTex.height)
                destRec = Rectangle(0.0, 0.0, screenWidth, screenHeight)
                origin  = Vector2(0.0, 0.0)
                DrawTexturePro(bgTex, srcRec, destRec, origin, 0.0, WHITE)
                return
            ok
        ok
        # Fallback rich interstellar cosmic gradient (Never pitch black!)
        DrawRectangleGradientV(0, 0, screenWidth, screenHeight, RAYLibColor(18, 32, 65, 255), RAYLibColor(5, 10, 24, 255))
    end

    func drawTextWithin text, x, y, maxW, fontSize, color
        if MeasureText(text, fontSize) <= maxW
            DrawText(text, x, y, fontSize, color)
            return y + fontSize + 4
        ok
        words = splitWords(text)
        lineStr = ""
        curY = y
        for w = 1 to len(words)
            word = words[w]
            testStr = lineStr
            if len(testStr) > 0 testStr += " " ok
            testStr += word
            if MeasureText(testStr, fontSize) > maxW and len(lineStr) > 0
                DrawText(lineStr, x, curY, fontSize, color)
                curY += fontSize + 3
                lineStr = word
            else
                lineStr = testStr
            ok
        next
        if len(lineStr) > 0
            DrawText(lineStr, x, curY, fontSize, color)
            curY += fontSize + 4
        ok
        return curY
    end

    func splitWords str
        words = []
        w = ""
        for i = 1 to len(str)
            c = str[i]
            if c = " " or c = char(9) or c = char(10) or c = char(13)
                if len(w) > 0
                    words + w
                    w = ""
                ok
            else
                w += c
            ok
        next
        if len(w) > 0
            words + w
        ok
        return words
    end

    func resetCamera
        camera.position.x = 0.0
        camera.position.y = 8.5
        camera.position.z = -25.0
        camera.target.x   = 0.0
        camera.target.y   = 1.8
        camera.target.z   = 35.0
    end

    func updateCamera dt, player
        camDist = 25.0
        if player.throttleState = 1  camDist = 30.0 ok
        if player.throttleState = -1 camDist = 20.0 ok

        camera.fovy += (player.targetFOV - camera.fovy) * 6.0 * dt

        desiredCamX = player.pos.x - player.fwdX * camDist
        desiredCamY = player.pos.y + 7.5 - player.fwdY * (camDist * 0.32)
        desiredCamZ = player.pos.z - player.fwdZ * camDist

        if player.camShake > 0
            desiredCamX += (GetRandomValue(-10, 10) / 100.0) * player.camShake * 2.5
            desiredCamY += (GetRandomValue(-10, 10) / 100.0) * player.camShake * 2.5
        ok

        camera.position.x += (desiredCamX - camera.position.x) * 10.0 * dt
        camera.position.y += (desiredCamY - camera.position.y) * 10.0 * dt
        camera.position.z += (desiredCamZ - camera.position.z) * 10.0 * dt

        lookDist = 42.0
        desiredTargetX = player.pos.x + player.fwdX * lookDist
        desiredTargetY = player.pos.y + player.fwdY * lookDist + 1.2
        desiredTargetZ = player.pos.z + player.fwdZ * lookDist

        camera.target.x += (desiredTargetX - camera.target.x) * 14.0 * dt
        camera.target.y += (desiredTargetY - camera.target.y) * 14.0 * dt
        camera.target.z += (desiredTargetZ - camera.target.z) * 14.0 * dt
    end

    func drawCockpit screenWidth, screenHeight, score, player, fleet
        # 1. Top Header Glass Bar
        recHeader = Rectangle(0, 0, screenWidth, 48)
        DrawRectangleRounded(recHeader, 0.0, 0, RAYLibColor(10, 15, 25, 210))
        DrawRectangleLines(0, 0, screenWidth, 48, DARKBLUE)

        # Score with Sci-Fi Font
        drawTextStyled("SCORE: " + score, 25, 14, 20, GOLD)

        # Wave Info
        drawTextStyled("WAVE " + fleet.currentWave + " / " + fleet.maxWaves, screenWidth / 2 - 80, 14, 20, SKYBLUE)

        # Enemies Remaining
        drawTextStyled("ENEMIES: " + fleet.count(), screenWidth - 190, 14, 18, RAYWHITE)

        # 2. Bottom Left: Rounded Player Hull Bar
        recHullBg = Rectangle(25, screenHeight - 65, 220, 24)
        DrawRectangleRounded(recHullBg, 0.35, 4, DARKGRAY)
        hpWidth = (player.health / player.maxHealth) * 214
        if hpWidth > 0
            hpColor = GREEN
            if player.health < 45 hpColor = ORANGE ok
            if player.health < 25 hpColor = RED ok
            recHp = Rectangle(28, screenHeight - 62, hpWidth, 18)
            DrawRectangleRounded(recHp, 0.35, 4, hpColor)
        ok
        DrawRectangleRoundedLines(recHullBg, 0.35, 4, 1.5, WHITE)
        drawTextStyled("HULL INTEGRITY: " + player.health + "%", 28, screenHeight - 90, 15, RAYWHITE)

        # 3. Bottom Center: Speedometer & Flight Dashboard
        recDash = Rectangle(screenWidth/2 - 210, screenHeight - 75, 420, 65)
        DrawRectangleRounded(recDash, 0.25, 6, RAYLibColor(10, 15, 25, 225))
        DrawRectangleRoundedLines(recDash, 0.25, 6, 1.5, DARKBLUE)

        curKmSpeed = floor(player.forwardSpeed * 2.5)
        if player.throttleState = 1
            drawTextStyled(">> AFTERBURNER BOOST: " + curKmSpeed + " KM/S <<", screenWidth/2 - 180, screenHeight - 68, 14, GOLD)
        elseif player.throttleState = -1
            drawTextStyled("<< AIR-BRAKE ACTIVE: " + curKmSpeed + " KM/S >>", screenWidth/2 - 170, screenHeight - 68, 14, SKYBLUE)
        else
            drawTextStyled("- CRUISE PROPULSION: " + curKmSpeed + " KM/S -", screenWidth/2 - 165, screenHeight - 68, 14, LIGHTGRAY)
        ok

        # Speedometer progress bar
        recSpdBg = Rectangle(screenWidth/2 - 180, screenHeight - 44, 360, 10)
        DrawRectangleRounded(recSpdBg, 0.5, 4, DARKGRAY)
        spdRatio = (player.forwardSpeed - player.brakeSpeed) / (player.boostSpeed - player.brakeSpeed)
        if spdRatio < 0.05 spdRatio = 0.05 ok
        if spdRatio > 1.0 spdRatio = 1.0 ok
        barColor = SKYBLUE
        if player.throttleState = 1 barColor = ORANGE ok
        if player.throttleState = -1 barColor = BLUE ok
        recSpdFill = Rectangle(screenWidth/2 - 180, screenHeight - 44, 360 * spdRatio, 10)
        DrawRectangleRounded(recSpdFill, 0.5, 4, barColor)

        # Heading & Controls Info
        curHeading = floor(player.yaw)
        drawTextStyled("HDG: " + curHeading + "°", screenWidth/2 - 180, screenHeight - 27, 12, GREEN)
        drawTextStyled("[A/D] 360° TURN  |  [U] 180° REVERSE", screenWidth/2 - 70, screenHeight - 27, 12, LIGHTGRAY)

        # 4. Bottom Right: Rounded Power-up Timers
        if player.powerShieldTimer > 0
            recShield = Rectangle(screenWidth - 225, screenHeight - 75, 200, 26)
            DrawRectangleRounded(recShield, 0.3, 4, RAYLibColor(0, 80, 180, 200))
            drawTextStyled("SHIELD: " + ceil(player.powerShieldTimer) + "S", screenWidth - 210, screenHeight - 70, 15, SKYBLUE)
        ok
        if player.powerShotTimer > 0
            recShot = Rectangle(screenWidth - 225, screenHeight - 42, 200, 26)
            DrawRectangleRounded(recShot, 0.3, 4, RAYLibColor(0, 150, 50, 200))
            drawTextStyled("MEGA SHOT: " + ceil(player.powerShotTimer) + "S", screenWidth - 210, screenHeight - 37, 15, GREEN)
        ok

        # 5. 3D Aim Crosshair in center
        DrawCircleLines(screenWidth / 2, screenHeight / 2 - 25, 16, RAYLibColor(0, 200, 255, 140))
        DrawCircleLines(screenWidth / 2, screenHeight / 2 - 25, 4, RAYLibColor(0, 200, 255, 180))
        DrawLine(screenWidth / 2 - 24, screenHeight / 2 - 25, screenWidth / 2 + 24, screenHeight / 2 - 25, RAYLibColor(0, 200, 255, 110))
        DrawLine(screenWidth / 2, screenHeight / 2 - 49, screenWidth / 2, screenHeight / 2 - 1, RAYLibColor(0, 200, 255, 110))

        # 6. Tactical Dogfight Radar Alert
        if fleet.behindCount > 0
            alertColor = RED
            if sin(GetTime() * 10.0) > 0 alertColor = GOLD ok
            recAlert = Rectangle(screenWidth/2 - 270, screenHeight - 110, 540, 28)
            DrawRectangleRounded(recAlert, 0.3, 4, RAYLibColor(45, 10, 10, 225))
            DrawRectangleRoundedLines(recAlert, 0.3, 4, 1.5, alertColor)
            drawTextStyled("! " + fleet.behindCount + " ENEMY BEHIND (" + floor(fleet.closestBehindDist) + "M) - TAP [U] FOR 180° FLIP !", screenWidth/2 - 255, screenHeight - 104, 13, alertColor)
        elseif fleet.targetLockIdx > 0
            recLock = Rectangle(screenWidth/2 - 140, screenHeight - 105, 280, 24)
            DrawRectangleRounded(recLock, 0.3, 4, RAYLibColor(10, 30, 20, 200))
            DrawRectangleRoundedLines(recLock, 0.3, 4, 1.5, GREEN)
            drawTextStyled("TARGET LOCK: " + floor(fleet.minTargetDist) + " M", screenWidth/2 - 115, screenHeight - 100, 14, GREEN)
        ok

        # 7. Tactical Mini-Radar Screen (Side Radar with Red Enemy Dots)
        drawTacticalRadar(screenWidth, screenHeight, player, fleet)
    end

    # ---------------------------------------------------------------
    # Tactical Mini-Radar Screen (Side Radar with Red Enemy Dots)
    # ---------------------------------------------------------------
    func drawTacticalRadar screenWidth, screenHeight, player, fleet
        radarRadius   = 66.0
        radarX        = screenWidth - 88
        radarY        = 132
        radarMaxRange = 500.0

        # 1. Bezel & Dark Cyber Background
        DrawCircle(radarX, radarY, radarRadius + 4, RAYLibColor(12, 18, 30, 190))
        DrawCircleLines(radarX, radarY, radarRadius + 4, DARKBLUE)
        DrawCircle(radarX, radarY, radarRadius, RAYLibColor(6, 12, 22, 225))

        # 2. Concentric Range Grid Rings
        DrawRingLines(Vector2(radarX, radarY), radarRadius - 1.0, radarRadius + 1.0, 0.0, 360.0, 36, RAYLibColor(0, 140, 230, 180))
        DrawCircleLines(radarX, radarY, radarRadius * 0.60, RAYLibColor(0, 90, 170, 110))
        DrawCircleLines(radarX, radarY, radarRadius * 0.25, RAYLibColor(0, 80, 150, 90))

        # Crosshairs
        DrawLine(radarX - radarRadius, radarY, radarX + radarRadius, radarY, RAYLibColor(0, 110, 200, 75))
        DrawLine(radarX, radarY - radarRadius, radarX, radarY + radarRadius, RAYLibColor(0, 110, 200, 75))

        # 3. Rotating Radar Sweep Beam
        sweepAng = GetTime() * 3.2
        swX = radarX + cos(sweepAng) * radarRadius
        swY = radarY + sin(sweepAng) * radarRadius
        DrawLine(radarX, radarY, swX, swY, RAYLibColor(0, 210, 255, 95))

        # 4. Labels & Compass Reference
        drawTextStyled("FWD", radarX - 14, radarY - radarRadius - 14, 10, SKYBLUE)
        drawTextStyled("RADAR 500M", radarX - 38, radarY + radarRadius + 8, 10, SKYBLUE)

        # 5. Center Player Marker (Cyan Triangle pointing Up)
        DrawCircle(radarX, radarY, 2.5, SKYBLUE)
        DrawLine(radarX, radarY - 6, radarX - 3, radarY + 2, SKYBLUE)
        DrawLine(radarX, radarY - 6, radarX + 3, radarY + 2, SKYBLUE)
        DrawLine(radarX - 3, radarY + 2, radarX + 3, radarY + 2, SKYBLUE)

        # 6. Plot Nearby Enemies as Red Dots
        yawRad  = player.yaw * DEG2RAD
        hFwdX   = -sin(yawRad)
        hFwdZ   = cos(yawRad)
        hRightX = -cos(yawRad)
        hRightZ = -sin(yawRad)

        for i = 1 to len(fleet.enemiesList)
            en = fleet.enemiesList[i]
            ePos  = en[1]
            eType = en[3]

            dx = ePos.x - player.pos.x
            dz = ePos.z - player.pos.z

            # Relative coordinates in player's horizontal frame
            relRight = dx * hRightX + dz * hRightZ
            relFwd   = dx * hFwdX   + dz * hFwdZ

            dist2D = sqrt(relRight*relRight + relFwd*relFwd)
            normX  = relRight / radarMaxRange
            normY  = -relFwd / radarMaxRange

            distRatio = dist2D / radarMaxRange

            if distRatio <= 1.0
                blipX = radarX + normX * radarRadius
                blipY = radarY + normY * radarRadius

                blipRadius = 3.5
                if eType = 4 blipRadius = 5.5 ok # Cruiser / Boss is larger

                # Bright Red Dot
                DrawCircle(blipX, blipY, blipRadius, RED)
                DrawCircleLines(blipX, blipY, blipRadius + 1.0, MAROON)

                # Pulsing target lock indicator
                if i = fleet.targetLockIdx
                    DrawCircleLines(blipX, blipY, blipRadius + 3.0, YELLOW)
                ok

                # Behind indicator glow (if enemy is in rear sector)
                if relFwd < 0
                    DrawCircleLines(blipX, blipY, blipRadius + 2.0, RAYLibColor(255, 60, 60, 110))
                ok
            elseif distRatio <= 1.4
                # Outside radar: clamp to radar rim perimeter
                rimX = radarX + (normX / distRatio) * (radarRadius - 2.0)
                rimY = radarY + (normY / distRatio) * (radarRadius - 2.0)
                DrawCircle(rimX, rimY, 2.2, RAYLibColor(220, 50, 50, 160))
            ok
        next
    end

    # ---------------------------------------------------------------
    # 1. Cinematic Story Prologue Banner (STATE_STORY)
    # ---------------------------------------------------------------
    func drawStoryBanner screenWidth, screenHeight
        # Backdrop dimming with subtle cosmic gradient
        DrawRectangleGradientV(0, 0, screenWidth, screenHeight, RAYLibColor(5, 10, 22, 180), RAYLibColor(2, 4, 12, 230))

        # Main Transmission Glass Panel with Vertical Gradient
        bW = 760
        bH = 460
        bX = screenWidth / 2 - bW / 2
        bY = screenHeight / 2 - bH / 2

        recBanner = Rectangle(bX, bY, bW, bH)
        DrawRectangleGradientV(bX, bY, bW, bH, RAYLibColor(16, 26, 48, 245), RAYLibColor(6, 10, 20, 252))
        DrawRectangleRoundedLines(recBanner, 0.06, 6, 2.2, SKYBLUE)

        # Tech Corner Brackets
        cr = 20
        DrawLine(bX + 4, bY + 4, bX + 4 + cr, bY + 4, GOLD)
        DrawLine(bX + 4, bY + 4, bX + 4, bY + 4 + cr, GOLD)
        DrawLine(bX + bW - 4, bY + 4, bX + bW - 4 - cr, bY + 4, GOLD)
        DrawLine(bX + bW - 4, bY + 4, bX + bW - 4, bY + 4 + cr, GOLD)
        DrawLine(bX + 4, bY + bH - 4, bX + 4 + cr, bY + bH - 4, GOLD)
        DrawLine(bX + 4, bY + bH - 4, bX + 4, bY + bH - 4 - cr, GOLD)
        DrawLine(bX + bW - 4, bY + bH - 4, bX + bW - 4 - cr, bY + bH - 4, GOLD)
        DrawLine(bX + bW - 4, bY + bH - 4, bX + bW - 4, bY + bH - 4 - cr, GOLD)

        # Priority Dispatch Header Bar with Gradient
        DrawRectangleGradientV(bX + 2, bY + 2, bW - 4, 38, RAYLibColor(28, 46, 82, 250), RAYLibColor(14, 22, 42, 240))
        DrawLine(bX + 2, bY + 40, bX + bW - 2, bY + 40, DARKBLUE)

        pulseTime = GetTime() * 4.0
        dotAlpha = floor(160 + sin(pulseTime) * 90)
        DrawCircle(bX + 25, bY + 20, 6, RAYLibColor(240, 50, 50, dotAlpha))
        DrawCircleLines(bX + 25, bY + 20, 9, RED)

        DrawText("PRIORITY DISPATCH // EMERGENCY TRANSMISSION PROTOCOL ALPHA", bX + 42, bY + 12, 14, GOLD)
        DrawText("SECTOR ORION", bX + bW - 130, bY + 12, 14, SKYBLUE)

        # Main Titles
        drawTextStyled("OPERATION: CHRONO-GATE", bX + 35, bY + 58, 24, GOLD)
        DrawText("THE SHADOW ARMADA INVASION // STAR DATE 2488", bX + 35, bY + 95, 17, SKYBLUE)
        DrawLine(bX + 35, bY + 120, bX + bW - 35, bY + 120, RAYLibColor(0, 150, 240, 100))

        # Narrative Story Content
        storyY = bY + 138
        DrawText("COMMAND BRIEFING:", bX + 35, storyY, 16, RAYWHITE)

        DrawText("> The peaceful colonies in the Orion sector are facing a surprise invasion!", bX + 45, storyY + 28, 16, LIGHTGRAY)
        DrawText("> The hostile Shadow Armada has breached the orbital defense grid through an", bX + 45, storyY + 52, 16, LIGHTGRAY)
        DrawText("  unstable Chrono-Gate warp rift, deploying heavy assault squadrons.", bX + 45, storyY + 74, 16, LIGHTGRAY)

        DrawText("> Earth Defense Fleet Command has initiated emergency combat mobilization.", bX + 45, storyY + 106, 16, RAYWHITE)
        DrawText("> As Earth's elite Vanguard Commander, you are summoned to the Starfleet Hangar.", bX + 45, storyY + 130, 16, GOLD)
        DrawText("> Choose your starfighter, calibrate tactical weapons, and engage the 10 waves!", bX + 45, storyY + 154, 16, SKYBLUE)

        # Action Prompt Button with Gradient & Pulse
        promptY = bY + bH - 65
        pulseBtn = floor(180 + sin(pulseTime) * 70)
        btnW = bW - 120
        btnH = 44
        btnX = bX + 60
        btnRec = Rectangle(btnX, promptY, btnW, btnH)
        DrawRectangleGradientV(btnX, promptY, btnW, btnH, RAYLibColor(24, 75, 45, pulseBtn), RAYLibColor(10, 32, 20, pulseBtn))
        DrawRectangleRoundedLines(btnRec, 0.25, 4, 2.0, GREEN)

        promptTxt = "PRESS [SPACE] OR [ENTER] TO ENTER STARFLEET HANGAR"
        pTxtW = MeasureText(promptTxt, 15)
        drawTextStyled(promptTxt, btnX + btnW / 2 - pTxtW / 2, promptY + 14, 15, GREEN)
    end

    # ---------------------------------------------------------------
    # 2. 3D Starfleet Hangar & Ship Selection UI (STATE_HANGAR)
    # ---------------------------------------------------------------
    func drawHangarUI screenWidth, screenHeight, selectedBay, bays, turntableSpin, showHUD
        bayData = bays[selectedBay]
        bName    = bayData[2]
        bClass   = bayData[3]
        bFaction = bayData[4]
        bArmor   = bayData[5]
        bWeapons = bayData[6]
        bSpeed   = bayData[7]
        bColor   = bayData[10]
        maxHP    = bayData[16]
        cruise   = bayData[17]
        boost    = bayData[18]
        turnSpd  = bayData[19]

        # Top Header Bar with Cyber Gradient
        recHeader = Rectangle(0, 0, screenWidth, 46)
        DrawRectangleGradientV(0, 0, screenWidth, 46, RAYLibColor(16, 28, 52, 240), RAYLibColor(8, 14, 28, 220))
        DrawRectangleLines(0, 0, screenWidth, 46, DARKBLUE)

        drawTextStyled("STARFLEET SHIP SELECTION HANGAR", 20, 13, 16, GOLD)
        DrawText("BAY " + selectedBay + " / " + len(bays) + " // [A]/[D] SELECT // [H] TOGGLE PANELS", screenWidth - 460, 15, 13, SKYBLUE)

        if showHUD
            # Left Panel: Vessel Technical Dossier (Expanded Width & Gradients)
            pW = 270
            pH = 450
            pX = 14
            pY = 62
            recLeft = Rectangle(pX, pY, pW, pH)
            DrawRectangleGradientV(pX, pY, pW, pH, RAYLibColor(14, 24, 44, 225), RAYLibColor(5, 9, 18, 240))
            DrawRectangleRoundedLines(recLeft, 0.08, 6, 1.8, bColor)

            # Left Panel Header with Gradient
            DrawRectangleGradientV(pX + 2, pY + 2, pW - 4, 30, RAYLibColor(28, 44, 76, 240), RAYLibColor(12, 20, 36, 220))
            drawTextStyled("VESSEL DOSSIER", pX + 12, pY + 8, 13, GOLD)

            # Ship Name & Faction with Strict Text Containment
            maxW = pW - 24
            curY = pY + 38
            curY = drawTextWithin(bName, pX + 12, curY, maxW, 11, bColor)
            curY = drawTextWithin(bClass, pX + 12, curY, maxW, 10, LIGHTGRAY)
            curY = drawTextWithin("FACTION: " + bFaction, pX + 12, curY, maxW, 10, SKYBLUE)
            DrawLine(pX + 12, curY + 4, pX + pW - 12, curY + 4, RAYLibColor(0, 120, 200, 80))

            # Combat Specs Bars with Horizontal Gradients
            sY = curY + 12
            DrawText("HULL ARMOR: " + maxHP + " HP", pX + 12, sY, 11, RAYWHITE)
            hpRatio = maxHP / 600.0
            if hpRatio > 1.0 hpRatio = 1.0 ok
            barWidth = maxW
            DrawRectangle(pX + 12, sY + 16, barWidth, 7, DARKGRAY)
            DrawRectangleGradientH(pX + 12, sY + 16, floor(barWidth * hpRatio), 7, GREEN, LIME)
            DrawRectangleLines(pX + 12, sY + 16, barWidth, 7, LIGHTGRAY)

            sY += 30
            DrawText("WEAPONS:", pX + 12, sY, 11, RAYWHITE)
            sY = drawTextWithin(bWeapons, pX + 12, sY + 14, maxW, 10, GOLD)

            sY += 6
            DrawText("SPEED: " + boost + " KM/S", pX + 12, sY, 11, RAYWHITE)
            spdRatio = boost / 130.0
            if spdRatio > 1.0 spdRatio = 1.0 ok
            DrawRectangle(pX + 12, sY + 16, barWidth, 7, DARKGRAY)
            DrawRectangleGradientH(pX + 12, sY + 16, floor(barWidth * spdRatio), 7, SKYBLUE, BLUE)
            DrawRectangleLines(pX + 12, sY + 16, barWidth, 7, LIGHTGRAY)

            sY += 30
            DrawText("AGILITY: " + turnSpd + " DEG/S", pX + 12, sY, 11, RAYWHITE)
            turnRatio = turnSpd / 140.0
            if turnRatio > 1.0 turnRatio = 1.0 ok
            DrawRectangle(pX + 12, sY + 16, barWidth, 7, DARKGRAY)
            DrawRectangleGradientH(pX + 12, sY + 16, floor(barWidth * turnRatio), 7, YELLOW, GOLD)
            DrawRectangleLines(pX + 12, sY + 16, barWidth, 7, LIGHTGRAY)

            sY += 32
            spinTxt = "TURNTABLE: ACTIVE (360°)"
            if not turntableSpin spinTxt = "TURNTABLE: PAUSED" ok
            DrawText(spinTxt, pX + 12, sY, 11, ORANGE)
            DrawText("[SPACE] Pause / Resume Spin", pX + 12, sY + 16, 10, LIGHTGRAY)

            # Right Panel: Flight Academy & Controls Manual (Gradients & Clean Fit)
            rX = screenWidth - pW - 14
            recRight = Rectangle(rX, pY, pW, pH)
            DrawRectangleGradientV(rX, pY, pW, pH, RAYLibColor(14, 24, 44, 225), RAYLibColor(5, 9, 18, 240))
            DrawRectangleRoundedLines(recRight, 0.08, 6, 1.8, SKYBLUE)

            # Right Panel Header with Gradient
            DrawRectangleGradientV(rX + 2, pY + 2, pW - 4, 30, RAYLibColor(28, 44, 76, 240), RAYLibColor(12, 20, 36, 220))
            drawTextStyled("FLIGHT ACADEMY", rX + 12, pY + 8, 13, GOLD)

            # Guidance: How to select ship
            mY = pY + 38
            DrawText("SELECTION CONTROLS:", rX + 12, mY, 11, GOLD)
            DrawText("- [A] / [D] or Arrows : Cycle Ships", rX + 12, mY + 18, 10, RAYWHITE)
            DrawText("- Keys [1] to [6]     : Direct Bay Select", rX + 12, mY + 34, 10, RAYWHITE)
            DrawText("- [SPACE]             : Toggle Turntable", rX + 12, mY + 50, 10, RAYWHITE)
            DrawText("- Mouse Drag & Wheel  : 3D Orbit/Zoom", rX + 12, mY + 66, 10, SKYBLUE)
            DrawText("- [H]                 : Hide/Show Panels", rX + 12, mY + 82, 10, YELLOW)

            DrawLine(rX + 12, mY + 100, rX + pW - 12, mY + 100, RAYLibColor(0, 120, 200, 80))

            # Guidance: How to fly and combat
            mY += 108
            DrawText("COMBAT MANEUVERS:", rX + 12, mY, 11, GOLD)
            DrawText("- W / S / Arrows  : Pitch Climb & Dive", rX + 12, mY + 18, 10, RAYWHITE)
            DrawText("- A / D / Arrows  : 360° All-Range Turn", rX + 12, mY + 34, 10, RAYWHITE)
            DrawText("- SPACE / LMB     : Dual Plasma Cannons", rX + 12, mY + 50, 10, GREEN)
            DrawText("- SHIFT / E       : Turbo Afterburner", rX + 12, mY + 66, 10, SKYBLUE)
            DrawText("- CTRL / C        : Tactical Air-Brake", rX + 12, mY + 82, 10, RAYWHITE)
            DrawText("- U / F / R       : 180° Tactical U-Turn", rX + 12, mY + 98, 10, GOLD)
            DrawText("- Q / X / Z       : 360° Barrel Roll Dodge", rX + 12, mY + 114, 10, SKYBLUE)
            DrawText("- B               : Toggle Bloom Glow", rX + 12, mY + 130, 10, RAYWHITE)
        ok

        # Bottom Centered Launch Bar with Gradient
        pulseTime = GetTime() * 5.0
        launchAlpha = floor(180 + sin(pulseTime) * 75)
        barW = 480
        barH = 46
        barX = screenWidth / 2 - barW / 2
        barY = screenHeight - 56

        recLaunch = Rectangle(barX, barY, barW, barH)
        DrawRectangleGradientV(barX, barY, barW, barH, RAYLibColor(22, 65, 38, launchAlpha), RAYLibColor(8, 28, 16, launchAlpha))
        DrawRectangleRoundedLines(recLaunch, 0.25, 4, 2.0, GREEN)

        launchTxt = "PRESS [ENTER] TO LAUNCH STARFIGHTER!"
        lTxtW = MeasureText(launchTxt, 15)
        drawTextStyled(launchTxt, barX + barW / 2 - lTxtW / 2, barY + 14, 15, GREEN)
    end

    func drawMenu screenWidth, screenHeight
        mW = 560
        mH = 400
        mX = screenWidth/2 - mW/2
        mY = screenHeight/2 - mH/2
        recMenu = Rectangle(mX, mY, mW, mH)
        DrawRectangleGradientV(mX, mY, mW, mH, RAYLibColor(18, 28, 52, 245), RAYLibColor(6, 10, 20, 250))
        DrawRectangleRoundedLines(recMenu, 0.12, 6, 2.0, SKYBLUE)

        drawTextStyled("SPACE SHOOTER 3D", screenWidth/2 - 180, screenHeight/2 - 165, 26, GOLD)
        DrawText("Operation: Chrono-Gate - 360° All-Range Combat", screenWidth/2 - 240, screenHeight/2 - 115, 20, SKYBLUE)

        DrawText("FLIGHT CONTROLS:", screenWidth/2 - 230, screenHeight/2 - 75, 18, RAYWHITE)
        DrawText("- A / D / Arrows : Continuous 360° Turn & Banking", screenWidth/2 - 210, screenHeight/2 - 47, 16, LIGHTGRAY)
        DrawText("- W / S / Arrows : Pitch Up / Down (Climb & Dive)", screenWidth/2 - 210, screenHeight/2 - 23, 16, LIGHTGRAY)
        DrawText("- U / F / R      : 180° Tactical U-Turn (Turn Around & Attack)", screenWidth/2 - 210, screenHeight/2 + 1, 16, GOLD)
        DrawText("- Q / X / Z      : 360° Acrobatic Barrel Roll (Evasive Dodge)", screenWidth/2 - 210, screenHeight/2 + 25, 16, SKYBLUE)
        DrawText("- SHIFT / CTRL   : Afterburner Boost / Air-Brake", screenWidth/2 - 210, screenHeight/2 + 49, 16, RAYWHITE)
        DrawText("- SPACE / LMB    : Dual Plasma Cannons", screenWidth/2 - 210, screenHeight/2 + 73, 16, GREEN)
        DrawText("- B              : Toggle Bloom Post-Processing (OFF/ON)", screenWidth/2 - 210, screenHeight/2 + 97, 16, RAYWHITE)

        drawTextStyled("PRESS [SPACE] TO ENGAGE", screenWidth/2 - 160, screenHeight/2 + 140, 18, GREEN)
    end

    func drawGameOver screenWidth, screenHeight, score, distanceTraveled
        oW = 480
        oH = 260
        oX = screenWidth/2 - oW/2
        oY = screenHeight/2 - oH/2
        recOver = Rectangle(oX, oY, oW, oH)
        DrawRectangleGradientV(oX, oY, oW, oH, RAYLibColor(45, 12, 16, 248), RAYLibColor(14, 5, 8, 252))
        DrawRectangleRoundedLines(recOver, 0.15, 6, 2.2, RED)

        drawTextStyled("MISSION FAILED", screenWidth/2 - 140, screenHeight/2 - 95, 26, RED)
        drawTextStyled("FINAL SCORE: " + score, screenWidth/2 - 110, screenHeight/2 - 40, 18, GOLD)
        drawTextStyled("DISTANCE: " + floor(distanceTraveled) + " M", screenWidth/2 - 105, screenHeight/2 - 5, 16, RAYWHITE)

        drawTextStyled("PRESS [ENTER] TO RETRY // [H] FOR HANGAR", screenWidth/2 - 190, screenHeight/2 + 55, 15, GREEN)
    end

    func drawVictory screenWidth, screenHeight, score, distanceTraveled, maxWaves
        vW = 520
        vH = 280
        vX = screenWidth/2 - vW/2
        vY = screenHeight/2 - vH/2
        recVic = Rectangle(vX, vY, vW, vH)
        DrawRectangleGradientV(vX, vY, vW, vH, RAYLibColor(16, 45, 30, 248), RAYLibColor(6, 16, 12, 252))
        DrawRectangleRoundedLines(recVic, 0.15, 6, 2.2, GOLD)

        drawTextStyled("VICTORY! GALAXY SAVED!", screenWidth/2 - 180, screenHeight/2 - 100, 22, GOLD)
        drawTextStyled("FINAL SCORE: " + score, screenWidth/2 - 110, screenHeight/2 - 50, 18, SKYBLUE)
        drawTextStyled("ALL " + maxWaves + " WAVES DESTROYED!", screenWidth/2 - 130, screenHeight/2 - 15, 16, GREEN)
        drawTextStyled("TOTAL DISTANCE: " + floor(distanceTraveled) + " M", screenWidth/2 - 130, screenHeight/2 + 20, 16, GOLD)
        drawTextStyled("PRESS [ENTER] TO REPLAY // [H] FOR HANGAR", screenWidth/2 - 180, screenHeight/2 + 65, 15, RAYWHITE)
    end

    func cleanup
        if fontLoaded
            UnloadFont(fontSciFi)
            fontLoaded = false
        ok
    end
end
