-------------------------------------------------------------------------------
helptxt = "GTA Path Generator

Version 0.3 / April 7th 2005
© 2005 by Steve M.
http://www.steve-m.com

This script generates path segments out of the selected (spline) shapes,
compatible to GTA VC and SA. The coordinates are printed to the MaxScript
listener (F11), simply copy the text and add it to an ipl file.

To create junctions, let the spline knots within ONE shape overlap. Note that
not more than 12 nodes can be used per path segment/junction. However, this
limit is irrelevant for linear paths, as they will be split up automatically."

-- For more information about paths and this script visit:
-- http://www.gtaforums.com/index.php?showtopic=93990
-------------------------------------------------------------------------------

rollout GTAPATH2 "GTA Path Generator"
(
	local
		settings,
		pathtype,	
		errormsg = "",	
		typecols = #(green, red, blue, yellow) -- path type colors array (peds, cars, boats, default)

	group " Path Generator "
	(
		button generate "Generate Path Segments" tooltip:"Generates path segments from selected shapes."
		spinner threshold "Node Threshold:" range:[0,1,0.1] type:#float fieldwidth:40
		spinner nodevar "Ped Node Var.:" range:[0,1,0.2] type:#float fieldwidth:40
		checkbox comments "Enable Comments" checked:true align:#center
	)
	group " Segment Settings "
	(
		dropdownlist p_type "Path Type:" items:#("Peds", "Cars", "Boats") selection:2
		spinner p_width "Path Width:" range:[0,200,0] type:#float fieldwidth:50
		spinner p_leftlanes "Left Lanes:" range:[0,5,1] type:#integer fieldwidth:50
		spinner p_rightlanes "Right Lanes:" range:[0,5,1] type:#integer fieldwidth:50
		spinner p_flag1 "Flag 1:" range:[0,2,1] type:#integer fieldwidth:50
		spinner p_flag2 "Flag 2:" range:[0,8,0] type:#integer fieldwidth:50
		spinner p_flag3 "Flag 3:" range:[0,1,1] type:#float fieldwidth:50
		spinner p_flag4 "Flag 4:" range:[0,9,0] type:#integer fieldwidth:50
		
		button store_settg "Store" across:2 width:65 tooltip:"Stores current segment settings in the user properties of selected shapes."
		button retr_settg "Retrieve" width:65 tooltip:"Retrieves segment settings from the user properties of the FIRST selected shape, if available."
		button clear_settg "Clear User Props" width:133 tooltip:"Clears the user properties buffer of the selected shapes, so default segment settings will be used."
	)
	button help "About / Help" width:153 tooltip:"Display about information and help text."
	on help pressed do MessageBox helptxt title:"About GTA Path Generator" beep:false
	
	
	function ReadSetting obj item =
	(
	 userprop = GetUserProp obj item
	 if userprop != undefined then userprop else execute ("GTAPATH."+item)
	)
	
	on store_settg pressed do
	(	
		for obj in selection do if (iskindof obj Shape) then
		(				
			SetUserProp obj "p_type.selection" p_type.selection
			obj.wirecolor = typecols[p_type.selection]
			SetUserProp obj "p_width.value" p_width.value
			SetUserProp obj "p_leftlanes.value" p_leftlanes.value
			SetUserProp obj "p_rightlanes.value" p_rightlanes.value
			SetUserProp obj "p_flag1.value" p_flag1.value
			SetUserProp obj "p_flag2.value" p_flag2.value
			SetUserProp obj "p_flag3.value" p_flag3.value
			SetUserProp obj "p_flag4.value" p_flag4.value
		)
	)
	on retr_settg pressed do
	(
		obj = selection[1]
		if (iskindof obj Shape) then
		(				
			p_type.selection = ReadSetting obj "p_type.selection" 
			p_width.value = ReadSetting obj "p_width.value" 
			p_leftlanes.value = ReadSetting obj "p_leftlanes.value" 
			p_rightlanes.value = ReadSetting obj "p_rightlanes.value" 
			p_flag1.value = ReadSetting obj "p_flag1.value" 
			p_flag2.value = ReadSetting obj "p_flag2.value" 
			p_flag3.value = ReadSetting obj "p_flag3.value" 
			p_flag4.value = ReadSetting obj "p_flag4.value" 
		)
	)
	on clear_settg pressed do
	(
		for obj in selection do if (iskindof obj Shape) then
		(				
			SetUserPropBuffer obj ""
			obj.wirecolor = typecols[4]
		)
	)

-------------------------------------------------------------------------------	
	
	function PrintPathNode type ntype next vert settg =
	(
		if type == 0 then -- ped node XY variation
		(		
			vert.x += random -nodevar.value nodevar.value
			vert.y += random -nodevar.value nodevar.value
		)
		
		vert *= 16	
		format "\n\t%, %, 0, %, %, %, %" ntype next vert.x vert.y vert.z settg	
	)
	
	function PrintEmptyNodes n =
	(
		for x = 1 to n do format "\n\t0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0"
	)
	
-------------------------------------------------------------------------------

	function MakeLinearSeg spl =
	(
		for i = 1 to numSplines spl do
		(
		    num = numKnots spl i
			
			if (num > 1) then
			(
				if comments.checked then format "\n\n# Shape \"%\", Spline %" spl.name i
				local k = 99
				
				j = 1
				while j <= num do
				(						
					if (k>12) then -- start new segment
					(
						format "\n%, -1" pathtype
						k = 1
						
						if (j>1) then j-=1 -- repeat node
					)
					
					if (k==12 OR j==num) then
					(
						-- external nodes (last and first)						
						PrintPathNode pathtype 1 -1 (getKnotPoint spl i j) settings
						PrintPathNode pathtype 1 0 (getKnotPoint spl i (j-k+1)) settings
					
					) else if (k>1) then (
						-- internal nodes					
						PrintPathNode pathtype 2 (k-1) (getKnotPoint spl i j) settings
					)
					
					k+=1
					j+=1					
				)
					
				PrintEmptyNodes (13-k)				
			)			
		)	
	)
	
	function MakeJunctionSeg spl =
	(
		local 
			verts = #(), -- array of unique knot vertices
			usage = #(), -- how many times the vert is shared
			links = #()  -- node linking array, indices of the two verts
			
		-- collect knot and segment data	
		
		for i = 1 to numSplines spl do
		(
		    local
				num = numKnots spl i,
				last_vi
			
			if isClosed spl i then 
			(
				-- open spline and duplicate first knot as last
				Open spl i
				AddKnot spl i #corner #line (GetKnotPoint spl i 1)
				UpdateShape spl
			)
				
			if (num > 1) then for j = 1 to num do
			(
				local v, vi = 0, k = 1
				
				v = GetKnotPoint spl i j
				
				-- check for existing vert
				while k <= verts.count AND vi == 0 do
				(
					if (distance v verts[k]) <= threshold.value then vi = k
					k+=1
				)
				
				if vi == 0 then
				( -- new vert
					append verts v
					append usage 0
					vi = verts.count
				)				
				
				if j > 1 then 
				(
					append links #(vi, last_vi)
					usage[vi] += 1
					usage[last_vi] += 1
				)
				
				last_vi = vi
			)	
		)
		
		-- now check what we got
		
		local
			last_node = 0, -- index of what will be used as exit node (-1)
			num_exits = 0, -- number of external nodes
			num_juncs = 0  -- number of internal nodes used more than twice (junctions)
			
		for i = 1 to verts.count do
		(
			if usage[i] == 1 then
			( -- external node
				num_exits += 1
				if last_node == 0 then last_node = i
			)
			else if usage[i] > 2 then
			( -- junction node
				num_juncs += 1
			)		
		)
		
		-- problem detector
		
		if (num_juncs == 0) then
		( -- no junctions, so use other algo
			MakeLinearSeg spl
			return true
		)
		else if (links.count > 11 OR verts.count > 12) then
		( -- too many nodes
			errormsg += "\n"+spl.name+" - more than 12 nodes not allowed for junctions"
			return false
		)
		else if (num_juncs > num_exits-2 OR verts.count <= links.count) then
		( -- circuit - todo: allow circuits
			errormsg += "\n"+spl.name+" - circuit detected, please split up the shape"
			return false
		)		
		-- separate spline detector: see below (after ordering)

		
		-- sort links: internal, external, to exit
		fn compareFN v1 v2 ln: u: =
		(
			local p1, p2
			
			p1 = case of
			(
				(v1[1] == ln OR v1[2] == ln): 2
				(u[v1[1]] == 1 OR u[v1[2]] == 1 ): 1
				default: 0
			)
			p2 = case of
			(
				(v2[1] == ln OR v2[2] == ln): 2
				(u[v2[1]] == 1 OR u[v2[2]] == 1 ): 1
				default: 0
			)
			
			p1 - p2
		)
		qsort links compareFN ln:last_node u:usage
		
		-- flip links if necessary
		fn flip v =
		(
			local tmp
			tmp = v[1]
			v[1] = v[2]
			v[2] = tmp
		)
		local flag = #(), order = #()
		
		--order[last_node] = links.count+1
		for i = links.count to 1 by -1 do
		(
			if flag[links[i][1]] == 1 OR links[i][1] == last_node OR (usage[links[i][2]] == 1 AND links[i][2] != last_node) then flip links[i]
			flag[links[i][1]] = 1
			--order[links[i][1]] = i
		)
		
		-- move 'to exit' node to top
		InsertItem links[links.count] links 1 
		DeleteItem links links.count
		
		-- store order
		order[last_node] = links.count+1
		for i = links.count to 1 by -1 do order[links[i][1]] = i
		
		-- check order for holes
		for i = 1 to order.count do	if order[i] == undefined then 
		( -- found one :o
			errormsg += "\n"+spl.name+" - interruption detected, not allowed for junctions"
			return false
		)
		
		-- test output
		--for i = 1 to verts.count do format "\n%. % * %" i verts[i] usage[i]
		--format "\n\nExit Node: %; External Nodes: %; Junction Nodes: %\n\n" last_node num_exits num_juncs
		--for i = 1 to links.count do format "% -> %\n" links[i][1] links[i][2]
		
		-- finally output the path data
		
		if comments.checked then format "\n\n# Shape \"%\"" spl.name
		format "\n%, -1" pathtype
		
		for i = 1 to links.count do
			PrintPathNode pathtype (if usage[links[i][1]] > 1 then 2 else 1) (order[links[i][2]]-1) verts[links[i][1]] settings
		
		PrintPathNode pathtype 1 -1 verts[last_node] settings
		
		PrintEmptyNodes (11 - links.count)			
	)
	
	
	on generate pressed do
	(
		ClearListener()
		errormsg = ""
		
		format "path"
		
		for spl in selection do if (iskindof spl Shape) then
		(				
			ConvertToSplineShape spl	
		
			-- get settings for this segment
			settings = (readsetting spl "p_width.value") as string + ", " + (readsetting spl "p_leftlanes.value") as string + ", " + (readsetting spl "p_rightlanes.value") as string + ", " + (readsetting spl "p_flag1.value") as string + ", " + (readsetting spl "p_flag2.value") as string + ", " + (readsetting spl "p_flag3.value") as string + ", " + (readsetting spl "p_flag4.value") as string
			pathtype = (readsetting spl "p_type.selection") - 1
		
			-- adjust color
			spl.wirecolor = typecols[pathtype+1]
	
			-- start junction algorithm
			MakeJunctionSeg spl
		)
		
		format "\nend\n"
		
		if errormsg != "" then messagebox ("The following shapes could not be exported as paths\ndue to errors:\n"+errormsg) title:"Warning!"
	)
) -- rollount

try (closeRolloutFloater gta_path) catch () 
gta_path = newRolloutFloater "GTA Path Generator" 180 446 20 130 
addRollout  GTAPATH2  gta_path