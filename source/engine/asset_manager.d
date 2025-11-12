module engine.asset_manager;

import bindbc.sdl;

class AssetManager {
  import std.stdio;
  import engine.atlas;
  import engine.animation;

  // Textures
  SDL_Texture*[string] textures;

  // Atlases
  Atlas[string] atlases;

  // Animation
  Animation[string] animations;

  this() {
  }


  ~this() {
    writeln("AssetManager is destroyed");
  }


  void clean_up() {
    // remove all atlases
    foreach(atlas; this.textures) {
      destroy(atlas);
    }

    // remove all textures 
    foreach(texture; this.textures.byValue()) {
      if(texture != null) {
	SDL_DestroyTexture(texture);
      }
    }

  }
}
