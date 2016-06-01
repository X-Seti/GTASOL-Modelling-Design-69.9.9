fn showFlags N = (
local fs = #("TRISTRIP","POSITIONS","TEXTURED1","PRELIT","NORMALS","LIGHT","MODULATE","TEXTURED2")
local i, res = ""

for i = 1 to 8 do 
 if bit.and N (2^(i-1)) > 0 do res += fs[i] + ", "
 
res
)


fn readBString f n = (
local i, res = ""
for i = 1 to n do res += bit.intAsChar (readbyte f #unsigned)
res
)


fn readHeader ff = (
local res = #()
res[1] = readLong ff #unsigned
res[2] = readLong ff #unsigned
res[3] = readLong ff #unsigned

res
)



fn findHeaderInSection f3 ID Size = (
local HSize = Size, HID, res = #()
res[4] = false

while HSize>0 do (
  H = readHeader f3
  if H[1] == ID then ( res[4] = true; exit )
  else (
    fseek f3 H[2] #seek_cur
	HSize -= (H[2]+12)
  )
) -- while

res[1] = H[1]
res[2] = H[2]
res[3] = H[3]

res
) -- end fn




fn importDFF DFFfile  = (
local i, j, k, H, UVnum = #(), GEOMunk1, resultat
local meshverts = #(), meshfaces = #(), vcolors = #(), nvc = #(), UVcoords = #(), FaceMatID = #(), norms = #()
local InitMat = #(), PFrame = #(), FrameNames = #(), Flags = #(), DFFmesh = #()
local GEOMunk3, GEOMunk4, FaceCount, VertCount, BSphere = #(), FaceMatID = #()
local FLunknown = #()
local ObjectsCount, FrameCount, haveUVanim = false
local f = DFFfile

-- begin
fseek f 0 #seek_set

H = readHeader f
if H[1] == 0x2B do ( -- if have anim 0x2B
 haveUVanim = true
 fseek f H[2] #seek_cur
 H = readHeader f
) -- if have anim 0x2B


if H[1]!=0x10 then messageBox "DFF have no CLUMP section"
else (
 H = readHeader f -- CLUMP/structure
 
 ObjectsCount = readlong f #unsigned
 CLunk1 = readlong f #unsigned
 CLunk2 = readlong f #unsigned
 
 H = readHeader  f ---------------------------------------------------------------- FRAME LIST
 if H[1] != 0x0E then messageBox "DFF have no FRAME LIST section"
 else (
  H = readHeader f -- structure
  FrameCount = readlong f #unsigned
  FrameStat = #()
  FrameObj = #()
  
  for k = 1 to FrameCount do (
  FrameStat[k] = 0
  InitMat[k] = (matrix3 [(readfloat f),(readfloat f),(readfloat f)] \
                        [(readfloat f),(readfloat f),(readfloat f)] \
						[(readfloat f),(readfloat f),(readfloat f)] \
						[(readfloat f),(readfloat f),(readfloat f)] )
  PFrame[k] = readlong f #signed
  FLunknown[k] = readlong f #unsigned -- if node is head hierarhy -> 0300 0200 else 0000 0000
  ) -- k loop
  
 for k = 1 to FrameCount do (
   H = readHeader f
   if H[1] != 0x03 do break ()
   if H[2] == 0 then FrameNames[k] = "Dummy" + k as string
   else (
    FH = findHeaderInSection f 0x253F2FE H[2] 
	if FH[4] then FrameNames[k] = readBString f FH[2]
	         else break ()
   )
 ) -- for k = 1 to FrameCount
 
 
 
 H = readHeader f ---------------------------------------------------------- GEOMETRY LIST
 if H[1] != 0x1A then messageBox "can't find GEOMETRY LIST section"
 else (
  H = readHeader f -- GList/structure
  GeometryCount = readlong f #unsigned
  --format "Gcount = %\n" GeometryCount
  
  
  for k = 1 to GeometryCount do (
   H = readHeader f ----------------- GEOMETRY
   if H[1]!=0x0F do break ()
   
   H = readHeader f ----------------- GEOMETRY/structure  
   Flags[k] = readshort f #unsigned
   
   UVnum[k] = readshort f #unsigned
   FaceCount = readlong f #unsigned
   VertCount = readlong f #unsigned
   GEOMunk1 = readlong f #unsigned
   
   if bit.and Flags[k] 8 > 0 do ( -- VERTEX COLORS
   vcolors = #()
   valphas = #()
   for i = 1 to VertCount do (
	 vcolors[i] = (color (readbyte f #unsigned) (readbyte f #unsigned) (readbyte f #unsigned))
	 valphas[i] = (readbyte f #unsigned)
	)
   ) -- if have prelit flag
   
   
   for i = 1 to UVnum[k] do (
    UVcoords[i] = #()
    for j = 1 to VertCount do
      UVcoords[i][j] = [(readfloat f) , -(readfloat f) , 0]
   )
   
	 
   MeshFaces = #()
   FaceMatID = #()
   for i = 1 to FaceCount do (
    for j = 1 to 4 do H[j] = readshort f #unsigned
     MeshFaces[i] = [H[2]+1, H[1]+1, H[4]+1]
	 FaceMatID[i] = H[3]+1
   ) -- i
   
   BSphere[k] = #((readfloat f), (readfloat f), (readfloat f), (readfloat f))
   --sphere xray:true \
   --       pos:[BSphere[k][1],BSphere[k][2],BSphere[k][3]] \
	--	  radius:BSphere[k][4] segs:64
   
   GEOMunk3 = readlong f #unsigned
   GEOMunk4 = readlong f #unsigned
   
   meshverts = #()
   for i = 1 to VertCount do
     meshverts[i] = [ (readfloat f) , (readfloat f) , (readfloat f) ]
   
   if bit.and Flags[k] 16 > 0 do ( -- if have NORMALS flag
   norms = #()
   for i = 1 to VertCount do
     norms[i] = [ (readfloat f) , (readfloat f) , (readfloat f) ]   
   ) -- if have NORMALS flag
   
   H = readHeader f  -------------------------------------------------------------  MATERIAL LIST
   MListEndPos = ftell f + H[2]
   
   H = readHeader f -- ML structure
   MatCount = readlong f #unsigned
   for i = 1 to MatCount do readlong f #unsigned -- unknown -1
   
   Mat = #()
   for i = 1 to MatCount do (
    H = readHeader f -- material i
	--format "mat head = %\n" H
	H = readHeader f -- material i/structure
	--format "mat head stru = %\n" H
	Mat[i] = standard ()
	
	MatUnk1 = readlong f #unsigned
	Mat[i].diffuse = (color (readbyte f #unsigned) (readbyte f #unsigned) (readbyte f #unsigned))
	Mat[i].opacity = ((readbyte f #unsigned) as float) / 2.55
	MatUnk2 = readlong f #unsigned
	TexCount = readlong f #unsigned
	
	Mat[i].diffuseMapAmount = (readFloat f) * 100
	Mat[i].specularMapAmount = (readFloat f) * 100
	Mat[i].ambientMapAmount = (readFloat f) * 100
	
	for j = 1 to TexCount do (
	 H = readHeader f -- texture
	 --format "texture = %\n" H
	 H = readHeader f -- texture/structure
	 fseek f 4 #seek_cur
	 H = readHeader f -- texture name
	 TexName = (readstring f)
	 fseek f (H[2] - TexName.count - 1) #seek_cur
	 --format "texture name = %\n" TexName
	 Mat[i].diffusemap = bitmaptexture filename:(TexName + ".tga")
	 
	 H=readheader f -- alphatexture
	 --format "texture A = %\n" H
	 TexNameA = (readstring f)
	 if TexNameA != undefined and TexNameA!="" then (
	   Mat[i].opacitymap = bitmaptexture filename:(TexName + ".tga")
	   fseek f (H[2] - TexNameA.count - 1) #seek_cur
	   )
	  else fseek f (H[2] - 1) #seek_cur
	 
	 H = readHeader f -- extension texture
	 --format "exten1 = %\n" H
	 fseek f H[2] #seek_cur
	 
	) --- for j
	
	H = readHeader f -- extension material
	--format "exten2 = %\n" H
	fseek f H[2] #seek_cur
	
   ) -- for i = 1 to MatCount
   
   
   if MatCount== 1 then NewMat = Mat[1]
   else (
    NewMat = multimaterial  numsubs:MatCount
	for j = 1 to MatCount do ( 
	  NewMat[j] = Mat[j]
	  ShowTextureMap NewMat[j] true
	  )
   ) 
    
   
   H = readHeader f  -------------------------------------------------------------  GEOM EXTENSION
   nextPos = H[2] + (ftell f)
   
   FH = findHeaderInSection f 0x253F2F9 H[2]
   if FH[4] do (
    --format "unknown % % % %\n" (readbyte f #unsigned) (readbyte f #unsigned) \
	--                           (readbyte f #unsigned) (readbyte f #unsigned)
	fseek f 4 #seek_cur
    for i = 1 to VertCount do (
	 nvc[i] = [((readbyte f #unsigned) as float)/255, \ 
	           ((readbyte f #unsigned) as float)/255, \
			   ((readbyte f #unsigned) as float)/255]
	 b = readbyte f
    )						  
   )
   
   fseek f nextPos #seek_set -- pass data



   DFFmesh[k] = mesh vertices:meshverts  faces:meshfaces materialIDs:FaceMatID
   DFFmesh[k].material = NewMat
   
   if UVnum[k]>0 do (            ----------------- set uv
    meshop.setMapSupport DFFmesh[k] 1 true
    DFFmesh[k].numTverts = VertCount
	for i = 1 to VertCount do 
	 meshop.setMapVert DFFmesh[k] 1 i UVcoords[1][i]
	buildTVFaces DFFmesh[k]
	
	for i = 1 to FaceCount do
	 meshOp.setMapFace DFFmesh[k] 1 i [meshfaces[i][1], meshfaces[i][2], meshfaces[i][3]]
   ) -- UV
   
   if bit.and Flags[k] 8 > 0 do ( --- if have Vcolors
	defaultVCFaces DFFmesh[k]
	for i = 1 to VertCount do 
	 setVertColor DFFmesh[k] i vcolors[i]
   ) -- vcolor

   if FH[4] do ( --- NVC
	meshop.defaultMapFaces DFFmesh[k] -1
	for i = 1 to VertCount do
	 meshop.setMapVert DFFmesh[k] -1 i nvc[i]
   ) -- NVC   
   
   --format "type = %   Flags = %\n" UVnum[k] (showFlags Flags[k])
   --format "type = %\n" vcolors
  
  ) -- for k = 1 to GeometryCount
  
  
  
  for k = 1 to GeometryCount do ( 
  H = readheader f ------------------------------------------------------- ATOMIC
  --format "Atomic% = %\n" k H
  if H[1] != 0x14 do break ()
  AtomicSize = H[2]
  H = readheader f -- structure
  FrameIndex = (readlong f #unsigned) + 1
  GeometryIndex = (readlong f #unsigned) + 1
  ATOMunk1 = readlong f #unsigned
  ATOMunk2 = readlong f #unsigned
  
  DFFmesh[GeometryIndex].name = FrameNames[FrameIndex]
  FrameObj[FrameIndex] = DFFmesh[GeometryIndex]
  FrameStat[FrameIndex] = 1
  fseek f (AtomicSize-28) #seek_cur
  ) -- for i in ATOMIC
  
  
 for k = 1 to FrameCount do -- replace not used to DUMMY
  if FrameStat[k] == 0 then FrameObj[k] = dummy boxsize:[0.2, 0.2, 0.2] name:FrameNames[k]
  
 for k = 1 to FrameCount do ( -- hierarhy and placement
  if PFrame[k]>-1 then FrameObj[k].parent = FrameObj[PFrame[k]+1]
                  else resultat = FrameObj[k]
  in coordsys parent (FrameObj[k].rotation = InitMat[k]
                      FrameObj[k].position = InitMat[k][4] )
 ) 
  
  
  
 ) -- have GEOMETRY LIST section 0x1A
 ) -- have FRAME LIST section 0x0E
) -- have CLUMP section 0x10


--format "heave anim : %\n" HaveUVanim
--format "Frames : %\n" FrameNames

resultat
) -- end importDFF