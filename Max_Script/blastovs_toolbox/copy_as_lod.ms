s = selection as array
clearSelection ()

for i = 1 to s.count do
 (
  new_ob = copy s[i]
  new_ob.name = "LOD" + (substring s[i].name 1 -1)
  selectmore new_ob
  setUserPropBuffer new_ob (getUserPropBuffer s[i])
 )
 