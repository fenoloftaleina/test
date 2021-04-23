




local spine = require "spine-love.spine"

local skeleton

local lsp = {}

function lsp.prepare()

end

function lsp.update()

end

function lsp.add()

end

function lsp.draw()

end



-- load atlas, load skeleton data, and then build objects with skeleton and state on that

function load_skeleton (file, animation, x, y, scale)
	local loader = function (path) return love.graphics.newImage("data/" .. path) end
	local atlas = spine.TextureAtlas.new(spine.utils.readFile("data/" .. file .. ".atlas"), loader)

	local json = spine.SkeletonJson.new(spine.AtlasAttachmentLoader.new(atlas))
	json.scale = scale or 1
	local skeletonData = json:readSkeletonDataFile("data/" .. file .. ".json")
	local skeleton = spine.Skeleton.new(skeletonData)
	skeleton.x = x
	skeleton.y = y
	skeleton.scaleY = -1
	skeleton:setToSetupPose()

	local skeleton2 = spine.Skeleton.new(skeletonData)
	skeleton2.x = x
	skeleton2.y = y
	skeleton2.scaleY = -1
	skeleton2:setToSetupPose()

	local stateData = spine.AnimationStateData.new(skeletonData)
	local state = spine.AnimationState.new(stateData)
	state:setAnimationByName(0, animation, true)

	state:update(0.5)
	state:apply(skeleton)

	-- local stateData2 = spine.AnimationStateData.new(skeletonData)
	local state2 = spine.AnimationState.new(stateData)
	state2:setAnimationByName(0, "jump", true)

	state2:update(0.5)
	state2:apply(skeleton2)

	return { state = state, skeleton = skeleton,
  state2 = state2, skeleton2 = skeleton2
}
end

function spine_load()
	skeletonRenderer = spine.SkeletonRenderer.new(true)
  skeleton = load_skeleton("eye", "idle", 400, 500)
end

local jumped = false
local idle = true
local t = 0
local last_jump = 0

function spine_update(dt)
  t = t + dt

	skeleton.state:update(dt)
	skeleton.state2:update(dt)

  if jumped then
    last_jump = t
    jumped = false
  elseif (not idle) and t - last_jump > 0.8 then
    skeleton.state:setAnimationByName(0, "idle", true)
    idle = true
  end
end

function spine_draw ()
	-- love.graphics.setBackgroundColor(0, 0, 0, 255)
	-- love.graphics.setColor(255, 255, 255)

	skeleton.state:apply(skeleton.skeleton)
	skeleton.skeleton:updateWorldTransform()

	skeletonRenderer:draw(skeleton.skeleton)

	skeleton.state2:apply(skeleton.skeleton2)
	skeleton.skeleton2:updateWorldTransform()

	skeletonRenderer:draw(skeleton.skeleton2)
end

function love.mousepressed (x, y, button, istouch)
  jumped = true
  idle = false
  skeleton.state:setAnimationByName(0, "jump", false)
end




















local ls = love.sound
local la = love.audio
local lg = love.graphics
local lk = love.keyboard

local utils = require "utils"
local ls = require "love_sprites"
local flux = require "flux"

require 'spine-love/spine'

local player = {
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

local player_states = {}
local N = 15

local w = 0;
local h = 0;

local pyszneczekoladka = la.newSource("sounds/pyszneczekoladka.mp3", "static")

local chocolates = {}

local particles

function love.load()
  lg.setBackgroundColor(0.7, 0.7, 0.7, 1)
  love.window.setMode(800, 600, {msaa=4})
  love.graphics.setLineStyle("smooth")

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

  -- la.setEffect("my-chorus", {rate = 3, depth = 2, type = "chorus"})
  -- pyszneczekoladka:setEffect("my-chorus")

  flux.to(player, 0.2, {visibility = 1}):ease("expoin"):delay(0.2)


  particles = lg.newParticleSystem(lg.newImage("images/gracz_animation1.png"))
  particles:setParticleLifetime(0.7)
  particles:setEmissionRate(15)
  particles:setEmissionArea("uniform", 50, 50, 0, true)
  particles:setLinearAcceleration(-20, 50, -50, 100)
  particles:setColors(1, 1, 1, 0.1, 1, 1, 1, 0.5)


  spine_load()
end

local every_t = 0.04
local last_t = every_t

local t = 0

function love.update(dt)
  t = t + dt

  flux.update(dt)
  ls.update(sprites, dt)

  spine_update(dt)
  -- spine_animation:update(dt)

  particles:update(dt)

  if lk.isDown("escape") then
    love.event.quit(0)
  end

  local a = 30
  local s = 6
  local m = 500

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

  lg.setColor(0.5, 0.5, 0.5, 1)
  lg.setLineWidth(3)

  -- lg.line(100, 100, 500, 100)
  -- lg.arc("line", "open", 500, 150, 50, math.rad(0), math.rad(-90))
  -- lg.line(550, 150, 550, 450)

  local segments = {
    -- 550, 50, 600, 100
  }
  local ox, oy, r  = 525, 75, 50
  local x, y = ox, oy
  segments[1] = x
  segments[2] = y
  for i=1,10 do
    x = x + 10 / i
    y = y + 10
    segments[i * 2 + 1] = x
    segments[i * 2 + 2] = y
  end
  lg.line(segments)


  -- local n = 20
  -- local step = 500 / n
  -- local x1, y1, x2, y2
  -- local sin = math.sin
  -- local offset = 200
  -- local sin_scale = 1000 / n
  -- local sin_amplitude = 50
  -- for i=1,n do
  --   x1 = i * step
  --   y1 = sin(i * sin_scale + t) * sin_amplitude
  --   x2 = x1 + step
  --   y2 = sin((i + 1) * sin_scale + t) * sin_amplitude
  --   lg.line(x1 + offset, y1 + offset, x2 + offset, y2 + offset)
  -- end


  lg.draw(particles, 300, 300)




  lg.setColor(1, 1, 1, 1)
  spine_draw()
  -- spine_animation:draw(400, 400)


  -- lg.pop()
end
