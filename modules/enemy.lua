enemy={}

enemies={}
local enemyNum=10

local spawnTimer=5
local matingTime=1.5
aliveNum=0



function enemy.randomGene()
	local gene={}
	gene.angularVelocity=4.8
	gene.viewRange=math.random(180,270)

	gene.viewDistance=math.random(100,200)

	
	gene.hue=math.random()
	gene.endurance=math.random(120,200)
	gene.power=math.random()+1
	gene.greed=math.random()*0.5+0.5
	gene.lifeTime=math.random(9,13)
	gene.aggressiveness=math.random()
	gene.appearance=math.random(1,3)
	
	--gene.waveLength=math.random(300,400)
	return gene
end

function enemy.new(gene)
	local e
	e={}
	
	e.gene=gene
	
	e.id=math.random(0,10000)
	e.birthday=day
	e.breedAge=math.floor(e.gene.lifeTime*0.4)
	--e.breedAge=20
	e.age=day-e.birthday
	e.maxEnergy=e.gene.power*math.abs(math.sin(e.age/cycleDay*math.pi))+1
	e.greed=e.maxEnergy*e.gene.greed
	
	e.boidsStage=0
	
	e.mates={}
	
	e.x=math.random(20,width-20)
	e.y=math.random(20,height-20)
	e.size=10
	
	e.vx=math.random()-0.5
	e.vy=math.random()-0.5
	e.ax=math.random()-0.5
	e.ay=math.random()-0.5
	e.leftRad=0
	e.rightRad=0
	e.leftLoop=0
	e.rightLoop=0
	
	
	
	
	e.endurance=e.gene.endurance
	e.alive=true
	e.target=nil
	e.isPlayer=false
	e.isMating=false
	e.isChasing=false
	e.isAttacking=false
	
	e.viewRange=e.gene.viewRange
	e.viewDistance=e.gene.viewDistance
	e.angle=0
	
	e.minAngle=e.angle-e.viewRange/2
	e.maxAngle=e.angle+e.viewRange/2
	
	
	
	e.energy=0.6
	--e.energy=3--todo
	e.speed=e.energy*300/e.gene.angularVelocity

	e.ps=love.graphics.newParticleSystem(particle[gene.appearance], 2000)	
	if gene.appearance==1 then
		e.ps:setEmissionRate(130)
	elseif gene.appearance==2 then
		e.ps:setEmissionRate(10)
	elseif gene.appearance==3 then
		e.ps:setEmissionRate(130)
	end
	
	e.ps:setParticleLifetime(e.energy/2, e.energy)


	e.ps:setSizes(1, 3)
	
	e.ps:start()
	e.ps:setPosition(e.x , e.y )
	
	e.HSBColor={h=e.gene.hue,s=0,b=1,a=1}
	enemy.setHSBColor(e,e.HSBColor)
	--e.explosion=explosion:new(e.color)
	e.ps:setPosition(e.x , e.y )

	return e
end




function enemy.levelup(e,amount)
	e.energy=e.energy+0.1*amount
	
	
	--e.speed=math.clamp(e.speed,4,30)

	enemy.updateEnergy(e)
	
	--text=e.speed
end

function enemy.collide(e)
	enemy.levelup(e,1)
end

function enemy.init()
	local i
	for i=1,enemyNum do
		enemies[i]=enemy.new(enemy.randomGene())
	
	end
	
end


function enemy.setColor(e,C)
	e.color=C
	e.HSBColor=HSBColor.fromColor(C)
	
	local tc=HSBColor.getNearColor(e.HSBColor,60)
	e.ps:setColors(e.color.r,e.color.g, e.color.b, e.color.a, tc.r, tc.g, tc.b, 0)
end

function enemy.setHSBColor(e,HSBC)
	e.color=HSBColor.toColor(HSBC)
	e.HSBColor=HSBC
	
	local tc=HSBColor.getNearColor(e.HSBColor,60)
	e.ps:setColors(e.color.r,e.color.g, e.color.b, e.color.a, tc.r, tc.g, tc.b, 0)
