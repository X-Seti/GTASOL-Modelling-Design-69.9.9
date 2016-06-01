-----------------------------------------------------------------------------------------------------------

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

-----------------------------------------------------------------------------------------------------------

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
	  count = 0
	  sipl = #()
	  objnames = #()
	  lodnames = #()	  
	   
	   do
	    if not eof f then (
	    s = readline f
		s = no_comments s
		if lowercase s == "end" do exit
		fs = filterString s  ", "
		if fs.count > 10 do 
		 if (lowercase (substring fs[2] 1 3) != "lod") do (
		 count += 1
		 sipl[count] = fs[1] + ", , " + fs[3] + ", " + fs[4] + ", " + fs[5] + ", " + fs[6] + ", " + \
		               fs[7] + ", " + fs[8] + ", " + fs[9] + ", " + fs[10] + ", "
         objnames[count] = fs[2]	
         lodnames[count] = lowercase (replace fs[2] 1 3 "lod")
				   
		 ) -- if count > 10 
		) -- if not eof f
		else ( er_code = 1
		       exit )
	   while true
	 
	   format "count %\n" count

close f
	   
-----------------------------------------------------------------------------------------------------------	 

GtaPathName = getSavePath caption:"SELECT GTA DIR"
GtaPathName += "\\"

GtaDatFname = GtaPathName + "data\\gta.dat"

fgtadat = openfile GtaDatFname

if fgtadat != undefined then (
 IDEcount = 0
 IDEnames = #()
 
 while not eof fgtadat do (
  s = readline fgtadat
  s = no_comments s
  if lowercase (substring s 1 3) == "ide" do (
   IDEcount += 1
   IDEnames [IDEcount] = GtaPathName + trimLeft (trimRight (substring s 4 -1))
  )
 )
 
close fgtadat

if  IDEcount > 0 then (
 i = 0
 j = 1
 lodide = #()
 AllReaded = false
 
 do (
  f = openFile IDEnames[j]
  if f != undefined then (
   while not eof f do (
    s = readline f
	s = no_comments s
	fs = filterString s ", "
	if fs.count>4 do
	if lowercase (substring fs[2] 1 3) == "lod" do
	 if (n = findItem lodnames (lowercase fs[2])) > 0 do (
	  lodide[n] = fs[1]
	  i+=1
	  if i == count do AllReaded = true
	 )
   )
  )
  else (er_code = 1
        exit)
		
 close f
 j+=1		
 )		
 while (j<=IDEcount)and(not AllReaded)
 
 
clearListener ()
lodn = 1

for i = 1 to count do (
 n = findString sipl[i] ","
 format "%" (replace sipl[i] (n+2) 0 objnames[i])
 m = findItem lodnames (lowercase(replace objnames[i] 1 3 "lod"))
 if lodide[m]!=undefined then (
  format "%\n" lodn
  format "%, -1\n" (replace (replace sipl[i] (n+2) 0 lodnames[m]) 1 (n-1) lodide[m])
  lodn += 1
 )
 else format "-1\n"
 lodn += 1
)

format "lodnum :%\n" lodn
-----------------------------------------------------------------------------------------------------------

)
else format "no IDE in gta.dat\n"
 
 
) --- dat nof fount
else format "GTA.DAT nof found\n"
	   
-----------------------------------------------------------------------------------------------------------
	   
  ) --- inst not found
  else format "INST not found\n"
) --- if fname IPL undef 