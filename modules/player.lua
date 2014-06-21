player={}

function player.init()
	player.size=10
	player.x=width/2-player.size/2
	player.y=height/2-player.size/2+200
	

	player.ax=0
	player.ay=0
	player.vx=0
	player.vy=-1
	
	player.gene={}
	player.gene.angularVelocity=4.8
	player.gene.viewRange=180
	player.gene.viewDistance=100
	player.gene.hue=math.random()
	
	
	player.viewRange=180
	player.viewDistance=player.gene.viewDistance
	player.angle=0
	player.minAngle=player.angle-player.gene.viewRange/2
	player.maxAngle=player.angle+player.gene.viewRange/2
	
	player.energy=0.8
	player.speed=player.energy*5/player.gene.angularVelocity
	
	
	
	ps = love.graphics.newParticleSystem(particle, 2000)
	ps:setParticleLife(player.energy/2, player.energy)
	ps:setSizes(1, 3)

	ps:setColors(120,120, 120, 150, 120, 120, 120, 0)
	--ps:setSpeed(2,4)
	--ps:setSpread(math.tau)
	--ps:setEmissionRate(200)
	ps:setEmissionRate(200)
	--ps:setRadialAcceleration(-2000)
	--ps:setTangentialAcceleration(1000)

	ps:start()
	player.smoke=ps

	player.HSBColor={h=player.gene.hue,s=0,b=1,a=1}

	player.setHSBColor(	player.HSBColor)
	--player.color={r=120,g=120,b=120,a=150}

	player.leftRad=0
	player.chargedTimer=0

	player.rightRad=0
	player.leftLoop=0
	player.rightLoop=0
	
end

function player.setColor(C)
	player.color=C
	player.HSBColor=HSBColor.fromColor(C)
	
	local tc=HSBColor.getNearColor(player.HSBColor,60)
	
	player.smoke:setColors(player.color.r,player.color.g, player.color.b, player.color.a, tc.r, tc.g, tc.b, 0)
end

function player.setHSBColor(HSBC)
	player.color=HSBColor.toColor(HSBC)
	player.HSBColor=HSBC
	
	local tc=HSBColor.getNearColor(player.HSBColor,60)
	player.smoke:setColors(player.color.r,player.color.g, player.color.b, player.color.a, tc.r, tc.g, tc.b, 0)
end

function player.updateEnergy()
	local HSBC=player.HSBColor
	HSBC.s=player.energy/2
	player.setHSBColor(HSBC)
end



function player.update(dt)
	player.x=math.clamp(player.x, 0, width)
	player.y=math.clamp(player.y, 0, height)


	player.vx,player.vy=vector2.normalized(player.vx,player.vy, player.speed)
	player.angle=math.getAngle(0,0,player.vx,player.vy)
	
	
	if love.keyboard.isDown("return")  then
		player.ax,player.ay=vector2.rotate(player.vx,player.vy,-math.pi/2)
		player.rightRad=0
		player.leftRad=player.leftRad+0.08
		
		player.rightLoop=0
		if player.leftRad>2*math.pi then 
			player.leftLoop=player.leftLoop+1
			player.leftRad= player.leftRad-2*math.pi
		end
		player.chargedTimer=player.chargedTimer+dt
		
	else
		player.ax,player.ay=vector2.rotate(player.vx,player.vy,math.pi/2)
		player.leftRad=0
		player.rightRad=player.rightRad+0.08
		
		player.leftLoop=0
		if player.rightRad>2*math.pi then 
			player.rightLoop=player.rightLoop+1
			player.rightRad= player.rightRad-2*math.pi
		end
		player.chargedTimer=0
	end
	--text=player.leftLoop..', '..player.rightLoop

	player.ax,player.ay=vector2.normalized(player.ax,player.ay, player.speed*player.gene.angularVelocity)
	
	
	
	
	player.vx=player.vx+player.ax
	player.vy=player.vy+player.ay
	
	
	player.x=player.x+player.vx*dt
	player.y=player.y+player.vy*dt
end

function player.draw()
	love.graphics.setColor(player.color.r,player.color.g,player.color.b, (math.pingPong(realTimer*0.5,0.5)+0.5)*255)
	love.graphics.circle( "fill",player.x,player.y, player.size )
	love.graphics.draw(player.smoke)
	
end

function player.levelup(amount)	
	player.energy=player.energy+0.1*amount
	player.energy=math.clamp(player.energy,0.8,2)
	player.speed=player.energy*5/player.gene.angularVelocity
	player.updateEnergy()
	if networkOn then
		world[entity].smoke:setParticleLife(player.energy/2, player.energy)
		local dg = string.format("%s %s %d %d %d %d %f", entity, 'state', player.color.r,player.color.g,player.color.b,player.color.a, player.energy)
		udp:send(dg)
	else
		player.smoke:setParticleLife(player.energy/2, player.energy)
	end
	
	
end


function player.collide()
	--text=text.."hit!"
	player.levelup(2)
end
