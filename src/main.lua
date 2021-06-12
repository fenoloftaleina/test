local ls = love.sound
local la = love.audio
local lg = love.graphics
local lk = love.keyboard
local lm = love.mouse


local utils = require "utils"
local ls = require "core/love_sprites"
-- local lsp = require "core/love_spines"

local flux = require "libs/flux"

local world = require "world"
local map = require "map"

local shaders = require "shaders"


-- local bg = require "bg"


local join = require "join"



local canvas
local shader


local sprites = {}
local spines = {}

local eye_animation

local bg_sprites = {}

local bg_particles


function love.load()
  lg.setBackgroundColor(0.9, 0.9, 0.9, 1)
  love.window.setMode(1400, 900, {msaa=4})
  love.window.setVSync(1)
  -- love.window.setFullscreen(true)
  lg.setLineStyle("smooth")

  world.w = lg.getWidth()
  world.h = lg.getHeight()

  canvas = lg.newCanvas(world.w, world.h, {msaa=4})

  ls.prepare(world.sprites, {"gracz_animation"})
  ls.prepare(bg_sprites, {"bg_a_animation"})

  -- lsp.prepare(spines, {"eye"})
  -- eye_animation = lsp.create_animation(spines, "eye")
  -- lsp.play_animation(spines, eye_animation, "idle", true)


  -- bg.prepare()


  join.prepare()


  map.load()

  shader = shaders.example

  -- bg_particles = lg.newParticleSystem(bg_sprites.sprite_batches[1]:getTexture(), 10)
  bg_particles = lg.newParticleSystem(lg.newImage("resources/images/bg_a_animation0000.png"), 10)
  bg_particles:setParticleLifetime(1)
  bg_particles:setEmissionRate(2)
  -- local quads = bg_sprites.quads_data["bg_a_animation"].quad_objects
  -- bg_particles:setQuads(quads[1], quads[2], quads[3], quads[4], quads[5])

  bg_particles:setLinearAcceleration(-100, -100, 100, 100)
  bg_particles:setSpeed(50)
end


local show_circle = false

-- local updates = 0
-- local semi_fixed_updates = 0


local dt1_120 = 1 / 120
local dt1_60 = 1 / 60
local dt1_30 = 1 / 30
local dt_e = 0.002
local ticks_accumulator = 0


function semi_fixed_update(dt)
  -- semi_fixed_updates = semi_fixed_updates + 1

  world.t = world.t + dt

  flux.update(dt)

  ls.update(world.sprites, dt)
  ls.update(bg_sprites, dt)
  -- lsp.update(spines, dt)


  -- bg.update(dt)


  join.update(dt)


  if lk.isDown("escape") then
    -- print("updates " .. updates)
    -- print("semi_fixed_updates" .. semi_fixed_updates)
    love.event.quit(0)
  end

  map.update(dt)


  -- lsp.add_animation(spines, eye_animation, 1350, 650, 0.25, 0.25)


  bg_particles:update(dt)
end


local frame = false
local ticks
local max_ticks = 5


function love.update(delta_frame_time)
  -- updates = updates + 1

  if math.abs(delta_frame_time - dt1_60) < dt_e then
    ticks = 1
  elseif math.abs(delta_frame_time - dt1_120) < dt_e then
    ticks = 0.5
  elseif math.abs(delta_frame_time - dt1_30) < dt_e then
    ticks = 2
  else
    ticks = 0.0166 / delta_frame_time
  end

  frame = false

  ticks_accumulator = math.min(ticks_accumulator + ticks, max_ticks);
  while ticks_accumulator >= 1 do
    semi_fixed_update(dt1_60)
    ticks_accumulator = ticks_accumulator - 1;
    frame = true
  end
end


function love.draw()
  if frame then
    canvas:renderTo(function()
      lg.clear()
      lg.setBlendMode("alpha")


      -- bg.draw()


      join.draw()


      map.draw()

      lg.setColor(1, 1, 1, 0.5)
      -- ls.draw(bg_sprites)
      lg.setColor(1, 1, 1)

      ls.draw(world.sprites)
      -- lsp.draw(spines)


      -- lg.draw(bg_particles, 300, 300)


      lg.setCanvas()
    end)
  end

  lg.translate(0, world.h)
  lg.scale(1, -1)

  lg.setBlendMode("alpha", "premultiplied")

  lg.setColor(1, 1, 1, 1)

  -- lg.setShader(shader)
  -- shader.send(shader, "mouse", {lm.getX(), lm.getY()})
  lg.draw(canvas)
  -- lg.setShader()
end
