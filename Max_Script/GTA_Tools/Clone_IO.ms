-- DDF35.MS - R2.5, R3 and R4 compatible
-- This short free Utility checks for Double Faces in Meshes.
-- It is a fix for the bug in STL-Check Modifier which
-- selects both faces in a pair of Double Faces.
------------------------------------------------------------------------------------------------
-- THIS REVISION adds the option to add modifiers to the bottom of the stack
-- for objects using Physique etc. and max 4 support
------------------------------------------------------------------------------------------------
-- You may use, redistribute and modify this utility freely.
-- Please give me credit if you do so.
-- For questions and sugestions, email me at
-- bobo@email.archlab.tuwien.ac.at
-- or visit Boboland:
-- http://gfxcentral.com/bobo/
-------------------------------------------------------------------------------------------------
-- DISCLAIMER: This utility modifies your meshes! Use it at your own risk!
-- And save (or at least Hold) frequently...
-------------------------------------------------------------------------------------------------
-- ddf41_pz.ms - only tested with 3ds max r3.1
-- Updated by Richard Annema ( www.pointzero.nl/contact/ ), pointZero Development
-- This script will now pick up on coincident faces that don't share vers as well
-- additionally, the old 'non-quick' and check is much faster now
-- script underwent several changes, aesthetical as well as programming-wise
-- comments starting with "ZB: " will explain the changes
--
-- three new UI elements :
-- Check Type
--   1:1 Check (fast) - this is the old 'quick' option
--   Vert Indices Check - this is the old non-quick option, even though it's MUCH sped up in this alteration
--   Vert Pos Check (slow) - this is the new option which can detect 'duplicate'/coincidental faces that don't share verts. It says 'slow', but it's really not much slower than Vert Indices Check.
--
-- Check Flipped Normals - Available with the Vert type checks, this will have the script test against faces with flipped normals when checked
--
-- Pos Threshold - A threshold for the Vest Pos Check method. The reason for this is that in a simple test, a null-threshold failed. max's numerical accuracy fell apart in the check. This threshold will allow You to determine the accuracy. Default value should be good.
------------------------------------------------------------------------------------------------

-- ZB: General - aesthetic changes such as:
-- ZB: moving parentheses
-- ZB: encapsulating if-then-else tests with parentheses
-- ZB: using 'if ... do' instead of 'if ... then' if no 'else' follows
-- ZB: changed all the formats to single-lined commands, rather than the 'declare var, format var' method

