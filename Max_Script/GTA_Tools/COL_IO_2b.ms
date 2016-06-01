Global ColorAry = #( 
			color 59 59 59, 		--00 Standard
			color 123 123 123,		--01 Street	
			color 0 144 0,			--02 Grass
			color 100 74 51,		--03 Soil
			color 137 105 56,		--04 Dirt
			color 173 173 173,		--05 Beton
			color 224 224 224,		--06 Aluminum
			color 101 160 180,		--07 Glas
			color 55 55 45,			--08 Metal Pole
			color 128 128 0,		--09 Door
			color 224 224 224,		--10 Metal Sheet
			color 200 200 200,		--11 Metal
			color 153 153 153,		--12 Small Metal Post
			color 108 108 108,		--13 Large Metal Post
			color 133 133 133,		--14 Medium Metal Post
			color 186 154 154,		--15 Steel
			color 225 225 225,		--16 Fence
			color 198 72 72,		--17 Unused
			color 250 223 69,		--18 Sand
			color 0 72 240,			--19 Water
			color 151 75 0,			--20 Wooden Box
			color 119 60 0,			--21 Wooden Lathes
			color 92 48 29,			--22 Wood
			color 244 244 244,		--23 Metal Box
			color 229 229 229,		--24 Metal Box
			color 0 98 0,			--25 Hedge
			color 144 144 144,		--26 Rock
			color 159 159 159,		--27 Metal Container
			color 187 187 187,		--28 Metal Barrel
			color 198 72 72,		--29 Unused
			color 206 206 206,		--30 Metal Card Box
			color 198 72 72,		--31 Unused
			color 64 0 64,			--32 Gate/Bars
			color 250 223 69,		--33 Sand 2 (VC)
			color 0 144 0 )			--34 Grass 2 (VC)


Global PartAry = #( 	"Default",
    "Bonnet",            "Boot", 
	"Front Bumper",      "Rear Bumper",
	"Left Front Door",   "Right Front Door",
	"Left Rear Door",    "Right Rear Door",
	"Left Front Wing",   "Right Front Wing",
	"Left Rear Wing",    "Right Rear Wing",
	"","","","",								--13-16 are emply
	"Windscreen" )


Global surfaceAry = #(	"Standard",
	"Street",			"Grass",			"Soil",				"Dirt",				"Beton",
	"Aluminum",			"Glas",				"Metal Pole",		"Door",				"Metal Sheet",
	"Metal",			"Small Metal Post",	"Large Metal Post",	"Medium Metal Post",	"Steel",
	"Fence",			"Unused",			"Sand",				"Water",			"Wooden Box",
	"Wooden Lathes",	"Wood",				"Metal Box",		"Metal Box",		"Hedge",
	"Rock",				"Metal Container",	"Metal Barrel",		"Unused",			"Metal Card Box",
	"Unused",			"Gate/Bars",		"Sand 2 (VC)",		"Grass 2 (VC)" )


fn readCollHeader f = (
	--Get file size--
	fseek f 0 #seek_end
	endofcol = ftell f
	fseek f 0 #seek_set
	ColStartAry = #(0)
	ColNameAry = #()
	while (ftell f) != endofcol do (
		collheader = readLong f 
		if collheader != 0x4C4C4F43 then (
			format "Collision Header Error!\n"
			return undefined
		) else (
			thiscolsize = readLong f #unsigned
			append ColStartAry ( (ftell f) + thiscolsize )
			thiscolname = readstring f
			append ColNameAry thiscolname
			fseek f (thiscolsize - 1 - thiscolname.count) #seek_cur
		)
	)--end while
	deleteitem ColStartAry (ColStartAry.count)
	return #(ColStartAry,ColNameAry)
)--end fn readCollHeader 


