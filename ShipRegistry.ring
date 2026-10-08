#===================================================================#
# Space Shooter 3D - Unified Starfleet Registry
# Single Source of Truth for 3D Models, Materials, Scales & Combat Specs
# Shared by the Starfleet Showroom/Hangar and the 3D Combat Simulator
#===================================================================#

# Starfleet Ship Index Constants
SHIP_COYOTE        = 1
SHIP_FIGHTER38     = 2
SHIP_FIGHTER232    = 3
SHIP_INTERGALACTIC = 4
SHIP_ATTACK        = 5
SHIP_BOSS          = 6
TOTAL_STARFLEET    = 6

# -------------------------------------------------------------------
# Clean Obsolete / Temporary Early Development Files from data/
# -------------------------------------------------------------------
func cleanObsoleteDataFiles
    filesToRemove = [
        "data/hero_plane.obj",
        "data/enemy_boss.obj",
        "data/plane.obj",
        "data/chrono_gate_warp.jpg",
        "data/dogfight_battle.jpg",
        "data/shadow_boss.jpg",
        "data/New folder/enemy_interceptor.obj",
        "data/New folder/enemy_scout.obj"
    ]
    for f in filesToRemove
        if fexists(f)
            remove(f)
        ok
    next
end

# -------------------------------------------------------------------
# Helper: Get All Starfleet Ship Definitions
# -------------------------------------------------------------------
func getStarfleetBays
    return [
        # Bay 1: Quarren Coyote (Vanguard Starfighter)
        [
            1,
            "QUARREN COYOTE [VANGUARD INTERCEPTOR]",
            "Player Multi-Vector Vanguard Starfighter",
            "Earth Defense Fleet (Vanguard Commander)",
            "Ceramic Composite Ablative Armor (120 HP)",
            "Dual High-Energy Plasma Cannons + Hyperspace Boost",
            "52 - 115 KM/S (Afterburners)",
            Vector3(-55.0, 3.4, 6.0),
            0.018, # showroom scale
            RAYLibColor(90, 150, 210, 255),
            0.4,   # yOffset
            0.0,   # zOffset
            0.0,   # rotOffset
            "data/quarren_coyote_ship.obj",
            0.015, # player combat scale
            120,   # maxHealth
            52.0,  # cruiseSpeed
            115.0, # boostSpeed
            110.0, # turnSpeed
            0.17,  # fireCooldown
            0.015, # enemyScale
            0.0    # yMeshOffset
        ],
        # Bay 2: Fighter 38 (Recon Scout Drone)
        [
            2,
            "FIGHTER 38 [RECON SCOUT DRONE]",
            "High-Agility Lightweight Scouting Interceptor",
            "Shadow Armada (Vanguard Scout Squadron)",
            "Crimson Nanotech Cellular Carbon Plating (90 HP)",
            "Rapid Twin Pulse Blasters (High Fire Rate)",
            "65 - 130 KM/S (Agile Vector)",
            Vector3(-33.0, 3.4, 2.0),
            2.60,
            RAYLibColor(230, 60, 60, 255),
            0.1,
            0.0,
            90.0, # rotOffset (Nose is along -X in Blender)
            "data/fighter_38/fighter_38.obj",
            3.60, # player combat scale (enlarged to true fighter proportion)
            90,    # maxHealth
            65.0,  # cruiseSpeed
            130.0, # boostSpeed
            140.0, # turnSpeed
            0.12,  # fireCooldown
            2.60,  # enemyScale
            0.0    # yMeshOffset
        ],
        # Bay 3: Fighter 232 (Heavy Strike Raider)
        [
            3,
            "FIGHTER 232 [HEAVY STRIKE RAIDER]",
            "Heavy Frontline Assault Fighter with Multi-Wing Stabilizers",
            "Shadow Armada (Main Battle Wing)",
            "Cobalt Heavy Titanium Blast Armor (160 HP)",
            "Twin Heavy Laser Nacelles & Wingtip Pods",
            "42 - 95 KM/S (Heavy Assault)",
            Vector3(-11.0, 3.4, -2.0),
            0.28,
            RAYLibColor(50, 135, 240, 255),
            -0.5,
            0.0,
            90.0, # rotOffset (Nose is along -X in Blender)
            "data/fighter_232/fighter_232.obj",
            0.26, # player combat scale
            160,   # maxHealth
            42.0,  # cruiseSpeed
            95.0,  # boostSpeed
            85.0,  # turnSpeed
            0.20,  # fireCooldown
            0.26,  # enemyScale
            0.0    # yMeshOffset
        ],
        # Bay 4: Intergalactic Spaceship (Razor Stealth Interceptor)
        [
            4,
            "INTERGALACTIC CRUISER [RAZOR INTERCEPTOR]",
            "High-Speed Precision Pursuit Dogfighter",
            "Shadow Armada (Elite Hunter-Killer Unit)",
            "Obsidian Stealth Carbon-Weave Composite (100 HP)",
            "Forward-Swept Wingtip Rail-Lasers",
            "58 - 120 KM/S (Fast Pursuit)",
            Vector3(11.0, 3.4, -2.0),
            1.50,
            RAYLibColor(180, 70, 220, 255),
            0.2,
            0.0,
            0.0, # rotOffset
            "data/enemy_fighter.obj",
            1.15, # player combat scale
            100,   # maxHealth
            58.0,  # cruiseSpeed
            120.0, # boostSpeed
            125.0, # turnSpeed
            0.15,  # fireCooldown
            1.15,  # enemyScale
            0.0    # yMeshOffset
        ],
        # Bay 5: Attack Fighter (Heavy Escort Cruiser)
        [
            5,
            "ATTACK FIGHTER [HEAVY ESCORT CRUISER]",
            "Alternative Heavy Armor Siege Gunship Drone",
            "Shadow Armada (Reinforcement Division)",
            "Reinforced Bronze Ablative Plating (140 HP)",
            "Dual Pulse Repeaters & Plasma Pods",
            "46 - 102 KM/S (Cruiser)",
            Vector3(33.0, 3.4, 2.0),
            0.013,
            RAYLibColor(230, 140, 40, 255),
            -10.1,
            -1.6,
            0.0,   # rotOffset
            "data/enemy_scout.obj",
            0.0085,# player combat scale (sleek, proportional)
            140,   # maxHealth
            46.0,  # cruiseSpeed
            102.0, # boostSpeed
            95.0,  # turnSpeed
            0.18,  # fireCooldown
            0.0090,# enemyScale
            760.0  # yMeshOffset (shifted down to align with laser fire points)
        ],
        # Bay 6: Titan Dreadnought Flagship Boss
        [
            6,
            "TITAN DREADNOUGHT BOSS [ARMADA CAPITAL FLAGSHIP]",
            "COLOSSAL CAPITAL FLAGSHIP // ENLARGED BOSS VESSEL",
            "Shadow Armada (Armada High Command)",
            "Hazard Gold Blast Plating + Fortress Shield (600 HP)",
            "Quad Heavy Plasma Turrets + Swarm Missiles + Fortress Shield Grid",
            "28 KM/S (Dreadnought Flagship)",
            Vector3(55.0, 6.2, 6.0),
            3.80, # showroom scale
            GOLD,
            0.8,
            0.0,
            0.0, # rotOffset
            "data/enemy_fighter.obj",
            1.35, # player combat scale (perfect size behind chase camera, never blocks screen!)
            600,  # maxHealth
            28.0, # cruiseSpeed
            55.0, # boostSpeed
            60.0, # turnSpeed
            0.24, # fireCooldown
            2.90, # enemyScale (Giant flagship when encountered as an enemy Boss!)
            0.0   # yMeshOffset
        ]
    ]
end
