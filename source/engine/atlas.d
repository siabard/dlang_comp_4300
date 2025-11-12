module engine.atlas;

class Atlas {
  import bindbc.sdl;

  string name;
  string texture_name;
  int tile_width, tile_height;
  
  SDL_Rect[] rects;

  this(string name, string texture_name, int width, int height, SDL_Texture* texture) {
    this.name = name;
    this.tile_height = height;
    this.tile_width = width;
    this.texture_name = texture_name;
    
    int w, h;
    SDL_QueryTexture(texture,
		     null,
		     null,
		     &w, &h);
    
    int tile_col = w / tile_width;
    int tile_row = h / tile_height;

    this.rects.length = tile_col * tile_row;

    int idx = 0;
    foreach(tr; 0..tile_row) {
      foreach(tc; 0..tile_col) {
	SDL_Rect rect =  {
	  x: tc * tile_width,
	  y: tr * tile_height,
	  w: tile_width,
	  h: tile_height
	};
	this.rects[idx] = rect;
	idx++;
      }
    }
    
  }
}
