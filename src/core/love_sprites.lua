local ls = {}

local lg = love.graphics
local utils = require "utils"

canvas_size = 1024
separator = 1


function add_batch(sprites)
  sprites.current_atlas = {
    batch_id = sprites.current_atlas.batch_id + 1,
    canvas = lg.newCanvas(canvas_size, canvas_size),
    x = 0,
    y = 0,
    max_y = 0
  }
end


function batch_prepared(sprites)
  table.insert(sprites.sprite_batches, lg.newSpriteBatch(sprites.current_atlas.canvas))
end


function prepare_quad_data(sprites, name, images)
  sprites.quads_data[name] = {
    quad_objects = {}
  }

  if #images > 1 then
    sprites.quads_data[name].frames = #images
  end

  for i=1,#images do
    image = images[i]
    w = image:getWidth()
    h = image:getHeight()

    if sprites.current_atlas.x + w + separator > canvas_size then
      sprites.current_atlas.x = 0
      sprites.current_atlas.y = sprites.current_atlas.max_y + separator
    end

    if sprites.current_atlas.y + h + separator > canvas_size then
      batch_prepared(sprites)
      add_batch(sprites)
    elseif sprites.current_atlas.y + h + separator > sprites.current_atlas.max_y then
      sprites.current_atlas.max_y = sprites.current_atlas.y + h + separator
    end

    sprites.current_atlas.canvas:renderTo(function()
      lg.draw(image, sprites.current_atlas.x, sprites.current_atlas.y)
    end)

    table.insert(sprites.quads_data[name].quad_objects, {
      quad = lg.newQuad(sprites.current_atlas.x, sprites.current_atlas.y, w, h, canvas_size, canvas_size),
      batch_id = sprites.current_atlas.batch_id
    })

    sprites.current_atlas.x = sprites.current_atlas.x + w + separator
  end
end


function new_image(name)
  filename = "resources/images/" .. name .. ".png"

  if love.filesystem.getInfo(filename) then
    return lg.newImage(filename)
  end

  return nil
end


function ls.prepare(sprites, names, frame_t)
  sprites.quads_data = {}
  sprites.sprite_batches = {}
  sprites.animations = {}
  sprites.current_atlas = {}
  sprites.current_atlas.batch_id = 0
  sprites.frame_t = frame_t or 0.1
  add_batch(sprites)

  for i=1,#names do
    local name = names[i]
    local images = {}

    if name:sub(-9) == "animation" then -- animation
      frame = 1
      image = new_image(name .. frame)

      while true do
        if image then
          table.insert(images, image)

          frame = frame + 1
          image = new_image(name .. frame)
        else
          break
        end
      end
    else
      table.insert(images, new_image(name))
    end

    prepare_quad_data(sprites, name, images)

  end

  batch_prepared(sprites)

  sprites.current_atlas = nil
end


function ls.update(sprites, dt)
  for i=1,#sprites.sprite_batches do
    sprites.sprite_batches[i]:clear()
  end

  for i=1,#sprites.animations do
    local animation = sprites.animations[i]
    if not animation.dead and animation.run then
      animation.frame_t = animation.frame_t - dt
      if animation.frame_t < 0 then
        animation.frame_t = animation.frame_t + sprites.frame_t
        animation.frame = animation.frame + 1
        if animation.frame == animation.frames + 1 then
          if animation.then_animations then
            local then_animation = table.remove(animation.then_animations)
            if next(animation.then_animations) == nil then
              animation.then_animations = nil
            end
            ls.play_animation(sprites, animation.id, then_animation, animation.loop, animation.then_animations)
          elseif animation.loop then
            animation.frame = 1
          else
            animation.frame = animation.frames
            animation.run = false
          end
        end
      end
    end
  end
end


function add_quad(sprites, name, quad_id, x, y, r, sx, sy)
  quad_object = sprites.quads_data[name].quad_objects[quad_id]

  sprite_batch = sprites.sprite_batches[quad_object.batch_id]

  sprite_batch:add(quad_object.quad, x, y, r, sx, -(sy or 1))
end


function ls.add(sprites, name, x, y, r, sx, sy)
  add_quad(sprites, name, 1, x, y, r, sx, sy)
end


function ls.add_animation(sprites, animation_id, x, y, r, sx, sy)
  local animation = sprites.animations[animation_id]
  add_quad(sprites, animation.name, animation.frame, x, y, r, sx, sy)
end


function ls.create_animation(sprites)
  local new_animation_id = nil

  for i=1,#sprites.animations do
    if sprites.animations[i].dead then
      new_animation_id = i
      break
    end
  end

  new_animation_id = new_animation_id or #sprites.animations + 1
  sprites.animations[new_animation_id] = {id = new_animation_id}

  return new_animation_id
end


function ls.play_animation(sprites, animation_id, name, loop, then_animations)
  local animation = sprites.animations[animation_id]

  animation.name = name
  animation.run = true
  animation.loop = loop
  if then_animations then
    animation.then_animations = {}
    for i=1,#then_animations do -- reverse
      table.insert(animation.then_animations, then_animations[i])
    end
  end
  animation.frame = 1
  animation.frames = sprites.quads_data[name].frames
  animation.frame_t = sprites.frame_t
end


function ls.stop_animation(sprites, animation_id)
  local animation = sprites.animations[animation_id]

  animation.loop = false
  animation.then_animation = nil
  animation.run = false
end


function ls.destroy_animation(sprites, animation_id)
  sprites.animations[animation_id].dead = true
end


function ls.draw(sprites, x, y, r, s)
  x = x or 0
  y = y or 0
  r = r or 0
  s = s or 1

  for i=1,#sprites.sprite_batches do
    local sprite_batch = sprites.sprite_batches[i]
    sprite_batch:flush()
    lg.draw(sprite_batch, x, y, r, s, s)
  end
end


return ls
