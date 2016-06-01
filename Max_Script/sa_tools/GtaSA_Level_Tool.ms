rollout GTASALevelTool "Properties"
(
	group "Object Properties (GENERAL)"
	(		
		spinner id_choose "ID Number: " range:[0,99999,19000] type:#integer scale:1
		edittext name_choose "Object File Name:"
	)
	group "Object Properties (IDE)"
	(		
		edittext txd_choose "Txd File Name:"
		spinner lod_choose "LOD Distance: " range:[0,1500,0] type:#integer scale:1
		spinner typ_choose "Typ: " range:[0,5000000,0] type:#integer scale:1
	)
	group "Object Properties (IPL)"
	(		
		spinner int_choose "Interior Number: " range:[0,999,0] type:#integer scale:1		
	)
	group "Set/Get Properties | Select Objects"
	(		
		button set_prop "Set Properties" width:80 align:#left toolTip:"set Properties" offset:[0,-5]
		button get_prop "Get Properties" width:80 align:#right toolTip:"get Properties" offset:[0,-26]
		button reset_prop "Reset Prop." width:80 align:#left toolTip:"Reset Values & Text in Rollout" offset:[0,-5]
		button get_obj "Get Objects" width:80 align:#right toolTip:"Get Objects" offset:[0,-26]
		button get_obj_by_id "Get Obj by ID" width:80 align:#left toolTip:"Get Object by ID Number" offset:[0,-5]
--		button dummy2 "Get Objects" width:80 align:#right toolTip:"Get Objects" offset:[0,-26]
	)				

	group "Object rotation"
	(
		button rotate90cw "90° CW" width:55 align:#left toolTip:"rotate selected object by 90° CW" offset:[0,-5]
		button rotate90ccw "90° CCW" width:55 align:#right toolTip:"rotate selected object by 90° CCW" offset:[0,-26]
		button rotate180 "180°" width:55 align:#center toolTip:"rotate selected object by 180°" offset:[0,-26]
	)

	on set_prop pressed do
		(
			for obj in selection do
			(
				if id_choose.value != 0 then setUserProp obj "id" id_choose.value
				else (setUserProp obj "id" 19000
					id_choose.value = 19000)
				if lod_choose.value != 0 then setUserProp obj "lod" lod_choose.value
				else (setUserProp obj "lod" 299
					lod_choose.value = 299)
				if name_choose.text != "" then setUserProp obj "name" name_choose.text
				else (setUserProp obj "name" "name_dummy" 
					name_choose.text = "name_dummy")
				if txd_choose.text != "" then setUserProp obj "txd" txd_choose.text
				else (setUserProp obj "txd" "txd_dummy"
					txd_choose.text = "txd_dummy")
				setUserProp obj "typ" typ_choose.value
				setUserProp obj "int" int_choose.value
			)
		)
	on get_prop pressed do
		(
			if selection.count == 1 then (
			for obj in selection do
			(
				if (getUserProp obj "id") != undefined then id_choose.value = (getUserProp obj "id")
					else (MessageBox "ID Number is undefined!" title:"Object Error")
				if (getUserProp obj "name") != undefined then name_choose.text = (getUserProp obj "name")
					else (MessageBox "Object File Name is undefined!" title:"Object Error")
				if (getUserProp obj "txd") != undefined then txd_choose.text = (getUserProp obj "txd")
					else (MessageBox "TXD File Name is undefined!" title:"Object Error")
				if (getUserProp obj "lod") != undefined then lod_choose.value = (getUserProp obj "lod")
					else (MessageBox "LOD Distance is undefined!" title:"Object Error")
				if (getUserProp obj "typ") != undefined then typ_choose.value = (getUserProp obj "typ")
					else (MessageBox "Typ is undefined!" title:"Object Error")
				if (getUserProp obj "int") != undefined then int_choose.value = (getUserProp obj "int")
					else (MessageBox "Interior is undefined!" title:"Object Error")
			)
			)else(MessageBox "Select only 1 Object" title:"Selection Error")
		)
	on reset_prop pressed do
	(
		id_choose.value = 19000
		lod_choose.value = 299
		name_choose.text = "name_dummy"
		txd_choose.text = "txd_dummy"
		typ_choose.value = 0
		int_choose.value = 0
	)
	on get_obj pressed do
	(
		for obj in selection do (deselect obj)
		get_now = (hitByNameDlg())
	)

	on get_obj_by_id pressed do
	(
		max select all
		getCurrentSelection
		get_all = selection as array
		format "Selection Count: %\n" get_all.count
		gobi_val = id_choose.value
		format "id_choose: %\n" gobi_val

		for obj in selection do (
		gobi_val1 = getUserProp obj "id"
		format "gobi_sel_id: %\n" gobi_val1
		
		if gobi_val != gobi_val1 then deselect obj
			if getUserProp obj "id" != undefined then (gobi_id = getUserProp obj "id"
			if gobi_id != id_choose.value then deselect obj)
			
			if (getUserProp obj "id") == (id_choose.value) then (lol = 1)
			else (deselect obj)
		)
		-- get_now = (hitByNameDlg())
	)

	on rotate180 pressed do
		(
			if selection.count != 0 then (
				for obj in selection do(
				obj_rotate = eulerangles 0 0 180
				rotate obj obj_rotate
			))
			else (MessageBox "Select more then 0 Objects" title:"Selection Error")
		)

	on rotate90cw pressed do
		(
			if selection.count != 0 then (
				for obj in selection do(
				obj_rotate = eulerangles 0 0 270
				rotate obj obj_rotate
			))
			else (MessageBox "Select more then 0 Objects" title:"Selection Error")
		)

	on rotate90ccw pressed do
		(
			if selection.count != 0 then (
				for obj in selection do(
				obj_rotate = eulerangles 0 0 90
				rotate obj obj_rotate
			))
			else (MessageBox "Select more then 0 Objects" title:"Selection Error")
		)

)-- end of rollout