fn ReadCol f fileStart Iscale = (
	fseek f fileStart #seek_set
	if (readLong f) != 0x4C4C4F43 then ( format "\nError in ReadCol!!!\n" ; return undefined )
	fseek f 28 #seek_cur
	bradius = (readFloat f) * Iscale
	brpos = [(readFloat f),(readFloat f),(readFloat f)] * Iscale
	bboxmin = [(readFloat f),(readFloat f),(readFloat f)] * Iscale
	bboxmax = [(readFloat f),(readFloat f),(readFloat f)] * Iscale
	tmp = sphere radius:bradius pos:brpos xray:on wirecolor:(color 216 218 140)
	tmp.name = "Bounding Sphere"
	boxsize = bboxmax - bboxmin
	tmp = box length:boxsize.y width:boxsize.x height:boxsize.z xray:on wirecolor:(color 216 218 140)
	tmp.center = (bboxmax + bboxmin) / 2
	tmp.name = "Bounding Box"
    format "Bounding Sphere:%\tradius:%\n" brpos bradius
    format "Bounding Box Min:%\n" bboxmin
    format "Bounding Box Max:%\n" bboxmax
	sp_count = readLong f
    format "Collision Spheres: %\n" sp_count 
	for i = 1 to sp_count do (
		spr = (readFloat f) * Iscale
		sppos = [(readFloat f),(readFloat f),(readFloat f)] * Iscale
		tmp = sphere radius:spr pos:sppos
		sv = readByte f #unsigned
		setUserProp tmp "surface_value" sv
		tmp.wirecolor = ColorAry[(sv+1)]
		sp = readByte f #unsigned
		setUserProp tmp "surface_parameter" sp
		if sp != 0 then tmp.name = PartAry[(sp+1)]
		readShort f
	)
	readLong f
	bx_count = readLong f
    format "Collision boxes: %\n" bx_count 
	for i = 1 to bx_count do (
		boxmin = [(readFloat f),(readFloat f),(readFloat f)] * Iscale
		boxmax = [(readFloat f),(readFloat f),(readFloat f)] * Iscale
		boxsize = boxmax - boxmin
		tmp = box length:boxsize.y width:boxsize.x height:boxsize.z 
		tmp.center = (boxmax + boxmin) / 2
 		sv = readByte f #unsigned
		setUserProp tmp "surface_value" sv
		tmp.wirecolor = ColorAry[(sv+1)]
		sp = readByte f #unsigned
		setUserProp tmp "surface_parameter" sp
		if sp != 0 then tmp.name = PartAry[(sp+1)]
		readShort f
	)
	verts_count = readLong f
    format "Collision Mesh-> Verts:%\t" verts_count
	VertAry = #();FaceAry = #()
	for i = 1 to verts_count do (
		append VertAry ( [(readFloat f),(readFloat f),(readFloat f)] * Iscale )
	)
	faces_count = readLong f 
    format "Faces:%\n\n" faces_count
	ValAry = #()
	ParAry = #()
	sameVal = True
	samePar = True
	for i = 1 to faces_count do (
		f2 = (readLong f) + 1.0
		f1 = (readLong f) + 1.0
		f3 = (readLong f) + 1.0
		append FaceAry [f1,f2,f3]
		sv = readByte f #unsigned
		if (ValAry.count > 0)AND(ValAry[1] != sv) then sameVal = False
		append ValAry sv
		sp = readByte f #unsigned
		if (ParAry.count > 0)AND(ParAry[1] != sp) then samePar = False
		append ParAry sp
		readShort f
	)
	if faces_count != 0 then (
		tmp = mesh vertices:VertAry faces:FaceAry wirecolor:(color 52 132 166)
		if sameVal == True then dcol = ColorAry[(ValAry[1]+1)] else dcol = (color 255 255 255)
		tmp.material = standardMaterial diffuse:dcol twoSided:true
		tmp.name = "Collision Mesh"
		if sameVal == True then setUserProp tmp "surface_value" ValAry[1]
		else (
			setUserProp tmp "Val" ValAry
			for i = 1 to Val.count do setFaceMatID tmp i (Val[i]+1)
		)
		if samePar == True then setUserProp tmp "surface_parameter" ParAry[1]
		else setUserProp tmp "Par" ParAry
	)
	--format "%\n%\nHere:%\n" VertAry FaceAry (ftell f)
)--end fn ReadCol


fn Checkpot ObjectAry = (
	unique = for obj in ObjectAry where (obj.name == "Bounding Sphere") collect obj
	if unique.count > 1 then (
		messagebox "Select 1 Bounding Sphere!" title:"Bounding Sphere Error"
		return false
	)
	unique = for obj in ObjectAry where (obj.name == "Bounding Box") collect obj
	if unique.count > 1 then (
		messagebox "Select 1 Bounding Box!" title:"Bounding Box Error"
		return false
	)	
	unique = for obj in ObjectAry where (obj.name == "Collision Mesh") collect obj
	if unique.count > 1 then (
		messagebox "Select 1 Collision Mesh!" title:"Collision Mesh Error"
		return false
	)
	return true
)--end fn Checkpot


