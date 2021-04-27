local ls = love.sound
local la = love.audio
local lg = love.graphics
local lk = love.keyboard
local lm = love.mouse


local utils = require "utils"
local ls = require "love_sprites"
local flux = require "flux"
local lsp = require "love_spines"
local collisions = require "collisions"

local world = require "world"
local player = require "player"
local map = require "map"


local sprites = {}
local spines = {}

local eye_animation


function love.load()
  lg.setBackgroundColor(0.7, 0.7, 0.7, 1)
  love.window.setMode(1400, 900, {msaa=4})
  love.window.setVSync(1)
  lg.setLineStyle("smooth")

  world.w = lg.getWidth()
  world.h = lg.getHeight()

  ls.prepare(world.sprites, {"gracz_animation"})

  lsp.prepare(spines, {"eye"})
  eye_animation = lsp.create_animation(spines, "eye")
  lsp.play_animation(spines, eye_animation, "idle", true)

  player.load()
  map.load()
end


local show_circle = false


function love.update(dt)
  world.t = world.t + dt

  flux.update(dt)

  ls.update(world.sprites, dt)
  lsp.update(spines, dt)

  if lk.isDown("escape") then
    love.event.quit(0)
  end

  player.update(dt)
  map.update(dt)

  lsp.add_animation(spines, eye_animation, 1350, 650, 0.25, 0.25)
end


function love.draw()
  lg.translate(0, world.h)
  lg.scale(1, -1)

  if show_circle then
    lg.setColor(1, 1, 1)
    lg.circle("line", player.x, player.y, player.r)
  end

  if lk.isDown("c") then
    show_circle = not show_circle
  end

  map.draw()

  ls.draw(world.sprites)
  lsp.draw(spines)
end
