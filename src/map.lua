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

local clicked = false
local click_platform = {}
local selected


function map.load()
  map.platforms = {} --table.load("src/platforms")
end


function handle_editing(dt)
  if lk.isDown("p") then
    table.save(map.platforms, "src/platforms")
  end

  if lm.isDown(1) then
    local mx = lm.getX()
    local my = world.h - lm.getY()

    if selected then
      local diff_x = mx - click_platform.x1
      local diff_y = my - click_platform.y1
      click_platform.x1 = mx
      click_platform.y1 = my

      selected.x1 = selected.x1 + diff_x
      selected.y1 = selected.y1 + diff_y
      selected.x2 = selected.x2 + diff_x
      selected.y2 = selected.y2 + diff_y
    elseif not clicked then
      clicked = true

      local selected_i

      for i=1,#map.platforms do
        local platform = map.platforms[i]

        if mx >= platform.x1 and
          mx <= platform.x2 and
          my >= platform.y1 and
          my <= platform.y2 then
          selected = platform
          selected_i = i
        end
      end

      if selected and lk.isDown("d") then
        table.remove(map.platforms, selected_i)
      end

      click_platform = {}
      click_platform.x1 = mx
      click_platform.y1 = my

      if not selected then
        click_platform.x2 = mx
        click_platform.y2 = my

        table.insert(map.platforms, click_platform)
      end
    else
      click_platform.x2 = mx
      click_platform.y2 = my
    end
  elseif clicked then
    clicked = false

    if not selected then
      click_platform.x2 = lm.getX()
      click_platform.y2 = world.h - lm.getY()

      if click_platform.x2 < click_platform.x1 then
        local temp = click_platform.x1
        click_platform.x1 = click_platform.x2
        click_platform.x2 = temp
      end

      if click_platform.y2 < click_platform.y1 then
        local temp = click_platform.y1
        click_platform.y1 = click_platform.y2
        click_platform.y2 = temp
      end
    else
      selected = nil
    end
  end
end


function map.update(dt)
  handle_editing(dt)
end


function map.draw()
  for i=1,#map.platforms do
    local platform = map.platforms[i]

    lg.rectangle("line", platform.x1, platform.y1, platform.x2 - platform.x1, platform.y2 - platform.y1)
  end
end

return map
