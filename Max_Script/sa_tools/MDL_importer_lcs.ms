commonBoneOrder = #("Root", "Pelvis", "Spine", "Spine1", "Neck", "Head", 
		"Bip01 L Clavicle", "L UpperArm", "L Forearm", "L Hand", "L Finger", "Bip01 R Clavicle",
		"R UpperArm", "R Forearm", "R Hand", "R Finger", "L Thigh", "L Calf",
		"L Foot", "L Toe0", "R Thigh", "R Calf", "R Foot", "R Toe0")
kamBoneID = #(0, 1, 2, 3, 4, 5, 31, 32, 33, 34, 35, 21, 22, 23, 24, 25, 41, 42, 43, 2000, 51, 52, 53, 2001)
kamFrameName =    #("Root", "Pelvis", "Spine", "Spine1", "Neck", "Head", 
		"Bip01~L~Clavicle", "L~UpperArm", "L~Forearm", "L~Hand", "L~Finger", "Bip01~R~Clavicle",
		"R~UpperArm", "R~Forearm", "R~Hand", "R~Finger", "L~Thigh", "L~Calf",
		"L~Foot", "L~Toe0", "R~Thigh", "R~Calf", "R~Foot", "R~Toe0")
kamBoneType = #(0, 0, 0, 2, 0, 3, 2, 0, 0, 0, 1, 0, 0, 0, 0, 1, 2, 0, 0, 1, 0, 0, 0, 1)
kamBoneIndex = #("00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23")

commonBoneOrderVCS = #("root", "pelvis", "spine", "spine1", "neck", "head",
		"jaw", "bip01_l_clavicle", "l_upperarm", "l_forearm", "l_hand", "l_finger",
		"bip01_r_clavicle", "r_upperarm", "r_forearm", "r_hand", "r_finger", "l_thigh",
		"l_calf", "l_foot", "l_toe0", "r_thigh", "r_calf", "r_foot",
		"r_toe0")
commonBoneNamesVCS = #("Root", "Pelvis", "Spine", "Spine1", "Neck", "Head",
		"Jaw", "Bip01 L Clavicle", "L UpperArm", "L Forearm", "L Hand", "L Finger",
		"Bip01 R Clavicle", "R UpperArm", "R Forearm", "R Hand", "R Finger", "L Thigh",
		"L Calf", "L Foot", "L Toe0", "R Thigh", "R Calf", "R Foot",
		"R Toe0")		
kamBoneIDVCS = 	#(0, 1, 2, 3, 4, 5, 
		8, 31, 32, 33, 34, 35, 
		21, 22, 23, 24, 25, 41,
		42, 43, 2000, 51, 52, 53, 
		2001)
kamFrameNameVCS =    #("Root", "Pelvis", "Spine", "Spine1", "Neck", "Head", 
		"Jaw", "Bip01~L~Clavicle", "L~UpperArm", "L~Forearm", "L~Hand", "L~Finger",
		"Bip01~R~Clavicle", "R~UpperArm", "R~Forearm", "R~Hand", "R~Finger", "L~Thigh",
		"L~Calf", "L~Foot", "L~Toe0", "R~Thigh", "R~Calf", "R~Foot",
		"R~Toe0")
kamBoneTypeVCS = 	#(0, 0, 0, 2, 0, 2,
		3, 2, 0, 0, 0, 1,
		0, 0, 0, 0, 1, 2, 
		0, 0, 1, 0, 0, 0, 
		1)
kamBoneIndexVCS = #("00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23")


LCSATOMIC1	= 0x01050001
LCSATOMIC2	= 0x01000001
LCSCLUMP		= 0x00000002

VCSATOMIC1	= 0x0004AA01
VCSATOMIC2	= 0x0004AA01
VCSCLUMP		= 0x0000AA02

importType	= 0
fn Short2Float shortInt =
(
	if (shortInt == 0) then return 0
	--format "shortInt: 0x%\n" (bit.intAsHex (shortInt))
	longInt = bit.shift shortInt 16
	--format "longInt: 0x%\n" (bit.intAsHex (longInt))
	sign = bit.and longInt 0x80000000
	if (sign != 0) then sign = 1
	exponent = bit.and longInt 0x7F800000
	exponent /= 8388608
	exponent -= 127
	mantissaBits = bit.and longInt 0x007FFFFF
	mantissa = 1.0
	--format "mantissaBits: %\n" (bit.intAsHex (mantissaBits))
	for i = 1 to 23 do
	(
		temp = 1
		temp = bit.shift temp (23-i)
		temp = bit.and mantissaBits temp
		if (temp != 0) then mantissa += (pow 2 -i)
	)
	--format "mantissa: %\n" mantissa
	--format "exponent: %\n" exponent
	--format "sign: %\n" sign
	result = mantissa * (pow 2 exponent)
	if (sign == 1) then result *= -1
	--format "result: %\n" result
	return result
)

