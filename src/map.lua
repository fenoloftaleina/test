local map = {
  platforms = {}
}

local lg = love.graphics
local lk = love.keyboard

local utils = require "utils"
local world = require "world"


function map.ij_to_xy(pos)
  pos.x = pos.i * (map.tile_size + map.margin)
  pos.y = pos.j * (map.tile_size + map.margin)
end


function map.prepare()
  map.hiders = {}

  map.tiles_overlay = {}
  for i=1,#map.tiles do
    map.tiles_overlay[i] = {}

    for j=1,#map.tiles[i] do
      map.tiles_overlay[i][j] = {active = false, opacity = 0}

      if map.tiles[i][j] == map.bush or map.tiles[i][j] == map.wall then
        map.hiders[#map.hiders + 1] = {i = i, j = j}
        map.ij_to_xy(map.hiders[#map.hiders])
      end
    end
  end
end


function map.load(map_name)
  map.tiles = table.load(map_name)

  map.name = map_name

  map.tile_size = 120
  map.offset_x = -50
  map.offset_y = -115
  map.margin = 5

  map.guy = -2
  map.dog = -3

  map.grass = 1
  map.bush = 2
  map.water = 3
  map.wall = 4
  map.bone = 5
  map.cat = 6

  map.colors_n = 6

  map.grass_color = {0.8, 0.8, 0.8}
  map.bush_color = {0.7, 0.8, 0.5}
  map.water_color = {0.6, 0.8, 1.0}
  map.wall_color = {0.5, 0.5, 0.5}
  map.bone_color = {1, 1, 1}
  map.cat_color = {0.6, 0.6, 0.5}

  map.types_colors = {map.grass_color, map.bush_color, map.water_color, map.wall_color, map.bone_color, map.cat_color}

  map.prepare()

  -- map.tiles = {}
  --
  -- for i=1,10 do
  --   map.tiles[i] = {}
  --
  --   for j=1,8 do
  --     map.tiles[i][j] = map.grass
  --   end
  -- end
  --
  -- map.tiles.guy_pos = {i = 5, j = 5}
  -- map.tiles.dog_pos = {i = 8, j = 7}
end


function map.tile_pos(tile)
  for i=1,#map.tiles do
    for j=1,#map.tiles do
      if map.tiles[i][j] == tile then
        return {x = i, y = j}
      end
    end
  end
end


function map.draw()
  for i=1,#map.tiles do
    for j=1,#map.tiles[i] do
      local tile = map.tiles[i][j]

      lg.setColor(map.types_colors[tile])
      local pos = {i = i, j = j}
      map.ij_to_xy(pos)
      lg.rectangle("fill", pos.x + map.offset_x, pos.y + map.offset_y, map.tile_size, map.tile_size)


      if map.tiles_overlay[i][j].opacity > 0 then
        lg.setColor(map.types_colors[tile][1] + 0.2, map.types_colors[tile][2], map.types_colors[tile][3] + 0.1, map.tiles_overlay[i][j].opacity)
        local pos = {i = i, j = j}
        map.ij_to_xy(pos)
        lg.rectangle("fill", pos.x + map.offset_x, pos.y + map.offset_y, map.tile_size, map.tile_size)
      end
    end
  end

  lg.setColor(1, 1, 1)
end

return map
