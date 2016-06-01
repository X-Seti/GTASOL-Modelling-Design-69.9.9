----------------------------------------------------------------------------------------------------------------
rollout Deniska_sa_scripts_rollout "Deniska SA Tools" width:144 height:149
----------------------------------------------------------------------------------------------------------------
( -- rollout start
----------------------------------------------------------------
button dff_script "DFF EXPORT" width:120 align:#center
 on dff_script pressed do ( 
  try ( fileIn (scriptspath+"\\sa_tools\\export_dff.ms") quiet:true   )
  catch messagebox "Please re-install scripts !" \
        title:"Can't find script"
 )

button train_script "TRAIN PATHS IO" width:120 align:#center
 on train_script pressed do ( 
  try ( fileIn (scriptspath+"\\sa_tools\\TrainPathsIO.ms") quiet:true   )
  catch messagebox "Please re-install TrainPathsIO script!" \
        title:"Can't find TrainPathsIO script"
 )		

button breake_script "BREAKABLE OBJECTS" width:120 align:#center
 on breake_script pressed do ( 
  try ( fileIn (scriptspath+"\\sa_tools\\brakableobjects.ms") quiet:true   )
  catch messagebox "Please re-install brakableobjects.ms script!" \
        title:"Can't find brakableobjects.ms script"
 )		


button ecol_script "COL SCRIPT EXPORT" width:120 align:#center
 on ecol_script pressed do (
  try ( fileIn (scriptspath+"\\sa_tools\\export_steve_col_script.ms") quiet:true   )
  catch messagebox "Please re-install export_steve_col_script.ms script!" \
        title:"Can't find export_steve_col_script.ms script"
 )

button cull_script "CULL IO" width:120 align:#center
 on cull_script pressed do ( 
  try ( fileIn (scriptspath+"\\sa_tools\\cull_io.ms") quiet:true   )
  catch messagebox "Please re-install CULL IO script!" \
        title:"Can't find CULL IO script"
 )
 
button occlu_script "OCCLU IO" width:120 align:#center
 on occlu_script pressed do ( 
  try ( fileIn (scriptspath+"\\sa_tools\\occlu_io.ms") quiet:true   )
  catch messagebox "Please re-install occlu_io.ms script!" \
        title:"Can't find occlu_io.ms script"
 )

button anim_script "MAP ANIM EXPORT" width:120 align:#center
 on anim_script pressed do ( 
  try ( fileIn (scriptspath+"\\sa_tools\\anim_export.ms") quiet:true   )
  catch messagebox "Please re-install anim_export.ms script!" \
        title:"Can't find anim_export.ms script"
)


group "UV animation" ( 
button uv_anim_script "UV ANIM EXPORT" width:120 align:#center
button tv_script "TV ANIM HELPER" width:120 align:#center
)

 on uv_anim_script pressed do (
  try ( fileIn (scriptspath+"\\sa_tools\\UVanim_tool.ms") quiet:true)
  catch messagebox "Please re-install UVanim_tool.ms script!"  \
        title:"Can't find UVanim_tool.ms script"
)

 on tv_script pressed do (
  try ( fileIn (scriptspath+"\\sa_tools\\TVanimHelper.ms") quiet:true)
  catch messagebox "Please re-install TVanimHelper.ms script!" \
        title:"Can't find TVanimHelper.ms script"
)

group "show vertex color" (
button day_btn "DAY" width:60 align:#left
button night_btn "NIGHT" width:70 align:#right offset:[0,-26]
)

on night_btn pressed do
 if $ != undefined then (
  for o in $ do
   if superclassof o == GeometryClass then (
   o.showVertexColors = true
   o.vertexColorType = #illum
  )
  
 completeRedraw()
 )
  
on day_btn pressed do
 if $ != undefined then (
  for o in $ do
   if superclassof o == GeometryClass then (
   o.showVertexColors = true
   o.vertexColorType = #color
  )
 completeRedraw()
 )
  


group "other stuff" (
button ide_script "ide from selection" width:120 align:#center
button copylod_script "copy as lod" width:120 align:#center
button copyni_script "copy no index" width:120 align:#center
button seluniq_script "deselect same name" width:120 align:#center
)

 on ide_script pressed do (
  try ( fileIn (scriptspath+"\\sa_tools\\createIDE.ms") quiet:true)
  catch ()
)

 on seluniq_script pressed do (
  try ( fileIn (scriptspath+"\\sa_tools\\selectUniq.ms") quiet:true)
  catch ()
)

 on copylod_script pressed do (
  try ( fileIn (scriptspath+"\\sa_tools\\copy_as_lod.ms") quiet:true)
  catch ()
)

 on copyni_script pressed do (
  try ( fileIn (scriptspath+"\\sa_tools\\copy_no_index.ms") quiet:true)
  catch ()
)
	label LabelCa "GTA-SA Tools"
	label LabelDa "by Deniska"
----------------------------------------------------------------
)-- end of rollout
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
try (closeRolloutFloater deniska_flo) catch () 
deniska_flo = newRolloutFloater "GTA SA Tools" 220 512 5 50
addRollout Deniska_sa_scripts_rollout deniska_flo rolledup:false