food={}
foodArray={}
foodNum=20
foodMax=0
foodAlive=0

local spawnInterval=10
local spawnTimer=spawnInterval


function food.randomGene()
	local gene={}
	gene.angularVelocity=4
	
	--gene.endurance=math.random(120,200)
	gene.power=math.random()+1
	gene.lifeTime=math.random(2,4)
	gene.growSpeed=math.random()*0.05+0.05
	
	
	return gene
end

function food.new(gene)
	local f={}
	f.gene=gene
	
	f.alive=true
	
	f.HSBColor={h=math.random(),s=1,b=1,a=1}
	--f.HSBColor={h=0.8,s=1,b=1,a=1}
	f.color=HSBColor.toColor(f.HSBColor)
	
	--text=f.color.r..", "..f.color.g..", "..f.color.b
	f.birthday=day
	f.age=day-f.birthday

	f.breedAge=math.floor(f.gene.lifeTime*0.5)
	--f.breedAge=0
	f.vx=math.random()-0.5
	f.vy=math.random()-0.5
	f.ax=math.random()-0.5
	f.ay=math.random()-0.5
	f.energy=1
	f.size=f.energy*10
	
	f.speed=60*f.energy/f.gene.angularVelocity
	
	f.x=math.random(0+10,width-10)
	f.y=math.random(0+10,height-10)
	--f.explosion=explosion:new(f.color)
	return f
end


function food.init()
	--foodMax=20*math.abs(math.sin(day/cycleDay*math.pi))+10
	local i
	for i=1,foodNum do 
		foodArray[i]=food.new(food.randomGene())
	end	
end

function food.generateRandom(num)
	for i=1,num do 
		local newfood=food.new(food.randomGene())
		table.insert(foodArray,newfood)
	end
end

function food.generate(f)
	
	
	if #foodArray>50 then
		return
	end
	
	local newfood=food.new(f.gene)
	newfood.x=f.x
	newfood.y=f.y
	f.energy=1
	table.insert(foodArray,newfood)
end
	

	
function food.growUp(f)
	f.age=day-f.birthday
	
	if f.age>f.gene.lifeTime then
		f.isAlive=false
		return
	end
	
	f.maxEnergy=f.gene.power*math.abs(math.sin(f.age/cycleDay*math.pi))+1.5
	food.updateEnergy(f)
end

function food.updateEnergy(f)
	f.energy=math.clamp(f.energy,0,f.maxEnergy)
	f.speed=60*f.energy/f.gene.angularVelocity
	f.size=f.energy*10
	local HSBC=f.HSBColor
	HSBC.s=f.energy/2
	food.setHSBColor(f,HSBC)
end

function food.setHSBColor(f,HSBC)
	f.color=HSBColor.toColor(HSBC)
	f.HSBColor=HSBC
end

function food.update(dt)
	--foodMax=8*math.abs(math.sin(day/cycleDay*math.pi))+12
	
	foodAlive=0
	for i,v in pairs(foodArray) do
		--v.explosion:update(dt )
		if v.alive then
			foodAlive=foodAlive+1
			
			
			if (brightness>0.5) then
				v.energy=v.energy+v.gene.growSpeed*dt
			end
			
			if v.age>=v.breedAge and v.energy>1.2 then
				food.generate(v)
			end
			
			food.growUp(v)

			--[[
			if player.x >= v.x-v.size and player.x <= v.x + v.size
			and  player.y >= v.y-v.size and player.y  <= v.y + v.size 
			then
				local noteIndex=math.floor(math.random(1,6))

				sound.note[noteIndex]:setPitch(math.clamp(player.energy/2,0,2))
				--sound.note[noteIndex]:setVolume(math.random(0.5,1))
				sound.note[noteIndex]:play()
				
				--player.color=v.color
				--player.setColor(v.color)
				player.collide()

				v.alive=false
				v.explosion:setColors(255-	v.color.r,255-v.color.g, 255-v.color.b, 150,v.color.r,v.color.g, v.color.b, 0)
				v.explosion:setPosition(v.x , v.y )
				v.explosion:start()
			end
			]]
			v.vx,v.vy=vector2.normalized(v.vx,v.vy, v.speed)
			local left=math.random(1,2)

			if left>1 then
				v.ax,v.ay=vector2.rotate(v.vx,v.vy,-math.pi/2)
			else
				v.ax,v.ay=vector2.rotate(v.vx,v.vy,math.pi/2)
			end
			
			v.ax,v.ay=vector2.normalized(v.ax,v.ay, v.speed*v.gene.angularVelocity)
			
			
			v.vx=v.vx+v.ax*dt/2
			v.vy=v.vy+v.ay*dt/2
			
			v.x=v.x+v.vx*dt
			v.y=v.y+v.vy*dt
			
			v.x=math.clamp(v.x, 0, width)
			v.y=math.clamp(v.y, 0, height)
			
			if (v.x<10 or v.x>width-10 or v.y<10 or v.y>height-10) then
				v.ax,v.ay=vector2.rotate(v.vx,v.vy,-math.pi/2)
			end
			
			for _i,s in pairs(stimulationArray) do
				if s.x >= v.x-v.size and s.x <= v.x + v.size
				and  s.y >= v.y-v.size and s.y  <= v.y + v.size 
				then
					s.alive=false
					food.generate(v)
				end
			end
			
			for _i,e in pairs(enemies) do
				if e.x >= v.x-v.size and e.x <= v.x + v.size
				and  e.y >= v.y-v.size and e.y  <= v.y + v.size 
				then
					if e.isPlayer then
						local noteIndex=math.floor(math.random(1,6))
						sound.note[noteIndex]:setPitch(math.clamp(e.energy/2,0,2))
						sound.note[noteIndex]:play()
					end
					--enemy.setColor(e,v.color,v.HSBColor)
					enemy.levelup(e,v.energy)
					
					
					
					v.alive=false
					--v.explosion:setColors(255-v.color.r,255-v.color.g, 255-v.color.b, 150,v.color.r,v.color.g, v.color.b, 0)
					--v.explosion:setPosition(v.x , v.y )
					--v.explosion:start()
				end
			end
		else
			table.remove(foodArray,i)
		end
	end
	if spawnTimer>0  then
		spawnTimer=spawnTimer-dt
	else
		--[[
		if #foodArray<5 and brightness>0.4 then
			food.generateRandom(2)
			spawnTimer=spawnInterval
		end
		]]
		--stimulation.generateRandom(2,0.1)
		spawnTimer=spawnInterval
	end
	
end



function food.draw()
	for i,v in pairs(foodArray) do
		if v.alive then
			love.graphics.setColor(v.color.r,v.color.g,v.color.b,v.color.a)
			--love.graphics.setColor(255,255,255,130)
			love.graphics.setBlendMode("additive")
			love.graphics.draw(glow, v.x-glow:getWidth()/2, v.y-glow:getHeight()/2,0,1,1)
			
			love.graphics.setBlendMode("alpha")
			love.graphics.circle( "line",v.x,v.y, math.pingPong(realTimer*2,v.size/3)+v.size/2)
			
			
			
			love.graphics.setColor(255,255,255,100)
			love.graphics.circle( "fill",v.x,v.y, 4)
			love.graphics.setColor(0,0,0,120)
			love.graphics.circle( "fill",v.x,v.y, 2)
			
			
		end
		--love.graphics.draw(v.explosion)
	end
end