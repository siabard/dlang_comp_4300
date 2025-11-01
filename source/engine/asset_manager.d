module engine.asset_manager;

import bindbc.sdl;

class AssetManager {
  import std.stdio;
  // Textures
  SDL_Texture*[string] textures;

  this() {
  }


  ~this() {
    writeln("AssetManager is destroyed");
  }


  void clean_up() {
    // remove all textures 
    foreach(texture; this.textures.byValue()) {
      if(texture != null) {
	SDL_DestroyTexture(texture);
      }
    }

  }
}
