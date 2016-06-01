--revise start; 11/03/06
--global variables
--timer
start = 0
end = 0
global geomcount
global lightcount
global helpercount
global dfffile
global dffstream
global filesize
global int1 = 0
global int2 = 0
global framelistsize = 0
global frmlstint = 131075 --only for root! otherwise 0
global frmlistsizepos = 0
global geom_size = 0 --used for final writing
global actual_geomsize = 0
global geomlist_size = 0
global geometrylistsize = 0
global geometrystrucsize = 0
global material_size = 0
global material_list_size = 0
global material_struc_size = 0
global matcount = 0
global facetype = 0 --0 is triangle list, 1 tri strip
global modulatemc = 0--modulate material color - write and blend the diffuse color if non-white
global geomsizepos = 0
global matlist_size_pos = 0
global flagspos
global count = 0
global geomarray = #()
global atomicarray = #()
global lightarray = #()
global dumarray = #()
global uvcount = 0
global uvpos = 0
global flags
global istextured
--global vars, from gui
global flipnorm
global geomflagpos
global geomflagprelight
global geomflagnormals
global geomflaglighting
--geometry flags, value it adds if true
global geotristrip = false --0x01
global geopos = false --always on?? 0x02 (default) write objects @ 0,0,0 if so!
global geotex = false --0x04. if this is false, no UV coords are written, unless its UV2, then both are. its false if there is no diffusemap on any of the materials for this geometry.
global geoprelit = false --0x08
global geonormals = false --0x10
global geolight = false --0x20
global geomodulate = false --0x40 (on if diffuse col != 255,255,255)
global geotex2 = false --0x7c (124. should add up to 128d, but the other 4 bytes are used by geotex). if geotex2 is true, it cancels out
--geotex and modulate, setting their flags to false.
--bassic rw sects
global rwvers
global struc = 0x00000001
global str = 0x00000002
global ext = 0x00000003
global texture = 0x00000006
global mat = 0x00000007
global matlistsect = 0x00000008
global frmlist = 0x0000000e
global geom = 0x0000000f
global clump = 0x00000010
global rwlight = 0x00000012
global atomic = 0x00000014
--txd stuff
global texnative = 0x00000015 --compressed txd'a are just dds files sans header, dds plugins already exist for max w/source, gotta be a way to combine them..
global texdic = 0x00000016
--end txd stuff
--extended rw sects
global geomlist = 0x0000001a
global animanim = 0x0000001b --sa only
global righttorender = 0x0000001f
global uvanimdict 0x0000002B --sa only
global matfx = 0x00000120
global skinplg 0x00000116
global uvanim = 0x00000135 --sa only
global hanim = 0x0000011E
global binmesh = 0x0000050e
global saspecmat = 0x0253f2f6 --sa only
global gtalight = 0x0253f2f8 --sa only
global colext = 0x0253f2fa --sa only
global sarefmat = 0x0253f2fc --sa only
global binmesh_ext = 0x0253f2fd --sa only
global frame = 0x0253f2fe
--end global variables

fn writelastext =
(
	--write the last ext
	writelong dffstream ext
	writelong dffstream 0
	writelong dffstream rwvers
	filesize = filesize + 12
)

fn closeit =
(	
	fseek dffstream 0x04 #seek_set
	writelong dffstream filesize --dont need to allocate more space for this, was done at the begining
	end = timeStamp()
	format "Export took % seconds\n" ((end - start) / 1000.00)
	format "Clump size % bytes\n" (filesize)
	fclose dffstream
	filesize = 0 --reset the clump size so it reports correctly on multiple exports
)


fn writeatomic obj = 
(	--atomic data links a geometry to a frame. one atomic is added per geometry
	--print obj.name
	--print selection.count
	ext = 3
	geomframeindex = 0
	meshindex = 0
	for obj in selection do
	(
		--(	
			--find the frame and geometry indexes. make sure its geometry only!
		--)
		if superclassof obj == GeometryClass then
		(
			framesel = selection as array
			meshin = finditem atomicarray (obj) --mesh index
			blob = (meshin - 1)
			framein = finditem framesel (obj) --frame index
			hooty = framein - 1
			meshindex = blob
			geomframeindex = hooty
			atomicsize = 0
			atomic_struc_size = 0
			--write the atomic data
			writelong dffstream atomic
			atomic_size_pos = ftell dffstream --set the position for the atomic size
			writelong dffstream atomicsize
			writelong dffstream rwvers
			filesize = filesize + 12
				--then write the struct for the atomic fata
			writelong dffstream struc
			atomic_struc_size_pos = ftell dffstream --set the position for the atomic struc size
			writelong dffstream atomic_struc_size
			writelong dffstream rwvers --that ends the head data, now add the actual info
			writelong dffstream geomframeindex
			writelong dffstream meshindex
			writelong dffstream 5 --this is unknown, but always 5
			writelong dffstream 0 --also unknown, always 0
			filesize = filesize + 28
			atomicsize = atomicsize + 28
			atomic_struc_size = atomic_struc_size + 16
			--then write the ext. theres one more "ext" that closes the file, we'll write that in its own section
			writelong dffstream ext
			writelong dffstream 0 --this is always 0 bytes
			writelong dffstream rwvers
			filesize = filesize + 16
			atomicsize = atomicsize + 12 --struc size isnt updated
			
			--if the geometry this atomic links to has material effects in ANY of the submats, another section is written here!
			--also a "right to render" section? (bike.dff)
			
			--go back and do the sizes		
			--atomic
			atomic_end_pos = ftell dffstream --get the current position
			fseek dffstream atomic_size_pos #seek_set --reset the pointer, and write again!
			writelong dffstream atomicsize
			fseek dffstream atomic_end_pos #seek_set
			--struct
			struc_end_pos = ftell dffstream --get the current position
			fseek dffstream atomic_struc_size_pos #seek_set --reset the pointer, and write again!
			writelong dffstream atomic_struc_size
			fseek dffstream struc_end_pos #seek_set
		)
	)
writelastext()
)

