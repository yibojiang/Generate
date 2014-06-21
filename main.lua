
math.tau = math.pi * 2



realTimer=0
dayTimer=0
day=0
cycle=0

dayTime=60
cycleDay=10

dtFactor=1

brightness=0

showDebug=false

bgHSBColor={h=0,s=0,b=0,a=1}

particle={}
particle[1]=love.graphics.newImage("images/particle.png")
particle[2]=love.graphics.newImage("images/circle.png")
particle[3]=love.graphics.newImage("images/point.png")

glow=love.graphics.newImage("images/glow-light.png")

music = {
	noise = love.audio.newSource("sounds/melody.mp3", "stream")
}
music.noise:setLooping(true)
music.noise:setVolume(0.15)
music.noise:play()

sound={
	note={}
}

sound.note[1]=love.audio.newSource("sounds/note1.mp3", "static")
sound.note[2]=love.audio.newSource("sounds/note2.mp3", "static")
sound.note[3]=love.audio.newSource("sounds/note3.mp3", "static")
sound.note[4]=love.audio.newSource("sounds/note4.mp3", "static")
sound.note[5]=love.audio.newSource("sounds/note5.mp3", "static")
sound.note[6]=love.audio.newSource("sounds/note6.mp3", "static")


curEnemyIndex=1

function love.load()
	math.randomseed(os.time())
	math.random()
	math.random()
	math.random()  
    
	
	love.graphics.setBackgroundColor( 0, 0, 0 )
	require("modules.math")
	require("modules.HSBColor")
	require("modules.camera")
	require("modules.vector2")
	require("modules.explosion")
	require("modules.light")
	require("modules.stimulation")
	require("modules.food")
	require("modules.player")
	require("modules.enemy")
	require("modules.signal")
	
	--balls.initMetaball()
	
	
	current=1

	selection={}

	speciesType={value={"algae","grazer"},current=1,step=1}
	table.insert(selection,speciesType)

	editGene={}
	updateEditGene()
	
	
	windowsWidth = love.graphics.getWidth()
	windowsHeight = love.graphics.getHeight()
	
	width=1200
	height=900
	

	camera:setBounds(0, 0, width-windowsWidth, height-windowsHeight)
	camera.x=1
	camera.y=1

	text = ""
	
	cmd={text="",enable=false}

	light.init()
	
end

function gameStart()
	player.init()
	enemy.init()
	food.init()
	stimulation.init()
	
	camera:setTarget(enemies[curEnemyIndex])
end


function love.update(dt)
	--balls.update(dt)
	
	
	dt=dt*dtFactor
	
	light.update(dt)
	food.update(dt)
	stimulation.update(dt)
	enemy.update(dt)
	signal.update(dt)
	
	realTimer=realTimer+dt
	dayTimer=realTimer%dayTime
	day=math.floor(realTimer/dayTime)
	cycle=math.floor(day/cycleDay)
	

	--player.update(dt)
	
	
	--[[
	local r, g, b, a =love.graphics.getBackgroundColor()
	]]
	
	if	enemies[curEnemyIndex]~=nil then
		--bgHSBColor.h=1-enemies[curEnemyIndex].HSBColor.h
		--bgHSBColor.s=1-enemies[curEnemyIndex].HSBColor.s
		
		--r=r+ (255- enemies[curEnemyIndex].color.r-r)*dt
		--g=g+ (255- enemies[curEnemyIndex].color.g-g)*dt
		--b=b+ (255- enemies[curEnemyIndex].color.b-b)*dt
	else
		--findNextEnemy()
		camera:setTarget(nil)
	end
	
	bgHSBColor.h=0.6
	bgHSBColor.s=1
	--bgHSBColor.b=brightness
	bgHSBColor.b=1
	--local bc=HSBColor.getNearColor(bgHSBColor,120)
	local bc=HSBColor.toColor(bgHSBColor)
	
	love.graphics.setBackgroundColor(bc.r,bc.g,bc.b,bc.a)
	
	camera:update(dt)

	brightness=math.sin(dayTimer/dayTime*math.pi*2)+0.5
	brightness=math.clamp(brightness,0,1)
end


pacwidth = math.pi / 6 -- size of his mouth


