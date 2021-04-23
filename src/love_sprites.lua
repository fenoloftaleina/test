local ls = {}

local lg = love.graphics
local utils = require "utils"

canvas_size = 500
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
  filename = "images/" .. name .. ".png"

  if love.filesystem.getInfo(filename) then
    return lg.newImage(filename)
  end

  return nil
end


function ls.prepare(sprites, names, frame_t)
  sprites.quads_data = {}
  sprites.sprite_batches = {}
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

  for i, quad_data in pairs(sprites.quads_data) do
    quad_data.next_current_frame = nil

    if quad_data.current_frame then
      quad_data.current_frame_t = quad_data.current_frame_t - dt

      if quad_data.current_frame_t < 0 then
        quad_data.current_frame_t = quad_data.current_frame_t + sprites.frame_t
        quad_data.current_frame = quad_data.current_frame % quad_data.frames + 1
      end
    end
  end
end


-- function


function ls.add(sprites, name, x, y)
  quad_id = 1

  if sprites.quads_data[name].frames then
    if not sprites.quads_data[name].current_frame then
      sprites.quads_data[name].current_frame = 1
      sprites.quads_data[name].current_frame_t = sprites.frame_t
    end
    sprites.quads_data[name].next_current_frame = sprites.quads_data[name].current_frame

    quad_id = sprites.quads_data[name].current_frame
  end

  quad_object = sprites.quads_data[name].quad_objects[quad_id]

  sprite_batch = sprites.sprite_batches[quad_object.batch_id]

  sprite_batch:add(quad_object.quad, x, y)
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

  for _, quad_data in pairs(sprites.quads_data) do
    quad_data.current_frame = quad_data.next_current_frame
  end
end


return ls
