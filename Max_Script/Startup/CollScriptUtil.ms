-------------------------------------------------------------------------------
--	GTA Collision Script Exporter/Importer
--	Version 1.5 / 22. 07. 2004
--
--	© 2002-2004 by Steve M.
--	Email: support@steve-m.com
--	Web: http://www.steve-m.com
-------------------------------------------------------------------------------

utility COLL "GTA CollScript Utility"
(
	label note "Read CollScriptUtil.txt first!!!" offset:[-12,0]
		
	group " Export Collision Script "
	(
		button prepare "Prepare" toolTip:"Set rotation of gizmos to 0" across:2 width:63
		button make_file "Export" toolTip:"Export object data as text file" width:63
	)
	
	group " Import Collision Script "
	(
		button get_file "Import" toolTip:"Import object data from text file" width:130
	)
	
	group " Surface Types "
	(
		radiobuttons sur_method "Import/export..." labels:#("sliding friction*", "material ID", "disable/default") default:1
		label lblStar "* export only" align:#center offset:[-14,-6]
		dropdownlist defsur "Default / Boxes && Spheres:" items:#("[00] Standard", "[01] Street", "[02] Grass", "[03] Soil", "[04] Dirt", "[05] Beton", "[06] Aluminum", "[07] Glas", "[08] Metal Pole", "[09] Door", "[10] Metal Sheet", "[11] Metal", "[12] Small Metal Post", "[13] Large Metal Post", "[14] Medium Metal Post", "[15] Steel", "[16] Fence", "[17] ? X", "[18] Sand", "[19] Water", "[20] Wooden Box", "[21] Wooden Lathes", "[22] Wood", "[23] Metal Box", "[24] Metal Box", "[25] Hedge", "[26] Rock", "[27] Metal Container", "[28] Metal Barrel", "[29] ? X", "[30] Metal Card Box", "[31] ?", "[32] Gate/Bars", "[33] Sand 2 (VC)", "[34] Grass 2 (VC)")
		label lbl99 "(value 99 disables export)" align:#center
	)
	
	group " About "
	(
		label LabelA "CollScript Utility"
		label LabelB "Version 1.5"
		label LabelC "© 2002-2004 by Steve M."
		label LabelD "http://www.steve-m.com"
	)
	
	on prepare pressed do
	(
		--global obj
		for obj in helpers do
			if (iskindof obj SphereGizmo) or (iskindof obj BoxGizmo) then
			(
				--obj.rotation.x_rotation = 0
				--obj.rotation.y_rotation = 0
				--obj.rotation.z_rotation = 0
				obj.rotation = obj.parent.rotation
			)
	)			
	
	on make_file pressed do
	(
		--COL = getSaveFileName types:"Collision Script (*.cst)|*.cst" 
		--if COL != undefined then
		
		s_path = getSavePath caption:"Select .cst Export Directory"		
		if s_path != undefined then
		(
			for colobj in selection do if ((not iskindof colobj helper) or (colobj.children.count>0)) then -- only allow helpers with children
			--if (iskindof colobj editable_mesh) then
			(				
			    local colname = s_path+"\\"+colobj.name+".cst"
				format "Exporting % to % ...\n" colobj.name colname
				col = createFile (colname)
				format "# GTA Collision Script Exporter version 1.5 by Steve M.\n# Web: http://www.steve-m.com   E-Mail: support@steve-m.com\n# Exported %\n\n" localtime to:col
			
				local oldtrans = colobj.transform
				colobj.transform = identity colobj.transform
			
				format "=> Spheres:\n" to:col
				local n = 0
				for obj in helpers do
					if (iskindof obj SphereGizmo) and (obj.parent==colobj) then
					(
						format "S %: %  |  %; %; %  |  [%]\n" n obj.radius obj.pos.x obj.pos.y obj.pos.z ((defsur.selection - 1) as integer) to:col
						n+=1
					)
				
				format "\n=> Boxes:\n" to:col
				n = 0
				for obj in helpers do
					if (iskindof obj BoxGizmo) and (obj.parent==colobj) then
					(
						format "B %: %; %; %  |  %; %; %  |  [%]\n" n (obj.pos.x-obj.width/2) (obj.pos.y-obj.length/2) (obj.pos.z) (obj.pos.x+obj.width/2) (obj.pos.y+obj.length/2) (obj.pos.z+obj.height) ((defsur.selection - 1) as integer) to:col
						n+=1
					)
			
				-- Make a copy of the object, convert it to editable mesh (if possible), and then restore the position of the original object
				obj = copy colobj
				ConvertToMesh obj
				colobj.transform = oldtrans
				
				if (iskindof obj editable_mesh) then
				(				
					format "\n=> Vertex Count: %\n" obj.numverts to:col
					for i = 1 to obj.numverts do
					(
						format "V %: %; %; %\n" (i-1) (obj.verts[i].pos.x) (obj.verts[i].pos.y) (obj.verts[i].pos.z) to:col
					)
					format "\n=> Face Count: %\n" obj.numfaces to:col
					for i = 1 to obj.numfaces do
					(
						local fp3 = getface obj i
						local sur = case sur_method.state of
						(	1: case (classof obj.material) of
							   ( Multimaterial:    abs obj.material[getFaceMatID obj i].slidingFriction*100
							     Standardmaterial: abs obj.material.slidingFriction*100
								 default:          defsur.selection-1
							   )
							2: (getFaceMatID obj i)-1
							3: defsur.selection-1
						)
						if (sur != 99) then -- don't export faces with value 99
						(	if (sur<0 or sur>34) then sur=0
							format "F %: %; %; %  |  [%]\n" (i-1) ((fp3.x - 1) as integer) ((fp3.z - 1) as integer) ((fp3.y - 1) as integer) (sur as integer) to:col
						)
					)				
				)
				-- delete the copy
				delete obj
				
				--obj.transform = oldtrans
				
				close col
			)
			else format "% not exported.\n" colobj.name
		)
	)	
	
	on get_file pressed do
	(
		COL = getOpenFileName types:"Collision Script (*.cst)|*.cst" 
		if COL != undefined then
		(		
			col = openFile COL
			
			local cverts = #()
			local cfaces = #()
			local cmats  = #()
			
			while not eof col do
			(
				ln = readline col
			
				if ln != "" then
				(
					data = filterString ln ":; |[]"
					case data[1] of
					(
						"S":(	-- Spheres
								local sg = SphereGizmo name:("Coll Sphere "+(data[2] as string))
								sg.radius = (data[3] as float)
								sg.pos.x = (data[4] as float)
								sg.pos.y = (data[5] as float)
								sg.pos.z = (data[6] as float)
							)
						"B":(	-- Boxes
								local bg = BoxGizmo name:("Coll Box "+(data[2] as string))
								bg.pos.x = ((data[6] as float)+(data[3] as float))/2
								bg.pos.y = ((data[7] as float)+(data[4] as float))/2
								bg.pos.z = ((data[8] as float)+(data[5] as float))/2
								bg.width = (data[6] as float)-(data[3] as float)
								bg.length = (data[7] as float)-(data[4] as float)
								bg.height = (data[8] as float)-(data[5] as float)
							)
						"V":(	-- Vertices
								append cverts [(data[3] as float),(data[4] as float),(data[5] as float)]
							)
						"F":(	-- Faces
								append cfaces [(data[3] as integer)+1,(data[5] as integer)+1,(data[4] as integer)+1]
								append cmats ((data[6] as integer)+1)
							)					
					)
				)			
			)
			close col
			
			if (cverts.count >= 3) and (cfaces.count >= 1) then 
			(
				local m
				if (sur_method.state==2) then
				(
				  m = mesh name:"Coll Mesh" vertices:cverts faces:cfaces materialIDs:cmats
				) else (
				  m = mesh name:"Coll Mesh" vertices:cverts faces:cfaces
				)
				for i=1 to m.numfaces do setFaceSmoothGroup m i 0
				update m
			)
		)
	)
)