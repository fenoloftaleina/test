collisions = {}

local utils = require "utils"

local abs = math.abs
local sqrt = math.sqrt

function collisions.circle_rect(cx, cy, cr, x1, y1, x2, y2)
  local dx = utils.clamp(x1, cx, x2) - cx
  local dy = utils.clamp(y1, cy, y2) - cy
  local d_squared = dx*dx + dy*dy
  local collided = (d_squared <= cr*cr)

  if collided then
    local d = sqrt(d_squared)
    local nx, ny = dx / d, dy / d
    local restitution = cr - d
    return true, d, - restitution * nx, - restitution * ny
  else
    return false, nil, 0, 0
  end
end


-- hw - half width, hh - half height
function collisions.rect_rect(ax, ay, ahw, ahh, bx1, by1, bx2, by2)
  local bhw = (bx2 - bx1) * 0.5
  local bhh = (by2 - by1) * 0.5
  local bx = bx1 + bhw
  local by = by1 + bhh

  local dx = ax - bx
  local dy = ay - by
  local adx = abs(dx)
  local ady = abs(dy)

  local shw = ahw + bhw
  local shh = ahh + bhh

  if adx >= shw or ady >= shh then
    return false, nil, 0, 0
  end

  local sx = shw - adx
  local sy = shh - ady
  local s = sx * sx + sy * sy

  if sx < sy then
    if sx > 0 then
      sy = 0
    end
  else
    if sy > 0 then
      sx = 0
    end
  end

  if dx < 0 then
    sx = -sx
  end
  if dy < 0 then
    sy = -sy
  end

  return true, s, sx, sy
end


return collisions
