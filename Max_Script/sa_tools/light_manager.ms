rollout light_manager_rol "lights"
(
button lon "ON" align:#left width:60 across:2
button loff "OFF" align:#right width:60

label l01 "multiplier" align:#left across:2
spinner mul "" type:#float range:[0, 10000, 1.0] width:50
label l05 "multiplier incr." align:#left across:2
spinner mulinr "" type:#float range:[0, 10000, 0.0] width:50

label l02 "color" align:#left across:2
colorPicker col "" align:#right

label l03 "far atten start" align:#left across:2
spinner fas "" type:#float range:[0, 10000, 10.0] width:50
label l04 "far atten end" align:#left across:2
spinner fae "" type:#float range:[0, 10000, 20.0] width:50

button fashow "FA SHOW/HIDE"

on fashow pressed do 
 if $!=undefined then
    for obj in selection do 
	   if SuperclassOF obj == light then
          obj.showFarAtten = not obj.showFarAtten  

on lon pressed do 
 if $!=undefined then 
    for obj in selection do 
	   if SuperclassOF obj == light then
          obj.enabled = true

on loff pressed do 
 if $!=undefined then 
    for obj in selection do 
	   if SuperclassOF obj == light then
          obj.enabled = false		  
		  
on mul changed val do 
 if $!=undefined then 
    for obj in selection do 
	   if SuperclassOF obj == light then
          obj.multiplier = val

on mulinr changed val do 
 if $!=undefined then 
    for obj in selection do 
	   if SuperclassOF obj == light then
          obj.multiplier += val		  

on col changed val do 
 if $!=undefined then 
    for obj in selection do 
	   if SuperclassOF obj == light then
          obj.color = val	

on fas changed val do 
 if $!=undefined then
    for obj in selection do
	   if SuperclassOF obj == light then
          obj.farAttenStart = val

on fae changed val do 
 if $!=undefined then
    for obj in selection do
	   if SuperclassOF obj == light then
          obj.farAttenEnd = val


) -- roll

try (closeRolloutFloater light_manager_flo  ) catch () 
light_manager_flo   = newRolloutFloater "" 170 260 20 130 
addRollout  light_manager_rol light_manager_flo 