fn dumpCol ObjectAry SavePathName Colname Iscale = (
		bs = for obj in ObjectAry where (obj.name == "Bounding Sphere") collect obj
		bb = for obj in ObjectAry where (obj.name == "Bounding Box") collect obj
		deselect bs
		deselect bb
		s = 36 + 48
		for o in ObjectAry where (classof o == Sphere) do s += 20
		for o in ObjectAry where (classof o == Box) do s += 28
		CM = for o in ObjectAry where (o.name == "Collision Mesh") collect o 
		if CM.count != 0 then (
			s += CM[1].numverts * 12
			s += CM[1].numFaces * 16
			ID = getUserProp CM[1] "ID"
		)
		if ID != undefined then ID += 0x300000
		else ID = 0x0030FFFF
		format "//"
		format "\n" 
		clearlistener()
		format "<!-- path=\"%\" -->\n" SavePathName
		format "//\n// Collision file <%> start here\n//\n" Colname
		format "c 4\nCOLL\n"
		format "i 1\n%\n" s
		format "c 20\n%\n" Colname
		format "i 1\n%\n" ID        
		if bs.count == 0 then (
			bmax = $.max
			bmin = $.min
			boxsize = bmax - bmin
			br = sqrt ( (boxsize.x/2 * boxsize.x/2)+(boxsize.y/2 * boxsize.y/2)+(boxsize.z/2 * boxsize.z/2) )
			obj = sphere radius:br xray:on wirecolor:(color 216 218 140)
			obj.center = (bmax + bmin) / 2
			obj.name = "tmpBS"
		) else obj = bs[1]
		if obj.scale != [1,1,1] then (
			sc = obj.scale.x
			if sc > obj.scale.y then sc = obj.scale.y
			if sc > obj.scale.z then sc = obj.scale.z
		)else sc = 1
		format "//BoundingSphere R X Y Z\n"
		format "f 10\n% % % %\n" (obj.radius * sc * Iscale) (obj.pos.x * Iscale) (obj.pos.y * Iscale) (obj.pos.z * Iscale)
		try (delete $'tmpBS') catch ()
		if bb.count == 0 then (
			bmax = $.max
			bmin = $.min
			boxsize = bmax - bmin
			obj = box length:boxsize.y width:boxsize.x height:boxsize.z xray:on wirecolor:(color 216 218 140)
			obj.center = (bmax + bmin) / 2
			obj.name = "tmpBB"
		) else obj = bb[1]
        t = snapshot obj
		tmx = t.max
		tmn = t.min
		delete t
		format "//BoundingBox min max\n"
		format "% % % % % %\n" (tmn.x * Iscale) (tmn.y * Iscale) (tmn.z * Iscale) (tmx.x * Iscale) (tmx.y * Iscale) (tmx.z * Iscale)
		try (delete $'tmpBB') catch ()        
		sp = for obj in ObjectAry where ((classof obj == Sphere)AND(obj.name != "Bounding Sphere")) collect obj
		format "//Spheres\n"
		format "i 1\n%\n" sp.count
		for s in sp do (
			if s.scale != [1,1,1] then (
				sc = s.scale.x
				if sc > s.scale.y then sc = s.scale.y
				if sc > s.scale.z then sc = s.scale.z
			)else sc = 1
			format "f 4\n% % % %\n" (s.radius * sc * Iscale) (s.pos.x * Iscale) (s.pos.y * Iscale) (s.pos.z * Iscale)
			svl = getUserProp s "surface_value"
			if svl == undefined then svl = 0
			spt = getUserProp s "surface_parameter"
			if spt == undefined then spt = 0
			format "b 4\n% % 0 0\n" svl spt 
		)--end for 
		bx = for obj in ObjectAry where ((classof obj == Box)AND(obj.name != "Bounding Box")) collect obj
		format "//Boxes\n"
		format "i 2\n0 %\n" bx.count
		for b in bx do (
			t = snapshot b
			tmx = t.max
			tmn = t.min
			delete t
			format "f 6\n% % % % % %\n" (tmn.x * Iscale) (tmn.y * Iscale) (tmn.z * Iscale) (tmx.x * Iscale) (tmx.y * Iscale) (tmx.z * Iscale)
			svl = getUserProp b "surface_value"
			if svl == undefined then svl = 0
			spt = getUserProp b "surface_parameter"
			if spt == undefined then spt = 0
			format "b 4\n% % 0 0\n" svl spt 
		)--end for
		CM = for o in ObjectAry where (o.name == "Collision Mesh") collect o 
		if CM.count == 0 then (
			format "//No Collision Mesh\n"	
			format "i 2\n0 0\n"
		) else (
			obj = CM[1]
			format "//Collision Mesh\n"
			format "i 1\n%\nf %\n" obj.numverts (obj.numverts * 3)
			for i = 1 to obj.numverts do (
				format "% % %\n" (obj.verts[i].pos.x * Iscale) (obj.verts[i].pos.y * Iscale) (obj.verts[i].pos.z * Iscale)
			)--end for i
			format "i %\n%\n" (obj.numfaces * 4 + 1) obj.numfaces
			sv = getUserProp obj "surface_value"
			sp = getUserProp obj "surface_parameter"
			if sp == undefined then (
				stg = getUserPropbuffer obj
				tmp = findstring stg "Par"
				if tmp == undefined then (
					stg = undefined
					sp = 0
				) else (
					stg = ( substring stg tmp (stg.count-tmp) ) as stringStream
					skiptostring stg "("
				)
			)
			for i = 1 to obj.numfaces do (
				tmp = getFace obj i
				if sv == undefined then sv = (getFaceMatID obj i) - 1
				if stg != undefined then sp = readvalue stg
				format "% % % %\n" ((tmp.y - 1) as integer) ((tmp.x - 1) as integer) ((tmp.z - 1) as integer) (sv + sp * 256)
			)--end for i 
		)
		format "//\n"
		format "//"
)--end fn dumpCol


