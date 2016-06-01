-- NVC Exporter
-- Version 0.1
-- Created / Copyright 2007 David Brennan
-- www.turnipfan.com
--
-- Based on Assignment.ms by Kam

utility NVCEXPORT "NVC Exporter"
(			
	fn mshfilter msh = (classof msh == Editable_mesh)AND((getNumCPVVerts msh) > 0)
	
	button make_file "Export NVC" filter:mshfilter
	spinner b01 "" fieldwidth:30 type:#integer range:[0,255,1] align:#center across:4
	spinner b02 "" fieldwidth:30 type:#integer range:[0,255,1] align:#center
	spinner b03 "" fieldwidth:30 type:#integer range:[0,255,1] align:#center
  	spinner b04 "" fieldwidth:30 type:#integer range:[0,255,1] align:#center 	
  	
	on make_file pressed do(
		objs = for i in selection collect i
		if objs.count == 0 then(
			MessageBox "No objects selected to export" title:"NVC Export"
		)
		else(
			for x = 1 to objs.count do(
				msh = objs[x]
				NVC = getSaveFileName types:"NVC Data(*.nvc)|*.nvc|" 
				if NVC != undefined then(		
					nvc = fopen NVC "wb"

					writebyte nvc b01.value
					writebyte nvc b02.value
					writebyte nvc b03.value
					writebyte nvc b04.value
					
					for i = 1 to msh.numverts do (
					    	vc = getVertColor msh i
						writebyte nvc vc.r
						writebyte nvc vc.g
						writebyte nvc vc.b
						writebyte nvc vc.a
	  				)
										
		
					fclose nvc
				)
			)
		)
	)	
)
openUtility NVCEXPORT