function love.draw()
	
	--love.graphics.setBlendMode("additive")
	--love.graphics.setBlendMode("alpha")
	--love.graphics.setBlendMode("multiplicative")
	--love.graphics.setBlendMode("subtractive")
	--love.graphics.setBlendMode("premultiplied")
	
	--love.graphics.setColor( 255, 255, 0 ) -- pacman needs to be yellow
	--love.graphics.arc( "fill", 400, 300, 100, pacwidth, (math.pi * 2) - pacwidth )


	love.graphics.setBlendMode("multiplicative")
	love.graphics.setColor(0,0,0,(1-brightness)*250)
	love.graphics.rectangle("fill", 0, 0,windowsWidth,windowsHeight)
	
	camera:set()
	
	light.draw()
	love.graphics.setBlendMode("alpha")
	enemy.draw()
	food.draw()
	stimulation.draw()
	signal.draw()
	
	--love.graphics.setColor(255,255,255,255*brightness)
    love.graphics.setColor(255,255,255,255)
	love.graphics.setBlendMode("additive")
	--love.graphics.draw(glow, 30, 30,0,10,10)
	
	camera:unset()

	--love.graphics.setPixelEffect()


	--love.graphics.setColor(0,0,0,(1-brightness)*200)
	--love.graphics.setBlendMode("alpha")
	--love.graphics.rectangle("fill", 0, 0,windowsWidth,windowsHeight)
	
	


	love.graphics.setColor(255,255,255,255)
	love.graphics.setBlendMode("alpha")
	--love.graphics.print("by yibojiang", windowsWidth-100, windowsHeight-60)
	
	if not showDebug then
		return
	end
	
	love.graphics.setColor(0,255,0,255)
	love.graphics.print("FPS: "..love.timer.getFPS(), 10, 20)
	
	if cmd.enable then
		love.graphics.print( "Cmd: "..cmd.text, 10, 400 )
	end
	
	current=math.clamp(current,1,#selection)


	love.graphics.print( "type: "..speciesType.value[speciesType.current], 800, 360 )
	
	local j=1
	for i,v in pairs(editGene) do
		love.graphics.print( i..": "..v, 800, j*20+360)
		j=j+1
	end
	
	
	love.graphics.print("cycle: "..cycle, 10, 40)
	love.graphics.print("day: "..day, 10, 60)
	love.graphics.print("timer: "..dayTimer, 10, 80)
	love.graphics.print("bightness: "..brightness, 10, 100)
	
	
	love.graphics.print("Num: "..aliveNum.."/"..#enemies, 10, 120)
	love.graphics.print("food: "..foodAlive.."/"..#foodArray, 10, 140)
	love.graphics.print("stimulation: "..#stimulationArray, 10, 160)
	
	love.graphics.print(""..dtFactor, windowsWidth-40, windowsHeight-40)
	
	if	enemies[curEnemyIndex]~=nil then
		caculateAverage()

	
		local i=0
		for _i,_v in pairs(enemies[curEnemyIndex].gene) do
			love.graphics.print(_i..": ".._v, 500, i*20+20)
			i=i+1
		end

		love.graphics.print("breedAge: "..enemies[curEnemyIndex].breedAge,800, i*20+20)
		i=i+1
		love.graphics.print("mating: "..(enemies[curEnemyIndex].isMating and "yes" or "no"),800, i*20+20)
		i=i+1
		love.graphics.print("attacking: "..(enemies[curEnemyIndex].isAttacking and "yes" or "no"),800, i*20+20)
		i=i+1
		love.graphics.print("left: "..enemies[curEnemyIndex].leftLoop, 800, i*20+20)
		i=i+1
		love.graphics.print("right: "..enemies[curEnemyIndex].rightLoop, 800, i*20+20)
		i=i+1
		love.graphics.print("energy: "..enemies[curEnemyIndex].energy.."/"..enemies[curEnemyIndex].greed, 800,  i*20+20)
	end

	--love.graphics.print("isPlayer: "..enemies[curEnemyIndex].isPlayer, 10, 140)
	
	--if dayTimer<5 or dayTimer>30-5 then
	
	--updateLight(brightness)
	--end
end

function caculateAverage()
	gene={}
	for _i,_v in pairs(enemies[curEnemyIndex].gene) do 
		gene[_i]=0
	end
	
	for _i,_e in pairs(enemies) do
		if _e.alive then
			for _j,_v in pairs(_e.gene) do 
				gene[_j]=gene[_j]+_v
			end
		end
	end
	
	local i=0
	for _i,_v in pairs(gene) do
		love.graphics.print(_i..": ".._v/aliveNum, 10, i*20+300)
		i=i+1
	end
end

function updateLight(amount)

	for i,e in pairs(enemies) do
		local HSBC=e.HSBColor
		HSBC.b=amount
		--HSBC.b=math.clamp(0,1)
		enemy.setHSBColor(e,HSBC)
	end

end

function findNextEnemy()
	if aliveNum==0 then
		camera:setTarget(nil)
		return
	end
	
	local count=0
	curEnemyIndex=curEnemyIndex+1
	while enemies[curEnemyIndex]==nil do
		count=count+1
		if count>#enemies*2 then
			return
		end
		
		if curEnemyIndex>#enemies then
			curEnemyIndex=1
		else
			curEnemyIndex=curEnemyIndex+1
		end
		
		
	end
	camera:setTarget(enemies[curEnemyIndex])
end

function updateEditGene()
	selection[current].current=math.clamp(selection[current].current,1,#selection[current].value)
	if speciesType.value[speciesType.current]=="grazer" then
		editGene=enemy.randomGene()
	elseif speciesType.value[speciesType.current]=="algae" then
		editGene=food.randomGene()
	end
end

function love.mousepressed(x, y, button)
	if button == "wu" then
		current = current + 1;
	end

	if button == "wd" then
		current = current - 1;
	end
	
	if button == "l" then
		selection[current].current=1
		updateEditGene()
		
		local f=food.new(editGene)
		f.x=(x+camera._x)*camera.scaleX
		f.y=(y+camera._y)*camera.scaleY
		table.insert(foodArray,f)
		--[[
		if speciesType.value[speciesType.current]=="grazer" then
			local e=enemy.new(editGene)
			e.x=(x+camera._x)*camera.scaleX
			e.y=(y+camera._y)*camera.scaleY
			e.ps:setPosition(e.x , e.y )
			table.insert(enemies,e)
		elseif speciesType.value[speciesType.current]=="algae" then
			local f=food.new(editGene)
			f.x=(x+camera._x)*camera.scaleX
			f.y=(y+camera._y)*camera.scaleY
			table.insert(foodArray,f)
		end
		]]
	end
	
	if button == "r" then
		selection[current].current=2
		updateEditGene()
		
		local e=enemy.new(editGene)
		e.x=(x+camera._x)*camera.scaleX
		e.y=(y+camera._y)*camera.scaleY
		e.ps:setPosition(e.x , e.y )
		table.insert(enemies,e)
		
	end
end


function love.keypressed( key, unicode )
	if key=="q" then
		dtFactor=dtFactor+0.5
	end
	
	if key=="s" then
		
		if enemies[curEnemyIndex] then
			local sc={r=255,g=255,b=255,a=128}
			enemy.sendSignal(enemies[curEnemyIndex],sc)
		end
	end
	
	if key=="d" then
		showDebug=not showDebug
	end
	
	if key=="w" then
		dtFactor=1
	end
	
	if key=="e" then
		dtFactor=dtFactor-0.5
	end
	
	if key=="p" then
		if enemies[curEnemyIndex] then
			enemies[curEnemyIndex].isPlayer=not enemies[curEnemyIndex].isPlayer
		end
	end
	
	
	if key=="tab" then
		if enemies[curEnemyIndex] then
			enemies[curEnemyIndex].isPlayer=false
		end

		findNextEnemy()		
	end
	
	--[[
	if key == "1" then
		selection[current].current=1
		updateEditGene()
	end
	
	if key == "2" then
		selection[current].current=2
		updateEditGene()
	end
	]]
	

	if key=="o" then
		camera.target=nil
		camera:setPosition(0,0)
		camera:setScale(width/windowsWidth, height/windowsHeight)
		camera:setBounds(0, 0, width/camera.scaleX-windowsWidth, height/camera.scaleY-windowsHeight)
	end
	
	if key=="i" then
		camera:setTarget(enemies[curEnemyIndex])
		camera:setScale(1, 1)
		camera:setBounds(0, 0, width-windowsWidth, height-windowsHeight)
	end
end

function love.keyreleased( key, unicode )

end

function love.quit()
	if networkOn then
		local dg = string.format("%s %s $", entity, 'leave')
		udp:send(dg)
	end
end



