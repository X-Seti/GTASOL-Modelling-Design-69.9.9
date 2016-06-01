global DataFileName = (scriptsPath + "\\saparticle_data.ini")

------------------------------------------------------------------------------------------------------------- FUNCTIONS
fn GetLightDataCount =
(
	local i = 1, LightPresetName
	while true do
	(
		LightPresetName = getINISetting DataFileName "lightpresets" ("preset" + (i as string) + "_name")
		if LightPresetName == "" then exit
		i+=1
	)
	return (i-1)
)

fn lowercase str = (
	 local i, j, ucase, lcase, result
	 ucase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	 lcase = "abcdefghijklmnopqrstuvwxyz"
	 
	 result = copy str
	 for i = 1 to result.count do
	  (
	   j = findString ucase result[i]
	   if j != undefined  do result[i] = lcase[j]
	  )
	 result
) -- end fn lowercase

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

fn setDFFlist f =
(
    DFFnames = #()
	fseek f 4 #seek_set
	local N = readlong f
	local i
	    for i = 1 to N do
        (
		    ItemOffs = readlong f
			ItemSize = readlong f
			ItemName = readNString f 24
			ItemType = lowercase (getFilenameType ItemName)
			if ItemType == ".dff" then
			(
			  --format "% , ofs = %, size = %\n" ItemName ItemOffs ItemSize
			  append DFFnames (lowercase ItemName)
			  append DFFoffs ItemOffs
			)
		) -- i
local msgStr = "NUM DFFs = " + (DFFnames.count as string)
messageBox msgStr
DFFnames.count
) -- fn

fn setIMGtoDFF f DName =
(
	fseek f 4 #seek_set
	local N = readlong f
	local i, res = 0
	    for i = 1 to N do
        (
		    ItemOffs = readlong f
			ItemSize = readlong f
			ItemName = lowercase (readNString f 24)
			if ItemName ==Dname then
			(
			  res = ItemOffs
			  fseek f (ItemOffs*2048) #seek_set
			  exit
			)
		) -- i
res
) -- fn



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

fn writeHeader f H = 
(
 writeLong f H[1]
 writeLong f H[2]
 writeLong f H[3]
)

fn copyData f1 f2 N = (
local i, b
 for i = 1 to N do (b = readByte f1 ; writeByte f2 b ) 
)


fn findHeaderInSection f3 fo ID Size = (
local HSize = Size, HID, res = #(), H
res[4] = false

while HSize>0 do (
  H = readHeader f3; if fo != undefined then writeHeader fo H
  if H[1] == ID then ( res[4] = true; exit )
  else (
    if fo != undefined then copyData f3 fo H[2] else fseek f3 H[2] #seek_cur
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
			
			H = readHeader f; if fo != undefined then writeHeader fo H
			
            if H[1] == 0x2B do 
			( -- if have anim 0x2B
				if fo != undefined then copyData f fo H[2]
								   else fseek f H[2] #seek_cur
	            H = readHeader f; if fo != undefined then writeHeader fo H
			) -- if have anim 0x2B
			
			if H[1]!=0x10 then 
			(
			        format "++++++++++++++++++++++  DFF have no CLUMP section %\n" (getfilenamefile fname)
					HaveError = true
			)
            else
			(       
			        result[1] = #((ftell f) - 8, H[2]) -- CLUMP
			        H = readHeader f; if fo != undefined then writeHeader fo H
					if fo != undefined then copyData f fo H[2] else fseek f H[2] #seek_cur -- structure
					
					H = readHeader f; if fo != undefined then writeHeader fo H
					if fo != undefined then copyData f fo H[2] else fseek f H[2] #seek_cur -- FLIST
					
					H = readHeader f; if fo != undefined then writeHeader fo H  -- GLIST
					result[2] = #((ftell f) - 8, H[2])
					
					H = readHeader f; if fo != undefined then writeHeader fo H
					if fo != undefined then copyData f fo H[2] else fseek f H[2] #seek_cur -- structure
					
					H = readHeader f; if fo != undefined then writeHeader fo H -- GEOM
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
									result[9] = FH[2] - 4
							) -- have 2fn
                            else
								if fo != undefined then
								(       
								        --format "zzz = %\n" FH
								        result[6] = 16
										writeHeader fo #(0x253F2F8, 4, FH[3])
										result[5] = #((ftell f) + 4, 0)
										--writelong fo 1
										result[8] = 0
										result[9] = 0
								)

					) -- find ETXEN
					
			) -- have CLUMP
result[7] = HaveError
result
) -- fb