fn matsplit obj matcount = --matsplit = binmesh. need to make sure it only operating on the current object in the selection!
(
	--format "Material Count %\n" (matcount) --just to make sure the object was passed correctly
	--write the material Extension that will hold the material split
	facecount = obj.numfaces
	vertcount = obj.numverts
			(
			--add check here for if mat split is necessary? will always be, since there is always atleast one material.
			--declare the fucking variables
			extsize = 0
			--facetype is declared globally
			splitsize = 0
			splitcount = 0--will need to change to match num multisub
			indexcount = facecount * 3  --for the section, theres another one for each spit as well
			--write the fucking ext
			writelong dffstream ext
			extext_size_pos = ftell dffstream --get the current section position for the material list size
			writelong dffstream extsize
			writelong dffstream rwvers
			geomlist_size = geomlist_size + 12 --increment the geomtry list size
			actual_geomsize = actual_geomsize + 12
			filesize = filesize + 12
			--write the binmesh header info
			writelong dffstream binmesh
			splitsize_pos = ftell dffstream
			writelong dffstream splitsize
			writelong dffstream rwvers
			--write the binmesh geom info
			writelong dffstream facetype
			splitcount_pos = ftell dffstream
			writelong dffstream splitcount
			writelong dffstream indexcount
			geomlist_size = geomlist_size + 24 --increment the geomtry list size
			actual_geomsize = actual_geomsize + 24	
			filesize = filesize + 24
			extsize = extsize + 24
			splitsize = splitsize + 12
			
			mtl = obj.material
			
			count1 = 1 --gonna use this variable as the master splitcount
			
			if classof mtl == Standarmaterial then
				(
					count1 = 1 --always gonna have atleast one material.
				)
			
			if classof mtl == Multimaterial then
				( 
					--count1 = mtl.numsubs --need atleast one split
					--should be using the actual number of materials on the object, not the numsubs in a multimat!
					count1 = matcount
				)
			
			splitid = 0
			splitcount  = count1
			
			objmat = obj.material --will assume multi sub for this
			objfaces = obj.numfaces
			objverts = obj.numverts
			--nummats = objmat.numsubs --outdated. see material checking code!
			nummats = matcount
			idcount = 1
			theid = 1
			--end matsplit section header
			
			local matsplitfacearray = #()
			for g=1 to matcount do
			(
				for f=1 to objfaces do
				(
					faceindices = getface obj f
					append matsplitfacearray f
				)
				
				tempar = #()
						
				for mface in matsplitfacearray do
				( --BAFC, "f" is always 0. also, index is 0-based in RW, not 1 like in Max
					matid = getFaceMatID obj mface
					if matid == theid then --if faceid is not 0, should always be true
					(
						append tempar mface
					)
				)
				faceindexcount = tempar.count * 3
				writelong dffstream faceindexcount
				writelong dffstream (theid - 1) --material the faces of these vertices is assigned to
				
				extsize = extsize + 8
				splitsize = splitsize + 8
				geomlist_size = geomlist_size + 8 --increment the geomtry list size
				actual_geomsize = actual_geomsize + 8
				filesize = filesize + 8
				
				for splittri in tempar do
				(
					face = getface obj splittri
					matid = getFaceMatID obj splittri
					writelong dffstream (face.x - 1) --these need to start @ 0, not 1 (see for loop)
					writelong dffstream (face.y - 1)
					writelong dffstream (face.z - 1)
					splitsize = splitsize + 12
					extsize = extsize + 12
					geomlist_size = geomlist_size + 12 --increment the geomtry list size
					actual_geomsize = actual_geomsize + 12
					filesize = filesize + 12
				)
				--empty arrays
				matsplitfacearray = #()
				tempar = #()
				theid = (theid + 1)
			)
			
			--go back and fill in the header data
			--ext size
			binmeshextsize_pos = ftell dffstream --get the current position
			fseek dffstream extext_size_pos #seek_set --reset the pointer, and write again!
			writelong dffstream extsize
			fseek dffstream binmeshextsize_pos #seek_set	
			--ext binmesh struct size
			binmeshstruc_size_pos = ftell dffstream --get the current position
			fseek dffstream splitsize_pos #seek_set --reset the pointer, and write again!
			writelong dffstream splitsize
			fseek dffstream binmeshstruc_size_pos #seek_set
			--splitcount
			binmeshcount_pos = ftell dffstream --get the current position
			fseek dffstream splitcount_pos #seek_set --reset the pointer, and write again!
			writelong dffstream splitcount
			fseek dffstream binmeshcount_pos #seek_set
			
			--and once more for the ACTUAL geometry size
			currentpos_geomend = ftell dffstream --get the current position
			fseek dffstream geom_size #seek_set --reset the pointer, and write again! "geom_size" is 0!!
			writelong dffstream actual_geomsize
			fseek dffstream currentpos_geomend #seek_set	
			
			--geometry list size
			currentpos1 = ftell dffstream --get the current position
			fseek dffstream geomsizepos #seek_set --reset the pointer, and write again!
			writelong dffstream geomlist_size
			--format "Geometry List Size % bytes\n" (geomlist_size)
			fseek dffstream currentpos1 #seek_set	
				
			)
			--write a "Binmesh Ext" (0x253f2fd) section here if necessary
			--writeatomic(obj) --need to write atomic section as a separate chunk
			--set flags
		if geopos == true then
		(
			--add 0x02 to the flag
			flags = flags + 0x02
		)
		if geotex == true then
		(
			flags  = flags + 0x04
			uvcount = 1
		)
		if geoprelit == true then
		(
			flags  = flags + 0x08
		)
		if geonormals == true then
		(
			flags = flags + 0x10
		)
		if geolight == true then
		(
			flags = flags + 0x20
		)
		if geotex2 == true then
		(
			flags  = flags + 0x7c
			uvcount = 2
		)
		--once all the flags have been set (by this point they are) then go back and write them properly
		theflagpos = ftell dffstream --get the current position
		fseek dffstream flagspos #seek_set --reset the pointer, and write again!
		writeshort dffstream flags
		fseek dffstream theflagpos #seek_set
		--ooh, and write the UV count!
		uvflagpos = ftell dffstream --get the current position
		fseek dffstream uvpos #seek_set --reset the pointer, and write again!
		writeshort dffstream uvcount
		fseek dffstream uvflagpos #seek_set
)

