if DFFoutInfo == undefined then fileIn (scriptspath+"\\GTA_Tools\\gtaDFFout_Fn.mse") quiet:true 
else if DFFoutInfo() < 051026 then fileIn (scriptspath+"\\GTA_Tools\\gtaDFFout_Fn.mse") quiet:true
if DFFoutInfo() < 051026 then messagebox "You didn't have the right export function to run this script!\nTry Install it again!" title:"Import Function Error" 


fn batmapdff fpath ver = (
	total_dff = SelectionSets.count
	for i = 1 to total_dff do (
		tmp = SelectionSets[i] as string
		dff_name = substring tmp 14 (tmp.count - 13)
		select SelectionSets[i]
		format "exporting %.dff\n" dff_name
		f = fopen (fpath + "\\" + dff_name + ".dff") "wb"
		DFFout f $selection false true true false 1.0 ver undefined 1 false
		fclose f
	)--end for i
)

fn BatchHelp = (
	messagebox "1. You need to import ipl from MAP IO\n2. Select the Export Path first" title:"How to use this script"
)

rollout batchmapexp_Roll "" (
	button ipath "Path" width:45 align:#left across:2
	edittext tpath "" width:110 align:#left offset:[-30,2]
	on ipath pressed do (
		imgpath = getSavePath caption:"Locate DFF Path"
		if imgpath != undefined then tpath.text = imgpath
		else tpath.text = ""
	)--end on ipath

	button BG3 "Convert to  GTA3  DFF" width:150  
	button BVC "Convert to    VC    DFF" width:150 offset:[0,-4]
	button BSA "Convert to    SA    DFF" width:150 offset:[0,-4]
	on BG3 pressed do (
		if (tpath.text.count > 3)AND(SelectionSets.count > 0) then (
			batmapdff tpath.text 0x0800FFFF
		) else ( BatchHelp() )
	)--end BG3
	on BVC pressed do (
		if (tpath.text.count > 3)AND(SelectionSets.count > 0) then (
			batmapdff tpath.text 0X0C02FFFF
		) else ( BatchHelp() )
	)--end BVC
	on BSA pressed do (
		if (tpath.text.count > 3)AND(SelectionSets.count > 0) then (
			batmapdff tpath.text 0x1803FFFF
		) else ( BatchHelp() )
	)--end BSA	
	
	group "About" (
		label lbl01 "A handy tool to Batch convert" 
		label lbl02 "GTA Map dff's across GTA3\VC\SA" 
		label lbl03 " "
		label lbl04 "by Kam" align:#right
		label lbl05 "kam.lai@ntlworld.com" align:#right
	)
)--end rollout

if Kam_batchmapexp != undefined then ( closeRolloutFloater Kam_batchmapexp; gc() )
Kam_batchmapexp = newRolloutFloater "Batch Map DFF Exporter" 250 280 10 50
addRollout batchmapexp_Roll Kam_batchmapexp