--dexx tool launcher
--this file should be placed in the max\scripts\startup directory

utility dexxtools "Dexx SA Tools" width:162 height:300
(
	GroupBox grp4 "Launch" pos:[8,8] width:144 height:110 enabled:true
	button btn_runsaeffects "Run SA Effects" pos:[16,24] width:128 height:20
	GroupBox grp6 "Info" pos:[8,128] width:144 height:112 enabled:true
	label lbl11 "DexX @ gtaforums.com" pos:[16,176] width:120 height:16
	label lbl12 "You may contact me via the following:" pos:[16,144] width:128 height:24
	label lbl13 "All tools 2004-2007, by Me, unless otherwise noted." pos:[16,208] width:128 height:24
	
	fn runscript script =
	(
		fileIn script
	)
	
	on btn_runsaeffects pressed do
	(
		--launch sa effects script
		script = ("scripts\\dexx_gta\\2dfxrevise_release.ms")
		runscript(script)
	)
)