rollout importRoll "Importer"
(
	local fname = undefined
	local no_clump = #()

	button imp "Import  .MDL" width:120 align:#left
	spinner scaleFactor "Scale %:" fieldwidth:67 align:#left type:#float range:[0,1000000,100]
	checkbox faceFlip "Flip Even Faces" checked:false
	checkbox attachStrips "Attach Tri-Strips" checked:true

	on imp pressed do
	(
		fname = getopenfilename caption:"Import .MDL file" types:".MDL file (*.mdl)|*.mdl|"
		if fname != undefined then
		(
			clearlistener()
			f = fopen fname "rb"
			if f == undefined then ( Messagebox "Can't open the file" title:"I/O Error" ; 	fclose ; gc() ; return undefined )
			format "File % opened...\n" fname	
			fseek f 0 #seek_end
			fileEnd = ftell f
			
			format "fileEnd: %\n" fileEnd			
			fseek f 0 #seek_set						
			format "\nfile start: %\n" (bit.intAsHex (ftell f))
			
			--globalScale 		= scaleFactor.value * 0.0000003
			--New Scale - Difference in Factor: 1.0172734378213830268624789172734
			globalScale 		= scaleFactor.value * 0.00000030518203134641490805874367518203
			minVertDistance		= 0.000001
			
			sectionType 		= 1
			fileSize 			= 0
			ptr2BeforeTexNameList	= 0
			ptr2TexNameList 		= 0
			ptr2ptr2TexNameList 	= 0
			ptrFound 			= false
			topLevelPtr 		= 0
			xScale 			= 0.0
			yScale 			= 0.0
			zScale 			= 0.0
			atomics			= #()
			importedObjects		= #()
			strips			= #()
			verts 			= #()
			faces			= #()
			texCoords			= #()
			vertexColors		= #()
			normals			= #()			
			partMaterials		= #()
			partOffsets		= #()			
			curPart			= 0
			--tvertCounter		= 0
			validFacesIndices		= #()		
			textures			= #()
			atomicsCount		= 0
			curAtomic			= 0
			nextAtomic		= 0
			impObjectCount		= 0
			vertStage 		= 0			
			curStripVertCount 		= 0
			curStripTVertCount 		= 0
			curStripVertColorCount 	= 0
			curStripNormalsCount 	= 0
			curStripFaceCount 		= 0
			stripCount 		= 0
			Found6C018000		= false
			unknownSectionPtr		= 0
			curMatID			= 1
			overallTranslation		= point3 0 0 0
			curStripSkinData		= #()
			curStripSkinDataCount	= 0
			curSkinData		= undefined
			boneList			= #()
			skinModifier		= undefined
			firstFrame		= 0
			frameDataList		= #()
			curFrameData		= undefined
			
			importType		= 0
			
			struct AtomicsData (framePtr=0, geometryPtr=0, clumpPtr=0, nextAtomicPtr=0, materialList=#(), materialCount=0)
			struct MaterialData (rgba=0xFFFFFFFF, ambient=1.0, specular=0.0, diffuse=1.0, texture=undefined, reflectionMap=undefined, offset=0)
			struct SkinData (id1=0, weight1=1.0, id2=0, weight2=0.0, id3=0, weight3=0.0, id4=0, weight4=0.0)
			struct FrameData (object=undefined, name=undefined, pointer=0)
			
			while ((ftell f) < fileEnd) do
			(					
				case sectionType of
				(
					1: 			--header
					(

						l = ReadByte f #unsigned
						d = ReadByte f #unsigned
						m = ReadByte f #unsigned
						ReadByte f #unsigned						
						if (l != 'l' OR l != 'l' OR l != 'l') then
						(
							format ".MDL Header not recognized... exiting."
							fclose f
							gc()	
							return undefined						
						)
						ReadLong f
						fileSize = ReadLong f #unsigned
						unknown1 = ReadLong f
						unknown2 = ReadLong f
						actorMDL = false
						--if (unknown2 == unknown1 + 4) then actorMDL = true --WORKAROUND!!!
						ReadLong f
						ptr2BeforeTexNameList = ReadLong f #unsigned
						ReadLong f
						--if (actorMDL == true) then ReadLong f --WORKAROUND!!!
						temp = ReadLong f #unsigned						
						
						if (temp == LCSCLUMP) OR (temp == VCSCLUMP) then
						(
							if (importType == 0) then
							(
								if (temp == LCSCLUMP) then importType = 1
								else importType = 2								
							)
							topLevelPtr = 0x20							
							sectionType = 7
							fseek f -4 #seek_cur
							continue
						)
						
						topLevelPtr = temp						
						oldPos = ftell f
						fseek f topLevelPtr #seek_set
						temp = ReadLong f #unsigned
						
						
						if (temp == LCSATOMIC1) OR (temp == LCSATOMIC2) OR (temp == VCSATOMIC1) OR (temp == VCSATOMIC2) then
						--if ((((temp == LCSATOMIC1) OR (temp == LCSATOMIC2)) AND importType == 1) OR (((temp == VCSATOMIC1) OR (temp == VCSATOMIC2)) AND importType == 2))  then
						(
							
							if (importType == 0) then
							(
								if (temp == LCSATOMIC1) OR (temp == LCSATOMIC2) then importType = 1
								else importType = 2
							)
							else
							(
								if (((temp == LCSATOMIC1) OR (temp == LCSATOMIC2) AND importType == 2) OR ((temp == VCSATOMIC1) OR (temp == VCSATOMIC2) AND importType == 1)) then 
								(
									format "VERSION MISMATCH!!!! Trying to continue nonetheless....\n"
								)
							)								
							sectionType = 2
							atomicsCount = 1
							curAtomic = 1
							fseek f -4 #seek_cur
							continue
						)
						else
						(
							--we quite possibly have an actor mdl in this case; let's test it.
							if ((temp != LCSCLUMP) AND (temp != VCSCLUMP)) then
							(
								fseek f oldPos #seek_set
								temp = ReadLong f #unsigned
								topLevelPtr = temp	
								fseek f temp #seek_set
								temp = ReadLong f #unsigned
								if (temp == LCSATOMIC1) OR (temp == LCSATOMIC2) OR (temp == VCSATOMIC1) OR (temp == VCSATOMIC2) then
								(
									if (importType == 0) then
									(
										if (temp == LCSATOMIC1) OR (temp == LCSATOMIC2) then importType = 1
										else importType = 2
									)
									else
									(
										if (((temp == LCSATOMIC1) OR (temp == LCSATOMIC2) AND importType == 2) OR ((temp == VCSATOMIC1) OR (temp == VCSATOMIC2) AND importType == 1)) then 
										(
											format "VERSION MISMATCH!!!! Trying to continue nonetheless....\n"
										)
									)	
									actorMDL = true --WORKAROUND!!!
									sectionType = 2
									atomicsCount = 1
									curAtomic = 1
									fseek f -4 #seek_cur
									continue
								)
								else
								(									
									if ((temp != LCSCLUMP) AND (temp != VCSCLUMP)) then
									(
										format "Clump/Atomics not recognized... exiting.\n"
										fclose f
										gc()	
										return undefined
									)
									
									if (importType == 0) then
									(
										if (temp == LCSCLUMP) then importType = 1
										else importType = 2
									)								
									actorMDL = true --WORKAROUND!!!
									sectionType = 7
									fseek f -4 #seek_cur									
									continue
								)
							)
							
							if (importType == 0) then
							(
								if (temp == LCSCLUMP) then importType = 1
								else importType = 2
							)								
							sectionType = 7
							fseek f -4 #seek_cur
							continue
						)
					)
					
					0:			--unknown
					(
						temp = 0
						do
						(
							temp = ReadLong f #unsigned
						)
						while (temp == 0)
						
						if (temp == 0x01050001) then
						(
							sectionType = 2
							continue
						)
						if (temp == 0x00000008) then
						(
							sectionType = 3
							continue
						)
						if (temp == 0x0F000000) then
						(
							sectionType = 4
							continue
						)
						
						temp2 = ReadLong f #signed
											
						if (temp2 == -1) then
						(							
							ptr2TexNameList = temp
							ReadLong f #unsigned
							unknownSectionPtr = ReadLong f #unsigned
							continue
						)						
						
						if ((ftell f) == unknownSectionPtr+8) then
						(
							ReadLong f #unsigned
							ReadLong f #unsigned
							continue
						)
						
						if (ptrFound == true) then
						(
							sectionType = 5
							fseek f -8 #seek_cur
							continue
						)
						
						if (temp < fileEnd - 8) then
						(
							curFilePos = (ftell f)
							fseek f temp+4 #seek_set
							temp2 = ReadLong f #signed
							if (temp2 == -1) then
							(
								ptr2ptr2TexNameList = temp
								ptrFound = true
							)
							fseek f curFilePos-4 #seek_set							
						)
						else fseek f -8 #seek_cur						
						continue						
					)
					
					2:			--section 1051 (Atomic)
					(
						format "Atomic#% found at: 0x%...\n" (atomics.count+1) (bit.intAsHex (ftell f))
						currentAtomic = AtomicsData framePtr:0					
						ReadLong f #unsigned
						currentAtomic.framePtr = ReadLong f #unsigned
						dummies = #()
						boneList = #()
						if (actorMDL == true) then rootBoneLink = false
						else rootBoneLink = true
						if (curAtomic == 1) then
						(
							returnPos = ftell f
							curFramePtr = currentAtomic.framePtr							
							if (firstFrame == 0) then firstFrame = curFramePtr
							--else if (actorMDL == false) then curFramePtr = firstFrame							
							else curFramePtr = firstFrame
							parentDummy = undefined
							framePtrList = #()
							do
							(		
								fseek f (curFramePtr+8) #seek_set
								temp = ReadLong f #unsigned
								--if ((temp+4) == (ftell f)) then
								(
									curDummy = dummy boxsize:[(0.1*(scaleFactor.value/100)),(0.1*(scaleFactor.value/100)),(0.1*(scaleFactor.value/100))] position:[0,0,0]
									if (actorMDL == true) then
									(
										curDummy.wirecolor = color 255 255 0
										curDummy.showLinksOnly = true
									)
									append boneList curDummy									
									ReadLong f #unsigned
									temp1 = ReadFloat f
									temp2 = ReadFloat f
									temp3 = ReadFloat f
									ReadLong f #unsigned
									row1 = point3 temp1 temp2 temp3
									temp1 = ReadFloat f
									temp2 = ReadFloat f
									temp3 = ReadFloat f
									ReadLong f #unsigned
									row2 = point3 temp1 temp2 temp3
									temp1 = ReadFloat f
									temp2 = ReadFloat f
									temp3 = ReadFloat f
									ReadLong f #unsigned
									row3 = point3 temp1 temp2 temp3
									temp1 = ReadFloat f
									temp2 = ReadFloat f
									temp3 = ReadFloat f
									ReadLong f #unsigned
									row4 = point3 (temp1*scaleFactor.value/100) (temp2*scaleFactor.value/100) (temp3*scaleFactor.value/100)
									if (dummies.count > 0) then 
									(
										if (rootBoneLink == true) then curDummy.parent = dummies[dummies.count]
										else rootBoneLink = true
									)
									if (parentDummy != undefined) then curDummy.transform = parentDummy.transform
									transformMatrix = matrix3 row1 row2 row3 row4
									--curDummy.position += transformMatrix.translationPart
									--curDummy.transform = transformMatrix
									curDummy.rotation.controller.value = transformMatrix.rotationPart
									curDummy.position.controller.value = transformMatrix.translationPart
									--parentDummy = curDummy
									fseek f (curFramePtr+0xA4) #seek_set
									if (importType == 2) then fseek f 4 #seek_cur																		
									boneNamePtr = ReadLong f #unsigned
									if (boneNamePtr != 0) then
									(
										fseek f boneNamePtr #seek_set
										curBoneName = ReadString f
										curDummy.name = curBoneName
									)
									append dummies curDummy
									curFrameData = FrameData object:curDummy name:curBoneName pointer:curFramePtr
									append frameDataList curFrameData

								)
								fseek f (curFramePtr+0x90) #seek_set
								append framePtrList curFramePtr
								curFramePtr = ReadLong f #unsigned
								ReadLong f #unsigned
								ReadLong f #unsigned
								ReadLong f #unsigned
								ReadLong f #unsigned
								if (importType == 2) then fseek f 4 #seek_cur
								boneNamePtr = ReadLong f #unsigned
								tempPos = ftell f
								fseek f boneNamePtr #seek_set
								boneName = ReadString f
								fseek f tempPos #seek_set																						
								
								if (curFramePtr == 0) then
								(									
									while (framePtrList.count > 0)
									do
									(	
										newPos = framePtrList[framePtrList.count]

										fseek f (newPos+0x94) #seek_set
										curFramePtr = ReadLong f #unsigned
										if (curFramePtr != 0) then 
										(											
											deleteItem framePtrList framePtrList.count
											deleteItem dummies dummies.count
											exit
										)
										deleteItem framePtrList framePtrList.count
										deleteItem dummies dummies.count
									)
								)
							)
							while (curFramePtr != 0)
							fseek f returnPos #seek_set							
						)
						
						ReadLong f #unsigned
						ReadLong f #unsigned
						ReadLong f #unsigned
						currentAtomic.geometryPtr = ReadLong f #unsigned						
						currentAtomic.clumpPtr = ReadLong f #unsigned
						currentAtomic.nextAtomicPtr = ReadLong f #unsigned
						ReadLong f #unsigned
						ReadLong f #unsigned
						ReadLong f #unsigned
						ReadLong f #unsigned
						append atomics currentAtomic
						nextAtomic = currentAtomic.nextAtomicPtr
						if ((nextAtomic >= fileEnd) OR (nextAtomic == topLevelPtr+8)) then
						(
							nextAtomic = 0
						)
						sectionType = 3
						fseek f currentAtomic.geometryPtr #seek_set						
						continue						
					)
					
					3:			--section 08
					(					
						ReadLong f #unsigned
						ReadLong f #unsigned
						ReadLong f #unsigned
						partMaterials = #()
						materialListPtr = ReadLong f #unsigned
						materialCount = ReadLong f #unsigned
						
						if (materialCount > 0) then
						(
							oldPos = ftell f
							fseek f materialListPtr #seek_set
							for i = 1 to materialCount do 
							(
								currentMaterial = MaterialData offset:0
								curMatPtr= ReadLong f #unsigned
								oldMatPos = ftell f
								fseek f curMatPtr #seek_set
								texPtr = ReadLong f #unsigned
								if (texPtr > 0) then
								(
									tempPos = ftell f
									fseek f texPtr #seek_set
									currentMaterial.texture = ReadString f
									fseek f tempPos #seek_set
								)
								currentMaterial.rgba = ReadLong f #unsigned
								ReadLong f #unsigned
								specPtr = ReadLong f #unsigned
								if (specPtr > 0) then
								(
									tempPos = ftell f
									fseek f specPtr #seek_set
									ReadLong f #unsigned
									ReadLong f #unsigned
									currentMaterial.specular = ReadFloat f
									fseek f tempPos seek_set
								)
								fseek f oldMatPos #seek_set
								append (currentAtomic.materialList) currentMaterial
							)
							fseek f oldPos #seek_set							
						)
						
						for i = 1 to 13 do
						(
							ReadLong f #unsigned
						)
						xScale = ReadFloat f
						yScale = ReadFloat f
						zScale = ReadFloat f
						overallTranslation.x = (ReadFloat f)*scaleFactor.value/100
						overallTranslation.y = (ReadFloat f)*scaleFactor.value/100
						overallTranslation.z = (ReadFloat f)*scaleFactor.value/100	
						
						partOffsets = #()						
						temp = ReadLong f #unsigned			
						temp = bit.and temp 0x60000000
						while (temp != 0x60000000)
						do
						(
							for i = 1 to 6 do
							(
								ReadLong f #unsigned
							)
							temp = ReadLong f #unsigned
							append partOffsets temp
							ReadShort f #unsigned
							temp = ReadShort f #unsigned
							append partMaterials temp
							ReadLong f #unsigned
							ReadLong f #unsigned
							ReadLong f #unsigned
							temp = ReadLong f #unsigned
							temp = bit.and temp 0x60000000
						)						
						fseek f -4 #seek_cur
						
						
						--Geometry Parts Sub-Section Reached
						strips = #()
						stripCount = 0
						geoStart = ftell f
						format "geoStart: 0x%\n" (bit.intAsHex (ftell f))
						do
						(
							curPart = 0
							curPos = ftell f						
							for i = 1 to partMaterials.count do
							(								
								tempOffset = partOffsets[i]
								if (curPos >= (geoStart+tempOffset)) then
								(
									curPart += 1
								)
								else
								(
									exit
								)
								
							)	
							
							temp = ReadLong f #unsigned						
							temp = bit.and temp 0x60000000						
							while (temp != 0x60000000)
							do
							(
								for i = 1 to 11 do
								(
									ReadLong f #unsigned
								)
								temp = ReadLong f #unsigned
								temp = bit.and temp 0x60000000
							)						
							fseek f -4 #seek_cur
							
							if (Found6C018000 != true) then
							(
								for i = 1 to 4 do
								(
									ReadLong f #unsigned
								)
							)							
							Found6C018000 = false
							
							format "Tri-Strip Start: 0x%\n" (bit.intAsHex (ftell f))
														
							for i = 1 to 12 do
							(
								ReadLong f #unsigned
							)
														
							ReadShort f #unsigned						
							curStripVertCount = ReadByte f #unsigned
							ReadByte f #unsigned
															
							verts 		= #()
							faces		= #()
							validFacesIndices	= #()
							texCoords		= #()
							vertexColors	= #()
							normals		= #()
							curStripSkinData	= #()							
							curStripFaceCount = 0	
							curStripTVertCount = 0
							curStripVertColorCount = 0
							curStripNormalsCount = 0
							curStripSkinDataCount = 0														
							for i = 1 to curStripVertCount do
							(
								xPos = ReadShort f
								yPos = ReadShort f
								zPos = ReadShort f
								verts[i] = point3 (((xPos as Float)*xScale*globalScale)+overallTranslation.x) (((yPos as Float)*yScale*globalScale)+overallTranslation.y) (((zPos as Float)*zScale*globalScale)+overallTranslation.z)
												
								if (i > 2) do
								(
									--format "dist: %\n" (distance vert[i-1] vert [i]) 
									--if (((distance verts[i-2] verts[i-1]) >= minVertDistance) AND
									--    ((distance verts[i-1] verts[i])   >= minVertDistance) AND
									--    ((distance verts[i-2] verts[i])   >= minVertDistance)) then
									(
										curStripFaceCount += 1
										faces[curStripFaceCount] = [i-2, i-1, i]
										validFacesIndices[curStripFaceCount] = 1;
									)
								)
							)														
							
							if (mod curStripVertCount 2) == 1 then ReadShort f
							
							--UV/VertCol/Normals/SkinData Sub-Section Reached
							for i = 1 to 7 do
							(
								ReadLong f #unsigned
							)							
										
							ReadShort f #unsigned
							curStripTVertCount = ReadByte f #unsigned
							ReadByte f #unsigned
							
							for i = 1 to curStripTVertCount do
							(
								uCoord = (ReadByte f #unsigned) as Float
								uCoord /= 255.0
								uCoord *= 2.0
								vCoord = (ReadByte f #unsigned) as Float
								vCoord /= 255.0
								vCoord *= 2.0
								append texCoords (point3 uCoord (1-vCoord) 0.0)
							)
							sectionPadding = 4 - (mod (2*curStripTVertCount) 4)
							if (sectionPadding != 4) then
							(
								for i = 1 to sectionPadding do (ReadByte f #unsigned)
							)
							
							
							
							ReadByte f #unsigned
							unknownByte1 = ReadByte f #unsigned
							sectionCount = ReadByte f #unsigned
							unknownByte2 = ReadByte f #unsigned							
							if ((unknownByte1 == 0x80) AND (unknownByte2 == 0x6F)) then
							(
								curStripVertColorCount = sectionCount
								for i = 1 to curStripVertColorCount do
								(
									vColor = ReadShort f #unsigned
									vRed = (bit.and vColor 0x001F) as Float
									vRed *= 255.0/32.0
									vGreen = bit.and vColor 0x03E0
									vGreen /= 32
									vGreen = vGreen as Float
									vGreen *= 255.0/32.0
									vBlue = bit.and vColor 0x7C00
									vBlue /= 1024
									vBlue = vBlue as Float
									vBlue *= 255.0/32.0
									vAlpha = bit.and vColor 0x8000
									vAlpha /= 32768
									vAlpha = vAlpha as Float
									append vertexColors (color vRed vGreen vBlue vAlpha)
								)
								
								sectionPadding = 4 - (mod (2*curStripVertColorCount) 4)
								if (sectionPadding != 4) then
								(
									for i = 1 to sectionPadding do (ReadByte f #unsigned)
								)
							)
							else
							(
								if ((unknownByte1 == 0x80) AND (unknownByte2 == 0x6A)) then
								(
									curStripNormalsCount = sectionCount
									for i = 1 to curStripNormalsCount do
									(
										normalX = (ReadByte f #signed) as Float
										normalX /= 127.0
										normalY = (ReadByte f #signed) as Float
										normalY /= 127.0
										normalZ = (ReadByte f #signed) as Float
										normalZ /= 127.0
										append normals (point3 normalX normalY normalZ)										
									)
									
									sectionPadding = 4 - (mod (3*curStripNormalsCount) 4)
									if (sectionPadding != 4) then
									(
										for i = 1 to sectionPadding do (ReadByte f #unsigned)
									)
								)
								else
								(
									if ((unknownByte1 == 0x80) AND (unknownByte2 == 0x6C)) then
									(
										for i = 1 to sectionCount do
										(
											ReadLong f #unsigned
											ReadLong f #unsigned
											ReadLong f #unsigned
											ReadLong f #unsigned
										)										
									)
									else
									(
										format "Error! Did not recognize section in tri-strip segment... aborting.\n"
										return undefined
									)
								)
							)
							
							ReadByte f #unsigned
							unknownByte1 = ReadByte f #unsigned
							sectionCount = ReadByte f #unsigned
							unknownByte2 = ReadByte f #unsigned
							if ((unknownByte1 == 0x80) AND (unknownByte2 == 0x6A)) then
							(
								curStripNormalsCount = sectionCount
								for i = 1 to curStripNormalsCount do
								(
									normalX = (ReadByte f #signed) as Float
									normalX /= 127.0
									normalY = (ReadByte f #signed) as Float
									normalY /= 127.0
									normalZ = (ReadByte f #signed) as Float
									normalZ /= 127.0
									append normals (point3 normalX normalY normalZ)
								)
								
								sectionPadding = 4 - (mod (3*curStripNormalsCount) 4)
								if (sectionPadding != 4) then
								(
									for i = 1 to sectionPadding do (ReadByte f #unsigned)
								)
							)
							else
							(
								if ((unknownByte1 == 0x80) AND (unknownByte2 == 0x6C)) then
								(
									for i = 1 to sectionCount do
									(
										curSkinData = SkinData id1:0
										curSkinData.id1 = (ReadByte f #unsigned)/4
										ReadByte f #unsigned
										tempWeight = ReadShort f #unsigned
										curSkinData.weight1 = Short2Float tempWeight
										curSkinData.id2 = (ReadByte f #unsigned)/4
										ReadByte f #unsigned
										tempWeight = ReadShort f #unsigned
										curSkinData.weight2 = Short2Float tempWeight
										curSkinData.id3 = (ReadByte f #unsigned)/4
										ReadByte f #unsigned
										tempWeight = ReadShort f #unsigned
										curSkinData.weight3 = Short2Float tempWeight
										curSkinData.id4 = (ReadByte f #unsigned)/4
										ReadByte f #unsigned
										tempWeight = ReadShort f #unsigned
										curSkinData.weight4 = Short2Float tempWeight
										append curStripSkinData curSkinData										
										curStripSkinDataCount += 1
										--format "SkinData#%: %\n" curStripSkinDataCount curSkinData
									)
								)
								else
								(
									fseek f -4 #seek_cur
								)
							)		
												
							
							ReadLong f #unsigned		-- = 0x14000006, if all is well...						
							do
							(
								temp = ReadLong f #unsigned
							)
							while (temp == 0x00000000)
							
							if (temp == 0x6C018000) then
							(
								Found6C018000 = true
							)
							else 
							(
								temp = bit.and temp 0xFFFF0000
							)
							fseek f -4 #seek_cur														
													
							stripCount += 1
							strips[stripCount] = mesh vertices:verts faces:faces
																											
							
							setNumTverts  strips[stripCount] curStripTVertCount false
							buildTVFaces strips[stripCount] false
							for i = 1 to curStripTVertCount do
							(
								setTvert strips[stripCount] i texCoords[i]								
							)
							
							for i = 1 to curStripFaceCount do
							(
								setTVFace strips[stripCount] i faces[i].x faces[i].y faces[i].z								
							)
							
							if (curStripVertColorCount > 0) then
							(
								meshop.setMapSupport strips[stripCount] 0 true					
								meshop.setNumMapVerts strips[stripCount] 0 curStripVertColorCount
								
								setNumCPVVerts strips[stripCount] curStripVertColorCount false
								buildVCFaces strips[stripCount] false
								
								for i = 1 to curStripFaceCount do
								(
									setVCFace strips[stripCount] i faces[i].x faces[i].y faces[i].z
								)
								
								for i = 1 to curStripVertColorCount do
								(
									setVertColor strips[stripCount] i vertexColors[i]
								)
							)	
							
							if (curStripNormalsCount > 0) then
							(
								for i = 1 to curStripNormalsCount do
								(
									setNormal strips[stripCount] i normals[i]
								)
							)
							else 
							(
								meshop.unifyNormals strips[stripCount] strips[stripCount].faces
							)													
							
							meshop.deleteIsoVerts strips[stripCount]
							meshop.deleteIsoMapVertsAll strips[stripCount]
							for i = 1 to strips[stripCount].numfaces do
							(
								if ((mod i 2) == 0) then
								(
									if (faceFlip.checked == true) then meshop.flipnormals strips[stripCount] #(i)
								)
								
								curMatID = partMaterials[curPart] + 1
								setFaceMatID strips[stripCount] i (curMatID)							
							)														
							
							meshop.setVDataChannelSupport strips[stripCount] 11 true
							meshop.setVDataChannelSupport strips[stripCount] 12 true
							meshop.setVDataChannelSupport strips[stripCount] 13 true
							meshop.setVDataChannelSupport strips[stripCount] 14 true
							meshop.setVDataChannelSupport strips[stripCount] 15 true
							meshop.setVDataChannelSupport strips[stripCount] 16 true
							meshop.setVDataChannelSupport strips[stripCount] 17 true
							meshop.setVDataChannelSupport strips[stripCount] 18 true
							for i = 1 to curStripSkinData.count do
							(								
								meshop.setVDataValue strips[stripCount] 11 i curStripSkinData[i].id1
								meshop.setVDataValue strips[stripCount] 12 i curStripSkinData[i].weight1
								meshop.setVDataValue strips[stripCount] 13 i curStripSkinData[i].id2
								meshop.setVDataValue strips[stripCount] 14 i curStripSkinData[i].weight2
								meshop.setVDataValue strips[stripCount] 15 i curStripSkinData[i].id3
								meshop.setVDataValue strips[stripCount] 16 i curStripSkinData[i].weight3
								meshop.setVDataValue strips[stripCount] 17 i curStripSkinData[i].id4
								meshop.setVDataValue strips[stripCount] 18 i curStripSkinData[i].weight4
							)
														
							for i = strips[stripCount].numfaces to 1 by -1 do
							(
								faceVerts = getFace strips[stripCount] i
								if (((distance (getVert strips[stripCount] faceVerts.x) (getVert strips[stripCount] faceVerts.y)) < minVertDistance) OR
								    ((distance (getVert strips[stripCount] faceVerts.y) (getVert strips[stripCount] faceVerts.z))   < minVertDistance) OR
								    ((distance (getVert strips[stripCount] faceVerts.x) (getVert strips[stripCount] faceVerts.z))   < minVertDistance)) then
								(
									deleteFace strips[stripCount] i
								)
							)
							
							
							format "Tri-Strip#% has % vertices, % texels, % vertex colors and % normals with Material-ID %...\n" stripCount curStripVertCount curStripTVertCount curStripVertColorCount curStripNormalsCount curMatID
						)						
						while ((temp == 0x60000000) OR (Found6C018000 == true))
						
						
						if (attachStrips.checked == true) then
						(
							if (strips.count > 1) then
							(
								for i = 2 to strips.count do
								(
									attach strips[1] strips[i]
								)
								strips.count = 1
							)
							
							select strips[1]
							max backface			
							deselect strips[1]
						)
						else
						(
							for i = 1 to strips.count do
							(
								select strips[i]
								max backface			
								deselect strips[i]
							)
						)												
						
						tempMultiMat = undefined
						tempMaterial = undefined
						for i = 1 to materialCount do
						(
							if (i == 2) then
							(
								tempMultiMat = multimaterial numsubs:materialCount
								tempMultiMat[1] = tempMaterial 
							)
							
							tempMaterial = standardMaterial name:"Test"
							mRed = (bit.and (currentAtomic.materialList[i].rgba) 0xFF) as Float
							mGreen = (bit.and (currentAtomic.materialList[i].rgba) 0xFF00) as Float
							mGreen /= 256.0
							mBlue = (bit.and (currentAtomic.materialList[i].rgba) 0xFF0000) as Float
							mBlue /= 65536.0
							mAlpha = (bit.and (currentAtomic.materialList[i].rgba) 0xFF000000) as Float
							mAlpha /= 16777216.0
							if (mAlpha < 0.0) then mAlpha = 256.0 + mAlpha
							tempMaterial.Diffuse_Color = color mRed mGreen mBlue 255
							tempMaterial.opacity = ((100*mAlpha/255.0) as Integer)
							if ((currentAtomic.materialList[i].texture) != undefined) then
							(
								searchDir = getFilenamePath fname
								extension = ".png"
								bitmapName = searchDir + (currentAtomic.materialList[i].texture) + extension
								if ((doesFileExist bitmapName) == false) then
								(
									extension = ".tga"
									bitmapName = searchDir + (currentAtomic.materialList[i].texture) + extension
									if ((doesFileExist bitmapName) == false) then
									(
										extension = ".jpg"
										bitmapName = searchDir + (currentAtomic.materialList[i].texture) + extension
										if ((doesFileExist bitmapName) == false) then
										(
											extension = ".bmp"
											bitmapName = searchDir + (currentAtomic.materialList[i].texture) + extension
											if ((doesFileExist bitmapName) == false) then
											(
												bitmapName = undefined
											)
										)
									)
								)
								if (bitmapName != undefined) then
								(
									curBitmap = openBitmap bitmapName
									if (curBitmap != undefined) then
									(
										curBitmapTexture = bitmaptexture bitmap:curBitmap
										tempMaterial.DiffuseMap = curBitmapTexture
										showTextureMap tempMaterial tempMaterial.DiffuseMap true
									)
								)
							)
							
							if (i > 1) then
							(
								tempMultiMat[i] = tempMaterial 
							)
							
							if (i == materialCount) do 
							(
								if (tempMultiMat != undefined) then strips[1].material = tempMultiMat
								else strips[1].material = tempMaterial
							)
						)
									
						
						oldPos = ftell f
						
						/*if (actorMDL == true) then  fseek f firstFrame #seek_set
						else fseek f currentAtomic.framePtr #seek_set*/						
						fseek f currentAtomic.framePtr #seek_set

						if (actorMDL == false) then
						(
							for i = 1 to frameDataList.count do
							(								
								if (frameDataList[i].pointer == (ftell f)) then
								(									
									replaceObject = frameDataList[i].object
									strips[1].parent = replaceObject.parent
									for child in (replaceObject.children) do
									(
										--child = replaceObject.children[j]
										if (child != undefined) then
										(											
											append strips[1].children child
										)
									)	
									strips[1].name = replaceObject.name
									deleteItem frameDataList i
									delete replaceObject
									exit
								)
							)
						)
						ReadLong f #unsigned
						ReadLong f #unsigned
						ReadLong f #unsigned
						ReadLong f #unsigned
						temp1 = ReadFloat f
						temp2 = ReadFloat f
						temp3 = ReadFloat f
						ReadLong f #unsigned
						row1 = point3 temp1 temp2 temp3
						temp1 = ReadFloat f
						temp2 = ReadFloat f
						temp3 = ReadFloat f
						ReadLong f #unsigned
						row2 = point3 temp1 temp2 temp3
						temp1 = ReadFloat f
						temp2 = ReadFloat f
						temp3 = ReadFloat f
						ReadLong f #unsigned
						row3 = point3 temp1 temp2 temp3
						temp1 = ReadFloat f
						temp2 = ReadFloat f
						temp3 = ReadFloat f
						ReadLong f #unsigned
						row4 = point3 (temp1*scaleFactor.value/100) (temp2*scaleFactor.value/100) (temp3*scaleFactor.value/100)

						for i = 1 to strips.count do
						(
							--if (actorMDL == false) then
							(
								strips[i].transform = matrix3 row1 row2 row3 row4								
							)
						)
						
						
						if (actorMDL == true) then 
						(
							max modify mode
							select strips[1]							
							addModifier strips[1] (skin())
							skinModifier = strips[1].modifiers[1]
							rootBone = boneList[1] 
							/*rootBone = boneList[1]
							rootBone.parent = strips[1]
							boneList[2].parent = rootBone*/
							
							boneOrder = 0
							if (importType == 1) then boneOrder = commonBoneOrder
							else boneOrder = commonBoneOrderVCS
							
							for i = boneList.count to 1 by -1 do
							(
								if (boneList[i].name == "pivots" OR boneList[i].name == "male_base" OR boneList[i].name == "scene_root") then
								(
									delete boneList[i]
									deleteItem boneList i
									continue
								)
								if (boneList[i].name == "Root" OR boneList[i].name == "root") then
								(
									rootBone = boneList[i]									
									continue
								)
							)
							rootBone.parent = strips[1]
							
							for i = 1 to boneList.count do
							(
								if (boneList[i].name == "Pelvis" OR boneList[i].name == "pelvis") then
								(
									pelvisBone = boneList[i]
									pelvisBone.parent = rootBone
									exit
								)
							)								
															
							for j = 1 to boneOrder.count do
							(
								for i = 1 to boneList.count do
								(	
									if (boneList[i].name == "pivots" OR boneList[i].name == "male_base" OR boneList[i].name == "scene_root") then
									(
										continue
									)
									if (boneList[i].name == boneOrder[j]) then
									(
										format "3: %\n" i
										if (importType == 1) then
										(
											setUserProp boneList[i] "BoneID" kamBoneID[j]
											setUserProp boneList[i] "FrameName" kamFrameName[j]
											setUserProp boneList[i] "BoneType" kamBoneType[j]
											setUserProp boneList[i] "BoneIndex" kamBoneIndex[j]
										)
										else
										(
											boneList[i].name = commonBoneNamesVCS[j]
											setUserProp boneList[i] "BoneID" kamBoneIDVCS[j]
											setUserProp boneList[i] "FrameName" kamFrameNameVCS[j]
											setUserProp boneList[i] "BoneType" kamBoneTypeVCS[j]
											setUserProp boneList[i] "BoneIndex" kamBoneIndexVCS[j]
										)
										skinops.addbone skinModifier boneList[i] -1
										exit
									)
								)
								skinops.setStartPoint skinModifier j (skinops.getEndPoint skinModifier j)
								skinOps.SetInnerRadius skinModifier j 1 0
								skinOps.SetOuterRadius skinModifier j 1 0
								skinOps.SetInnerRadius skinModifier j 2 0
								skinOps.SetOuterRadius skinModifier j 2 0

							)
								
							for i = 1 to (strips[1].numverts as Integer) do
							(	
								temp1 = meshop.getVDataValue strips[1] 11 i
								temp2 = meshop.getVDataValue strips[1] 12 i
								temp3 = meshop.getVDataValue strips[1] 13 i
								temp4 = meshop.getVDataValue strips[1] 14 i
								temp5 = meshop.getVDataValue strips[1] 15 i
								temp6 = meshop.getVDataValue strips[1] 16 i
								temp7 = meshop.getVDataValue strips[1] 17 i
								temp8 = meshop.getVDataValue strips[1] 18 i

								boneIDs = #(((temp1+1) as Integer),((temp3+1) as Integer),((temp5+1) as Integer),((temp7+1) as Integer))
								vertexWeights = #(temp2,temp4,temp6,temp8)
								format "Processing Vertex#% out of %...\n" i strips[1].numverts
								skinOps.ReplaceVertexWeights skinModifier i boneIDs vertexWeights
							)
							format "Vertex Processing finished...\n"
							meshop.freeVData strips[1] 11
							meshop.freeVData strips[1] 12
							meshop.freeVData strips[1] 13
							meshop.freeVData strips[1] 14
							meshop.freeVData strips[1] 15
							meshop.freeVData strips[1] 16
							meshop.freeVData strips[1] 17
							meshop.freeVData strips[1] 18
							update strips[1]
						)
							
						fseek f oldPos #seek_set
						
						impObjectCount += 1
						append importedObjects strips[1]
						
						if (nextAtomic != 0) then
						(
							sectionType = 2
							fseek f (nextAtomic-0x1C) #seek_set
							curAtomic += 1
							continue
						)
						else
						(
							exit
						)												
					)
					
					4:			--section F0 (frame)
					(						
						for i = 1 to 39 do
						(
							ReadLong f #unsigned
						)
						sectionType = 0
						continue
					)
					
					5:			--ptr section
					(
						counter = 0
						do
						(
							temp = ReadLong f
							counter += 1
						)
						while (temp != 0x00000020)
						fseek f -4 #seek_cur
						read_in = 1
						if (counter == 12) then read_in = 2
						for i = 1 to read_in do
						(
							ReadLong f #unsigned
						)
						sectionType = 6
						continue
					)
					6:			--texture names section
					(
						temp = ReadString f						
						continue
					)
					7:
					(
						format "Clump found at: 0x%...\n" (bit.intAsHex (ftell f))
						ReadLong f #unsigned
						firstFrame = ReadLong f #unsigned
						firstAtomicPos = ReadLong f #unsigned						
						fseek f (firstAtomicPos-0x1C) #seek_set

						sectionType = 2
						atomicsCount = 1						
						curAtomic = 1
						continue
					)
					
				)					
						
			) --end while			
					
			importType = 0				
			fclose f
			gc()
			format "\n\n\n"
		)
	)
)



rollout aboutRoll "About"
(
	label a1 ".MDL importer (v0.2)"
	label a2 "by Alex"
	label a3 "Dedicated to Kam"

)


if AK73_MDL != undefined then 
(
	closeRolloutFloater AK73_MDL
	gc() 
)
AK73_MDL = newRolloutFloater ".MDL Importer" 175 245 10 100		
addRollout importRoll AK73_MDL 	rolledup:false
addRollout aboutRoll AK73_MDL 	rolledup:false
