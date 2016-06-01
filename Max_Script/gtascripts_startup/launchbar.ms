----------------------------------------------------------------------------------------------------------------
rollout scriptbar_rollout "GTA Scripts" width:190 height:149
----------------------------------------------------------------------------------------------------------------
(--Rollout Start
----------------------------------------------------------------------------------------------------------------
--interface button
	button scriptbar01 "2dfx Effects" width:95 align:#center  toolTip:"Whatever text you want in a floating bubble in max" across:2--this creates a button, within " " is the button name
--  make a button, buttonID, UI button name, button size, alignment, tooltip when you hover the mouse over the button
-- launch code for the buttons below
	on scriptbar01 pressed do -- this tells Max what to do when the button is pressed
		( 
			try ( fileIn (scriptspath+"\\gtascripts_startup\\2dfxrevise_release.ms") quiet:true) -- this line tells Max which folder the script is in, and which script to run
			catch messagebox "Re-install GTA Launchbar" title:"Can't find 2dfxrevise_release.ms Script " -- this is the error handling line that brings up a message box instead of this script crashing
		)	

	button scriptbar02 "Batch Map Export" width:95 align:#center toolTip:"Whatever text you want in a floating bubble in max" 
	on scriptbar02 pressed do 
		(
			try ( fileIn (scriptspath+"\\gtascripts_startup\\Batch_map_dff_export.ms") quiet:true) 
			catch messagebox "Can't find Batch_map_dff_export.ms Script " title:"Re-install GTA Launchbar" 
		)	
----------------------------------------------------------------------------------------------------------------
	button scriptbar03 "Blastov" width:95 align:#center toolTip:"Whatever text you want in a floating bubble in max" across:2
	on scriptbar03 pressed do 
		( 
			try ( fileIn (scriptspath+"\\gtascripts_startup\\blastov_rollout.ms") quiet:true) 
			catch messagebox "Re-install GTA Launchbar" title:"Can't find blastov_rollout.ms Script " 
		)	

	button scriptbar04 "Blastov utils" width:95 align:#center toolTip:"Whatever text you want in a floating bubble in max" 
	on scriptbar04 pressed do 
		(
			try ( fileIn (scriptspath+"\\gtascripts_startup\\blastov_utility.ms") quiet:true) 
			catch messagebox "Re-install GTA Launchbar" title:"Can't find blastov_utility.ms Script " 
		)			
----------------------------------------------------------------------------------------------------------------
	button scriptbar05 "Detach" width:95 align:#center toolTip:"Whatever text you want in a floating bubble in max" across:2
	on scriptbar05 pressed do 
		( 
			try ( fileIn (scriptspath+"\\gtascripts_startup\\detachbyID.ms") quiet:true) 
			catch messagebox "Re-install GTA Launchbar" title:"Can't find detachbyID.ms Script " 
		)	

	button scriptbar06 "Kams" width:95 align:#center toolTip:"Whatever text you want in a floating bubble in max" 
	on scriptbar06 pressed do 
		(
			try ( fileIn (scriptspath+"\\gtascripts_startup\\GTAScript_Controller.ms") quiet:true) 
			catch messagebox "Re-install GTA Launchbar" title:"Can't find GTAScript_Controller.ms Script " 
		)					
----------------------------------------------------------------------------------------------------------------
	button scriptbar07 "Deniska SA Tools" width:95 align:#center toolTip:"Whatever text you want in a floating bubble in max" across:2
	on scriptbar07 pressed do 
		( 
			try ( fileIn (scriptspath+"\\gtascripts_startup\\SA_scripts.ms") quiet:true) 
			catch messagebox "Re-install GTA Launchbar" title:"Can't find SA_scripts.ms Script " 
		)	

	button scriptbar08 "Object Explode" width:95 align:#center toolTip:"Whatever text you want in a floating bubble in max" 
	on scriptbar08 pressed do 
		(
			try ( fileIn (scriptspath+"\\gtascripts_startup\\object_explode.ms") quiet:true) 
			catch messagebox "Re-install GTA Launchbar" title:"Can't find object_explode.ms Script " 
		)							
----------------------------------------------------------------------------------------------------------------
	button scriptbar09 "SA Tools 2010" width:95 align:#center toolTip:"Whatever text you want in a floating bubble in max" across:2
	on scriptbar09 pressed do 
		( 
			try ( fileIn (scriptspath+"\\gtascripts_startup\\SA_scripts2010.ms") quiet:true) 
			catch messagebox "Re-install GTA Launchbar" title:"Can't find SA_scripts2010.ms Script " 
		)	

	button scriptbar10 "VC Paths" width:95 align:#center toolTip:"Whatever text you want in a floating bubble in max" 
	on scriptbar10 pressed do 
		(
			try ( fileIn (scriptspath+"\\gtascripts_startup\\VCPaths.ms") quiet:true) 
			catch messagebox "Re-install GTA Launchbar" title:"Can't find VCPaths.ms Script " 
		)
----------------------------------------------------------------------------------------------------------------		
	button scriptbar11 "X Tools" width:95 align:#center toolTip:"Whatever text you want in a floating bubble in max" across:2
	on scriptbar11 pressed do 
		( 
			try ( fileIn (scriptspath+"\\gtascripts_startup\\Xscripts.ms") quiet:true) 
			catch messagebox "Re-install GTA Launchbar" title:"Can't find Xscripts.ms Script " 
		)	

	button scriptbar12 "IV Script Centre" width:95 align:#center toolTip:"Whatever text you want in a floating bubble in max" 
	on scriptbar12 pressed do 
		(
			try ( fileIn (scriptspath+"\\gtascripts_startup\\GTAIV_Script_Centre.mse") quiet:true) 
			catch messagebox "Can't find GTAIV_Script_Centre.mse" title:"Re-install GTA Launchbar " 
		)										
----------------------------------------------------------------------------------------------------------------	
	label LabelCa "Gforce and X-Seti"
	label LabelDa "22nd September 2011"
	label LabelEa "www.gtaforums.com"   	
----------------------------------------------------------------------------------------------------------------
)--Rollout End
----------------------------------------------------------------------------------------------------------------
try (closeRolloutFloater script_flo) catch () 
script_flo = newRolloutFloater "GTA Script Launch Bar" 235 250 5 50
addRollout scriptbar_rollout script_flo rolledup:false