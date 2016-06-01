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

	editText Kdir "" pos:[43,84] width:170 height:21 
	button GoButton "GO" pos:[16,20] width:192 height:42 
	label lbl1 "KAM's DFF files path" pos:[66,64] width:109 height:18 
	label lbl3 "Output directory" pos:[80,107] width:94 height:18 
	editText Ddir "" pos:[43,126] width:170 height:21 
	button ChooseBut1 "" pos:[13,82] width:24 height:22 
	button ChooseBut2 "" pos:[15,126] width:24 height:22 
	spinner spnR "r" pos:[22,199] width:40 height:16 range:[0, 255, 180] type:#integer
	spinner spnG "g" pos:[73,199] width:40 height:16 range:[0, 255, 180] type:#integer
	spinner spnB "b" pos:[124,199] width:40 height:16 range:[0, 255, 180] type:#integer
	spinner spnA "a" pos:[175,199] width:40 height:16 range:[0, 255, 255] type:#integer
	button ApplayButton "apply to selection" pos:[14,225] width:193 height:21 
	groupBox grp1 "" pos:[7,4] width:217 height:156 
	groupBox grp3 "" pos:[7,162] width:216 height:97 
	label lbl4 "objects must have unknown color" pos:[30,174] width:166 height:17 
	button CheckBtn "Check" pos:[25,270] width:60 height:32
	button AssocBtn "Associate" pos:[130,270] width:70 height:32

on AssocBtn pressed do 
if selection.count != 1 then messageBox "select just 1 object"
else (
 fname = getOpenFileName caption:"select DFF" filename:(Kdir.text + "\\") \
                         types:"DFF (*.dff)|*.dff|"
 if fname != undefined do setUserProp selection[1] "dff_file" (getFilenameFile fname)						 
)
	
on CheckBtn pressed do (
if Kdir.text==undefined or Ddir.text==undefined then messageBox "set directories"
else
 if selection.count == 0 then messageBox "No object selected"
 else 
  for obj in selection do (
   fname = Kdir.text + "\\" + obj.name + ".dff"
   if not doesFileExist fname do
    if (aname = getUserProp obj "dff_file")!=undefined then (
	fname = Kdir.text + "\\" + aname + ".dff"
	if not doesFileExist fname do (
    str = "file " + obj.name + ".dff  not  exist"
	messageBox str
	)
   ) -- if anime != undef
   else 
    (
     str = "file " + obj.name + ".dff  not  exist"
	 messageBox str	
    )
  )
)

on ChooseBut1 pressed do (
 iDFFdir = GetSavePath initialDir:DFFdir
 if iDFFdir != undefined do (
  Kdir.text = iDFFdir
  DFFdir = iDFFdir
  )
)

on ChooseBut2 pressed do (
 oDFFdir = GetSavePath initialDir:DFFdir
 if oDFFdir!=undefined do (
  Ddir.text = oDFFdir
  DFFdir = oDFFdir
  )
)

on ApplayButton pressed do (
 if selection.count>0 do 
  for obj in $ do (
   setUserProp obj "R" spnR.value
   setUserProp obj "G" spnG.value
   setUserProp obj "B" spnB.value
   setUserProp obj "A" spnA.value
  )   
)

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

