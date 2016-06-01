rollout Para "export NVC" (
  fn mshfilter msh = (classof msh == Editable_mesh)AND((getNumCPVVerts msh) > 0)
  spinner b01 "" fieldwidth:30 type:#integer range:[0,255,0] align:#center across:4
  spinner b02 "" fieldwidth:30 type:#integer range:[0,255,0] align:#center
  spinner b03 "" fieldwidth:30 type:#integer range:[0,255,0] align:#center
  spinner b04 "" fieldwidth:30 type:#integer range:[0,255,0] align:#center
  pickbutton dumpNVC "Pick Mesh" filter:mshfilter width:80 height:30 align:#center
  on dumpNVC picked msh do (
    fname = msh.name + ".nvc"
	f = fopen fname "wb"
	if f == undefined then messagebox "File creation failed!"
	else (
	  writebyte f b01.value
	  writebyte f b02.value
	  writebyte f b03.value
	  writebyte f b04.value
	  for i = 1 to msh.numverts do (
	    vc = getVertColor msh i
	    writebyte f vc.r
		writebyte f vc.g
		writebyte f vc.b
		writebyte f vc.a
	  )	
	)
	fclose f
  )
)
if NVC != undefined then ( 
  closeRolloutFloater NVC
  floaterpos = NVC.pos
)
if floaterpos != undefined then NVC = newRolloutFloater "Kams Export NVC" 190 150 floaterpos.x floaterpos.y
else NVC = newRolloutFloater "Kams Export NVC" 190 150
addRollout Para NVC
--addrollout about rolledup:false