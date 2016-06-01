macroscript TexturedBevel category:"Deniska tools"
(
 rollout TexBevRoll "" width:222 height:217
 (
 	GroupBox grp1 "bevel type" pos:[8,10] width:108 height:77
 	radiobuttons btype "" pos:[18,31] width:85 height:48 labels:#("Group", "Local Normal", "By Polygon") \
	                      default:1 columns:1 enabled:false
 	label lbl1 "outline amount" pos:[132,49] width:74 height:16
 	label lbl2 "height" pos:[150,10] width:35 height:16
 	spinner bevheight "" pos:[136,28] width:62 height:16 range:[-1e+016,1e+016,0] type:#float enabled:false
 	spinner bevoutline "" pos:[136,68] width:62 height:16 range:[-1e+016,1e+016,0] type:#float enabled:false
 	button bevcencel "Cencel" pos:[11,177] width:91 height:28
 	button bevok "OK" pos:[121,176] width:91 height:28
		
 	button pbegin "preview begin" pos:[126,96] width:86 height:69
 	label lbl3 "scale" pos:[12,101] width:31 height:14
 	label lbl4 "W angle" pos:[11,124] width:47 height:14
 	label lbl5 "mat ID" pos:[11,149] width:47 height:14
 	spinner scl "" pos:[59,99] width:55 height:16 range:[-1e+016,1e+016,1] type:#float
 	spinner wan "" pos:[59,123] width:55 height:16 range:[-1e+016,1e+016,0] type:#float
 	spinner mid "" pos:[59,147] width:55 height:16 range:[1,100,1] type:#integer
	
	local obj = undefined
	
	fn tbevel s = (
    if iskindof s editable_poly then (
    local TVMat = rotateZMatrix (wan.value) -- matrix3 1
    local tscale = 1.0/(scl.value)
    local tdir = 1.0, toff = 0.0

    nf1 = getNumFaces s
    nv1 = getNumVerts s

    max modify mode 
    subObjectLevel = 4
    --s.bevelHeight = pheight.value
    --s.bevelOutline= poutline.value
    s.buttonOp #Bevel

    nf2 = getNumFaces s
    nv2 = getNumVerts s

    for i = nf1+1 to nf2 do --- for i in new faces
    ( 
      NMapFaces = polyOp.getNumMapVerts s 1
      polyOp.setNumMapVerts s 1 (NMapFaces+4) keep:true
      FaceVerts = polyOp.getFaceVerts s i
 
      P1 = polyOp.getVert s FaceVerts[1]
      P2 = polyOp.getVert s FaceVerts[2]
      P3 = polyOp.getVert s FaceVerts[3]
 
      Yvector = normalize (P2 - P1)
      Xvector = normalize (P3 - P1)
      Zvector = normalize (cross Xvector Yvector)
      Xvector = normalize (cross Yvector Zvector)
      CoordMat = matrix3 Xvector Yvector Zvector P1
 
      ty2 = (distance P1 P2)*tscale
      in coordSys CoordMat ty3 = (polyOp.getVert s FaceVerts[3]).y*tscale
      in coordSys CoordMat ty4 = (polyOp.getVert s FaceVerts[4]).y*tscale
 
      v1 = [0, toff, 0]*TVMat
      v2 = [0, toff + ty2, 0]*TVMat
      v3 = [-1, toff + ty3, 0]*TVMat
      v4 = [-1, toff + ty4, 0]*TVMat
 
      polyOp.setMapVert s 1 (NMapFaces+1) v1         ---- set texture verteces and faces
      polyOp.setMapVert s 1 (NMapFaces+2) v2
      polyOp.setMapVert s 1 (NMapFaces+3) v3
      polyOp.setMapVert s 1 (NMapFaces+4) v4
      polyOp.setMapFace s 1 i #(NMapFaces+1, NMapFaces+2, NMapFaces+3, NMapFaces+4)
      polyOp.setFaceMatID s i (mid.value)
      toff += ty2
      ) -- end for i in new faces
   )
 else messageBox "selected must be tditable poly"
	
	) -- function
	
	on pbegin pressed do
	   if selection.count == 1 then (
	      obj = selection[1]
		  obj.previewbegin #bevel
		  obj.bevelHeight = bevheight.value
		  obj.bevelOutline = bevoutline.value
		  obj.bevelType = btype.state - 1
		  btype.enabled = true
          bevheight.enabled = true
		  bevoutline.enabled = true
	   )
	
	on bevheight changed val do 
	   if obj != undefined then obj.bevelHeight = val	
	on bevOutline changed val do 
	   if obj != undefined then obj.bevelOutline = val
	on btype changed val do 
	   if obj != undefined then obj.beveltype = val-1
	
	on bevcencel pressed do 
	   if obj != undefined then obj.PreviewCancel()
	
	on bevok pressed do
	   if selection.count == 1 and selection[1] == obj then (
	      obj.PreviewCancel ()
	      tbevel obj
		  DestroyDialog TexBevRoll
	   )
	   
	
 ) -- roll

 On IsEnabled Return (Filters.Is_EPolySpecifyLevel #{5..6} and selection.count == 1)
 On IsVisible Return (Filters.Is_EPolySpecifyLevel #{5..6} and selection.count == 1) and \
                      not TexBevRoll.open
 On isChecked Do TexBevRoll.open					  
 
 On execute do (
     createDialog TexBevRoll
	 local obj = selection[1]
 )
 on closeDialogs do ( selection.count != 1 or selection[1] != obj )
) -- macro