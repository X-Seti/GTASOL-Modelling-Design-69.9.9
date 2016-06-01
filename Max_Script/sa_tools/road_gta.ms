---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

fn getNor p1 p2 = 
   (normalize (([p2.x,p2.y,0] - [p1.x,p1.y,0])*(rotateZMatrix 90))) 

---------------------------------------------------------------------------------------------------------------

fn getCross p1 p2 = (
 if distance p1 p2 < 0.001 then p1
 else
 (
	 local c = - (p1.y^2 + p1.x^2)
	 local c1 = - (p2.y^2 + p2.x^2)
	 local d = p1.x*p2.y - p1.y*p2.x
	 [(c1*p1.y - c*p2.y)/d , (c*p2.x - c1*p1.x)/d , 0]
 )
)

---------------------------------------------------------------------------------------------------------------

fn GetVZAngle v1 = (
local q1 = normalize [v1.x, v1.y, 0.0]
local q2 = [0.0, 1, 0.0] 
local resultat = if q1!=q2 then acos(dot q1 q2) 
                           else 0.0 
if 	q1.x>0.0 then resultat 
             else -resultat					   
)

---------------------------------------------------------------------------------------------------------------

fn divided_spline s N = (
local res = copy s, i, j, m

	for i = 1 to numsplines res do (
	    j = numsegments res i
		
		while j>0 do (
		   for m = N to 2 by -1 do
		       refineSegment res i j (1.0 - 1.0/m)
		   j -= 1
		)
	)
res
)

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------


