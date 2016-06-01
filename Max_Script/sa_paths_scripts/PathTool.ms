-------------------------------------------------------------------------------
helptxt = "GTA SA Path Tool

Version 0.2 / October 1st 2006
© 2006 by Steve M.
http://www.steve-m.com

This script exports vertex coordinates of the selected (spline) shapes to an
intermediate format used by PathTool.exe to compile path node files for
GTA San Andreas.

To create junctions, simply let the spline knots overlap. A junction node
can't have more than 15 branches."

-- For more information about path nodes in SA visit:
-- http://www.gtaforums.com/index.php?showtopic=214901
-------------------------------------------------------------------------------

utility GTAPATH "GTA SA Path Tool"
(
	local
		errormsg = "",
		typecols = #(green, red, blue, yellow, white) -- path type colors array (peds, cars, boats, other, default)

	group " Path Generator "
	(
		button generate "Generate Paths" tooltip:"Generates path data from selected shapes."
		checkbox compile "Execute Compiler" checked:false enabled:false align:#center

	)
	group " Segment Settings "
	(
		-- General --
		radiobuttons p_type labels:#("Peds", "Vehicles") default:2 columns:2
		spinner p_width "Path Width:" range:[0,31.875,0] type:#float fieldwidth:50
		spinner p_id "Path ID:" range:[0,255,1] type:#integer fieldwidth:50

		-- Flags --
		dropdownlist p_traffic "Traffic:" items:#("Full", "Medium", "Low", "None") selection:1
		checkbox p_roadblock "Roadblock Flag" checked:false
		checkbox p_boats "Boat Flag" checked:false
		checkbox p_emergency "Emergency Veh. Only" checked:false
		checkbox p_highway "Highway Flag(s)" checked:false
		checkbox p_parking "Parking Flag" checked:false
		
		label lblLanes "Right / Left Lanes" offset:[0,8]
		spinner l_right range:[0,7,1] type:#integer align:#right across:2
		spinner l_left range:[0,7,1] type:#integer align:#left

		-- Buttons --
		button store_settg "Store" offset:[0,8] across:2 width:65 tooltip:"Stores current segment settings in the user properties of selected shapes."
		button retr_settg "Retrieve" offset:[0,8] width:65 tooltip:"Retrieves segment settings from the user properties of the FIRST selected shape, if available."
		button clear_settg "Clear User Props" width:133 tooltip:"Clears the user properties buffer of the selected shapes, so default segment settings will be used."
	)
	button help "About / Help" width:153 tooltip:"Display about information and help text."
	on help pressed do MessageBox helptxt title:"About GTA SA Path Tool" beep:false
	
	on p_type changed state do
	(
		p_roadblock.enabled = (state == 2)
		p_boats.enabled = (state == 2)
		p_highway.enabled = (state == 2)
		p_parking.enabled = (state == 2)
		l_right.enabled = (state == 2)
		l_left.enabled = (state == 2)
		
		if state == 2 then p_id.value = (1 + p_boats.tristate) else p_id.value = 0
	)
	on p_boats changed state do if state then p_id.value = 2 else p_id.value = 1
	on p_emergency changed state do if state then p_traffic.selection = 3 else p_traffic.selection = 1
	on p_parking changed state do if state then	(
		p_emergency.checked = true
		p_traffic.selection = 4
	) else (
		p_emergency.checked = false
		p_emergency.changed false
	)


	function GetColor type id =
	(
		if (type == 1) then
			typecols[1]
		else if (id == 1) then
			typecols[2]
		else if (id == 2) then
			typecols[3]
		else
			typecols[4]
	)


	function ReadSetting obj item =
	(
		userprop = GetUserProp obj item
		if userprop != undefined then userprop else execute ("GTAPATH."+item)
	)

	on store_settg pressed do
	(
		for obj in selection do if (iskindof obj Shape) then
		(
			SetUserProp obj "p_type.state" p_type.state
			SetUserProp obj "p_width.value" p_width.value
			SetUserProp obj "p_id.value" p_id.value
			obj.wirecolor = GetColor p_type.state p_id.value

			SetUserProp obj "p_traffic.selection" p_traffic.selection
			SetUserProp obj "p_roadblock.triState" p_roadblock.triState
			SetUserProp obj "p_boats.triState" p_boats.triState
			SetUserProp obj "p_emergency.triState" p_emergency.triState
			SetUserProp obj "p_highway.triState" p_highway.triState
			SetUserProp obj "p_parking.triState" p_parking.triState
			
			SetUserProp obj "l_right.value" l_right.value
			SetUserProp obj "l_left.value" l_left.value
		)
	)
	on retr_settg pressed do
	(
		obj = selection[1]
		if (iskindof obj Shape) then
		(
			p_type.state = ReadSetting obj "p_type.state"
			p_type.changed p_type.state
			p_width.value = ReadSetting obj "p_width.value"
			p_id.value = ReadSetting obj "p_id.value"

			p_traffic.selection = ReadSetting obj "p_traffic.selection"
			p_roadblock.triState = ReadSetting obj "p_roadblock.triState"
			p_boats.triState = ReadSetting obj "p_boats.triState"
			p_emergency.triState = ReadSetting obj "p_emergency.triState"
			p_highway.triState = ReadSetting obj "p_highway.triState"
			p_parking.triState = ReadSetting obj "p_parking.triState"
			
			l_right.value = ReadSetting obj "l_right.value"
			l_left.value = ReadSetting obj "l_left.value"
		)
	)
	on clear_settg pressed do
	(
		for obj in selection do if (iskindof obj Shape) then
		(
			SetUserPropBuffer obj ""
			obj.wirecolor = typecols[5]
		)
	)



	on generate pressed do
	(
		--ClearListener()
		errormsg = ""

		s_path = getSaveFileName types:"Path Segment Listing (*.txt)|*.txt"
		if s_path != undefined then
		(
			out = CreateFile s_path
			format "// GTA SA Path Segment Listing\n// Exported %\n" localtime to:out

			for spl in selection do if (iskindof spl Shape) then
			(
				local settings, pathtype, pathid
				
				ConvertToSplineShape spl	
		
				-- get type and ID for this spline
				pathtype = (readsetting spl "p_type.state")
				pathid   = (readsetting spl "p_id.value")	
	
				-- adjust color
				spl.wirecolor = GetColor pathtype pathid

				-- print section header
				format "\n%_path % {\n\n" (if (pathtype == 1) then "ped" else "vehicle") spl.name to:out

				-- print settings
				if pathtype == 1 then  -- peds
				(
					format "\tdefault %, %, %, ,, %\n" (ReadSetting spl "p_width.value") pathid ((ReadSetting spl "p_traffic.selection")-1) (ReadSetting spl "p_emergency.triState") to:out
				) else (
					format "\tdefault %, %, %, %, %, %, ,,, %, %, ,,,,,,, %\n" (ReadSetting spl "p_width.value") pathid ((ReadSetting spl "p_traffic.selection")-1) (ReadSetting spl "p_roadblock.triState") (ReadSetting spl "p_boats.triState") (ReadSetting spl "p_emergency.triState") (1 - ReadSetting spl "p_highway.triState") (ReadSetting spl "p_highway.triState") (ReadSetting spl "p_parking.triState") to:out
					format "\tlanes %, %\n" (ReadSetting spl "l_right.value") (ReadSetting spl "l_left.value") to:out
				)

				-- iterate through splines and print them
				for i = 1 to numSplines spl do
				(
					num = numKnots spl i
					if isClosed spl i then num = num + 1
					format "\n\tsegment {  // #%\n\t\t%\n" i num to:out

					for j = 1 to numKnots spl i do
					(
						v = getKnotPoint spl i j
						format "\t\t%, %, %\n" v.x v.y v.z to:out
					)
					
					if isClosed spl i then
					(
						-- print first knot again
						v = getKnotPoint spl i 1
						format "\t\t%, %, %\n" v.x v.y v.z to:out
					)

					format "\t}\n" to:out
				)

				format "}\n" to:out
			)

			close out

			if errormsg != "" then messagebox ("The following shapes could not be exported as paths\ndue to errors:\n"+errormsg) title:"Warning!"
		)
	)
)
openUtility GTAPATH