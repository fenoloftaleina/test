local shaders = {}

shaders.example = {}
-- love.graphics.newShader[[
-- extern vec2 mouse;
-- vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)\
-- {
--   number pw = 1/love_ScreenSize.x;//pixel width
--   number ph = 1/love_ScreenSize.y;//pixel height
--
--   vec4 regular = Texel(texture, texture_coords);
--   // vec4 double = Texel(texture, texture_cords * 2);
--
--   // vec4 sum = regular * 0.5 + double * 0.5;
--
--   vec4 sum = regular;
--
--   vec4 pixel = vec4(sum.rgb, 1.0);
--
--   float r = 200;
--
--   // pixel.r = pixel.r * (
--   pixel.a =
--   r - distance(mouse, pixel_coords)
--   // )
--   ;
--
--   return pixel;
--
-- }
-- ]]

return shaders
