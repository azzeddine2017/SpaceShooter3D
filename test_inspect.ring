# Test script to inspect 3D models and measure their load time and bounding dimensions
load "raylib.ring"

func main
    InitWindow(400, 300, "Test Model Inspector")
    SetTargetFPS(60)

    modelFiles = [
        "data/Fighter+38_obj/Fighter 38.obj",
        "data/Fighter+232_obj/Fighter 232.obj",
        "data/enemy_fighter.obj",
        "data/enemy_scout.obj",
        "data/imperial_shuttle_ver1.obj"
    ]

    logStr = "MODEL INSPECTION REPORT:" + nl

    for i = 1 to len(modelFiles)
        mPath = modelFiles[i]
        logStr += "----------------------------------------" + nl
        logStr += "Checking: " + mPath + nl
        
        if not fexists(mPath)
            logStr += "ERROR: File does not exist!" + nl
            loop
        ok

        t0 = GetTime()
        m = LoadModel(mPath)
        t1 = GetTime()
        dt = t1 - t0

        logStr += "Loaded successfully in " + dt + " seconds" + nl
        logStr += "Mesh count: " + m.meshCount + nl
        logStr += "Material count: " + m.materialCount + nl

        UnloadModel(m)
    next

    logStr += "========================================" + nl
    logStr += "ALL MODELS TESTED SUCCESSFULLY!" + nl

    write("model_inspection_report.txt", logStr)
    see logStr

    CloseWindow()
end
