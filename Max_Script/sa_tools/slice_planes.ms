rollout slicePlanes_rol "" width:162 height:81
(
	button button_go "sclice planes" pos:[11,5] width:138 height:25
	spinner xstep "" pos:[86,36] width:63 height:16 range:[0.01, 10000, 10.0] type:#float
	spinner ystep "" pos:[86,55] width:63 height:16 range:[0.01, 10000, 10.0] type:#float
	label lbl1"x_step" pos:[16,37] width:65 height:15
	label lbl2 "y_step" pos:[18,54] width:65 height:15
	button rem_go "remove_#verts" pos:[11,78] width:138 height:25

on button_go pressed do (

s = $selection[1]

convertTo s (Editable_Poly)

rx = xstep.value
ry = ystep.value

smin = s.min
smax = s.max

x = smin.x
do (
p = (ray [x, smin.y , smin.z] [1,0,0])
polyOp.slice s #all p
x += rx
)
while (x<smax.x)

y = smin.y
do (
p = (ray [smin.x, y , smin.z] [0,1,0])
polyOp.slice s #all p
y += ry
)
while (y<smax.y)
 
) -- pressed

on rem_go pressed do (
s = selection[1]
vs = #{}

for i = 1 to s.NumVerts do (
 a = (polyOp.getEdgesUsingVert s i) as array
 if a.count<3 do vs+=#{i}
)

polyOp.setVertSelection s vs
s.Remove selLevel:#Vertex
) -- pressed 

) -- rollout

try (closeRolloutFloater slicePlanes_rol) catch () 
mbevel_flo = newRolloutFloater "" 170 165 20 130 
addRollout  slicePlanes_rol mbevel_flo