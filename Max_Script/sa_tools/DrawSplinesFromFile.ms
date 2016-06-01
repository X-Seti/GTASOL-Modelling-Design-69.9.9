fname = getOpenFileName ()
if fname != undefined then
(
    f = fopen fname "rb"
	if f == undefined then messagebox "can't open file"
	else
	(
		while true do
		(
		      ExitFlag = 0
			  SplineFlag = 0
			  while true do
			  (
			        X = readFloat f
					if X==undefined then (ExitFlag = 1; exit)
					if X>9999.0 then exit
					Y = readFloat f
					Z = readFloat f
					Z-=1
					if SplineFlag == 0 then
					(
					   SplineFlag = 1
					   S = SplineShape Pos:[x,y,z]
					   addNewSpline S
					)
					AddKnot S 1 #corner #line [x,y,z]
			  )
			  if SplineFlag > 0 then updateShape S
			  if ExitFlag > 0 then Exit
		) -- while 1
    FClose f
	)
)