fn writeHeader f ID Size = (
  writelong f ID
  writelong f Size
  writelong f 0x1803FFFF
)

------------------------------------------------------------------------------------------------------------------

fn copyHeader f1 f2 = (
local res = #()
res[1] = readLong f1 #unsigned
res[2] = readLong f1 #unsigned
res[3] = readLong f1 #unsigned

writelong f2 res[1]
writelong f2 res[2]
writelong f2 res[3]

res
)

------------------------------------------------------------------------------------------------------------------

fn copyData f1 f2 N = (
local i, b

for i = 1 to N do (
    b = readbyte f1
	writebyte f2 b
)
) -- fn

------------------------------------------------------------------------------------------------------------------

fn copyUntil f1 f2 ID Size = (
local HSize = Size, HID, res = #()
res[4] = false

while HSize>0 do (
  H = copyHeader f1 f2
  if H[1] == ID then ( res[4] = true; exit )
  else (
	copyData f1 f2 H[2]
	HSize -= (H[2]+12)
  )
) -- while

res[1] = H[1]
res[2] = H[2]
res[3] = H[3]

res
) -- end fn

------------------------------------------------------------------------------------------------------------------

fn write_esc_data f EscData = (
local i

writefloat f EscData[1].x
writefloat f EscData[1].y
writefloat f EscData[1].z

writelong f 10
writelong f 40

for i = 2 to 4 do (
  writefloat f EscData[i].x
  writefloat f EscData[i].y
  writefloat f EscData[i].z
)

writelong f EscData[5]

) -- end fn

------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------


fn add_escalator f1 f2 EscData = (
local H, sizePos = #(), size = #()

H = copyHeader f1 f2
if H[1] == 0x2B do ( -- if have anim 0x2B
   copyData f1 f2 H[2]
   H = copyHeader f
) -- if have anim 0x2B

if H[1]!= 0x10 then messageBox "DFF have no CLUMP section"
else (
	sizePos[1] = (ftell f2) - 8
	size[1] = H[2]
	
    H = copyHeader f1 f2 -- CLUMP structure
	copyData f1 f2 H[2]
	
    H = copyHeader f1 f2 -- FRAME LIST
	copyData f1 f2 H[2]

    H = copyHeader f1 f2 -- GEOMETRY LIST
	sizePos[2] = (ftell f2) - 8
	size[2] = H[2]
	
    H = copyHeader f1 f2 -- GEOMETRY LIST structure
	copyData f1 f2 H[2]

    H = copyHeader f1 f2 -- GEOMETRY 1
	if H[1]!=0x0f then messageBox "DFF have no GEOMETRY section"
	else (
	    sizePos[3] = (ftell f2) - 8
		size[3] = H[2]
	    
		H = copyHeader f1 f2 -- GEOMETRY structure
		copyData f1 f2 H[2]
		
		H = copyHeader f1 f2 -- MATERIAL LIST
		copyData f1 f2 H[2]
		
		H = copyHeader f1 f2 -- GEOMETRY EXTENSION
		sizePos[4] = (ftell f2) - 8
		size[4] = H[2]
		
		FH = copyUntil f1 f2 0x253f2f8 H[2]
		if FH[4] then (
		     sizePos[5] = (ftell f2) - 8
			 size[5] = FH[2]
		     ECount = readlong f1 #unsigned
			 writeLong f2 (ECount + 1) #unsigned
			 write_esc_data f2 EscData
			 copyData f1 f2 (FH[2]-4)
			 sizeIncr = 60
		)
		else (		    
		    writeHeader f2 0x253f2f8 64
			sizePos[5] = udefined
			writeLong f2 1
			write_esc_data f2 EscData
			sizeIncr = 76
		)
		
		do (
		  b = readbyte f1
		  if b==undefined then exit
		  writebyte f2 b
		)
		while true
		
		for i = 1 to 5 do if sizePos[i]!=undefined then (
		    fseek f2 sizePos[i] #seek_set
			writelong f2 (size[i]+SizeIncr) #unsigned
		)
	
    ) -- no geometry
) -- no clump

) -- fn add_escl

------------------------------------------------------------------------------------------------------------------

fn canBeEscalator obj = (
local res = false
if SuperclassOf obj != shape then messageBox "selection must be SHAPE"
else
  if numSplines obj != 1 then messageBox "Shape must have only 1 spline and 4 knots"
  else
     if numKnots obj != 4 then messageBox "Shape must have only 4 knots"
	                      else res = true
res
) -- fn

------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------

rollout sa_escl_rol "sa escalator" width:137 height:72
(
	button GO "ADD  ESCALATOR" pos:[10,8] width:116 height:25
	checkbox inv "inverse" pos:[38,42] width:61 height:19
	
on GO pressed do 
if $==undefined then messageBox "select shape"
else (
   obj = selection[1]
   if canBeEscalator obj then (
      escal_data = #()
	  for i = 1 to 4 do 
	      escal_data[i] = getKnotPoint obj 1 i
	  if inv.checked then escal_data[5] = 0
	                 else escal_data[5] = 1
	  
      fname = getOpenFileName caption:"Select DFF to add data" \
	                          types:"SA DFF file|*.dff|"
      if fname!=undefined then (
         f = fopen fname "rb"
         if f==undefined then messagebox "can't open file"
         else (
            ftempname = (getFilenamePath fname) + "\\escalator_" + (filenameFromPath fname)
            ftemp = fopen ftempname "wb"
	        add_escalator f ftemp escal_data
	        fclose f
			--deleteFile fname
	        fclose ftemp
			--renameFile ftempname fname
         ) -- if f
      ) -- if fname
   ) -- can be escl
) -- pressed

) -- rollout

try (closeRolloutFloater sa_escl_flo) catch ()
sa_escl_flo = newRolloutFloater "" 150 100 40 150
addRollout sa_escl_rol sa_escl_flo