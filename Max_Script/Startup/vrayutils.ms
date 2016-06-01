fn sqr x = x*x

-- used to look up materials that have already been converted
orig_mtls=#()
new_mtls=#()

fn convertFrom_Standard origMtl = (
	r=VRayMtl()
	r.name="vray "+origMtl.name
	
	r.texmap_bump=origMtl.bumpMap
	r.texmap_bump_on=origMtl.bumpMapEnable
	r.texmap_bump_multiplier=origMtl.bumpMapAmount

	r.texmap_displacement=origMtl.displacementMap
	r.texmap_displacement_on=origMtl.displacementMapEnable
	r.texmap_displacement_multiplier=origMtl.displacementMapAmount

	r.diffuse=origMtl.diffuse
	r.texmap_diffuse=origMtl.diffuseMap
	r.texmap_diffuse_on=origMtl.diffuseMapEnable
	r.texmap_diffuse_multiplier=origMtl.diffuseMapAmount

	r.reflection=origMtl.specular*origMtl.specularLevel*0.01
	
	K=2.0^(origMtl.glossiness*0.01*10.0)
	if (origMtl.shaderType==5) then (
		-- phong
		r.brdf_type=0
		r.reflection=r.reflection*2.0/(K+1.0)
	) else (
		-- blinn
		r.brdf_type=1
		K=K*4
		r.reflection=r.reflection*8.0/(K+1.0)
	)
	
	r.reflection_lockGlossiness=false
	r.hilight_glossiness=1.0-(1.0/(K+1.0))^(1.0/3.5)
	r.reflection_glossiness=1.0
	r.option_traceReflection=false
	
	r.texmap_opacity=origMtl.opacityMap
	r.texmap_opacity_on=origMtl.opacityMapEnable
	r.texmap_opacity_multiplier=origMtl.opacityMapAmount
	
	r
)

fn convertFrom_Raytrace origMtl = (
	r=VRayMtl()
	r.name="vray "+origMtl.name

	r.texmap_bump=origMtl.bumpMap
	r.texmap_bump_on=origMtl.bumpMapEnable
	r.texmap_bump_multiplier=origMtl.bumpMapAmount

	r.texmap_displacement=origMtl.displacementMap
	r.texmap_displacement_on=origMtl.displacementMapEnable
	r.texmap_displacement_multiplier=origMtl.displacementMapAmount

	r.diffuse=origMtl.diffuse
	r.texmap_diffuse=origMtl.diffuseMap
	r.texmap_diffuse_on=origMtl.diffuseMapEnable
	r.texmap_diffuse_multiplier=origMtl.diffuseMapAmount

	r.reflection=origMtl.spec__color*origMtl.specular_level*0.01*0.5
	
	K=2.0^(origMtl.glossiness*0.01*10.0)
	if (origMtl.shaderType==1) then (
		-- phong
		r.brdf_type=0
		r.reflection=r.reflection*2.0/(K+1.0)
	) else (
		-- blinn
		r.brdf_type=1
		K=K*4
		r.reflection=r.reflection*8.0/(K+1.0)
	)

	if (origMtl.reflect.r>r.reflection.r) then r.reflection.r=origMtl.reflect.r
	if (origMtl.reflect.g>r.reflection.g) then r.reflection.g=origMtl.reflect.g
	if (origMtl.reflect.b>r.reflection.b) then r.reflection.b=origMtl.reflect.b
	
	r.reflection_lockGlossiness=false
	r.hilight_glossiness=1.0-(1.0/(K+1.0))^(1.0/3.5)
	
	if ((origMtl.reflect.r+origMtl.reflect.g+origMtl.reflect.b)/3.0<1e-6) then r.option_traceReflection=false
	
	r.texmap_reflection=origMtl.reflectionMap
	r.texmap_reflection_on=origMtl.reflectionMapEnable
	r.texmap_reflection_multiplier=origMtl.reflectionMapAmount
	
	r.refraction=origMtl.transparecy
	r.refraction_ior=origMtl.Index_of_Refraction

	r.texmap_refraction=origMtl.transparencyMap
	r.texmap_refraction_on=origMtl.transparencyMapEnable
	r.texmap_refraction_multiplier=origMtl.transparencyMapAmount

	r
)

