local ls = love.sound
local la = love.audio
local lg = love.graphics
local lk = love.keyboard

local utils = require "utils"
local ls = require "love_sprites"
local flux = require "flux"
local lsp = require "love_spines"


local w = 0;
local h = 0;

function love.load()
  lg.setBackgroundColor(0.7, 0.7, 0.7, 1)
  love.window.setMode(800, 600, {msaa=4})
  love.graphics.setLineStyle("smooth")

  w = lg.getWidth()
  h = lg.getHeight()

end

local t = 0

function love.update(dt)
  t = t + dt

  if lk.isDown("escape") then
    love.event.quit(0)
  end

end

function love.draw()

end
