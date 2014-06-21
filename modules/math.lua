function math.clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end

function math.deg2Rad(Deg)
	return Deg/180*math.pi/2
end

function math.rad2Deg(Rad)
	return Rad*2/math.pi*180
end

function math.pingPong(T,L)
	if math.floor(T/L) %2==0 then
		return T%L
	else
		return L-T%L
	end
end

function math.loop(T,L)
	return (T%L)
end

function math.getAngle(x1,y1,x2,y2)
	local x0=x2-x1
	local y0=y2-y1

	if x0==0 and y0==0 then
		return 0
	end
	
	local c1= 3.14159265 * 0.25;
	local c2=3*c1
	local ay= y0<0 and -y0 or y0
	
	local angle=0
	
	if x0>=0 then
		angle=c1-c1*( (x0-ay)/(x0+ay) )
	else
		angle=c2-c1*((x0+ay)/(ay-x0) )
	end
	
	angle=((y0<0) and -angle or angle)*57.2957796

	if angle>90 then
		angle=angle-270
	else 
		angle=angle+90
	end
	
	
	return angle
end