fn convertFrom_fR_Advanced origMtl = (
	r=VRayMtl()
	r.name="vray "+origMtl.name
	
	-- diffuse
	r.diffuse=origMtl.diffuseColor
	r.texmap_diffuse=origMtl.diffuseMap
	r.texmap_diffuse_on=origMtl.useDiffuseMap
	r.texmap_diffuse_multiplier=origMtl.diffuseMapAmount
	
	-- bump map
	r.texmap_bump=origMtl.bumpMap
	r.texmap_bump_on=origMtl.useBumpMap
	r.texmap_bump_multiplier=origMtl.bumpMapAmount
	
	-- displacement
	r.texmap_displacement=origMtl.MTDMap
	r.texmap_displacement_on=origMtl.useMTDMap
	r.texmap_displacement_multiplier=origMtl.MTDMapAmount

	-- reflection
	r.reflection=origMtl.reflectFilter
	r.texmap_reflection=origMtl.reflectMap
	r.texmap_reflection_on=origMtl.useReflectMap
	r.texmap_reflection_multiplier=origMtl.reflectMapAmount
	
	r.reflection_glossiness=1.0-sqr (origMtl.reflectGlossy*0.01)
	r.texmap_reflectionGlossiness=origMtl.reflectBlurryMap
	r.texmap_reflectionGlossiness_on=origMtl.useReflectBlurryMap
	r.texmap_reflectionGlossiness_multiplier=origMtl.reflectBlurryMapAmount
	
	r.reflection_subdivs=sqrt origMtl.reflectSamples
	r.reflection_fresnel=origMtl.useFresnel
	r.reflection_useInterpolation=origMtl.useReflBlur
	
	-- refraction
	r.refraction=origMtl.refractFilter
	r.texmap_refraction=origMtl.refractMap
	r.texmap_refraction_on=origMtl.useRefractMap
	r.texmap_refraction_multiplier=origMtl.refractMapAmount
	
	r.refraction_ior=origMtl.refractIOR
	r.texmap_refractionIOR=origMtl.refractIORMap
	r.texmap_refractionIOR_on=origMtl.useRefractIORMap
	r.texmap_refractionIOR_multiplier=origMtl.refractIORMapAmount
	
	r.refraction_glossiness=1.0-sqr (origMtl.refractGlossy*0.01)
	r.texmap_refractionGlossiness=origMtl.refractBlurryMap
	r.texmap_refractionGlossiness_on=origMtl.useRefractBlurryMap
	r.texmap_refractionGlossiness_multiplier=origMtl.refractBlurryMapAmount
	
	r.refraction_subdivs=sqrt origMtl.refractSamples
	r.refraction_useInterpolation=origMtl.useRefrBlur
	
	r
)

fn convertFrom_fR_Metal origMtl = (
	r=VRayMtl()
	r.name="vray "+origMtl.name
	
	r.diffuse=origMtl.diffuseColor
	r.texmap_diffuse=origMtl.diffuseMap
	r.texmap_diffuse_on=origMtl.diffuseMapEnable
	r.texmap_diffuse_multiplier=origMtl.diffuseMapAmount
	
	r.reflection=origMtl.reflectColor
	r.texmap_reflection=origMtl.reflectLevelMap
	r.texmap_reflection_on=origMtl.reflectLevelMapEnable
	r.texmap_reflection_multiplier=origMtl.reflectLevelMapAmount
	
	r
)

fn convertFrom_fR_Glass origMtl = (
	r=VRayMtl()
	r.name="vray "+origMtl.name
	
	r.diffuse=origMtl.diffuseColor
	r.texmap_diffuse=origMtl.diffuseMap
	r.texmap_diffuse_on=origMtl.diffuseMapEnable
	r.texmap_diffuse_multiplier=origMtl.diffuseMapAmount

	r.reflection=origMtl.reflectColor
	r.reflection_fresnel=origMtl.useFresnel
	r.texmap_reflection=origMtl.reflectMap
	r.texmap_reflection_on=origMtl.reflectMapEnable
	r.texmap_reflection_multiplier=origMtl.reflectMapAmount
	
	r.refraction=origMtl.refractColor
	r.refraction_ior=origMtl.refractIOR
	r.texmap_refraction=origMtl.refractMap
	r.texmap_refraction_on=origMtl.refractMapEnable
	r.texmap_refraction_multiplier=origMtl.refractMapAmount
	
	r.refraction_affectShadows=true
	r.refraction_affectAlpha=true
	
	r
)