rollout delete_double_faces "DDF" (

local del_array = #()
local maxVer = 3

-- ZB: Moved the about box to the bottom
group "DoubleFace Check" (
	button scan_faces "CHECK Selected Meshes" width:140 height:30
-- ZB: Changed from a q_check toggle to a check_type selection as there's now 3 ways to check
	radiobuttons check_type "Check Type:" labels:#("1:1 Check (fast)","Vert Indices Check","Vert Pos Check (slow)") default:1
	checkbox check_flipped "Check Flipped Normals" enabled:false checked:true offset:[0,-3]
	spinner pos_thresh "Pos Threshold:" range:[0.0,1.0,0.001] fieldwidth:40 scale:0.001 offset:[0,-5] enabled:false
	checkbutton extract_faces "EXTRACT DoubleFaces" width:140 checked:false highlightcolor:([128,255,128] as color)
	checkbutton remove_faces "DELETE DoubleFaces" width:140 checked:false highlightcolor:([255,128,128] as color)
	radiobuttons remove_kind "Deletion Method:" labels:#("Add DeleteMesh Modifier","Collapse EMeshes only","Collapse All Meshes")
	checkbox add_to_bottom "Mods to Stack Bottom" checked:true
)

group "About..." (
	label ddfabout01 "DeleteDoubleFaces" offset:[0,-3]
-- ZB: Changed Bobo's date structure a little. Please, let's be internationally sound and use yyyy/mm/dd - hey, computer databases like them better, too... can we say "sort without date conversion" ?
	label ddfabout02 "Version 4.0 - 2001/02/17" offset:[0,-3]
	label ddfabout03 "(c)Bobo's Rendert**ls" offset:[0,-3]
	label ddfabout04 "http://gfxcentral.com/bobo/" offset:[0,-3]
	label ddfabout05 "Version 4.1_pz - 2004/Apr/26" offset:[0,5]
	label ddfabout06 "©pointZero development" offset:[0,-3]
	label ddfabout07 "http://www.pointzero.nl/" offset:[0,-3]
)

on check_type changed state do (
	check_flipped.enabled = (state >= 2)
	pos_thresh.enabled = (state == 3)
)

fn scan_for_double_faces c_node = (
	e_node = c_node

	format "%\n" ("Checking Mesh " + e_node.name)

	ms = mesh_select()
	addmodifier e_node ms

	format "%\n" (e_node.numfaces as string + " Faces in Mesh.")

	face_array = #()
-- ZB: New array to store face normals
	norm_array = #()
	del_array = #()

	progressStart "DoubleFaces Check:"
	thresh = pos_thresh.value
	for i = 1 to e_node.numfaces do (
		progress_percent = ((i as float / e_node.numfaces) * 100) as integer
		if (old_percent != progress_percent) do (
			old_percent = progress_percent
			if (not progressUpdate progress_percent) do ( exit )
		)

		get_face_norm = getFaceNormal e_node i
		get_face = getFace e_node i

		if (check_type.state == 1) then (
			f_item = findItem face_array get_face
			if (f_item != 0) then ( append del_array i )
			else ( append face_array get_face )
		)
		else (
			dd_found = false
			for j = 1 to face_array.count do (
-- ZB: cache the normals
				comp_norm = norm_array[j]
				cur_norm = get_face_norm
-- ZB: check the normals, and run tests depending on the normals.
-- ZB: If the normals are too different (a very *stupid* test using distance, instead of something like dot, but it works :P), then the tests aren't run
				if (((distance cur_norm comp_norm) < thresh) OR (check_flipped.checked AND ((distance cur_norm (-comp_norm)) < thresh))) do (
-- ZB: cache the vertex indices
					comp_x = face_array[j].x
					comp_y = face_array[j].y
					comp_z = face_array[j].z
					cur_x = get_face.x
					cur_y = get_face.y
					cur_z = get_face.z
					if (check_type.state == 2) then (
						xx = comp_x == cur_x; xy = comp_x == cur_y; 	xz = comp_x == cur_z; yx = comp_y == cur_x; yy = comp_y == cur_y; yz = comp_y == cur_x; zx = comp_z == cur_x; zy = comp_z == cur_y; zz = comp_z == cur_z
						if (xx) AND (yy) AND (zz) then ( dd_found = true )
						else if (xy) AND (yz) AND (zz) then ( dd_found = true )
						else if (xz) AND (yy) AND (zx) then ( dd_found = true )
						else if (xx) AND (yz) AND (zy) then ( dd_found = true )
						else if (xy) AND (yz) AND (zx) then ( dd_found = true )
						else if (xz) AND (yx) AND (zy) then ( dd_found = true )
					)
-- ZB: if using Vert Pos check, then cache vertex positions instead
					else if (check_type.state == 3) do (
						comp_x = getVert e_node comp_x
						comp_y = getVert e_node comp_y
						comp_z = getVert e_node comp_z
						cur_x = getVert e_node cur_x
						cur_y = getVert e_node cur_y
						cur_z = getVert e_node cur_z
-- ZB: check distances between verts based on threshold
						xx = (distance comp_x cur_x) < thresh; xy = (distance comp_x cur_y) < thresh; xz = (distance comp_x cur_z) < thresh; yx = (distance comp_y cur_x) < thresh; yy = (distance comp_y cur_y) < thresh; yz = (distance comp_y cur_z) < thresh; zx = (distance comp_z cur_x) < thresh; zy = (distance comp_z cur_y) < thresh; zz = (distance comp_z cur_z) < thresh
						if (xx) AND (yy) AND (zz) then ( dd_found = true )
						else if (xy) AND (yx) AND (zz) then ( dd_found = true )
						else if (xz) AND (yy) AND (zx) then ( dd_found = true )
						else if (xx) AND (yz) AND (zy) then ( dd_found = true )
						else if (xy) AND (yz) AND (zx) then ( dd_found = true )
						else if (xz) AND (yx) AND (zy) then ( dd_found = true )
					)
				)
-- ZB: removed all the 'append_del_array i' from the checks, might as well add it here, if dd_found == true.
				if (dd_found) do (
-- ZB: prevent faces we already covered from magically getting stored
					if ((findItem del_array i) == 0) do ( append del_array i )
				)
			)
			if (not dd_found) do (
				append face_array get_face
-- store the face's normal
				append norm_array get_face_norm
			)
		) -- end Vert checks
	) -- end i loop
	progressEnd()

	if (del_array.count > 0) then (
		format "%\n" (del_array.count as string + " DoubleFaces Found!")
		delete_enabled = true
	)
	else (
		format "No DoubleFaces Found!\n"
		delete_enabled = false
	)

	deletemodifier e_node ms

	delete_enabled
) -- end check fn

fn remove_double_faces c_node = (
	e_node = c_node
	undo on (
		ms = mesh_select()
		dm = deletemesh()

		if (maxVer >= 4) then (
			addmodifier e_node ms
			setfaceselection e_node ms del_array
			addmodifier e_node dm
		)
		else (
			max modify mode
			if (add_to_bottom.checked) then ( modPanel.setCurrentObject e_node.baseobject )
			modPanel.addModToSelection ms
			subObjectLevel = 3
			setfaceselection e_node ms del_array
			modPanel.addModToSelection dm
			max utility mode
		)

		format "%\n" (del_array.count as string + " Faces Selected...")
		format "DeleteMesh Modifier Applied.\n"

		if (remove_kind.state == 2) then (
			n_mods = e_node.modifiers.count
			if (n_mods == 2) then (
				collapsestack e_node
				format "Modifier Stack Collapsed.\n"
			)
			else (
				format "No Changes To Modifier Stack.\n"
			)
		)
		else if (remove_kind.state == 3) then (
			collapsestack e_node
			format "Modifier Stack Collapsed.\n"
		)
	) -- end undo
) -- end fn



fn extract_double_faces c_node = (
	e_node = c_node

	undo on (
		select e_node
		ms = mesh_select()
		addmodifier e_node ms
		new_vert_array = #()
		new_face_array = #()
		new_mat_ids = #()
		new_t_verts = #()

		for i = 1 to e_node.numverts do (
			new_vert_array[i] = getvert e_node i
		)

		for i = 1 to del_array.count do (
			append new_face_array (getface e_node del_array[i])
			append new_mat_ids (getfacematid e_node del_array[i])
		)

		new_node = mesh vertices:new_vert_array faces:new_face_array materialids:new_mat_ids --tverts:new_t_verts
		new_tvc = getNumTVerts e_node
		setnumTVerts new_node new_tvc
		if (new_tvc > 0) do (
			for i = 1 to e_node.numtverts do (
				settvert new_node i (gettvert e_node i)
			)
			buildTVfaces new_node
		)
	) -- end undo

	--SET TVFACES, EDGE VISIBILITY AND SMOOTHING GROUPS
-- ZB: optimally, this would also copy vertex colors, appdata, and whatnot. But imho, the intent of this script would be to rid Yourself of duplicate/coincident faces -before- messing with them. So I've left the rest of this stuff intact
	for i = 1 to del_array.count do (
		if (new_tvc > 0) do (
			new_tvface = (getTVface e_node del_array[i])
			setTVface new_node i new_tvface
		)
		new_edgevis_1 = (getedgevis e_node del_array[i] 1)
		new_edgevis_2 = (getedgevis e_node del_array[i] 2)
		new_edgevis_3 = (getedgevis e_node del_array[i] 3)
		new_smooth = (getfacesmoothgroup e_node del_array[i])

		setedgevis new_node i 1 new_edgevis_1
		setedgevis new_node i 2 new_edgevis_2
		setedgevis new_node i 3 new_edgevis_3
		setfacesmoothgroup new_node i new_smooth
	)
	update new_node
	deletemodifier e_node ms
	new_node.name = ("DF_"+ e_node.name)
	if (e_node.material != undefined) do ( new_node.material = e_node.material )
	new_node.pivot = e_node.pivot

	format "%\n" ("DoubleFaces Extracted to EMesh " + new_node.name)
) -- end fn

on scan_faces pressed do (
	obj_array = selection as array
	for n = 1 to obj_array.count do (
		check_node = obj_array[n]
		select check_node
		if (classof check_node == Editable_Mesh) do (
			scan_result = scan_for_double_faces check_node
			if (scan_result) do (
				if (extract_faces.checked) do ( extract_double_faces check_node )
				if (remove_faces.checked) do ( remove_double_faces check_node )
			)
		)
	) -- end n loop

	format "Ready.\n"
	format "\n"
	select obj_array
) -- end on

on delete_double_faces open do (
	local maxVer
	try ( maxVer = MaxVersion() )
	catch ( maxVer = 2 )

	if (maxVer != 2) then (
		if (maxVer[1] == 4000) then (
			maxVer = 4
			format "MAX 4.x Detected.\n"
		)
		else (
			maxVer = 3
			format "MAX 3.x Detected.\n"
		)
	)
	else ( format "MAX 2 Detected.\n" )
) -- end on rollout open

) -- end rollout

try ( closeRolloutFloater pzDDF )
catch ()
pzDDF = newRolloutFloater "pzDDF" 200 512
addRollout delete_double_faces pzDDF
