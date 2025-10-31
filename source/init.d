module engine.init;

enum WINDOW_TITLE = "COMP 4300";

bool is_sdl_loaded() {
  import bindbc.sdl;
  auto ret = loadSDL();
  
  if(ret != sdlSupport) {
    return false;
  }

  return true;
}
