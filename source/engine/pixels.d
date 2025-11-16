module engine.pixels;

import std.conv;
import bindbc.sdl;

void set_pixel(SDL_Surface *surface, int x, int y, uint pixel)
{
  uint* target_pixel = cast(uint*) (cast(ubyte*) surface.pixels
				    + y * surface.pitch
				    + x * surface.format.BytesPerPixel);
  *target_pixel = pixel;
}
