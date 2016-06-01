-- JostVice, copyright 6/5/2009
-- for contact, do www.gtaforums.com
-- else Horizont3D@Gmail.com == EMAIL != MSN
-- yes, that ^ is syntaxed. That email doesn't work as MSN so don't bother adding it.
-- Anyway, you shouldn't be looking at this... >:(
-- Gforce, don't copy my code!

cool = newRolloutFloater "SA ZON Importer" 228 260
--addRollout abohlp cool rolledup:true
Rollout params "Main"
(
	group "Import/Export ZONE" (
		button zondmp "Open *.zone file" width:146
		button zonexp "Export INFO.zon" width:90 across:2
		button mapexp "Export MAP.zon" width:90 align:#right
		--radiobuttons ztype labels:#("Info.zon", "Map.zon") default:1
	)
		group "Edit info" (
		button zoneset "Set info" width:66 across:2 
		button zoneret "Retrieve info" width:73 
		radiobuttons zislands labels:#("Los Santos", "San Fierro", "Las Venturras")
		edittext zgtx "GTX Name:"
	)
	on zondmp pressed do (
		zonopenname = getOpenFileName caption:"Open GTASA ZON file" types:"GTASA ZON file (*.zon)|*.zon|"
		zonname = openfile zonopenname
		if zonname != undefined do
		(
			while not eof zonname do
		    (
		        line = readLine zonname --We start reading the file
		        if line == "zone" do
		        (
		            format "Begin zone import\n" to:listener
		            ZONEIMPORT = true -- we found the zone section so switch to import mode
			        continue
		        )
				
		        if line == "end" do 
		        (
		            format "Done ZONE import\n" to:listener --the file has end
		            continue
		        )
			    if ZONEIMPORT == true do  
			    (
				args = filterstring line ","
				X1 = args[3] as float
				X2 = args[6] as float
				Y1 = args[4] as float
				Y2 = args[7] as float
				Z1 = args[5] as float
				Z2 = args[8] as float
				W = X2 - X1 --Cool math operations, idea by me
				L = Y2 - Y1
				H = Z2 - Z1
				X = (W / 2.0) + X1
				Y = (L / 2.0) + Y1
				b = box name:args[1] width:W length:L height:H pos:[X,Y,Z1]
				SetUserProp b "zislandss" args[9]
				SetUserProp b "gtxentry" args[10]
				b.xray = true --This is so the box is see-trought
				format "Imported % W % L % H % at %\n" b.name b.width b.length b.height b.pos to:listener --dumps info to listener
			    continue
			    )
			)
		) 
	)--end on zondmp

	on zoneset pressed do --when the set info button is pressed...
	(
	if $ != undefined then
		for zoneh in $ do
		(
			if classof(zoneh) == Box then --If the selected model is a box
			(
			SetUserProp zoneh "zislandss" zislands.state --apply to the user info the selected stuff
			SetUserProp zoneh "gtxentry" zgtx.text
			zoneh.xray = true
			)
		)
	)
	on zoneret pressed do 
	(
	if $ != undefined then
		for zoneh in $ do
		(
			if classof(zoneh) == Box then --If the selected model is a box
			(
			zislands.state = getUserProp zoneh "zislandss" --we get the info from the user properties
			zgtx.text = getUserProp zoneh "gtxentry"
			)
		)
	)
	on zonexp pressed do --Exporting the info.zon file 
	(
		zonep = getSaveFileName types:"GTASA ZON file (*.zon)|*.zon|" 
		if zonep != undefined then
		(		
			zonep = createFile (zonep)
			format "#info.zon file generated with JostVice's JV-Zone script\nzone\n" to:zonep
			
		if $ != undefined then
		for zoneh in $ do
		(
			if classof(zoneh) == Box then
			(
				Xx1 = zoneh.pos.X - (zoneh.width / 2.0) -- Cool maths, done by me :P
				Yy1 = zoneh.pos.Y - (zoneh.length  / 2.0) 
				Zz1 = zoneh.pos.Z
				Xx2 = zoneh.pos.X + (zoneh.width / 2.0) 
				Yy2 = zoneh.pos.Y + (zoneh.length  / 2.0) 
				Zz2 = zoneh.pos.Z + zoneh.height  
				zislexp = getUserProp zoneh "zislandss"
				zgtxexp = getUserProp zoneh "gtxentry"
				format "%, 0, %, %, %, %, %, %, %, %\n" zoneh.name Xx1 Yy1 Zz1 Xx2 Yy2 Zz2 zislexp zgtxexp to:zonep
			)			
			else
			format "% is not a box %\n" obj.name
		)
		format "end\n" to:zonep
		close zonep
		)
	)
	on mapexp pressed do --exporting the map.zon file
	(
		zonep = getSaveFileName types:"GTASA ZON file (*.zon)|*.zon|" 
		if zonep != undefined then
		(		
			zonep = createFile (zonep)
			format "#map.zon file generated with JostVice's JV-Zone script\nzone\n" to:zonep
			
		if $ != undefined then
		for zoneh in $ do
		(
			if classof(zoneh) == Box then
			(
				Xx1 = zoneh.pos.X - (zoneh.width / 2.0) -- Cool maths, done by me :P
				Yy1 = zoneh.pos.Y - (zoneh.length  / 2.0) 
				Zz1 = zoneh.pos.Z
				Xx2 = zoneh.pos.X + (zoneh.width / 2.0) 
				Yy2 = zoneh.pos.Y + (zoneh.length  / 2.0) 
				Zz2 = zoneh.pos.Z + zoneh.height  
				zislexp = getUserProp zoneh "zislandss"
				zgtxexp = getUserProp zoneh "gtxentry"
				format "%, 3, %, %, %, %, %, %, %, %\n" zoneh.name Xx1 Yy1 Zz1 Xx2 Yy2 Zz2 zislexp zgtxexp to:zonep
			)			
			else
			format "% is not a box %\n" obj.name
		)
		format "end\n" to:zonep
		close zonep
		)
	)
)
Rollout abohlp "About/Help"
(
	label a1 " " 
	label a2 "About: Version 1.0" 
	label a3 " " 
	label a4 "by JostVice" align:#left across:2
	label a5 "6/april/2009" align:#right
	label a6 "www.gtaforums.com - horizont3D@gmail.com"
	label a7 " "	
	label a8 "Help: "
	label a9 " "
	label a10 "Import your zone file, remember there are " align:#left
	label a11 "two types: Info.zon and Map.zon." align:#left
	label a12 "Select one of the new boxes and press " align:#left
	label a13 "'retrieve' to get that zone info" align:#left
	label a14 "You can modify the info (island and GTX)" align:#left
	label a15 "then press 'set' button to apply the info" align:#left
	label a16 "you can aply info to new boxes too" align:#left
	label a17 "	"
	label a18 "To export your zones, select all the zones" align:#left
	label a19 "(Remember to have the info set)" align:#left
	label a20 "And export whatever file you want." align:#left
	label a21 "	"
	label a22 "READ README" 
	label a23 "FOR BETTER EXPLANATION!!!" 
)
addRollout params cool
addRollout abohlp cool rolledup:true