fn expCol f ObjectAry Colname Iscale = (
		bs = for obj in ObjectAry where (obj.name == "Bounding Sphere") collect obj
		bb = for obj in ObjectAry where (obj.name == "Bounding Box") collect obj
		deselect bs
		deselect bb
		s = 36 + 48
		for o in ObjectAry where (classof o == Sphere) do s += 20
		for o in ObjectAry where (classof o == Box) do s += 28
		CM = for o in ObjectAry where (o.name == "Collision Mesh") collect o 
		if CM.count != 0 then (
			s += CM[1].numverts * 12
			s += CM[1].numFaces * 16
			ID = getUserProp CM[1] "ID"
		)
		if ID != undefined then ID += 0x300000
		else ID = 0x0030FFFF
		Colname = getFilenameFile Colname
		writeLong f 0x4C4C4F43		--COLL
		writeLong f s				--size
		writeString f Colname
		for i = 1 to 19 - Colname.count do writeByte f 0
		writeLong f ID		
		if bs.count == 0 then (
			bmax = $.max
			bmin = $.min
			boxsize = bmax - bmin
			br = sqrt ( (boxsize.x/2 * boxsize.x/2)+(boxsize.y/2 * boxsize.y/2)+(boxsize.z/2 * boxsize.z/2) )
			obj = sphere radius:br xray:on wirecolor:(color 216 218 140)
			obj.center = (bmax + bmin) / 2
			obj.name = "tmpBS"
		) else obj = bs[1]
        if obj.scale != [1,1,1] then (
			sc = obj.scale.x
			if sc > obj.scale.y then sc = obj.scale.y
			if sc > obj.scale.z then sc = obj.scale.z
		)else sc = 1
		writeFloat f (obj.radius * sc * Iscale) 
		writeFloat f (obj.pos.x * Iscale) 
		writeFloat f (obj.pos.y * Iscale) 
		writeFloat f (obj.pos.z * Iscale)
		try (delete $'tmpBS') catch ()
		if bb.count == 0 then (
			bmax = $.max
			bmin = $.min
			boxsize = bmax - bmin
			obj = box length:boxsize.y width:boxsize.x height:boxsize.z xray:on wirecolor:(color 216 218 140)
			obj.center = (bmax + bmin) / 2
			obj.name = "tmpBB"
		) else obj = bb[1]
        t = snapshot obj
		tmx = t.max
		tmn = t.min
		delete t
		writeFloat f (tmn.x * Iscale) 
		writeFloat f (tmn.y * Iscale)
		writeFloat f (tmn.z * Iscale)
		writeFloat f (tmx.x * Iscale)
		writeFloat f (tmx.y * Iscale)
		writeFloat f (tmx.z * Iscale)
		try (delete $'tmpBB') catch ()
		sp = for obj in ObjectAry where ((classof obj == Sphere)AND(obj.name != "Bounding Sphere")) collect obj
		writeLong f sp.count
		for s in sp do (
			if s.scale != [1,1,1] then (
				sc = s.scale.x
				if sc > s.scale.y then sc = s.scale.y
				if sc > s.scale.z then sc = s.scale.z
			)else sc = 1
			writeFloat f (s.radius * sc * Iscale) 
			writeFloat f (s.pos.x * Iscale) 
			writeFloat f (s.pos.y * Iscale) 
			writeFloat f (s.pos.z * Iscale)
			svl = getUserProp s "surface_value"
			if svl == undefined then svl = 0
			spt = getUserProp s "surface_parameter"
			if spt == undefined then spt = 0
			writeLong f (svl + spt * 256) 
		)--end for 
		writeLong f 0
		bx = for obj in ObjectAry where ((classof obj == Box)AND(obj.name != "Bounding Box")) collect obj
		writeLong f bx.count
		for b in bx do (
			t = snapshot b
			tmx = t.max
			tmn = t.min
			delete t
			writeFloat f (tmn.x * Iscale) 
			writeFloat f (tmn.y * Iscale)
			writeFloat f (tmn.z * Iscale)
			writeFloat f (tmx.x * Iscale)
			writeFloat f (tmx.y * Iscale)
			writeFloat f (tmx.z * Iscale)
			svl = getUserProp b "surface_value"
			if svl == undefined then svl = 0
			spt = getUserProp b "surface_parameter"
			if spt == undefined then spt = 0
			writeLong f (svl + spt * 256) 
		)--end for
		CM = for o in ObjectAry where (o.name == "Collision Mesh") collect o 
		if CM.count == 0 then (
			writeLong f 0
			writeLong f 0
		) else (
			obj = CM[1]
			writeLong f obj.numverts
			for i = 1 to obj.numverts do (
				writeFloat f (obj.verts[i].pos.x * Iscale)
				writeFloat f (obj.verts[i].pos.y * Iscale)
				writeFloat f (obj.verts[i].pos.z * Iscale)
			)--end for i
			writeLong f obj.numfaces
			sv = getUserProp obj "surface_value"
			sp = getUserProp obj "surface_parameter"
			if sp == undefined then (
				stg = getUserPropbuffer obj
				tmp = findstring stg "Par"
				if tmp == undefined then (
					stg = undefined
					sp = 0
				) else (
					stg = ( substring stg tmp (stg.count-tmp) ) as stringStream
					skiptostring stg "("
				)
			)
			for i = 1 to obj.numfaces do (
				tmp = getFace obj i
				if sv == undefined then sv = (getFaceMatID obj i) - 1
				if stg != undefined then sp = readvalue stg
				writeLong f ((tmp.y - 1) as integer)
				writeLong f ((tmp.x - 1) as integer)
				writeLong f ((tmp.z - 1) as integer)
				writeLong f (sv + sp * 256)
			)--end for i 
		)
)--fn expCol



