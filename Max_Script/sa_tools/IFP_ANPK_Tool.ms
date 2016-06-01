utility yelmi_IFP_anpk "IFP-ANPK-TOOL"
(
label lbl10 "--------------"
label lbl11 "SA ANPK export"
label lbl12 "by yelmi"
label lbl13 "coauthor:- DENISka" 
label lbl14 "--------------"

button GO_CAM "Camera" width:140 align:#center
 on GO_CAM pressed do ( 
  try ( fileIn (scriptspath+"\\GTA_Tools\\SetCamera.ms") quiet:true   )
  catch messagebox "Please re-install scripts !" \
        title:"Can't find script"
 )
group "Animation" (
  button GO_OBJ "ANPK" width:140 align:#center offset:[0,-5]
  ) -- group
   on GO_OBJ pressed do ( 
    try ( fileIn (scriptspath+"\\GTA_Tools\\IFP_ANPK.ms") quiet:true   )
    catch messagebox "Please re-install scripts !" \
        title:"Can't find script"
   )

) -- utility

openUtility yelmi_IFP_anpk