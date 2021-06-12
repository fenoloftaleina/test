local logic = {}


local lg = love.graphics
local flux = require "libs/flux"

local utils = require "utils"
local world = require "world"
local map = require "map"


function logic.prepare(guy, dog)
  map.ij_to_xy(guy.pos)
  map.ij_to_xy(dog.pos)
end


function logic.run(guy, dog, move)
  guy.pos.i = guy.pos.i + move.i
  guy.pos.j = guy.pos.j + move.j

  flux.to(guy.pos, 0.3, {x = guy.pos.i * (map.tile_size + map.margin), y = guy.pos.j * (map.tile_size + map.margin)})

  dog.pos.i = dog.pos.i + move.i
  dog.pos.j = dog.pos.j + move.j

  flux.to(dog.pos, 0.3, {x = dog.pos.i * (map.tile_size + map.margin), y = dog.pos.j * (map.tile_size + map.margin)})
end


return logic
