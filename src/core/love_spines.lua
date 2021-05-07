local lsp = {}

local lg = love.graphics
local utils = require "../utils"

local spine = require "../libs/spine-love.spine"
local skeleton_renderer = spine.SkeletonRenderer.new(true)

-- load atlas, load skeleton data, and then build objects with skeleton and state on that


function load_skeleton_data(file)
	local loader = function (path) return love.graphics.newImage("resources/spines/" .. path) end
	local atlas = spine.TextureAtlas.new(spine.utils.readFile("resources/spines/" .. file .. ".atlas"), loader)
	local json = spine.SkeletonJson.new(spine.AtlasAttachmentLoader.new(atlas))
	json.scale = scale or 1
	local skeleton_data = json:readSkeletonDataFile("resources/spines/" .. file .. ".json")

  return skeleton_data
end


function lsp.prepare(spines, names)
  spines.animations = {}
  spines.skeletons_data = {}

  for i=1,#names do
    local name = names[i]
    spines.skeletons_data[name] = load_skeleton_data(name)
  end
end


function lsp.update(spines, dt)
  for i=1,#spines.animations do
    local animation = spines.animations[i]
    if not animation.dead and animation.run then
      animation.state:update(dt)
    end
  end
end


function lsp.add_animation(spines, animation_id, x, y, sx, sy)
  local animation = spines.animations[animation_id]
  animation.draw = true
  animation.skeleton.x = x or 0
  animation.skeleton.y = y or 0
  animation.skeleton.scaleX = sx or 1
  animation.skeleton.scaleY = sy or 1
end


function lsp.create_animation(spines, skeleton_name)
  local new_animation_id = nil

  for i=1,#spines.animations do
    if spines.animations[i].dead then
      new_animation_id = i
      break
    end
  end

  new_animation_id = new_animation_id or #spines.animations + 1

  local skeleton_data = spines.skeletons_data[skeleton_name]
  local skeleton = spine.Skeleton.new(skeleton_data)
  local state = spine.AnimationState.new(spine.AnimationStateData.new(skeleton_data))

  skeleton.x, skeleton.y, skeleton.scaleY = 0, 0, -1
	skeleton:setToSetupPose()

  spines.animations[new_animation_id] = {
    id = new_animation_id,
    state = state,
    skeleton = skeleton,
    run = false
  }

  return new_animation_id
end


function lsp.play_animation(spines, animation_id, name, loop)
  local animation = spines.animations[animation_id]
  animation.run = true
  animation.state:setAnimationByName(0, name, loop)
  animation.state:update(0.5)
  animation.state:apply(animation.skeleton)
end


function lsp.stop_animation(sprites, animation_id)
  local animation = spines.animations[animation_id]
  animation.state:stop()
  animation.run = false
end


function lsp.destroy_animation(sprites, animation_id)
  sprites.animations[animation_id].dead = true
end


function lsp.draw(spines)
  for i=1,#spines.animations do
    local animation = spines.animations[i]

    if animation.draw then
      animation.state:apply(animation.skeleton)
      animation.skeleton:updateWorldTransform()
      skeleton_renderer:draw(animation.skeleton)
    end

    animation.draw = false
  end
end


return lsp