end

function enemy.updateEnergy(e)
	e.energy=math.clamp(e.energy,0,e.maxEnergy)
	e.speed=e.energy*300/e.gene.angularVelocity
	local HSBC=e.HSBColor
	HSBC.s=e.energy/2
	enemy.setHSBColor(e,HSBC)
	e.ps:setParticleLifetime(e.energy/2, e.energy)
end

function enemy.growUp(e)
	e.age=day-e.birthday
	
	if e.age>e.gene.lifeTime then
		enemy.die(e)
		return
	end
	
	e.maxEnergy=e.gene.power*math.abs(math.sin(e.age/cycleDay*math.pi))+1
	e.greed=e.maxEnergy*e.gene.greed
	enemy.updateEnergy(e)
end

function enemy.die(e)
	e.alive=false
	e.ps:stop()
	--e.ps=nil
	stimulation.generate(e.x,e.y,e.energy)
	e=nil
end


function enemy.turnLeft(e,dt)
	e.rightRad=0
	e.rightLoop=0	
	e.leftRad=e.leftRad+e.gene.angularVelocity/2*dt
	e.ax,e.ay=vector2.rotate(e.vx,e.vy,-math.pi/2)
	
	if e.leftRad>2*math.pi then
		e.leftRad=0
		e.leftLoop=e.leftLoop+1
		
		if e.isMating then
			local tempsignal={r=0,g=255,b=0,a=128}
			enemy.sendSignal(e,tempsignal)
		end
	end
end

function enemy.mate(e,dt)
	e.target=nil
	e.HSBColor.h=e.gene.hue
	e.isAttacking=false
	if e.isMating~=true then
		--search for others
		for i,v in pairs(enemies) do
			if v.isMating and v.alive and v.id~=e.id then
				--if v.energy>=e.greed then
					text="chasing"
					e.isChasing=true
					e.target=v
					
					return
				--end
			
			end
		end
		
	end
	--text=e.id..": self"
	--if no others then mate
	enemy.turnLeft(e,dt)
end

function enemy.checkMate(e,dt)
	for i,v in pairs(enemies) do
		if v.alive and v.id~=e.id then
			if e.x >= v.x-v.size and e.x <= v.x + v.size
			and  e.y >= v.y-v.size and e.y  <= v.y + v.size 
			then
				if e.mates[v.id] then
					e.mates[v.id]=e.mates[v.id]+dt
					--text="timer: "..e.mates[v.id]
				else
					e.mates[v.id]=0
				end
				
				if e.mates[v.id]>matingTime then
					enemy.generate(e,v)
				end
			end
		end
		
	end
end

function enemy.checkAttack(e,dt)
	for i,v in pairs(enemies) do
		if v.alive and v.id~=e.id then
			if e.x >= v.x-v.size and e.x <= v.x + v.size
			and  e.y >= v.y-v.size and e.y  <= v.y + v.size 
			then
				if e.energy>v.energy then
					enemy.die(v)
					e.energy=e.energy+v.energy
				else
					if v.isAttacking then
						enemy.die(e)
						v.energy=v.energy+e.energy
					end
				end
				
			end
		end
		
	end
end

function enemy.generate(e,v)
	genes={}

	for i=1,4 do
		genes[i]={}
	end
	
	for j,g in pairs(genes) do
		for i1,g1 in pairs(e.gene) do
			local select=math.random(1,2)
			
			if select>1 then
				g[i1]=e.gene[i1]
			else
				g[i1]=v.gene[i1]
			end
		end
		
		local newEnemy=enemy.new(g)
		newEnemy.x=e.x
		newEnemy.y=e.y
		table.insert(enemies,newEnemy)
	end


	
	enemy.die(e)
	enemy.die(v)
	
	--enemies[i]=enemy.new(enemy.randomGene())
	
