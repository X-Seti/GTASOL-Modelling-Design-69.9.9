utility Blastov "MS Toolbox"
(
group "New Tools" (
button dff_script "Mass DFF Exporter" width:120 align:#center
button ecol_script "Mass COL Exporter" width:120 align:#center
button train_script "Train Paths IO" width:120 align:#center
button cull_script "CULL IO" width:120 align:#center
button occlu_script "OCCLU IO" width:120 align:#center
button anim_script "Map Animation export" width:120 align:#center
button tv_script "UV Anim - TV helper" width:120 align:#center
button salevel_script "SA Level tool" width:120 align:#center
button ide_script "Mass IDE creater" width:120 align:#center
button copylod_script "Copy as LOD object(s)" width:120 align:#center
button copyni_script "Duplicate object(s)" width:120 align:#center
button seluniq_script "Deselect same name" width:120 align:#center
 )

 on dff_script pressed do ( 
  try ( fileIn (scriptspath+"\\blastovs_toolbox\\export_dff.ms") quiet:true   )
  catch messagebox "Please re-install scripts !" \
        title:"Can't find script"
 )
 
 
  on ecol_script pressed do (
  try ( fileIn (scriptspath+"\\blastovs_toolbox\\export_steve_col_script.ms") quiet:true   )
  catch messagebox "Please re-install export_steve_col_script.ms script!" \
        title:"Can't find export_steve_col_script.ms script"
 )


 on train_script pressed do ( 
  try ( fileIn (scriptspath+"\\blastovs_toolbox\\TrainPathsIO.ms") quiet:true   )
  catch messagebox "Please re-install TrainPathsIO script!" \
        title:"Can't find TrainPathsIO script"
 )		


 on cull_script pressed do ( 
  try ( fileIn (scriptspath+"\\blastovs_toolbox\\cull_io.ms") quiet:true   )
  catch messagebox "Please re-install CULL IO script!" \
        title:"Can't find CULL IO script"
 )
 

 on occlu_script pressed do ( 
  try ( fileIn (scriptspath+"\\blastovs_toolbox\\occlu_io.ms") quiet:true   )
  catch messagebox "Please re-install occlu_io.ms script!" \
        title:"Can't find occlu_io.ms script"
 )


 on anim_script pressed do ( 
  try ( fileIn (scriptspath+"\\blastovs_toolbox\\anim_export.ms") quiet:true   )
  catch messagebox "Please re-install anim_export.ms script!" \
        title:"Can't find anim_export.ms script"
)


on tv_script pressed do (
  try ( fileIn (scriptspath+"\\blastovs_toolbox\\TVanimHelper.ms") quiet:true)
  catch messagebox "Please re-install TVanimHelper.ms script!" \
        title:"Can't find TVanimHelper.ms script"
)


on salevel_script pressed do (
  try ( fileIn (scriptspath+"\\blastovs_toolbox\\GtaSA_Level_Tool.ms") quiet:true)
  catch messagebox "Please re-install GtaSA_Level_Tool.ms script!" \
        title:"Can't find GtaSA_Level_Tool.ms script"
)

 on ide_script pressed do (
  try ( fileIn (scriptspath+"\\blastovs_toolbox\\createIDE.ms") quiet:true)
  catch ()
)

 on seluniq_script pressed do (
  try ( fileIn (scriptspath+"\\blastovs_toolbox\\selectUniq.ms") quiet:true)
  catch ()
)

 on copylod_script pressed do (
  try ( fileIn (scriptspath+"\\blastovs_toolbox\\copy_as_lod.ms") quiet:true)
  catch ()
)

 on copyni_script pressed do (
  try ( fileIn (scriptspath+"\\blastovs_toolbox\\copy_no_index.ms") quiet:true)
  catch ()
)

group "Show Vertex Color" (
button day_btn "Day" width:60 align:#left
button night_btn "Night" width:70 align:#right offset:[0,-26]
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
button blast_saeffects "SA Effects" width:140 align:#center	
	on blast_saeffects pressed do (
		try ( fileIn (scriptspath+"\\blastovs_toolbox\\2dfxrevise_release.ms") quiet:true   )
		catch messagebox "Please re-install my Toolbox script!" title:"Can't find SA Effects script"
	)	
	button blast_water "Water.dat editor" width:140 align:#center
	on blast_water pressed do (
		try ( fileIn (scriptspath+"\\blastovs_toolbox\\water_utility.ms") quiet:true   )
		catch messagebox "Please re-install my Toolbox script!" title:"Can't find Water Editor script"
	)
	button blast_nvc1 "Night Vertex Colors tool 1" width:140 align:#center
	on blast_nvc1 pressed do (
		try ( fileIn (scriptspath+"\\blastovs_toolbox\\NightVertCol_final.ms") quiet:true   )
		catch messagebox "Please re-install my Toolbox script!" title:"Can't find Night Vertex Colors tool 1script"
	)
	button blast_nvc2 "Night Vertex Colors tool 2" width:140 align:#center
	on blast_nvc2 pressed do (
		try ( fileIn (scriptspath+"\\blastovs_toolbox\\NVCExport.ms") quiet:true   )
		catch messagebox "Please re-install my Toolbox script!" title:"Can't find Night Vertex Colors tool 2 script"
	)	
	button blast_brokenmesh "Broken Mesh" width:140 align:#center
	on blast_brokenmesh pressed do (
		try ( fileIn (scriptspath+"\\blastovs_toolbox\\exportSectionMeshEXT_v1_utility.ms") quiet:true   )
		catch messagebox "Please re-install my Toolbox script!" title:"Can't find Broken Mesh script"
	)	
	button blast_uvanim "UV Animation export" width:140 align:#center
	on blast_uvanim pressed do (
		try ( fileIn (scriptspath+"\\blastovs_toolbox\\UVanim_tool_v2.0_utility.ms") quiet:true   )
		catch messagebox "Please re-install my Toolbox script!" title:"Can't find UV Animation export script"
	)	
	button blast_sapaths "SA Path Tool" width:140 align:#center
	on blast_sapaths pressed do (
		try ( fileIn (scriptspath+"\\blastovs_toolbox\\PathTool.ms") quiet:true   )
		catch messagebox "Please re-install my Toolbox script!" title:"Can't find SA Path Tool script"
	)	
	button blast_pathsgen "VC\GTA3 Path Generator" width:140 align:#center
	on blast_pathsgen pressed do (
		try ( fileIn (scriptspath+"\\blastovs_toolbox\\PathGenerator.ms") quiet:true   )
		catch messagebox "Please re-install my Toolbox script!" title:"Can't find Path Generator script script"
	)	
	button blast_vcpathimport "VC Path Importer" width:140 align:#center
	on blast_vcpathimport pressed do (
		try ( fileIn (scriptspath+"\\blastovs_toolbox\\VCPaths.ms") quiet:true   )
		catch messagebox "Please re-install my Toolbox script!" title:"Can't find VC Path Importer script script"
	)
	
	group "Kam's GTA Scripts" (
		button script01 "DFF IO" width:140 align:#center
		button script02 "Collision IO" width:140 align:#center --offset:[0,-5]
		button script03 "Map IO" width:140 align:#center --offset:[0,-5]
		button script04 "IFP dump" width:140 align:#center tooltip:"This script is for GMax only"--offset:[0,-5]
		button script05 "IFP IO" width:140 align:#center --offset:[0,-5]
		button script06 "Modelling Helper" width:140 align:#center --offset:[0,-5]
		button script07 "Envelopes Helper" width:140 align:#center --offset:[0,-5]
		spinner tuneRef "Ref. increment" fieldwidth:45 range:[-100,100,0] align:#right
		button MtlFix "Apply increment" width:120 tooltip:"Apply Reflection increment to all selected objects" align:#center --offset:[0,-5]

	)
		on script01 pressed do ( 
			try ( fileIn (scriptspath+"\\GTA_Tools\\GTA_DFF_IO.ms") quiet:true   )
			catch messagebox "Please re-install my DFF IO script!" title:"Can't find DFF IO script"
		)		
		on script02 pressed do (   
			try ( fileIn (scriptspath+"\\GTA_Tools\\GTA_COL_IO.mse") quiet:true   )
			catch messagebox "Please re-install my Collision IO script!" title:"Can't find Collision IO script"
		)
		on script03 pressed do ( 
			try ( fileIn (scriptspath+"\\GTA_Tools\\GTA_Map_IO.ms") quiet:true   )
			catch messagebox "Please re-install my Map IO script!" title:"Can't find Map IO script"
		)	
		on script04 pressed do (
			try ( fileIn (scriptspath+"\\GTA_Tools\\GTA_IFP_dump.ms") quiet:true   )
			catch messagebox "Please re-install my IFP IO script!" title:"Can't find Animation IO script"
		)	
		on script05 pressed do (
			try ( fileIn (scriptspath+"\\GTA_Tools\\GTA_IFP_IO.ms") quiet:true   )
			catch messagebox "Please re-install my IFP IO script!" title:"Can't find Animation IO script"
		)
		on script06 pressed do ( 
			try ( fileIn (scriptspath+"\\GTA_Tools\\GTA_Helper_v31.ms") quiet:true   )
			catch messagebox "Please re-install my Helper script!" title:"Can't find Helper script"
		)
		on script07 pressed do ( 
			try ( fileIn (scriptspath+"\\GTA_Tools\\Kam_envelope_tools.ms") quiet:true   )
			catch messagebox "Please re-install my Helper script!" title:"Can't find Helper script"
		)
	on MtlFix pressed do (
 		if $selection.count > 0 then ( 
  			objAry = $selection as array
  			for obj in objAry where obj.material != undefined do (
   				if classof obj.material == Multimaterial then (
    				for i = 1 to obj.material.count do (
     					oldref = obj.material[i].Reflection
     					newref = tuneRef.value - oldref
     					if newref < 0 then newref = 0
     					if newref > 100 then newref = 100
     					obj.material[i].Reflection = newref
					)
				) else (
					oldref = obj.material.Reflection
					newref = oldref + tuneRef.value
					if newref < 0 then newref = 0
					if newref > 100 then newref = 100
					obj.material.Reflection = newref
				)
			)
 		)
	) 
	    	
)
openUtility Blastov