Global fname

rollout COL_IO "IO Parameters" (
	button impCol "Open Collision File" width:120 align:#center tooltip:"Open Collision File"
	listbox ColList height:10 offset:[0,-3]
	button loaCol "Load" width:61 align:#left tooltip:"Load the selected model into (G)Max" offset:[0,-3] across:2 
	spinner INScale "" range:[0.000001,100000,1] fieldwidth:45 align:#right offset:[-1,0] 
	button SavCol "* Save As" width:61 align:#left tooltip:"Save ONLY your selected SCENE models to a new col file" across:2
	button DelCol "Delete" width:61 align:#right tooltip:"not available in GMax"
	button RepCol "Replace" width:61 align:#left tooltip:"not available in GMax" across:2 offset:[0,-5]
	button AppCol "Append" width:61 align:#right tooltip:"Select your models and type the name below" offset:[0,-5]
	edittext newname "" align:#center width:125 offset:[-2,-5]

on SavCol pressed do (
		if ($selection.count > 0)AND(newname.text.count > 0) then (
			if Checkpot $selection == true then (
				Sname = getSaveFileName caption:"Save as New GTA Collision File" types:"Collisiion File (*.col)|*.col|"
				if Sname != undefined then (
					try (
						f = fopen Sname "wb"
						expCol f $selection newname.text INScale.value
						fclose f
						format "% saved\n" Sname
					) catch (	
						Sname = (substring Sname 1 (Sname.count-4)) + ".txt"
						dumpCol $selection Sname newname.text INScale.value
					)
				)--end if Sname
			)--end if Checkpot
		)--end if
	)--end on SavCol
	
	on RepCol pressed do (
		if ($selection.count > 0)AND(ColList.selection > 0) then (
			if Checkpot $selection == true then (
				try (					--	undefined * undefined
					Sname = (getFilenamePath fname) + "temp.bin"
					f = fopen Sname "wb"
					ff = fopen fname "rb"
					if ColList.selection == ColList.items.count then (
						addstart1 = 0
						addend1 = ColAry[1][ColList.selection] - 1
						addstart2 = undefined
						addend2 = undefined
					) else
					if ColList.selection == 1 then (
						addstart1 = undefined
						addend1 = undefined	
						addstart2 = ColAry[1][2]
						fseek ff 0 #seek_end
						addend2 = (ftell ff) - 1
					) else (
						addstart1 = 0
						addend1 = ColAry[1][(ColList.selection)] - 1
						addstart2 = ColAry[1][(ColList.selection + 1)]
						fseek ff 0 #seek_end
						addend2 = (ftell ff) - 1
					)				
					if addstart1 != undefined then (
						fseek ff addstart1 #seek_set
						for i = addstart1 to addend1 do  writeByte f (readByte ff)				
					)
					expCol f $selection ColList.selected INScale.value
					if addstart2 != undefined then (
						fseek ff addstart2 #seek_set
						for i = addstart2 to addend2 do  writeByte f (readByte ff)
		 			)
				 	fclose ff
					fclose f
					deleteFile fname
					renameFile Sname fname					
					f = fopen fname "rb"
					global ColAry = readCollHeader f
					ColList.items = ColAry[2]
					fclose f
				) catch (
					Sname = (getFilenamePath fname) + ColList.selected + ".txt"
					dumpCol $selection Sname ColList.selected INScale.value
				)--end try/catch
			)
		)--end if
	)--end on RepCol	


	on DelCol pressed do (
		if ColList.items.count == 1 then (
			ColList.items = #()
			ColAry = #()
			impCol.text = "Open Collision File"
			gc()
		) else 	
		if (ColList.selection > 0) then (	
			try (
				Sname = (getFilenamePath fname) + "temp.bin"
				f = fopen Sname "wb"
				ff = fopen fname "rb"
				addstart2 = undefined
				addend2 = undefined
				if ColList.selection == ColList.items.count then (
					addstart1 = 0
					addend1 = ColAry[1][ColList.selection] - 1
				) else
				if ColList.selection == 1 then (
					addstart1 = ColAry[1][2]
					fseek ff 0 #seek_end
					addend1 = (ftell ff) - 1
				) else (
					addstart1 = 0
					addend1 = ColAry[1][(ColList.selection)] - 1
					addstart2 = ColAry[1][(ColList.selection + 1)]
					fseek ff 0 #seek_end
					addend2 = (ftell ff) - 1
				)				
				fseek ff addstart1 #seek_set
				for i = addstart1 to addend1 do  writeByte f (readByte ff)				
				if addstart2 != undefined then (
					fseek ff addstart2 #seek_set
					for i = addstart2 to addend2 do  writeByte f (readByte ff)
		 		)
			 	fclose ff
				fclose f
				deleteFile fname
				renameFile Sname fname					
				f = fopen fname "rb"
				global ColAry = readCollHeader f
				ColList.items = ColAry[2]
				fclose f			 
			) catch()
		)
	)--end on DelCol
	
	on AppCol pressed do (
		if ($selection.count > 0)AND(newname.text.count > 0)AND(ColList.selection > 0) then (
			if Checkpot $selection == true then (
				try (				--	undefined * undefined
					Sname = (getFilenamePath fname) + "temp.bin"
					f = fopen Sname "wb"
					ff = fopen fname "rb"
					fseek ff 0 #seek_end
					totalbyte = ftell ff
					fseek ff 0 #seek_set
					for i = 1 to totalbyte do ( writeByte f (readByte ff) )
					fclose ff
					expCol f $selection newname.text INScale.value
					fclose f
					format "Data Appended\n"	
					deleteFile fname
					renameFile Sname fname					
					f = fopen fname "rb"
					global ColAry = readCollHeader f
					ColList.items = ColAry[2]
					fclose f					
				) catch (
					Sname = (getFilenamePath fname) + newname.text + ".txt"
					dumpCol $selection Sname newname.text INScale.value
				)--end try/catch
			)--end if Checkpot
		)--end if
	)--end on AppCol	
	
	

	on loaCol pressed do (
		if (ColList.selection > 0) then (
			f = fopen fname "rb"
			format "Coll. File:> %\n" ColList.selected
			ReadCol f ColAry[1][ColList.selection] INScale.value
			fclose f
			newname.text = ColList.selected
		)
	)--end on loaCol
	
	on impCol pressed do (	
		fname = getOpenFileName caption:"Open GTA Collision File" types:"Collisiion File (*.col)|*.col|"
		if (fname != undefined) then (
			f = fopen fname "rb"
			global ColAry = readCollHeader f
			ColList.items = ColAry[2]
			for i = 1 to ColAry[1].count do		format "%:\t%\n" ColAry[2][i] ColAry[1][i]
			impCol.text = "Col. File :  " + (getFilenameFile fname) + ".col"
			fclose f
		) else (
			impCol.text =  "Open Collision File" 
			ColList.items = #()
		)
	)--end on impCol
	
)--end rollout COL_IO



