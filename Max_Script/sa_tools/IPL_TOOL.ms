-- GLOBALS

dfflist = #()
txdlist = #()
ObjName = #()
ObjID = #()
ObjTName = #()


fn no_comments str = (
	 local n
	 local s
	 n = findString str "#"
	 if n != undefined then
	    if n>1 then
		   s = subString str 1 (n-1)
		else s = ""
	 else s = str
	 s = trimLeft (trimRight s)
) -- end no_comments

------------------------------------------------------------------------------------------------------------------
	
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

------------------------------------------------------------------------------------------------------------------

fn readto f1 slist = (
local res = false, str
 while not eof f1 do (
  str = no_comments (readline f1)
  if finditem slist str >0 then (res = true; exit)
 )
res
)

------------------------------------------------------------------------------------------------------------------

fn readAllIDE = (
local count = -1
dfflist = #()
txdlist = #()
ObjName = #()
ObjID = #()
ObjTName = #()

gdir = getsavepath caption:"select gta directory" initialDir:"D:\\GTA_ANDERIUS\\GTA_San_Andreas\\"
if gdir != udefined then (
 gtadatname = getOpenFileName caption:"select gta.dat" types:"gta data|*.dat|text|*.txt|"
 if gtadatname != undefined then (
   fdat = openFile gtadatname
   if fdat == undefined then messagebox "cant open gta.dat"
   else (
      idenum = 0; idename = #()
	  iplnum = 0; iplname = #()
	  while not eof fdat do (
	     s = readline fdat
		 if substring s 1 3 == "IDE" then (
		    idenum+=1
			idename[idenum] = trimleft(trimright(substring s 4 -1))
			--print idename[idenum]
		 )
		 if substring s 1 3 == "IPL" then (
		    iplnum+=1
			iplname[iplnum] = trimleft(trimright(substring s 4 -1))
			--print iplname[iplnum]
		 )		 
	  )
	 ) -- else
     close fdat

-------------------------------------------------------------------------------------------------------------
      
	  HaveError = false
	  count = 0
	  clearListener ()
	  
	  for fname in idename do (
	    f1 = openfile (gdir + "\\" + fname)
		format "------ % \n" fname
		
		do (
		  if readto f1 #("objs","anim","tobj") then (
		     do (
			    if eof f1 then (format "\n\n\n\n\n -------------- end error %\n\n\n\n" fname; exit)
			    s = no_comments (readline f1)
				if s == "end" then exit
				fss = filterString s " , "
				if fss.count > 3 then (
				   count+=1
				   FObjName = lowercase (trimLeft(trimright( fss[2])))
				   FFF = fss[1] as integer
				   if (eee = finditem ObjID FFF) > 0 then (
				       if not HaveError then ( messageBox "FOUND DOUBLE IDE" ; HaveError = true)
				       format "**********************  DOUBLE IDE ERROR : % % - % *********************************** \n" \
					          FFF FObjName ObjName[eee]
					  )
				   if (eee = finditem ObjName FObjName) > 0 then (
				       if not HaveError then ( messageBox "FOUND DOUBLE NAMES" ; HaveError = true)
				       format "************  DOUBLE NAME ERROR : % % - % ********************************************* \n" \
					          FFF FObjName ObjID[eee]
					  )				         
				   ObjID[count] = FFF
				   ObjName[count] = FObjName
				   ObjTName[count] = lowercase (trimLeft(trimright( fss[3])))
				)				
			 ) ---- do
			 while true
		   ) ---- if copyto
		   else exit
		  ) -- do
		while true
		
		close f1
	  ) ---  for fname
  

 ) --- if gta dat		
) --- if gta dir

format "\n\nIDE found = %\n" (count)
count
) -- END FN READ IDE


------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------

-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************


