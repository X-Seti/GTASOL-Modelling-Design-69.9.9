global f, nvcF  

rollout NVC_rol "" width:234 height:320
( 
    local DFFdir = "D:\\"
--------------------------------------------------------------------------------------------------
fn CopyHeader SizeIncr= (
local i, res = #()

b = readLong f #unsigned
writeLong nvcF b #unsigned
res[1] = b

b = readLong f #unsigned
writeLong nvcF (b + SizeIncr) #unsigned
res[2] = b

b = readShort f #unsigned
writeShort nvcF b #unsigned
res[3] = b

b = readShort f #unsigned
writeShort nvcF b #unsigned
res[4] = b

res
)

--------------------------------------------------------------------------------------------------
fn CopyData n = (
local i, b
--format "\ndata :\n"

for i = 1 to n do (
b = readByte f #unsigned
writeByte nvcF b #unsigned
--format "% " b
--if (mod i 24) as integer == 0 do format "\n"
)
--format "\n"
)

--------------------------------------------------------------------------------------------------
fn FindSection DataID DataSize = (
local headerID, hSize, b, i

if DataSize > 0 then (
headerID = readLong f #unsigned
writeLong nvcF headerID #unsigned
hSize = readLong f #unsigned
writeLong nvcF hSize #unsigned
b = readShort f #unsigned
writeShort nvcF b #unsigned
b = readShort f #unsigned
writeShort nvcF b #unsigned
if headerID != DataID then (
copyData hSize
FindSection DataID (DataSize - hSize - 12)
)
else true
)
else false

) -- end FindExtension
--------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------- 
-------------------------------------------------------------------------------------------------- 
-------------------------------------------------------------------------------------------------- 
-------------------------------------------------------------------------------------------------- 
-------------------------------------------------------------------------------------------------- 

	button GoButton "APPEND"  width:70
	label lbl4 "NVC params"
	spinner spn1 "P1" range:[0, 255, 0] type:#integer width:60 align:#center
	spinner spn2 "P2" range:[0, 255, 0] type:#integer width:60 align:#center
	spinner spn3 "P3" range:[0, 255, 255] type:#integer width:60 align:#center
	spinner spn4 "P4" range:[0, 255, 255] type:#integer width:60 align:#center
	
	checkbox DelOriginal "into sourse"
	
	group "Edit normals"
	(
		checkbox EditNormalsCB "enabled"
	)
---------------------------------------------------------------------------------------------------

on GoButton pressed do (

if selection.count == 0 then messageBox "no objects selected"
else
if selection.count > 1 then messageBox "Select just 1 object"
else (
clearListener ()

--for nobj in selection do 
--(
nobj = selection[1]

--fname = Kdir.text + "\\" + nobj.name + ".dff" -- "D:\\SA_MOD\\test\\nvc_test1.dff"
fname = getOpenFileName types:"SA model (*.dff)|*.dff|"

if fname!=undefined then 
(
		format "file: %\n" fname
		
		f = fopen fname "rb"
		
		if f != undefined then 
		(
				fseek f 0 #seek_set
				
				s = copy nobj -- selection[1]
				
				convertToMesh s
				
				VCount = s.numverts
				aname = getFilenameFile fname
				OrigFileDir = getFilenamePath fname
				
				--SaveDir = Ddir.text -- "D:\\SA_MOD\\test\\nvc\\"
				NVCfname = OrigFileDir + "\\" + aname + "_NCV_applied.dff"
				
				unkn = (color spn1.value spn2.value spn3.value spn4.value)

				nvcF = fopen NVCfname "w+"
				
				if EditNormalsCB.checked then 
				(
					EN_MOD = nobj.modifiers[1]
					if classOf EN_MOD != Edit_normals then EN_MOD = undefined
				)
				else EN_MOD = undefined
				
				--------------------------------------------------------------------------------------------------
				ProcessDone = false
				
				H = CopyHeader (VCount*4 + 16) -- CLUMP
				FPosSize1 = (ftell nvcF) - 8
				DFFunk = H[3]
				DFFver = H[4]
				if H[1] == 16 then 
				(
				
					ClumpSize = H[2]
					
					H = CopyHeader 0 -- clump/struc
					if H[1] == 1 then 
					(
						b = readByte f #unsigned
						writeByte nvcF b #unsigned
						if b == 1 then 
						(
							CopyData (H[2]-1)
							
							H = CopyHeader 0 -- CLUMP/FRAMELIST
							if H[1] == 14 then 
							(
								CopyData H[2] 
								
								H = CopyHeader (VCount*4 + 16) -- CLUMP/GEOMETRYLIST
								FPosSize2 = (ftell nvcF) - 8
								if H[1] == 26 then 
								(
									GeomListSize = H[2]
									
									H = CopyHeader 0 -- CLUMP/GEOMETRYLIST/struc
									if H[1] == 1 then 
									(
										b = readByte f #unsigned
										writeByte nvcF b #unsigned
										if b == 1 then 
										(
											CopyData (H[2]-1)
											
											H = CopyHeader (VCount*4 + 16) -- CLUMP/GEOMETRYLIST/GEOMETRY
											FPosSize3 = (ftell nvcF) - 8
											if H[1] == 15 then 
											(
												H = CopyHeader 0 -- CLUMP/GEOMETRYLIST/GEOMETRY/struc
												if H[1] == 1 then 
												(
													flags = readShort f #unsigned -- flags 2
													
													writeShort nvcF flags #unsigned
													NumUVs = readByte f #unsigned -- NUM UV
													b = readByte f #unsigned -- NUM UV
													writeByte nvcF NumUVs #unsigned
													writeByte nvcF b #unsigned
													FNum = readLong f #unsigned -- faces 4
													writeLong nvcF FNum #unsigned
													VNum = readLong f #unsigned -- verts 4
													writeLong nvcF VNum #unsigned
													--format "\n\nFLAG = %\nF = %\nV = %\n" flags FNum VNum
													
													if VNum == VCount then 
													(
														b = readLong f #unsigned -- frame count 2
														writeLong nvcF b #unsigned
														
														if EditNormalsCB.checked and EN_MOD != undefined and (bit.and flags 4) > 0 then 
														(
															if (bit.and flags 3) > 0 then CopyData (VNum*4) -- VERT COLORS
															CopyData (VNum*NumUVs*8) -- UVs
															CopyData (FNum*8) -- Faces
															CopyData 24 -- Bounding + unk
															CopyData (VNum*12) -- VERTs
															
															EN_Norms = #{}
															
															for EN_i = 1 to VCount do --EN_MOD.GetNumVertices () do
															(
																EN_MOD.ConvertVertexSelection #{EN_i} EN_Norms
																EN_NormalVec = [0,0,0]
																for EN_j in EN_Norms do EN_NormalVec += EN_MOD.GetNormal EN_j
																EN_NormalVec = normalize EN_NormalVec
																writeFloat nvcF EN_NormalVec.x
																writeFloat nvcF EN_NormalVec.y
																writeFloat nvcF EN_NormalVec.z
															)
															
															fseek f (VNum*12) #seek_cur
															
														)
														else
															CopyData (H[2] - 16)
														
														H = CopyHeader 0 -- CLUMP/GEOMETRYLIST/GEOMETRY/MATLIST
														if H[1] == 8 then 
														(
															CopyData H[2]
															
															H = CopyHeader (VCount*4 + 16) -- CLUMP/GEOMETRYLIST/GEOMETRY/EXTEN
															FPosSize4 = (ftell nvcF) - 8
															if H[1] == 3 then 
															(
																CurFilePos = ftell f
																--format "\nCURRENT = % .... + DATA %\n" CurFilePos H[2]
																
																if (FindSection 39056121 H[2]) do (            -- if alredy have NVC then pass data
																 NVCpos = ftell nvcF
																 fseek f -8 #seek_cur
																 OldNVCsize = readLong f #unsigned
																 
																 fseek nvcF FPosSize1 #seek_set
																 b = readLong nvcF #unsigned
																 fseek nvcF -4 #seek_cur
																 writeLong nvcF (b - OldNVCsize - 12) #unsigned
																 
																 fseek nvcF FPosSize2 #seek_set
																 b = readLong nvcF #unsigned
																 fseek nvcF -4 #seek_cur
																 writeLong nvcF (b - OldNVCsize - 12) #unsigned
																
																 fseek nvcF FPosSize3 #seek_set
																 b = readLong nvcF #unsigned
																 fseek nvcF -4 #seek_cur
																 writeLong nvcF (b - OldNVCsize - 12) #unsigned
																
																 fseek nvcF FPosSize4 #seek_set
																 b = readLong nvcF #unsigned
																 fseek nvcF -4 #seek_cur
																 writeLong nvcF (b - OldNVCsize - 12) #unsigned 
																  
																 fseek f (4 + OldNVCsize) #seek_cur
																 fseek nvcF (NVCpos - 12) #seek_set
																 format "NVC was detected in DFF\n" 
																)
																
																writeLong nvcF 39056121 #unsigned -- write header NVC
																writeLong nvcF (VCount*4 + 4) #unsigned
																writeShort nvcF DFFunk #unsigned
																writeShort nvcF DFFver #unsigned
																
																writeByte nvcF spn1.value #unsigned -- write unknown color+alpha spn1.value spn2.value spn3.value spn4.value
																writeByte nvcF spn2.value #unsigned
																writeByte nvcF spn3.value #unsigned
																writeByte nvcF spn4.value #unsigned
																
																vcol = #()                              --  set Vcolor data
																for i = 1 to s.numFaces do 
																(
																	q = getVCFace s i
																	--q = polyop.getMapFace s -1 i
																	w = getFace s i
																	for j = 1 to 3 do 
																	 if vcol[w[j]] == undefined do 
																	 (
																		  vcol[w[j]] = GetVertColor s q[j]
																		  --vcol[w[j]] = polyop.GetMapVert s -1 q[j]
																	 )
																) 
																
																for i = 1 to VCount do   -- write Vcolor data
																 if vcol[i] == undefined then 
																 (
																	  vc = getVertColor s i
																	  writebyte nvcF (vc.r as integer)
																	  writebyte nvcF (vc.g as integer)
																	  writebyte nvcF (vc.b as integer)
																	  writebyte nvcF (vc.a as integer)
																 ) 
																 else 
																 (
																	  writebyte nvcF (vcol[i].r as integer)
																	  writebyte nvcF (vcol[i].g as integer)
																	  writebyte nvcF (vcol[i].b as integer)
																	  writebyte nvcF (vcol[i].a as integer)
																 )
																
																fpos = ftell f
																fseek f 0 #seek_end
																fend = ftell f
																fseek f fpos #seek_set
																
																while (ftell f)<fend do (      --  copy  data left
																 b = readByte f #unsigned
																 writeByte nvcF b #unsigned
																)
															
																ProcessDone = true
															
															) else messageBox "#1 not standart DFF" -- CLUMP/GEOMETRYLIST/GEOMETRY/EXTENSION ID != 3
														) else messageBox "#2 not standart DFF" -- CLUMP/GEOMETRYLIST/GEOMETRY/MATLIST ID != 8
													) else messageBox "mesh vertex count != dff vertex count" -- mesh numV != dff numV
												) else messageBox "#3 not standart DFF" -- CLUMP/GEOMETRYLIST/GEOMETRY/struc ID != 1
											) else messageBox "#4 not standart DFF" -- CLUMP/GEOMETRYLIST/GEOMETRY ID != 15
										) else messageBox "geometry count >1 in DFF" -- CLUMP/GEOMETRYLIST/struc data != 1
									) else messageBox "#5 not standart DFF" -- CLUMP/GEOMETRYLIST/struc ID != 1 
								) else messageBox "#6 not standart DFF" -- CLUMP/GEOMETRYLIST ID != 26 
							) else messageBox "#7 not standart DFF" -- CLUMP/FRAMELIST ID != 14
						) else messageBox "object count >1 in DFF" -- CLUMP/struc data != 1
					) else messageBox "#8 not standart DFF" -- CLUMP/struc ID != 1
				) else messageBox "#9 not standart DFF" -- CLUMP ID != 16
				
				--format "\nfile offset = %\n" (ftell f)
				--fseek f 0 #seek_end
				--format "file size = %\n" (ftell f)
				--------------------------------------------------------------------
		
		) -- f = undef
		else (
		 str = "can't open file " + fname
		 messageBox str 
		 format "%\n" str 
		)
		
) -- fname != undefined

Fclose f
Fclose nvcF
delete s

if DelOriginal.checked and ProcessDone then
(
	DeleteFile fname
	RenameFile NVCfname fname
)

--) -- for nobj
) -- selected objects
) -- GoButton


) -- rollount

try (closeRolloutFloater nvc_flo) catch () 
nvc_flo = newRolloutFloater "Night Vertex Color" 110 230 220 100 
addRollout  NVC_rol  nvc_flo
