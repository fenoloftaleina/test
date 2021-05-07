local lk = love.keyboard
local lm = love.mouse

local utils = require "utils"
local ls = require "core/love_sprites"
local world = require "world"
local map = require "map"
local collisions = require "collisions"

local player = {
  x = 150,
  y = 350,
  r = 35,
  velocity = {
    x = 0,
    y = 0
  },
  animation = {},
  collision = false
}


local jump_height = 150
local time_to_apex = 0.3
local gravity = - 2 * jump_height / (time_to_apex * time_to_apex)
local initial_jump_v = math.sqrt(2 * (- gravity) * jump_height)
local gravity_clamp = -800

local acceleration_x = 2000
local damping = 10
local dampen = 800
local clamp_x = 400

local grounded = false

local jump = false


function player.load()
  player.animation = ls.create_animation(world.sprites)
  ls.play_animation(world.sprites, player.animation, "gracz_animation", true)
end


function stop_jump()
  jump = false
  if player.velocity.y > 0 then
    player.velocity.y = 0
  end
end


function check_collisions(already_checked)
  local chosen_dx, chosen_dy = 0, 0
  local min_d = 99999

  for i=1,#map.platforms do
    local platform = map.platforms[i]

    local collision, d, dx, dy
    collision, d, dx, dy = collisions.circle_rect(
      player.x, player.y, player.r, platform.x1, platform.y1, platform.x2, platform.y2)

    if collision then
      player.collision = true

      if d < min_d then
        chosen_dx = dx
        chosen_dy = dy

        min_d = d
      end
    end
  end

  if player.collision then
    player.collided(chosen_dx, chosen_dy)

    if not already_checked then
      check_collisions(true)
    end
  end
end


function player.update(dt)
  if lk.isDown("r") then
    player.x = 150
    player.y = 650
  end

  if lk.isDown("a") or lk.isDown("left") then
    player.velocity.x =
      utils.clamp(-clamp_x, player.velocity.x - acceleration_x * dt, clamp_x)
  elseif lk.isDown("d") or lk.isDown("right") then
    player.velocity.x =
      utils.clamp(-clamp_x, player.velocity.x + acceleration_x * dt, clamp_x)
  else
    -- local new_velocity =
    -- if player.velocity.x > 0 then
      player.velocity.x = player.velocity.x / (1 + damping * dt)
    -- else
      -- player.velocity.x = utils.clamp(-clamp_x, player.velocity.x + dampen * dt, 0)
    -- end
  end

  if lk.isDown("w") or lk.isDown("up") or lk.isDown("space") then
    if grounded and not jump then
      jump = true
      grounded = false
      player.velocity.y = initial_jump_v
    end
  elseif jump then
    stop_jump()
  end

  player.velocity.y = utils.clamp(gravity_clamp, player.velocity.y + gravity * dt, 100000)
  player.x = player.x + player.velocity.x * dt
  player.y = player.y + player.velocity.y * dt


  check_collisions()


  -- ls.add(world.sprites, "gracz_animation", player.x - 50, player.y + 50)
end


function player.collided(dx, dy)
  player.x = player.x - dx
  player.y = player.y - (dy * 1.0002)

  if dy < 0 then
    grounded = true
  elseif dy > 0 then
    stop_jump()
  end
end


return player
