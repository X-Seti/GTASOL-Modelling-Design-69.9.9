fn readHeader ff = (
local res = #()
res[1] = readLong ff #unsigned
res[2] = readLong ff #unsigned
res[3] = readLong ff #unsigned

res
)


fname = getopenfilename ()
if fname!= undefined then (
   f = fopen fname "rb"
   if f == undefined then messagebox "cant open"
   else
   (  
      dir = (getFilenamePath fname) + "DFF\\"
	  makeDir dir
      mcount = 0
      while true do (
	      H = readheader f
		  if H[1] == undefined then exit
		  mcount += 1
		  fname = dir + "model_" + (mcount as string) + ".dff"
		  format "%\n" fname
		  f1 = fopen fname "wb"
		  writelong f1 H[1]
		  writelong f1 H[2]
		  writelong f1 H[3]
		  for i = 1 to H[2] do (
		      b = readbyte f
			  writebyte f1 b
		  )		      
		  fclose f1
		  format "-- % \n" (bit.intAsHex H[1])
		  --fseek f H[2] #seek_cur	         
      ) 
      fclose f  
   )
)
