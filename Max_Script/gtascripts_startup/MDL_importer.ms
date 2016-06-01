--Den_sa launcher
--this file should be placed in the max\scripts\startup directory

utility Mdl "MDL importer" width:162 height:100
(
	GroupBox grp4 "Launch" pos:[8,8] width:144 height:80 enabled:true
	button btn_runMdl "MDL_importer" pos:[16,24] width:128 height:20
	fn runscript script =
	(
		fileIn script
	)
	
	on btn_runMdl pressed do
	(
		--launch MDL_importer script
		script = ("scripts\\MDL_importer.ms")
		runscript(script)
	)
)