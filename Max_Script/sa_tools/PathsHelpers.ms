-- paths helper

rollout divide_splines_rol "div segments"
(
button go_btn "DIVIDE SEGS" width:100
label l1 "step" across:2 align:#left
spinner MLen "" range:[0.01, 1000000, 20] width:50 align:#right


local obj, minlen, i,j, N, Nseg, Nknots, lens, L

on go_btn pressed do
if $!=undefined then (
   MinLen = Mlen.value
   for obj in selection do (
      for i = 1 to numsplines obj do
       for j = 1 to numknots obj i do
	       setKnotType obj i j #corner
       for i = 1 to numsplines obj do (
	       --if isClosed obj i then open obj i
	       Nseg = numsegments obj i
		   Nknots = numKnots obj i
		   Lens = getSegLengths obj i
	       for j = Nseg to 1 by -1 do (
		       L = Lens[Nseg+j]
			   if L>MinLen then (
			      N = floor (L/MinLen) -- or ceil/floor
				  subdivideSegment obj i j N
			   )
		   ) -- j	   
	   ) -- i
	   
   for i = 1 to numsplines obj do
     for j = 1 to numknots obj i do
	       setKnotType obj i j #corner
   updateShape obj
   ) -- obj loop
) -- pressed

) -- roll




--------------------------------------------------------------------------------------------------------------------------





rollout showpathswidth_rol "show paths width"
(
button showWidth "Show paths width"
button hideWidth "Hide paths width"

on showWidth pressed do
(
	for s in selection do
	    if classOf S == line or classOf S == SplineShape then
		      if ( w = getUserProp s "p_width.value" ) != undefined then
			  (
			       s.render_displayRenderMesh = true
				   s.render_rectangular = true
				   s.render_length = 0.2
				   s.render_width = w
			  )
			  else format "have no width property\n"
) -- 

on HideWidth pressed do
(
	for s in selection do
	    if classOf S == line or classOf S == SplineShape then 
		   s.render_displayRenderMesh = false
) -- 

) -- roll





--------------------------------------------------------------------------------------------------------------------------



rollout splinOnMeshes_rol "spline on meshes"
(
button go_btn "SET SPLINES ON MESHES" --width:100

local HaveError = false, i, j, S, Mpos

fn getIntersect p =
(
local res = undefined, R = (ray p [0,0,-1]), obj

	for obj in $geometry do
		if (not obj.isHidden) then --and (not obj.isFrozen) then
		(    
			     ir = intersectRay obj R
				 if ir != undefined then return ir.position
		)
res
)


on go_btn pressed do
 if $!=undefined then (
			
			HaveError = false
			for S in selection do
			    if classOf S == line or classOf S == SplineShape then
				(
			       for i = 1 to numSplines S do
				       for j = 1 to numKnots S i do
					         if (Mpos = getIntersect ((getKnotPoint S i j) + [0,0,10000])) != undefined then
							    setKnotPoint S i j Mpos
							 else
							    if not HaveError then
								(
								    HaveError = true
							    	MessageBox "Some knots have no intersections"
								)
				   updateShape S
				)
				
) -- pressed

) -- roll


--------------------------------------------------------------------------------------------------------------------------




rollout weldknots_rol "weld_knots"
(
button go_btn "WELD KNOTS" width:100
spinner zr "z radius" range:[0, 100000, 1]
spinner xyz "xy radius" range:[0, 100000, 1]

local i, j, S1, S2

on go_btn pressed do
 if $!=undefined then (
	 for S1 in selection do
	     if classOf S1 == line or classOf S1 == SplineShape then
		 (
		      for i1 = 1 to numsplines S1 do
			      for j1 = 1 to numKnots S1 i1 do
				  (
				      p1 = getKnotPoint S1 i1 j1
					  for S2 in selection do
					      if S2 != S1 then
						     if classOf S2 == line or classOf S2 == SplineShape then
                                for i2 = 1 to numSplines S2 do
								    for j2 = 1 to NumKnots S2 i2 do
									(
									    p2 = getKnotPoint S2 i2 j2
										d = p2 - p1
										if abs d.z < zr.value and abs d.x < xyz.value and abs d.y < xyz.value then
                                           setKnotPoint S1 i1 j1 p2
									)
				  ) -- i1
		  updateShape S1
		  ) -- S1
) -- pressed

) -- roll







--------------------------------------------------------------------------------------------------------------------------


rollout checkSplines_rol "check"
(
button go_btn "CHECK" width:100

local i, j, S1, S2

on go_btn pressed do
 if $!=undefined then (
 MsgStr = ""
	 for S1 in selection do
	     if classOf S1 == line or classOf S1 == SplineShape then
		 (
		      if getUserProp S1 "p_type.state" == undefined then
			     MsgStr += S1.name + " have no props\n"
		 ) -- S1
		 else MsgStr += S1.name + " not a Splineshape\n"
		 
	 if MsgStr != "" then messageBox MsgStr
	    else messageBox "OK"
) -- pressed

) -- roll


--------------------------------------------------------------------------------------------------------------------------


rollout explodeshapes_rol "explode shapes"
(
button go_btn "EXPLODE" width:100

local i, j, s, ns, n, wc, upb, objs

on go_btn pressed do
		if $!= undefined then (
		objs = selection as array
		
		for s in objs do
		  if classOf s == SplineShape or classOf s == line then
			if numsplines s > 1 then (
			   n = numsplines s
			   upb = getuserpropbuffer s
			   wc = s.wirecolor
			   for i = 1 to n do (
			       ns = copy s
				   ns.wirecolor = wc
				   setuserpropbuffer ns upb
				   for j = 1 to i-1 do
				     deleteSpline ns 1
				   while numsplines ns > 1 do (
				      deletespline ns (numsplines ns)
				   )
			   updateShape ns
			   )
			   delete s
			)
		) -- $

) -- roll


--------------------------------------------------------------------------------------------------------------------------

try (closeRolloutFloater PathsHelper_flo) catch () 
PathsHelper_flo = newRolloutFloater "path helper" 180 450 20 130 
addRollout  divide_splines_rol PathsHelper_flo
addRollout  splinOnMeshes_rol PathsHelper_flo
addRollout  weldknots_rol PathsHelper_flo
addRollout  explodeshapes_rol PathsHelper_flo
addRollout  showpathswidth_rol PathsHelper_flo
addRollout  checkSplines_rol PathsHelper_flo