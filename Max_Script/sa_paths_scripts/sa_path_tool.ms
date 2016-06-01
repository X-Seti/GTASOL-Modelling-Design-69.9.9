-------------------------------------------------------------------------------
helptxt = "GTA SA Path Tool"
-------------------------------------------------------------------------------

rollout GTAPATH_ROL "SA Path Tool"
(
	local
		errormsg = "",
		typecols = #(green, red, blue, yellow, white) -- path type colors array (peds, cars, boats, other, default)

	group " Path Generator "
	(
		button generate "Generate Paths" tooltip:"Generates path data from selected shapes."
		--checkbox compile "Execute Compiler" checked:false enabled:false align:#center

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
	    try ( fileIn (scriptspath+"\\sa_paths_scripts\\path_export.ms") quiet:true   )
        catch messagebox "Can't find pathsExport script" \
                          title:"export error"
	)
) -- roll















vrts = #(\
[-0.1,-0.1,0], [0.1,-0.1,0], [-0.1,0.1,0], [0.1,0.1,0], [-0.1,-0.1,2], [0.1,-0.1,2], \
[-0.1,0.1,2], [0.1,0.1,2], [-0.15,-0.42,2], [0.15,-0.42,2], [-0.15,0.42,2], [0.15,0.42,2], \
[-0.15,-0.42,4.07], [0.15,-0.42,4.07], [-0.15,0.42,4.07], [0.15,0.42,4.07], [0.14,-0.29,3.42], [0.19,-0.29,3.42], \
[0.14,0.29,3.42], [0.19,0.29,3.42], [0.14,-0.29,3.93], [0.19,-0.29,3.93], [0.14,0.29,3.93], [0.19,0.29,3.93], \
[0.14,-0.28,2.75], [0.19,-0.28,2.75], [0.14,0.28,2.75], [0.19,0.28,2.75], [0.14,-0.28,3.25], [0.19,-0.28,3.25], \
[0.14,0.28,3.25], [0.19,0.28,3.25], [0.14,-0.25,2.13], [0.19,-0.25,2.13], [0.14,0.25,2.13], [0.19,0.25,2.13], \
[0.14,-0.25,2.56], [0.19,-0.25,2.56], [0.14,0.25,2.56], [0.19,0.25,2.56])

fcs = #(\
[1,2,6], [6,5,1], [2,4,8], [8,6,2], [4,3,7], [7,8,4], \
[3,1,5], [5,7,3], [9,11,12], [12,10,9], [13,14,16], [16,15,13], \
[9,10,14], [14,13,9], [10,12,16], [16,14,10], [12,11,15], [15,16,12], \
[11,9,13], [13,15,11], [17,19,20], [20,18,17], [21,22,24], [24,23,21], \
[17,18,22], [22,21,17], [18,20,24], [24,22,18], [20,19,23], [23,24,20], \
[25,27,28], [28,26,25], [29,30,32], [32,31,29], [25,26,30], [30,29,25], \
[26,28,32], [32,30,26], [28,27,31], [31,32,28], [33,35,36], [36,34,33], \
[37,38,40], [40,39,37], [33,34,38], [38,37,33], [34,36,40], [40,38,34], \
[36,35,39], [39,40,36])

vcol = #(\
(color 90 90 90), (color 90 90 90), (color 90 90 90), (color 90 90 90), (color 90 90 90), (color 90 90 90), \
(color 90 90 90), (color 90 90 90), (color 90 90 90), (color 90 90 90), (color 90 90 90), (color 90 90 90), \
(color 90 90 90), (color 90 90 90), (color 90 90 90), (color 90 90 90), (color 255 0 0), (color 255 0 0), \
(color 255 0 0), (color 255 0 0), (color 255 0 0), (color 255 0 0), (color 255 0 0), (color 255 0 0), \
(color 255 255 0), (color 255 255 0), (color 255 255 0), (color 255 255 0), (color 255 255 0), (color 255 255 0), \
(color 255 255 0), (color 255 255 0), (color 0 255 0), (color 0 255 0), (color 0 255 0), (color 0 255 0), \
(color 0 255 0), (color 0 255 0), (color 0 255 0), (color 0 255 0))

--------------------------------------------------------------------------------------------------------------------------------------

fn createSvetofor S SegIndex andgle = (
local i, m, pos

    m = mesh vertices:vrts faces:fcs pos:[6,0,0]

    for i = 1 to 50 do
        setEdgeVis m i 3 false

    defaultVCFaces m
    for i = 1 to 40 do
    	  setVertColor m i vcol[i]		

    meshop.autoSmooth m #all 45.0
    m.showVertexColors = true
    m.vertexColorType = #color

    update m
	pos = ((getKnotPoint s 1 SegIndex) + (getKnotPoint s 1 (SegIndex+1)))/2
    m.position = pos
	m.parent = s
	setUserProp m "segment" SegIndex
	setUserProp m "type" 1
    m.name = "TrafficLight"
	m
)


--------------------------------------------------------------------------------------------------------------------------------------

rollout TL_ROL " Traffic Light Set "
(
	
	   button create_TL "Create" width:100 offset:[0,4]
	   label lblOff "Offset  " align:#left across: 2 offset:[0,4]
	   spinner move_TL "" range:[0.0, 1.0, 0.5] type:#float scale:0.01 align:#right width:45 offset:[0,4]
	   label lblDir "Direction" align:#left
       dropdownlist dir_TL items:#("North", "South", "East", "West") selection:3

	on create_TL pressed do
	if $!=undefined then (
	obj = selection[1]
	if ClassOf obj==line or ClassOf obj == SplineShape then
	 if numSplines obj != 1 then messageBox "splineShape must have only 1 spline"
	 else 
	   if IsClosed obj 1 then messageBox "splineShape must be open"
	   else (
	    SegSel = getSegSelection obj 1
		if SegSel.count == 0 then messagebox "no segment selected"
		else (
		   case dir_TL.selection of
		   ( 1: angle = 90
		     2: angle = -90
			 3: angle = 0
			 4: angle = 180
		   default:0
		   )
		   TraffLight = createSvetofor obj segSel[1] angle
		)
	)
	else messageBox "object is not SplineShape"
	) -- on create TL


	on dir_TL selected val do if $!=undefined then (
	   obj = selection[1]
	   n = getUserProp obj "segment"
	   if n!=undefined then (
	      case val of 
		( 1: (obj.rotation.z_rotation = 90)
		  2: (obj.rotation.z_rotation = -90)
		  3: (obj.rotation.z_rotation = 0)
		  4: (obj.rotation.z_rotation = 180)
		)
	   )
	) -- on dir_TL
	
	on move_TL changed val do
	if $!=undefined then (
	   obj = selection[1]
	   n = getUserProp obj "segment"
	   if n!=undefined then (
	      pobj = obj.parent
		  if pobj!=undefined then (
		     p1 = getKnotPoint pobj 1 n
			 p2 = getKnotPoint pobj 1 (n+1)
			 obj.position = p1 + val*(p2 - p1)
          )		 
	   )
	)
) -- TRAFLIG ROLL
--------------------------------------------------------------------------------------------------------------------------------------



try (closeRolloutFloater GTAPATH_FLO) catch ()
GTAPATH_FLO = newRolloutFloater "" 180 590 20 130
addRollout  GTAPATH_ROL GTAPATH_FLO
addRollout  TL_ROL GTAPATH_FLO