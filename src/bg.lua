local bg = {}

local lg = love.graphics
local sin = math.sin
local cos = math.cos
local pi = math.pi
local pow = math.pow

local ls = require "core/love_sprites"
local world = require "world"

function bg.prepare()
  bg.one = {sprites = {}, animation = 0}
  bg.two = {sprites = {}, animation = 0}

  bg.frame_t = 10.0
  bg.t = 0

  ls.prepare(bg.one.sprites, {"bg_a_animation"}, bg.frame_t)
  ls.prepare(bg.two.sprites, {"bg_b_animation"}, bg.frame_t)
  -- ls.prepare(bg.one.sprites, {"a_animation"}, bg.frame_t)
  -- ls.prepare(bg.two.sprites, {"b_animation"}, bg.frame_t)

  bg.one.animation = ls.create_animation(bg.one.sprites)
  ls.play_animation(bg.one.sprites, bg.one.animation, "bg_a_animation", true)
  -- ls.play_animation(bg.one.sprites, bg.one.animation, "a_animation", true)
  bg.two.animation = ls.create_animation(bg.two.sprites)
  ls.play_animation(bg.two.sprites, bg.two.animation, "bg_b_animation", true)
  -- ls.play_animation(bg.two.sprites, bg.two.animation, "b_animation", true)
  -- bg.two.sprites.animations[bg.two.animation].frame = 2
  bg.two.sprites.animations[bg.two.animation].frame_t = 1.5 * bg.frame_t
end

function bg.update(dt)
  ls.update(bg.one.sprites, dt)
  ls.update(bg.two.sprites, dt)

  ls.add_animation(bg.one.sprites, bg.one.animation)
  ls.add_animation(bg.two.sprites, bg.two.animation)

  bg.t = bg.t + dt
end

function bg.draw()
  local sin1 = (sin((bg.t / bg.frame_t - 0.25) * 2 * pi) + 1) * 0.5 * 0.5
  lg.setColor(1, 1, 1, sin1)
  ls.draw(bg.one.sprites, 0, 0, 0, 10, -10)
  local sin2 = (sin((bg.t / bg.frame_t - 0.75) * 2 * pi) + 1) * 0.5 * 0.5
  lg.setColor(1, 1, 1, sin2)
  ls.draw(bg.two.sprites, 0, 0, 0, 10, -10)
  lg.setColor(1, 1, 1, 1)
end

return bg
