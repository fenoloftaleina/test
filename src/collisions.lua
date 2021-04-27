collisions = {}

local utils = require "utils"

function collisions.circle_rect(cx, cy, cr, x1, y1, x2, y2)
  local dx = utils.clamp(x1, cx, x2) - cx
  local dy = utils.clamp(y1, cy, y2) - cy
  local d_squared = dx*dx + dy*dy
  local collided = (d_squared <= cr*cr)

  if collided then
    local d = math.sqrt(d_squared)
    local nx, ny = dx / d, dy / d
    local restitution = cr - d
    -- return true, cr - d * nx, cr - d * ny
    return true, restitution * nx, restitution * ny
  else
    return false, 0, 0
  end
end

return collisions
