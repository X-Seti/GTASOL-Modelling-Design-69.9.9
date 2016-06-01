-- face select inverse (poly)
macroscript SubSelectInverse category:"Deniska tools"
(
 On IsEnabled Return (selection.count == 1 and subObjectLevel > 0 and ClassOf selection[1] == Editable_poly)
 
on execute do (
  --for obj in selection do
  --if superClassOf obj == GeometryClass then (
     --obj_class = classOf obj
     --obj_sublevel = subObjectLevel
     --convertTo obj Editable_mesh
	 obj = selection[1]
	 case  of (
	 (subObjectLevel > 3) : 
	    (
	      fselection = polyop.getfaceselection obj
          fselection = #{1..(obj.NumFaces)} - fselection
          polyop.setFaceSelection obj fselection
	    ) -- 1
	 (subObjectLevel == 1): 
	    (
	      fselection = polyop.getvertselection obj
          fselection = #{1..(obj.NumVerts)} - fselection
          polyop.setVertSelection obj fselection
	    ) -- 2
	 (subObjectLevel == 2 or subObjectLevel == 3): (
	      fselection = polyop.getedgeselection obj
          fselection = #{1..(polyop.getnumedges obj)} - fselection
          polyop.setEdgeSelection obj fselection
	    ) -- 3
	 ) -- case
     --convertTo obj obj_class
     --if obj_sublevel != undefined then subObjectLevel = obj_sublevel
  completeRedraw ()
  )

) -- macro