signal={}


signals={}

function signal.update(dt)

end

function signal.new(E,L,C)
	local s={}
	s.waveLength=L
	s.l=0
	s.x=E.x
	s.y=E.y
	s.id=E.id
	s.color=C
	s.alive=true
	return s
end

function signal.update(dt)
	for i,v in pairs(signals) do
		if v.alive then
			if v.l<v.waveLength then
				v.l=v.l+100*dt
			else
				v.alive=false
			end
			
			
			for _i,e in pairs(enemies) do
				if (v.x-e.x)*(v.x-e.x)+(v.y-e.y)*(v.y-e.y) < v.l*v.l  and (v.x-e.x)*(v.x-e.x)+(v.y-e.y)*(v.y-e.y) > (v.l-1)*(v.l -1) then
					enemy.receiveSignal(e,v)
				end
			end
			
			v.l=math.clamp(v.l,0,v.waveLength)
		else
			table.remove(signals,i)
		end
		
	end
end

function signal.draw()
	for i,v in pairs(signals) do
		love.graphics.setColor(v.color.r,v.color.g,v.color.b,(1-v.l/v.waveLength)*255)
		love.graphics.circle( "line",v.x,v.y,v.l)
	end
	

end