fn matprops mtl obj = --mtl is the same output from both! woorddd
(
	--reset this shit (all of it) every time it loops to a new material
	material_size = 0
	material_struc_size = 0
	(
				matamb = 1
				matdif = 1
				matspec = 1
				--int2 = 239953508 --does the int actually make a difference? dif nums all seem to work. try it 0?
				int2 = 2021156196 --my digital signature, in hex this reads "dexx"!
				texcount = 0
				extsize = 0
				matR1 = 0
				matG1 = 0
				matB1 = 0
				matA1 = 0
				
				if mtl == undefined then
				(
					--messagebox "No materials asshole!"
					--return 0
				)
				
			--grab the material properties from the object, start with ambience...
			(
				--matamb = matambtot
				matamb = 1.0 --just hardcode it for now. no true equivalent in standarmaterial
				--format "Material Ambient (0-1) %\n" (matamb)
			)
			--now the diffuse
			(
				--matdif = matdiftot
				matdif = 1.0 --just hardcode it for now. no true equivalent in standarmaterial
				--format "Material Diffuse (0-1) %\n" (matdif)
			)
			--and finally the spec, for the mat params
			(
				mat_speclvl = mtl.specularlevel

				mat_speclvl = 100
				matspec = mat_speclvl / 100 --tell them not to set the fucking level over 100 though, or it might cause issues
				if matspec > 1.0 then
				(
					--messagebox "keep the spec level at 100 or less you fuck!" (note to self to watch Anger Management again)
					matspec = 1.0
				)
				--format "Material Specular (0-1) %\n" (matspec)
			)
			--now get the fucking colors, and alpha..
			(
				matcolR = 0
				matcolG = 0
				matcolB = 0
				matcol = mtl.diffuse
				matalpha = mtl.opacity * 2.55 --value is 0-100 in max, gotta multiply it to be 0-255
				matcolR = matcol.r
				matcolG = matcol.g
				matcolB = matcol.b
				matR1 = matcol.r
				matG1 = matcol.g
				matB1 = matcol.b
				matA1 = matalpha
				if mtl.diffuse != [255,255,255] then
				(
					geomodulate = true
					if geomodulate == true then
						(
							flags = 0
							flags = flags + 0x40
						)
				)
			)
			
			--last, but surely not least, grab the amount of textures in the diffuse channel, and the texture name. 
			difmap = ""
			difalphaname = ""
			refmap = ""
			bumpmap = ""
			specmap = "" --just incase i decide to mess with the spec settings
			--grab other texture info, filtering, tiling, etc
			filt1 = 6 --byte; 1 None/Point, 2 Summed Area/Linear, 6 Pyramidal/Anisotropic
			filt2 = 0 --byte; 0 if Pyramidal, 1 otherwise
			uflag = 0x01
			vflag = 0x10
			
			(
			difmapenable = mtl.diffusemapenable
			print difmapenable
			if difmapenable == false then texcount = 0
			--else if difmapenable == true then
			else
				(
					--use this space to grab the texture name?
					texcount = 1
					thetex = mtl.diffusemap
					if thetex == undefined then --if diffuse is enabled, but no texture is assigned
						(
							messagebox "No diffuse TextureMap in Material. Check Listener for details."
							format "No diffuse TextureMap assigned to %\n" ($.material.name) --check the material selected in the mat editor, but not teh object..
							return 0
							--its checking ALL the time. no good for transparent materials.
							--update: no, this is fine, since its only checking if the diffusemap is checked, but there's no image!
						)
					texname = getfilenamefile thetex.filename
					difmap = texname
					format "%\n" (difmap) 
					--need to get num characters in string
					difletcount = (difmap.count + 1) --rwstrings include the 0!
					
					--get filtering
					texfilter = thetex.filtering
					if texfilter == 0 then
					(
						filt1 = 6
					)
					else
					if texfilter == 1 then
					(
						filt1 = 2
					)
					else
					if texfilter == 2 then
					(
						filt1 = 1
					)
					
					--get UV mirror stuff, U
					if thetex.coordinates.u_mirror == true then
					(
						uflag = 0x02
					)
					else
					if thetex.coordinates.u_tile == true then
					(
						uflag = 0x01
					)					
					else
					(
						uflag = 0x03
					)
					
						--get UV mirror stuff, V
					if thetex.coordinates.v_mirror == true then
					(
						vflag = 0x20
					)
					else
					if thetex.coordinates.v_tile == true then
					(
						vflag = 0x10
					)					
					else
					(
						vflag = 0x30
					)
				)
			)
			--write the material header
			writelong dffstream mat
			material_size_pos = ftell dffstream --get the current section position for the material size
			writelong dffstream material_size
			writelong dffstream rwvers
			filesize = filesize + 12 --increment filesize
			geomlist_size = geomlist_size + 12 --increment the geomtry list size
			material_list_size = material_list_size + 12 --increment matlist size
			actual_geomsize = actual_geomsize + 12
			
				--material structure
				(
					writelong dffstream struc
					materialstruc_size_pos = ftell dffstream --get the current section position for the material size
					writelong dffstream material_struc_size
					writelong dffstream rwvers
					filesize = filesize + 12 --increment filesize
					geomlist_size = geomlist_size + 12 --increment the geomtry list size
					material_list_size = material_list_size + 12 --increment matlist size
					material_size = material_size + 12 --increment material size
					actual_geomsize = actual_geomsize + 12
				)
					--material info
					(
						writelong dffstream 0 --int1
						--writelong dffstream -1 --this will become the color of said mat
						writebyte dffstream matR1
						writebyte dffstream matG1
						writebyte dffstream matB1
						writebyte dffstream matA1
						writelong dffstream int2 --int 2
						writelong dffstream texcount --number of textures in this material
						writefloat dffstream matamb --material ambient
						writefloat dffstream matspec --material spec (0-1 in RW)
						writefloat dffstream matdif --material diffuse
						filesize = filesize + 28 --increment filesize
						geomlist_size = geomlist_size + 28 --increment the geomtry list size
						material_list_size = material_list_size + 28 --increment matlist size
						material_size = material_size + 28 --increment material size
						material_struc_size = material_struc_size + 28 --increment material struc size
						actual_geomsize = actual_geomsize + 28
					)
					
					--write texturemap information before the extension is written!
					if difmapenable then
					(
					--make sure i've written UV coords first!!
					local texsize = 0
					local texsect_sizepos
					local texstringonepos
					local texstringtwopos
					(--write texture section
						writelong dffstream texture --write type
						texsect_sizepos = ftell dffstream --get the current section position for the material size
						writelong dffstream texsize --write type size
						writelong dffstream rwvers --write type version
						(--increase sizes appropriately for tex section
							filesize = filesize + 12 --increment filesize
							geomlist_size = geomlist_size + 12 --increment the geomtry list size
							actual_geomsize = actual_geomsize + 12
							material_list_size = material_list_size + 12 --increment matlist size
							material_size = material_size + 12 --increment material size
						)
					)
					
					(--write texture struct data
						writelong dffstream struc
						writelong dffstream 4
						writelong dffstream rwvers
						(
								texsize = (texsize + 12) --4*3sections
						)
						
						(--write struct data here
						--writelong dffstream 0x1106
						writebyte dffstream filt1
						writebyte dffstream (uflag + vflag)
						writebyte dffstream filt2
						writebyte dffstream 0
							(--increase size appropriately
								texsize = (texsize + 4)
							)
						)--end tex struct
						
						(--string1, main texture name
							writelong dffstream str
							writelong dffstream difletcount --needs to be number of letter in string!
							writelong dffstream rwvers
							(
								texsize = (texsize + 12) --4*3sections
							)
							--write string
							(
								writestring dffstream difmap --"bodyCompleteMap"
								texstringonepos = ftell (dffstream) --set position directly after text, to write over the "0" it appends
								texsize = (texsize + difletcount) --number of characters
							)
						)--end main texname
						
						(--texture alphaname
							writelong dffstream str
							writelong dffstream 4
							writelong dffstream rwvers
							(
								texsize = (texsize + 12)
							)
							writelong dffstream 0
							(--increase size appropriately
								texsize = (texsize + 4)
							)
						)--end tex alpha name
						
						(--final extension
							writelong dffstream ext
							writelong dffstream 0 --extensions like this should be 0 bytes
							writelong dffstream rwvers
							(
								texsize = (texsize + 12)
							)
						)--end final extension
						
					)--end texture
					
					
					
					(--go back up update texsize
							curpos = ftell dffstream --get the current position
							fseek dffstream texsect_sizepos #seek_set --reset the pointer, and write again!
							writelong dffstream texsize
							fseek dffstream curpos #seek_set
							print "texsize"
							print texsize
							
							filesize = filesize + texsize --increment filesize
							geomlist_size = geomlist_size + texsize --increment the geomtry list size
							actual_geomsize = actual_geomsize + texsize --increment the actual geomtry section size
							material_list_size = material_list_size + texsize --increment matlist size
							material_size = material_size + texsize --increment material size
					)
					
					)					
					--once the mat info is written, need to add the ext..
						writelong dffstream ext --wite the extension section type
						writelong dffstream extsize --0, unless there are material effects
						writelong dffstream rwvers
						(						
							filesize = filesize + 12 --increment filesize						
							geomlist_size = geomlist_size + 12 --increment the geomtry list size
							material_list_size = material_list_size + 12 --increment matlist size
							material_size = material_size + 12 --increment material size
							actual_geomsize = actual_geomsize + 12
							--material_struc_size = material_struc_size + 12 --increment material struc size, if ext is 0 bytes, the section doesnt increment the material size
						)
						
						--if any material effects, this is the place to write them!
						(
							--also if mat effects are not NULL, then need to write a MatFx to the atomic as well
						)
						
						--update filesize
						lastwrite = ftell dffstream --get the current section position
						fseek dffstream 0x04 #seek_set
						writelong dffstream filesize --dont need to allocate more space for this, was done at the begining
						fseek dffstream lastwrite #seek_set
						
						--geometry list size
						currentpos1 = ftell dffstream --get the current position
						fseek dffstream geomsizepos #seek_set --reset the pointer, and write again!
						writelong dffstream 652--geomlist_size
						--format "Geometry List Size % bytes\n" (geomlist_size)
						fseek dffstream currentpos1 #seek_set
						
						--material list size
						mymatlist_pos = ftell dffstream --get the current position
						fseek dffstream matlist_size_pos #seek_set --reset the pointer, and write again!
						writelong dffstream material_list_size
						--format "Material List Size % bytes\n" (material_list_size)
						fseek dffstream mymatlist_pos #seek_set
						
						--material size
						mymat_pos = ftell dffstream --get the current position
						fseek dffstream material_size_pos #seek_set --reset the pointer, and write again!
						writelong dffstream material_size
						--format "Material Size % bytes\n" (material_size)
						fseek dffstream mymat_pos #seek_set
						
						--material struc size
						mymatstruc_pos = ftell dffstream --get the current position
						fseek dffstream materialstruc_size_pos #seek_set --reset the pointer, and write again!
						writelong dffstream material_struc_size
						--format "Material Struct Size % bytes\n" (material_struc_size)
						fseek dffstream mymatstruc_pos #seek_set
						
						count = count + 1
	)
	if count >= matcount then
	(
	--count = 0
	--writeatomic() --its been going to the EOF after processing the first material!
	matsplit(obj)matcount
	)
)


