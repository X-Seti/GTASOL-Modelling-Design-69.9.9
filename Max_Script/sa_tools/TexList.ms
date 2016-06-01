-- © 2003 by Steve M.

utility TEXLIST "Texture List Exporter"
(			
	button make_file "Export"

	on make_file pressed do
	(
		TXT = getSaveFileName types:"Texture List(*.txt)|*.txt|" 
		if TXT != undefined then
		(		
			txt = createFile (TXT)
			local mapfiles = #()

			fn addmap mapfile = (
				local mapfileN=mapfile as name 
				local index=finditem mapfile mapfileN 
				if index == 0 do append mapfile mapfileN 
			)

			enumeratefiles addmap

			sort mapfile
			format "[TXDList]\nCount=%\nApp=3D Studio Max\n\n" mapfile.count to:txt
			local i=0
			for mapfile in mapfile do (
				i+=1
				format "[Texture%]\npath=%\n\n" i (mapfile as string) to:txt
			)
			
			close txt
		)
	)	
)