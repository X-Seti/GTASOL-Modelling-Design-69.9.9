utility Den_sa_paths "SA-PATH-TOOL"
(
label lbl10 "--------------"
label lbl11 "SA path export"
label lbl12 "by Deniska"
label lbl13 "--------------"

button GO_PATHS "RUN" width:100 align:#center
 on GO_PATHS pressed do ( 
  try ( fileIn (scriptspath+"\\sa_paths_scripts\\sa_path_tool.ms") quiet:true   )
  catch messagebox "Please re-install scripts !" \
        title:"Can't find script"
 )

) -- utility

--openUtility Den_sa_paths