fn checkmattype obj =
(
	--for obj in $ do --materials are only on geometry!!
	(
			--declare variables to be used here
			material_list_size = 0
			material_list_struct_size = 4 --this should alwasy be atleast 4, its a dword int, followed by -1 for each material
			--material specific parameters
			material_size = 0
			material_struc_size = 0
			matcount = 1 --one minimum, since there si ALWAYS SOME material applied
			--start writing the material list
			writelong dffstream matlistsect --write sect type matlist
			matlist_size_pos = ftell dffstream --get the current section position for the material list size
			writelong dffstream material_list_size --write material list size
			writelong dffstream rwvers
			filesize = filesize + 12 --increment filesize
			geomlist_size = geomlist_size + 12 --increment the geomtry list size
			actual_geomsize = actual_geomsize + 12 --increment the actual geomtry section size
			--start writing the material list structure
			writelong dffstream struc
			matstruc_list_size_pos = ftell dffstream --get the current section position for the material list size
			writelong dffstream material_list_struct_size --number of materials in the mat list struct
			writelong dffstream rwvers
			matstruc_matcount_pos = ftell dffstream
			writelong dffstream matcount
			matstruc_unknown = ftell dffstream
			writelong dffstream 0 --need to add -1 PER MATERIAL if its a multi sub, -1 by default if only one material
			filesize = filesize + 16 --increment filesize, but dont count the unknown yet!
			geomlist_size = geomlist_size + 16 --increment the geomtry list size
			actual_geomsize = actual_geomsize + 20 --increment the actual geomtry section size
			material_list_size = material_list_size + 16 --increment matlist size
			
			mtl = obj.material --grab the material from the current object in the selection
			if mtl == undefined then --critical error. pop up at all times. or use Wire color?
			(
				--write out a basic material, using the wirecolor as the diffuse, and setting everything else to Rw defaults.
				matprops(mtl)obj
				(
					messagebox "No materials applied to object"
					return 0
					--will want to come back later, and use the wire color as the diffuse color, and give it a basic material
				)
			--get the listener checkbox state
			if chk_error.state == true then
				(
					format "No material(s) applied to %\n" (obj.name)
				)
			)
			--done with object checking			
			else			
			if classof mtl == Standardmaterial then
			(
				--go back and update the count
				currentpos_matcount = ftell dffstream --get the current position
				fseek dffstream matstruc_matcount_pos #seek_set --reset the pointer, and write again!
				writelong dffstream 1 --only one material if its a standardmaterial
				fseek dffstream currentpos_matcount #seek_set
				
				currentpos_unknowns = ftell dffstream --current pos
				fseek dffstream matstruc_unknown #seek_set --goto and write
				writelong dffstream -1
				fseek dffstream currentpos_unknowns #seek_set
				filesize = filesize + 4
				geomlist_size = geomlist_size + 4
				actual_geomsize = actual_geomsize + 4
				geometrystrucsize = geometrystrucsize + 4
				material_list_size = material_list_size + 4 --increment matlist size
				material_list_struct_size = material_list_struct_size + 4
				
				--go back and update the size of the matlist struct
				currentpos_matlistsize = ftell dffstream --get the current position
				fseek dffstream matstruc_list_size_pos #seek_set --reset the pointer, and write again!
				writelong dffstream material_list_struct_size
				fseek dffstream currentpos_matlistsize #seek_set
				--this also updates the "unknown count" in the mat list struct				
				--format "Material Type %\n" (mtl)
					matprops(mtl)obj
				--fclose dffstream
				--from here, force the matsplit to be 1 since it has no subs
			)
			--end of standardmaterial
			else if classof mtl == Multimaterial then
			(
				local thenummats = #()
				local thematindex = #(-1)
				--nummats = mtl.numsubs
				--^^ this code, is incorrect!
				(
				facecount = obj.numfaces
				for f=1 to facecount do
				( --BAFC, "f" is always 0. also, index is 0-based in RW, not 1 like in Max
					faceindices = getface obj f
					matid = getFaceMatID obj f
					append thenummats matid
					if matid != 0 then --if faceid is not 0, should always be true
					(
						if thematindex.count != 0 then
						(
							for m=1 to thematindex.count do --check the array
							(
								b = finditem thematindex matid
								if b == 0 then		
								(
									--if it  can't find the item, it needs to be appended.
									(
										append thematindex matid
									)
								)
								--else print "b is undefined (array == 0)"
								--this is returning true on the default value
							)
						)
						else
						(
							print "index is empty"
						)
					)
				)
				deleteitem thematindex 1
				themin = amin thenummats
				themax = amax thenummats
				--print "MatIndex"				
				--thenummats = #()
				--thematindex = #(-1)
			)
				thenummats = thematindex.count
				thematcount = thematindex.count
				matcount = thematcount --<-- do not delete!! will corrupt material export
				print thematcount
				--print "mat Count"
				--messagebox (thematindex.count as string)
				
				--go back and update the count
				currentpos_matcount = ftell dffstream --get the current position
				fseek dffstream matstruc_matcount_pos #seek_set --reset the pointer, and write again!
				writelong dffstream thematcount
				fseek dffstream currentpos_matcount #seek_set
				--this also updates the "unknown count" in the mat list struct as well, 4 bytes per material
 				
				currentpos_unknowns = ftell dffstream --current pos
				fseek dffstream matstruc_unknown #seek_set --goto and write
				temp = 0
				for unk=1 to matcount do
				(
					writelong dffstream -1
					filesize = filesize + 4
					geomlist_size = geomlist_size + 4
					actual_geomsize = actual_geomsize + 4
					geometrystrucsize = geometrystrucsize + 4
					material_list_size = material_list_size + 4 --increment matlist size
					material_list_struct_size = material_list_struct_size + 4
					temp = temp + 4
					if temp >= 8 then
					(
						currentpos_unknowns = currentpos_unknowns + 4
						print temp
					)
				)
				fseek dffstream currentpos_unknowns #seek_set
				
				--go back and update the size of the matlist struct
				currentpos_matlistsize = ftell dffstream --get the current position
				fseek dffstream matstruc_list_size_pos #seek_set --reset the pointer, and write again!
				writelong dffstream material_list_struct_size
				fseek dffstream currentpos_matlistsize #seek_set
				--this also updates the "unknown count" in the mat list struct
				
				--format "Material Type %\n" (mtl) --mutli materials seem to automatically tell you the type of submats...
				--format "Sub Materials %\n" (thenummats)
				--now try to get each submat in the multi
				matlist = mtl.materialList
				--for mat in matlist do
				
				if matlist.count != thematcount then --if the number of materials in the multisub, isn't the same as the num applied to the object
				(
					materror = "Material '" + mtl.name + "' has the incorrect number of sub-materials. See the help file for instructions."
					Messagebox materror --then output this critical error. unused materials waste space/memory!
					--messagebox (thematcount as string)
					return 0
				)
				
				for mtl in matlist do
				--collect the materials into an array, then export the first X number of materials
					(
						--for every material in the material list, check ITS type as well!
						--mtl = mat
							--matprops(mtl)obj --get the properties, only for every material in the multi sub
						matprops(mtl)obj
						--fclose dffstream
					)
			)
		)
)

