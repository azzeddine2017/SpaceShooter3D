# Calculate bounding boxes of the downloaded 3D OBJ models

func getObjBounds filePath
    if not fexists(filePath)
        see "File not found: " + filePath + nl
        return
    ok

    fp = fopen(filePath, "r")
    if fp = 0
        see "Could not open: " + filePath + nl
        return
    ok

    minX =  999999.0  maxX = -999999.0
    minY =  999999.0  maxY = -999999.0
    minZ =  999999.0  maxZ = -999999.0
    vCount = 0

    while not feof(fp)
        line = readline(fp)
        if len(line) > 2 and line[1] = "v" and line[2] = " "
            # Parse vertex line: v X Y Z
            parts = split(trim(line), " ")
            # remove empty tokens caused by multiple spaces
            coords = []
            for p in parts
                if len(p) > 0 and p != "v"
                    coords + 0.0 + p
                ok
            next
            if len(coords) >= 3
                x = coords[1]
                y = coords[2]
                z = coords[3]
                if x < minX minX = x ok
                if x > maxX maxX = x ok
                if y < minY minY = y ok
                if y > maxY maxY = y ok
                if z < minZ minZ = z ok
                if z > maxZ maxZ = z ok
                vCount++
            ok
        ok
    end
    fclose(fp)

    dimX = maxX - minX
    dimY = maxY - minY
    dimZ = maxZ - minZ
    centerX = (minX + maxX) / 2.0
    centerY = (minY + maxY) / 2.0
    centerZ = (minZ + maxZ) / 2.0

    out = "FILE: " + filePath + nl
    out += "Vertices: " + vCount + nl
    out += "Min: (" + minX + ", " + minY + ", " + minZ + ")" + nl
    out += "Max: (" + maxX + ", " + maxY + ", " + maxZ + ")" + nl
    out += "Center: (" + centerX + ", " + centerY + ", " + centerZ + ")" + nl
    out += "Dimensions: X=" + dimX + ", Y=" + dimY + ", Z=" + dimZ + nl
    out += "---------------------------------------------" + nl
    see out
    return out
end

func main
    rep = "MODEL BOUNDS REPORT:" + nl + nl
    rep += getObjBounds("data/Fighter+38_obj/Fighter 38.obj")
    rep += getObjBounds("data/Fighter+232_obj/Fighter 232.obj")
    rep += getObjBounds("data/enemy_fighter.obj")
    rep += getObjBounds("data/enemy_scout.obj")
    rep += getObjBounds("data/imperial_shuttle_ver1.obj")

    write("bounds_report.txt", rep)
end
