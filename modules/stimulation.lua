stimulation={}
stimulationArray={}
stimulationNum=0


local spawnInterval=15
local spawnTimer=spawnInterval

function stimulation.generate(X,Y,Energy)
	
	local energy=math.ceil(Energy*10)
	
	for i=1,energy do
		local s=stimulation.new()
		s.x=X
		s.y=Y
		table.insert(stimulationArray,s)
	end
end

function stimulation.generateRandom(Num,Energy)
	
	local energy=math.ceil(Energy*10)
	for j=1,Num do
		local X=math.random(0+10,width-10)
		local Y=math.random(0+10,height-10)
		for i=1,energy do
			local s=stimulation.new()
			s.x=X
			s.y=Y
			table.insert(stimulationArray,s)
		end
	end
end


function stimulation.init()
	stimulation.generateRandom(stimulationNum,0.2)
end

function stimulation.new()
	local s={}
	
	s.alive=true
	s.vx=math.random()-0.5
	s.vy=math.random()-0.5
	s.ax=math.random()-0.5
	s.ay=math.random()-0.5
	s.alive=true
	s.size=6
	s.energy=0.6
	s.angularVelocity=4
	s.speed=80*s.energy/s.angularVelocity
	
	return s
end

function stimulation.update(dt)
	if spawnTimer>0  then
		spawnTimer=spawnTimer-dt
	else
		if #stimulationArray<=100 then
			stimulation.generateRandom(2,0.1)
			spawnTimer=spawnInterval
		end
	end
	
	for i,v in pairs(stimulationArray) do
		if v.alive then
			
			v.vx,v.vy=vector2.normalized(v.vx,v.vy, v.speed)
			local left=math.random(1,2)

			if left>1 then
				v.ax,v.ay=vector2.rotate(v.vx,v.vy,-math.pi/2)
			else
				v.ax,v.ay=vector2.rotate(v.vx,v.vy,math.pi/2)
			end
			
			v.ax,v.ay=vector2.normalized(v.ax,v.ay, v.speed*v.angularVelocity)
			
			
			v.vx=v.vx+v.ax*dt/2
			v.vy=v.vy+v.ay*dt/2
			
			v.x=v.x+v.vx*dt
			v.y=v.y+v.vy*dt
			
			v.x=math.clamp(v.x, 0, width)
			v.y=math.clamp(v.y, 0, height)
			
			if (v.x<10 or v.x>width-10 or v.y<10 or v.y>height-10) then
				v.ax,v.ay=vector2.rotate(v.vx,v.vy,-math.pi/2)
			end
		else
			table.remove(stimulationArray,i)	
		end
		
	end

end

function stimulation.draw()
	for i,v in pairs(stimulationArray) do
		if v.alive then
		
			love.graphics.setColor(255,255,255,130)
			love.graphics.circle( "fill",v.x,v.y, v.size)
			love.graphics.setColor(255,255,255,100)
			love.graphics.circle( "fill",v.x,v.y, 4)
			love.graphics.setColor(0,0,0,120)
			love.graphics.circle( "fill",v.x,v.y, 2)
		end
	end
end