rollout IDE_IPL_rol "IPL EXPORT" width:132 height:170
(
	button IMP_zz "LOAD IDE" across:2 align:#left
	button exp_zz "EXPORT IPL" align:#right
	label lbl1 "lod start" across:2 align:#left
	spinner lodstart "" range:[1,10000,1] type:#integer scale:1 align:#right
	button btn3 "get lod start from file"
	label lbl2 "interior" across:2	 align:#left
	spinner IntNum "" type:#integer	 align:#right
	

	on IMP_zz pressed do
	(
	-- LOAD IDE TO SELECTED OBJECTS
	
	obj = $selection as array
	
	if obj.count > 0 then
	(
	clearListener ()
	
	fname = getOpenFileName caption:"select IDE"  types:"GTA IDE file (*.ide)|*.ide|"
	if fname !=undefined do
	( 
	  ideid = #()
	  idelod = #()
	  idename = #()
	  
	  f = openFile fname
	  er_code = 0
	  
	  do         -- file pos to OBJS
	   if not eof f then (
	     s = readLine f
	     s = no_comments s
	     if (lowercase s == "objs") do exit
	   )
	    else ( er_code = 1 
		       exit )
	  while true
	  
	  --------------------
	  if er_code == 0 then 
	  (
	   n = 0
	
	   do
	    if not eof f then 
		(
		 s = readLine f
		 s = no_comments s
		 if s == "end" then exit
		 if s != "" do
		 (
		  fs = #()
		  fs = filterString s  ","
		  if fs.count >4 then
		   (
		    n += 1
		    ideid[n] = trimLeft(trimRight fs[1])
		    idename[n] = lowercase (trimLeft(trimRight fs[2]))
		    idelod[n] = "0"
		   )
		  else ( er_code = 2
		         exit )
		 )
		)
		else ( er_code = 1 
		       exit )
	   while true
	    
	  )
	  else format "objs not found \n"
	  
	  if er_code == 1  do format "not expected end of file\n"
	  if er_code == 2  do format "wrong data in :%\n" s
	  
	  nobj = 0
	  nlod = 0
	  if er_code == 0 do
	   for i = 1 to obj.count do
	   (
	    oname = lowercase obj[i].name
		if (substring oname 1 3)!= "lod" do
		(
		 k = findItem idename oname
		 if k>0 then 
		 (
		  nobj += 1
		  setuserpropbuffer obj[i] ""
		  setUserProp obj[i] "ID" ideid[k]
		  setUserProp obj[i] "LOD" "0"
		  
		  lodname = replace oname 1 3 "lod"
		  k = findItem idename lodname
		  if k>0 do (setUserProp obj[i] "LOD" ideid[k]
		             nlod +=1 )
		  
		 )
		 else format "%  -- not in thie IDE list\n" obj[i].name
		) -- if oname not LOD
	   ) -- i loop
	  
	  format "\nObj:%\nLod:%\n" nobj nlod
	  
	  close f
	) -- if fname !=undefined
	
	) -- if obj.count>0
	else format "no object selected\n"
	
	) -- on IMP pressed do
	
	
on exp_zz pressed do (
	
	obj = $selection as array
	L = lodstart.value as integer
	
	 if obj.count>0 then  (
	  clearlistener ()
	  for i = 1 to obj.count do 
	  if getuserprop obj[i] "ID" == undefined or getuserprop obj[i] "LOD" == undefined then (
	     ErStr = "User properties not set for " + obj[i].name
	     messageBox Erstr
		 exit
	  )
	  else (
	      r = obj[i].rotation
	      format "%, %, %, %, %, %, %, %, %, %, "  \
		                     (getuserprop obj[i] "ID")  obj[i].name IntNum.value \
							 obj[i].position.x  obj[i].position.y  obj[i].position.z \
							 (-r.x as float) (-r.y as float) (-r.z as float) (r.w as float)
		   if (getuserprop obj[i] "LOD") != 0 then (
		       format "% \n" (L as integer)
			   L+=1
			   format "%, %, %, %, %, %, %, %, %, %, -1\n"  \
		                     (getuserprop obj[i] "LOD") (replace obj[i].name 1 3 "lod") IntNum.value \
							 obj[i].position.x  obj[i].position.y  obj[i].position.z \
							 (-r.x as float) (-r.y as float) (-r.z as float) (r.w as float)
		   )
		                                          else  format "-1\n"
	      L += 1                                               											  
	  )
	  format "\n# ---------------------------------------------------------------- LOD NUM = % \n" L
	 )
	else  format "empty selection\n"
	) -- on EXP pressed do
	
	
on btn3 pressed do (

	fname = getOpenFileName caption:"select IPL"  types:"GTA IPL file (*.ipl)|*.ipl|"
	
	if fname !=undefined do (
	  f = openFile fname
	  er_code = 0
	  
	  do         -- file pos to inst
	   if not eof f then (
	     s = readLine f
	     s = no_comments s
	     if (lowercase s == "inst") do exit
	   )
	    else ( er_code = 1 
		       exit )
	  while true
	  
	  if er_code == 0 then (
	   count = 1
	   
	   do
	    if not eof f then (
	    s = readline f
		s = no_comments s
		if lowercase s == "end" do exit
		fs = filterString s  ","
		if fs.count > 10 do count += 1 
		)
		else ( er_code = 1
		       exit )
	   while true
	   
	   if er_code == 0 then ( format "LOD NUM = %\n" count
	                          lodstart.value = count)
					   else  format "not expected end of file \n"
	   
	   close f
	  )
	  else format "wrong data\n"

	) -- if fname

) -- on getlodnum
	
)
	



-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************


