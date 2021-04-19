local ls = {}

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


function prepare_sprite_data(sprites, name, images)
  sprites.sprites_data[name] = {
    quads_data = {}
  }

  if #images > 1 then
    sprites.sprites_data[name].frames = #images
  end

  for i, image in ipairs(images) do
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

    table.insert(sprites.sprites_data[name].quads_data, {
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
  sprites.sprites_data = {}
  sprites.sprite_batches = {}
  sprites.current_atlas = {}
  sprites.current_atlas.batch_id = 0
  sprites.frame_t = frame_t or 0.1
  add_batch(sprites)

  for i, name in ipairs(names) do
    images = {}

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

    prepare_sprite_data(sprites, name, images)

  end

  batch_prepared(sprites)

  sprites.current_atlas = nil
end


function ls.update(sprites, dt)
  for i, sprite_batch in ipairs(sprites.sprite_batches) do
    sprite_batch:clear()
  end

  for i, sprite_data in pairs(sprites.sprites_data) do
    sprite_data.next_current_frame = nil

    if sprite_data.current_frame then
      sprite_data.current_frame_t = sprite_data.current_frame_t - dt

      if sprite_data.current_frame_t < 0 then
        sprite_data.current_frame_t = sprite_data.current_frame_t + sprites.frame_t
        sprite_data.current_frame = sprite_data.current_frame % sprite_data.frames + 1
      end
    end
  end
end


function ls.add(sprites, name, x, y)
  quad_id = 1

  if sprites.sprites_data[name].frames then
    if not sprites.sprites_data[name].current_frame then
      sprites.sprites_data[name].current_frame = 1
      sprites.sprites_data[name].current_frame_t = sprites.frame_t
    end
    sprites.sprites_data[name].next_current_frame = sprites.sprites_data[name].current_frame

    quad_id = sprites.sprites_data[name].current_frame
  end

  quad_data = sprites.sprites_data[name].quads_data[quad_id]

  sprite_batch = sprites.sprite_batches[quad_data.batch_id]

  sprite_batch:add(quad_data.quad, x, y)
end


function ls.draw(sprites, x, y, r, s)
  x = x or 0
  y = y or 0
  r = r or 0
  s = s or 1

  for i, sprite_batch in ipairs(sprites.sprite_batches) do
    sprite_batch:flush()
    lg.draw(sprite_batch, x, y, r, s, s)
  end

  for _, sprite_data in pairs(sprites.sprites_data) do
    sprite_data.current_frame = sprite_data.next_current_frame
  end
end


return ls
