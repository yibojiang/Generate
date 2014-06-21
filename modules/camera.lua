camera = {}
camera._x = 0
camera._y = 0
camera.scaleX = 1
camera.scaleY = 1
camera.rotation = 0
camera.target=nil
function camera:set()
  love.graphics.push()
  love.graphics.rotate(-self.rotation)
  love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
  love.graphics.translate(-self._x, -self._y)
end

function camera:unset()
  love.graphics.pop()
end

function camera:setTarget(t)
	camera.target=t
end

function camera:move(dx, dy)
  self._x = self._x + (dx or 0)
  self._y = self._y + (dy or 0)
  --[[
  if self._bounds then
	self._x = math.clamp(self._x, self._bounds.x1, self._bounds.x2)
	self._y = math.clamp(self._y, self._bounds.y1, self._bounds.y2)
  end
  ]]
end

function camera:update(dt)
	if self.target~=nil then
		camera:move( (camera.target.x-camera._x-windowsWidth/2) *dt, (camera.target.y-camera._y-windowsHeight/2)*dt)
	end
end

function camera:rotate(dr)
  self.rotation = self.rotation + dr
end

function camera:scale(sx, sy)
  sx = sx or 1
  self.scaleX = self.scaleX * sx
  self.scaleY = self.scaleY * (sy or sx)
end

function camera:setX(value)
  if self._bounds then
    self._x = math.clamp(value, self._bounds.x1, self._bounds.x2)
  else
    self._x = value
  end
end

function camera:setY(value)
  if self._bounds then
    self._y = math.clamp(value, self._bounds.y1, self._bounds.y2)
  else
    self._y = value
  end
end

function camera:setPosition(x, y)
  if x then self:setX(x) end
  if y then self:setY(y) end
end

function camera:setScale(sx, sy)
  self.scaleX = sx or self.scaleX
  self.scaleY = sy or self.scaleY
end

function camera:getBounds()
  return unpack(self._bounds)
end

function camera:setBounds(x1, y1, x2, y2)
  self._bounds = { x1 = x1, y1 = y1, x2 = x2, y2 = y2 }
end