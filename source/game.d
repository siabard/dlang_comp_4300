module engine.game;

struct SceneSetting {
  string name;
  string path;
}

class Game {
  import bindbc.sdl;
  import std.stdio;
  import std.string;

  SDL_Window* window;
  SDL_Renderer* renderer;

  SDL_Event event;
  bool is_running;

  SceneSetting[string] scene_settings;

  this(SDL_Window* window, SDL_Renderer* renderer) {
    this.window = window;
    this.renderer = renderer;
  }

  ~this() {
    if(this.renderer != null) {
      SDL_DestroyRenderer(this.renderer);
    }

    if(this.window != null) {
      SDL_DestroyWindow(window);
    }
  }

  void load_setting(string filepath) {
    File file = File(filepath, "r");
    
    while(!file.eof()) {
      string line = strip(file.readln());
      

      // 빈 줄도 무시한다.
       if(line.length == 0) {
	 continue;
       }

      // # 으로 시작하면 주석이라 무시한다.
      if(line[0] == '#') {
	continue;
      }


      // line 을 split 하여 각 앞이 어떤 값인지에 따라 각기 다른 형태의 설정을 한다.
      // window w, h : Window의 width와 height를 재설정 
      auto lineArray = line.split;
      
      // split 했는데 한 줄로 쭈욱이어졌다면
      // 그건 잘못된 포맷이다.
      if(lineArray.length  == 0) {
	continue;
      }

      if(lineArray[0] == "window") {
	writeln(" Width :" , lineArray[1], " Height :", lineArray[2]);
      } else if(lineArray[0] == "scene") {
	// scene 정보 등록 
	SceneSetting ss = { name: lineArray[1], path: lineArray[2] };
	scene_settings[ lineArray[1] ] = ss;
      }
      
    }
    file.close();

    // Scnene 정보 확인 
    foreach (scene_setting; this.scene_settings.values ) {
      writeln("name :", scene_setting.name , " path : ", scene_setting.path );
    }
  }

  void game_loop() {
    this.is_running = true;

    while(this.is_running) {
      while(SDL_PollEvent(&this.event)) {
	if( this.event.type == SDL_QUIT) {
	  this.is_running = false;
	}
      }
      
      SDL_RenderClear(this.renderer);
      
      SDL_RenderPresent(this.renderer);
    }
  }

}
