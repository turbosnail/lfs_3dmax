plugin Material LFS_MATERIAL
    name:"LFS Material"
    classID:#(0x362e69e0, 0x2d2d864c)
	extends:Standard replaceUI:true version:2
(
	parameters main rollout:params 
	(
		color 				type:#color 		default:white 	ui:color 
		
		flag				type:#integer 	default:0	ui:flag
		rotate_h					type:#integer 	default:0	ui:rotate_h
		rotate_p					type:#integer 	default:0	ui:rotate_p
		rotate_r					type:#integer 	default:0	ui:rotate_r
		
		
		x					type:#float		default:0.0	ui:pos_x
		y					type:#float		default:0.0	ui:pos_y
		z					type:#float		default:0.0	ui:pos_z

		width				type:#float		default:0.0	ui:width
		height				type:#float		default:0.0	ui:height
		
		cutout				type:#integer 	default:1	ui:cutout
		cutout_op			type:#integer 	default:1	ui:cutout_op
		
		
		on color set val do delegate.diffuse_color = val
		
	)
	
		
	rollout params  "LFS Material Parameters" (
 				
		group "Main"(

 			colorpicker		color 		"Color" 			
			
			spinner			flag		"Flag"		type:#integer
		)
		
		group "Geometry" (
			label rotate	 "Rotation"
			spinner			rotate_h		"Heading" range:[-180.0,180.0,0.0] scale:0.25
			spinner			rotate_p		"Pitch" range:[-90.0,90.0,0.0] scale:0.25
			spinner			rotate_r		"Roll" range:[-180.0,180.0,0.0] scale:0.25
			label position	 "Position"
			spinner			pos_x		"X" range:[-65536.0,65536.0,0.0]
			spinner			pos_y		"Y" range:[-65536.0,65536.0,0.0]
			spinner			pos_z		"Z" range:[-65536.0,65536.0,0.0]
			label dimensions	 "Dimensions"
			spinner			width		"Width"
			spinner			height		"Height"
		)
		
		group "Cutouts"(
			spinner cutout "Cutout" type:#integer
			spinner cutout_op "Cutout Oposite" type:#integer
		)

		
		
		label info12 "" 
        label info13 "(c) turbosnail 2020 - 2021" align:#right
 	)
)
