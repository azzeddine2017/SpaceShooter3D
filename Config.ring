#===================================================================#
# Space Shooter 3D - Configuration & Math Utilities
#===================================================================#

# Screen Dimensions
SCREEN_WIDTH  = 1024
SCREEN_HEIGHT = 650

# Game States
STATE_STORY    = 0  # Cinematic Story Prologue Banner
STATE_HANGAR   = 1  # 3D Starfleet Hangar & Ship Selection
STATE_PLAYING  = 2  # Active 360° Space Dogfight Combat
STATE_GAMEOVER = 3  # Mission Failed Screen
STATE_VICTORY  = 4  # Mission Accomplished Screen
STATE_MENU     = STATE_HANGAR # Legacy compatibility alias

# Math Constants
PI      = 3.141592653589793
DEG2RAD = PI / 180.0
RAD2DEG = 180.0 / PI
CYAN    = SKYBLUE

# RayLib Material Texture Map Indices
MATERIAL_MAP_DIFFUSE = 0
MAP_DIFFUSE          = 0

# -------------------------------------------------------------------
# 3D Vector Math Utilities
# -------------------------------------------------------------------

# Calculate Euclidean distance between two 3D points
func getDistance3D v1, v2
    dx = v1.x - v2.x
    dy = v1.y - v2.y
    dz = v1.z - v2.z
    return sqrt(dx*dx + dy*dy + dz*dz)

# Normalize a 3D vector to unit length
func normalizeVector3 v
    lenSq = v.x*v.x + v.y*v.y + v.z*v.z
    if lenSq > 0.0001
        invL = 1.0 / sqrt(lenSq)
        return Vector3(v.x * invL, v.y * invL, v.z * invL)
    ok
    return Vector3(0.0, 0.0, -1.0)

# -------------------------------------------------------------------
# Particle & Powerup Helpers
# -------------------------------------------------------------------

# Spawn 3D particle explosion (snappy fireball expansion that dissipates quickly)
func spawnExplosion particlesList, pos, count, baseColor
    for k = 1 to count
        vel = Vector3(
            GetRandomValue(-160, 160) / 10.0,
            GetRandomValue(-160, 160) / 10.0,
            GetRandomValue(-160, 160) / 10.0
        )
        life = GetRandomValue(25, 45) / 100.0
        size = GetRandomValue(30, 65) / 100.0
        particlesList + [Vector3(pos.x, pos.y, pos.z), vel, baseColor, size, life, life]
    next

# Quick spark flash for laser impacts (very short life: 0.12 - 0.18s, flashes and vanishes)
func spawnImpactSparks particlesList, pos, count, baseColor
    for k = 1 to count
        vel = Vector3(
            GetRandomValue(-110, 110) / 10.0,
            GetRandomValue(-110, 110) / 10.0,
            GetRandomValue(-110, 110) / 10.0
        )
        life = GetRandomValue(10, 18) / 100.0
        size = GetRandomValue(18, 32) / 100.0
        particlesList + [Vector3(pos.x, pos.y, pos.z), vel, baseColor, size, life, life]
    next

# Spawn random powerup capsule (1: Health, 2: MegaShot, 3: Shield)
func spawnRandomPowerup powerupsList, x, y, z
    pType = GetRandomValue(1, 3)
    powerupsList + [Vector3(x, y, z), pType, 0.0]

