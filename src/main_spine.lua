-------------------------------------------------------------------------------
-- Spine Runtimes License Agreement
-- Last updated January 1, 2020. Replaces all prior versions.
--
-- Copyright (c) 2013-2020, Esoteric Software LLC
--
-- Integration of the Spine Runtimes into software or otherwise creating
-- derivative works of the Spine Runtimes is permitted under the terms and
-- conditions of Section 2 of the Spine Editor License Agreement:
-- http://esotericsoftware.com/spine-editor-license
--
-- Otherwise, it is permitted to integrate the Spine Runtimes into software
-- or otherwise create derivative works of the Spine Runtimes (collectively,
-- "Products"), provided that each user of the Products must obtain their own
-- Spine Editor license and redistribution of the Products in any form must
-- include this license and copyright notice.
--
-- THE SPINE RUNTIMES ARE PROVIDED BY ESOTERIC SOFTWARE LLC "AS IS" AND ANY
-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL ESOTERIC SOFTWARE LLC BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES,
-- BUSINESS INTERRUPTION, OR LOSS OF USE, DATA, OR PROFITS) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
-- THE SPINE RUNTIMES, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------------------------------------

local spine = require "spine-love.spine"

local skeleton

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

	local stateData = spine.AnimationStateData.new(skeletonData)
	local state = spine.AnimationState.new(stateData)
	state:setAnimationByName(0, animation, true)

	state:update(0.5)
	state:apply(skeleton)

	return { state = state, skeleton = skeleton }
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
	skeleton.state:apply(skeleton.skeleton)
	skeleton.skeleton:updateWorldTransform()

  if jumped then
    last_jump = t
    jumped = false
  elseif (not idle) and t - last_jump > 0.8 then
    skeleton.state:setAnimationByName(0, "idle", true)
    idle = true
  end
end

function spine_draw ()
	love.graphics.setBackgroundColor(0, 0, 0, 255)
	love.graphics.setColor(255, 255, 255)

	skeletonRenderer:draw(skeleton.skeleton)
end

function love.mousepressed (x, y, button, istouch)
  jumped = true
  idle = false
  skeleton.state:setAnimationByName(0, "jump", false)
end
