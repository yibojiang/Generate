vector2={}

function vector2.rotate(X,Y,Rad)
	return	X*math.cos(Rad)-Y*math.sin(Rad),X*math.sin(Rad)+Y*math.cos(Rad)
end

function vector2.normalized(X,Y,Length)
	local mag=math.sqrt(X*X+Y*Y)
	return X/mag*Length,Y/mag*Length
end

function vector2.distanceSqr(X1,Y1,X2,Y2)
	return math.pow( X2-X1,2)+math.pow( Y2-Y1,2)
	
end

