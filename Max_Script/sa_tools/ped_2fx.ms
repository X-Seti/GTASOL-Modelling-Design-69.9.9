fn showFlags N = (
local fs = #("TRISTRIP","POSITIONS","TEXTURED1","PRELIT","NORMALS","LIGHT","MODULATE","TEXTURED2")
local i, res = ""

for i = 1 to 8 do 
 if bit.and N (2^(i-1)) > 0 do res += fs[i] + ", "
 
res
)

fn writeStringZero f str N = (
local i, len

writeString f str
len = str.count
if len<N do 
 for i = 1 to (N-len-1) do writeByte f 0x0 #unsigned
N - len 
)

fn readBString f n = (
local i, res = ""
for i = 1 to n do res += bit.intAsChar (readbyte f #unsigned)
res
)

fn readNString f n = (
local i, res = "", b
	for i = 1 to n do 
	(   
	    b = readbyte f #unsigned
		if b == undefined then exit
		if b == 0 then (fseek f (n-i) #seek_cur; exit)
		res += bit.intAsChar b
	)
res
)


fn readHeader ff = (
local res = #()
res[1] = readLong ff #unsigned
res[2] = readLong ff #unsigned
res[3] = readLong ff #unsigned

res
)

fn writeHeader f H = (
 writeLong f H[1]
 writeLong f H[2]
 writeLong f H[3]
)

fn copyData f1 f2 N = (
local i, b
 for i = 1 to N do (b = readByte f1 ; writeByte f2 b ) 
)



fn findHeaderInSection f3 fo ID Size = (
local HSize = Size, HID, res = #()
res[4] = false

while HSize>0 do (
  H = readHeader f3; writeHeader fo H
  if H[1] == ID then ( res[4] = true; exit )
  else (
    copyData f3 fo H[2]
	HSize -= (H[2]+12)
  )
) -- while

res[1] = H[1]
res[2] = H[2]
res[3] = H[3]

res
) -- end fn




-- #########################################################################################################################################

fn setFileTo2fx f fo =
(
local i, h, fh, result = #()
local HaveError = false
			
			H = readHeader f; writeHeader fo H
			
            if H[1] == 0x2B do ( -- if have anim 0x2B
            --fseek f H[2] #seek_cur
			copyData f fo H[2]
            H = readHeader f; writeHeader fo H
			) -- if have anim 0x2B
			
			if H[1]!=0x10 then 
			(
			        format "++++++++++++++++++++++  DFF have no CLUMP section %\n" (getfilenamefile fname)
					HaveError = true
			)
            else
			(       
			        result[1] = #((ftell f) - 8, H[2]) -- CLUMP
			        H = readHeader f; writeHeader fo H;  copyData f fo H[2] -- stru
					H = readHeader f; writeHeader fo H;  copyData f fo H[2] -- FLIST
					H = readHeader f; writeHeader fo H  -- GLIST
					result[2] = #((ftell f) - 8, H[2])
					H = readHeader f; writeHeader fo H;  copyData f fo H[2] -- stru
					H = readHeader f; writeHeader fo H -- GEOM
					result[3] = #((ftell f) - 8, H[2])
					
					FH = findHeaderInSection f fo 0x03 H[2]
					if FH[4] then
					(       result[4] = #((ftell f) - 8, FH[2])
							FH = findHeaderInSection f fo 0x253F2F8 FH[2]
							if FH[4] then
							(       result[5] = #((ftell f) - 8, FH[2] + 12)
							        result[6] = 0
									FXcount = readlong f
									--writelong fo (FXcount+1)
									result[8] = FXcount
							) -- have 2fn
                            else
							(       
							        --format "zzz = %\n" FH
							        result[6] = 16
									writeHeader fo #(0x253F2F8, 4, FH[3])
									result[5] = #((ftell f) + 4, 0)
									--writelong fo 1
									result[8] = 0
							)
					) -- find ETXEN
					
			) -- have CLUMP
result[7] = HaveError
result
) -- fb

fn write2fxData fo obj =
(
local FXtype = getUserProp obj "FXtype"
local res = 0
	case FXtype of
	(
	    3: -- peds
		(
			PEDtype = getUserProp obj "PEDtype"
			FXpos = in coordsys parent obj.position
			D = ((in coordsys parent obj.rotation) as matrix3)[2]
			SCMscript = getUserProp obj "SCMscript"
			writefloat fo FXpos.x; writefloat fo FXpos.y; writefloat fo FXpos.z
			writelong fo 3; writelong fo 56
			writelong fo PEDtype
			writefloat fo -D.x; writefloat fo D.y; writefloat fo D.z
			writefloat fo -D.x; writefloat fo D.y; writefloat fo D.z
			writefloat fo D.x; writefloat fo -D.y; writefloat fo -D.z
			writeStringZero fo SCMscript 12
			writelong fo 0
			res = 76
		)  -- peds
		default: ()
	) -- case FX
res
) -- fn


fn checkObj =
(
local res = true, obj
	if $ == undefined then res == false
	else
		for obj in selection do 
            if getuserprop obj "FXtype" == undefined then (res = false ; exit)
res
)

-- #########################################################################################################################################
-- #########################################################################################################################################
-- #########################################################################################################################################


rollout dff_ped_adder_rol "DFF 2FX"
(
button append2fx "APPEND" tooltip:"selected only"

group "PEDS"
(
button SetPed "Set to selection"
label L01 "ped type" across:2 align:#left
spinner Ptype type:#integer range:[0, 1000, 6] width:40 align:#right
edittext scmScript "SCM script name" text:"none" LabelOnTop:true
)

on SetPed pressed do if $!= undefined then
for obj in selection do 
(
    setUserProp obj "FXtype" 3
	setUserProp obj "PEDtype" Ptype.value
	setUserProp obj "SCMscript" scmScript.text
)

on append2fx pressed do
if checkObj () then
(
	fname = getopenfilename caption:"Select DFF" types:"SA MODEL FILE|*.dff|"
	if fname != undefined then
	(
			f = fopen fname "rb"
			if f == undefined then messagebox "cant open file"
			else
			(
				fnameOut = (getfilenamepath fname) + "\\temp2fx_" + (filenamefrompath fname)
				fo = fopen fnameOut "wb"
				if fo == undefined then messagebox "cant write file"
				else
				(
						R = setFileTo2fx f fo
						if not R[7] then
						(
						       DataSize = 0
							   writelong fo (R[8] + selection.count)
							   
							   for obj in selection do 
                                          DataSize += write2fxData fo obj
								  
							   
							   while (b = readbyte f) != undefined do writebyte fo b
							   
							   for i = 1 to 4 do
							   (
									   fseek fo R[i][1] #seek_set
									   writelong fo (R[i][2] + R[6] + DataSize)
							   ) -- i
							   fseek fo R[5][1] #seek_set
							   writelong fo (R[5][2] + R[6] + DataSize - 12)
							   
							   fclose fo
							   fclose f
							   deletefile fname
							   renameFile fnameOut fname
						)
						fclose fo
				) -- fo
			fclose f
			) -- f
	) -- fname
) -- append

) -- roll

try (closeRolloutFloater dff_ped_adder_flo) catch ()
dff_ped_adder_flo   = newRolloutFloater "PED DFF 2DFX" 160 200 20 130
addRollout  dff_ped_adder_rol dff_ped_adder_flo