on GoButton pressed do (

if selection.count == 0 then messageBox "no objects selected"
else (
clearListener ()

for nobj in selection do (

fname = Kdir.text + "\\" + nobj.name + ".dff" -- "D:\\SA_MOD\\test\\nvc_test1.dff"
if not doesFileExist fname do 
 if (aname = getUserProp nobj "dff_file")!=undefined do fname = fname = Kdir.text + "\\" + aname + ".dff"
if doesFileExist fname then (

format "file: %\n" fname
f = fopen fname "rb"
if f != undefined then (
fseek f 0 #seek_set

s = nobj -- selection[1]
VCount = s.numverts
aname = getFilenameFile fname

SaveDir = Ddir.text -- "D:\\SA_MOD\\test\\nvc\\"
NVCfname = SaveDir + "\\" + aname + ".dff"

if (RR = getUserProp s "R") == undefined or (GG = getUserProp s "G") == undefined or (BB = getUserProp s "B") == undefined or (AA = getUserProp s "A") == undefined then 
 unkn = (color spnR.value spnG.value spnB.value spnA.value)
else 
 unkn = (color RR GG BB AA)

-- if doesFileExist NVCfname do deleteFile NVCfname
nvcF = fopen NVCfname "w+"

--------------------------------------------------------------------------------------------------

H = CopyHeader (VCount*4 + 16) -- CLUMP
FPosSize1 = (ftell nvcF) - 8
DFFunk = H[3]
DFFver = H[4]
if H[1] == 16 then (

ClumpSize = H[2]

H = CopyHeader 0 -- clump/struc
if H[1] == 1 then (
b = readByte f #unsigned
writeByte nvcF b #unsigned
if b == 1 then (
CopyData (H[2]-1)

H = CopyHeader 0 -- CLUMP/FRAMELIST
if H[1] == 14 then (
CopyData H[2] 

H = CopyHeader (VCount*4 + 16) -- CLUMP/GEOMETRYLIST
FPosSize2 = (ftell nvcF) - 8
if H[1] == 26 then (
GeomListSize = H[2]

H = CopyHeader 0 -- CLUMP/GEOMETRYLIST/struc
if H[1] == 1 then (
b = readByte f #unsigned
writeByte nvcF b #unsigned
if b == 1 then (
CopyData (H[2]-1)

H = CopyHeader (VCount*4 + 16) -- CLUMP/GEOMETRYLIST/GEOMETRY
FPosSize3 = (ftell nvcF) - 8
if H[1] == 15 then (
H = CopyHeader 0 -- CLUMP/GEOMETRYLIST/GEOMETRY/struc
if H[1] == 1 then (
flags = readShort f #unsigned -- flags 2

writeShort nvcF flags #unsigned
b = readShort f #unsigned -- unknown 2
writeShort nvcF b #unsigned
FNum = readLong f #unsigned -- faces 4
writeLong nvcF FNum #unsigned
VNum = readLong f #unsigned -- verts 4
writeLong nvcF VNum #unsigned
--format "\n\nFLAG = %\nF = %\nV = %\n" flags FNum VNum

if VNum == VCount then (
b = readShort f #unsigned -- frame count 2
writeShort nvcF b #unsigned
CopyData (H[2] - 14)

H = CopyHeader 0 -- CLUMP/GEOMETRYLIST/GEOMETRY/MATLIST
if H[1] == 8 then (
CopyData H[2]

H = CopyHeader (VCount*4 + 16) -- CLUMP/GEOMETRYLIST/GEOMETRY/EXTEN
FPosSize4 = (ftell nvcF) - 8
if H[1] == 3 then (
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

writeByte nvcF (unkn.r as integer) #unsigned -- write unknown color+alpha
writeByte nvcF (unkn.g as integer) #unsigned
writeByte nvcF (unkn.b as integer) #unsigned
writeByte nvcF (unkn.a as integer) #unsigned

vcol = #()                              --  set Vcolor data
for i = 1 to s.numFaces do (
q = getVCFace s i
w = getFace s i
for j = 1 to 3 do 
 if vcol[w[j]] == undefined do (
  vcol[w[j]] = GetVertColor s q[j]
 )
) 

for i = 1 to VCount do   -- write Vcolor data
 if vcol[i] == undefined then (
  vc = getVertColor s i
  writebyte nvcF (vc.r as integer)
  writebyte nvcF (vc.g as integer)
  writebyte nvcF (vc.b as integer)
  writebyte nvcF (vc.a as integer)
 ) 
 else (
  writebyte nvcF (vcol[i].r as integer)
  writebyte nvcF (vcol[i].g as integer)
  writebyte nvcF (vcol[i].b as integer)
  writebyte nvcF (vcol[i].a as integer)
 )

fpos = ftell f
fseek f 0 #seek_end
fend = ftell f
fseek f fpos #seek_set

while (ftell f)<fend do  (      --  copy  data left
 b = readByte f #unsigned
 writeByte nvcF b #unsigned
)

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

format "\n\nfile offset = %\n" (ftell f)
fseek f 0 #seek_end
format "file size = %\n" (ftell f)
--------------------------------------------------------------------

) -- f = undef
else (
 str = "can't open file " + fname
 messageBox str 
 format "%\n" str 
) 
) -- not exist
else (
 str = "file " + fname + "not exist"
 messageBox str
 format "%\n" str
)

Fclose f
Fclose nvcF

) -- for nobj
) -- selected objects
) -- GoButton


) -- rollount

try (closeRolloutFloater nvc_flo) catch () 
nvc_flo = newRolloutFloater "Night Vertex Color" 250 340 20 130 
addRollout  NVC_rol  nvc_flo