end

function enemy.turnRight(e,dt)
	e.leftRad=0
	e.leftLoop=0
	e.rightRad=e.rightRad+e.gene.angularVelocity/2*dt
	e.ax,e.ay=vector2.rotate(e.vx,e.vy,math.pi/2)
	
	if e.rightRad>2*math.pi then
		e.rightRad=0
		e.rightLoop=e.rightLoop+1
	end
end

function enemy.wander(e,dt)
	e.HSBColor.h=e.gene.hue
	e.isAttacking=false
	local group={}
	--local color={r=255,g=0,b=0,a=255}
	for i,v in pairs(enemies) do
		if v.alive and v.id~=e.id then
			local angleToEnemy=math.getAngle(e.x,e.y,v.x,v.y)
			if (e.minAngle<e.maxAngle and angleToEnemy>e.minAngle and angleToEnemy<e.maxAngle) or (e.minAngle>e.maxAngle and not(angleToEnemy<e.minAngle and angleToEnemy>e.maxAngle) ) then

				local distanceToEnemy=vector2.distanceSqr(e.x,e.y,v.x,v.y)

				if  distanceToEnemy<math.pow(e.viewDistance,2) then
					table.insert(group,v)
					--[[
					if e.id==enemies[curEnemyIndex].id then
						color={r=255,g=0,b=0,a=255}
						enemy.setColor(v,color)
					end
					]]
				else
					--[[
					if e.id==enemies[curEnemyIndex].id then
						color={r=0,g=255,b=0,a=255}
						enemy.setColor(v,color)
					end
					]]
				end
				
			else
				--[[
				if e.id==enemies[curEnemyIndex].id then
					color={r=0,g=255,b=0,a=255}
					enemy.setColor(v,color)
				end
				]]
			end
		end
	end
	if #group>0 then
		if e.boidsStage==0 then
			local force={x=0,y=0}
			for i,v in pairs(group) do
				local f={x=e.x-v.x,y=e.y-v.y}
				force.x=force.x+f.x
				force.y=force.y+f.y
			end
			
			local forceAngle=math.getAngle(0,0,force.x,force.y)
			local da=forceAngle-e.angle
			if da<-180 then
				da=360+da
			end
			
			if da>180 then
				da=360-da
			end
			
			if da>0 then
				enemy.turnRight(e,dt)
			else	
				enemy.turnLeft(e,dt)
			end
			
		elseif e.boidsStage==1 then
		
			local averAngle=0
			for i,v in pairs(group) do
				averAngle=averAngle+v.angle
			end
			averAngle=averAngle/#group
			
			local da=averAngle-e.angle
			if da<-180 then
				da=360+da
			end
			
			if da>180 then
				da=360-da
			end
			
			if da>0 then
				enemy.turnRight(e,dt)
			else	
				enemy.turnLeft(e,dt)
			end
			
		elseif e.boidsStage==2 then
		
			local averPos={x=0,y=0}
			for i,v in pairs(group) do
				averPos.x=averPos.x+v.x
				averPos.y=averPos.y+v.y
			end
			averPos.x=averPos.x/#group
			averPos.y=averPos.y/#group
			
			local posAngle=math.getAngle(0,0,averPos.x,averPos.y)
			local da=posAngle-e.angle
			if da<-180 then
				da=360+da
			end
			
			if da>180 then
				da=360-da
			end
			
			if da>0 then
				enemy.turnRight(e,dt)
			else	
				enemy.turnLeft(e,dt)
			end
		
		
		end
	else
		local left=math.random(1,2)

		if left>1 then
			enemy.turnLeft(e,dt)
		else
			enemy.turnRight(e,dt)
		end
	end

end

