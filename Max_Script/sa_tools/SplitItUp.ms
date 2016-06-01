--Split It Up script by Carl-Mikael Lagnecrantz for CG Talk challenge--

global CGSplitchunks
global CGSplitpos

fn CGSplit_interface =
(
	rollout CGSplitroll "Split it"
	(
		
		button splitbutt "Split" width: 62 height: 22 align:#center tooltip: "Split up model to chunks."
		spinner splitspin "Levels:" range:[1,100,10] type:#integer align:#center fieldwidth:36
		checkbox splitcheck "Seperate objects" checked:true
		checkbox splitcheck2 "Build inner topology" checked:false
		checkbox splitcheck3 "Set Material ID's" checked:true
		checkbox splitcheck4 "Mess up inside!" checked:false
		radiobuttons splitrad "" labels:#("Type 1","Type 2") default: 1 columns: 2 enabled:false
		spinner splitspin3 "Mess amount:" range:[0.0,10000.0,0.0] align:#center fieldwidth:46 enabled:false
		group "Check result:"
		(
		spinner splitspin2 "Move chunks:" range:[0.0,10000.0,0.0] align:#center fieldwidth:46
		)
		
		on splitcheck changed state do splitspin2.enabled = state
		on splitcheck4 changed state do (splitspin3.enabled = state ; splitrad.enabled = state)
		on splitbutt pressed do 
			(
			if selection.count == 1 and classof $ == Editable_Poly then undo off
				(
				setWaitcursor()
				try(suspendEditing())catch()
				numval = splitspin.value
				polyop.setFaceSelection $.baseobject #all
				distMin = $.min-$.pivot
				distMax = $.max-$.pivot
				for i = 1 to numval do --split up object with slice mod and cap holes
					(
					addmodifier $ (SliceModifier slice_type:1)
					randomrot = quat (random -1.0 1.0) (random -1.0 1.0) (random -1.0 1.0) (random -1.0 1.0)
					$.modifiers[#Slice].Slice_Plane.rotation = randomrot
					randpos = [(random distMin.x distMax.x),(random distMin.y distMax.y),(random distMin.z distMax.z)]
					$.modifiers[#Slice].Slice_Plane.position = randpos
					convertTo $ Editable_Poly
					polyOp.capHolesByEdge $.baseobject #all
					if keyboard.escpressed == true do exit
					)
				try(resumeEditing())catch()
				disablesceneredraw()
				if splitcheck2.state == true do --build inner topology by selecting inside verts and connectiong, then removing created edges on the outside
					(
					inif = polyop.getFaceSelection $.baseobject
					allaf = polyop.getNumFaces $.baseobject
					innerf = #{1..allaf} - inif
					oute = polyop.getEdgesUsingFace $.baseobject inif
					polyop.setVertSelection $.baseobject (polyop.getVertsUsingFace $.baseobject innerf)
					$.EditablePoly.ConnectVertices ()
					oute2 = polyop.getEdgesUsingFace $.baseobject (polyop.getFaceSelection $.baseobject)
					polyop.setEdgeSelection $.baseobject (oute2-oute)
					$.remove selLevel:#Edge
					)
				if splitcheck3.state == true do --set material ID's
					(
					inif = polyop.getFaceSelection $.baseobject
					polyOp.setFaceMatID $.baseobject inif 1
					allaf = polyop.getNumFaces $.baseobject
					inf = #{1..allaf} - inif
					polyOp.setFaceMatID $.baseobject inf 2
					)
				if splitcheck4.state == true do --mess up inside by tesselating the inside faces and moving the resulting verts randomly
					(
					$.tesselateBy = splitrad.state - 1
					inif = polyop.getFaceSelection $.baseobject
					allaf = polyop.getNumFaces $.baseobject
					inf = #{1..allaf} - inif
					polyop.setFaceSelection $.baseobject inf
					polyOp.tessellateByFace $.baseobject inf
					polyOp.tessellateByFace $.baseobject (polyop.getFaceSelection $.baseobject)
					allef = polyop.getNumFaces $.baseobject
					ino = #{1..allef} - (polyop.getFaceSelection $.baseobject)
					allav = polyop.getNumVerts $.baseobject
					innv = #{1..allav} - (polyop.getVertsUsingFace $.baseobject ino)
					for w in innv do
						(
						randvec = normalize ([(random 0.0 10.0),(random 0.0 10.0),(random 0.0 10.0)] - [(random 0.0 10.0),(random 0.0 10.0),(random 0.0 10.0)])
						curp = polyop.getVert $.baseobject w node:$
						polyop.setVert $.baseobject w (curp + (randvec * splitspin3.value)) node:$
						)
					)
				if splitcheck.state == true then --explode elements to seperate objects
					(
					Selobj = $
					splitval = 0
					max select all
					while splitval == 0 do --get a random face and detach the element wich the face is on, then select a new random face and so on until there is no faces left
						(
						elmf = polyop.getElementsUsingFace Selobj.baseobject 1
						polyOp.detachFaces Selobj.baseobject elmf delete:true asNode:true node:Selobj
						if (polyop.getNumFaces Selobj.baseobject) == 0 do (splitval = 1 ; delete Selobj)
						if keyboard.escpressed == true do (splitval = 1 ; delete Selobj)
						)
					max select invert
					CGSplitchunks = selection as array --put all the chunks into an array for later moving
					CGSplitpos = for p in CGSplitchunks collect p.pos --put the positions of all chunks into an array
					)
				else (CGSplitchunks = #() ; CGSplitpos = #())
				enablesceneredraw()
				setArrowcursor()
				gc()
				redrawviews()
				)
			else messagebox "Yes dude...\nIt needs to be an Editable polygon object!" title:"Split It Up!"
			)
		on splitspin2 changed value do undo off
			(
			if CGSplitchunks.count != 0 do --move all chunks
				try(
				selnum = 0
				allpos = [0,0,0]
				for d in CGSplitchunks do (selnum += 1 ; allpos += d.center)
				midpos = allpos/selnum
				for w = 1 to selnum do
					(
					levec = normalize (CGSplitchunks[w].center-midpos)
					CGSplitchunks[w].pos = CGSplitpos[w] + (levec * value)
					)
				)catch()
			)
	)
	CGSplitfloat = newrolloutfloater "Split It up!" 156 254 790 130
	addrollout CGSplitroll CGSplitfloat
	)
CGSplit_interface()