fn convertFromBlend orig_mtl = (
	r=VRayBlendMtl()
	r.name="vray "+orig_mtl.name
	
	r.baseMtl=orig_mtl.map1
	r.coatMtl[1]=orig_mtl.map2
	r.blend[1]=(orig_mtl.mixAmount*0.01)*(color 255 255 255)
	if orig_mtl.maskEnabled then r.texmap_blend[1]=orig_mtl.mask
	
	r
)

fn convertFromShellac orig_mtl = (
	r=VRayBlendMtl()
	r.name="vray "+orig_mtl.name
	r.additiveMode=true
	
	r.baseMtl=orig_mtl.shellacMtl1
	r.coatMtl[1]=orig_mtl.shellacMtl2
	r.blend[1]=(orig_mtl.shellacColorBlend*0.01)*(color 255 255 255)
	
	r
)

fn convertFromDoubleSided orig_mtl = (
	r=VRay2SidedMtl()
	r.name="vray "+orig_mtl.name

	r.frontMtl=orig_mtl.material1
	r.backMtl=orig_mtl.material2
	r.translucency=orig_mtl.translucency*0.01*(color 255 255 255)
	r.backMtlOn=orig_mtl.map2Enabled
	
	r
)

fn convertFrom_Architectural orig_mtl = (
	r=VRayMtl()
	r.name="vray "+orig_mtl.name

	-- diffuse component
	r.diffuse=orig_mtl.diffuse
	r.texmap_diffuse=orig_mtl.diffuseMap
	r.texmap_diffuse_on=orig_mtl.diffuseMapEnable
	r.texmap_diffuse_multiplier=orig_mtl.diffuseMapAmount

	-- specular component
	r.reflection=(color 255 255 255)
	r.texmap_reflection=orig_mtl.shininessMap
	r.reflection_fresnel=true
	r.hilight_glossiness=(orig_mtl.shininess*0.01)*0.25+0.75
	r.reflection_glossiness=1.0
	r.reflection_lockGlossiness=false

	-- refraction
	r.refraction=orig_mtl.transparency*0.01*(color 255 255 255)
	r.refraction_ior=orig_mtl.ior
	
	-- if there is luminance, wrap the material into a VRayBlendMtl and add a VRayLightMtl on top of it
	if orig_mtl.luminance>0 then (
		local l=VRayLightMtl()
		l.color=orig_mtl.diffuse
		l.multiplier=orig_mtl.luminance
		l.opacity_texmap=VRayColor()
		l.opacity_texmap.color=(color 0 0 0)
		
		local m=VRayBlendMtl()
		m.baseMtl=r
		m.coatMtl[1]=l
		m.blend[1]=(color 255 255 255)
		
		r=m
	)
	
	-- if there is translucency, wrap the material into a VRay2SidedMtl
	if orig_mtl.translucency>0 then (
		local m=VRay2SidedMtl()
		m.frontMtl=r
		m.translucency=orig_mtl.translucency*0.01*(color 255 255 255)
		r=m
	)
	
	r
)

fn isVRayCompatible mtl_classid = (
	-- native V-Ray materials
	if mtl_classid==VRayMtl then return true
	if mtl_classid==VRay2SidedMtl then return true
	if mtl_classid==VRayBlendMtl then return true
	if mtl_classid==VRayFastSSS then return true
	if mtl_classid==VRayLightMtl then return true
	if mtl_classid==VRayMtlWrapper then return true
	
	-- supported 3dsmax materials
	if mtl_classid==Multimaterial then return true
	
	false
)

fn createVRayMtl orig_mtl = (
	-- check if this is a material; if not, just return the value
	if ((superclassof orig_mtl)!=material) then return orig_mtl

	-- check if we have already converted this material; if yes, just return
	-- the already converted one	
	local i=findItem orig_mtls orig_mtl
	if i>0 then return new_mtls[i]

	-- recurse into sub-materials, if any
	local sub_count=getNumSubMtls orig_mtl
	if sub_count>1 then (
		for i=1 to sub_count do (
			setSubMtl orig_mtl i (createVRayMtl (getSubMtl orig_mtl i))
		)
	)

	-- get the material class id
	cls=classof orig_mtl
	
	-- if this is already a V-Ray compatible material, return the same one
	if (isVRayCompatible cls) then return orig_mtl

	-- otherwise, try to convert
	format "  %\n" orig_mtl
	local new_mtl=case cls of (
		StandardMaterial: convertFrom_Standard orig_mtl
		RaytraceMaterial: convertFrom_Raytrace orig_mtl
		Architectural: convertFrom_Architectural orig_mtl
		
		fR_Advanced: convertFrom_fR_Advanced orig_mtl
		fR_Metal: convertFrom_fR_Metal orig_mtl
		fR_Glass: convertFrom_fR_Glass orig_mtl
		
		Blend: convertFromBlend orig_mtl
		Shellac: convertFromShellac orig_mtl
		DoubleSided: convertFromDoubleSided orig_mtl
		
		default: orig_mtl
	)
	
	-- if converted, add to the list of converted materials
	if new_mtl!=orig_mtl then (
		append orig_mtls orig_mtl
		append new_mtls new_mtl
	)
	
	-- return the new material
	new_mtl
)