fn dogeom = 
(
	for obj in $ do
	--int "geom array count"
	--print geomarray
	--for obj in geomarray do
	if superclassof obj != GeometryClass then
	(
		--fughedaboutit!
	)
	else
	(
		
	--now to do object specific stuff
	flags = 0x00 --0x72 for the model im examining
	--will add it up correctly with flag params
	geomsize = 0
	strucsize = 0
	facecount = 0
	vertcount = 0
	geomframecount = 1 --as in, number of frames in this geometry, should always be 1?
	uvcount = 0 --if 0, RW will NOT add uv coords!!!!
	-----blah
	actual_geomsize = 0
	actual_geomstructsize = 0 --need to reset it for every geometry!!
	--Geometry section, and so it begins
	writelong dffstream geom -- write the ACTUAL geometry section
	geom_size = ftell dffstream --get the current section position
	writelong dffstream actual_geomsize --size of said geometry section
	writelong dffstream rwvers --rw version
	filesize = filesize + 12
	geomlist_size = geomlist_size + 12
	--write the struct for the ACTUAL geometry section
	writelong dffstream struc
	geom_strucsize = ftell dffstream --get the current section position
	writelong dffstream actual_geomstructsize
	writelong dffstream rwvers
	filesize = filesize + 12
	geomlist_size = geomlist_size + 12
	actual_geomsize = actual_geomsize + 8 --this section was being written 4 bytes too big! 8 or 12?!?!?
	
	--time to write honest to god useful data! should i get the data first, or...
	flagspos = ftell dffstream --come back and write the flags
	writeshort dffstream flags --geometry flags
	uvpos = ftell dffstream --come back and write the UV count
	writeshort dffstream uvcount --num uv channels object is using
	face_count = ftell dffstream --come back and write the face count
	writelong dffstream facecount
	vertex_count = ftell dffstream --come back and write the vertice count
	writelong dffstream vertcount
	writelong dffstream geomframecount
	filesize = filesize + 16
	geomlist_size = geomlist_size + 16
	actual_geomsize = actual_geomsize + 16
	actual_geomstructsize = actual_geomstructsize + 16

--sort out dummy objects from being treated as a mesh
--no. in the begining, separate the objects by type, into arrays, then work within the arrays.
--or use a "for geometry" loop
--actual geometry data
	(
			facecount = obj.numfaces
			
			--if the geometry is textured, in rw36, UVs are the first set of data written
			--need material, check material diffusemap. if ANY material on the object has a diffusemap, ALL the vertices on the object have UVs!
			
			istextured = false
			
			--if prelighting is true, export vertex colora
			--add 0x08 to geom flags
			if geoprelit == true then
			(
				flags = flags + 0x08
				defaultVCFaces obj
				--buildVCFaces obj true --build all colors @ default
				format "Color Verts %\n" (getNumCPVVerts obj)
				for vcol = 1 to getNumVerts obj do
				--for vcol=1 to getNumFaces obj do
				(					
					vcolor = getVertColor obj vcol
					
					writebyte dffstream vcolor.r
					writebyte dffstream vcolor.g
					writebyte dffstream vcolor.b
					writebyte dffstream vcolor.a
					
					filesize = filesize + 4
					geomlist_size = geomlist_size + 4
					actual_geomsize = actual_geomsize + 4
					actual_geomstructsize = actual_geomstructsize + 4
				)
			)
			
			--export the UVs for now anyway
			if istextured = true then
			(
				--set the flag to true, be sure to reset it after this geometry though!
				(					
					geotex = true --even fucking reading this?
				)
				--get uv data
				format "Num UV Verts %\n" (getNumTVerts obj)
				--for dextri=1 to facecount do --old method
				for uv = 1 to getNumVerts obj do
				( 					
					--vertindices = getvert obj uv --(in coordsys local vertindices.x)
					uvw = getTVert obj uv
					
					--Note: should multiply these by the "Tiling" multiplier in the material!
					--except, there is no vertex-level material access, may not be worth effort for a more complex routine.
					
					writefloat dffstream uvw.x--(uvw.x-(uvw.x*2)) --vertex 1, U
					writefloat dffstream (uvw.y-(uvw.y*2)) --vertex 1, V (for some reason V is flipped. oleg has same problem in zmod one, but i;ll be damned if im flipping every texture vertically!)
					
					--increase the following section sizes appropriately
					filesize = filesize + 8
					geomlist_size = geomlist_size + 8
					actual_geomsize = actual_geomsize + 8
					actual_geomstructsize = actual_geomstructsize + 8
				)
			)--end if
			
			for f=1 to facecount do
				( --BAFC, "f" is always 0. also, index is 0-based in RW, not 1 like in Max
					faceindices = getface obj f
					fix = (faceindices.x - 1)
					fiy = (faceindices.y - 1)
					fiz = (faceindices.z - 1)					

					if flipnorm = false then
					(
						writeshort dffstream fix
						writeshort dffstream fiy
						writeshort dffstream 0	 -- <-- switch this one around?
						writeshort dffstream fiz
					)
					else
					(
						writeshort dffstream fiy
						writeshort dffstream fix
						writeshort dffstream 0	 -- <-- switch this one around?
						writeshort dffstream fiz
					)
					filesize = filesize + 8
					geomlist_size = geomlist_size + 8
					actual_geomsize = actual_geomsize + 8
					actual_geomstructsize = actual_geomstructsize + 8
					--go back and write the face count
					face_pos = ftell dffstream --get the current position
					fseek dffstream face_count #seek_set --reset the pointer, and write again!
					writelong dffstream facecount
					fseek dffstream face_pos #seek_set
				)
				
				--next is the bounding stuff per geometry
				(
				--location of bounding sphere, the radius, xyzr, float
				local objradius = 0
					(--radius
						--i have the diameter (max - min), now divide by 2. since the value is in xyz, ill grab the biggest of the 3.
						diam = (obj.max - obj.min)
						myradius = diam / 2
						if myradius.x > myradius.y then
						(
							if myradius.x > myradius.z then
							(
								objradius = myradius.x
							)
						)
						else
						if myradius.x > myradius.z then
						(	
							objradius = myradius.x
						)
						else
						if myradius.y > myradius.z then
						(
							objradius = myradius.y
						)
						else (objradius = myradius.z)
						--print radius
					)
					radIposx = obj.pos.x
					radIposy = obj.pos.y
					radIposz = obj.pos.z
					writefloat dffstream radIposx --temp x
					writefloat dffstream radIposy --temp y
					writefloat dffstream radIposz --temp z
					writefloat dffstream objradius --temp radius
					filesize = filesize + 16
					geomlist_size = geomlist_size + 16
					actual_geomsize = actual_geomsize + 16
					actual_geomstructsize = actual_geomstructsize + 16
				)
				--2 unknowns apparently.. -which are "1" in files i check, not 00!
				(
					writelong dffstream 1 --unknown int 1
					writelong dffstream 1 --unknown int 2
					filesize = filesize + 8
					geomlist_size = geomlist_size + 8
					actual_geomsize = actual_geomsize + 8
					actual_geomstructsize = actual_geomstructsize + 8
				)
		--and write the vertex positions
				vertcount = obj.numverts
				--print "Vertice Count" --in rw, cerain smoothing angles, will create new vertices. not in my exporter, yet.
				--but i may need to implement that at a later time, in order to achieve the same resutls ingame, as i have in my scene.
				--print vertcount
				oldpos = obj.pos
				--move obj [0,0,0]
				obj.pos.x = 0
				obj.pos.y = 0
				obj.pos.z = 0
				for v = 1 to getNumVerts obj do
				(
					vertindices = getvert obj v --(in coordsys local vertindices.x)
					--vpx = (in coordsys local vertindices.x) --"local" - not necessary?
					--vpy = (in coordsys local vertindices.y)
					--vpz = (in coordsys local vertindices.z)
					vpx = vertindices.x
					vpy = vertindices.y
					vpz = vertindices.z
					writefloat dffstream vpx --temp vert x --export vertices in local coordsys (vert pos relative to local axis)
					writefloat dffstream vpy --temp vert y
					writefloat dffstream vpz --temp vert z
					filesize = filesize + 12
					geomlist_size = geomlist_size + 12
					actual_geomsize = actual_geomsize + 12
					actual_geomstructsize = actual_geomstructsize + 12
					--go back and write the vertex count
					vert_pos = ftell dffstream --get the current position
					fseek dffstream vertex_count #seek_set --reset the pointer, and write again!
					writelong dffstream vertcount
					fseek dffstream vert_pos #seek_set
				)
				obj.pos.x = oldpos.x
				obj.pos.y = oldpos.y
				obj.pos.z = oldpos.z
				--write the normal data for each vertex. need to invert, apply modifier to snapshot, then delete
						for n = 1 to getNumVerts obj do
							(
								normindices = (getNormal obj n)
								normzd = normalize normindices --normalized! wooo!!
								vnx = normzd.x --need to be inverted?
								vny = normzd.y
								vnz = normzd.z
								if flipnorm == true then
									(
										--print flipnorm
										if vnx != 0 then --if vector is not 0
										(
											vnx = (vnx - (vnx * 2))
										)
										if vny != 0 then
										(
											vny = (vny - (vny * 2))
										)
										if vnz != 0 then
										(
											vnz = (vnz - (vnz * 2))
										)
									)
								writefloat dffstream vnx--(vnx - (vnx * 2)) --temp normal x
								writefloat dffstream vny --temp normal y
								writefloat dffstream vnz --temp normal z
								filesize = filesize + 12
								geomlist_size = geomlist_size + 12
								actual_geomsize = actual_geomsize + 12
								actual_geomstructsize = actual_geomstructsize + 12
							)
						--update filesize
						lastwrite = ftell dffstream --get the current section position
						fseek dffstream 0x04 #seek_set
						writelong dffstream filesize --dont need to allocate more space for this, was done at the begining
						fseek dffstream lastwrite #seek_set
						
						--and once more for the ACTUAL geometry size
						currentpos_geomend = ftell dffstream --get the current position
						fseek dffstream geom_size #seek_set --reset the pointer, and write again!
						writelong dffstream actual_geomsize
						fseek dffstream currentpos_geomend #seek_set
						
						--and once more for the geometry struc size
						currentpos_geom_struc_end = ftell dffstream --get the current position
						fseek dffstream geom_strucsize #seek_set --reset the pointer, and write again!
						writelong dffstream actual_geomstructsize
						fseek dffstream currentpos_geom_struc_end #seek_set
						
						--geometry list size
						currentpos1 = ftell dffstream --get the current position
						fseek dffstream geomsizepos #seek_set --reset the pointer, and write again!
						writelong dffstream geomlist_size--geomlist_size
						fseek dffstream currentpos1 #seek_set
				)
				checkmattype(obj)
		) --for obj
) --end of geom sect

