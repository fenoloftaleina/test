local editor = {}

local lg = love.graphics
local lk = love.keyboard

local flux = require "libs/flux"

local utils = require "utils"
local world = require "world"
local map = require "map"
local logic = require "logic"

local clicked_e = false
local clicked_j = false
local step_left = false
local step_right = false
local step_up = false
local step_down = false

function editor.prepare()
  map.editor_active = false
  editor.pos = {i = 5, j = 5}
end


function editor.update(dt)
  if lk.isDown("h") then
    if not clicked_e then
      clicked_e = true
      map.editor_active = not map.editor_active




      -- if map.editor_active then
      --   map.tiles_overlay[1][1].active = true
      --   flux.to(map.tiles_overlay[1][1], 1, {opacity = 1})
      -- else
      --   map.tiles_overlay[1][1].active = false
      --   flux.to(map.tiles_overlay[1][1], 1, {opacity = 0})
      -- end


    end
  elseif clicked_e then
    clicked_e = false
  end

  if not map.editor_active then return end

  if lk.isDown("p") then
    table.save(map.tiles, "maps")
  end


  if lk.isDown("a") or lk.isDown("left") then
    if not step_left then
      step_left = true

      editor.pos.i = editor.pos.i - 1
    end
  elseif step_left then
    step_left = false
  end

  if lk.isDown("d") or lk.isDown("right") then
    if not step_right then
      step_right = true

      editor.pos.i = editor.pos.i + 1
    end
  elseif step_right then
    step_right = false
  end

  if lk.isDown("s") or lk.isDown("down") then
    if not step_down then
      step_down = true

      editor.pos.j = editor.pos.j - 1
    end
  elseif step_down then
    step_down = false
  end

  if lk.isDown("w") or lk.isDown("up") then
    if not step_up then
      step_up = true

      editor.pos.j = editor.pos.j + 1
    end
  elseif step_up then
    step_up = false
  end

  if lk.isDown("j") then
    if not clicked_j then
      clicked_j = true

      map.tiles[editor.pos.i][editor.pos.j] =
        (map.tiles[editor.pos.i][editor.pos.j] % map.colors_n) + 1
    end
  elseif clicked_j then
    clicked_j = false
  end

  map.ij_to_xy(editor.pos)
end


function editor.draw()
  if map.editor_active then
    lg.setColor(0.7, 0.2, 0.3)
    lg.setLineWidth(5)
    lg.rectangle("line", editor.pos.x + map.offset_x, editor.pos.y + map.offset_y, map.tile_size, map.tile_size)
    lg.setColor(1, 1, 1)
  end
end


return editor
