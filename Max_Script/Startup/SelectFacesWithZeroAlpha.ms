macroScript SelectFacesWithZeroAlpha category:"Deniska tools"
(
fn SelectFacesWithZeroAlpha obj =
(
	if obj == undefined then return false
	
	convertTo obj editable_mesh
	
	if meshop.GetMapSupport obj -2 == false then return false
	
	local i, j, fv, fsel = #{}, FaceIsBlack = true
	
	local FaceNum = obj.numfaces
	local MFaceNum = meshop.getNumMapFaces obj -2
	
	format "------------------- object: %\n" obj.name
	
	format "Num faces = %\nNum VA faces = %\n" FaceNum MFaceNum 
	
	if FaceNum != MFaceNum then return false
	
	for i = 1 to FaceNum do
	(
		fv = meshop.getMapFace obj -2 i
		--FaceIsBlack = true
		--for j in fv do 
			--if length (meshop.getMapVert obj -2 j) < 0.001 then (FaceIsBlack = false ;exit)
			
		if length (meshop.getMapVert obj -2 fv[1]) < 0.001 and
		   length (meshop.getMapVert obj -2 fv[2]) < 0.001 and
		   length (meshop.getMapVert obj -2 fv[3]) < 0.001 then append fsel i
		
		--if FaceIsBlack then append fsel i
	)
	
	setFaceSelection obj fsel
	true
)

for obj in selection do -- obj = selection[1]
	if SuperClassOf obj == GeometryClass then SelectFacesWithZeroAlpha obj
)