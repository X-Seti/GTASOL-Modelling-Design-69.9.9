utility Den_sa_scripts "Deniska SA TOOLS"
(

button dff_script "DFF EXPORT" width:120 align:#center
 on dff_script pressed do ( 
  try ( fileIn (scriptspath+"\\sa_tools\\export_dff.ms") quiet:true   )
  catch messagebox "Please re-install scripts !" \
        title:"Can't find script"
 )
 

 button load_IPLSC "LOAD IPL" width:120 align:#center
 on load_IPLSC pressed do ( 
  try ( fileIn (scriptspath+"\\sa_tools\\load_ipl.ms") quiet:true   )
  catch messagebox "Please re-install scripts !" \
        title:"Can't find script"
 )

button train_script "TRAIN PATHS IO" width:120 align:#center
 on train_script pressed do ( 
  try ( fileIn (scriptspath+"\\sa_tools\\TrainPathsIO.ms") quiet:true   )
  catch messagebox "Please re-install TrainPathsIO script!" \
        title:"Can't find TrainPathsIO script"
 )		

button breake_script "BRAKABLE OBJECTS" width:120 align:#center
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

button waterIO_script "waterIO" width:120 align:#center
 on waterIO_script pressed do ( 
  try ( fileIn (scriptspath+"\\sa_tools\\waterIO.ms") quiet:true   )
  catch messagebox "Please re-install waterIO.ms script!" \
        title:"Can't find waterIO.ms script"
)

button vcpath_script "VCPATH IMPORT" width:120 align:#center
 on vcpath_script pressed do ( 
  try ( fileIn (scriptspath+"\\sa_tools\\pathsimport.ms") quiet:true   )
  catch messagebox "Please re-install pathsimport.ms script!" \
        title:"Can't find pathsimport.ms script"
)

button sa_roadgen "SA Road maker" width:120 align:#center
 on sa_roadgen pressed do ( 
  try ( fileIn (scriptspath+"\\sa_tools\\road_gta.ms") quiet:true   )
  catch messagebox "Please re-install road_gta.ms script!" \
        title:"Can't find road_gta.ms script"
)

button ipltools_but "IPL Tools" width:120 align:#center
 on ipltools_but pressed do ( 
  try ( fileIn (scriptspath+"\\sa_tools\\IPL_TOOL.ms") quiet:true   )
  catch messagebox "Please re-install IPL_TOOL.ms script!" \
        title:"Can't find IPL_TOOL.ms script"
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
button setclr "SET PRELITE" width:120 align:#left
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

on setclr pressed do (
  try ( fileIn (scriptspath+"\\sa_tools\\prelitsetter.ms") quiet:true)
  catch messagebox "Please re-install prelitsetter.ms script!" \
        title:"Can't find prelitsetter.ms script"
)

group "Mahnunt Import" (
button BSP_SC "import BSP" width:120 align:#center
button BSP_SC2 "import BSP2" width:120 align:#center
button BSP_SC3 "import BSP3" width:120 align:#center
button BSP_SC4 "import BSP4" width:120 align:#center
button MEDFF "manhunt explode dff" width:120 align:#center
)

on BSP_SC pressed do (
  try ( fileIn (scriptspath+"\\sa_tools\\import_BSP.ms") quiet:true)
  catch messagebox "Please re-install import_BSP2.ms.ms script!" \
        title:"Can't find import_BSP.ms script"
)


on BSP_SC2 pressed do (
  try ( fileIn (scriptspath+"\\sa_tools\\import_BSP2.ms") quiet:true)
  catch messagebox "Please re-install import_BSP2.ms script!" \
        title:"Can't find import_BSP2.ms.ms script"
)

on BSP_SC3 pressed do (
  try ( fileIn (scriptspath+"\\sa_tools\\import_BSP3.ms") quiet:true)
  catch messagebox "Please re-install import_BSP3.ms script!" \
        title:"Can't find import_BSP3.ms.ms script"
)


on BSP_SC4 pressed do (
  try ( fileIn (scriptspath+"\\sa_tools\\import_BSP4.ms") quiet:true)
  catch messagebox "Please re-install import_BSP4.ms script!" \
        title:"Can't find import_BSP4.ms.ms script"
)


on MEDFF pressed do (
  try ( fileIn (scriptspath+"\\sa_tools\\manhunt_explode_dff.ms") quiet:true)
  catch messagebox "Please re-install manhunt_explode_dff.ms script!" \
        title:"Can't find manhunt_explode_dff.ms script"
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

) -- utility

--openUtility Den_sa_scripts