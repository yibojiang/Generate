explosion={}
function explosion:new(Color)
	newexplosion=love.graphics.newParticleSystem(particle, 100)
	newexplosion:setEmissionRate(100)
	newexplosion:setLifetime(5)
	newexplosion:setParticleLife(5, 5)
	newexplosion:setSizes(1, 5)
	newexplosion:setSpread(math.tau)
	newexplosion:setSpeed(100, 300)
	
	newexplosion:setColors(255-	Color.r,255-Color.g, 255-Color.b, 150,Color.r,Color.g, Color.b, 0)
	newexplosion:stop()
	return newexplosion

end