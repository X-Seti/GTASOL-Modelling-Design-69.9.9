utility Allen_Scripts "Allen's Manhunt2 Scripts" 
(
	button script01 "MDL IO" width:140 align:#center 
	on script01 pressed do (
		try ( fileIn (scriptspath+"\\Manhunt2_Tools\\MDL_IO.mse") quiet:true   )
		catch messagebox "Please re-install my MDL IO script!" title:"Can't find MDL IO script"
	)

)
openUtility Allen_Scripts