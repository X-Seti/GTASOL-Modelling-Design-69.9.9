struct NodeStructure (NodeShape = undefined, KnotIndex = -1, Links = #(), NaviLinks = #())
struct NaviStructure (Target = -1, x = 0.0, y = 0.0, alpha = 0.0, flag = 0)
struct LinkStructure (Area = -1, Index = -1)

Global Nodes = for i = 1 to 64 collect #()
Global Navis = for i = 1 to 64 collect #()

rollout progress_rol "progress"
(
label p_name "" align:#left
progressBar p_bar
)

------------------------------------------------------------------------------------- FUNCTIONS

fn getSubNavi obj Index = (
local chil = 0, chObj = 0, upr, res = #(0, 0)
chil = obj.children
if chil.count>0 then
   for chObj in chil do (
       upr = getUserProp chObj "type"
	   if upr!=undefined then res = #(upr,0)
	   upr = getUserProp chObj "segment"
	   if upr!=undefined then
	      if upr==Index then (
		     res[2] = chObj
			 exit
		  )
   )
--format "% -- %  %  %\n" obj.name chil.count Index res
if res[2]==0 then res = undefined
res
)

-------------------------------------------------------------------------------------   

fn getLinkFromInt N =
   LinkStructure (bit.and (bit.shift N -16) 127) (bit.and N 65535)

-------------------------------------------------------------------------------------   
   
fn getIntFromLink A I = (bit.shift A 16) + I

-------------------------------------------------------------------------------------   

fn getArea p = (
local x, y, pos = p + [3000.0, 3000.0, 0]
  pos/=750.0
  x = (floor pos.x) as integer
  y = (floor pos.y) as integer
x + y*8 + 1
)

-------------------------------------------------------------------------------------   

fn getCrossNodeIndex a p = (
local res = 0, i

if Nodes[a]!=undefined then
    for i = 1 to Nodes[a].count do
	    if length (p - (getKnotPoint Nodes[a][i].NodeShape 1 Nodes[a][i].KnotIndex))<0.5 then (
		   res = i
		   exit
		)
res		
) -- fn

-------------------------------------------------------------------------------------   

fn getNaviFlag unk LL RL TDir TBehavior = (
local res = unk + (bit.shift RL 11) + (bit.shift LL 8) + (bit.shift TBehavior 14) + (bit.shift TDir 16)
res 
)

-------------------------------------------------------------------------------------   

fn getNodeFlag T A B C E IsHighWay K L M N O P = (
local res = (bit.shift T 4) + \
            (bit.shift A 6) + \
			(bit.shift B 7) + \
			(bit.shift C 8) + \
			(bit.shift E 10) + \
			(bit.shift IsHighWay 12) + \
			(bit.shift K 16) + \
			(bit.shift L 17) + \
			(bit.shift M 18) + \
			(bit.shift N 19) + \
			(bit.shift O 20) + \
			(bit.shift P 21)

--if trafLightON then (
   -- traffik lights
--)
res
)

-------------------------------------------------------------------------------------  

fn ReplaceFlag flag b1 b2 v = (
local i, res = flag 

for i = b1+1 to b2+1 do 
    res = bit.set res i false

i = bit.shift v b1 
bit.or res i 
)

-------------------------------------------------------------------------------------   

fn getAngle P = (
local res = 0, d
if (abs p.x)>0.01 then (
   d = (p.y as float)/(p.x as float)
   res = atan d
   if p.x<0 then res += 180.0
)
else
  if p.y>0 then res = 90.0
  else res = -90.0
res  
)

-------------------------------------------------------------------------------------   

fn checkPathShapes =  if $!= undefined then (
local obj, ErrorMsg = "", n, ErrorCount = 0, i
for obj in selection do
 if obj.parent==undefined then
  if ClassOf obj != line and ClassOf obj!= SplineShape then (
     ErrorMsg += ((ErrorCount + 1) as string) + ".  object " + obj.name + " is not LINE....\n"
	 ErrorCount += 1
  )
  else 
    if (n=NumSplines obj) > 1 then (
       ErrorMsg += ((ErrorCount + 1) as string) + ".  shape " + obj.name + \
	                " have more then one spline....\n"
	   ErrorCount += 1
	)
	else
	  if IsClosed obj 1 then (
         ErrorMsg += ((ErrorCount + 1) as string) + ".  shape " + obj.name + \
	                  " is closed....\n"
	     ErrorCount += 1
	  )

if errorCount>0 then messageBox ErrorMsg
                --else messageBox "path shapes - OK"

errorCount	  
)

-------------------------------------------------------------------------------------   

------------------------------------------------------------------------------------- END FUNCTIONS
clearListener ()

if $ != undefined then 
if checkPathShapes () == 0 then (
ExportPathDir = scriptsPath + "sa_paths_scripts\\node_files"
ExportPath = getSavePath initialDir:ExportPathDir
if ExportPath != undefined then (

PedShapes = #()
VehShapes = #()
for obj in selection do 
 if obj.parent==undefined then (
   Path_ID = (getUserProp obj "p_type.state"); if Path_ID==undefined then Path_ID = 2
   if Path_ID == 1 then append PedShapes obj
                   else append VehShapes obj
)

ProgressIncr = 85.0/(pedShapes.count + vehShapes.count)
ProgressVal = 0.0

----------------------------------------------------------------------------- START VEHICLE PATHS

createDialog progress_rol width:280

for obj in VehShapes do (
progress_rol.p_name.text = "VEHICLE PATH :" + obj.name
ProgressVal += ProgressIncr
progress_rol.p_bar.value = ProgressVal
	curNavi = -1
	predLink = -1
	predNavi = -1
	curArea = -1
	curIndex = -1
    predArea = -1
    predIndex = -1
    N1 = -1
    N2 = -1
	P1 = [0,0,0]
	p2 = [0,0,0]
	
	NKnots = NumKnots obj
	
	--format "VEH SHAPE : %\n" obj.name
	
	for i = 1 to NKnots do (
		
		--format "Knot # %\n" i
		
	    if i == 1 then (
		     curArea = getArea (getKnotPoint obj 1 i)
             curIndex = getCrossNodeIndex curArea (getKnotPoint obj 1 i)	     
		     if curIndex==0 then (
			     curIndex = Nodes[curArea].count + 1
			     Nodes[curArea][curIndex] = (NodeStructure obj i)
			 )
		)
		
        if i>1 then ( -- add pred navi and pred link to current node
		     PosInLink = 0
			 --format "area = %; index = %\n" curArea curIndex
			 for j = 1 to Nodes[curArea][curIndex].NaviLinks.count do
                 if Nodes[curArea][curIndex].NaviLinks[j]>predNavi then (PosInLink = j; exit)
			 if PosInLink>0 then (
			    insertItem predNavi Nodes[curArea][curIndex].NaviLinks PosInLink
				insertItem (getIntFromLink predArea predIndex) Nodes[curArea][curIndex].Links PosInLink
			 )
			 else (
			    append Nodes[curArea][curIndex].NaviLinks predNavi
				append Nodes[curArea][curIndex].Links (getIntFromLink predArea predIndex)
			 )
		) -- i>1
		
		
		if i<NKnots then (
		     nextArea = getArea (getKnotPoint obj 1 (i+1))
		     nextIndex = getCrossNodeIndex nextArea (getKnotPoint obj 1 (i+1))
		     if nextIndex == 0 then (
			    nextIndex = Nodes[nextArea].count + 1
			    Nodes[nextArea][nextIndex] = NodeStructure obj (i+1)
			 )
			 
			 -- create new navi
			 P1 = getKnotPoint Nodes[curArea][curIndex].NodeShape 1 Nodes[curArea][curIndex].KnotIndex
			 P2 = getKnotPoint Nodes[nextArea][nextIndex].NodeShape 1 Nodes[nextArea][nextIndex].KnotIndex
			 NaviPos = (P1 + P2)/2
			 NaviArea = getArea NaviPos
			 NaviIndex = Navis[NaviArea].count + 1
			 Navis[NaviArea][NaviIndex] = NaviStructure ()
			 Navis[NaviArea][NaviIndex].x = NaviPos.x
			 Navis[NaviArea][NaviIndex].y = NaviPos.y
			 N1 = getIntFromLink curArea curIndex
			 N2 = getIntFromLink nextArea nextIndex
			 if N1<N2 then (
			    Navis[NaviArea][NaviIndex].target = N1
				Navis[NaviArea][NaviIndex].alpha = getAngle (normalize (P1 - P2))
				Reversed = false
			 )
			 else (
			    Navis[NaviArea][NaviIndex].target = N2
				Navis[NaviArea][NaviIndex].alpha = getAngle (normalize (P2 - P1))
				Reversed = true
			 )
             if (up_RL = getUserProp obj "l_right.value")==undefined then up_RL = 1
             if (up_LL = getUserProp obj "l_left.value")==undefined then up_LL = 1
			 
			 TDir = 0
			 Tbehavior = 0
			 Sub = getSubNavi obj i
			 --format "SUB = %\n" Sub
			 if Sub!=undefined then ( -- svetofor check
			 --format "Traffic Light Found \n"
			 SubAngle = Sub[2].rotation.z_rotation
			 Navis[NaviArea][NaviIndex].x = Sub[2].position.x
			 Navis[NaviArea][NaviIndex].y = Sub[2].position.y
			    if Sub[1]==1 then (
				   v1 = normalize (P2-P1)				   
				   SubDir = v1.x*(cos SubAngle) + v1.y*(sin SubAngle)
				   if SubDir > 0 then TBehavior = 1
				                 else TBehavior = 0
				   if abs (cos SubAngle) > abs (sin SubAngle) then TDir = 2
				                                              else TDir = 1
                   if Reversed then (
				      --TDir = 3 - TDir
					  TBehavior = 1 - TBehavior
                   )															  
				)
			 ) -- svetofor check
			 
			 if Reversed then swap up_RL up_LL
			 
			 Navis[NaviArea][NaviIndex].flag = getNaviFlag 0 up_LL up_RL TDir TBehavior
			 -- end create new navi
			 
		     PosInLink = 0
			 curNavi = getIntFromLink NaviArea NaviIndex
			 for j = 1 to Nodes[curArea][curIndex].NaviLinks.count do
                 if Nodes[curArea][curIndex].NaviLinks[j]>curNavi then (PosInLink = j; exit)
			 if PosInLink>0 then (
			    insertItem curNavi Nodes[curArea][curIndex].NaviLinks PosInLink
				insertItem (getIntFromLink nextArea nextIndex) Nodes[curArea][curIndex].Links PosInLink
			 )
			 else (
			    append Nodes[curArea][curIndex].NaviLinks curNavi
				append Nodes[curArea][curIndex].Links (getIntFromLink nextArea nextIndex)
			 )

		) -- if i<NKnots
		
    predArea = curArea
    predIndex = curIndex
    predNavi = curNavi
	curArea = nextArea
	curIndex = NextIndex
			 
	--format "at end - A = %; Index = %\n" curArea curIndex		
	) -- i loop

) -- obj loop



----------- END VEHICLE PATHS

---------------------------------------------------------------------------------------------------- START PED PATHS

for obj in PedShapes do (
    progress_rol.p_name.text = "PED PATH :" + obj.name
    ProgressVal += ProgressIncr
    progress_rol.p_bar.value = ProgressVal
	predLink = -1
	curArea = -1
	curIndex = -1
    predArea = -1
    predIndex = -1
    N1 = -1
    N2 = -1
	P1 = [0,0,0]
	p2 = [0,0,0]
	
	NKnots = NumKnots obj
	
	for i = 1 to NKnots do (
		
	    if i == 1 then (
		     curArea = getArea (getKnotPoint obj 1 i)
             curIndex = getCrossNodeIndex curArea (getKnotPoint obj 1 i)	     
		     if curIndex==0 then (
			     curIndex = Nodes[curArea].count + 1
			     Nodes[curArea][curIndex] = (NodeStructure obj i)
			 )
		)
		
        if i>1 then ( -- add pred link to current node
		     PosInLink = 0
			 for j = 1 to Nodes[curArea][curIndex].Links.count do
                 if Nodes[curArea][curIndex].Links[j]>predLink then (PosInLink = j; exit)
			 if PosInLink>0 then
			    insertItem predLink Nodes[curArea][curIndex].Links PosInLink
			 else
				append Nodes[curArea][curIndex].Links predLink
		) -- i>1
		
		
		if i<NKnots then (
		     nextArea = getArea (getKnotPoint obj 1 (i+1))
		     nextIndex = getCrossNodeIndex nextArea (getKnotPoint obj 1 (i+1))
		     if nextIndex == 0 then (
			    nextIndex = Nodes[nextArea].count + 1
			    Nodes[nextArea][nextIndex] = NodeStructure obj (i+1)
			 )
			 
		     PosInLink = 0
			 curLink = getIntFromLink nextArea nextIndex
			 for j = 1 to Nodes[curArea][curIndex].Links.count do
                 if Nodes[curArea][curIndex].Links[j]>curLink then (PosInLink = j; exit)
			 if PosInLink>0 then
			    insertItem curLink Nodes[curArea][curIndex].Links PosInLink
			 else
			    append Nodes[curArea][curIndex].Links curLink
			 
		) -- if i<NKnots
		
    predArea = curArea
    predIndex = curIndex
    predLink = curLink
	curArea = nextArea
	curIndex = NextIndex

	) -- i loop
) -- obj loop



----------- END PED PATHS



---------------------------------------------------------------------------------------------  WRITE TO FILES




--ExportPath = scriptsPath + "sa_paths_scripts\\node_files" --"G:\\SA_MOD\\test\\paths"
if ExportPath != undefined then (

ExportMsg = ""
ProgressIncr = 15.0/64
ProgressVal = 85.0

for i = 1 to 64 do (
  progress_rol.p_name.text = "NODES" + ((i-1) as string) + ".DAT"
  ProgressVal += ProgressIncr
  progress_rol.p_bar.value = ProgressVal
  if Nodes[i].count>0 then (
  fname = ExportPath + "\\Nodes" + ((i - 1) as string) + ".dat"
  f = fopen fname "wb"
  if f==undefined then (
     ErrorMsg = "Can't create file " + (fileNameFromPath fname)
     messageBox ErrorMsg
	 exit
  )
  
  NodeCount = Nodes[i].count 
  CarCount = 0
  PedCount = 0
  NaviCount = Navis[i].count
  LinksCount = 0
  
  writelong f NodeCount
  writelong f 0
  writelong f 0
  writelong f NaviCount
  writelong f 0
  ----------------------------------------------------------------------  NODES
  
  for j = 1 to NodeCount do (
       obj = Nodes[i][j].NodeShape
	   Path_ID = (getUserProp obj "p_type.state"); if Path_ID==undefined then Path_ID = 2
	   if Path_ID==1 then PedCount += 1
	  
       writelong f 0 -- mem/unused
	   writelong f 0 -- zero/unused
	   KnotPos = getKnotPoint Nodes[i][j].NodeShape 1 Nodes[i][j].KnotIndex
	   x = (KnotPos.x * 8) as integer
	   y = (KnotPos.y * 8) as integer
	   z = (KnotPos.z * 8) as integer
	   writeshort f x
	   writeshort f y
	   writeshort f z
	   writeshort f 0x7FFE -- unk 1
	   writeshort f LinksCount -- link ID
	   LinksCount += Nodes[i][j].links.count
	   writeshort f (i-1) -- area id
	   writeshort f (j-1) -- node id
	   PWidth = getUserProp obj "p_width.value"; if PWidth==undefined then PWidth = 0.0
	   writebyte f (PWidth*8) -- path width
	   PType = getUserProp obj "p_id.value"; if PType==undefined then PType = 1
	   writebyte f PType -- node type
	   --flags = 987138
	   
	   flag_T = (getUserProp obj "p_traffic.selection") ; if flag_T==undefined then flag_T = 0
	   flag_T -= 1
	   flag_A = (getUserProp obj "p_roadblock.triState") ; if flag_A==undefined then flag_A = 0
	   flag_B = (getUserProp obj "p_boats.triState") ; if flag_B==undefined then flag_B = 0
	   flag_C = (getUserProp obj "p_emergency.triState") ; if flag_C==undefined then flag_C = 0
	   flag_E = (getUserProp obj "UnknownE") ; if flag_E==undefined then flag_E = 0
	   flag_HighWay = (getUserProp obj "p_highway.triState") ; if flag_HighWay==undefined then flag_HighWay = 0
	   if Path_ID>0 then flag_HighWay+=1
	                 else flag_HighWay=0
	   flag_P = (getUserProp obj "p_parking.triState") ; if flag_P==undefined then flag_P = 0
       flags = getNodeFlag flag_T  flag_A  flag_B  flag_C  flag_E  flag_HighWay  1 1 1 1 0 flag_P
	   
	   flags = ReplaceFlag flags 0 3 Nodes[i][j].links.count
	   writelong f flags  
  ) -- j
  
  ------------------------------------------------------------------------ NAVI NODES
   
   for j = 1 to Navis[i].count do (
	     writeshort f (Navis[i][j].x*8)
	     writeshort f (Navis[i][j].y*8)
	     writeshort f ((getLinkFromInt Navis[i][j].target).area - 1) -- Target Area ID
	     writeshort f ((getLinkFromInt Navis[i][j].target).Index - 1) -- Target Node ID
	     writebyte f ((cos Navis[i][j].alpha)*100.0)
	     writebyte f ((sin Navis[i][j].alpha)*100.0)
	     writelong f Navis[i][j].flag -- flags

   )
   
  ------------------------------------------------------------------------ LINKS
   
   for j = 1 to NodeCount do
     for k = 1 to Nodes[i][j].links.count do (
	    L = getLinkFromInt Nodes[i][j].links[k]
	    writeshort f (L.Area - 1)
	    writeshort f (L.Index - 1)
   )     

  ------------------------------------------------------------------------ FILLER
   
   for i = 1 to 192 do (
	   writeshort f 0xFFFF
	   writeshort f 0
   )
   
   ------------------------------------------------------------------------ NAVI LINKS
   
   for j = 1 to NodeCount do (
     obj = Nodes[i][j].NodeShape
	 Path_ID = (getUserProp obj "p_type.state"); if Path_ID==undefined then Path_ID = 2
	 if Path_ID==2 then
       for k = 1 to Nodes[i][j].navilinks.count do (
	      L = getLinkFromInt Nodes[i][j].navilinks[k]
	      writeshort f ((L.Index-1) + (bit.shift (L.Area-1) 10))
       ) -- k loop
	 else
       for k = 1 to Nodes[i][j].links.count do writeshort f 0
   ) -- j loop

   
   -------------------------------------------------------------------------- LINK LEN
   
   for j = 1 to NodeCount do (
     KnotPos1 = getKnotPoint Nodes[i][j].NodeShape 1 Nodes[i][j].KnotIndex
     for k = 1 to Nodes[i][j].links.count do (
		AID = (getLinkFromInt Nodes[i][j].links[k]).Area
		NI = (getLinkFromInt Nodes[i][j].links[k]).Index
	    KnotPos2 = getKnotPoint Nodes[AID][NI].NodeShape 1 Nodes[AID][NI].KnotIndex
	    writebyte f (distance KnotPos1 KnotPos2)
      ) -- k 
   ) -- j 
   
   --------------------------------------------------------------------------- SIZES
   
   fseek f 4 #seek_set
   writelong f (NodeCount - PedCount)
   writelong f PedCount
   writelong f NaviCount
   writeLong f LinksCount
   
   --format "EXPORTED AREA %\n" (i-1)
   ExportMsg += "AREA " + ((i-1) as string) + " EXPORTED\n"
   fclose f

) -- first if in i loop
else ( -- write zero file
  fname = ExportPath + "\\Nodes" + ((i - 1) as string) + ".dat" 
  f = fopen fname "wb"
  if f==undefined then (
     ErrorMsg = "Can't create file " + fileNameFromPath
     messageBox ErrorMsg
	 exit
  )
  
  for zzzzz = 1 to 5 do writelong f 0
  for zzzzz = 1 to 192 do (
	  writeshort f 0xFFFF
	  writeshort f 0
  ) -- zzzzz
  
  fclose f
)

) -- i loop

messageBox ExportMsg

) -- if ExportPath != undefined
else messageBox "PATH NOT EXPORTED"

DestroyDialog progress_rol


-------------------------------------------  END WRITE TO FILES

if false then
for A = 1 to 64 do
  if Nodes[A].count>0 then
     for i = 1 to Nodes[A].count do (
	     format "--------\nNODE (%,  %)\n" a i
	   format "links --"
	   for j = 1 to nodes[a][i].links.count do format "(% = %); " j (getLinkFromInt nodes[a][i].links[j])
	   format "\nnavi --"
       for j = 1 to nodes[a][i].links.count do format "(% = %); " j (getLinkFromInt nodes[a][i].navilinks[j])
	   format "\n"
  )

) -- if ExportPath != undefined
) -- if $!=undef