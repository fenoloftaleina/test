local map = {
  platforms = {}
}

local ls = love.sound
local la = love.audio
local lg = love.graphics
local lk = love.keyboard
local lm = love.mouse

local utils = require "utils"

local world = require "world"


local grass_color = {0.3, 0.7, 0.5}
local guy_color = {0.1, 0.2, 0.6}
local dog_color = {0.5, 0.4, 0.1}

local types_colors = {grass_color, guy_color, dog_color}


function map.load()
  -- map.tiles = table.load("maps")

  map.tiles = {}

  map.tile_size = 50
  map.offset_x = 375
  map.offset_y = 200
  map.margin = 5

  map.grass = 1
  map.guy = 2
  map.dog = 3

  for i=1,10 do
    map.tiles[i] = {}

    for j=1,10 do
      map.tiles[i][j] = map.grass
    end
  end

  map.tiles[5][5] = map.guy
  map.tiles[8][7] = map.dog
end


function handle_editing(dt)
  if lk.isDown("p") then
    table.save(map.tiles, "maps")
  end

end


function map.update(dt)
  handle_editing(dt)
end


function map.draw()
  for i=1,#map.tiles do
    for j=1,#map.tiles[i] do
      local tile = map.tiles[i][j]

      lg.setColor(types_colors[tile])
      lg.rectangle("fill", i * (50 + map.margin) + map.offset_x, j * (50 + map.margin) + map.offset_y, map.tile_size, map.tile_size)
    end
  end

  lg.setColor(1, 1, 1)
end

return map