fn dogeomlist =
(
	--initialize local variables
	--geomlistsectsize = 0 --done globally
	geomlist_size = 0
	geomliststrucsize = 4
	actual_geomsize = 0
	actual_geomstructsize = 0
	--write the section type
	writelong dffstream geomlist
	geomsizepos = ftell dffstream --get the current section position
	--print "Geometry List Size pointer is"
	--print geomsizepos
	writelong dffstream geomlist_size
	writelong dffstream rwvers
	filesize = filesize + 12
	--now do the geomstry list struct
	writelong dffstream struc
	writelong dffstream geomliststrucsize --should always be 4
	writelong dffstream rwvers
	writelong dffstream geometry.count --should only be writing the amount of geometry in the selection
	filesize = filesize + 16
	geomlist_size = geomlist_size + 16
	--geometry list size
	currentpos1 = ftell dffstream --get the current position
	fseek dffstream geomsizepos #seek_set --reset the pointer, and write again!
	writelong dffstream geomlist_size--geomlist_size
	--format "Geometry List Size % bytes\n" (geomlist_size)
	fseek dffstream currentpos1 #seek_set
)

fn doframenames = 
(
	for obj in $ do
		(				--add geometry to geom array. will be used later
			if superclassof obj == geometryclass then
				(
					append geomarray obj
					--print "Appended"
				)
				else(print "Not Appended")		
		
			beginpos = ftell dffstream --get the current section position	
			--write the header, declare sizes first, and reset them on each pass
			extsize = 0 --extension size			
			framesize = 0 --frame size = char.count in string
			
			--then set up the necessary pointers..			
			( --do ext size
			writelong dffstream ext --frame name extension section type
			framelistsize = framelistsize + 4
			extpos = ftell dffstream --get the current file position
			writelong dffstream extsize -- write extension size, will come back to this
			filesize = filesize + 8 --increment the global filesize
			framelistsize = framelistsize + 4 --increment the Frame List Section Size
			writelong dffstream rwvers
			filesize = filesize + 4 --increment the global filesize
			framelistsize = framelistsize + 4 --increment the Frame List Section Size
			)			
			
			(--now need frame type,  size
			writelong dffstream frame
			framelistsize = framelistsize + 4
			framepos = ftell dffstream --get the current file position
			writelong dffstream framesize
			extsize = extsize + 8 --increment the extension size
			framelistsize = framelistsize + 4 --increment the Frame List Section Size
			writelong dffstream rwvers
			filesize = filesize + 12 --increment the global filesize
			extsize = extsize + 4 --increment the extension size
			framelistsize = framelistsize + 4 --increment the Frame List Section Size
			)
			
			lettercount = obj.name.count
			letcnt --dont assign a value to this!
			writestring dffstream obj.name
			filesize = filesize + lettercount --increment the global filesize
			extsize = extsize + lettercount --increment the extension size
			framesize = framesize + lettercount --increment the extension size
			framelistsize = framelistsize + lettercount --increment the Frame List Section Size
			
			--oh yea, max adds a 1-byte garabage character at the end of strings! gotta correct that..	
			filepos = ftell dffstream --get the current file position			
			if filepos == undefined then
				(
					messagebox "File position undefined. Re-run script"
					fclose dffstream
					return 0
				)
			else
			
			filepos1 = filepos - 1
			fseek dffstream filepos1 #seek_set --reset the pointer to be one space back, and write again!
			secpos = ftell dffstream --get the current section position
			--now write the ext size
			fseek dffstream extpos #seek_set --reset the pointer to be at the ext size, and write again!
			--print "Resetting pointer position (extension)"
			writelong dffstream extsize
			fseek dffstream secpos #seek_set --reset the pointer again!
			--now write the frame size
			fseek dffstream framepos #seek_set --reset the pointer to be at the ext size, and write again!
			--print "Resetting pointer position (frame)"
			writelong dffstream framesize
			--go back to the end of this section
			fseek dffstream secpos #seek_set --reset the pointer again!
			--fseek 
					)
		here = ftell dffstream --grab current position
		fseek dffstream frmlistsizepos #seek_set --reset the pointer to be at the section size, and write again!
		--print "Resetting pointer position (framelist size)"
		writelong dffstream framelistsize		
		fseek dffstream here #seek_set
)