fn replaceMtlNode node = (
	if isValidNode node then (
		local m=createVRayMtl node.material
		node.material=m
		format "    %\n" node.name
	)
	for i=1 to node.children.count do (
		replaceMtlNode node.children[i]
	)
)

-- convert all scene materials to VRay materials
fn mtlsToVRay = (
	format "Converting scene materials...\n"
	orig_mtls=#()
	new_mtls=#()
	replaceMtlNode rootNode
	format "Converting Material Editor materials...\n"
	for i=1 to 24 do (
		local m=createVRayMtl meditmaterials[i]
		meditmaterials[i]=m
	)
	orig_mtls=#()
	new_mtls=#()
	format "Done\n"
)

fn shadowsNode node = (
	if (isValidNode node) then (
		scls=superclassof node
		if (scls==light) then (
			try (
				olds=node.shadowGenerator
				cls=classof olds
				if (cls!=shadowMap and cls!=VRayShadow) then (
					format "  %\n" node
					news=VRayShadow()
					node.shadowGenerator=news
				)
			)
			catch ()
		)
	)
	
	for i=1 to node.children.count do (
		shadowsNode node.children[i]
	)
)

-- convert all shadow types except shadow maps to VRay shadows
fn shadowsToVRay = (
	format "Converting shadows...\n"
	shadowsNode rootNode
	format "Done\n"
)

fn convertToVRay = (
	mtlsToVRay()
	shadowsToVRay()
)

fn registerMenuItems = (
	local quadMenu=menuMan.getViewportRightClickMenu #nonePressed
	local menu=quadMenu.getMenu 1
	
	-- register old menus
	if menuMan.registerMenuContext 0x763abd78 then (
		local vrayProperties=menuMan.createActionItem "VRayProperties" "VRay"
		menu.addItem vrayProperties -1

		local vrayConverter=menuMan.createActionItem "VRaySceneConverter" "VRay"
		menu.addItem vrayConverter -1
	)
	-- register new menus
	if menuMan.registerMenuContext 0x3f523d41 then (
		local vrayMeshExport=menuMan.createActionItem "VRayMeshExport" "VRay"
		menu.addItem vrayMeshExport -1
	)
	-- register newer menus
	if menuMan.registerMenuContext 0x45e60e47 then (
		local vrayShowVFB=menuMan.createActionItem "VRayShowVFB" "VRay"
		menu.addItem vrayShowVFB -1
	)
)

macroScript VRayProperties category:"VRay" buttontext:"V-Ray properties" tooltip:"Displays the VRay object or light properties" (
	doVRayObjectProperties()
)

macroScript VRaySceneConverter category:"VRay" buttontext:"V-Ray scene converter" tooltip:"Convert all scene materials to VRayMtl and all raytraced shadows to VRay shadows" (
	local res=queryBox "All scene materials and raytraced shadows will be converted to VRay materials and shadows. Are you sure?" title:"VRay scene converter"
	if res then convertToVRay()
)

macroScript VRayMeshExport category:"VRay" buttontext:"V-Ray mesh export" tooltip:"Exports the selected meshes to an external file" (
	doVRayMeshExport()
)

macroScript VRayShowVFB category:"VRay" buttontext:"V-Ray VFB" tooltip:"Displays the last rendered V-Ray VFB, if is exists" (
	r=renderers.current
	cls=r.classid
	if (cls[1]==1941615238 and cls[2]==2012806412) then r.showLastVFB()
)

fn setupVRayUI = (
	registerMenuItems()
)

setupVRayUI()