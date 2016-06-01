fn read_mesh_structure f =
(     local res = undefined
      mesh_v = #()
	  mesh_f = #()
	  mesh_fid = #()
	  mesh_uv = #()
	  mesh_vc = #()
	  mesh_nvc = #()
      unk1 = readlong f
	  fnum = readlong f
	  
	  if fnum > 0 then
	  (
		  vnum = readlong f #unsigned
		  fseek f 32 #seek_cur
		  
		  for i = 1 to vnum do
		    mesh_v[i] = [readfloat f, readfloat f, readfloat f]
		  
		  for i = 1 to vnum do
		    mesh_nvc[i] = (color (readbyte f #unsigned) (readbyte f #unsigned) (readbyte f #unsigned) (readbyte f #unsigned))
		  
		  for i = 1 to vnum do (
		    mesh_vc[i] = (color (readbyte f #unsigned) (readbyte f #unsigned) (readbyte f #unsigned))
			b = (readbyte f #unsigned)
		  )
		  
		  for i = 1 to vnum do
		    mesh_uv[i] = [readfloat f, readfloat f, 0.0]
		  
		  for i = 1 to fnum do (
                        mesh_f[i] = [(readshort f #unsigned) + 1, (readshort f #unsigned) + 1, (readshort f #unsigned) + 1]
			mesh_fid[i] = (readshort f #unsigned) + 1
	      )	    
			
		  BSPmesh = mesh vertices:mesh_v  faces:mesh_f  materialIDs:mesh_fid
		  
		  
		  meshop.setMapSupport BSPmesh 1 true
		  BSPmesh.numTverts = vnum
	      for i = 1 to vnum do
	               meshop.setMapVert BSPmesh 1 i [mesh_uv[i].x, -mesh_uv[i].y, 0.0]
	      buildTVFaces BSPmesh
		  for i = 1 to fnum do
	               meshOp.setMapFace BSPmesh 1 i [mesh_f[i][1], mesh_f[i][2], mesh_f[i][3]]
				   
				   
		  defaultVCFaces BSPmesh
	      for i = 1 to vnum do 
	              setVertColor BSPmesh i mesh_vc[i]

		  meshop.defaultMapFaces BSPmesh -1
	      for i = 1 to vnum do 
	               meshop.setMapVert BSPmesh -1 i \
                          [(mesh_vc[i].r)/255.0, \
						   (mesh_vc[i].g)/255.0, \
						   (mesh_vc[i].b)/255.0]
				  
		  res = BSPmesh
	  ) -- fnum > 0
res	 
)	-- fn 


---------------------------------------------------------------------------------------------------------------------------------

fn readHeader ff = (
local res = #()
res[1] = readLong ff #unsigned
res[2] = readLong ff #unsigned
res[3] = readLong ff #unsigned

res
)


---------------------------------------------------------------------------------------------------------------------------------

fn read_plain ff Size = (
local H, NextPos

H = readHeader ff
fseek f H[2] #seek_cur

H = readHeader ff
NextPos = (ftell ff) + H[2]
if H[1] == 0x0A then read_plain ff H[2]

H = readHeader ff
NextPos = (ftell ff) + H[2]
if H[1] == 0x0A then read_plain ff H[2]
)
---------------------------------------------------------------------------------------------------------------------------------

fn readBString f n = (
local i, res = ""
for i = 1 to n do res += bit.intAsChar (readbyte f #unsigned)
res
)

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------


texture_path = getsavePath caption:"SELECT DIRECTORY WITH TEXTURES" initialdir:"D:\\MUNHA_TEXTURES"

fname = getopenfilename caption:"SELECT .BSP" filename:(texture_path + "\\*.bsp")
if fname != undefined then
(
  f = fopen fname "rb"
  if f == undefined then messagebox "cant open"
  else
  (   clearListener ()
      MeshCount = 0
      H = readheader f
	  format "% %\n" (bit.intAsHex H[1]) (bit.intAsHex H[3])
      if H[1] != 0x0b then messagebox "not WORLD"
      else (
	     H = readheader f --; format "% %\n---------\n" (bit.intAsHex H[1]) (bit.intAsHex H[3])
		 fseek f H[2] #seek_cur
	     H = readheader f  -- TLIST
		 H = readheader f  -- TLIST/STRUCT
		 texture_num = readlong f ; format "tnum %\n" texture_num -- MAT
		 fseek f (H[2] - 4) #seek_cur
		 mat = multimaterial ()
		 mat.numsubs = texture_num
		 for i = 1 to texture_num do (		     
	         H = readheader f  ; format "% %\n" (bit.intAsHex H[1]) (bit.intAsHex H[3]) -- MAT
		     NextPos = (ftell f) + H[2]
			 if H[1] != 0x07 then (
			    fseek f -12 #seek_cur
				exit
			 )
			 H = readheader f --; format "% %\n" (bit.intAsHex H[1]) (bit.intAsHex H[3]) -- MAT/STRUCT			 
			 b = readlong f
			 difcolor = (color (readbyte f #unsigned) (readbyte f #unsigned) (readbyte f #unsigned))
			 mat[i].diffuse = difcolor
			 mat[i].opacity = ((readbyte f #unsigned)*100.0)/255.0
			 b = readlong f
			 tcount = readlong f
			 fseek f 12 #seek_cur
			 if tcount > 0 then (
				 H = readheader f --; format "% %\n" (bit.intAsHex H[1]) (bit.intAsHex H[3]) -- TEX			 
				 H = readheader f --; format "% %\n" (bit.intAsHex H[1]) (bit.intAsHex H[3]) -- TEX/STRUC
				 fseek f H[2] #seek_cur
				 H = readheader f          -- string
	             tname = readBString f (H[2] - 1)
	             b = readbyte f
	             mat[i].diffusemap = bitmapTexture ()
	             mat[i].DiffuseMap.filename = texture_path + "\\" + tname + ".tga"
				 showTextureMap mat[i] true
	             H = readheader f
	             if H[2] > 4 then (
				    mat[i].opacitymap = bitmapTexture ()
					mat[i].opacitymap.filename = texture_path + "\\" + tname + ".tga"
					mat[i].opacitymap.alphasource = 0
					mat[i].opacitymap.RGBOutput = 1
					mat[i].opacitymap.monoOutput = 1
		         )
			 ) -- if tcount > 0
             fseek f NextPos #seek_set
             --if i > 2 then break ()	 
		 )
		 
		 aslot = medit.GetActiveMtlSlot()
	     --oldmat = getMeditMaterial aslot
	     --mat.name = oldmat.name
	     setMeditMaterial aslot mat
		 
		 --H = readheader f ; format "zzz % %\n" (bit.intAsHex H[1]) (bit.intAsHex H[3])
		 --break ()
		 if false then messagebox "no MATERIAL LIST"
		 else (
		      --H = readheader f
			  --fseek f H[2] #seek_cur
			  
			  while true do (
			  --if MeshCount > 20 then exit
			     H = readheader f
				 if H[1] == 0x0A then (
				    H = readheader f
				    fseek f H[2] #seek_cur
				 )
				 else
				   if H[1] == 0x09 then (
                      format "atomic found \n"                      			      
				      NextPos = (ftell f) + H[2]
					  H = readheader f
					  new_obj = read_mesh_structure f
					  if new_obj != undefined then (
					     new_obj.material = mat
					     MeshCount += 1
						 )
					  fseek f NextPos #seek_set
				   )
				   else (
				     format "end section ID = %\n" (bit.intAsHex H[1])
					 exit
				   )
			  ) -- while true
			  format "Meshes Found %\n" MeshCount
		 ) -- else no mat list
      ) -- else not WORLD  
	  fclose f
  )
)