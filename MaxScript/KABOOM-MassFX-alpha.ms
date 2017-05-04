--http://forums.cgsociety.org/showthread.php?t=995086
--to try:
--bomb center of blast dummy
--fragments direction target dummy
--to do:
--enbale/disable ground plane
--time scale

rollout KabooM2 ":: K a b o o M  MassFX::" width:200 
(

label l2 "KabooM MassFX v.alpha"
	label l3 ":::::::::::::"
Group ": 1 : RIGID BODIES" 
	(
button FrCol "Selection > Rigid Bodies" width:120 height:25 pos:[10,60]
button rstFrCol "Reset" width:40 height:25 pos:[132,60]
	)

	Group ": 2 : BOMB"(
spinner bombpw "Bomb power" type:#float range:[0,1000,6]
spinner bombrdpw "Random power" type:#float range:[0,1000,1]		
spinner spinpw "Spin power" type:#float range:[0,1000,0]		
spinner bombrg "Bomb range"	type:#integer range:[5,1000,15]
button selbmb "Select the Bomb"
	)	
		Group ": 3 : SIMULATION"(


spinner strtfrm "Start frame" type:#integer range:[0,1000,0]


button btn_Blast "!! K A B O O M !!" width:85 height:45 pos:[20,270]
button Resetsim "Stop Sim" width:70 height:45 pos:[110,270]			
button Resetkey "Reset Animation" width:160 height:35
	)
label l1 "KabooM v.alpha"
	
hyperlink hl ":::::::: L o R a n ::::::::" address:"http://loran-cg.blogspot.com/"  align:#center 
color:(color 50 150 255) 
hoverColor:(color 50 150 255) visitedColor:(color 50 150 255)

on KabooM2 open do
( 	
PhysXPanelInterface.instance.onLastFrame = 2 --stop simulation on last frame

	
if  isValidNode $'kaboom-BOMB' then bombrg.value = $'kaboom-BOMB'.max.y

	else
(

--BOMB GIZMO CREATION--	
c1=circle radius:bombrg.value
c2=circle radius:bombrg.value
c2.rotation = eulerangles 90 0 0
c3=circle radius:bombrg.value
c3.rotation = eulerangles 0 90 0
c4=circle radius:bombrg.value
converttosplineshape c1
converttosplineshape c2
converttosplineshape c3
converttosplineshape c4
addAndWeld c1  c2 0
addAndWeld c1  c3 0
addAndWeld c1  c4 0
c1.name="kaboom-BOMB"
c1.wireColor = [50,150,255] 
)
)


on selbmb pressed do (select $'kaboom-BOMB')

on spinpw changed val do 
(for o in selectionSets[#Kb_Frags]  do
	(
o.modifiers[#MassFX_Rigid_Body].spinSpeed	= spinpw.value
	)
)


-- on bombpw changed val do 
-- (for o in selectionSets[#Kb_Frags]  do
-- 	(
-- o.modifiers[#MassFX_Rigid_Body].velocitySpeed= bombpw.value
-- 	)
-- )

on bombrg changed val do 
(
	--$'kaboom-BOMB'.modifiers[#MassFX_Rigid_Body].meshRadius = bombrg.value
	scl=(bombrg.value*6.666)/100
	$'kaboom-BOMB'.scale = [scl,scl,scl]	
)--$BombGizmo.radius = bombrg.value

on groundbt changed theState do
(
if theState == true then
( 	MassFX_GroundPlane = true)	
else
( 	MassFX_GroundPlane = false)
)


--FRAGMENTS--
on FrCol pressed do 
	(
		mysel = for node in $ where iskindof node GeometryClass collect node
		NamedSelectionSetManager.RemoveNamedSelSetByName  "Kb_Frags"
		NamedSelectionSetManager.AddNewNamedSelSet mysel "Kb_Frags" 
		mysel.wireColor = [(random 0 255),(random 0 255),255] 
		
for o in mysel do(
		addModifier o (MassFX_RBody()) 
		o.modifiers[#MassFX_Rigid_Body].type = 2
		)	
			
	clearSelection()
	)


on rstFrCol pressed do 
	(
	if selectionSets["Kb_Frags"] == undefined then messagebox "Nothing to reset" else
		(
		for i in  selectionSets["Kb_Frags"] do
				(
					(
					deletemodifier i i.modifiers[#MassFX_Rigid_Body]
				--	try (deletemodifier i i.modifiers[#MassFX_Rigid_Body]) catch()
					i.wireColor = [(random 0 255),(random 0 255),255] 
					)
				)
			NamedSelectionSetManager.RemoveNamedSelSetByName  "Kb_Frags"
		)
	)
	
	
	on btn_Blast pressed do
	(

				 
		for o in selectionSets["Kb_Frags"] do
		(
			
			randy = (random -10 10)
			randpow = (random 0 bombrdpw.value)
			p0 = $'kaboom-BOMB'.position
			p1 = o.position
			dif = p1-p0
			len = Length(dif) --vector lenght
			vec = dif / len--vector direction
			rang = bombrg.value
			spd = (rang-len)*bombpw.value
			if spd<0 then spd = 0	
			--print len
			--print rang			
			if len > rang then 
			(
			o.modifiers[#MassFX_Rigid_Body].type = 2 --all objects to kinematic
			o.wireColor = [88,144,255] 
			)
			else
			(
				o.modifiers[#MassFX_Rigid_Body].switchType = true --must have
				o.modifiers[#MassFX_Rigid_Body].switchTypeAtFrame = strtfrm.value
				--o.modifiers[#MassFX_Rigid_Body].type = 1 --all objects to dynamic
				o.modifiers[#MassFX_Rigid_Body].InitialVelocityX =vec.x
				o.modifiers[#MassFX_Rigid_Body].InitialVelocityY =vec.y
				o.modifiers[#MassFX_Rigid_Body].InitialVelocityZ =vec.z
				o.modifiers[#MassFX_Rigid_Body].velocitySpeed= spd*randpow

				o.modifiers[#MassFX_Rigid_Body].InitialSpinX = randy
				o.modifiers[#MassFX_Rigid_Body].InitialSpinY = randy
				o.modifiers[#MassFX_Rigid_Body].InitialSpinZ = randy
				o.modifiers[#MassFX_Rigid_Body].spinSpeed = spinpw.value
				o.wireColor = [47,115,255] 
				addnewkey o.pos.controller (strtfrm.value)
				addnewkey o.rotation.controller (strtfrm.value)
/* 				at time (strtfrm.value-1) -- create keyframe 1
* 					(
* 					o.position = o.position
* 					o.rotation = o.rotation
* 					)
*/
			)
		)
	set animate on
	macros.run "PhysX" "PxPlaySimMS"
	)
	
	on Resetsim pressed do
	(
		
	macros.run "PhysX" "PxResetSimMS"
		set animate off
			
		for o in selectionSets["Kb_Frags"] do
				(
			o.modifiers[#MassFX_Rigid_Body].type = 2 --all objects to kinematic
			o.modifiers[#MassFX_Rigid_Body].switchType = false --must have
			o.wireColor = [88,144,255] 


				)

	
playAnimation()
	)
	
	on Resetkey pressed do
	(sliderTime = 0f
		for o in selectionSets["Kb_Frags"] do
		(
	selectKeys o.pos.controller 0 10000
	deleteKeys o.pos.controller #selection 
	selectKeys o.rotation.controller 0 10000
	deleteKeys o.rotation.controller #selection
	selectKeys o.scale.controller 0 10000
	deleteKeys o.scale.controller #selection
		)
stopAnimation()	
		
	)
	

	
	
---------------------------------------
)
createDialog KabooM2 