function enemy.update(dt)
	aliveNum=0
	
	if spawnTimer>0 then
		spawnTimer=spawnTimer-dt
	else
		--enemy.resetAll()
		spawnTimer=5
	end
	
	for i,v in pairs(enemies) do
		--v.ps:setColors(v.color.r,v.color.g, v.color.b, v.color.a, 120-v.color.r, 120-v.color.g, 120-v.color.b, 0)
		v.ps:update(dt )
		v.ps:setPosition(v.x , v.y )
		
		if v.alive then
			aliveNum=aliveNum+1
			
			v.boidsStage=v.boidsStage+1
			if v.boidsStage>2 then
				v.boidsStage=0
			end
			
			if v.energy>0.4 then
				v.energy=v.energy-v.energy*dt/v.endurance
			else
				enemy.die(v)
				return
			end
			
			if v.leftLoop>=3 then
				v.isMating=true
			else
				v.isMating=false
			end
			
			if v.isMating then
				--check others hit box
				enemy.checkMate(v,dt)
			end
			
			if v.isChasing and v.target  then
				if (not v.target.isMating) then
					v.target=nil
				end
			end
			
			if v.isAttacking and v.target then
				if v.energy<v.target.energy then
					v.target=nil
				end
				enemy.checkAttack(v,dt)
			end
			
			v.vx,v.vy=vector2.normalized(v.vx,v.vy, v.speed)

			enemy.growUp(v)
			
			
			--text=text.."/"..800*800
			
			if v.minAngle<-180 then
				v.minAngle=360+v.minAngle
			end
		
			if v.maxAngle>180 then
				v.maxAngle=v.maxAngle-360
			end
			
			if v.isPlayer then
				if love.keyboard.isDown("return")  then
					enemy.turnLeft(v,dt)
				else
					enemy.turnRight(v,dt)
				end
			else	
				if v.target~=nil then
					--text="follow"
					local angleToPlayer=math.getAngle(v.x,v.y,v.target.x,v.target.y)

					local da=angleToPlayer-v.angle
					if da<-180 then
						da=360+da
					end
					
					if da>180 then
						da=360-da
					end
					
					if da>0 then
						enemy.turnRight(v,dt)
					else	
						enemy.turnLeft(v,dt)
					end

					if v.target.alive==false then
						v.target=nil
					end
					
					if v.rightLoop>=3 then
						
						--if not v.isChasing then
						--	v.target=nil
							enemy.turnLeft(v,dt)
						--end
					end
				else
					--text="searching"
					
					
					if v.age>=v.breedAge then
						if v.energy>0.7 then
							enemy.mate(v,dt)
						else
							enemy.searchFood(v)
							enemy.wander(v,dt)
						end
					else
						if v.energy<v.greed then
							enemy.searchFood(v)
						end
						enemy.wander(v,dt)
					end

				end
				
				if (v.x<10 or v.x>width-10 or v.y<10 or v.y>height-10) then
					enemy.turnLeft(v,dt)
				end
			end
			
			v.ax,v.ay=vector2.normalized(v.ax,v.ay, v.speed*v.gene.angularVelocity)
			
			
			v.vx=v.vx+v.ax*dt/2
			v.vy=v.vy+v.ay*dt/2
			
			v.x=v.x+v.vx*dt
			v.y=v.y+v.vy*dt
			
			v.x=math.clamp(v.x, 0, width)
			v.y=math.clamp(v.y, 0, height)
			
			v.angle=math.getAngle(0,0,v.vx,v.vy)
			v.minAngle=v.angle-v.viewRange/2
			v.maxAngle=v.angle+v.viewRange/2
			
			
			--v.circle=math.loop(100*realTimer,v.circleMax)
		else
			table.remove(enemies,i)
		end
	end
	--text=enemy.log()
	
	
end