rollout idetool_rol "IDE LOADER"
(
group "" (
button LoadIDE "LOAD ALL IDE"
button LoadIDEtoSel "LOAD TO SELECTION"
button FindLOD "FIND LOD NUMBERS"
--button FLoad "LOAD FROM FILE"
)

group "" (
button FindFreeIDE "FIND FREE IDE"
spinner FindFreeStart "START IDE" type:#integer range:[0, 25000, 1200]
spinner FindFreeEnd "END IDE" type:#integer range:[0, 25000, 19000]
)

on LoadIDE pressed do (
   if readAllIDE () > 0 then LoadIDE.text = "IDE LOADED"
)

on LoadIDEtoSel pressed do (
ferr = false
clearListener ()
for obj in selection do (
    oname = lowercase obj.name
	z = findItem ObjName oname
	if z>0 then (
	   setUserProp obj "ID" ObjID[z]
	   lodname = "lod" + (substring oname 4 -1)
	   z = findItem ObjName lodname
	   if z>0 then setUserProp obj "LOD" ObjID[z]
	   else setUserProp obj "LOD" 0
	)
	else (
	   if not ferr then ( messagebox "Have error" ; ferr = true )
	   format "------------------------------- NOT FOUND IN IDE : %\n" obj.name
	   )
)	
) -- pressed

on FindLOD pressed do (
   fname = getOpenFileName caption:"select IPL"  types:"GTA IPL file (*.ipl)|*.ipl|"
   if fname != undefined then (
      FIPL = openFile fname
	  if FIPL == undefined then messagebox "Can't open IPL file"
	  else (
	     err = false
		 clearListener ()
		 
		 while true do (
		   if eof FIPL then (
		      errs = "INST not found in " + fname
		      messagebox  errs
			  err = true
			  exit
			  )
		   s = no_comments ( readline FIPL )
		   format "%\n" s
		   if s == "inst" then exit
		 ) -- while
		 
		 lodnum = 0
		 
		if not err then while true do (
		   if eof FIPL then (
		      errs = "END not found in " + fname
		      messagebox  errs
			  err = true
			  exit
			  )
           s = readline FIPL
		   ss = lowercase (no_comments s)
		   if ss == "end" then (format "end\n" ; exit)
		   fs = filterstring ss " , "
		   if fs.count>8 then (
		   lodnum += 1
		     if substring fs[2] 1 3 != "lod" then (
				format "%, %, %, %, %, %, %, %, %, %, " fs[1] fs[2] fs[3] fs[4] fs[5] fs[6] \
				                                           fs[7] fs[8] fs[9] fs[10]
				lodname = replace fs[2] 1 3 "lod"
				if (n = findItem ObjName lodname) > 0 then (
				   format "%\n" lodnum
				   format "%, %, %, %, %, %, %, %, %, %, -1\n" ObjID[n] lodname fs[3] fs[4] fs[5] fs[6] \
				                                               fs[7] fs[8] fs[9] fs[10]
				)
				else format "-1\n"
			 )
		   )
		   else format "%\n" s
        ) -- while if not err
		
		if not err then while not eof FIPL do (
		   s = readline FIPL
		   format "%\n" s
		)
		
	  ) -- else cant open
   ) -- fname != unf
) -- pressed

on FindFreeIDE pressed do (
clearlistener ()
--ObjName
--ObjID
--ObjTName
  b = FindFreeStart.value
  a = 0
  while true do (
    if b>FindFreeEnd.value then (
	   if a>0 then format "%...%\n" (b-a) (b-1)
	   exit
	)
	n = findItem ObjID b
	if n>0 then (
	   if a>0 then format "%...%  count = %\n" (b-a) (b-1) a
	   a = 0	   
    )
	else a+=1
	b+=1
  )
   
) -- FindFreeIDE pressed

) -- roll


-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************

