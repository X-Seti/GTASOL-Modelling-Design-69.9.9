rollout day_night_rol "Prelite Tool's" height:150
(
button day "  SET DAY  " across:2 align:#left
colorpicker cday "" color:(color 170 170 170) fieldWidth:60 align:#right
button night "SET NIGHT" across:2 align:#left
colorpicker cnight "" color:(color 25 25 25) fieldWidth:60 align:#right
button repl "DVC -> NVC" across:2 align:#left
button unrepl "NVC -> DVC" across:2 align:#left

on day pressed do
if $!=undefined then
  for obj in selection do (
    --if classof obj != Editable_Poly then
 polyOp.defaultMapFaces obj 0
    for i = 1 to obj.numverts do (
        polyOp.setMapVert obj 0 i \
                            [(cday.color.r)/255.0, \
           (cday.color.g)/255.0, \
           (cday.color.b)/255.0] )       
) -- day

on night pressed do
if $!=undefined then
  for obj in selection do (
    --if classof obj != Editable_Poly then
 polyOp.defaultMapFaces obj -1
    for i = 1 to obj.numverts do
        polyOp.setMapVert obj -1 i \
                            [(cnight.color.r)/255.0, \
           (cnight.color.g)/255.0, \
           (cnight.color.b)/255.0]        
) -- night

on repl pressed do (
ch1 = 0 -- откуда копируем (0 - vertex color)
ch2 = -1 -- куда (-1 - vert illum)
if $!=undefined then (
for obj in selection do (
 --if classof obj == editable_poly then (
  polyOp.defaultMapFaces obj ch2
  polyOp.setMapSupport obj ch2 true
  vcnum = polyOp.getNumMapVerts obj ch1
  polyOp.setNumMapVerts obj ch2 vcnum
  for i = 1 to vcnum do
    polyOp.setMapVert obj ch2 i (polyOp.getMapVert obj ch1 i)
  vcfaces = polyOp.getNumMapFaces obj ch1
  polyOp.setnummapfaces obj ch2 vcfaces
  for i = 1 to vcfaces do
    polyOp.setMapFace obj ch2 i (polyOp.getMapFace obj ch1 i) 
--print vcnum
--print obj.name
 )
)
)

on unrepl pressed do (
ch1 = -1 -- откуда копируем (0 - vertex color)
ch2 = 0 -- куда (-1 - vert illum)
if $!=undefined then (
for obj in selection do (
 --if classof obj == editable_poly then (
  polyOp.defaultMapFaces obj ch2
  polyOp.setMapSupport obj ch2 true
  vcnum = polyOp.getNumMapVerts obj ch1
  polyOp.setNumMapVerts obj ch2 vcnum
  for i = 1 to vcnum do
    polyOp.setMapVert obj ch2 i (polyOp.getMapVert obj ch1 i)
  vcfaces = polyOp.getNumMapFaces obj ch1
  polyOp.setnummapfaces obj ch2 vcfaces
  for i = 1 to vcfaces do
    polyOp.setMapFace obj ch2 i (polyOp.getMapFace obj ch1 i) 
--print vcnum
--print obj.name
 )
)
)
)

try (closerolloutfloater day_night_flo) catch ()
day_night_flo = newrolloutfloater "" 200 100 20 150
addrollout day_night_rol day_night_flo