fn new_road shape_obj rs ps bh RM PM BM Bmin Bmax m1 m2 m3 road_mat dseg have_bordur = (
local Varray = #()
local Farray = #()
local TVarray = #()
local TFarray = #()
local MIDs = #()
local PL = 0, RL = 0, BL = 0, si
local sobj

if dseg > 1 then sobj = divided_spline shape_obj dseg
            else sobj = copy shape_obj

 --L = curveLength Sobj 1
 --S = bwid.value/2.0 -- width
 --Vscale = 1.0/bscale.value
for si = 1 to numSplines sobj do 
(
 N = numknots sobj si
 Varray = #()
 Farray = #()
 TVarray = #()
 TFarray = #()
 MIDs = #()
 
 if isClosed Sobj si then (
  nor1 = getNor (getKnotPoint Sobj si 1) (getKnotPoint Sobj si 2)
  nor2 = getNor (getKnotPoint Sobj si N) (getKnotPoint Sobj si 1)
  NorRL = getCross (nor1*RS) (nor2*RS)
  NorPL = getCross (nor1*PS) (nor2*PS)
  nor1 = - getNor (getKnotPoint Sobj si 1) (getKnotPoint Sobj si 2)
  nor2 = - getNor (getKnotPoint Sobj si N) (getKnotPoint Sobj si 1)
  NorRR = getCross (nor1*RS) (nor2*RS)
  NorPR = getCross (nor1*PS) (nor2*PS)	
 )
 else (
  NorRL = (getNor (getKnotPoint Sobj si 1) (getKnotPoint Sobj si 2)) * RS
  NorRR = -NorRL
  NorPL = (getNor (getKnotPoint Sobj si 1) (getKnotPoint Sobj si 2)) * PS
  NorPR = -NorPL  
 )
 
 p = getKnotPoint Sobj si 1
 p1 = p + NorPL + [0,0,BH]
 p2 = p + NorRL + [0,0,BH]
 p3 = p + NorRL
 p4 = p + NorRR
 p5 = p + NorRR + [0,0,BH]
 p6 = p + NorPR + [0,0,BH]
 
 Varray = if have_bordur then #(p1, p2, p2, p3, p3, p, p4, p4, p5, p5, p6)
                         else #(p1, p3, p3, p , p4, p4, p6)
 tv1 = [0,0,0]
 tv2 = [1,0,0]*PM
 tv3 = [Bmin,0,0]*BM
 tv4 = [Bmax,0,0]*BM
 tv5 = [0,0,0]
 tv6 = [1,0,0]*RM
 tv7 = [0,0,0]
 tv8 = [Bmax,0,0]*BM
 tv9 = [Bmin,0,0]*BM
 tv10 = [1,0,0]*PM
 tv11 = [0,0,0]
 
 TVarray = if have_bordur then #(tv1,tv2,tv3,tv4,tv5,tv6,tv7,tv8,tv9,tv10,tv11)
                          else #(tv1,tv2,tv5,tv6,tv7,tv10,tv11)
 D = 0.0

 for i = 2 to N do (
	 Pcur = getKnotPoint Sobj si i
	 Ppred = getKnotPoint Sobj si (i-1)
	 D += distance Ppred Pcur
	 if i<N then Pnext = getKnotPoint Sobj si (i+1)
	 else 
		Pnext = getKnotPoint Sobj si 1
		
	 if i<N or isClosed Sobj si then
	   (
			  nor1 = getNor Pcur Pnext
			  nor2 = getNor Ppred Pcur
			  NorRL = getCross (nor1*RS) (nor2*RS)
			  NorPL = getCross (nor1*PS) (nor2*PS)
			  nor1 = - (getNor Pcur Pnext)
			  nor2 = - (getNor Ppred Pcur)
			  NorRR = (getCross nor1 nor2) * RS
			  NorPR = (getCross nor1 nor2) * PS		
	   )
	
	 if not (isClosed Sobj si) and i==N then
	 (
		    NorRL = (getNor Ppred Pcur) * RS
		    NorRR = -NorRL
		    NorPL = (getNor Ppred Pcur) * PS
		    NorPR = -NorPL 		
	 )
	 
	 p = Pcur
	 p1 = p + NorPL + [0,0,BH]
	 p2 = p + NorRL + [0,0,BH]
	 p3 = p + NorRL
	 p4 = p + NorRR
	 p5 = p + NorRR + [0,0,BH]
	 p6 = p + NorPR + [0,0,BH] 
	 
	 arr =  if have_bordur then #(p1, p2, p2, p3, p3, p, p4, p4, p5, p5, p6)
	                       else #(p1, p3, p3, p , p4, p4, p6)
	 join  Varray arr							
	 
	 k = if have_bordur then (i-2)*11
	                    else (i-2)*7
	 arr = if have_bordur then         #([k+13, k+12, k+1] , [k+1, k+2, k+13] , \   -- PL
	                                    [k+15, k+14, k+3] , [k+3, k+4, k+15], \     -- BL
										[k+17, k+16, k+5] , [k+5, k+6, k+17], \     -- RL
	                                    [k+18, k+17, k+6] , [k+6, k+7, k+18], \     -- RR
										[k+20, k+19, k+8] , [k+8, k+9, k+20], \     -- BR
										[k+22, k+21, k+10] , [k+10, k+11, k+22])	 					
	                     else          #([k+9, k+8, k+1] , [k+1, k+2, k+9] , \    
										[k+11, k+10, k+3] , [k+3, k+4, k+11], \  
	                                    [k+12, k+11, k+4] , [k+4, k+5, k+12], \  
										[k+14, k+13, k+6] , [k+6, k+7, k+14])									
	 join Farray arr
	 
	 if have_bordur then join MIDs #(m2,m2,m3,m3,m1,m1,m1,m1,m3,m3,m2,m2)
	                else join MIDs #(m2,m2,m1,m1,m1,m1,m2,m2)
	 
	 tv1 = [0,D,0]*PM
	 tv2 = [1,D,0]*PM
	 tv3 = [Bmin,D,0]*BM
	 tv4 = [Bmax,D,0]*BM
	 tv5 = [0,D,0]*RM
	 tv6 = [1,D,0]*RM
	 tv7 = [0,D,0]*RM
	 tv8 = [Bmax,D,0]*BM
	 tv9 = [Bmin,D,0]*BM
	 tv10 = [1,D,0]*PM
	 tv11 = [0,D,0]*PM
	 
	 arr = if have_bordur then #(tv1,tv2,tv3,tv4,tv5,tv6,tv7,tv8,tv9,tv10,tv11)
	                      else #(tv1,tv2,tv5,tv6,tv7,tv10,tv11)
	 join TVarray arr					  
 
 ) -- i loop
 
 if isClosed Sobj si then 
 (
	 arr = if have_bordur then #(Varray[1], Varray[2],Varray[3],Varray[4],Varray[5],Varray[6],Varray[7],Varray[8],Varray[9],Varray[10],Varray[11])
	                      else #(Varray[1], Varray[2],Varray[3],Varray[4],Varray[5],Varray[6])
	 join  Varray arr
	 k = if have_bordur then (N-1)*11
		                else (N-1)*7
	 arr = if have_bordur then         #([k+13, k+12, k+1] , [k+1, k+2, k+13] , \   -- PL
		                                    [k+15, k+14, k+3] , [k+3, k+4, k+15], \     -- BL
											[k+17, k+16, k+5] , [k+5, k+6, k+17], \     -- RL
		                                    [k+18, k+17, k+6] , [k+6, k+7, k+18], \     -- RR
											[k+20, k+19, k+8] , [k+8, k+9, k+20], \     -- BR
											[k+22, k+21, k+10] , [k+10, k+11, k+22])	 					
		                  else          #([k+9, k+8, k+1] , [k+1, k+2, k+9] , \    
											[k+11, k+10, k+3] , [k+3, k+4, k+11], \  
		                                    [k+12, k+11, k+4] , [k+4, k+5, k+12], \  
											[k+14, k+13, k+6] , [k+6, k+7, k+14])	
	 join Farray arr
	 if have_bordur then join MIDs #(m2,m2,m3,m3,m1,m1,m1,m1,m3,m3,m2,m2)
	                else join MIDs #(m2,m2,m1,m1,m1,m1,m2,m2)	 
	
	 D += distance (getKnotPoint sobj si N) (getKnotPoint sobj si 1)
		 tv1 = [0,D,0]*PM
		 tv2 = [1,D,0]*PM
		 tv3 = [Bmin,D,0]*BM
		 tv4 = [Bmax,D,0]*BM
		 tv5 = [0,D,0]*RM
		 tv6 = [1,D,0]*RM
		 tv7 = [0,D,0]*RM
		 tv8 = [Bmax,D,0]*BM
		 tv9 = [Bmin,D,0]*BM
		 tv10 = [1,D,0]*PM
		 tv11 = [0,D,0]*PM
		 
		 arr = if have_bordur then #(tv1,tv2,tv3,tv4,tv5,tv6,tv7,tv8,tv9,tv10,tv11)
		                      else #(tv1,tv2,tv5,tv6,tv7,tv10,tv11)
		 join TVarray arr										
 ) -- if closed
 
 mm = mesh vertices:Varray faces:Farray materialIDs:MIDs tverts:TVarray
 buildTVFaces mm
 --for i = 1 to TFarray.count do (setTVFace mm i TFarray[i])
 for i = 1 to mm.numfaces do setTVFace mm i Farray[i]
 
 if road_mat != undefined then mm.material = road_mat
 
 for i = 1 to mm.numfaces do
        setEdgeVis mm i 3 false
 
 update mm --update the mesh
 convertTo mm Editable_Poly
 mm.pivot = sobj.position
 
 mm.weldThreshold = 0.01
 polyOp.weldVertsByThreshold mm #all
 
 convertTo mm Editable_mesh
 meshop.autoSmooth mm #ALL 45.0
 convertTo mm Editable_Poly
		
) -- si loop
delete sobj

) -- fn


