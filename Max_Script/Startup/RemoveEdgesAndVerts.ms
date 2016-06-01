macroScript RemoveEdgesAndVerts category:"Deniska tools"
( 
	On IsEnabled Return (Filters.Is_EPolySpecifyLevel #{3} and selection.count == 1)
	On IsVisible Return (Filters.Is_EPolySpecifyLevel #{3} and selection.count == 1)
  
  on execute do (
     local obj = selection[1], vertsbyedge
	 local edges = polyop.getedgeselection obj
	 if not edges.isEmpty then (
	    vertsbyedge = polyOp.getVertsUsingEdge obj edges
		polyop.setvertselection obj vertsbyedge
        obj.EditablePoly.Remove selLevel:#Edge
		obj.EditablePoly.Remove selLevel:#Vertex
	 )
  ) -- execute
)
