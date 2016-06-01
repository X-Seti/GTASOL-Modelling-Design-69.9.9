NewDiffuseColor = (color 255 255 255)

for obj in selection do 
(
    mat = obj.material

    if classOf mat != Multimaterial then mat = #(mat)
    
    for m in mat where m != undefined do
        if classOf m == GTA_Mtl then m.color = NewDiffuseColor
        else
            if classOf m == Standard then m.diffuse = NewDiffuseColor
            else format "######################### UNDEFINED CLASS\n"
)