rollout dostrib_rol "OBJECT DISTRIBUTION"
(
button go "DO IT" align:#center offset:[0,4] width:80 height:30

label L00 "pick distribution object" offset:[0,4]
pickbutton DOBJ "none" width:120

group "" (
label L01 "X STEP" across: 2 align:#left
spinner SX "" width:50 type:#float range:[0.1, 10000, 10]
label L02 "Y STEP" across: 2 align:#left
spinner SY "" width:50 type:#float range:[0.1, 10000, 10]
label L03 "X NOISE" across: 2 align:#left
spinner NX "" width:50 type:#float range:[0, 10000, 2]
label L04 "Y NOISE" across: 2 align:#left
spinner NY "" width:50 type:#float range:[0, 10000, 2]
label L05 "RANDOM Z ROT" across: 2 align:#left
checkbox ZROT "" checked:true align:#right
label L06 "CHECKER TYPE" across: 2 align:#left
checkbox CTYPE "" checked:true align:#right
)

on DOBJ picked obj do DOBJ.text = obj.name

on DOBJ rightclick do (
   DOBJ.text = "none"
   DOBJ.object = undefined
)

on go pressed do 
if $!=undefined and DOBJ.object!=undefined then (
   omin = DOBJ.object.min
   omax = DOBJ.object.max
   
   for obj in selection do (      
      y = omin.y
	  che = true
	  
	  while y<omax.y do (
	    x = omin.x		
		if CTYPE.checked then (
		   che = not che
		   if che then x -= SX.value/2
		)
	    while x<omax.x do (
		   oray = ray [x,y,10000] [0,0,-1]
		   ir = intersectRay DOBJ.object oray
		   if ir!=undefined then (
			  oray2 = ray [x + (random -NX.value NX.value),y + (random -NY.value NY.value) ,10000] [0,0,-1]
			  ir2 = intersectRay DOBJ.object oray2
			  if ir2!=indefined then ir = ir2
		      newobj = copy obj
			  upb = getUserPropBuffer obj
			  setUserPropBuffer newobj upb
			  newobj.name = obj.name
			  newobj.position = ir.pos
			  newobj.position.z = obj.position.z
			  if ZROT.checked then newobj.rotation.z_rotation = random 0 360
		   )
		   x+=SX.value
		)
	    y+=SY.value
	  )
   ) -- obj loop
) -- on go

) -- roll



-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************

rollout Export_prog "Progress Test"
(
progressbar prog
)

fn intersect p obj = (
local res , pos = p
pos.z = 1000000
local oray = ray pos [0,0,-1]
res = intersectRay obj oray
)

fn IsObjGeometry obj = (superClassOf obj == GeometryClass)

rollout IPL_placer_rol "IPL PLACER"
(
label L1 "disribution object"
pickbutton DOBJ "none" message:"select distribution object" filter:IsObjGeometry \
                tooltip:"select distribution object" autoDisplay:true width:120
label L2 "align normal" across:2 align:#left				
checkbox nora "" align:#right checked:true
label L3 "use bounding box" across:2 align:#left				
checkbox useb "" align:#right checked:true	
radiobuttons minmax labels:#("max", "min")	
label L4 "offset" across:2 align:#left
spinner zoff "" width:60 align:#right range:[-100000, 100000, 0]		
button GO "GO" width:60

on DOBJ rightclick do (
  DOBJ.text = "none"
  DOBJ.object = undefined
) -- rclick

on GO pressed do
if $ == undefined then messagebox "nothing selected"
else
   if DOBJ.object == undefined then messagebox "select distribution object"
   else
   (   ppp = #()
       o = DOBJ.object
	   prog_count = 0
	   total_count = selection.count
	   createDialog Export_prog 220 60
	   Export_prog.prog.value = 0
       if not useb.checked then 
        for obj in selection do (
		    Export_prog.prog.value = prog_count*100/total_count
			prog_count += 1
		    ir = intersect obj.position o
			if ir != undefined then (
		       if nora.checked then mat = matrixFromNormal ir.dir
		       else mat = matrix3 1
		       obj.transform *= mat
		       obj.position = ir.pos + ir.dir*zoff.value			   
			)
			else format "object % have no intersection\n" obj.name
	    ) -- not useb
		else (
		   for obj in selection do (
		       Export_prog.prog.value = prog_count*100/total_count
			   prog_count += 1
		       ppp[1] = obj.min
			   ppp[2] = obj.max
			   ppp[3] = [obj.min.x, obj.max.y, 0]
			   ppp[4] = [obj.max.x, obj.min.y, 0]
			   if minmax.state == 1 then zmax = -1000000
			   else zmax = 1000000
			   ir = undefined
			   for i = 1 to 4 do (
			      fir = intersect ppp[i] o
				  if fir != undefined then
				    if minmax.state == 1 then
				       if fir.pos.z > zmax do zmax = fir.pos.z
					else 
					   if fir.pos.z < zmax do zmax = fir.pos.z
			   ) -- i loop
			   ir = intersect obj.position o
			   if ir != undefined then (
			      ir.pos.z = zmax
		          if nora.checked then mat = matrixFromNormal ir.dir
		          else mat = matrix3 1
		          obj.transform *= mat
		          obj.position = ir.pos + ir.dir*zoff.value			   
			   )
			   else format "object % have no intersection\n" obj.name

		   ) -- obj
		) -- else not useb
   DestroyDialog Export_prog
   ) -- GO
		
) -- roll


-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************
-- ***************************************************************************************************************


try (closeRolloutFloater dostrib_flo) catch ()
dostrib_flo = NewRolloutFloater "SA IPL TOOLS" 190 420 50 150
addRollout  idetool_rol dostrib_flo
addRollout IDE_IPL_rol  dostrib_flo
addRollout dostrib_rol  dostrib_flo rolledUp:true
addRollout IPL_placer_rol  dostrib_flo rolledUp:true