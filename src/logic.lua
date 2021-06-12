local logic = {}


local lg = love.graphics
local flux = require "libs/flux"

local utils = require "utils"
local world = require "world"
local map = require "map"


function logic.prepare(guy, dog)
  map.ij_to_xy(guy.pos)
  map.ij_to_xy(dog.pos)

  guy.in_bush = false
  dog.in_bush = false
end


function collisions(guy, dog)
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

  local collided = collisions(guy, dog)




  if collided then return end

  guy.pos.i = guy.next_pos.i
  guy.pos.j = guy.next_pos.j
  dog.pos.i = dog.next_pos.i
  dog.pos.j = dog.next_pos.j

  flux.to(guy.pos, 0.3, {x = guy.pos.i * (map.tile_size + map.margin), y = guy.pos.j * (map.tile_size + map.margin)})

  flux.to(dog.pos, 0.3, {x = dog.pos.i * (map.tile_size + map.margin), y = dog.pos.j * (map.tile_size + map.margin)})
end


return logic
