--revise start 11/03/06
rollout dffgui "Dff Gui" width:152 height:256
(
	button btn_dffexp "Export DFF" pos:[8,56] width:64 height:24
	button btn_updatedff "Update DFF" pos:[80,56] width:64 height:24 enabled:false
	dropdownList ddl_setrw "Stream Version" pos:[5,8] width:139 height:40 items:#("3.6.0.3 (SA)")
	checkbox chk_flipnorm "Flip Normals" pos:[16,176] width:80 height:16 checked:false enabled:false
	GroupBox grp1 "Geometry Flags" pos:[8,88] width:136 height:160
	checkbox chkgeompos "Geometry Positions" pos:[16,104] width:112 height:16 enabled:false checked:true
	checkbox chkprelight "Prelight" pos:[16,120] width:72 height:16 enabled:true checked:false
	checkbox chknorm "Normals" pos:[16,136] width:64 height:16 enabled:true checked:true
	checkbox chklighting "Lighting" pos:[16,152] width:56 height:16 enabled:true checked:true
	dropdownList ddl_exp_preset "PreSets" pos:[16,200] width:88 height:40 items:#("Default","Vehicles", "Buildings")
	
	global dfffile = "C:\\test.dff" --default file path
	global rwvers = 0x1003FFFF --3.6.0.3 by default
	global output_dff
	global obj
	global dffstream
	global flipnorm = true
	global geomflagpos
	global geomflagprelight
	global geomflagnormals
	global geomflaglighting
	
	fn nullselect = 
	(
		messagebox "No objects selected"
	)
	
	fn setrwvers sel =
	(
		--print sel
		if sel == 1 then --use case here?
		(
			rwvers = 0x1003FFFF	
			format "RwVers: %\n" rwvers
		)
	)
	
	fn setpresets sel2 =
	(
		if sel2 == 1 then --default
		(
			chkprelight.checked = false
			geomflagprelight = false
			chknorm.checked = true
			geomflagnormals = true
		)
		if sel2 == 2 then --vehicles
		(
			chkprelight.checked = false
			geomflagprelight = false
			chknorm.checked = true
			geomflagnormals = true
		)
		if sel2 == 3 then --buildings
		(
			chkprelight.checked = true
			geomflagprelight = true
			chknorm.checked = false
			geomflagnormals = false
		)
	)
	
	fn expfn = 
	(
			dfffile = output_dff
			filein "dffexpfn.ms"
			setflags(flipnorm)geomflagpos geomflagprelight geomflagnormals geomflaglighting
			doclump(dfffile)rwvers
			objcount()
			doframelist()
			doframenames()
			dogeomlist()
			dogeom()
			writeatomic(obj) --all atomic data is actually written separately
			closeit()
			fclose dffstream
			btn_updatedff.enabled = true
	)
	
	on dffgui open do
	(
		--btn_updatedff.enabled = false
		global geomflagpos = chkgeompos.state
		global geomflagprelight = chkprelight.state
		global geomflagnormals = chknorm.state
		global geomflaglighting = chklighting.state
	)
	on btn_dffexp pressed do
	(
	if $ != undefined then
			(
			output_dff = getSaveFileName caption:"DFF" types:"DFF (*.DFF)|*.dff|All Files (*.*)|*.*|"
			if output_dff != undefined then
			--shold end function here, storing path as a variable, and do all exporting in a sep fn; can reference sep fn for "update" btn
			--add multi clump options here
			expfn()
			)
			else(nullselect())
	
	)
	on btn_updatedff pressed do
	(
	--update dff. jump right to the export function, using last path saved
		--int dfffile
		if $ != undefined then
		(
			expfn()
		)
		else(nullselect())
	)
	on ddl_setrw selected sel do
	(
		setrwvers(sel)
	)
	on chk_flipnorm changed state do
	(
		--change the value
		flipnorm = chk_flipnorm.state
	)
	on chkgeompos changed state do
	(
		--geometry position flag
		geomflagpos = chkgeompos.state
	)
	on chkprelight changed state do
	(
		--geometry prelighting flag
		geomflagprelight = chkprelight.state
	)
	on chknorm changed state do
	(
		--geometry normals flag
		geomflagnormals = chknorm.state
	)
	on chklighting changed state do
	(
		--geometry lighting flag
		geomflaglighting = chklighting.state
	)
	on ddl_exp_preset selected sel2 do
	(
	--enable/disable options as necessary
		setpresets(sel2)
	)
)

rollout dffdbg "Debug" width:152 height:256
(
	--TBA
	button btn3 "Num Mats on Obj" pos:[8,8] width:96 height:24
	groupBox grp2 "Viewport" pos:[8,64] width:136 height:128
	checkbox chk6 "Enable Viewport Info" pos:[8,40] width:120 height:16
	radioButtons rdo1 "Object Names" pos:[16,80] width:103 height:30 labels:#("Fixed Pos","On Object") default:1
	
)

if (rwdffui != undefined ) then closeRolloutFloater rwdffui
rwdffui = newrolloutfloater "RwDffExp" 164 285 30 100
addrollout dffgui rwdffui rolledup:false
--addrollout dffdbg rwdffui rolledup:true