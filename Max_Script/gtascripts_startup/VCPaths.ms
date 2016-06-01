--------------------------------------
-- © 2003 by Steve M.               --
-- Version 0.3 | 06/14/2003			--
-- st.mu@web.de						--
-- http://people.freenet.de/steve-m --
--------------------------------------

utility VCPaths "VC Path Importer"
(

	button btnLoadNow "Import Paths..." pos:[39,7] width:84 height:21
	checkbox chkPeds "Peds" pos:[13,33] width:48 height:15 checked:true
	checkbox chkCars "Cars" pos:[59,33] width:45 height:15 checked:true
	checkbox chkBoats "Boats" pos:[103,33] width:51 height:15 checked:true
	progressBar prg 
	
	
	global fname
	
	
	fn LoadIPL fin =
	(	
		local path = #(),	-- Path SplineShape
		 	  s, 			-- Spline Number
			  type, 		-- ped, car or boat
			  links, 		-- Path Link Numbers
			  points,		-- Path Point Locations
		      ln, 			-- actual line in textfile
			  i,
			  filesize
			  
			
		prg.value = 0
		-- get filesize:	
		seek fin #eof
		filesize = filepos fin
		seek fin 0	  
			  
		do ( ln = readline fin ) while ( ln != "path" ) and ( not eof fin )
		
		if not eof fin then
		(		
			if chkPeds.checked then
			(
				path[1] = splineshape name:"Ped Paths" renderable:true thickness:1.5
				path[1].wireColor = (color 0 255 0)  -- peds (green)
			)
			if chkCars.checked then
			(
				path[2] = splineshape name:"Car Paths" renderable:true thickness:3.0
				path[2].wireColor = (color 255 0 0)  -- cars (red)
			)
			if chkBoats.checked then
			(	
				path[3] = splineshape name:"Boat Paths" renderable:true thickness:2.5
				path[3].wireColor = (color 0 0 255)  -- boats (blue)					
			)
		
			while ( ln = readline fin ) != "end" do
			(
				if ln!="" and ln[1] != "#" then
				(
					data = filterString ln ", "				
					type = (data[1] as Integer)+1
				)
				else
				(
					type = 0
				)
				
				if ln!="" and ln[1] != "#" and ((type==1 and chkPeds.checked) or (type==2 and chkCars.checked) or (type==3 and chkBoats.checked)) then
				(
					links = #()
					points = #()
					
					--format "Pos: %\n" (filepos fin)
					prg.value = 100.0*(filepos fin)/filesize
					
					for i=1 to 12 do
					(
						ln = readline fin
						data = filterString ln ", "
												
						if ln!="" and ((data[1] as Integer)==1 or (data[1] as Integer)==2) then
						(						
							append links ((data[2] as Integer)+1)
							append points [(data[4] as Float)/16, (data[5] as Float)/16, (data[6] as Float)/16]							
						)
						else ( i+=1 )					
					)
					
					-- LIMIT (enable to load only paths within the defined rectangle)
					--if points[1].x>-1980 and points[1].x<-1160 and points[1].y>-870 and points[1].y<-80 then
					(
						for i=1 to links.count do if links[i]>0 then
						(
					  		s = addnewSpline path[type]	
							addKnot path[type] s #corner #line points[i]
							addKnot path[type] s #corner #line points[links[i]]			
						)
					)
				)
				else
				(
					if type==1 or type==2 or type==3 then for i=1 to 12 do readline fin -- Skip unneeded section
				)
			)
			
			if chkPeds.checked then updateShape path[1]
			if chkCars.checked then updateShape path[2]
			if chkBoats.checked then updateShape path[3]
		)
		
		prg.value = 0

		return true
	)
	
	
	
--------------
	
	
	fn GetOpenFileStream =
	(
		local fin = openFile fname
		if (fin == undefined) then
		(
			messageBox "Could not open file for text reading!"
			return undefined
		)

		return fin
	)

	on btnLoadNow pressed do
	(
		fname = getOpenFileName types:"paths.ipl|paths.ipl|IPL Files (*.ipl)|*.ipl|"
		if (fname != undefined) then
		(
			local fin = GetOpenFileStream()
			if (fin != undefined) then
			(
				if ((LoadIPL fin) == true) then
					print "IPL file import successful."
				else
					print "IPL file import failed."
				fclose fin
			)
		)
	)
)