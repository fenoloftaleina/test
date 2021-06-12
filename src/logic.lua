local logic = {}


local lg = love.graphics
local flux = require "libs/flux"

local utils = require "utils"
local world = require "world"
local map = require "map"


local sqrt = math.sqrt
local floor = math.floor
local min = math.min
local max = math.max


function segmentVsAABB(x1, y1, x2, y2, l, t, r, b)
  -- normalize segment
  local dx, dy = x2 - x1, y2 - y1
  local d = sqrt(dx*dx + dy*dy)
  if d == 0 then
    return false
  end
  local nx, ny = dx/d, dy/d
  -- minimum and maximum intersection values
  local tmin, tmax = 0, d
  -- x-axis check
  if nx == 0 then
    if x1 < l or x1 > r then
      return false
    end
  else
    local t1, t2 = (l - x1)/nx, (r - x1)/nx
    if t1 > t2 then
      t1, t2 = t2, t1
    end
    tmin = max(tmin, t1)
    tmax = min(tmax, t2)
    if tmin > tmax then
      return false
    end
  end
  -- y-axis check
  if ny == 0 then
    if y1 < t or y1 > b then
      return false
    end
  else
    local t1, t2 = (t - y1)/ny, (b - y1)/ny
    if t1 > t2 then
      t1, t2 = t2, t1
    end
    tmin = max(tmin, t1)
    tmax = min(tmax, t2)
    if tmin > tmax then
      return false
    end
  end
  -- points of intersection
  -- one point
  local qx, qy = x1 + nx*tmin, y1 + ny*tmin
  if tmin == tmax then
    return true, qx, qy
  end
  -- two points
  return true, qx, qy, x1 + nx*tmax, y1 + ny*tmax
end


function logic.prepare_visibility(dog)
  local pos = {i = dog.pos.i, j = dog.pos.j}
  map.ij_to_xy(pos)
  local x1 = pos.x + (map.margin + map.tile_size) * 0.5
  local y1 = pos.y + (map.margin + map.tile_size) * 0.5

  local x2, y2, dx, dy, d, vx, vy, first_i, first_j, x, y, found, ci, cj

  local found_along_the_way = {}

  for i=1,#map.tiles do
    for j=1,#map.tiles[1] do
      map.tiles_overlay[i][j].next_active = false
    end
  end

  for i=1,#map.tiles do
    for j=1,#map.tiles do
      if map.tiles[i][j] == map.grass then
        pos = {i = i, j = j}
        map.ij_to_xy(pos)
        x2 = pos.x + (map.margin + map.tile_size) * 0.5
        y2 = pos.y + (map.margin + map.tile_size) * 0.5


        local found = false

        for k=1,#map.hiders do
          if map.hiders[k].i == dog.pos.i and map.hiders[k].j == dog.pos.j then
            -- skip
          else
            found = segmentVsAABB(x1, y1, x2, y2,
            map.hiders[k].x, map.hiders[k].y + map.tile_size, map.hiders[k].x + map.tile_size, map.hiders[k].y)

            if found then
              break
            end
          end
        end

        if found then
          if not map.tiles_overlay[i][j].active then
            map.tiles_overlay[i][j].active = true
            flux.to(map.tiles_overlay[i][j], 1, {opacity = 1})
          end
        else
          if map.tiles_overlay[i][j].active then
            map.tiles_overlay[i][j].active = false
            flux.to(map.tiles_overlay[i][j], 1, {opacity = 0})
          end
        end
      end
    end
  end

  -- dog.line = {x1, y1, x2, y2}
end


function logic.prepare(guy, dog)
  map.ij_to_xy(guy.pos)
  map.ij_to_xy(dog.pos)

  guy.in_bush = false
  dog.in_bush = false















  -- guy.crouching = false
  guy.crouching = true














  guy.win = false
  dog.lost = false
  dog.sees_bone = false
  dog.next_lost = false

  logic.prepare_visibility(dog)
end


function resolve_bone_case(dog)
  local i = dog.pos.i
  local j = dog.pos.j

  dog.sees_bone = false

  -- no bones seen from a bush
  -- if map.tiles[i][j] == map.bush then return end

  i = dog.pos.i - 1
  if i > 0 and not (map.tiles[i][j] == map.wall or map.tiles[i][j] == map.cat) then
    while i > 0 do
      if map.tiles[i][j] == map.bone then
        dog.next_pos.i = dog.pos.i - 1
        dog.next_pos.j = dog.pos.j
        dog.sees_bone = true
        return
      end

      i = i - 1
    end
  end

  i = dog.pos.i + 1
  if i <= #map.tiles and not (map.tiles[i][j] == map.wall or map.tiles[i][j] == map.cat) then
    while i <= #map.tiles do
      if map.tiles[i][j] == map.bone then
        dog.next_pos.i = dog.pos.i + 1
        dog.next_pos.j = dog.pos.j
        dog.sees_bone = true
        return
      end

      i = i + 1
    end
  end

  i = dog.pos.i

  j = dog.pos.j - 1
  if j > 0 and not (map.tiles[i][j] == map.wall or map.tiles[i][j] == map.cat) then
    while j > 0 do
      if map.tiles[i][j] == map.bone then
        dog.next_pos.j = dog.pos.j - 1
        dog.next_pos.i = dog.pos.i
        dog.sees_bone = true
        return
      end

      j = j - 1
    end
  end

  j = dog.pos.j + 1
  if j <= #map.tiles[1] and not (map.tiles[i][j] == map.wall or map.tiles[i][j] == map.cat) then
    while j <= #map.tiles[1] do
      if map.tiles[i][j] == map.bone then
        dog.next_pos.j = dog.pos.j + 1
        dog.next_pos.i = dog.pos.i
        dog.sees_bone = true
        return
      end

      j = j + 1
    end
  end