fn doframelist =
(
	framecount = 0	
	if $ == undefined then --make damn sure something is selected!
	(
		messagebox "Select objects to export!"
		return 0
	)	
	else
	for i in $ do
		(
			framecount = selection.count
		)
		local sectsize = (54 * framecount) + 4
		--local framelistsize = 0 --declared globally
		parfrm = 00 --default frame value 
		strucsize = 0
		--write the frame list header
		writelong dffstream frmlist --frame list section type

		( --do framelist size
			frmlistsizepos = ftell dffstream --get the current file position
			writelong dffstream 0 -- frame list size
		)

		writelong dffstream rwvers
		
		(--do struc size
			writelong dffstream struc --struct section type
			strucpos = ftell dffstream --get the struc position
			writelong dffstream sectsize -- struct size
			framelistsize = framelistsize + 12
		)

		writelong dffstream rwvers --rw version
		writelong dffstream framecount
		filesize = filesize + 28 --increment the global filesize
		framelistsize = framelistsize + 4 --increment the local section size. not everything gets incremented for the framelist!!
		--only the framecount, 4 bytes, should increment the framelist size.
		if $ == undefined then
		(
			messagebox "Select an object(s) to export"
			return 0
		)

		else
		
		for obj in selection do
		(
		
			objTransformR1X = obj.transform.row1.x
			objTransformR1Y = obj.transform.row1.y
			objTransformR1Z = obj.transform.row1.z
			
			objTransformR2X = obj.transform.row2.x
			objTransformR2Y = obj.transform.row2.y
			objTransformR2Z = obj.transform.row2.z
			
			objTransformR3X = obj.transform.row3.x
			objTransformR3Y = obj.transform.row3.y
			objTransformR3Z = obj.transform.row3.z
	
			--objPosXS = obj.pos.x * exportscale --scale this or the matrix?
			if superclassof obj == GeometryClass then
			(
				objPosX = (in coordsys parent obj.pos.x)
				objPosY = (in coordsys parent obj.pos.y)
				objPosZ = (in coordsys parent obj.pos.z)
			)
			else
			(
				if obj.parent != undefined then
				(
					objPosX = obj.pos.x
					objPosY = obj.pos.y
					objPosZ = obj.pos.z
				)
				else
				(
					objPosX = 0
					objPosY = 0
					objPosZ = 0
				)
			)
			
			theparent = obj.parent
			(
			--do parent object checking
			if obj.parent == undefined then
				(
					parfrm = -1
				)
			else --if the frame doesnt match the above conditions
			(
				namearray = selection as array
				--need to match the object name, with its index
				--parfrm = finditem namearray obj - 2 --we subtract 2, because max uses 1-based indexes, but rw uses -1 one based
				parfrm = finditem namearray theparent - 1
			)
		)
		--write the framelist data
			--going to have to redo this section, so it makes one pass, calculating the section size, 
			--then another, where it actually does everything, then writes it to a file
			sizeincrease = 0
			WriteFloat dffstream objTransformR1X
			WriteFloat dffstream objTransformR1Y
			WriteFloat dffstream objTransformR1Z
			sizeincrease = sizeincrease + 12
			WriteFloat dffstream objTransformR2X
			WriteFloat dffstream objTransformR2Y
			WriteFloat dffstream objTransformR2Z
			sizeincrease = sizeincrease + 12
			WriteFloat dffstream objTransformR3X
			WriteFloat dffstream objTransformR3Y
			WriteFloat dffstream objTransformR3Z
			sizeincrease = sizeincrease + 12
			--position. seems to be some debate how to do this. with the geompos flag set, geometry is exported @ 0,0,0, and derives its position from its parent
			--positions are relative to their parent objects. handled a few lines up
			
			writefloat dffstream objPosX
			writefloat dffstream objPosY
			writefloat dffstream objPosZ
				
			sizeincrease = sizeincrease + 12
			writelong dffstream parfrm
			if obj.parent == undefined then
			(
				writelong dffstream frmlstint
			)
			else
			writelong dffstream 3 --also seen as 0
			sizeincrease = sizeincrease + 8
	
			filesize = filesize + sizeincrease --increment the global filesize
			framelistsize = framelistsize + sizeincrease --increment the local section size
			strucsize = strucsize + sizeincrease --increment strucsize
			)
			secpos = ftell dffstream --get the current section position
			--now write the struc size
			fseek dffstream strucpos #seek_set --reset the pointer to be at the struc size, and write again!
			--print "Resetting pointer position (struct)"
			strucsize = strucsize + 4
			writelong dffstream strucsize 
			--go back to the end of this section
			fseek dffstream secpos #seek_set --reset the pointer again!
			--doframenames() --see gui
)




