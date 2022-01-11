loadDefaultMatLib() 

fileIn (".\\LFS_MATERIAL.ms") quiet:true
--- FUNCTION SECTION
fn ReadBytes2String fs len =
(
	local str = ""
	local length = 0
	local finished = false
	
	for i = 1 to len do
	(
		local c = ReadByte fs #unsigned
		
		if c == 0 then finished = true
		
		if finished then continue	
		
		str += bit.intAsChar(c)		
		
		if c != 32 then length = i		
	)
	substring str 1 length
)

function WriteString2Byte fs text size = 
(
	local len=text.count
	
	if(len < size) then (
		writestring fs text
		fseek fs -1 #seek_cur
		
		for i=len to size-1 do
		(
			writebyte fs 0
		)
	) else (
		substring text 1 (size-1)
		writestring fs text
	)
)

function fillZero fs count =
(
	for i = 1 to count do
	(
		writebyte fs 0 #unsigned	
	)
)



--- END FUNCTION SECTION

--- SRE_STRUCT SECTION
struct Header
(
	Header,
	Version,
	
	fn Read fs = (
		Header = ReadBytes2String fs 7
		Version = readbyte fs #unsigned
	),
	
	fn Write fs = (
		WriteString2Byte fs Header 7
		writebyte fs Version
	)
)

struct ObjInfo
(
    Flag,
	Type,
	FlipState,
	LODsCount,
	Name,
	SubObjState,
	unk2,
	unk3,
	sp,
	
	fn Read fs = (
		Flag = readbyte fs #unsigned
		Type = readbyte fs #unsigned
		FlipState = readbyte fs #unsigned
		LODsCount = readbyte fs #unsigned
		Name = ReadBytes2String fs 20
		SubObjState = readbyte fs #unsigned
		unk2 = readbyte fs #unsigned
		unk3 = readbyte fs #unsigned
		sp = readbyte fs #unsigned
	),
	
	fn Write fs = (
		writebyte fs Flag
		writebyte fs Type
		writebyte fs FlipState
		writebyte fs LODsCount
		WriteString2Byte fs Name 20
		writebyte fs SubObjState
		writebyte fs unk2
		writebyte fs unk3
		writebyte fs sp
	
	)
)

struct LODInfo
(
	unk,
	LODdistance,
	
	fn Read fs = 
	(
		unk = readshort fs #unsigned
		LODdistance = readshort fs #unsigned
	),
	
	fn Write fs = (
		writeshort fs unk
		writeshort fs LODdistance
	)
)

struct GeometryInfo
(
	NumVertex,
	NumFaces,
	CountNotice,
	Rotate,
	Zero,
	Position,
	
	fn Read fs = (
		NumVertex = readshort fs #unsigned
		NumFaces = readshort fs #unsigned
		CountNotice = readlong fs
		local rX = (readshort fs)*360.0/65536.0
		local rY = (readshort fs)*360.0/65536.0
		local rZ = (readshort fs)*360.0/65536.0

		Rotate = eulerangles rX rY rZ

		Zero = readshort fs
		
		local X = (readlong fs) *1.0 / 65536.0
		local Y = (readlong fs) *1.0 / 65536.0
		local Z = (readlong fs) *1.0 / 65536.0
		
		Position = Point3 X Y Z
	),
	
	fn Write fs = (
		writeshort fs NumVertex #unsigned
		writeshort fs NumFaces  #unsigned
		writelong fs CountNotice
		
		writeshort fs (Rotate.x*65536/360 as integer)
		writeshort fs (Rotate.y*65536/360 as integer)
		writeshort fs (Rotate.z*65536/360 as integer)
		
		writeshort fs Zero
		
		writelong fs (Position.x*65536 as integer)
		writelong fs (Position.y*65536 as integer)
		writelong fs (Position.z*65536 as integer)
	)

)

struct Vertex
(
	Flag=0,
	Position,
	
	fn Read fs = 
	(
		Flag = readlong fs
		local X = (readlong fs) *1.0 / 65536.0
		local Y = (readlong fs) *1.0 / 65536.0
		local Z = (readlong fs) *1.0 / 65536.0
		
		Position = Point3 X Y Z
	),
	
	fn Write fs = (
		writelong fs Flag
		
		writelong fs (Position.x*65536 as integer)
		writelong fs (Position.y*65536 as integer)
		writelong fs (Position.z*65536 as integer)
	)
)

