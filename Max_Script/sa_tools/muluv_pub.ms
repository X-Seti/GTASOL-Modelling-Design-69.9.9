--multi-object UV map modifier utility
--Created so that its possible to apply a separate uvw modifier to every object in the selection, which max does not currently do (max 7 anyway)
--instead if you have multiple objects selected and apply the uvw modifier, it will simply apply the one modifer to the entire selection, which is often not what is wanted
--v0.1 first public release
--2006-2007 Jesse Thoe

utility muluvutil "Multi Object UVW" width:168 height:472
(
	button muluv_douv "Apply Modifier to objects" pos:[8,440] width:152 height:24
	GroupBox grp1 "UV Settings" pos:[8,8] width:152 height:216
	radiobuttons rdo1 "Mapping" pos:[16,24] width:85 height:126 labels:#("Planar", "Cylindrical", "Spherical", "Shrink Wrap", "Box", "Face", "XYZ to UVW") default:1 columns:1
	checkbox chk_cap "Cap" pos:[105,56] width:43 height:15 enabled:false
	label lbl4 "U Tile:" pos:[16,152] width:48 height:17
	label lbl5 "V Tile:" pos:[16,176] width:48 height:17
	label lbl6 "W Tile:" pos:[16,200] width:48 height:17
	spinner spn_utile "" pos:[64,152] width:49 height:16 range:[-999,999,1] type:#float
	spinner spn_vtile "" pos:[64,176] width:49 height:16 range:[-999,999,1] type:#float
	spinner spn_wtile "" pos:[64,200] width:49 height:16 range:[-999,999,1] type:#float
	checkbox chk_uflip "Flip" pos:[120,152] width:37 height:15
	checkbox chk_vflip "Flip" pos:[120,176] width:37 height:15
	checkbox chk_wflip "Flip" pos:[120,200] width:37 height:15
	GroupBox grp6 "Channel" pos:[8,232] width:152 height:56
	radiobuttons rdo6 "" pos:[16,248] width:122 height:32 labels:#("Map Channel", "Vertex Color Channel")
	spinner spn_mapchnl "" pos:[104,248] width:48 height:16 range:[0,100,0] type:#integer
	GroupBox grp7 "Alignment" pos:[8,296] width:152 height:72
	radiobuttons rdo7 "" pos:[16,312] width:30 height:48 labels:#("X", "Y", "Z") default:3 columns:1
	GroupBox grp11 "Options" pos:[8,376] width:152 height:56
	checkbox muluv_selclear "Clear Selection" pos:[16,392] width:96 height:14
	checkbox muluv_stackcol "Collapse Stack" pos:[16,408] width:96 height:14
	
	global stackcol = false
	global clearsel = false
	global maptype = 0
	global cylcap = false
	global util = 1
	global vtil = 1
	global wtil = 1
	global uflip = false
	global vflip = false
	global wflip = false
	global align = 0
	global mapchannel = 1
	global channel = 0
	
	fn noobjfn = 
	(
		messagebox "No objects selected"
	)
	
	fn muluv = 
	(
		--for obj in $ do
		--grab selection as array
		oldsel = selection as array
		--print oldsel
		for f=1 to selection.count do
		(
			select oldsel[f]
			--print ("Selected " + oldsel[f].name)
			
			--add the modifier
			macros.run "Modifiers" "Uvwmap"
			--set its params
			$.modifiers[#UVW_Mapping].maptype = maptype --0 = planar
			$.modifiers[#UVW_Mapping].cap = cylcap --only if cylindrical is chosen
			$.modifiers[#UVW_Mapping].utile = spn_utile.value
			$.modifiers[#UVW_Mapping].vtile = spn_vtile.value
			$.modifiers[#UVW_Mapping].wtile = spn_wtile.value
			$.modifiers[#UVW_Mapping].uflip = uflip
			$.modifiers[#UVW_Mapping].vflip = vflip
			$.modifiers[#UVW_Mapping].wflip = wflip
			$.modifiers[#UVW_Mapping].mapChannel = spn_mapchnl.value
			$.modifiers[#UVW_Mapping].channel = channel --0 is map channel, 1 is vertex color
			$.modifiers[#UVW_Mapping].axis = align
			
			--collapse stack when done?
			if stackcol == true then
			(
				(maxOps.CollapseNode $ on)
			)
			
			f = (f + 1)
		)
		if clearsel == false then
		(
			--don't clear the selection
			select oldsel --restore old selection
		)
		else
		(
			--clear the selection
			clearSelection()
		)
	)	
	
	--controls
	
	
	
	
	
	
	on muluv_douv pressed do
	(
		if $ == undefined then (noobjfn) else
		muluv()
	)
	on rdo1 changed stat do
	(
		--get the selection from the radio
		--if selection is cylindrical, enable the "Cap"
		maptype = (rdo1.state - 1) --radio index is 1-based, where uvw modifier is 0-based
		if maptype == 1 then
		(
			chk_cap.enabled = true
		)
		else
		(
			chk_cap.enabled = false
		)
	)
	on chk_cap changed state do
	(
	--cylindircal capping
		cylcap = chk_cap.state
	)
	on chk_uflip changed state do
	(
		--if u flip
		if chk_uflip.state == true then
		(
			uflip = true
		)
		else
		(
			uflip = false
		)
	)
	on chk_vflip changed state do
	(
		--if v flip
		if chk_vflip.state == true then
		(
			vflip = true
		)
		else
		(
			vflip = false
		)
	)
	on chk_wflip changed state do
	(
		--if w flip
		if chk_wflip.state == true then
		(
			wflip = true
		)
		else
		(
			wflip = false
		)
	)
	on rdo6 changed stat do
	(
		--channel; map channel vs vertex color
		channel = (rdo6.state - 1)
	)
	on rdo7 changed stat do
	(
		--on alignment change		
		align = (rdo7.state - 1) --radio index is 1-based, where uvw modifier is 0-based
	)
	on muluv_selclear changed state do
	(
		--clear selection when done
		if muluv_selclear.state == true then
		(
			clearsel = true
		)
		else
		(
			clearsel = false
		)
	)
	on muluv_stackcol changed state do
	(
		--collapse stack when done
		if muluv_stackcol.state == true then
		(
			stackcol = true
		)
		else
		(
			stackcol = false
		)
	)
)