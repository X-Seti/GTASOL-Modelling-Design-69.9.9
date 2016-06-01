--Den_sa launcher
--this file should be placed in the max\scripts\startup directory

utility Den_sa "NightVert" width:162 height:100
(
	GroupBox grp4 "Launch" pos:[8,8] width:144 height:80 enabled:true
	button btn_runDen_sa "Nightvert" pos:[16,24] width:128 height:20
	fn runscript script =
	(
		fileIn script
	)
	
	on btn_runDen_sa pressed do
	(
		--launch Nightvert script
		script = ("scripts\\NightVertCol_final.ms")
		runscript(script)
	)
)