struct Face
(
	MirrorState=0,
	LayoutID=1,
	MapID=1,
	NCLevel=0,
	LodID=1,
	Smooth=0,
	Indexes,
	Inverted1=false,
	Inverted2=false,
	Inverted3=false,
	
	fn Read fs = 
	(
		MirrorState = (readbyte fs #unsigned)
		LayoutID = (readbyte fs #unsigned) + 1		
		MapID = (readbyte fs #unsigned) + 1
		
		NCLevel = (readbyte fs #unsigned) + 1
		LodID = (readbyte fs #unsigned) + 1
		Smooth = (readbyte fs #unsigned)

		local Ind1 = readshort fs
		local Ind2 = readshort fs
		local Ind3 = readshort fs
		
		if Ind1 < 0 then (
			Inverted1 = true
			Ind1 += 32768
		)
		
		if Ind2 < 0 then (
			Inverted2 = true
			Ind2 += 32768
		)
		
		if Ind3 < 0 then (
			Inverted3 = true
			Ind3 += 32768
		)
		
		Ind1 += 1
		Ind2 += 1
		Ind3 += 1
		Indexes = Point3 Ind1 Ind2 Ind3
	),
	
	fn Write fs = (
		writebyte fs MirrorState
		writebyte fs (LayoutID-1)
		writebyte fs (MapID-1)
		writebyte fs (NCLevel-1)
		writebyte fs (LodID-1)
		writebyte fs Smooth
		
		local Ind1 = (Indexes[1]-1)
		local Ind2 = (Indexes[2]-1)
		local Ind3 = (Indexes[3]-1)
		
		if(Inverted1==true) then (Ind1 -=32768)
		if(Inverted2==true) then (Ind2 -=32768)
		if(Inverted3==true) then (Ind3 -=32768)
	
		writeshort fs Ind1
		writeshort fs Ind2
		writeshort fs Ind3
	)
)

struct Page
(
	Type,
	Name,
	
	fn Read fs = (
		Type = readlong fs
		Name = ReadBytes2String fs 20
	),
	
	fn Write fs = (
		writelong fs Type
		WriteString2Byte fs Name 20
	)
)

struct CutOut
(
	Name,
	Rotate,
	Flag,
	PageId,
	AlphaType,
	EnvMapType,
	ShineType,
	ReflectionColor,
	Roughness,
	sizeX,
	sizeY,
	posX,
	posY,
	
	fn Read fs = (
		Name = ReadBytes2String fs 16
		Rotate = readbyte fs
		Flag = readbyte fs
		PageId = (readshort fs) +1
		AlphaType = readbyte fs
		EnvMapType = readbyte fs
		ShineType = readbyte fs
		
		readbyte fs -- spare
		
		ReflectionColor = color (readbyte fs #unsigned) (readbyte fs #unsigned) (readbyte fs #unsigned)
		
		Roughness = readbyte fs
		sizeX = readbyte fs
		sizeY = readbyte fs
		posX = readbyte fs
		posY = readbyte fs
	),
	
	fn Write fs = (
		WriteString2Byte fs Name 16
		writebyte fs Rotate
		writebyte fs Flag
		writeshort fs (PageId-1)
		writebyte fs AlphaType
		writebyte fs EnvMapType
		writebyte fs ShineType
		writebyte fs 0
		
		writebyte fs ReflectionColor.r
		writebyte fs ReflectionColor.g
		writebyte fs ReflectionColor.b
		
		writebyte fs Roughness
		writebyte fs sizeX
		writebyte fs sizeY
		writebyte fs posX
		writebyte fs posY
	)
)

struct Map
(
	-- 3dmax
	material,
	-- LFS
	Name,
	DiffuseColor,
	Flag,
	Rotate,
	Position,
	Width,
	Height,
	CutOutId,
	CutOutIdOpposite,
	
	fn Read fs = (
		Name = ReadBytes2String fs 16
		DiffuseColor = color (readbyte fs #unsigned) (readbyte fs #unsigned) (readbyte fs #unsigned)
		
		readbyte fs -- spare
	
		Flag = readlong fs
		Rotate = readlong fs #unsigned
		
		local rH = bit.and Rotate 2047
		if (rH > 720) then (rH -= 2048)
		
		local rP = bit.and (bit.shift Rotate -11) 2047
		if (rP > 360) then (rP -= 1024)
		
		local rR = bit.shift Rotate -21
		if (rR > 720) then (rR -= 2048)
				
		Rotate = Point3 (rH*1.0/4.0) (rP*1.0/4.0) (rR*1.0/4.0)
		
		local X = (readlong fs) *1.0 / 65536.0
		local Y = (readlong fs) *1.0 / 65536.0
		local Z = (readlong fs) *1.0 / 65536.0
		
		Position = Point3 X Y Z
		
		Width = (readlong fs) *1.0 / 65536.0
		Height = (readlong fs) *1.0 / 65536.0
		
		CutOutId = (readshort fs)+1
		CutOutIdOpposite = (readshort fs)+1
	),
	
	fn Write fs = (
		WriteString2Byte fs Name 16
		
		writebyte fs DiffuseColor.r
		writebyte fs DiffuseColor.g
		writebyte fs DiffuseColor.b
		writebyte fs 0
		
		writelong fs Flag
		local rH = (Rotate[1]*4 as integer)
		local rP = (Rotate[2]*4 as integer)
		local rR = (Rotate[3]*4 as integer)
		
		if (rH<0) then (rH+=2048)
		if (rP<0) then (rP+=1024)
		if (rR<0) then (rR+=2048)
		
		
		local r = bit.or rH (bit.shift rP 11)
		r = bit.or r (bit.shift rR 21)
		
		writelong fs r #unsigned
		
		writelong fs (Position.x*65536 as integer)
		writelong fs (Position.y*65536 as integer)
		writelong fs (Position.z*65536 as integer)
		
		writelong fs (Width*65536 as integer)
		writelong fs (Height*65536 as integer)
		
		writeshort fs (CutOutId-1)
		writeshort fs (CutOutIdOpposite-1)
	)
)

struct SreObject
(
	-- 3ds max section
	-- mesh
	object,
	multimat,
	-- LFS section
	Info,
	LODs = #(),
	
	Geometry,
	Vertexes = #(),
	Faces = #(),
	
	PagesCount,
	Pages = #(),
	
	CutOutsCount,
	CutOuts = #(),
	
	MapsCount,
	SomeVar,
	Maps = #(),
	
	fn Read fs = (
		--reset arrays
		Vertexes = #()
		Faces = #()
		Pages = #()
		CutOuts = #()
		Maps = #()
		
		-- start reading
		Info = ObjInfo()
		Info.Read fs
		
		for i=1 to Info.LODsCount do (
			local LOD = LODInfo()
			LOD.Read fs
			append LODs LOD
		)
		
		Geometry = GeometryInfo()
		Geometry.Read fs
		
		for i=1 to Geometry.NumVertex do (
			
			local v = Vertex()
			v.Read fs
			
			append Vertexes v
		)
		
		for i=1 to Geometry.NumFaces do (
			
			local f = Face()
			f.Read fs
			
			append Faces f
		)
		
		PagesCount = readlong fs
		
		for i=1 to PagesCount do (
			local p = Page()
			p.Read fs
			
			append Pages p
		)
		
		CutOutsCount = readlong fs
		
		for i=1 to CutOutsCount do (
			local c = CutOut()
			c.Read fs
			
			append CutOuts c
		)
		
		MapsCount = readshort fs #unsigned
		SomeVar = readshort fs
		
		for i=1 to MapsCount do (
			local m = Map()
			m.Read fs
			
			append Maps m
		)
	
	),
	
	fn Write fs = (
	
		Info.Write fs
		
		for i=1 to Info.LODsCount do (
			LODs[i].Write fs
		)
		
		Geometry.Write fs
		
		for i=1 to Geometry.NumVertex do (
			Vertexes[i].Write fs
		)
		
		for i=1 to Geometry.NumFaces do (
			Faces[i].Write fs
		)
		
		writelong fs PagesCount
		
		for i=1 to PagesCount do (
			Pages[i].Write fs
		)
		
		writelong fs  CutOutsCount
		
		for i=1 to CutOutsCount do (
			CutOuts[i].Write fs
		)
		
		writeshort fs MapsCount
		writeshort fs SomeVar
		
		for i=1 to MapsCount do (
			Maps[i].Write fs
		)
	
	),
	
	fn Sync = (
	
		Info.Name = object.name
		
		Geometry.NumVertex = object.numverts
		Geometry.NumFaces = object.numfaces
		
		tempVerts = #()
		
		for i=1 to object.numverts do (
			if ( Vertexes[i] != undefined) then (
				Vertexes[i].Position = object.verts[i].pos
				append tempVerts Vertexes[i]
			) else (
				vert = Vertex()
				vert.Position = object.verts[i].pos
				append tempVerts vert
			)
		)
		
		Vertexes = tempVerts
		
		tempFaces = #()
		
		for i=1 to object.numfaces do (
			if ( Faces[i] != undefined) then (
				f = Faces[i]
				f.Indexes = (getFace object i as Point3)
				f.MapID = (getFaceMatID object i)
				f.Smooth = (getFaceSmoothGroup object i)
				append tempFaces f
			) else (
				f = Face()
				f.MirrorState=0
				f.LayoutID=1
				f.MapID=1
				f.NCLevel=0
				f.LodID=1
				f.Indexes = (getFace object i as Point3)
				f.MapID = (getFaceMatID object i)
				f.Smooth = (getFaceSmoothGroup object i)
				append tempFaces f
			)
		)
		
		Faces = tempFaces

	)
	
)

--- END SRE_STRUCT SECTION

--- SRE_EDITOR SECTION
struct SRE_EDITOR
(
	sreHeader,
	Layouts = #(),
	SreObjects = #(),
	
	fn Load filename = (
	
		free Layouts
		free SreObjects
		
		print "Start read file"
		
		totalVobSize = GetFileSize filename
		
		local fs = fopen filename "rb"
		
		if fs == undefined then
		(
			print "Can't open file in binary mode"
			return SreObjects.count
		)
		
		sreHeader = Header()
		sreHeader.Read fs
		
		print sreHeader.Header
		
		local pos = 1
		do(
			sre = SreObject()
			sre.Read fs
			
			append SreObjects sre
		
			if (sre.Info.Type == 0) then (
			
				for i=1 to 16 do (
					local name = ReadBytes2String fs 8
					append Layouts name
				)
				
				local zero = ReadBytes2String fs 128 -- just spare to subobject
			)
			
			pos = ftell fs
		)
		while pos < totalVobSize
		
		fclose fs
		
		print "Finish read file"
		
		return SreObjects.count
	),
	
	fn BuildMeshes = (
		print "Start build meshes"
		for i=1 to SreObjects.count do (
		
			local sre = SreObjects[i]
			
			local name = sre.Info.Name
			
			if (name.count == 0) then ( name = "untitled_" + (i as string))
			
			sre.multimat = MultiMaterial()
			sre.multimat.name = name
			sre.multimat.numsubs = sre.MapsCount
			
			for j=1 to sre.MapsCount do (
				sre.multimat.names[j] = sre.Maps[j].Name
				sre.multimat[j] = LFS_MATERIAL()
				
				sre.multimat[j].showInViewport = true
				sre.multimat[j].name = sre.Maps[j].Name
				sre.multimat[j].color = sre.Maps[j].DiffuseColor
				
				sre.multimat[j].flag = sre.Maps[j].Flag
				sre.multimat[j].rotate_h = sre.Maps[j].Rotate[1]
				sre.multimat[j].rotate_p = sre.Maps[j].Rotate[2]
				sre.multimat[j].rotate_r = sre.Maps[j].Rotate[3]
				sre.multimat[j].x = sre.Maps[j].Position[1]
				sre.multimat[j].y = sre.Maps[j].Position[2]
				sre.multimat[j].z = sre.Maps[j].Position[3]
				
				sre.multimat[j].width = sre.Maps[j].Width
				sre.multimat[j].height = sre.Maps[j].Height
				
				sre.multimat[j].cutout = sre.Maps[j].CutOutId
				sre.multimat[j].cutout_op = sre.Maps[j].CutOutIdOpposite
				
				
				showTextureMap sre.multimat[j] true
			)
			
			if (i < 25) then (
				setMeditMaterial i sre.multimat
			)
			
			
		
			sre.object = mesh numverts:sre.Geometry.NumVertex numfaces:sre.Geometry.NumFaces

			
			
			for j=1 to sre.Geometry.NumVertex do (
				setVert sre.object j sre.Vertexes[j].Position
			)
			
			for j=1 to sre.Geometry.NumFaces do (
			
				setFace sre.object j sre.Faces[j].Indexes
			
				setFaceMatID sre.object j sre.Faces[j].MapID
				setFaceSmoothGroup sre.object j sre.Faces[j].Smooth
				
				setEdgeVis sre.object j 1 true
				setEdgeVis sre.object j 2 true
				setEdgeVis sre.object j 3 true
			)
			
			
			
			sre.object.name = name
			if(i == 1) then (
				sre.object.pos = sre.Geometry.Position
			) else (
				sre.object.pos = (sre.Geometry.Position + SreObjects[1].Geometry.Position)
			)
			
			sre.object.material = sre.multimat
			rotate sre.object sre.Geometry.Rotate
			update sre.object
		)
		print "Finish build meshes"
	),
	
	fn Sync = (
		
		print "Start update meshes"
		for i=1 to SreObjects.count do (
		
			local sre = SreObjects[i]
			
			sre.object.rotation = quat 0 0 0 0
			sre.object.pos = Point3 0 0 0
			
			sre.Sync()

			if(i == 1) then (
				sre.object.pos = sre.Geometry.Position
			) else (
				sre.object.pos = (sre.Geometry.Position + SreObjects[1].Geometry.Position)
			)
			
			--rotate sre.object sre.Geometry.Rotate
			update sre.object
		)
		print "Finish update meshes"
	
	),
	
	fn Save filename = (
	
		print "Start write file"
		local fs = fopen filename "wb"
		
		if fs == undefined then (
			return false
		)
		
		
		sreHeader.Write fs
		
		for i=1 to SreObjects.count do (
		
			
			SreObjects[i].Write fs
			
			if i==1 then (
				for j=1 to 16 do (
					WriteString2Byte fs Layouts[j] 8
				)
				
				fillZero fs 128
			)
		
		)
		
		fclose fs
		
		print "Finish write file"
		return true
	)
	
)
--- END SRE_EDITOR SECTION

try(destroydialog SreEditorDialog)catch()



rollout SreEditorDialog "Live For Speed Sre Editor" 
(
	local lfsdir = undefined
	

	local export = undefined
	
	group "Control" (
		button LFSEdirotRootDirButton "Select LFS Editor root dir" enabled:false
		button OpenFileButton "Open SRE File" enabled:true
		button SaveFileButton "Save SRE File" enabled:false
	)
	
	-- group "Info" ()
	
	group "Info" (
		label label_1 "(c) turbosnail 2015 - 2021"
	)
	
	
	on LFSEdirotRootDirButton pressed do 
	(
		lfsdir = getSavePath caption:"Select LFS Editor root dir" initialDir:"D:\games\games\LFS_EDITOR"
		
		if(lfsdir != undefined) then (
			OpenFileButton.enabled=true
		)
	)	
	
	on OpenFileButton pressed do 
	(
		local sreFileName = getOpenFilename \
		caption:"Select *.sre File" \
		types: "LFS Car Model(*.sre)|*.sre|All files (*.*)|*.*|"
		
		if(sreFileName == indefined) then (
			return false
		)
		
		resetMaxFile()
		clearlistener()
		

		
		local result = (EDITOR.Load sreFileName)

		if (result > 0) then (
			SaveFileButton.enabled=true
		)
		
		EDITOR.BuildMeshes()
	)
	
	on SaveFileButton pressed do
	(
		local sreFileName = getSaveFilename \
		caption:"Select *.sre File" \
		types: "LFS Car Model(*.sre)|*.sre|All files (*.*)|*.*|"
		
		if(sreFileName == indefined) then (
			return false
		)
		
		EDITOR.Sync()
		EDITOR.Save sreFileName
	)
	
	on SreEditorDialog open do (
		if(EDITOR == undefined) then (
				global EDITOR = SRE_EDITOR()
		)
		print EDITOR
		if (EDITOR.SreObjects.count > 0) then (SaveFileButton.enabled=true)
	)
	
)

createDialog SreEditorDialog -- 200 200
