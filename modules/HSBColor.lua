HSBColor={}


function HSBColor.toColor(HSBC)
	local r=HSBC.b
	local g=HSBC.b
	local b=HSBC.b
	local a=HSBC.a
	if HSBC.s~=0 then
		local max=HSBC.b
		local dif=HSBC.b*HSBC.s
		local min=HSBC.b-dif
		local h=HSBC.h*360
		
		if (h<60) then
			r=max
			g=h*dif/60+min
			b=min
		elseif (h<120) then
			r=-(h-120)*dif/60+min
			g=max
			b=min
		elseif (h<180) then
			r=min
			g=max
			b=(h-120)*dif/60+min
		elseif (h<240) then
			r=min
			g=-(h-240)*dif/60+min
			b=max
		elseif (h<300) then
			r=(h-240)*dif/60+min
			g=min
			b=max
		elseif (h<=360) then
			r=max
			g=min
			b=-(h-360)*dif/60+min
		else
			r=0
			g=0
			b=0
		end
		
	end
	
	r=math.clamp(r,0,1)
	g=math.clamp(g,0,1)
	b=math.clamp(b,0,1)
	a=math.clamp(a,0,1)
	local color={r=r*255,g=g*255,b=b*255,a=a*255}
	
	return color

       
end


function HSBColor.getNearColor(HSBC,Deg)
	local newHSBC={}
	newHSBC.h=HSBC.h+Deg/360
	newHSBC.h=newHSBC.h%1
	newHSBC.s=HSBC.s
	newHSBC.b=HSBC.b
	newHSBC.a=HSBC.a
	
	return HSBColor.toColor(newHSBC)
end

function HSBColor.fromColor(C)	
	ret={h=0,s=0,g=0,a=C.a/255}
	
	local r=C.r/255
	local g=C.g/255
	local b=C.b/255
	
	local max=math.max(r,math.max(g,b))
	
	if (max<=0) then
		return ret
	end
	
	local min=math.min(r,math.min(g,b))
	local dif=max-min
	
	if max>min then
		if (g==max) then
			ret.h=(b-r)/dif*60+120
		elseif (b==max) then
			ret.h=(r-g)/dif*60+240
		elseif (b>g) then
			ret.h=(g-b)/dif*60+360
		else
			ret.h=(g-b)/dif*60
		end
		
		if (ret.h<0) then
			ret.h=ret.h+360
		end
	else
		ret.h=0	
	end
	
	ret.h=ret.h*1/360
	ret.s=(dif/max)
	ret.b=max
	
	return ret
	
end