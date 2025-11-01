module dlang_comp_4300;

import std.stdio;
import bindbc.sdl;
import engine.init;
import engine.game;
import bindbc.loader;

int main()
{
  // DYNAMIC SDL 설정 
  auto loaded = is_sdl_loaded();

  if(!loaded) {
    writeln("CANNOT load SDL dynamically.");
    return 1;
  }
  

  int sdlInited = SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO );
  IMG_Init(IMG_INIT_PNG | IMG_INIT_JPG);

  if(sdlInited != 0) {
    writeln("SDL2 system cannot be initialized.");
    return 1;
  }

  SDL_Window* window;
  SDL_Renderer* renderer;


  window = SDL_CreateWindow(WINDOW_TITLE,
			    SDL_WINDOWPOS_UNDEFINED, 
			    SDL_WINDOWPOS_UNDEFINED, 
			    1024,
                            768, 
			    SDL_WINDOW_SHOWN);

  if(window == null) {
    writeln("Cannot create window");
    return 1;
  }


  renderer = SDL_CreateRenderer(window, -1, 
				SDL_RENDERER_ACCELERATED | 
				SDL_RENDERER_PRESENTVSYNC |
				SDL_RENDERER_TARGETTEXTURE);

  if(renderer == null) {
    writeln("Cannot create renderer");
    return 1;
  }


  // 전체 정의 완료
  Game aGame = new Game(window, renderer);

  aGame.load_setting("settings.txt");

  aGame.game_loop();


  SDL_Quit();
  return 0;
  
  
}
