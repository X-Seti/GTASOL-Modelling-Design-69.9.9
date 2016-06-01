--utility to export mirror data from a plane, to a cull line for SA
--dec 14, 2006 Jesse Thoe
utility cullmirexp "Cull Mirror" width:162 height:300
(
	button btn_mirexp "Export Mirror" pos:[12,72] width:72 height:24
	radioButtons rdo1 "Write Data To" pos:[12,20] width:60 height:46 labels:#("Listener", "File") default:1 columns:1
	groupBox grp2 "Mirrors" pos:[6,4] width:150 height:96
	groupBox grp3 "Notes" pos:[4,104] width:152 height:55
	label lbl2 "Exports cull mirror data from a Plane" pos:[12,124] width:140 height:24
	
	local path = "C:\\temp.txt"
	local extradata = 0
	
	fn mirfn =
	(
		if rdo1.state == 2 then
		(
		createfile path
		cullstream = openfile path mode: "wt"
		)
		
		for obj in $ do
		(
		--gather info
		mirrordir = 0
		--print obj.dir
		--direction stuff
		(
			if obj.dir.x != 0 then
			(
				--if not zero, still need to determine if positive or negative
				--if greater than 0, it must be positive
				if obj.dir.x > 0 then
				(
					mirrordir = obj.pos.x * -obj.dir.x
				)
				else --handle a negative value
				(
					mirrordir = obj.pos.x * obj.dir.x
				)
				format "X Dir: %, Rot X: %\n" mirrordir obj.dir.x
			)
			else
			
			if obj.dir.y != 0 then
			(
				if obj.dir.y > 0 then
				(
					mirrordir = obj.pos.y * -obj.dir.y
				)
				else
				(
					mirrordir = obj.pos.y * obj.dir.y
				)
				format "Y Dir: %, Rot Y: %\n" mirrordir obj.dir.y
			)
			else
			if obj.dir.z != 0 then
			(
				if obj.dir.z > 0 then
				(
					mirrordir = obj.pos.z * -obj.dir.z
				)
				else
				(
					mirrordir = obj.pos.z * obj.dir.z
				)
				format "Z Dir: %, Rot Z: %\n" mirrordir obj.dir.z
			)
		)
		--prepare data
		objpos = obj.pos
		zero = 0
		Y1 = obj.length --radius or width?
		zbottom = obj.pos.z --should do bounds check here?
		X1 = obj.width --radius or length?
		zero2 = 0
		--ztop = zbottom + 15 --just add 15 units for now, see if that helps
		ztop = obj.height + obj.pos.z
		effect = 0--1
		objrot = -obj.dir --obj.rotation.axis --as point3
		Cm = mirrordir
		
		--write data, try to match formatting as close as possible (write integers as integers, floats as floats, etc)
			if rdo1.state == 1 then
			(
				if extradata == 1 then
				(
					format "begin data for %\n" obj.name
				)
				format "%, %, %, %, %, %, %, %, %, %, %, %, %, %\n" objpos.x objpos.y objpos.z zero Y1 zbottom X1 zero2 ztop effect (objrot.x as integer) (objrot.y as integer) (objrot.z as integer) Cm--to:cullstream
				if extradata == 1 then
				(
					format "end data for %\n" obj.name
				)
			)
			else
			(
				--create file
				--createfile path
				--cullstream = openfile path mode: "wt"
				--write data
				if extradata == 1 then
				(
					format "begin data for %\n" obj.name to:cullstream
				)
				format "%, %, %, %, %, %, %, %, %, %, %, %, %, %\n" objpos.x objpos.y objpos.z zero Y1 zbottom X1 zero2 ztop effect (objrot.x as integer) (objrot.y as integer) (objrot.z as integer) Cm to:cullstream
				if extradata == 1 then
				(
					format "end data for %\n" obj.name to:cullstream
				)
			)
		)
		if rdo1.state == 2 then
		close cullstream
	)--end fn
	
	on btn_mirexp pressed do
	(
		if $ != undefined then
		mirfn()
		else messagebox "no object selected"
	)
)