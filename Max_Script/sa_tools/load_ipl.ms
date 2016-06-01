fileIn (scriptspath + "\\sa_tools\\importDFF2.ms") quiet:true

	fn no_comments str = 
	(
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
	
	fn lowercase str = 
	(
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
	
rollout loadipl_rol "load ipl" width:146 height:85
(
	button impdff "IMPORT DFF" pos:[7,8] width:121 height:26
	button loadmap "LOAD MAP" pos:[8,42] width:121 height:26
	
on loadmap pressed do (
dirrr = getSavePath caption:"select dff files dir"
fname = getOpenFileName caption:"select IPL"  types:"GTA IPL file (*.ipl)|*.ipl|"
if fname != undefined do (
f = openFile fname
 er_code = 0
	  do         --  file  pos to inst
	   if not eof f then (
	     s = readLine f
	     s = no_comments s
	     if (lowercase s == "inst") do exit
	   )
	    else ( er_code = 1 
		       exit )
	  while true

if er_code == 0 then (
 count = 0
 obj_names = #()
 do
  if not eof f then (
   s = readLine f
   s = no_comments s
   if lowercase s == "end" do exit
   fs = filterString s ","
   if fs.count>10 do (
	objname = trimLeft(trimRight fs[2])
	fname = getfiles (dirrr + "\\" + objname + ".dff") -- "D:\\SA UNPUCK\\"
	if fname.count>0 then (
	 fd = fopen fname[1] "rb"
	 obj = importDFF fd
	 fclose fd
	--)
	--obj = execute ("$" + objname)
	if obj != undefined then (
	 obj.rotation = (quat -(fs[7] as float) -(fs[8] as float) -(fs[9] as float) (fs[10] as float))
	 obj.position = [ (fs[4] as float), (fs[5] as float), (fs[6] as float)]	
	)
	else format "object not found %\n" objname
	) -- if fname.count
	count += 1
   ) -- if fs.count
  )
  else ( er_code = 1
         exit)
 while true
)
else format "wrong data\n"

format "objects : %\n" count
close f
)
) -- on load pressed

on impdff pressed do (
     fname = getOpenFileName caption:"select dff"  types:"dff (*.dff)|*.dff|"	
	  if fname!=undefined then (
	  fd = fopen fname "rb"
	  if fd!=undefined then obj = importDFF fd
	  fclose fd
)
) -- on imp pressed

) -- roll

try (closeRolloutFloater load_ipl_flo) catch () 
load_ipl_flo = newRolloutFloater "" 155 110 20 150 
addRollout  loadipl_rol load_ipl_flo