function enemy.draw()
	for i,v in pairs(enemies) do
		love.graphics.setBlendMode("alpha")
		love.graphics.draw(v.ps)
		if v.alive then
			
			love.graphics.setColor(v.color.r,v.color.g,v.color.b,120)
			love.graphics.setBlendMode("alpha")
			love.graphics.circle( "fill",v.x,v.y,v.size)
			
			love.graphics.setBlendMode("additive")
			love.graphics.draw(glow, v.x-glow:getWidth()/2, v.y-glow:getHeight()/2,0,1,1)
			
			
			
			--love.graphics.circle( "line",v.x,v.y,v.circle)
			
		end
		
		--love.graphics.draw(v.explosion)
	end
end

function enemy.sendSignal(e,C)
	local s=signal.new(e,300*e.energy,C)
	table.insert(signals,s)
end

function enemy.receiveSignal(e,s)
	local receiveC={r=0,g=0,b=255,a=255}
	--enemy.sendSignal(e,receiveC)
end

function enemy.searchFood(e)
	if #foodArray<=#enemies*0.5 then

		if e.gene.aggressiveness>0.5 then
			e.isAttacking=true
			e.HSBColor.h=0
		end

	else
		if e.isAttacking then
			e.HSBColor.h=e.gene.hue
			e.isAttacking=false
			e.target=nil
		end
	end
	
	if e.isAttacking then
		for i,v in pairs(enemies) do
			if v.alive and v.id~=e.id then
				local angleToEnemy=math.getAngle(e.x,e.y,v.x,v.y)
				if (e.minAngle<e.maxAngle and angleToEnemy>e.minAngle and angleToEnemy<e.maxAngle) or (e.minAngle>e.maxAngle and not(angleToEnemy<e.minAngle and angleToEnemy>e.maxAngle) ) then

					local distanceToEnemy=vector2.distanceSqr(e.x,e.y,v.x,v.y)

					if  distanceToEnemy<math.pow(e.viewDistance,2) and e.energy>v.energy then
						
						e.target=v
						return
					end

				end
			end
		end
	end
	
	if #foodArray<=#enemies then
		return
	end
	
	for i,f in pairs(foodArray) do
		
		if f.alive then
			
			local angleToEnemy=math.getAngle(e.x,e.y,f.x,f.y)
			
			if (e.minAngle<e.maxAngle and angleToEnemy>e.minAngle and angleToEnemy<e.maxAngle) or (e.minAngle>e.maxAngle and not(angleToEnemy<e.minAngle and angleToEnemy>e.maxAngle) ) then
			--if angleToEnemy>e.minAngle and angleToEnemy<e.maxAngle then
				--f.color.r=255
				--f.color.g=0
				--f.color.b=0
				local distanceToEnemy=vector2.distanceSqr(e.x,e.y,f.x,f.y)
				
				--text="distance: "..math.floor(distanceToEnemy).." x: "..math.floor(f.x-e.x).." y: "..math.floor(f.y-e.y).." angle2Enemy: "..math.floor(angleToEnemy).."\n"
				
				if  distanceToEnemy<math.pow(e.viewDistance,2) then
					e.target=f
					local tempsignal={r=255,g=255,b=255,a=128}
					enemy.sendSignal(e,tempsignal)
					return
					--f.color.r=0
					--f.color.g=0
					--f.color.b=255
					--text="distance: "..math.floor(distanceToEnemy).." x: "..f.x.." y: "..f.y.." yes".."\n"
					--text=text.."angle2Enmey: "..angleToEnemy.."\n"
					--text=text..enemy.log()
					
				end
				
			else
				--f.color.r=0
				--f.color.g=255
				--f.color.b=0
			end
		end
	end
end

function enemy.log()
	local info=""
	for i,v in pairs(enemies) do
		info=info.."enemy "..i..", speed: "..v.speed.." angle: "..math.floor(v.angle).." max: "..math.floor(v.maxAngle).." min: "..math.floor(v.minAngle)
		if v.target~=nil then
			info=info.." target: "..v.target.x..", "..v.target.y.."\n"
		else
			info=info.." target: no\n"
		end
	end
	return info
end