fn objcount =
(
local secsize
secsize = 4*3
if geomcount == 0 then int1 = 1 --if there are no geometries in the scene, the 2nd integer changes..
else
writelong dffstream struc
writelong dffstream secsize
writelong dffstream rwvers
writelong dffstream geomcount
writelong dffstream int1
writelong dffstream int2
filesize = filesize + 20 --i was adding 4 bytes to many, this should fix it?
--doframelist() --see gui
)

fn doclump dfffile rwvers=
(	
	start = timeStamp()
	geomcount = geometry.count
	lightcount = lights.count
	helpercount = helpers.count
	format "Geometric objects in scene: %\n" geomcount
	format "Light objects in scene: %\n" lightcount
	format "Helper objects in scene: %\n" helpercount	
	
	--open file, create clump header
	print dfffile
	print rwvers
	filesize = 0
	dffstream=fopen dfffile "wb"
	writeLong dffstream clump
	writelong dffstream filesize
	writelong dffstream rwvers
	--end clump info
	
	--thearray = rootnode.children as array
	sceneobjects = selection as array

	for obj in selection do
	(
		if superclassof obj == GeometryClass then
		(
			append geomarray obj
			append atomicarray obj
		)
		else
		if superclassof obj == light then
		(
			append lightarray obj
		)
		else
		if superclassof obj == helper then
		(
			append dumarray obj
		)
	)

	deleteItem geomarray 1 --it auto creates a duplicate for some reason. probably because the indexes are 1-based

)

fn setflags flipnorm geomflagpos geomflagprelight geomflagnormals geomflaglighting =
(
		--get geometry flags from gui
		----------geometry position flag
		if geomflagpos == true then
		(
			geopos = true
		)
		else if geomflagpos == false then
		(
			geopos = false
		)
		----------prelight flag
		if geomflagprelight == true then
		(
			geoprelit = true
		)
		else if geomflagprelight == false then
		(
			geoprelit = false
		)
		----------normals flag
		if geomflagnormals == true then
		(
			geonormals = true
		)
		else
		(
			geonormals = false
		)
		----------lighting flag
		if geomflaglighting == true then
		(
			geolight = true
		)
		else
		(
			geolight = false
		)
)