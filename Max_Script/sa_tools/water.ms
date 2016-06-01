rollout part1 "Objects"
(
	group "Objects"
	(		
		button imp_wat "Import water.dat" width:86 align:#left toolTip:"Import water.dat" offset:[0,-5]
		button exp_wat "Export water.dat" width:86 align:#right toolTip:"Export water.dat" offset:[0,-26]
	)				

on exp_wat pressed do
	(
		TXT = getSaveFileName types:"SA Water (*.dat)|*.dat" 
		if TXT != undefined then
		(		
			txt = createFile (TXT)
			format "# water.dat\n# by ocram88\n\nprocessed\n" to:txt
			for obj in selection do (
			if iskindof obj editable_mesh then
	     		(
				if obj.numverts == 4 then
				(
			    		format "% % % 0.0 0.0 0.25 0.0	% % % 0.0 0.0 0.25 0.0	% % % 0.0 0.0 0.25 0.0	% % % 0.0 0.0 0.25 0.0  1\n" obj.verts[1].pos.x obj.verts[1].pos.y obj.verts[1].pos.z obj.verts[2].pos.x obj.verts[2].pos.y obj.verts[2].pos.z obj.verts[3].pos.x obj.verts[3].pos.y obj.verts[3].pos.z obj.verts[4].pos.x obj.verts[4].pos.y obj.verts[4].pos.z to:txt
				)
				else
				(
					messagebox "Object has not 4 vertex points"
				)
			)
			else
			(
				--messagebox "Object not an editable mesh"
			)
			) --end for obj in sel
			close txt
		)
	)	





	on imp_wat pressed do
	(
		TXT = getOpenFileName types:"SA Water (*.dat)|*.dat" 
		if TXT != undefined then
		(		
			txt = openFile TXT
			n = 0
			max select none
			while not eof txt do
			(
				line = readline txt
			
				if line != "" then
				(
					data = filterString line " 	"
					if (data[1] != "#")and(data[1] != "processed") then
					(
						a = ((data[1]) as float)
						b = ((data[8]) as float)
						c = ((data[2]) as float)
						d = ((data[16]) as float)
						x_pos = ((b+((a-b)/2)) as float)
						y_pos = ((c+((d-c)/2)) as float)
						z_pos = ((data[3]) as float)
			    			--format "% % % %\n" a b c d

						e = a-b
						f = c-d
						if e <= -1 then e = e * (-1)
						if f <= -1 then f = f * (-1)
			    			--format "% %\n" e f
						n = n+1
						p = plane length:f width:e lengthsegs:1 widthsegs:1 name:("Water "+(n as string))
						move p [x_pos,y_pos,z_pos]
						--select p
						convertToMesh p
						p.wirecolor = (color 88 143 225)
					)
				)			
			)
			close txt
		)
	)







)-- end of rollout

rollout aboutrollout "About"
(
	label LabelA "Create water.dat"
	label LabelB "X,Y Coords must be rounded numbers"
	label LabelC "by ocram88"
)-- end of rollout

if wat != undefined then closeRolloutFloater wat
wat = newRolloutFloater "Water v1.0" 220 173 10 100		
addRollout part1 wat rolledup:false
addRollout aboutrollout wat rolledup:false
