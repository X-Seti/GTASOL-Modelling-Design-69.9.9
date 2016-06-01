--dexx tool launcher
--this file should be placed in the max\scripts\startup directory

utility Xscripts "Xscripts" width:162 height:300
(	
	button xscript01  "Run X Scripts Manager" align:#center
	fn runscript script =
	(
		fileIn script
	)	
	
	on xscript01 pressed do ( 
		try ( fileIn (scriptspath+"\\Xscripts\\MainX.ms") quiet:true   )
		catch messagebox "Please re-install X script!" title:"Can't find DFF IO script"
	)
)