rollout GTASALevelTool2 "File Export"
(
	group "File Exports"
	(
		button create_ide "IDE File Export" width:82 align:#left toolTip:"Export an IDE file" offset:[0,-5]
		button create_ipl "IPL File Export" width:82 align:#right toolTip:"Export an IPL file (automatic rotation)" offset:[0,-26]
	)

	on create_ide pressed do
	(
	ide = getSaveFileName types:"GTA SA IDE (*.ide)|*.ide|Textfile (*.txt)|*.txt|All Files (*.*)|*.*|" 
		if ide != undefined then
		(	
			get_now = (hitByNameDlg())
			if get_now != false then(
			local ide_array = #()
			i = 1
			ide_true = 0	
			ide = createFile (ide)
			format "# IDE generated with SA Map Script (SAMS)" to:ide
			format "\n" to:ide
			format "# Date %" localTime to:ide
			format "\n" to:ide
			format "# Author: ocram" to:ide
			format "\n" to:ide
			format "\n" to:ide
			format "objs\n" to:ide
			for obj in selection do
			(
			ide_array[i] = (getUserProp obj "id")
				for i = 1 to ide_array.count do
				(
					if ide_array[i] == (getUserProp obj "id") then ide_true += 1
				)
				if ide_true != 2 and ide_true <= 1 then
				(
					format "%, %, %, %, %" (getUserProp obj "id")(getUserProp obj "name")(getUserProp obj "txd")(getUserProp obj "lod")(getUserProp obj "typ") to:ide
					format "\n" to:ide
				)
			i+=1
			ide_true = 0
			)
			format "end\ntobj\nend\npath\nend\n2dfx\nend\nanim\nend\ntxdp\nend" to:ide
			close ide
			)	
		)else (MessageBox "IDE is undefined ? O_o ?" title:"IDE Export Error")
	)

	on create_ipl pressed do
	(
		ipl = getSaveFileName types:"GTA SA IPL (*.ipl)|*.ipl|Textfile (*.txt)|*.txt|All Files (*.*)|*.*|" 
		if IPL != undefined then
		(
			get_now = (hitByNameDlg())
			if get_now != false then
			(		
			ipl = createFile (ipl)
			format "# IPL generated with SA Map Script (SAMS)" to:ipl
			format "\n" to:ipl
			format "# Date %" localTime to:ipl
			format "\n" to:ipl
			format "# Author: ocram" to:ipl
			format "\n" to:ipl
			format "\n" to:ipl
			format "inst" to:ipl
			format "\n" to:ipl
			for obj in selection do (
			format "%, %, %, %, %, %, %, %, %, %, -1" (getUserProp obj "id") (getUserProp obj "name") (getUserProp obj "int") (obj.pos.x) (obj.pos.y) (obj.pos.z) (obj.rotation.x) (obj.rotation.y) (obj.rotation.z*(-1)) (obj.rotation.w) to:ipl
			format "\n" to:ipl
							)
			format "end\ncull\nend\nzone\nend\npath\nend\ngrge\nend\nenex\nend\npick\nend\ncars\nend\njump\nend\ntcyc\nend\nauzo\nend\nmult\nend\noccl\nend" to:ipl
			close ipl
			)
		)else (MessageBox "IPL is undefined ? O_o ?" title:"IPL Export Error")
	)

)-- end of rollout

rollout aboutrollout "About"
(
	label LabelA "SA Map Script"
	label LabelB "ocram"
)-- end of rollout

if SAMS != undefined then closeRolloutFloater SAMS
SAMS = newRolloutFloater "GTA SA Level Tool" 220 415 10 100		
addRollout GTASALevelTool SAMS rolledup:false
addRollout GTASALevelTool2 SAMS rolledup:true
addRollout aboutrollout SAMS rolledup:true
