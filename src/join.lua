local join = {}


local lg = love.graphics
local lk = love.keyboard

local utils = require "utils"
local world = require "world"
local map = require "map"
local logic = require "logic"


local step_left = false
local step_right = false
local step_up = false
local step_down = false


local guy_color = {0.0, 0.0, 0.0}
local dog_color = {1.0, 0.8, 1.0}


function join.prepare()
  join.guy = {pos = {i = map.tiles.guy_pos.i, j = map.tiles.guy_pos.j, x = 0, y = 0}, next_pos = {}}
  join.dog = {pos = {i = map.tiles.dog_pos.i, j = map.tiles.dog_pos.j, x = 0, y = 0}, next_pos = {}}

  logic.prepare(join.guy, join.dog)
end


function join.update(dt)
  if map.editor_active then return end

  if lk.isDown("a") or lk.isDown("left") then
    if not step_left then
      step_left = true

      logic.run(join.guy, join.dog, {i = -1, j = 0})
    end
  elseif step_left then
    step_left = false
  end

  if lk.isDown("d") or lk.isDown("right") then
    if not step_right then
      step_right = true

      logic.run(join.guy, join.dog, {i = 1, j = 0})
    end
  elseif step_right then
    step_right = false
  end

  if lk.isDown("s") or lk.isDown("down") then
    if not step_down then
      step_down = true

      logic.run(join.guy, join.dog, {i = 0, j = -1})
    end
  elseif step_down then
    step_down = false
  end

  if lk.isDown("w") or lk.isDown("up") then
    if not step_up then
      step_up = true

      logic.run(join.guy, join.dog, {i = 0, j = 1})
    end
  elseif step_up then
    step_up = false
  end
end


function join.draw()
  lg.setLineWidth(10)

  lg.setColor(guy_color)
  lg.rectangle("fill", join.guy.pos.x + map.offset_x, join.guy.pos.y + map.offset_y, map.tile_size, map.tile_size)
  if join.guy.in_bush then
    lg.setColor(map.bush_color)
    lg.rectangle("line", join.guy.pos.x + map.offset_x + 5, join.guy.pos.y + map.offset_y + 5, map.tile_size - 10, map.tile_size - 10)
  end

  lg.setColor(dog_color)
  lg.rectangle("fill", join.dog.pos.x + map.offset_x, join.dog.pos.y + map.offset_y, map.tile_size, map.tile_size)
  if join.dog.in_bush then
    lg.setColor(map.bush_color)
    lg.rectangle("line", join.dog.pos.x + map.offset_x + 5, join.dog.pos.y + map.offset_y + 5, map.tile_size - 10, map.tile_size - 10)
  end

  lg.setColor(1, 1, 1)

  -- if join.dog.line then
  --   lg.line(join.dog.line[1] + map.offset_x, join.dog.line[2] + map.offset_y, join.dog.line[3] + map.offset_x, join.dog.line[4] + map.offset_y)
  -- end
end


return join
