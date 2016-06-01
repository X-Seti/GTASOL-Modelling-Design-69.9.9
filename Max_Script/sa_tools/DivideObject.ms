
--------------------------------------------------------------------------------
-- CGTalk Challenge 2 - Divide Object
-- version 1.0
-- max version 6, 7
-- written by Joshua Newman
-- www.joshuanewman.net (http://www.joshuanewman.net/)
-- written 22/06/05
-- last updated 22/06/05
-- copyright 2005
--------------------------------------------------------------------------------
--
-- divides an editable poly into any (ok up to 100 each axis) objects

global obj, pgttl
rollout CGTalk_divider "Parameters"
(
-- Functions
fn objfilter obj=classof obj==Editable_Poly
-- Rollout items
pickbutton pobj "Pick Editable Poly!" width:240 filter:objfilter
group "Segments"
(
spinner xd "X objects:" type:#integer range:[1,100,2]
spinner yd "Y objects:" type:#integer range:[1,100,2]
spinner zd "Z objects:" type:#integer range:[1,100,2]
label objnum "objects:8" align:#right
label fcenum "faces:0" align:#right
)
checkbox obox "original to boxmode" checked:false across:2
checkbox ohde "hide original" checked:true offset:[28,0]

button go "Divide" width:240 height:50 enabled:false

progressbar prgrss "" color:red

label l1 "\xa9 2005 Joshua Newman" across:2 offset:[-8,0]
hyperlink hl "www.joshuanewman.net (http://www.joshuanewman.net/)" address:"www.joshuanewman.net (http://www.joshuanewman.net/)" offset:[4,0]
-- rollout functions
fn updatedisplay c=
(
pgttl=(zd.value*yd.value*xd.value)
objnum.text=("Objects:"+pgttl as string)
if obj!=undefined then
(
fcenum.text=("faces:"+(obj.numfaces*pgttl) as string)
)
)
-- rollout events
on xd changed c do updatedisplay c
on yd changed c do updatedisplay c
on zd changed c do updatedisplay c

on pobj picked o do
(
obj=o
pobj.text=obj.name
go.enabled=true
)

on CGTalk_divider open do
(
-- this routine scans the current selection to look for a likely source object, and if it finds one, it places it in the settings
for s in selection do
(
if classof s==Editable_Poly then
(
pobj.text=s.name
obj=s
print s
go.enabled=true
fcenum.text=("faces:"+(obj.numfaces*8) as string)
exit
)
)
)
-- the start of the prcess
on go pressed do
(
-- get the parameter values into variables
xdiv=xd.value
ydiv=yd.value
zdiv=zd.value

-- the objects vital statistics
size=obj.max-obj.min
zval=size.z*1./zdiv
yval=size.y*1./ydiv
xval=size.x*1./xdiv

-- check the hide and boxmode settings and act as appropriate
if obox.state then obj.boxmode=true -- make the origianl object display in boxmode
if ohde.state then hide obj -- hide the original object

-- some variables
zobj=#()
yobj=#()
xobj=#()
-- progressbar
pgvlu=0

-- Z slice!

for i=1 to zdiv do
(
local tmp=copy obj
polyop.slice tmp tmp.faces (ray [obj.pos.x,obj.pos.y,obj.min.z+zval*(i-1)] [0,0,1]) -- slice bottom segment
polyop.slice tmp tmp.faces (ray [obj.pos.x,obj.pos.y,obj.min.z+zval*i] [0,0,1]) -- slice top segment
fces=for i in tmp.faces collect i.index -- collect the faces into an array
dlfcs=#()
for f in fces do if (polyop.getfacecenter tmp f).z<(obj.min.z+(zval*(i-1))) then append dlfcs f -- collect the faces below the slice
for f in fces do if (polyop.getfacecenter tmp f).z>(obj.min.z+(zval*i)) then append dlfcs f -- collect the faces above the slice
if dlfcs.count>0 then polyop.deletefaces tmp (dlfcs as bitarray) delisoverts:true -- if the list isn't emply, delete the faces
polyop.capholesbyface tmp (tmp.faces as bitarray) -- cap holes! - this is using all faces! could be costly on large polys
append zobj tmp
pgvlu+=1 -- increase the progress
prgrss.value=100./pgttl*pgvlu -- update the progressbar
)
-- Y slice
for z in zobj do
(
for i=1 to ydiv do
(
local tmp=copy z
polyop.slice tmp tmp.faces (ray [obj.pos.x,obj.min.y+yval*(i-1),obj.pos.z] [0,1,0]) -- slice bottom segment
polyop.slice tmp tmp.faces (ray [obj.pos.x,obj.min.y+yval*i,obj.pos.z] [0,1,0]) -- slice top segment
fces=for i in tmp.faces collect i.index -- collect the faces into an array
dlfcs=#()
for f in fces do if (polyop.getfacecenter tmp f).y<(obj.min.y+(yval*(i-1))) then append dlfcs f -- collect the faces below the slice
for f in fces do if (polyop.getfacecenter tmp f).y>(obj.min.y+(yval*i)) then append dlfcs f -- collect the faces above the slice
if dlfcs.count>0 then polyop.deletefaces tmp (dlfcs as bitarray) delisoverts:true -- if the list isn't emply, delete the faces
polyop.capholesbyface tmp (tmp.faces as bitarray) -- cap holes! - this is using all faces! could be costly on large polys
append yobj tmp
pgvlu+=1 -- increase the progress
prgrss.value=100./pgttl*pgvlu -- update the progressbar
)
)
-- X slice
for y in yobj do
(
for i=1 to xdiv do
(
local tmp=copy y
polyop.slice tmp tmp.faces (ray [obj.min.x+xval*(i-1),obj.pos.y,obj.pos.z] [1,0,0]) -- slice bottom segment
polyop.slice tmp tmp.faces (ray [obj.min.x+xval*i,obj.pos.y,obj.pos.z] [1,0,0]) -- slice top segment
fces=for i in tmp.faces collect i.index -- collect the faces into an array
dlfcs=#()
for f in fces do if (polyop.getfacecenter tmp f).x<(obj.min.x+(xval*(i-1))) then append dlfcs f -- collect the faces below the slice
for f in fces do if (polyop.getfacecenter tmp f).x>(obj.min.x+(xval*i)) then append dlfcs f -- collect the faces above the slice
if dlfcs.count>0 then polyop.deletefaces tmp (dlfcs as bitarray) delisoverts:true -- if the list isn't emply, delete the faces
polyop.capholesbyface tmp (tmp.faces as bitarray) -- cap holes! - this is using all faces! could be costly on large polys
append xobj tmp
pgvlu+=1 -- increase the progress
prgrss.value=100./pgttl*pgvlu -- update the progressbar
)
)
-- remove the temporary slices
delete zobj
delete yobj
prgrss.value=0 -- reset progress bar
select xobj -- select new objects
)
)
newroll=newrolloutfloater "CGTalk - Challenge 2 - Divider." 260 302 750 80
addrollout CGTalk_divider newroll