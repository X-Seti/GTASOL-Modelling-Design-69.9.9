fn DelComments s cs =
(
local ss = trimLeft s
local p = FindString ss cs
if p == undefined then return ss
else
if p > 1 then
 return substring ss 1 (p-1)
else return ""
)
					 
---------------------------------------------------//
rollout MCamera "Camera Position Export"
(
	button LCamer "Load from File" width:89 height:24 tooltip:"Load from .dat File"
	button CCamer "Create Cmera" width:89 height:24 offset:[-1,5] tooltip:"Create Cmera"
	group "Create .dat"(
	button SCamer "Create File" width:69 height:24 offset:[-1,5]tooltip:"Create .dat File"
	)
	
on CCamer pressed do (
  Cam = targetCamera target:(targetObject ())
    Cam.target.position = [-0.324,0.0,0.0]
  select Cam
) --SCamer pressed
	
on SCamer pressed do (
local cam = undefined
    for obj in selection do(
		if ((classOf obj) == Targetcamera)then 
		(
	 	  if obj != undefined then cam = obj	
		) 
	)	
	clearSelection()
   if cam != undefined then Select cam	
     else messageBox "Camera is not selected"
 if selection.count > 0 then ( 
	if cam != undefined then (
    	index = numKeys cam.pos.controller
		index1 = numKeys cam.target.position.controller
        if (index > 0) and (index1 > 0) then 
        (  

        fname = getSaveFileName\ 
			types:"Text file (*.dat)|*.dat" --|All files (*.*)|*.*"  
      if fname != undefined then ( 			
         f = createfile fname
		  --------------------------------------------- BLOCK 1 
          format "%,\n" index to: f
          for i=1 to index do --at time frame
          (
             pos1 = getKeyTime cam.pos.controller i
             str1= (pos1.frame as float)/frameRate
             tm=cam.pos.controller.keys[i].time
             fov1 = at time tm cam.targetDistance
             if (fov1 > 99.0) then fov1 = "98.482513"
			 if 60.0 > fov1 then fov1 = fov1 + 20.0
             format "%f,%,%,%,\n" str1 fov1 fov1 fov1 to: f 
		  ) 
           format ";\n" to: f
		  --------------------------------------------- BLOCK 2	 	
           format "%,\n" index to: f 
           for i=1 to index do at time i
             (
              pos1 = getKeyTime cam.pos.controller i
              str1= (pos1.frame as float)/frameRate
              format "%f,0.000000,0.000000,0.000000,\n" str1 to: f
             )
		   format ";\n" to: f
		  --------------------------------------------- BLOCK 3		 	   
          format "%,\n" index to: f
           for i=1 to index do at time i
               (
                pos1 = getKeyTime cam.pos.controller i
                str1= (pos1.frame as float)/frameRate
                tm=cam.pos.controller.keys[i].time
                str2= at time tm cam.position.controller.x_position 
                str3= at time tm cam.position.controller.y_position
                str4= at time tm cam.position.controller.z_position
                format "%f,%,%,%,%,%,%,%,%,%,\n" str1 str2 str3 str4 str2 str3 str4 str2 str3 str4 to: f
               )
               format ";\n" to: f
		  --------------------------------------------- BLOCK 4		 	 
             index1 = numKeys cam.target.position.controller
             format "%,\n" index1 to: f
             for i=1 to index1 do at time i
              (
               pos1 = getKeyTime cam.target.position.controller i
               tm=cam.target.position.controller.keys[i].time
               str1= (pos1.frame as float)/frameRate
               str2=at time tm cam.target.position.controller.x_position--value 
               str3=at time tm cam.target.position.controller.y_position
               str4=at time tm cam.target.position.controller.z_position
               format "%f,%,%,%,%,%,%,%,%,%,\n" str1 str2 str3 str4 str2 str3 str4 str2 str3 str4 to: f
              )
              format ";\n;\n" to: f
            close f
            if fname != undefined do (
               f = fopen fname "ab"
               if f == undefined then messageBox "export error"
                  else (
                     fseek f 0 #seek_end
                     size = ftell f
                     fseek f size #seek_set
                     nill = (2048 - (mod size 2048)) as integer
                     for i = 1 to nill do writebyte f 0
                    fclose f
               ) -- if f
             )--fname !
            gc() 
		 ) -- fname != undefined
       )-- index > 0
	  else messageBox "No key frames"
  	) --cam != undefined
  ) --selection.count > 0 
) --end SCamer pressed

on LCamer pressed do (
	DZ = 0.0 ---1.0
fname = GetOpenFileName types:"gta cutscene data|*.dat|"
if fname!=undefined then
(
f = openFile fname
if f!=undefined then
(
  Cam = targetCamera target:(targetObject ())
  select Cam
  --------------------------------------------- BLOCK 1
  while not eof f do
  (
   s = DelComments (readline f) ";"
   if s!="" then exit
  )
 
  fs = filterString s " , "
  N = fs[1] as integer
 
  while not eof f do
  (
   s = DelComments (readline f) ";"
   if s!="" then
   (
    N -= 1
   )
   if N == 0 then exit
  )
 
  --------------------------------------------- BLOCK 2
  while not eof f do
  (
   s = DelComments (readline f) ";"
   if s!="" then exit
  )
 
  fs = filterString s " , "
  N = fs[1] as integer

  while not eof f do
  (
   s = DelComments (readline f) ";"
   if s!="" then
   (
    N -= 1
   )
   if N == 0 then exit
  )
 
  --------------------------------------------- BLOCK 3
  while not eof f do
  (
   s = DelComments (readline f) ";"
   if s!="" then exit
  )
 
  fs = filterString s " , "
  N = fs[1] as integer
 
  --format "Block 3 = %\n" N

  while not eof f do
  (
   s = DelComments (readline f) ";"
   if s!="" then
   (
    fs = filterString s " , "
    t = execute fs[1]
    t *= 30.0

    animate on
     at time t Cam.position.controller.value = [(fs[2] as float), (fs[3] as float), (fs[4] as float) + DZ]
    --format "-- % , %\n" t [(fs[2] as float), (fs[3] as float), (fs[4] as float)]
    N -= 1
   )
   if N == 0 then exit
  )

  --------------------------------------------- BLOCK 4
  while not eof f do
  (
   s = DelComments (readline f) ";"
   if s!="" then exit
  )
 
  fs = filterString s " , "
  N = fs[1] as integer
  while not eof f do
  (
   s = DelComments (readline f) ";"
   if s!="" then
   (
    fs = filterString s " , "
    t = execute fs[1]
	t *= 30.0
	animate on
     at time t Cam.target.position.controller.value = [(fs[2] as float), (fs[3] as float), (fs[4] as float) + DZ]
 animationRange = interval 0 (t + 1)
   N -= 1
   )
   if N == 0 then exit
  )
)
else messageBox "Cant open file"
close f
)
)--end LCamer pressed
 
)--end rollout
DAT_Camera = newRolloutFloater "Camera Export" 182 160 10 30
addRollout MCamera DAT_Camera