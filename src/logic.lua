local logic = {}


local lg = love.graphics
local flux = require "libs/flux"

local utils = require "utils"
local world = require "world"
local map = require "map"


local sqrt = math.sqrt
local floor = math.floor


function prepare_visibility(dog)
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

  for i=1,2 do
    for j=1,2 do
      if not map.tiles_overlay[i][j].next_active then
        pos = {i = i, j = j}
        map.ij_to_xy(pos)
        x2 = pos.x + (map.margin + map.tile_size) * 0.5
        y2 = pos.y + (map.margin + map.tile_size) * 0.5

        dx = x2 - x1
        dy = y2 - y1
        d = sqrt(dx * dx + dy * dy)
        vx = 1 / (d * 2)
        vy = dy / (dx * d * 2)

        found_along_the_way[#found_along_the_way] = {i = floor(x2 / (map.tile_size + map.margin)), j = floor(y2 / (map.tile_size + map.margin))}

        x, y = x2 + vx, y2 + vy
        found = false
        while x < x1 or y < y1 do
          ci = floor(x / (map.tile_size + map.margin))
          cj = floor(y / (map.tile_size + map.margin))

          if ci > 0 and cj > 0 and ci < #map.tiles and cj < #map.tiles[1] then
            if map.tiles[ci][cj] == map.bush or map.tiles[ci][cj] == map.wall then
              found = true
            else
              found_along_the_way[#found_along_the_way] = {i = ci, j = cj}
            end
          end

          x = x + vx
          y = y + vy
        end

        if found then
          for k=1,#found_along_the_way do
            map.tiles_overlay[found_along_the_way[k].i][found_along_the_way[k].j].next_active = true
            if not map.tiles_overlay[found_along_the_way[k].i][found_along_the_way[k].j].active then
              map.tiles_overlay[found_along_the_way[k].i][found_along_the_way[k].j].active = true
              flux.to(map.tiles_overlay[found_along_the_way[k].i][found_along_the_way[k].j], 1, {opacity = 1})
            end
          end
        else
          for k=1,#found_along_the_way do
            if map.tiles_overlay[found_along_the_way[k].i][found_along_the_way[k].j].active then
              map.tiles_overlay[found_along_the_way[k].i][found_along_the_way[k].j].active = false
              flux.to(map.tiles_overlay[found_along_the_way[k].i][found_along_the_way[k].j], 1, {opacity = 0})
            end
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


  prepare_visibility(dog)
end


function resolve_collisions(guy, dog)
  -- out of bounds
  if guy.next_pos.i < 1 or
    guy.next_pos.i > #map.tiles or
    guy.next_pos.j < 1 or
    guy.next_pos.j > #map.tiles[1] or
    dog.next_pos.i < 1 or
    dog.next_pos.i > #map.tiles or
    dog.next_pos.j < 1 or
    dog.next_pos.j > #map.tiles[1] then

    return true
  end

  -- water
  if map.tiles[guy.next_pos.i][guy.next_pos.j] == map.water or
    map.tiles[dog.next_pos.i][dog.next_pos.j] == map.water then

    return true
  end

  -- wall
  if map.tiles[guy.next_pos.i][guy.next_pos.j] == map.wall or
    map.tiles[guy.next_pos.i][guy.next_pos.j] == map.wall then
    return true
  end

  -- bush
  if map.tiles[guy.next_pos.i][guy.next_pos.j] == map.bush then
    guy.in_bush = true
  else
    guy.in_bush = false
  end
  if map.tiles[dog.next_pos.i][dog.next_pos.j] == map.bush then
    dog.in_bush = true
  else
    dog.in_bush = false
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
  dog.pos.i = dog.next_pos.i
  dog.pos.j = dog.next_pos.j

  flux.to(guy.pos, 0.3, {x = guy.pos.i * (map.tile_size + map.margin), y = guy.pos.j * (map.tile_size + map.margin)})

  flux.to(dog.pos, 0.3, {x = dog.pos.i * (map.tile_size + map.margin), y = dog.pos.j * (map.tile_size + map.margin)})


  prepare_visibility(dog)
end


return logic