-----------------------------------------------------------------------------------------------------------------------------------------------------------

fn write2fxData fo obj =
(
local FXtype = getUserProp obj "FXtype"
local res = 0, LColor , Lparams , i
	case FXtype of
	(
		0:
		(  -- lights
			FXpos = in coordsys parent obj.position
			writefloat fo FXpos.x; writefloat fo FXpos.y; writefloat fo FXpos.z
			writelong fo 0
			writelong fo 80
			LColor = execute (getUserProp obj "LightColor") -- color
			writeByte fo (LColor.red as integer) #unsigned
			writeByte fo (LColor.green as integer) #unsigned
			writeByte fo (LColor.blue as integer) #unsigned
			writeByte fo 200 #unsigned
			writefloat fo (getUserProp obj "LightDist")
			writefloat fo (getUserProp obj "LightOuter")
			writefloat fo (getUserProp obj "LightSize")
			writefloat fo (getUserProp obj "LightInner")
			Lparams = execute (getUserProp obj "LightParams")
			for i = 1 to 5 do writeByte fo Lparams[i] #unsigned
			writeStringZero fo (getUserProp obj "LightEf1") 24
			writeStringZero fo (getUserProp obj "LightEf2") 24
			Lparams = execute (getUserProp obj "LightUnk")
			for i = 1 to 7 do writeByte fo Lparams[i] #unsigned
			res = 100
		)
		
	    1: -- particle
		(
		    FXname = getUserProp obj "FXname"
			FXpos = in coordsys parent obj.position
			writefloat fo FXpos.x; writefloat fo FXpos.y; writefloat fo FXpos.z
			writelong fo 1
			writelong fo 24
			writeStringZero fo FXname 24
			res = 44
		) -- partic
		
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
	    7: -- text
		(
		    local str = #()
			str[1] = getUserProp obj "str1"
			str[2] = getUserProp obj "str2"
			str[3] = getUserProp obj "str3"
			str[4] = getUserProp obj "str4"
			FXpos = obj.position
			D = obj.rotation as eulerAngles
			
			writefloat fo FXpos.x; writefloat fo FXpos.y; writefloat fo FXpos.z
			writelong fo 7; writelong fo 88
			
			writefloat fo obj.width; writefloat fo obj.length
			
			writefloat fo -D.x; writefloat fo D.y; writefloat fo D.z
			writeShort fo 3
			writeStringZero fo SCMscript 12
			writelong fo 0
			res = 76
		)  -- tezx
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
            if getuserprop obj "FXtype" == undefined then (res = false ; format "object % have no 2fx information\n")
res
)

-- #########################################################################################################################################

fn getLightsFromDFF f DFF_NAME =
(
	local P, i, FXpos, FXtype, FXDataSize, NumLights = 0, str = #()
	local FXL_RGB, FXL_DIST, FXL_SIZE, FXL_OUT, FXL_IN
	local FXL_PAR = #(), FXL_UNK = #()
	
	P = setFileTo2fx f undefined
	if (P[7] == true) or (P[5] == undefined) then messageBox "No 2fx found"
	else
	(
		for i = 1 to P[8] do
		(
			FXpos = [readfloat f, readfloat f, readfloat f]
			FXtype = readlong f
			case FXtype of
			( 
			  0: (  NumLights += 1
			     	readlong f  -- size
					FXL_RGB = #(readbyte f #unsigned, readbyte f #unsigned, readbyte f #unsigned) ; readbyte f
					FXL_DIST = readfloat f
					FXL_OUT = readfloat f
					FXL_SIZE = readfloat f
					FXL_IN = readfloat f
					for j = 1 to 5 do FXL_PAR[j] = readbyte f #unsigned
					fseek f 48 #seek_cur
					for j = 1 to 7 do FXL_UNK[j] = readbyte f #unsigned
					
					str[NumLights] = "Inner = " + (FXL_IN as string) + " |  Outer = " + (FXL_OUT as string) + " |  Size = " + (FXL_Size as string) + \
									 " |  Params1 = " + (FXL_PAR as string) + " |  Params2 = " + (FXL_UNK as string)
					format "%\n" str[NumLights]
				 )
			  1: (  fseek f 28 #seek_cur ) -- particle
			  3: (  fseek f 60 #seek_cur ) -- PEDS
			  6: (  fseek f 48 #seek_cur ) -- type 3
			  7: (  fseek f 92 #seek_cur ) -- text
			  8: (  fseek f 8 #seek_cur ) -- type 7 // basket ?
			  9: (  fseek f 16 #seek_cur ) -- type 9
			  10: (  fseek f 44 #seek_cur ) -- type 10
			  default: 
			     (
				     format "########################################################## unknown type % %\n" FXtype (getfilenamefile fname)
					 FXDataSize = readlong f
					 fseek f FXDataSize #seek_cur
				 )
			) -- case

		) -- i
		
		if effect2fx_choice_rol != undefined then
		(
			createdialog effect2fx_choice_rol width:600
			--if NumLights > 8 then effect2fx_choice_rol.list2fx.height = NumLights
							 --else effect2fx_choice_rol.list2fx.height = 8
			effect2fx_choice_rol.LLLL.text = DFF_NAME
			effect2fx_choice_rol.list2fx.items = str
		)
	)
)

-- #########################################################################################################################################




















------------------------------------------------------------------------------------------------------------- ROLLOUT MAIN START
rollout sa_2fx_adder_rol "SA 2FX"
(
button append2fx "APPEND 2FX TO DFF" tooltip:"selected only"
button write2fx "WRITE 2FX TO DFF" tooltip:"selected only"

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
							--format "^%\n" R
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
	else messageBox "Not all selected have 2fx properties"

on write2fx pressed do
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
							--format "^%\n" R
							if not R[7] then
							(
							       DataSize = 0
								   writelong fo selection.count
								   
								   for obj in selection do
	                                          DataSize += write2fxData fo obj
									  
								   fseek f R[9] #seek_cur -- pass old 2fx data
								   --format "R[90] = %\n" R[9]
								   BytesToEnd = (R[1][1] + R[1][2] + 8) - (ftell f)
								   --while (b = readbyte f) != undefined do writebyte fo b
								   for i = 1 to BytesToEnd  do         
	                               ( 
								       b = readbyte f 
									   if b == undefined then (format "UNEXPECTED DFF END\n" ; exit)
									   writebyte fo b
								   )
								   
								   for i = 1 to 4 do
								   (
										   fseek fo R[i][1] #seek_set
										   writelong fo (R[i][2] + R[6] + DataSize - R[9])
								   ) -- i
								   fseek fo R[5][1] #seek_set
								   writelong fo (R[5][2] + R[6] + DataSize - 12 - R[9])
								   
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
	) -- writew
	else messageBox "Not all selected have 2fx properties"

) -- rollout main




------------------------------------------------------------------------------------------------------------- ROLLOUT MAIN END


------------------------------------------------------------------------------------------------------------- ROLLOUT LIGHTS START

rollout sa_lights_rol "lights"
(
button SetLig "Set light data to selection" width:200 height:24
label LLig1 "Distance" across:2 align:#left
spinner LigDist type:#float range:[0, 10000, 200] width:60 align:#right
label LLig2 "Size" across:2 align:#left
spinner LigSize type:#float range:[0, 10000, 2] width:60 align:#right
label LLig3 "Inner Radius" across:2 align:#left
spinner LigInner type:#float range:[0, 10000, 6] width:60 align:#right
label LLig4 "Outer Radius" across:2 align:#left
spinner LigOuter type:#float range:[0, 10000, 12] width:60 align:#right
label LLig5 "Color" across:2 align:#left
colorpicker LigColor color:(color 255 255 255) alpha:false fieldWidth:60 modal:true align:#right
label LLig51 "texture1" across:2 align:#left
dropdownlist LigEf1 Width:160 align:#right
label LLig52 "texture2" across:2 align:#left
dropdownlist LigEf2 Width:160 align:#right
label LigLP "parameters"
spinner LigP1  type:#integer range:[0, 255, 0] width:50 across:4
spinner LigP2  type:#integer range:[0, 255, 1] width:50
spinner LigP3  type:#integer range:[0, 255, 0] width:50
spinner LigP4  type:#integer range:[0, 255, 60] width:50
spinner LigP5  type:#integer range:[0, 255, 64] width:50 across:4
--label LigLP2 "parameters 2"
spinner LigF1  type:#integer range:[0, 255, 0] width:50
spinner LigF2  type:#integer range:[0, 255, 0] width:50
spinner LigF3  type:#integer range:[0, 255, 0] width:50
spinner LigF4  type:#integer range:[0, 255, 0] width:50 across:4
spinner LigF5  type:#integer range:[0, 255, 0] width:50
spinner LigF6  type:#integer range:[0, 255, 0] width:50
spinner LigF7  type:#integer range:[0, 255, 0] width:50
label LLig522 "-----------"
dropdownlist lightpresetsDDL "presets"
button SavePresetBtn "Save preset" across:2 width:70 align:#left
edittext SavePresetName width:130 align:#right
button LigGetFromFile "Get lights data from dff" width:200
button LigGetFromObject "Get lights data from object" width:200

local temp_array = #(), LightsDataCount = 0, i, LightPresetName 

------------------------------ INIT
on sa_lights_rol open do
(
	temp_array = #()
	i = 1
	
	while true do
	(
		LightPresetName = getINISetting DataFileName "lightpresets" ("preset" + (i as string) + "_name")
		if LightPresetName == "" then exit
		i+=1
		append temp_array LightPresetName 
	)
	
	lightpresetsDDL.Items = temp_array

	temp_array = #()
	i = 1
	
	while true do
	(
		LightPresetName = getINISetting DataFileName "texturenames" ("texture" + (i as string))
		if LightPresetName == "" then exit
		i+=1
		append temp_array LightPresetName
	)
	
	LigEf1.Items = temp_array
	LigEf1.Selection = 25
	LigEf2.Items = temp_array
	LigEf2.Selection = 11
)

------------------------------
on LigGetFromFile pressed do
(
	fname = getopenfilename caption:"Select DFF" types:"SA MODEL FILE|*.dff|"
	if fname != undefined then
	(
		f = fopen fname "rb"
		getLightsFromDFF f (FileNameFromPath fname)
		fclose f
	)
)

------------------------------
on LigGetFromObject pressed do
if $!=undefined then 
(
	obj = selection[1]
    u = getUserProp obj "FXtype"
	if u != undefined then
		if u == 0 then
		(
			LigDist.value = getUserProp obj "LightDist"
			LigSize.value = getUserProp obj "LightSize"
			LigInner.value = getUserProp obj "LightInner" 
			LigOuter.value = getUserProp obj "LightOuter" 
			LigColor.color = execute (getUserProp obj "LightColor")
			u = execute (getUserProp obj "LightParams")
			LigP1.value = u[1]
			LigP2.value = u[2]
			LigP3.value = u[3]
			LigP4.value = u[4]
			LigP5.value = u[5]
			u = execute (getUserProp obj "LightUnk")
			LigF1.value = u[1]
			LigF2.value = u[2]
			LigF3.value = u[3]
			LigF4.value = u[4]
			LigF5.value = u[5]
			LigF6.value = u[6]
			LigF7.value = u[7]
		)
)

------------------------------
on lightpresetsDDL selected val do
(
	SavePresetName.text = lightpresetsDDL.selected
	i = getINISetting DataFileName "lightpresets" ("preset" + (val as string) + "_param1")
	if i != "" then LigP1.value = i as integer
	i = getINISetting DataFileName "lightpresets" ("preset" + (val as string) + "_param2")
	if i != "" then LigP2.value = i as integer
	i = getINISetting DataFileName "lightpresets" ("preset" + (val as string) + "_param3")
	if i != "" then LigP3.value = i as integer
	i = getINISetting DataFileName "lightpresets" ("preset" + (val as string) + "_param4")
	if i != "" then LigP4.value = i as integer
	i = getINISetting DataFileName "lightpresets" ("preset" + (val as string) + "_param5")
	if i != "" then LigP5.value = i as integer
	i = getINISetting DataFileName "lightpresets" ("preset" + (val as string) + "_param6")
	if i != "" then LigF1.value = i as integer
	i = getINISetting DataFileName "lightpresets" ("preset" + (val as string) + "_param7")
	if i != "" then LigF2.value = i as integer
	i = getINISetting DataFileName "lightpresets" ("preset" + (val as string) + "_param8")
	if i != "" then LigF3.value = i as integer
	i = getINISetting DataFileName "lightpresets" ("preset" + (val as string) + "_param9")
	if i != "" then LigF4.value = i as integer
	i = getINISetting DataFileName "lightpresets" ("preset" + (val as string) + "_param10")
	if i != "" then LigF5.value = i as integer
	i = getINISetting DataFileName "lightpresets" ("preset" + (val as string) + "_param11")
	if i != "" then LigF6.value = i as integer
	i = getINISetting DataFileName "lightpresets" ("preset" + (val as string) + "_param12")
	if i != "" then LigF7.value = i as integer
)

------------------------------
on SavePresetBtn pressed do
(
	if SavePresetName.text == "" then messageBox "enter name for new preset"
	else
	(
			i = 1
			
			for LightPresetName in lightpresetsDDL.items do
			(
				if SavePresetName.text == LightPresetName then exit
				i+=1
			)
			
			setINISetting DataFileName "lightpresets" ("preset" + (i as string) + "_name") SavePresetName.text
			setINISetting DataFileName "lightpresets" ("preset" + (i as string) + "_param1") (LigP1.value as string)
			setINISetting DataFileName "lightpresets" ("preset" + (i as string) + "_param2") (LigP2.value as string)
			setINISetting DataFileName "lightpresets" ("preset" + (i as string) + "_param3") (LigP3.value as string)
			setINISetting DataFileName "lightpresets" ("preset" + (i as string) + "_param4") (LigP4.value as string)
			setINISetting DataFileName "lightpresets" ("preset" + (i as string) + "_param5") (LigP5.value as string)
			setINISetting DataFileName "lightpresets" ("preset" + (i as string) + "_param6") (LigF1.value as string)
			setINISetting DataFileName "lightpresets" ("preset" + (i as string) + "_param7") (LigF2.value as string)
			setINISetting DataFileName "lightpresets" ("preset" + (i as string) + "_param8") (LigF3.value as string)
			setINISetting DataFileName "lightpresets" ("preset" + (i as string) + "_param9") (LigF4.value as string)
			setINISetting DataFileName "lightpresets" ("preset" + (i as string) + "_param10") (LigF5.value as string)
			setINISetting DataFileName "lightpresets" ("preset" + (i as string) + "_param11") (LigF6.value as string)
			setINISetting DataFileName "lightpresets" ("preset" + (i as string) + "_param12") (LigF7.value as string)
			
			
			if i > lightpresetsDDL.items.count then 
			(
				temp_array = for LightPresetName in lightpresetsDDL.items collect LightPresetName
				append temp_array SavePresetName.text
				lightpresetsDDL.items = temp_array
			)
	)
) 

------------------------------ 
on SetLig pressed do
		for obj in selection do
		(
		    setUserProp obj "FXtype" 0
			setUserProp obj "LightDist" LigDist.value
			setUserProp obj "LightSize" LigSize.value
			setUserProp obj "LightInner" LigInner.value
			setUserProp obj "LightOuter" LigOuter.value
			setUserProp obj "LightColor" LigColor.color
			setUserProp obj "LightEf1" LigEf1.text
			setUserProp obj "LightEf2" LigEf2.text
			setUserProp obj "LightParams" #(LigP1.value,LigP2.value,LigP3.value,LigP4.value,LigP5.value)
			setUserProp obj "LightUnk" #(LigF1.value,LigF2.value,LigF3.value,LigF4.value,LigF5.value,LigF6.value,LigF7.value)
		)

) -- rollout lights



------------------------------------------------------------------------------------------------------------- ROLLOUT LIGHTS END







------------------------------------------------------------------------------------------------------------- ROLLOUT GET EFFECT START

rollout effect2fx_choice_rol "2fx lights"
(
label LLLL ""
listbox list2fx height:12 width:580
button Select2fx "GET"
 
on Select2fx pressed do 
	if sa_lights_rol != undefined and list2fx.items.count > 0 then
	(
		sss = filterstring list2fx.selected "|"
		sa_lights_rol.LigInner.value = execute (sss[1])
		sa_lights_rol.LigOuter.value = execute (sss[2])
		sa_lights_rol.LigSize.value = execute (sss[3])
		P = execute (sss[4])
		sa_lights_rol.LigP1.value = P[1]
		sa_lights_rol.LigP2.value = P[2]
		sa_lights_rol.LigP3.value = P[3]
		sa_lights_rol.LigP4.value = P[4]
		sa_lights_rol.LigP5.value = P[5]
		P = execute (sss[5])
		sa_lights_rol.LigF1.value = P[1]
		sa_lights_rol.LigF2.value = P[2]
		sa_lights_rol.LigF3.value = P[3]
		sa_lights_rol.LigF4.value = P[4]
		sa_lights_rol.LigF5.value = P[5]
		sa_lights_rol.LigF6.value = P[6]
		sa_lights_rol.LigF7.value = P[7]
		
		sa_lights_rol.SavePresetName.text = getFileNameFile (LLLL.text)
	)
)

------------------------------------------------------------------------------------------------------------- ROLLOUT GET EFFECT END








------------------------------------------------------------------------------------------------------------- ROLLOUT PARTICLES START
rollout sa_particles_rol "particles"
(
button SetPar "Set to selection"
--edittext ParticleName "Particle name" text:"fire" LabelOnTop:true
dropdownlist perticlePreset "" --across:2 align:#left width:100
--button SetSAef "SET" align:#right

local temp_array = #(), LightsDataCount = 0, i, ParticleName

------------------------------ INIT
on sa_particles_rol open do
(
	temp_array = #()
	i = 1
	
	while true do
	(
		ParticleName = getINISetting DataFileName "particlesystems" ("psys" + (i as string))
		if ParticleName == "" then exit
		i+=1
		append temp_array ParticleName
	)
	
	perticlePreset.Items = temp_array
)

-------------------------------

on SetPar pressed do
	for obj in selection do
	(
	    setUserProp obj "FXtype" 1
		setUserProp obj "FXname" perticlePreset.selected
	)

) -- roll



------------------------------------------------------------------------------------------------------------- ROLLOUT PARTICLES END






------------------------------------------------------------------------------------------------------------- ROLLOUT PED START

rollout sa_2fxPED_rol "peds"
(
button SetPed "Set to selection"
label L01 "ped type" across:2 align:#left
spinner Ptype type:#integer range:[0, 1000, 6] width:40 align:#right
edittext scmScript "SCM script name" text:"none" LabelOnTop:true
button CreatePedObj "Create PED object"
	
on CreatePedObj pressed do
(
		PBox = box pos:[0,0,0] width:0.4 length:0.15 height:0.4 \
		                       lengthsegs:1 widthsegs:3
		ConvertTo PBox Editable_Poly
		polyop.setFaceSelection PBox #{1,2,3}
		PBox.extrudeFaces 0.2
		polyop.setFaceSelection PBox #{1,3}
		PBox.extrudeFaces 0.74
		polyop.setFaceSelection PBox #{4,5,6}
		PBox.extrudeFaces 0.17
		polyop.setFaceSelection PBox #{34,38}
		PBox.BevelFaces 0.4 -0.03
		polyop.setFaceSelection PBox #{5}
		PBox.extrudeFaces 0.06
		PBox.extrudeFaces 0.2
		polyop.setFaceSelection PBox #{54}
		PBox.extrudeFaces 0.08
		polyop.setFaceSelection PBox #{1,3}
		PBox.extrudeFaces 0.06
		polyop.setFaceSelection PBox #{62,64}
		PBox.extrudeFaces 0.1
		PBOX.name = "2FX_PED"
		select PBOX
)

on SetPed pressed do 
	for obj in selection do 
	(
	    setUserProp obj "FXtype" 3
		setUserProp obj "PEDtype" Ptype.value
		setUserProp obj "SCMscript" scmScript.text
	)

) -- roll


------------------------------------------------------------------------------------------------------------- ROLLOUT PED END
	
-------------------------------------------------------------------------------------------------------------
try (closeRolloutFloater sa_2fx_adder_flo) catch ()
sa_2fx_adder_flo = newRolloutFloater "SA 2FX" 250 560 20 130
addRollout  sa_2fx_adder_rol sa_2fx_adder_flo
addRollout  sa_lights_rol sa_2fx_adder_flo
addRollout  sa_particles_rol sa_2fx_adder_flo rolledUp:true
addRollout  sa_2fxPED_rol sa_2fx_adder_flo rolledUp:true
