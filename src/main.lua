lf = love.filesystem
ls = love.sound
la = love.audio
lp = love.physics
lt = love.thread
li = love.image
lm = love.math
lg = love.graphics
lk = love.keyboard

utils = require "utils"
ls = require "love_sprites"
flux = require "flux"

player = {
  x = 630,
  y = 310,
  w = 100,
  w2 = 50,
  h = 100,
  h2 = 50,
  visibility = 0,
  velocity = {
    x = 0,
    y = 0
  }
}

local sprites = {}
local chocolate_sprite = {}

player_states = {}
N = 15

w = 0;
h = 0;

pyszneczekoladka = la.newSource("sounds/pyszneczekoladka.mp3", "static")

local chocolates = {}

function love.load()
  lg.setBackgroundColor(0.7, 0.7, 0.7, 1)
  love.window.setMode(800, 600, {msaa=4})
  -- love.graphics.setLineStyle("smooth")

  w = lg.getWidth()
  h = lg.getHeight()

  for i=N,1,-1 do
    player_states[i] = utils.copy(player)
  end

  ls.prepare(sprites, {
    "gracz_animation"
  })

  -- persistence
  -- table.save({a = 1, b = { c = 3 }}, "asdf.table")
  -- utils.tprint(table.load("asdf.table"))

  chocolates[#chocolates + 1] = {x = 130, y = 100, dead = false, visibility = 1}
  chocolates[#chocolates + 1] = {x = 220, y = 370, dead = false, visibility = 1}
  chocolates[#chocolates + 1] = {x = 410, y = 260, dead = false, visibility = 1}
  chocolates[#chocolates + 1] = {x = 270, y = 50, dead = false, visibility = 1}
  chocolates[#chocolates + 1] = {x = 510, y = 120, dead = false, visibility = 1}


  ls.prepare(chocolate_sprite, {"czekoladka1"})
  ls.update(chocolate_sprite)
  ls.add(chocolate_sprite, "czekoladka1", 0, 0)

  la.setEffect("my-chorus", {rate = 3, depth = 2, type = "chorus"})
  pyszneczekoladka:setEffect("my-chorus")

  flux.to(player, 0.2, {visibility = 1}):ease("expoin"):delay(0.2)
end

every_t = 0.04
last_t = every_t

t = 0

function love.update(dt)
  t = t + dt

  flux.update(dt)
  ls.update(sprites, dt)

  if lk.isDown("escape") then
    love.event.quit(0)
  end

  a = 30
  s = 6
  m = 500

  if lk.isDown("a") or lk.isDown("left") then
    player.velocity.x = utils.clamp(-m, player.velocity.x - a, m)
  elseif lk.isDown("d") or lk.isDown("right") then
    player.velocity.x = utils.clamp(-m, player.velocity.x + a, m)
  else
    if player.velocity.x > 0 then
      player.velocity.x = utils.clamp(0, player.velocity.x - s, m)
    else
      player.velocity.x = utils.clamp(-m, player.velocity.x + s, 0)
    end
  end

  player.x = player.x + player.velocity.x * dt

  if lk.isDown("w") or lk.isDown("up") then
    player.velocity.y = utils.clamp(-m, player.velocity.y - a, m)
  elseif lk.isDown("s") or lk.isDown("down") then
    player.velocity.y = utils.clamp(-m, player.velocity.y + a, m)
  else
    if player.velocity.y > 0 then
      player.velocity.y = utils.clamp(0, player.velocity.y - s, m)
    else
      player.velocity.y = utils.clamp(-m, player.velocity.y + s, 0)
    end
  end

  player.y = player.y + player.velocity.y * dt


  -- last_t = last_t - dt

  -- if last_t < 0 then

  for i=N,2,-1 do
    player_states[i] = player_states[i - 1]
  end
  player_states[1] = utils.copy(player)

    -- last_t = every_t
  -- end


  ls.add(sprites, "gracz_animation", player.x, player.y)


  for i=1,#chocolates do
    if not chocolates[i].dead then
      if utils.distance_squared(player.x, player.y, chocolates[i].x, chocolates[i].y) < player.w * player.w then
        chocolates[i].dead = true
        -- la.stop()
        pyszneczekoladka:stop()
        pyszneczekoladka:play()

        flux.to(chocolates[i], 0.2, {visibility = 0})
      end
    end
  end
end

function love.draw()
  -- lg.push()
  -- lg.translate(- t * 300, 0)

  -- for i=N,1,-1 do
  --   e = 1 / i
  --   lg.setColor(0.4 * e, 0.8 * e, 0.9 * e)
  --
  --   if i == 1 then
  --     p = player
  --   else
  --     p = player_states[i]
  --   end
  --   lg.rectangle("line", p.x, p.y, p.w, p.h);
  -- end
  --
  --
  -- lg.setColor(0.9, 0.3, 0.4)
  -- mm = p.w * 0.25
  -- lg.rectangle("fill", p.x + (p.w - mm) * 0.5, p.y + (p.h - mm) * 0.5, mm, mm)

  -- lg.circle("line", player.x + player.w2, player.y + player.w2, player.w2)

  lg.setColor(1, 1, 1, player.visibility)
  ls.draw(sprites)

  for i=1,#chocolates do
    local vis = chocolates[i].visibility
    if vis > 0 then
      lg.setColor(1, 1, 1, vis)
      ls.draw(
        chocolate_sprite,
        chocolates[i].x + (1 - vis) * 50,
        chocolates[i].y + (1 - vis) * 50,
        0,
        vis)
    end
  end

  -- lg.pop()
end
