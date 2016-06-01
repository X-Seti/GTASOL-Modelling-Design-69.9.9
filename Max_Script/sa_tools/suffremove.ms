utility jatsuffixremove "Suffix Remove" width:162 height:300
(
	button srbtn "Remove X Characters" pos:[16,24] width:128 height:24
	spinner srspn "" pos:[104,56] width:46 height:16 range:[0,100,2] type:#integer scale:1
	GroupBox srgrp "Suffix Remove" pos:[8,8] width:144 height:72
	label lbl1 "Chars to remove:" pos:[16,56] width:80 height:16
	
	fn rename =
	(
		local oldname
		local newname
		
		for obj in $ do
		(
			oldname = obj.name
			newname = substring oldname 1 (oldname.count - srspn.value)
			obj.name = newname
		)
	)
	
	on srbtn pressed do
	(
		if $ != undefined then
		rename()
		else
		messagebox "Select object(s) first"
	)
)