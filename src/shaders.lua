local shaders = {}

shaders.example = love.graphics.newShader[[
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
  number pw = 1/love_ScreenSize.x;//pixel width
  number ph = 1/love_ScreenSize.y;//pixel height

  vec2 left = texture_coords;
  left.x -= pw * 2;
  vec2 top = texture_coords;
  top.y -= ph * 2;

  float r = Texel(texture, left).r;
  float g = Texel(texture, texture_coords).g;
  float b = Texel(texture, top).b;

  vec4 pixel = vec4(r, g, b, 1.0);

  // pixel.rgb = vec3(1.0,1.0,1.0);

  return pixel;

}
]]

return shaders