rollout Surfroll "Surface Parameters" (

	group "Info." (
		button getinfo "Get Info." width:120
		label lbl0 ""
		label lbl1 ""
		label lbl2 "" align:#left across:2
		label lbl6 "" align:#right
		label lbl3 "" align:#left across:2
		label lbl7 "" align:#right
		label lbl4 "" align:#left across:2
		label lbl8 "" align:#right
		label lbl5 "" align:#left across:2
		label lbl9 "" align:#right
	)

	group "Surface Control" (
		colorpicker surfcol "" color:(color 59 59 59) enabled:false width:30 align:#left across:2
		dropdownlist surfval "" items:surfaceAry width:90 align:#right
		dropdownlist surfPar "" items:PartAry selection:1 width:118 align:#right
		button setsurf "Set Surface" width:118 align:#right 
	)

	button CreBBS "Create Boundings" width:120 align:#center tooltip:"Create bounding Sphere and Box for selections"

	on CreBBS pressed do (
		if $selection.count != 0 then (
			try ( delete $'Bounding Box'; delete $'Bounding Sphere') catch ()
			bmax = $.max
			bmin = $.min
			boxsize = bmax - bmin
			tmp = box length:boxsize.y width:boxsize.x height:boxsize.z xray:on wirecolor:(color 216 218 140)
			tmp.center = (bmax + bmin) / 2
			tmp.name = "Bounding Box"
			br = sqrt ( (boxsize.x/2 * boxsize.x/2)+(boxsize.y/2 * boxsize.y/2)+(boxsize.z/2 * boxsize.z/2) )
			tmp = sphere radius:br xray:on wirecolor:(color 216 218 140)
			tmp.center = (bmax + bmin) / 2
			tmp.name = "Bounding Sphere"
		)	
	)

	on setsurf pressed do (
		if $selection.count != 0 then (
			for obj in $selection do (
				if classof obj == Editable_mesh then (setUserPropBuffer obj ""; obj.name = "Collision Mesh" )
				setUserProp obj "surface_parameter" (surfPar.selection - 1)
				setUserProp obj "surface_value" (surfval.selection - 1)
				obj.wirecolor = surfcol.color
			)--end for
		)--end if
	)--end on setsurf

	on surfval selected id do (
		surfcol.color = ColorAry[id]
	)
	
	on getinfo pressed do (
		if $selection.count != 1 then messagebox "Select A Single Object!" title:"Selection Error"
		else (
		obj = $
		if classof obj == Sphere then (
			lbl2.text = "Radius:  " + obj.radius as string
			lbl3.text = obj.pos.x as string
			lbl4.text = obj.pos.y as string
			lbl5.text = obj.pos.z as string
			lbl6.text = "";lbl7.text = ""
			lbl8.text = "";lbl9.text = ""
			if obj.name == "Bounding Sphere" then lbl1.text = "Bounding Sphere"
			else (
				try (
					idx = getUserProp obj "surface_value" + 1
					surfval.selection = idx
					surfcol.color = ColorAry[idx]
					surfPar.selection = (getUserProp obj "surface_parameter")+1
					lbl1.text = obj.name
					lbl0.text = ""
				) catch (
					lbl0.text = ">>No Surface Properites<<"
				)--end try/catch
			)--end if/else Bounding Sphere	
		)--end if/else Sphere
		if classof obj == Box then (
			tm = snapshot obj
			tmax = tm.max;tmin = tm.min
 			delete tm
			lbl2.text = "    Max:"
			lbl6.text = "Min:    "
			lbl3.text = tmax.x as string
			lbl4.text = tmax.y as string
			lbl5.text = tmax.z as string
			lbl7.text = tmin.x as string
			lbl8.text = tmin.y as string
			lbl9.text = tmin.z as string
			if obj.name == "Bounding Box" then lbl1.text = "Bounding Box"
			else (
				try (
					idx = getUserProp obj "surface_value" + 1
					surfval.selection = idx
					surfcol.color = ColorAry[idx]
					surfPar.selection = (getUserProp obj "surface_parameter")+1
					lbl1.text = obj.name
					lbl0.text = ""
				) catch (
					lbl1.text = ">>No Surface Properites<<"
				)--end try/catch
			)--end if/else Bounding box
		)--end if/else Box
		if obj.name == "Collision Mesh" then ( 
			lbl1.text = "Collision Mesh"
			lbl2.text = "Verts: " + obj.numverts as string
			lbl6.text = "Faces: " + obj.numverts as string
			lbl3.text = "";lbl0.text = ""
			lbl5.text = "";lbl7.text = ""
			lbl8.text = "";lbl9.text = ""
			idx = getUserProp obj "Val"
			if idx != undefined then lbl4.text = "Multi Surface Properities"
			else (
				try (
					idx = getUserProp obj "surface_value" + 1
					surfval.selection = idx
					surfcol.color = ColorAry[idx]
					lbl4.text = ""
				) catch (
					lbl4.text = ">>No Surface Properites<<"
				)--end try/catch
			)--end if else "Val"
			idx = getUserProp obj "Par"
			if idx != undefined then lbl5.text = "Multi Parts Surface"
			else (
				try (
					surfPar.selection = (getUserProp obj "surface_parameter")+1
					lbl5.text = ""
				) catch (
					lbl5.text = ">>No Parts Surface<<"
				)--end try/catch
			)--end if/else "Par"
		)--end if Collision Mesh
		)
	)
	
)--end rollout Surfroll

rollout aboutRoll "About" (
	label l1 "GTA COL IO v0.2b"
	label l3 " " 
	label l4 "by Kam" align:#left across:2
	label l5 "11Mar05" align:#right
	label l6 "kam.lai@ntlworld.com"
	listbox dmybox "" items:#("For Multi-Surface prop.","of Collision Mesh:","",
		"Set the Material IDs","                for each face","",
		"But for Multi-Parts prop.","You have to manual set",
		"a UserProp \"Par\" Array","                for each face",
		"","eg:Par = #(2,8,0,1,0,5)") height:12 enabled:false selection:0
) 

if Kam_GTACOL != undefined then closeRolloutFloater Kam_GTACOL
Kam_GTACOL = newRolloutFloater "COL IO v0.2b" 175 355 10 100		
addRollout COL_IO Kam_GTACOL	
addRollout Surfroll Kam_GTACOL rolledup:true
addRollout aboutRoll Kam_GTACOL rolledup:true




