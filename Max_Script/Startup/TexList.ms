-- © 2003 by Steve M.
-- 3D Studio Max 8 update by REspawn

utility TEXLIST "Texture List Exporter"
(			
	button make_file "Export"

	on make_file pressed do
	(
		TXT = getSaveFileName types:"Texture List(*.txt)|*.txt|" 
		if TXT != undefined then
		(		
			txt = createFile (TXT)
			global mapfiles = #()
			
			fn addmap mapfile = (
				local mapfileN=mapfile as name 
				
				local index=finditem mapfiles mapfileN 
				if index == 0 do append mapfiles mapfileN 
			)

			enumeratefiles addmap

			sort mapfiles
			format "[TXDList]\nCount=%\nApp=3D Studio Max\n\n" mapfiles.count to:txt
			local i=0
			for mapfile in mapfiles do (
				i+=1
				format "[Texture%]\npath=%\n\n" i (mapfile as string) to:txt
			)
			
			close txt
		)
	)	
)