end


function resolve_collisions(guy, dog)
  -- out of bounds
  if guy.next_pos.i < 1 or
    guy.next_pos.i > #map.tiles or
    guy.next_pos.j < 1 or
    guy.next_pos.j > #map.tiles[1] then

    return true
  end

  -- bone
  resolve_bone_case(dog)

  if map.tiles[guy.next_pos.i][guy.next_pos.j] == map.bone then
    return true
  end

  if not dog.lost and (
      dog.next_pos.i < 1 or
      dog.next_pos.i > #map.tiles or
      dog.next_pos.j < 1 or
      dog.next_pos.j > #map.tiles[1]) then

      return true
    end

  -- water
  if map.tiles[guy.next_pos.i][guy.next_pos.j] == map.water then
    return true
  end

  -- wall
  if map.tiles[guy.next_pos.i][guy.next_pos.j] == map.wall or
    (not dog.lost and map.tiles[dog.next_pos.i][dog.next_pos.j] == map.wall) then

    if (not dog.lost and map.tiles[dog.next_pos.i][dog.next_pos.j] == map.wall) and
      dog.sees_bone then
      dog.sees_bone = false
    end

    return true
  end

  -- cat
  if not dog.lost and map.tiles[dog.next_pos.i][dog.next_pos.j] == map.cat then
    dog.next_pos.i = dog.pos.i
    dog.next_pos.j = dog.pos.j

    if dog.sees_bone then
      dog.sees_bone = false
    end
  end
  if map.tiles[guy.next_pos.i][guy.next_pos.j] == map.cat then
    return true
  end

  -- bush
  if map.tiles[guy.next_pos.i][guy.next_pos.j] == map.bush then
    guy.in_bush = true
    guy.crouching = true
  else
    guy.in_bush = false
  end


  if guy.in_bush or (guy.crouching and map.tiles_overlay[guy.next_pos.i][guy.next_pos.j].active) then
    if not dog.sees_bone then
      dog.lost = true
      dog.next_lost = true
    end

    dog.wannabe_lost = true
  else
    dog.next_lost = false
    if dog.wannabe_lost and guy.crouching then









      -- guy.crouching = false









      dog.wannabe_lost = false
    end
  end


  -- bush dog after guy visibility
  if not dog.lost then
    if map.tiles[dog.next_pos.i][dog.next_pos.j] == map.bush then
      dog.in_bush = true
    else
      dog.in_bush = false
    end
  end


  return false
end


function logic.run(guy, dog, move)
  guy.next_pos.i = guy.pos.i + move.i
  guy.next_pos.j = guy.pos.j + move.j

  dog.next_pos.i = dog.pos.i + move.i
  dog.next_pos.j = dog.pos.j + move.j

  if resolve_collisions(guy, dog) then return end


  guy.pos.i = guy.next_pos.i
  guy.pos.j = guy.next_pos.j

  flux.to(guy.pos, 0.3, {x = guy.pos.i * (map.tile_size + map.margin), y = guy.pos.j * (map.tile_size + map.margin)})

  if not dog.lost then
    dog.pos.i = dog.next_pos.i
    dog.pos.j = dog.next_pos.j

    flux.to(dog.pos, 0.3, {x = dog.pos.i * (map.tile_size + map.margin), y = dog.pos.j * (map.tile_size + map.margin)})
  elseif not dog.next_lost then
    dog.lost = false
  end

  logic.prepare_visibility(dog)


  if ((dog.pos.i == guy.pos.i and (dog.pos.j + 1 == guy.pos.j or dog.pos.j - 1 == guy.pos.j)) or
    (dog.pos.j == guy.pos.j and (dog.pos.i + 1 == guy.pos.i or dog.pos.i - 1 == guy.pos.i))) then
    guy.win = true
  end

  if map.tiles[dog.pos.i][dog.pos.j] == map.bone then
    dog.sees_bone = false
    map.tiles[dog.pos.i][dog.pos.j] = map.grass
  end
end


return logic
