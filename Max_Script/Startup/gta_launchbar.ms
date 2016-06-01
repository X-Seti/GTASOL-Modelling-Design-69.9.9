utility GTA_Scripts "GTA Scripts Launchbar " 
(
	button script01 "Launch Bar" width:140 align:#center toolTip:"Whatever text you want in a floating bubble in max" --this creates a button, within " " is the button name
	on script01 pressed do
		( 
			try ( fileIn (scriptspath+"\\gtascripts_startup\\launchbar.ms") quiet:true) -- this line tells Max where the launchbar script is
			catch messagebox "Re-install GTA Launchbar" title:"Can't find launchbar.ms Script " -- this is the error handling line that brings up a message box instead of the script crashing
		)	
	label LabelC "Gforce and X-Seti"
	label LabelD "22nd September 2011"
	label LabelE "www.gtaforums.com"   	
)
openUtility GTA_Scripts