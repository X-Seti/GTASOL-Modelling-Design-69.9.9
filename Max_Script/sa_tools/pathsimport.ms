rollout iplpaths_rol "IPL paths io" width:128 height:127
(
	button impVC "IMPORT IPL" pos:[12,8] width:100 height:27 toolTip:"import ipl path"

---------------------------------------------------------------------------------------------

on impVC pressed do (
fname = getOpenFileName caption:"select dat"  types:"ipl path (*.ipl)|*.ipl|"

if fname != undefined then (
  f = openfile fname
  if f != undefined then (
     clearlistener ()
     while not eof f do (
     s = readline f
  if s == "path" then exit
  )
  
  ZZZ = 0
  
  while not eof f do ( -- ZZZ < 250 do (
     s = readline f
  if s.count > 0 then
     if s[1] != "#" then (
     if s == "end" then exit
     fs = filterstring s " , "
     
     pathtype = execute fs[1]
     
     pos = #()
     ltype = #()
     link = #()
     slink = #()
     blink = #()
     used_node = for i = 1 to 12 collect 1
     nlinks = 0
     
     for i = 1 to 12 do (
         s = readline f
      fs = filterstring s " , "
      if (LT = execute fs[1]) > 0 then (
       pos[i] = [fs[4] as float, fs[5] as float, fs[6] as float]/16.0
       link[i] = (execute fs[2]) + 1
       ltype[i] = LT
       if link[i]>-1 and ltype[i]==1 then append slink i
       if link[i] > 0 then blink[link[i]] = i
                      --else blink[link[i]] = 0
       nlinks += 1
      )
     )
     
     --format "blink = % ... nodes = %\n" blink nlinks
     
     for i = 1 to nlinks do
         if blink[i] == undefined then (
           ss = SplineShape pos:pos[i]
     addnewspline ss
     addKnot ss 1 #corner #line pos[i]
     next_node = link[i]
     
     while true do (
       --format "--- used = %--- next = %\n" used_node next_node
       addKnot ss 1 #corner #line pos[next_node]
       if used_node[next_node]==0 then exit
       used_node[next_node] = 0
       next_node = link[next_node]
       if next_node == 0 then exit
     )
     
                       if pathtype == 1 then ss.wirecolor = (color 255 0 0)
     if pathtype == 0 then ss.wirecolor = (color 0 255 0)
     if pathtype == 2 then ss.wirecolor = (color 0 0 255)
     updateshape ss
      )
     
  ) -- s[1] != "#"
  ZZZ += 1
  ) -- while
  
  close f
  ) -- f
) -- fname
) -- on impVC

---------------------------------------------------------------------------------------------

) -- roolout

---------------------------------------------------------------------------------------------

try (closeRolloutFloater iplpaths_flo) catch () 
iplpaths_flo = newRolloutFloater "IPL PATHS IO" 140 150 20 130 
addRollout  iplpaths_rol iplpaths_flo