---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

rollout gta_road_rol "CREATE GTA ROAD"
(

button create_road "CREATE ROAD" tooltip:"select shape"
label lr2 "segment div" across:2 align:#left
spinner seg_div "" type:#integer width:40 range:[0, 100, 5] align:#right
label l12 "have bordur ?" across:2 align:#left
checkbox have_bord checked:true align:#right
label ml "select material"
materialbutton mat "pick material" width:80 across:2 align:#left
button clear_mat "clear" align:#right

group "ROAD"
(
label l1 "width" across:2 align:#left
spinner road_width "" type:#float width:40 range:[0.1, 10000, 6] align:#right
label l2 "mat ID" across:2 align:#left
spinner road_mid "" type:#integer width:40 range:[1, 100, 1] align:#right
label l4 "uv scale" across:2 align:#left
spinner road_scale "" type:#float width:40 range:[0.1, 10000, 6] align:#right
label l3 "uv direction" across:2 align:#left
dropdownlist road_uvdir items:#("U", "V", "U flip", "V flip") selection:2 align:#right
label l5 "mapping" align:#left
radiobuttons road_maps labels:#("GTA SA style", "road width") default:1
) -- road

group "PAVE"
(
label lp1 "width" across:2 align:#left
spinner pave_width "" type:#float width:40 range:[0.1, 10000, 4] align:#right
label lp2 "mat ID" across:2 align:#left
spinner pave_mid "" type:#integer width:40 range:[1, 100, 2] align:#right
label lp4 "uv scale" across:2 align:#left
spinner pave_scale "" type:#float width:40 range:[0.1, 10000, 4] align:#right
label lp3 "uv direction" across:2 align:#left
dropdownlist pave_uvdir items:#("U", "V", "U flip", "V flip") selection:2 align:#right
) -- pave

group "BORDUR"
(
label lb1 "width" across:2 align:#left
spinner bord_height "" type:#float width:50 range:[0.0, 10000, 0.2] align:#right
label lb2 "mat ID" across:2 align:#left
spinner bord_mid "" type:#integer width:40 range:[1, 100, 3] align:#right
label lb4 "uv scale" across:2 align:#left
spinner bord_scale "" type:#float width:50 range:[0.1, 10000, 4] align:#right
label lb5 "uv start" across:2 align:#left
spinner bord_uv1 "" type:#float width:50 range:[-1000, 1000, 0] align:#right
label lb6 "uv end" across:2 align:#left
spinner bord_uv2 "" type:#float width:50 range:[-1000, 1000, 1] align:#right
label lb3 "uv direction" across:2 align:#left
dropdownlist bord_uvdir items:#("U", "V", "U flip", "V flip") selection:2 align:#right
) -- bord

local road_mat

on mat picked m1 do (
   mat.text = m1.name
   road_mat = m1
)  

on clear_mat pressed do  (
   mat.text = "pick material"
   road_mat = undefined
)  


on create_road pressed do 
 if $ != undefined then 
  for shape_obj in selection do 
   if superclassof shape_obj == shape then (
	  RM = case road_uvdir.selection of (
	   1: (rotateZMatrix 90.0)*(scaleMatrix [1.0/road_scale.value, -1, 0])
	   2: scaleMatrix [-1, 1.0/road_scale.value, 0]
	   3: (rotateZMatrix 90.0)*(scaleMatrix [1.0/road_scale.value, 1, 0])
	   4: scaleMatrix [1, 1.0/road_scale.value, 0]
	  )
	  PM = case pave_uvdir.selection of (
	   1: (rotateZMatrix 90.0)*(scaleMatrix [1.0/pave_scale.value, -1, 0])
	   2: scaleMatrix [-1, 1.0/pave_scale.value, 0]
	   3: (rotateZMatrix 90.0)*(scaleMatrix [1.0/pave_scale.value, 1, 0])
	   4: scaleMatrix [1, 1.0/pave_scale.value, 0]
	  )
	  BM = case bord_uvdir.selection of (
	   1: (rotateZMatrix 90.0)*(scaleMatrix [1.0/bord_scale.value, -1, 0])
	   2: scaleMatrix [-1, 1.0/bord_scale.value, 0]
	   3: (rotateZMatrix 90.0)*(scaleMatrix [1.0/bord_scale.value, 1, 0])
	   4: scaleMatrix [1, 1.0/bord_scale.value, 0]
	  )   
      new_road shape_obj road_width.value (pave_width.value + road_width.value) bord_height.value \
	           RM PM BM bord_uv1.value bord_uv2.value road_mid.value pave_mid.value bord_mid.value \ 
			   road_mat (seg_div.value + 1) have_bord.checked
) -- create



) -- rolout

try (CloseRolloutFloater gta_road_flo) catch ()
gta_road_flo = NewRolloutFloater "" 170 520 40 180
AddRollout gta_road_rol gta_road_flo